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
	  8'h02   : data <= 8'h78; // MOV  R0, 
	  8'h03   : data <= 8'h06; //          #06H 
	  8'h04   : data <= 8'h76; // MOV  @R0,
	  8'h05   : data <= 8'h02; //          #02H
	  8'h06   : data <= 8'h96; // SUBB A,  R6
	  8'h07   : data <= 8'hF5; // MOV     ,A
	  8'h08   : data <= 8'h20; //      20H
	  8'h09   : data <= 8'hA9; // MOV  R1,
	  8'h0a   : data <= 8'h20; //          20H
	  8'h0b   : data <= 8'h7D; // MOV  R5,
      8'h0c   : data <= 8'h19; //          #19H
	  8'h0d   : data <= 8'h37; // ADDC A,  @R1
	  8'h0e   : data <= 8'hD4; // DA   A
	  8'h0f   : data <= 8'h04; // INC  A
	  8'h10   : data <= 8'h75; // MOV     ,
	  8'h11   : data <= 8'h30; //      30H
	  8'h12   : data <= 8'h0F; //          #0FH
	  8'h13   : data <= 8'h55; // ANL  A,
	  8'h14   : data <= 8'h30; //          30H
	  8'h15   : data <= 8'hF4; // CPL  A
	  8'h16   : data <= 8'h24; // ADD  A,
	  8'h17   : data <= 8'hF5; //          #0F5H
	  8'h18   : data <= 8'h38; // ADDC A,  R0
	  8'h19   : data <= 8'h33; // RLC  A
	  8'h1a   : data <= 8'h03; // RR   A
	  8'h1b   : data <= 8'h44; // ORL  A,
	  8'h1c   : data <= 8'h55; //          #55H
	  8'h1d   : data <= 8'h85; // MOV      ,
	  8'h1e   : data <= 8'h30; //           30H
	  8'h1f   : data <= 8'h90; //      P1
	  8'h20   : data <= 8'h05; // INC
	  8'h21   : data <= 8'h90; //      P1
	  8'h22   : data <= 8'h18; // DEC  R0
	  8'h23   : data <= 8'h06; // INC  @R0
	  8'h24   : data <= 8'hE6; // MOV  A,   @R0
	  default : data <= 8'h00; // NOP
	endcase
  always@(*)
    dout <= CS?8'hzz:data[7:0];
endmodule
 // test MOVs
/*  	  8'h00   : data <= 8'h74; // MOV  A,
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
 */