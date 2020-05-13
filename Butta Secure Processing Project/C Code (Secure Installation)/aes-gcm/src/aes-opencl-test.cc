//
//  aes-opencl-test.cc
//

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#include <iomanip>
#include <sstream>
#include <memory>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <chrono>

#include "aes.h"
#include "logging.h"
#include "opencl.h"

using namespace std::chrono;

/* aes_opencl_test */

struct aes_opencl_test
{
    opencl_ptr cl;
    opencl_device_list gpu_devices;
    opencl_device_ptr chosen_device;
    opencl_context_ptr clctx;
    opencl_command_queue_ptr clcmdqueue;
    
    void initCL()
    {
        // get gpu devices
        cl = opencl_ptr(new opencl());
        gpu_devices = cl->getDevices("gpu");
        if (gpu_devices.size() == 0) {
            log_error_exit("no OpenCL gpu devices found");
        }
        
        // find device with largest workgroup size
        size_t best_workgroupsize = 0;
        for (opencl_device_ptr device : gpu_devices) {
            if (device->getMaxWorkGroupSize() > best_workgroupsize) {
                best_workgroupsize = device->getMaxWorkGroupSize();
                chosen_device = device;
            }
        }
        log_debug("using device: %s", chosen_device->getName().c_str());
        chosen_device->print();
        
        // create context
        opencl_device_list use_devices{ chosen_device };
        clctx = cl->createContext(use_devices, false);
        clcmdqueue = clctx->createCommandQueue(chosen_device, 0);
    }
    
