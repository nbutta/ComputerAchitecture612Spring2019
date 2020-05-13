/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/

`include "mfp_ahb_const.vh"
module mccomp_sys (SI_ClkIn,SI_Reset_N,q,a,b,alu,adr,tom,fromm,pc,ir,memclk,IO_Switch,
                    IO_PB,IO_LED,IO_7SEGEN_N,IO_7SEG_N,IO_BUZZ,IO_SPI_SDO,IO_SPI_RS,IO_SPI_SCK,UART_RX,JB);
    input                  SI_Reset_N;
    input                   SI_ClkIn;
    output  [3:0] q;                              // state
    output [31:0] a;                              // alu input a
    output [31:0] b;                              // alu input b
    output [31:0] alu;                            // alu result
    output [31:0] adr;                            // memory address
    output [31:0] tom;                            // data to memory
    output [31:0] fromm;                          // data from memory
    output [31:0] pc;                             // program counter
    output [31:0] ir;                             // instruction register
    input         memclk;                         // memory clk for sync ram
    input  [`MFP_N_SW-1 :0] IO_Switch;
    input  [`MFP_N_PB-1 :0] IO_PB;
    output [`MFP_N_LED-1:0] IO_LED;
    output [ 7          :0] IO_7SEGEN_N;
    output [ 6          :0] IO_7SEG_N;
    output                  IO_BUZZ;                  
    output                  IO_SPI_SDO;
    output                  IO_SPI_RS;
    output                  IO_SPI_SCK;
    input                   UART_RX;
    input [8:1] JB;

     wire wmem;               // write data memory
     wire[31:0] data_cpu;     //data driven by cpu
     wire[127:0] sig_cpu;     //signature driven by cpu
     wire[31:0] data_mem;     //data driven by data memory
     wire[127:0] sig_mem;     //data driven by the signature memory
     wire[31:0] memout;       //input to data memory on a write. output of data memory on a read
     wire[127:0]sigout;       //input to signature memory on a write. output of signature memory on a read
     
     wire[31:0] data_gpio;    //data driven by GPIO module
     
     wire dbg_resetn_cpu;
     wire dbg_halt_cpu;
     
     wire clk;
     wire clrn;
     assign clk=SI_ClkIn;
     assign clrn = SI_Reset_N & dbg_resetn_cpu;
 // Check if memory mapped I/O
     wire[2:0] HSEL;
     
    mccpu mc_cpu (
        //in
        clk,clrn,memout,sigout,
        //out
        pc,ir,a,b,alu,wmem,adr,data_cpu,sig_cpu,q
    );   


    mccomp_decoder mccomp_decoder(adr,HSEL);

    //**************************************************************************
    //*** These paths must be updated to match your directory structure      ***
    //*** for the purposes of loading the instruction and signature memories ***
    //*** Be sure to use forward slashes '/', even on Windows                *** 
    //**************************************************************************
    
    //parameter RAM_FILE = "/home/besernd1/repos/mips-cpu/Software/Assembly/General\ Instruction\ Test/mcinstructiontest.hex";
    //parameter RAM_FILE = "C:/Users/nickb/Documents/JHU/612/repo/mips-cpu/Software/Assembly/Project/demo_imem_encrypted.hex";
    //parameter SIG_FILE = "C:/Users/nickb/Documents/JHU/612/repo/mips-cpu/Software/Assembly/Project/demo_imem_signatures_pt.hex";
    
    //For usage on Butta's NG PC
    parameter RAM_FILE = "C:/Users/j39950/Desktop/demo2/demo2_imem_encrypted.hex";
    parameter SIG_FILE = "C:/Users/j39950/Desktop/demo2/demo2_imem_signatures_pt.hex";
    
    //parameter RAM_FILE = "C:/Users/j39950/Desktop/demo_imem_encrypted.hex";
    //parameter SIG_FILE = "C:/Users/j39950/Desktop/demo_imem_signatures_pt.hex";    
    
    wire[31:0] dbg_mem_addr;
    wire[31:0] dbg_mem_din;
    wire dbg_mem_cs;
    wire dbg_mem_we;
    
    //Encrypted Instruction and Data Memory
    uram #(.A_WIDTH(8), .INIT_FILE(RAM_FILE), .READ_DELAY(0)) system_ram
        (.clk(clk), .we(wmem), .cs(HSEL[1]), .addr(adr), .data_in(memout), .data_out(data_mem));
 
    //Instruction Signature Memory
    sigram #(.A_WIDTH(8), .INIT_FILE(SIG_FILE), .READ_DELAY(0)) sig_ram
        (.clk(clk), .we(wmem), .cs(HSEL[1]), .addr(adr), .data_in(sigout), .data_out(sig_mem));

    mcgpio gpio (.clk(clk),
        .clrn(clrn),
        .dataout(data_gpio),
        .datain(memout),
        .haddr(adr[5:2]),
        .we(wmem),
        .HSEL(HSEL[2]),
        .IO_Switch(IO_Switch),
        .IO_PB(IO_PB),
        .IO_LED(IO_LED),
        .IO_7SEGEN_N(IO_7SEGEN_N),
        .IO_7SEG_N(IO_7SEG_N),
        .IO_BUZZ(IO_BUZZ),                
        .IO_SPI_SDO(IO_SPI_SDO),
        .IO_SPI_RS(IO_SPI_RS),
        .IO_SPI_SCK(IO_SPI_SCK));
    
    assign memout = wmem ? data_cpu :
                    HSEL[1] ? data_mem :
                    HSEL[2] ? data_gpio :
                    32'b0;

    assign sigout = wmem ? sig_cpu:
                    HSEL[1] ? sig_mem :
                    128'b0;
                                                      
endmodule
