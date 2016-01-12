`timescale 1ns / 1ps
module top_tb();
  parameter DELAY = 10;
  parameter delay = 1000;
  reg CLK,reset,resetclk;
  wire [7:0] P0,P1;
  reg  [7:0] P2,P3;  
  
  top uut(.CLK(CLK),.reset(reset),.resetclk(resetclk),.MHz12(),.P0(P0[7:0]),.P1L(P1[3:0]),.P2(P2[7:0]),.P3(P3[7:0]));
  
  initial begin
	// Initialize Inputs
	CLK = 0;
  end
  always #(DELAY/2) CLK=~CLK;
  
  initial begin
    resetclk = 1'b1;
	P2 = 8'h12; P3 = 8'h98;
    #(DELAY*2);
    resetclk = 1'b0;
	P2 = 8'h12; P3 = 8'h98;
    #(DELAY*500);
	reset = 1'b1;
	P2 = 8'h12; P3 = 8'h98;
    #delay;
	reset = 1'b0;
	#(delay*50);
	$stop;
  end
  
endmodule