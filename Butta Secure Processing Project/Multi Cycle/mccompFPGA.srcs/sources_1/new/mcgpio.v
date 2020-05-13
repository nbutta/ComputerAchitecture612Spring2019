`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2017 12:49:48 PM
// Design Name: 
// Module Name: scgpio
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
// mfp_ahb_gpio.v
//
// General-purpose I/O module for Altera's DE2-115 and 
// Digilent's (Xilinx) Nexys4-DDR board


`include "mfp_ahb_const.vh"

module mcgpio(
    input                        clk,
    input                        clrn,
    output reg  [31:0]               dataout,
    input   [31:0]               datain,
    input   [3:0]               haddr,
    input                        we,
    input                       HSEL,
 
// memory-mapped I/O
    input      [`MFP_N_SW-1  :0] IO_Switch,
    input      [`MFP_N_PB-1  :0] IO_PB,
    output reg [`MFP_N_LED-1 :0] IO_LED,
    output [ 7          :0] IO_7SEGEN_N,
    output [ 6          :0] IO_7SEG_N,
    output                  IO_BUZZ,                
    output                  IO_SPI_SDO,
    output                  IO_SPI_RS,
    output                  IO_SPI_SCK
);
// internal signals for I/Os: 7-segment displays, millisecond counter, buzzer
wire [ 6:0] segments;      // 7 segments value for enabled signal

reg  [ 7:0] SEGEN_N;       // 7-segment display enables
reg  [31:0] SEGDIGITS_N;   // value of 8 7-segment display digits
wire [31:0] millis;        // number of milliseconds since start of program
reg  [31:0] buzzerMicros;
reg  [ 7:0] SPIdata;       // 8-bit data to send from CPU
reg         SPIcmdb;       // cmd bar (1=data, 0 = command)
reg         SPIsend;       // CPU asserts SPIsend when data is ready to be sent
wire        SPIdone;       // SPI slave asserts SPIdone when done sending data

  reg  [3:0]  HADDR_d;
  reg         HWRITE_d;
  reg         HSEL_d;
  reg  [1:0]  HTRANS_d;
  reg [31:0]  datain_d;
  wire        wes;            // write enable

  // delay HADDR, HWRITE, HSEL, and HTRANS to align with HWDATA for writing
  always @ (posedge clk) 
  begin
    datain_d <= datain;
    HADDR_d  <= haddr;
	HWRITE_d <= we;
	HSEL_d   <= HSEL;
  end
  
  // overall write enable signal
  assign wes =  HSEL_d & HWRITE_d;

  milliscounter milliscounter(
  .clk(clk),
  .resetn(clrn),
  .millis(millis));
  
  buzzer buzzer(
  .clk(clk),
  .resetn(clrn),
  .numMicros(buzzerMicros),
  .buzz(IO_BUZZ));
  
  spi_interface spi_interface(
  .clk(clk),
  .resetn(clrn),
  .data(SPIdata),
  .cmdb(SPIcmdb),
  .send(SPIsend),
  .done(SPIdone),
  .sdo(IO_SPI_SDO),
  .rs(IO_SPI_RS),
  .sck(IO_SPI_SCK));
  
  sevensegtimer sevensegtimer(
     .clk      (clk),    
     .resetn   (clrn),
     .EN       (SEGEN_N), 
     .DIGITS   (SEGDIGITS_N), 
     .DISPENOUT(IO_7SEGEN_N), 
     .DISPOUT  (IO_7SEG_N));

always @(posedge clk or negedge clrn)
        if (~clrn) begin
          IO_LED <= `MFP_N_LED'b0;  // turn LEDS off at reset
        // turn 7-segment displays off at reset
          SEGEN_N      <= 8'hff;          // 7-segment display enables
          SEGDIGITS_N  <= 32'hffffffff;   // 7-segment digit values      
          buzzerMicros <= 32'b0;          // buzzer is off
          SPIdata      <= 8'b0;           // SPI data is 0
          SPIcmdb      <= 1'b0;           // SPI cmd defaulting to sending a command
          SPIsend      <= 1'b0;           // CPU not sending SPI data
         
        end else if (wes)
          case (HADDR_d)
            `H_LED_IONUM: IO_LED <= datain_d[`MFP_N_LED-1:0];
            `H_7SEGEN_IONUM:     SEGEN_N      <= datain_d[7:0];
            `H_7SEGDIGITS_IONUM: SEGDIGITS_N  <= datain_d;
            `H_BUZZER_IONUM:     buzzerMicros <= datain_d;
            `H_SPI_DATA_IONUM: begin 
                                SPIdata      <= datain_d[7:0]; 
                                SPIcmdb      <= datain_d[8]; 
                                SPIsend      <= 1'b1;
                              end
          endcase
       else if (~SPIdone) 
             SPIsend <= 1'b0;
     
     
       always @(*) begin
           if(HSEL) begin
             case (haddr)
               `H_SW_IONUM: dataout = { {32 - `MFP_N_SW {1'b0}}, IO_Switch };
               `H_PB_IONUM: dataout = { {32 - `MFP_N_PB {1'b0}}, IO_PB };
               `H_MILLIS_IONUM:   dataout <= millis;
               `H_SPI_DONE_IONUM: dataout = {31'b0, SPIdone};
            default:
                 dataout = 32'h00000000;
              endcase
           end else begin
             dataout = 32'h00000000;
            end
           end
		 
endmodule