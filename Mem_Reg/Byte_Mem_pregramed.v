module Byte_Mem_pregramed(clk,CS,addr,dout);
  parameter ADDRWIDTH = 8;
  
  input clk;
  input CS;  // Chip Select, L valid
  input [ADDRWIDTH-1:0] addr;
  
  output reg [7:0] dout;
  
  reg [7:0] data;
    
  always@(negedge clk)
    casex(addr[7:0])
 	  8'h00 : data <= 8'h75;
 	  8'h01 : data <= 8'h08;
 	  8'h02 : data <= 8'h3F;
 	  8'h03 : data <= 8'h75;
 	  8'h04 : data <= 8'h09;
 	  8'h05 : data <= 8'h06;
 	  8'h06 : data <= 8'h75;
 	  8'h07 : data <= 8'h0A;
 	  8'h08 : data <= 8'h5B;
 	  8'h09 : data <= 8'h75;
 	  8'h0A : data <= 8'h0B;
 	  8'h0B : data <= 8'h4F;
 	  8'h0C : data <= 8'h75;
 	  8'h0D : data <= 8'h0C;
 	  8'h0E : data <= 8'h66;
 	  8'h0F : data <= 8'h75;
 	  8'h10 : data <= 8'h0D;
 	  8'h11 : data <= 8'h6D;
 	  8'h12 : data <= 8'h75;
 	  8'h13 : data <= 8'h0E;
 	  8'h14 : data <= 8'h7D;
 	  8'h15 : data <= 8'h75;
 	  8'h16 : data <= 8'h0F;
 	  8'h17 : data <= 8'h07;
 	  8'h18 : data <= 8'h75;
 	  8'h19 : data <= 8'h10;
 	  8'h1A : data <= 8'h7F;
 	  8'h1B : data <= 8'h75;
 	  8'h1C : data <= 8'h11;
 	  8'h1D : data <= 8'h6F;
 	  8'h1E : data <= 8'h75;
 	  8'h1F : data <= 8'h12;
 	  8'h20 : data <= 8'h08;
 	  8'h21 : data <= 8'h85;
 	  8'h22 : data <= 8'hB0;
 	  8'h23 : data <= 8'h13;
 	  8'h24 : data <= 8'h85;
 	  8'h25 : data <= 8'hA0;
 	  8'h26 : data <= 8'h14;
 	  8'h27 : data <= 8'h85;
 	  8'h28 : data <= 8'hA0;
 	  8'h29 : data <= 8'h90;
 	  8'h2A : data <= 8'h7E;
 	  8'h2B : data <= 8'hFA;
 	  8'h2C : data <= 8'h7F;
 	  8'h2D : data <= 8'hFA;
 	  8'h2E : data <= 8'hDF;
 	  8'h2F : data <= 8'hFE;
 	  8'h30 : data <= 8'hDE;
 	  8'h31 : data <= 8'hFA;
 	  8'h32 : data <= 8'h85;
 	  8'h33 : data <= 8'hB0;
 	  8'h34 : data <= 8'h90;
 	  8'h35 : data <= 8'h80;
 	  8'h36 : data <= 8'hE0;
	 default  : data <= 8'h00; // NOP
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
  // test ALU
/* 	  8'h00   : data <= 8'h74; // MOV  A,
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
	  8'h24   : data <= 8'hE6; // MOV  A,   @R0 */
	// test control
	/* 
	  8'h00   : data <= 8'h74; // MOV  A,
	  8'h01   : data <= 8'h07; //          #07H
	  8'h02   : data <= 8'h78; // MOV  R0, 
	  8'h03   : data <= 8'h06; //          #06H 
	  8'h04   : data <= 8'h76; // MOV  @R0,
	  8'h05   : data <= 8'h07; //          #07H
	  8'h06   : data <= 8'h60; // JZ
	  8'h07   : data <= 8'hF8; //          #-08H
	  8'h08   : data <= 8'hB4; // CJNE A,
	  8'h09   : data <= 8'h07; //          #07H,
	  8'h0a   : data <= 8'hF5; //                #-0BH
	  8'h0b   : data <= 8'hB6; // CJNE @R0,
      8'h0c   : data <= 8'h07; //          #07H,
	  8'h0d   : data <= 8'hF2; //                #-0EH
	  8'h0e   : data <= 8'hB5; // CJNE A,
	  8'h0f   : data <= 8'h06; //          06H,
	  8'h10   : data <= 8'hEF; //                #-11H
	  8'h11   : data <= 8'hF5; // MOV      ,A
	  8'h12   : data <= 8'h90; //      P1
	  8'h13   : data <= 8'h7F; // MOV  R7,
	  8'h14   : data <= 8'h05; //          #05H
	  8'h15   : data <= 8'hDF; // DJNZ R7,
	  8'h16   : data <= 8'hFE; //          #-02H
	  8'h17   : data <= 8'hD5; // DJNZ
	  8'h18   : data <= 8'h90; //      P1,
	  8'h19   : data <= 8'hF9; //          #-07H
	  8'h1a   : data <= 8'h00; // NOP
	  8'h1b   : data <= 8'h80; // SJMP
	  8'h1c   : data <= 8'hF3; //          #-0DH
	  8'h1d   : data <= 8'h85; // MOV      ,
	  8'h1e   : data <= 8'h30; //           30H
	  8'h1f   : data <= 8'h90; //      P1
	  8'h20   : data <= 8'h05; // INC
	  8'h21   : data <= 8'h90; //      P1
	  8'h22   : data <= 8'h18; // DEC  R0
	  8'h23   : data <= 8'h06; // INC  @R0
	  8'h24   : data <= 8'hE6; // MOV  A,   @R0 */
	// test CLR SWAP
/* 	8'h00   : data <= 8'h74; // MOV  A,
	  8'h01   : data <= 8'hA5; //          #A5H
	  8'h02   : data <= 8'hC4; // SWAP A 
	  8'h03   : data <= 8'hE4; // CLR  A 
	   */
	 /*   //802E7401F5907FFA7EFA7D08DDFEDEFADFF62380EF
	  8'h00   : data <= 8'h80; // SJMP 
	  8'h01   : data <= 8'h2E; //          MAIN
	  8'h30   : data <= 8'h74; // MOV A, 
	  8'h31   : data <= 8'h01; //          #01H 
	  8'h32   : data <= 8'hF5; // MOV     ,A
	  8'h33   : data <= 8'h90; //     P1
	  8'h34   : data <= 8'h7F; // MOV R7,
	  8'h35   : data <= 8'hFA; //         #FAH
	  8'h36   : data <= 8'h7E; // MOV R6,
	  8'h37   : data <= 8'h8A; //         #8AH
	  8'h38   : data <= 8'h7D; // MOV R5,
	  8'h39   : data <= 8'h08; //         #08H
      8'h3a   : data <= 8'hDD; // DJNZ R5,
	  8'h3b   : data <= 8'hFE; //         $
	  8'h3c   : data <= 8'hDE; // DJNZ R6,
	  8'h3d   : data <= 8'hFA; //         LP1
	  8'h3e   : data <= 8'hDF; // DJNZ R7,
	  8'h3f   : data <= 8'hF6; //         LP2
	  8'h40   : data <= 8'h23; // RL   A
	  8'h41   : data <= 8'h80; // SJMP
	  8'h42   : data <= 8'hEF; //        ,LP3
	  */