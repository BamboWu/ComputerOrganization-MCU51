module MCU51(CLK,reset);

  input CLK,reset;
  
  
  CLK_12MHz clk_src(.CLKIN(CLK),.CLK_12MHz(CLK_12MHz),.resetn(~reset));

endmodule