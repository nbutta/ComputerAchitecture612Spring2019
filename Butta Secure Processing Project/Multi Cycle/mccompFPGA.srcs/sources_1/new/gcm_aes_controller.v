`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2019 03:26:21 PM
// Design Name: 
// Module Name: gcm_aes_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gcm_aes_controller(
						              //CPU to Controller
						              input wire         clk,
                          input wire         clrn,
                          input wire         gcm_aes_en,
                          input wire [127:0] gcm_aes_K,
                          input wire [127:0] gcm_aes_IV,
                          input wire [31:0]  gcm_aes_data_in,
                          //GCM to Controller

                          //Asserted by the GCM to indicate in Setup phase or working with a message/ciphertext and cannot accept adiitional block
                          input wire         dii_data_not_ready,
                          //Message/ciphertext or tag data
                          input wire [127:0] Out_data,
                          //When asserted, Out_data contains message/ciphertext
                          input wire         Out_vld,
                          //When asserted, Out_data contains tag data
                          input wire         Tag_vld,
                          //Number of valid bytes in Out_data
                          input wire [3:0]   Out_data_size,
                          //Asserted when the message/ciphertext is the last
                          input wire         Out_last_word,

                          //Controller to GCM
                          output reg [127:0] dii_data,
                          output reg [3:0]   dii_data_size,
                          output reg         dii_data_vld,
                          output reg         dii_data_type,
                          output reg         dii_last_word,
                          output reg [127:0] cii_K,
                          output reg         cii_ctl_vld,
                          output reg         cii_IV_vld,
                          output reg         gcm_aes_rst,

                          //Controller to CPU
                          output reg [127:0] gcm_aes_out,
                          output reg         gcm_aes_done,
                          output reg [31:0]  gcm_aes_data_out,
                          output reg [127:0] signature
                         );
                         
  //Register outputs to the input of the GCM block

  //Data input that is either Nonce (IV), message/ciphertext, or AAD block
  reg [127:0] dii_data_D;
 // reg [127:0] dii_data_Q;  

  //Size of valid dii_data ranging from 0-15
  //0 means one valid bytes in the LSB of dii_data, 15 means full block length (128 bits)
  reg [3:0]   dii_data_size_D;
 // reg [3:0]   dii_data_size_Q;  

  //When asserted, dii_data contains either message/ciphertext or AAD block
  reg         dii_data_vld_D;
//  reg         dii_data_vld_Q;  

  //When asserted, dii_data contains AAD block, otherwise message/ciphertext
  reg         dii_data_type_D;
//  reg         dii_data_type_Q;  

  //When asserted, dii_data contains the last message/ciphertext of AAD block
  reg         dii_last_word_D;
//  reg         dii_last_word_Q;  

  //Secret Key
  reg [127:0] cii_K_D;
 // reg [127:0] cii_K_Q;  

  //When asserted, starts the execution of GCM-AES
  reg         cii_ctl_vld_D;
 // reg         cii_ctl_vld_Q;  

  //When asserted, dii_data contains IV value
  reg         cii_IV_vld_D;
 // reg         cii_IV_vld_Q;  

  reg cycle_delay_D;
  reg cycle_delay_Q;

  reg [127:0] iv_D;
  reg [127:0] iv_Q;

  //Used for handshaking
  reg gcm_aes_done_D;

  reg [31:0]  gcm_aes_data_out_D;
  reg [127:0] signature_D;
  
  //FSM states
  parameter [3:0] E_IDLE        = 4'b0000,
                  E_KEY         = 4'b0001,
                  E_IV          = 4'b0010,
                  E_AAD1        = 4'b0011,
                  E_AAD2_WAIT   = 4'b0100,                  
                  E_AAD2        = 4'b0101,
                  E_DATA1_WAIT  = 4'b0110,
                  E_DATA1       = 4'b0111,
                  E_DEC         = 4'b1000,
                  E_SIGNATURE   = 4'b1001;
  reg [3:0] state_Q;
  reg [3:0] state_D;                         
 
  //FSM
  always @* begin

    //default signal assignments
    state_D         = state_Q;
	cii_ctl_vld_D   = 1'b0;
    cii_IV_vld_D    = 1'b0;
	dii_data_vld_D  = 1'b0;
	dii_last_word_D = dii_last_word;		
	dii_data_type_D = dii_data_type;
	cycle_delay_D   = cycle_delay_Q;
	gcm_aes_done  = 1'b0;

	dii_data_D      = dii_data;
	//dii_data_size_D = dii_data_size; 
    cii_K_D         = cii_K;    
    gcm_aes_data_out_D  = gcm_aes_data_out;
    signature_D     = signature;
    iv_D = iv_Q;

  	case (state_Q)
      E_IDLE: begin
        dii_last_word_D = 1'b0;
        dii_data_D      = 0;
        dii_data_size   = 0;
        cii_K_D         = gcm_aes_K;
        gcm_aes_done    = 1'b1;
        gcm_aes_rst     = 1'b1;

      	if (gcm_aes_en) begin
          gcm_aes_rst   = 1'b0;
          dii_data_D    = gcm_aes_IV;
          iv_D          = gcm_aes_IV;
          gcm_aes_done  = 1'b0;
     	    cii_ctl_vld_D = 1'b1;  	
      	  state_D       = E_KEY;
      	end
      end

      //Set the Key and start the execution
      E_KEY: begin
      	cii_IV_vld_D = 1'b1;      	
        //dii_data_D   = gcm_aes_IV;
        //dii_data_D   = iv_Q;
        state_D      = E_IV;
      end

      E_IV: begin
        cii_IV_vld_D = 1'b1;
      	if (!dii_data_not_ready) begin
          state_D    = E_AAD1;
        end      
      end      
      
      E_AAD1: begin
        dii_data_vld_D  = 1'b1; 
        dii_data_type_D = 1'b1; //AAD
        dii_data_size   = 4'd15;
        dii_data_D      = 128'hfeedfacedeadbeeffeedfacedeadbeef;
        cycle_delay_D   = 1'b1;
        state_D         = E_AAD2_WAIT;      
      end

      E_AAD2_WAIT: begin
         if (cycle_delay_Q) begin
           cycle_delay_D = 1'b0;
         end else begin
       	  if (!dii_data_not_ready) begin
             state_D    = E_AAD2;
           end      
         end
      end        

      E_AAD2: begin
        dii_data_vld_D  = 1'b1; 
        dii_data_type_D = 1'b1; //AAD
        dii_data_size   = 4'd3;
        dii_data_D      = 32'habaddad2;
        cycle_delay_D   = 1'b1;        
        state_D         = E_DATA1_WAIT;
      end
      
      E_DATA1_WAIT: begin
         if (cycle_delay_Q) begin
           cycle_delay_D = 1'b0;
         end else begin
           if (!dii_data_not_ready) begin
             state_D    = E_DATA1;
           end      
         end    
      end        

      E_DATA1: begin
        dii_data_vld_D  = 1'b1; 
        dii_data_type_D = 1'b0; //message/ciphertext
        dii_data_size   = 4'd3;
        dii_data_D      = gcm_aes_data_in;
        cycle_delay_D   = 1'b1;
        dii_last_word_D = 1'b1;
        state_D         = E_DEC;
      end

      //Get the decrypted instruction
      E_DEC: begin
        if (Out_vld) begin
          gcm_aes_data_out_D = Out_data[127:96];
          state_D           = E_SIGNATURE;
        end
      end

      //Get the calulated signature
      E_SIGNATURE: begin
        if (Tag_vld) begin
          signature_D = Out_data;
          state_D     = E_IDLE;
        end
      end

      default: begin
      	state_D = E_IDLE;
      end
  	endcase
  end

  //Sequential process to update the state
  always @ (posedge clk or negedge clrn) begin
  	if (!clrn) begin
  		state_Q       <= E_IDLE;
  		dii_data      <= 0;
  		//dii_data_size <= 0;
  		dii_data_vld  <= 1'b0;
  		dii_data_type <= 1'b0;
  		dii_last_word <= 1'b0;
  		cii_K         <= 0;
  		cii_ctl_vld   <= 1'b0;
  		cii_IV_vld    <= 1'b0;
  		cycle_delay_Q <= 1'b0;
  		//gcm_aes_done  <= 1'b0;
      gcm_aes_data_out  <= 0;
      signature     <= 0;
      iv_Q          <= 0;
  	end else begin
  	  state_Q         <= state_D;
      dii_data      <= dii_data_D;
      //dii_data_size <= dii_data_size_D;
      dii_data_vld  <= dii_data_vld_D;
      dii_data_type <= dii_data_type_D;
      dii_last_word <= dii_last_word_D;
      cii_K         <= cii_K_D;
      cii_ctl_vld   <= cii_ctl_vld_D;
      cii_IV_vld    <= cii_IV_vld_D; 
      cycle_delay_Q <= cycle_delay_D; 
      //gcm_aes_done  <= gcm_aes_done_D;
      gcm_aes_data_out  <= gcm_aes_data_out_D;		
      signature     <= signature_D;
      iv_Q          <= iv_D;
  	end
  end
                           
endmodule
