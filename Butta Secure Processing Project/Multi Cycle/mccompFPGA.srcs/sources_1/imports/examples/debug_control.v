module debug_control(
    input jtag_tck,
    input jtag_tms,
    input jtag_tdi,
    input jtag_trst,
    output jtag_tdo,

    input sys_rstn, //System reset. Should NOT be externally tied to our cpu_resetn_cpu output

    input cpu_clk,

    output reg[31:0] cpu_mem_addr,
    output reg[31:0] cpu_debug_to_mem_data,
    input[31:0] cpu_mem_to_debug_data,
    input cpu_mem_to_debug_data_ready,
    output reg cpu_mem_cs,
    output reg cpu_mem_we,

    output reg cpu_halt_cpu,
    output cpu_resetn_cpu
    );

    //Signals from the JTAG TAP to the synchronizer
    wire jtag_userOp_ready;

    //Resulting signal in the CPU domain
    wire cpu_userOp_ready;

    //Requested operation/data from the TAP in the JTAG domain
    wire[7:0] jtag_userOp;
    wire[31:0] jtag_userData;

    reg[31:0] cpu_userData;

    //The Jtaglet JTAG TAP
    jtaglet #(.ID_PARTVER(4'h3), .ID_PARTNUM(16'hBEEF), .ID_MANF(11'h035)) jtag_if
        (.tck(jtag_tck), .tms(jtag_tms), .tdo(jtag_tdo), .tdi(jtag_tdi), .trst(jtag_trst),
         .userData_out(jtag_userData), .userData_in(cpu_userData), .userOp(jtag_userOp),
         .userOp_ready(jtag_userOp_ready));

    //Synchronizer to take the userOp ready signal into the CPU clock domain
    ff_sync #(.WIDTH(1)) userOpReady_toCPUDomain
        (.clk(cpu_clk), .rst_p(~sys_rstn), .in_async(jtag_userOp_ready), .out(cpu_userOp_ready));

    //Stateless debug operations (which ignore debug register contents)
    localparam DEBUGOP_NOOP_OP      = 8'h00;
    localparam DEBUGOP_CPUHALT_OP   = 8'h01;
    localparam DEBUGOP_CPURESUME_OP = 8'h02;
    localparam DEBUGOP_CPURESET_OP  = 8'h03;

    //Debug operations (use previously stored data to carry out an operation)
    //DMem and IMem operations will both perform the same action on unified memory
    localparam DEBUGOP_READIMEM_OP  = 8'h04;
    localparam DEBUGOP_WRITEIMEM_OP = 8'h05;
    localparam DEBUGOP_READDMEM_OP  = 8'h06;
    localparam DEBUGOP_WRITEDMEM_OP = 8'h07;

    //Load/store debug operations (have no side-effects apart from
    //loading/storing the appropriate debug register)
    //DMem and IMem operations will both perform the same action on unified memory
    localparam DEBUGOP_IADDR_REG     = 8'h80;
    localparam DEBUGOP_IDATA_REG     = 8'h81;
    localparam DEBUGOP_DADDR_REG     = 8'h82;
    localparam DEBUGOP_DDATA_REG     = 8'h83;
    localparam DEBUGOP_CPUFLAGS_REG  = 8'h84;

    reg cpu_userOp_ready_last;
    wire execUserOp = ~cpu_userOp_ready_last & cpu_userOp_ready;

    always @(posedge cpu_clk or negedge sys_rstn) begin
        if(~sys_rstn) cpu_userOp_ready_last <= 0;
        else cpu_userOp_ready_last <= cpu_userOp_ready;
    end

    //DMem and IMem operations will both perform the same action on unified memory
    always @(posedge cpu_clk or negedge sys_rstn) begin
        if(~sys_rstn) begin
            cpu_mem_we <= 0;
            cpu_mem_cs <= 0;
        end else begin
            cpu_mem_we <= 0;
            cpu_mem_cs <= 0;
            if(execUserOp) case(jtag_userOp)
                DEBUGOP_READDMEM_OP: cpu_mem_cs <= 1;
                DEBUGOP_READIMEM_OP: cpu_mem_cs <= 1;
                DEBUGOP_WRITEIMEM_OP: begin
                    cpu_mem_we <= 1;
                    cpu_mem_cs <= 1;
                end
                DEBUGOP_WRITEDMEM_OP: begin
                    cpu_mem_we <= 1;
                    cpu_mem_cs <= 1;
                end
            endcase
        end
    end

    //DMem and IMem operations will both perform the same action on unified memory
    always @(posedge cpu_clk) begin
        if(execUserOp) case(jtag_userOp)
            DEBUGOP_IADDR_REG: cpu_mem_addr <= jtag_userData;
            DEBUGOP_DADDR_REG: cpu_mem_addr <= jtag_userData;
        endcase
    end

    always @(posedge cpu_clk) begin
        if(execUserOp) case(jtag_userOp)
            DEBUGOP_IDATA_REG: cpu_debug_to_mem_data <= jtag_userData;
            DEBUGOP_DDATA_REG: cpu_debug_to_mem_data <= jtag_userData;
        endcase
    end

    always @(posedge cpu_clk or negedge sys_rstn) begin
        if(~sys_rstn) begin
            cpu_userData <= 0;
        end else begin
            if(cpu_mem_to_debug_data_ready) cpu_userData <= cpu_mem_to_debug_data;
        end
    end

    //Reset Stretcher
    reg requestReset;
    reg[9:0] resetStretch;
    assign cpu_resetn_cpu = ~(|resetStretch);
    always @(posedge cpu_clk or negedge sys_rstn) begin
        if(~sys_rstn) resetStretch <= 10'b0;
        else if(requestReset) resetStretch <= {10{1'b1}};
        else if(resetStretch != 0) resetStretch <= resetStretch - 1;
    end

    always @(posedge cpu_clk or negedge sys_rstn) begin
        if(~sys_rstn) begin
            cpu_halt_cpu <= 0;
            requestReset <= 0;
        end else begin
            requestReset <= 0;
            if(execUserOp) case(jtag_userOp)
                DEBUGOP_CPUHALT_OP: cpu_halt_cpu <= 1;
                DEBUGOP_CPURESUME_OP: cpu_halt_cpu <= 0;
                DEBUGOP_CPURESET_OP: begin
                    cpu_halt_cpu <= 0;
                    requestReset <= 1;
                end
            endcase
        end
    end

endmodule
