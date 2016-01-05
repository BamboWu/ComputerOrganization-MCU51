module Byte_Mem_pregramed(clk,CS,addr,dout);
  parameter ADDRWIDTH = 8;
  
  input clk;
  input CS;  // Chip Select, L valid
  input [ADDRWIDTH-1:0] addr;
  
  output reg [7:0] dout;
  
  reg [7:0] data;
    
  always@(negedge clk)
    casex(addr[7:0])
	  8'h00   : data <= 8'h74;
	  8'h01   : data <= 8'h55;
	  8'h02   : data <= 8'hF8;
	  8'h03   : data <= 8'hFF;
	  default : data <= 8'h00;
	endcase
  always@(*)
    dout <= CS?8'hzz:data[7:0];
endmodule