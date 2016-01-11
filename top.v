module top(CLK,reset,resetclk,
           // I/O ports
		   MHz12,
		   //P0,
		   P1,
		   P2,
		   P3
		   );
  
  input CLK,reset,resetclk;
  //output wire [7:0] P0;
  output wire [7:0] P1;
  input  wire [7:0] P2;
  input  wire [7:0] P3;
  output wire MHz12;
  
  // clock supply
  wire resetn;
  assign resetn = ~resetclk;
  wire CLK_12MHz;
  CLK_12MHz clk_src(.CLKIN(CLK),.CLK_12MHz(CLK_12MHz),.resetn(resetn));
  
  // Micro Control Unit
  MCU51 MCU(.XTAL1(CLK_12MHz),.XTAL2(MHz12),.RST(reset),.EA(1'b1),.ALE(),.PSEN(),
            .P0(/*P0[7:0]*/),.P1(P1[7:0]),.P2(P2[7:0]),.P3(P3[7:0]));
endmodule