/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
`timescale 1ns/1ns

`include "mfp_ahb_const.vh"

module mccomp_tb;
    reg         clk,clrn,memclk;
    wire [31:0] a,b,alu,adr,tom,fromm,pc,ir;
    wire  [3:0] q;
     reg  [`MFP_N_SW-1 :0] IO_Switch;
       reg  [`MFP_N_PB-1 :0] IO_PB;
       wire [`MFP_N_LED-1:0] IO_LED;
     wire [ 7           :0] IO_7SEGEN_N;
       wire [ 6           :0] IO_7SEG_N; 
       wire                   IO_BUZZ;
       wire                   IO_SPI_SDO;
       wire                   IO_SPI_RS;
       wire                   IO_SPI_SCK;
      reg                   UART_RX;
      reg [8:1]              JB;


     mccomp_sys mccomp_sys(
  			        .SI_Reset_N(clrn),
                    .SI_ClkIn(clk),
                    .q(q),
                    .a(a),
                    .b(b),
                    .alu(alu),
                    .adr(adr),
                    .tom(tom),
                    .fromm(fromm),
                    .pc(pc),
                    .ir(ir),
                    .memclk(memclk),
                    .IO_Switch(IO_Switch),
                    .IO_PB({BTNU, BTND, BTNL, BTNC, BTNR}),
                    .IO_LED(IO_LED),
                    .IO_7SEGEN_N(IO_7SEGEN_N),
                    .IO_7SEG_N(IO_7SEG_N), 
                    .IO_BUZZ(IO_BUZZ),
                    .IO_SPI_SDO(IO_SPI_SDO),
                    .IO_SPI_RS(IO_SPI_RS),
                    .IO_SPI_SCK(IO_SPI_SCK),
                    .UART_RX(UART_TXD_IN),
                    .JB(JB));   
                    
    initial begin
               clk  = 0;
         forever
             #50 clk = ~ clk;
     end
 
     initial begin
          memclk = 0;
       forever
          #25 memclk = ~ memclk;
     end
     initial begin
         clrn  = 1;
         #25 clrn = 0;
         forever
             #50 clrn  = 1;
     end
     
     initial begin
         IO_Switch = 0;
         forever 
           #350 IO_Switch =16'h5555;;
      end 
 endmodule
/*
   0 -  28
  40 -  68
  68 -  96
 408 - 436
*/
