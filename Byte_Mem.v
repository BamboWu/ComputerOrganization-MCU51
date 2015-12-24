module Byte_Mem(clk,CS,RW,addr,din,dout);
  parameter ADDRWIDTH = 3;
  parameter DEPTH = 2**ADDRWIDTH;
  
  input clk;
  input CS;  // Chip Select, L valid
  input RW;  // Read/Write,  H Read, L Write
  input [ADDRWIDTH-1:0] addr;
  input [7:0] din;
  
  output reg [7:0] dout;
  
  reg [7:0] mem[DEPTH-1:0];
    
  always@(negedge clk)
    casex({CS,RW})
	  2'b1x : dout <= {8{1'bz}};
	  2'b01 : dout <= mem[addr];
	  2'b00 : mem[addr] <= din[7:0];
	  default : dout <= {8{1'bz}};
	endcase
  
endmodule