module top(CLK,reset,P0,P1,P2,P3);
  
  input CLK,reset;
  output wire [7:0] P0,P1,P2,P3;
  
  // clock supply
  wire CLK_12MHz;
  CLK_12MHz clk_src(.CLKIN(CLK),.CLK_12MHz(CLK_12MHz),.resetn(~reset));
  
  // Micro Control Unit
  MCU51 MCU(.XTAL1(CLK_12MHz),.XTAL2(),.RST(reset),.EA(1'b1),.ALE(),.PSEN(),
            .P0(P0[7:0]),.P1(P1[7:0]),.P2(P2[7:0]),.P3(P3[7:0]));
endmodule