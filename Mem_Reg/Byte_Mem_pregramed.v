module Byte_Mem_pregramed(clk,CS,addr,dout);
  parameter ADDRWIDTH = 8;
  
  input clk;
  input CS;  // Chip Select, L valid
  input [ADDRWIDTH-1:0] addr;
  
  output reg [7:0] dout;
  
  reg [7:0] data;
    
  always@(negedge clk)
    casex(addr[7:0])
      8'h00    : data <= 8'h02; // LJMP
	  8'h01    : data <= 8'h00; //         #02
	  8'h02    : data <= 8'hC2; //            C2H
	  8'hC2    : data <= 8'h74; // MOV  A,
	  8'hC3    : data <= 8'hFF; //         #0FFH
	  8'hC4    : data <= 8'h04; // INC  A
	  8'hC5    : data <= 8'h40; // JC
	  8'hC6    : data <= 8'h89; //         #-77H
	  8'h50    : data <= 8'h04; // INC  A
	  8'h51    : data <= 8'h50; // JNC
	  8'h52    : data <= 8'hAD; //         #-53H
	  default  : data <= 8'h00;
	endcase
  always@(*)
    dout <= CS?8'hzz:data[7:0];
endmodule

/*     casex(addr[7:0])
	  8'h00 : data <= 8'h75;
      8'h01 : data <= 8'h08;
      8'h02 : data <= 8'h40; // 0 : 0100 0000
      8'h03 : data <= 8'h75;
      8'h04 : data <= 8'h09;
      8'h05 : data <= 8'h79; // 1 : 0111 1001
      8'h06 : data <= 8'h75;
      8'h07 : data <= 8'h0A;
      8'h08 : data <= 8'h24; // 2 : 0010 0100
      8'h09 : data <= 8'h75;
      8'h0A : data <= 8'h0B;
      8'h0B : data <= 8'h30; // 3 : 0011 0000
      8'h0C : data <= 8'h75;
      8'h0D : data <= 8'h0C;
      8'h0E : data <= 8'h19; // 4 : 0001 1001
      8'h0F : data <= 8'h75;
      8'h10 : data <= 8'h0D;
      8'h11 : data <= 8'h12; // 5 : 0001 0010
      8'h12 : data <= 8'h75;
      8'h13 : data <= 8'h0E;
      8'h14 : data <= 8'h02; // 6 : 0000 0010
      8'h15 : data <= 8'h75;
      8'h16 : data <= 8'h0F;
      8'h17 : data <= 8'h78; // 7 : 0111 1000
      8'h18 : data <= 8'h75;
      8'h19 : data <= 8'h10;
      8'h1A : data <= 8'h00; // 8 : 0000 0000
      8'h1B : data <= 8'h75;
      8'h1C : data <= 8'h11;
      8'h1D : data <= 8'h10; // 9 : 0001 0000
      8'h1E : data <= 8'h85;
      8'h1F : data <= 8'hB0;
      8'h20 : data <= 8'h12;
      8'h21 : data <= 8'h85;
      8'h22 : data <= 8'hA0;
      8'h23 : data <= 8'h13;
      8'h24 : data <= 8'hE4;
      8'h25 : data <= 8'hF5;
      8'h26 : data <= 8'h14;
      8'h27 : data <= 8'h75;
      8'h28 : data <= 8'h90;
      8'h29 : data <= 8'h77; // P1L : 0111
      8'h2A : data <= 8'h75;
      8'h2B : data <= 8'h16;
      8'h2C : data <= 8'h80;
      8'h2D : data <= 8'h75;
      8'h2E : data <= 8'h15;
      8'h2F : data <= 8'h7D;
      8'h30 : data <= 8'hE5;
      8'h31 : data <= 8'h13;
      8'h32 : data <= 8'h54;
      8'h33 : data <= 8'h0F;
      8'h34 : data <= 8'h24;
      8'h35 : data <= 8'h08;
      8'h36 : data <= 8'hF8;
      8'h37 : data <= 8'hE6;
      8'h38 : data <= 8'hF5;
      8'h39 : data <= 8'h80;
      8'h3A : data <= 8'hAF;
      8'h3B : data <= 8'h90;
      8'h3C : data <= 8'h78;
      8'h3D : data <= 8'h01;
      8'h3E : data <= 8'hEF;
      8'h3F : data <= 8'h08;
      8'h40 : data <= 8'h80;
      8'h41 : data <= 8'h01;
      8'h42 : data <= 8'h23;
      8'h43 : data <= 8'hD8;
      8'h44 : data <= 8'hFD;
      8'h45 : data <= 8'hF5;
      8'h46 : data <= 8'h90;
      8'h47 : data <= 8'hE5;
      8'h48 : data <= 8'h16;
      8'h49 : data <= 8'h42;
      8'h4A : data <= 8'h80;
      8'h4B : data <= 8'h7F;
      8'h4C : data <= 8'hFA;
      8'h4D : data <= 8'h00;
      8'h4E : data <= 8'h00;
      8'h4F : data <= 8'hDF;
      8'h50 : data <= 8'hFC;
      8'h51 : data <= 8'hE5;
      8'h52 : data <= 8'h13;
      8'h53 : data <= 8'h54;
      8'h54 : data <= 8'hF0;
      8'h55 : data <= 8'hC4;
      8'h56 : data <= 8'h24;
      8'h57 : data <= 8'h08;
      8'h58 : data <= 8'hF8;
      8'h59 : data <= 8'hE6;
      8'h5A : data <= 8'hF5;
      8'h5B : data <= 8'h80;
      8'h5C : data <= 8'hAF;
      8'h5D : data <= 8'h90;
      8'h5E : data <= 8'h78;
      8'h5F : data <= 8'h01;
      8'h60 : data <= 8'hEF;
      8'h61 : data <= 8'h08;
      8'h62 : data <= 8'h80;
      8'h63 : data <= 8'h01;
      8'h64 : data <= 8'h23;
      8'h65 : data <= 8'hD8;
      8'h66 : data <= 8'hFD;
      8'h67 : data <= 8'hF5;
      8'h68 : data <= 8'h90;
      8'h69 : data <= 8'hE5;
      8'h6A : data <= 8'h16;
      8'h6B : data <= 8'h42;
      8'h6C : data <= 8'h80;
      8'h6D : data <= 8'h7F;
      8'h6E : data <= 8'hFA;
      8'h6F : data <= 8'h00;
      8'h70 : data <= 8'h00;
      8'h71 : data <= 8'hDF;
      8'h72 : data <= 8'hFC;
      8'h73 : data <= 8'hE5;
      8'h74 : data <= 8'h12;
      8'h75 : data <= 8'h54;
      8'h76 : data <= 8'h0F;
      8'h77 : data <= 8'h24;
      8'h78 : data <= 8'h08;
      8'h79 : data <= 8'hF8;
      8'h7A : data <= 8'hE6;
      8'h7B : data <= 8'hF5;
      8'h7C : data <= 8'h80;
      8'h7D : data <= 8'hAF;
      8'h7E : data <= 8'h90;
      8'h7F : data <= 8'h78;
      8'h80 : data <= 8'h01;
      8'h81 : data <= 8'hEF;
      8'h82 : data <= 8'h08;
      8'h83 : data <= 8'h80;
      8'h84 : data <= 8'h01;
      8'h85 : data <= 8'h23;
      8'h86 : data <= 8'hD8;
      8'h87 : data <= 8'hFD;
      8'h88 : data <= 8'hF5;
      8'h89 : data <= 8'h90;
      8'h8A : data <= 8'hE5;
      8'h8B : data <= 8'h16;
      8'h8C : data <= 8'h42;
      8'h8D : data <= 8'h80;
      8'h8E : data <= 8'h7F;
      8'h8F : data <= 8'hFA;
      8'h90 : data <= 8'h00;
      8'h91 : data <= 8'h00;
      8'h92 : data <= 8'hDF;
      8'h93 : data <= 8'hFC;
      8'h94 : data <= 8'hE5;
      8'h95 : data <= 8'h12;
      8'h96 : data <= 8'h54;
      8'h97 : data <= 8'hF0;
      8'h98 : data <= 8'hC4;
      8'h99 : data <= 8'h24;
      8'h9A : data <= 8'h08;
      8'h9B : data <= 8'hF8;
      8'h9C : data <= 8'hE6;
      8'h9D : data <= 8'hF5;
      8'h9E : data <= 8'h80;
      8'h9F : data <= 8'hAF;
      8'hA0 : data <= 8'h90;
      8'hA1 : data <= 8'h78;
      8'hA2 : data <= 8'h01;
      8'hA3 : data <= 8'hEF;
      8'hA4 : data <= 8'h08;
      8'hA5 : data <= 8'h80;
      8'hA6 : data <= 8'h01;
      8'hA7 : data <= 8'h23;
      8'hA8 : data <= 8'hD8;
      8'hA9 : data <= 8'hFD;
      8'hAA : data <= 8'hF5;
      8'hAB : data <= 8'h90;
      8'hAC : data <= 8'hE5;
      8'hAD : data <= 8'h16;
      8'hAE : data <= 8'h42;
      8'hAF : data <= 8'h80;
      8'hB0 : data <= 8'h7F;
      8'hB1 : data <= 8'hFA;
      8'hB2 : data <= 8'h00;
      8'hB3 : data <= 8'h00;
      8'hB4 : data <= 8'hDF;
      8'hB5 : data <= 8'hFC;
      8'hB6 : data <= 8'h15;
      8'hB7 : data <= 8'h15;
      8'hB8 : data <= 8'hE5;
      8'hB9 : data <= 8'h15;
      8'hBA : data <= 8'h60;
      8'hBB : data <= 8'h03;
      8'hBC : data <= 8'h80;
      8'hBD : data <= 8'h72;
      8'hBE : data <= 8'hE5;
      8'hBF : data <= 8'h16;
      8'hC0 : data <= 8'h70;
      8'hC1 : data <= 8'h2C;
      8'hC2 : data <= 8'hE5;
      8'hC3 : data <= 8'h14;
      8'hC4 : data <= 8'h64;
      8'hC5 : data <= 8'h3C;
      8'hC6 : data <= 8'h70;
      8'hC7 : data <= 8'h22;
      8'hC8 : data <= 8'hF5;
      8'hC9 : data <= 8'h14;
      8'hCA : data <= 8'hE5;
      8'hCB : data <= 8'h13;
      8'hCC : data <= 8'hB4;
      8'hCD : data <= 8'h59;
      8'hCE : data <= 8'h15;
      8'hCF : data <= 8'hE4;
      8'hD0 : data <= 8'hF5;
      8'hD1 : data <= 8'h13;
      8'hD2 : data <= 8'hE5;
      8'hD3 : data <= 8'h12;
      8'hD4 : data <= 8'hB4;
      8'hD5 : data <= 8'h23;
      8'hD6 : data <= 8'h05;
      8'hD7 : data <= 8'hE4;
      8'hD8 : data <= 8'hF5;
      8'hD9 : data <= 8'h12;
      8'hDA : data <= 8'h80;
      8'hDB : data <= 8'h13;
      8'hDC : data <= 8'hE5;
      8'hDD : data <= 8'h12;
      8'hDE : data <= 8'h04;
      8'hDF : data <= 8'hD4;
      8'hE0 : data <= 8'hF5;
      8'hE1 : data <= 8'h12;
      8'hE2 : data <= 8'h80;
      8'hE3 : data <= 8'h0B;
      8'hE4 : data <= 8'hE5;
      8'hE5 : data <= 8'h13;
      8'hE6 : data <= 8'h04;
      8'hE7 : data <= 8'hD4;
      8'hE8 : data <= 8'h80;
      8'hE9 : data <= 8'h05;
      8'hEA : data <= 8'h05;
      8'hEB : data <= 8'h14;
      8'hEC : data <= 8'h80;
      8'hED : data <= 8'h01;
      8'hEE : data <= 8'h00;
      8'hEF : data <= 8'h63;
      8'hF0 : data <= 8'h16;
      8'hF1 : data <= 8'h80;
      8'hF2 : data <= 8'h80;
      8'hF3 : data <= 8'h37; */