    void testCL()
    {
        int a[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
        int b[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
        int c[8];
        
        opencl_program_ptr testprog = clctx->createProgram("src/test.cl");
        
        opencl_buffer_ptr abuffer = clctx->createBuffer(CL_MEM_READ_ONLY, sizeof(a), NULL);
        opencl_buffer_ptr bbuffer = clctx->createBuffer(CL_MEM_READ_ONLY, sizeof(b), NULL);
        opencl_buffer_ptr cbuffer = clctx->createBuffer(CL_MEM_WRITE_ONLY, sizeof(c), NULL);
        
        opencl_kernel_ptr addkernel = testprog->getKernel("add");
        addkernel->setArg(0, abuffer);
        addkernel->setArg(1, bbuffer);
        addkernel->setArg(2, cbuffer);
        
        clcmdqueue->enqueueWriteBuffer(abuffer, true, 0, sizeof(a), a);
        clcmdqueue->enqueueWriteBuffer(bbuffer, true, 0, sizeof(b), b);
        clcmdqueue->enqueueNDRangeKernel(addkernel, opencl_dim(8));
        clcmdqueue->enqueueReadBuffer(cbuffer, true, 0, sizeof(c), c)->wait();
        
        bool error = false;
        for (int i = 0; i < 8; i++) {
            error |= (a[i] + b[i] != c[i]);
        }
        log_debug("%s Add Test: %s", __func__, error ? "Failed" : "Success");
    }

    void testAES()
    {
        opencl_program_ptr aesprog = clctx->createProgram("src/aes.cl");
        opencl_kernel_ptr aes_rijndael_encrypt_kernel = aesprog->getKernel("aes_rijndael_encrypt");
        opencl_kernel_ptr aes_rijndael_decrypt_kernel = aesprog->getKernel("aes_rijndael_decrypt");
        
        static const int num_runs = 5;
        static const aes_uchar key[16] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F };
        static const size_t MEGA_BYTE = 1024 * 1024;
        static const size_t DATA_SIZE = 32 * MEGA_BYTE;
        
        aes_uchar *pt = new aes_uchar[DATA_SIZE];
        if (!pt) log_error_exit("pt alloc_failed");
        char c = 0x01;
        for (size_t j = 0; j < DATA_SIZE; j+= sizeof(int)) {
            pt[j] = (c ^= c * 7);
        }
        
        aes_uchar *ct = new aes_uchar[DATA_SIZE];
        if (!ct) log_error_exit("pt alloc_failed");
        memset((void*)ct, 0x00, DATA_SIZE);

        aes_uchar *dt = new aes_uchar[DATA_SIZE];
        if (!dt) log_error_exit("pt alloc_failed");
        memset((void*)dt, 0x00, DATA_SIZE);
        
        void *rk = aes_encrypt_init(key, 16);

        opencl_buffer_ptr rk_buf = clctx->createBuffer(CL_MEM_READ_WRITE, AES_PRIV_SIZE, NULL);
        opencl_buffer_ptr pt_buf = clctx->createBuffer(CL_MEM_READ_WRITE, DATA_SIZE, NULL);
        opencl_buffer_ptr ct_buf = clctx->createBuffer(CL_MEM_READ_WRITE, DATA_SIZE, NULL);
        
        aes_rijndael_encrypt_kernel->setArg(0, rk_buf);
        aes_rijndael_encrypt_kernel->setArg(1, (cl_int)10);
        aes_rijndael_encrypt_kernel->setArg(2, pt_buf);
        aes_rijndael_encrypt_kernel->setArg(3, ct_buf);

        clcmdqueue->enqueueWriteBuffer(rk_buf, true, 0, AES_PRIV_SIZE, rk)->wait();
        
        // Memory reads and writes
        for (int i = 0; i < num_runs; i++) {
            const auto t1 = high_resolution_clock::now();
            clcmdqueue->enqueueWriteBuffer(pt_buf, true, 0, DATA_SIZE, pt)->wait();
            const auto t2 = high_resolution_clock::now();
            clcmdqueue->enqueueReadBuffer(ct_buf, true, 0, DATA_SIZE, ct)->wait();
            const auto t3 = high_resolution_clock::now();
            
            float write_time_sec = duration_cast<microseconds>(t2 - t1).count() / 1000000.0;
            float read_time_sec = duration_cast<microseconds>(t3 - t2).count() / 1000000.0;
            log_debug("memory test %ld MB write: %f sec (%f MB/sec) read: %f sec (%f MB/sec)",
                      DATA_SIZE / MEGA_BYTE,
                      write_time_sec, DATA_SIZE / MEGA_BYTE / write_time_sec,
                      read_time_sec, DATA_SIZE / MEGA_BYTE / read_time_sec);
        }
        
        // Copy host buffer to device -> GPU encrypt -> Copy device buffer to host
        for (int i = 0; i < num_runs; i++) {
            const auto t1 = high_resolution_clock::now();
            
            // GPU encrypt
            clcmdqueue->enqueueWriteBuffer(pt_buf, true, 0, DATA_SIZE, pt);
            clcmdqueue->enqueueNDRangeKernel(aes_rijndael_encrypt_kernel, opencl_dim(DATA_SIZE / 16), opencl_dim(256));
            clcmdqueue->enqueueReadBuffer(ct_buf, true, 0, DATA_SIZE, ct)->wait();
            
            const auto t2 = high_resolution_clock::now();
            
            // CPU encrypt
            for (size_t j = 0; j < DATA_SIZE; j += 16) {
                aes_rijndael_encrypt((aes_uint*)rk, 10, pt + j, dt + j);
            }
            
            const auto t3 = high_resolution_clock::now();
            
            // Stats
            bool pass = (memcmp(ct, dt, DATA_SIZE) == 0);
            float gpu_time_sec = duration_cast<microseconds>(t2 - t1).count() / 1000000.0;
            float cpu_time_sec = duration_cast<microseconds>(t3 - t2).count() / 1000000.0;
            log_debug("encrypt %s %ld MB GPU: %f sec (%f MB/sec) CPU: %f sec (%f MB/sec)",
                      (pass ? "PASS" : "FAIL"), DATA_SIZE / MEGA_BYTE,
                      gpu_time_sec, DATA_SIZE / MEGA_BYTE / gpu_time_sec,
                      cpu_time_sec, DATA_SIZE / MEGA_BYTE / cpu_time_sec);
        }

        // GPU encryption only (no memory transfers)
        for (int i = 0; i < num_runs; i++) {
            const auto t1 = high_resolution_clock::now();
            clcmdqueue->enqueueNDRangeKernel(aes_rijndael_encrypt_kernel, opencl_dim(DATA_SIZE / 16), opencl_dim(256))->wait();
            const auto t2 = high_resolution_clock::now();
            float gpu_time_sec = duration_cast<microseconds>(t2 - t1).count() / 1000000.0;
            log_debug("encrypt %ld MB GPU: %f sec (%f MB/sec) [no memory transfer]",
                      DATA_SIZE / MEGA_BYTE,
                      gpu_time_sec, DATA_SIZE / MEGA_BYTE / gpu_time_sec);
        }
        
        aes_encrypt_deinit(rk);
        delete [] pt;
        delete [] ct;
        delete [] dt;
    }
};

int main(int argc, const char * argv[])
{
    aes_opencl_test test;
    
    test.initCL();
    test.testCL();
    test.testAES();

    return 0;
}

