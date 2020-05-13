/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
module dff128 (d,clk,clrn,q);                            // a 32-bit register
    input      [127:0] d;                                // input d
    input             clk, clrn;                        // clock and reset
    output reg [127:0] q;                                // output q
    always @(negedge clrn or posedge clk)
        if (!clrn) q <= 0;                              // q = 0 if reset
        else       q <= d;                              // save d
endmodule
