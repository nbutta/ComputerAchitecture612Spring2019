/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
module mccpu (
        input wire clk,
        input wire clrn,
        input wire [31:0] frommem,
        input wire [127:0] fromsigmem,
        output [31:0] pc,
        output [31:0] inst,
        output [31:0] alua,
        output [31:0] alub,
        output [31:0] alu,
        output wmem,
        output [31:0] madr,
        output [31:0] datatomem,
        output [127:0] sigtomem,
        output [3:0] state
);
    
    wire [31:0] encrypted_ir;   
    
    // instruction fields    
    wire    [5:0] op   = inst[31:26];             // op
    wire    [4:0] rs   = inst[25:21];             // rs
    wire    [4:0] rt   = inst[20:16];             // rt
    wire    [4:0] rd   = inst[15:11];             // rd
    wire    [5:0] func = inst[05:00];             // func
    wire   [15:0] imm  = inst[15:00];             // immediate
    wire   [25:0] addr = inst[25:00];             // address
    // control signals
    wire    [3:0] aluc;                           // alu operation control
    wire    [1:0] pcsrc;                          // select pc source
    wire          wreg;                           // write regfile
    wire          regrt;                          // dest reg number is rt
    wire          m2reg;                          // instruction is an lw
    wire          shift;                          // instruction is a shift
    wire    [1:0] alusrcb;                        // alu input b selection
    wire          jal;                            // instruction is a jal
    wire          sext;                           // is sign extension
    wire          wpc;                            // write pc
    wire          wir;                            // write ir
    wire          iord;                           // select memory address
    wire          selpc;                          // select pc
    // datapath wires
    wire   [31:0] bpc;                            // branch target address
    wire   [31:0] npc;                            // next pc
    wire   [31:0] qa;                             // regfile output port a
    wire   [31:0] qb;                             // regfile output port b
    //wire   [31:0] alua;                           // alu input a
    //wire   [31:0] alub;                           // alu input b
    wire   [31:0] wd;                             // regfile write port data
    wire   [31:0] r;                              // alu out or mem
    wire   [31:0] sa  = {27'b0,inst[10:6]};       // shift amount
    wire   [15:0] s16 = {16{sext & inst[15]}};    // 16-bit signs
    wire   [31:0] i32 = {s16,imm};                // 32-bit immediate
    wire   [31:0] dis = {s16[13:0],imm,2'b00};    // word distance
    wire   [31:0] jpc = {pc[31:28],addr,2'b00};   // jump target address
    wire    [4:0] reg_dest;                       // rs or rt
    wire    [4:0] wn  = reg_dest | {5{jal}};      // regfile write reg #
    wire          z;                              // alu, zero tag
    wire   [31:0] rega;                           // register a
    wire   [31:0] regb;                           // register b
    wire   [31:0] regc;                           // register c
    wire   [31:0] data;                           // output of dr
    wire   [127:0] data_signature;
    wire   [31:0] opa;                            // sa or output of reg a
    
    //Secure Multi-Cycle Processor (SMCP) Signals
    wire gcm_aes_en;
    wire write_encrypted_ir;
    wire gcm_aes_done;
    wire gcm_aes_rst;
    wire [127:0] gcm_aes_IV;

    wire [127:0]     dii_data;
    wire [3:0]       dii_data_size;
    wire             dii_data_vld;
    wire             dii_data_type;
    wire             dii_last_word;

    wire [127:0]     cii_K;
    wire             cii_ctl_vld;
    wire             cii_IV_vld;
  
    // Outputs
    wire             dii_data_not_ready;
    wire [127:0]     Out_data;
    wire             Out_vld;
    wire             Tag_vld;
    wire [3:0]       Out_data_size;
    wire             Out_last_word;  
  
    wire [127:0]     gcm_aes_out;
    wire [127:0]     calculated_signature;
    wire [127:0]     instruction_signature;
    wire [31:0]      fetched_seq_num;
    wire [31:0]      gcm_aes_data_out;
    
    wire sn_we;
    wire [31:0] sn_data_in;
    wire [31:0] sn_data_out;
    
    wire [31:0] gcm_aes_data_in;
    wire [1:0] gcmaessel;
    wire [31:0] e_regb;
    wire we_e_regb;
    wire [31:0] lw_verified;
    
    // datapath
    mccu control_unit (
                       //in
                       pc,op,func,z,clk,clrn,

                       gcm_aes_done, instruction_signature, data_signature, calculated_signature,
                       sn_data_out, regc,

                       //out
                       wpc,wir,
                       write_encrypted_ir, gcm_aes_en, gcm_aes_IV,

                       sn_we, sn_data_in,
                       gcmaessel, 
                       we_e_regb,

                       wmem,wreg,
                       iord,regrt,m2reg,aluc,
                       shift,selpc,alusrcb,
                       pcsrc,jal,sext,state
    );

    //PC register. 
    //PC gets updated after IF
    dffe32  ip (npc,clk,clrn,wpc,pc);

    //Decrypted Instruction Register (DIR)
    //IR gets the output of the GCM AES ONLY after successful verification
    //wir is generated by the MCCU if the calculated signature matches the fetched signature
    dffe32  dir (gcm_aes_data_out,clk,clrn,wir,inst);
    
    //Encrypted Instruction Register (EIR) fetched from Instruction Memory
    //frommem/fromsigmem is generated using the pc as an address
    dffe32  eir (frommem, clk, clrn, write_encrypted_ir, encrypted_ir);    
    //Instruction Signature Register (ISR) fetched from Signature Memory
    dffe128 isr (fromsigmem, clk, clrn, write_encrypted_ir, instruction_signature);
    
    //Encrypted Data Register (EDR)
    //frommem/fromsigmem is generated using the regc (effective address) as an address
    //from load/store instructions
    dff32   edr (frommem,clk,clrn,data);
    //Data Signature Register (DSR)
    dff128  dsr (fromsigmem,clk,clrn,data_signature);

    //Register A
    dff32   reg_a (qa, clk,clrn,rega);
    
    //Register B
    dff32   reg_b (qb, clk,clrn,regb);
    
    //Register C 
    dff32   reg_c (alu,clk,clrn,regc);
    
    //Shift Amount or output of Register A
    mux2x32 aorsa (rega,sa,shift,opa);
    
    //ALU input A
    mux2x32 alu_a (opa,pc,selpc,alua);
    
    //ALU input B
    mux4x32 alu_b (regb,32'h4,i32,dis,alusrcb,alub);

    //ALU output (Register C) or GCM AES plaintext (decrypted data from lw instruction)
    mux2x32 alu_m (regc,gcm_aes_data_out,m2reg,r);

    //Use the pc or the effective address (Register C) to indec into the instruction/data + signature memory
    mux2x32 mem_a (pc,regc,iord,madr);

    //Mux in front of the d input to the register file
    mux2x32 link  (r,pc,jal,wd);
    
    mux2x5 reg_wn (rd,rt,regrt,reg_dest);         // rs or rt
    mux4x32 nextpc(alu,regc,qa,jpc,pcsrc,npc);    // next pc
    
    //Register file
    regfile rf (rs,rt,wd,wn,wreg,clk,clrn,qa,qb);
    
    //ALU
    alu alunit (alua,alub,aluc,alu,z);
    
    //change
    assign datatomem = e_regb;                          // output of reg b
    assign sigtomem  = calculated_signature;

    //Sequence Number RAM
    //For the sake of simplicity, this memory is in our trusted environment. This would need to be written out to main memory
    //along with the protected block and its signature in the event of a cache miss and block eviction
    seqram #(.A_WIDTH(8), .READ_DELAY(0)) seq_num_ram
        (.clk(clk), .we(sn_we), .cs(1'b1), .addr(regc), .data_in(sn_data_in), .data_out(sn_data_out));
    
    //Encrypted register B
    dffe32 enc_regb (gcm_aes_data_out, clk, clrn, we_e_regb, e_regb);

    //Data into the engine can be 4 things:
    //  0: the encrypted instruction register on instruction fetch (EIR)
    //  1: the register b for SW instructions (Register B)
    //  2: the encrypted register b to get the signature on the plaintext (Encrypted Register B)
    //  3: the data from a LW instruction (Encrypted Data Register EDR)
    mux4x32 gcm_aes_in (encrypted_ir, regb, e_regb, data, gcmaessel, gcm_aes_data_in);

    //GCM AES Controller
    //Current 128-bit key is the hardcoded value seen below
    //AAD was chosed arbitrarily and is embedded into the GCM AES Controller FSM logic
    //  Key = feffe9928665731c6d6a8f9467308308
    //  AAD = feedfacedeadbeeffeedfacedeadbeef_abaddad2
    //  IV  = 96-bit instruction/data address & 32-bit 1
    //Key could be the output of a pseudo-random LFSR in the future if desired

    gcm_aes_controller u_controller(
		//in
		.clk(clk),
		.clrn(clrn),
		.gcm_aes_en(gcm_aes_en),
		.gcm_aes_K(128'hfeffe9928665731c6d6a8f9467308308),
        .gcm_aes_IV(gcm_aes_IV),
		.gcm_aes_data_in(gcm_aes_data_in),

		.dii_data_not_ready(dii_data_not_ready),
		.Out_data(Out_data),
		.Out_vld(Out_vld),
		.Tag_vld(Tag_vld),
		.Out_data_size(Out_data_size),
		.Out_last_word(Out_last_word),

		//out
		.dii_data(dii_data),
		.dii_data_size(dii_data_size),
		.dii_data_vld(dii_data_vld),
		.dii_data_type(dii_data_type),
		.dii_last_word(dii_last_word),
		.cii_K(cii_K),
		.cii_ctl_vld(cii_ctl_vld),
		.cii_IV_vld(cii_IV_vld),
        .gcm_aes_rst(gcm_aes_rst),
		
		.gcm_aes_out(gcm_aes_out),
		.gcm_aes_done(gcm_aes_done),
		.gcm_aes_data_out(gcm_aes_data_out),
		.signature(calculated_signature)
	);

    //GCM AES Engine
    //This was modified to avoid a situation where the simulation was getting stuck in an
    //infinity loop of delta cycles due to a circular feedback loop of signal assignments
    //It was also modified to be completely clear on a reset so that register artifacts
    //from previous encryption/decryption runs don't affect the results of future runs
	gcm_aes_v0 u_dut (
		  .clk(clk), 
		  .rst(gcm_aes_rst | !clrn), 
		  .dii_data(dii_data), 
		  .dii_data_size(dii_data_size),
		  .dii_data_vld(dii_data_vld), 
		  .dii_data_type(dii_data_type), 
		  .dii_data_not_ready(dii_data_not_ready), 
		  .dii_last_word(dii_last_word),
          .cii_K(cii_K),
		  .cii_ctl_vld(cii_ctl_vld), 
		  .cii_IV_vld(cii_IV_vld), 
		  .Out_data(Out_data), 
		  .Out_vld(Out_vld), 
		  .Tag_vld(Tag_vld),
          .Out_data_size(Out_data_size),
          .Out_last_word(Out_last_word)
	);
        
endmodule
