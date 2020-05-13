`timescale 1ns / 1ps
`define SIZE 128

module tb_gcm_aes_controller;

  // Inputs
  reg clk;
  reg rst;
  reg clrn;
  
  wire [127:0]     dii_data;
  wire [3:0]       dii_data_size;
  wire             dii_data_vld;
  wire             dii_data_type;
  wire             dii_last_word;

  wire [127:0]     cii_K;
  wire             cii_ctl_vld;
  wire             cii_IV_vld;
  
  reg gcm_aes_en;
  
  // Outputs
  wire                  dii_data_not_ready;
  wire [127:0]          Out_data;
  wire                  Out_vld;
  wire                  Tag_vld;
  wire [3:0]            Out_data_size;
  wire                  Out_last_word;  
  
  wire [127:0] gcm_aed_out;
  wire gcm_aes_done;
  

	gcm_aes_controller u_controller(
		//in
		.clk(clk),
		.clrn(clrn),
		.gcm_aes_en(gcm_aes_en),
		.gcm_aes_K(128'hfeffe9928665731c6d6a8f9467308308),
		.gcm_aes_IV(128'hcafebabefacedbaddecaf888_00000001),

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
		
		.gcm_aed_out(gcm_aed_out),
		.gcm_aes_done(gcm_aes_done)
	);

	gcm_aes_v0 u_dut (
		  .clk(clk), 
		  .rst(rst), 
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

	always
		#7 clk = ~clk;

	initial begin
	    clk = 0;
	    gcm_aes_en = 0;
	    rst = 0;
	    clrn = 1;
	    repeat(1) @(posedge clk);
	    rst =  1;
	    clrn = 0;
	    repeat(10) @(posedge clk);
	    rst =  0;
	    clrn = 1;
	    repeat(5) @(posedge clk);
	    gcm_aes_en = 1;
	    repeat(2) @(posedge clk);
	    gcm_aes_en = 0;
	end		

	initial
   $monitor($time,":DNR = %b, Out_data = %h, Out_vld = %b, Tag_vld = %b, Out_data_size=%d, Out_last_word=%d\n",dii_data_not_ready,Out_data,Out_vld,Tag_vld,Out_data_size,Out_last_word);
	

endmodule