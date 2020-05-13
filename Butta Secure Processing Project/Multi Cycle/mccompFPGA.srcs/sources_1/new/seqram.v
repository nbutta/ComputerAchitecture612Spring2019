//Universal RAM
module seqram(input clk, clrn,
            input we,
            input cs,
            input[31:0] addr,
            input[31:0] data_in,
            output reg[31:0] data_out);
            
parameter A_WIDTH = 0; //Address Bit width (gives 2^A_WIDTH 32 bit words)
parameter READ_DELAY = 0;

reg[31:0] ram[0:(1<<A_WIDTH)-1]; //Nx32 Instruction RAM
wire [31:0] addrmasked;
integer i;
assign addrmasked = addr & 2**(A_WIDTH+2)-1;
always @(posedge clk or negedge clrn) begin
    if (!clrn)
      for (i = 0; i < (1<<A_WIDTH)-1; i = i + 1)
        ram[i]  <= 0;                   // reset
    else 
      if(we & cs) begin
        //Ram accesses in this system are word-oriented
        ram[addrmasked>>2] <= data_in;
    end
end

generate
    if(READ_DELAY == 0) begin
        //Asynchronous read (in the same clock cycle)
        always @(*) data_out = cs ? ram[addrmasked>>2] : 0;
    end else if(READ_DELAY == 1) begin
        //Registered read (ready by next clock cycle)
        always @(posedge clk) begin
            if(cs) data_out <= ram[addrmasked>>2];
            else data_out <= 0;
        end
    end
endgenerate

initial begin
    for (i = 0; i < (1<<A_WIDTH)-1; i = i + 1)
        ram[i]  <= 0;                   // reset
end

endmodule

