module Byte_Mem_pregramed(clk,CS,addr,dout);
  parameter ADDRWIDTH = 8;
  
  input clk;
  input CS;  // Chip Select, L valid
  input [ADDRWIDTH-1:0] addr;
  
  output reg [7:0] dout;
  
  reg [7:0] data;
    
  always@(negedge clk)
    casex(addr[7:0])
	  8'h00   : data <= 8'h74; // MOV  A,
	  8'h01   : data <= 8'h07; //          #07H
	  8'h02   : data <= 8'hF8; // MOV  R0, A
	  8'h03   : data <= 8'h7F; // MOV  R7, 
	  8'h04   : data <= 8'h03; //          #03H
	  8'h05   : data <= 8'hE6; // MOV  A,  @R0
	  8'h06   : data <= 8'hE8; // MOV  A,  R0
	  8'h07   : data <= 8'hA8; // MOV  R0,
	  8'h08   : data <= 8'h07; //          07H
	  8'h09   : data <= 8'hE5; // MOV  A,
	  8'h0a   : data <= 8'h00; //          00H
	  8'h0b   : data <= 8'h00; // NOP
      8'h0c   : data <= 8'h75; // MOV     ,
	  8'h0d   : data <= 8'h01; //      01H
	  8'h0e   : data <= 8'h06; //          #06H
	  8'h0f   : data <= 8'h77; // MOV  @R1,
	  8'h10   : data <= 8'h07; //          #07H
	  8'h11   : data <= 8'h8E; // MOV     ,R6
	  8'h12   : data <= 8'h00; //      00H
	  8'h13   : data <= 8'h86; // MOV     ,@R0
	  8'h14   : data <= 8'h20; //      20H
	  8'h15   : data <= 8'h85; // MOV     ,
	  8'h16   : data <= 8'h20; //          20H
	  8'h17   : data <= 8'h01; //      01H
	  8'h18   : data <= 8'hF5; // MOV     ,A
	  8'h19   : data <= 8'h80; //      P0
	  8'h1a   : data <= 8'h85; // MOV     ,
	  8'h1b   : data <= 8'h20; //          20H
	  8'h1c   : data <= 8'h90; //      P1
	  default : data <= 8'h00; // NOP
	endcase
  always@(*)
    dout <= CS?8'hzz:data[7:0];
endmodule
/* 	  8'h00   : data <= 8'h74; // MOV  A,
	  8'h01   : data <= 8'h55; //          #55H
	  8'h02   : data <= 8'hF8; // MOV  R0, A
	  8'h03   : data <= 8'hFF; // MOV  R7, A
	  8'h04   : data <= 8'h79; // MOV  R1, 
	  8'h05   : data <= 8'h07; //          #07H
	  8'h06   : data <= 8'h74; // MOV  A,
	  8'h07   : data <= 8'hAA; //          #0AAH
	  8'h08   : data <= 8'hE7; // MOV  A,  @R1
 */