module Bit_Mem(clk,CS,RW,addr,din,dout);
  parameter ADDRWIDTH = 3;
  parameter DEPTH = 2**ADDRWIDTH;
  
  input clk;
  input CS;  // Chip Select, L valid
  input RW;  // Read/Write,  H Read, L Write
  input [ADDRWIDTH-1:0] addr;
  input din;
  
  output reg dout;
  
  reg mem[DEPTH-1:0];
  
  // input
  always@(posedge clk)
    casex({CS,RW})
	  2'b00 : mem[addr] <= din;
	  default : mem[addr] <= mem[addr];
	endcase
  // output
  always@(posedge clk)
    casex({CS,RW})
	  2'b1x : dout <= 1'bz;
	  2'b01 : dout <= mem[addr];
	  default : dout <= 1'bz;
	endcase
  
endmodule