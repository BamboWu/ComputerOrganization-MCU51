`timescale 1ns / 1ps
module top_tb();
  parameter DELAY = 10;
  parameter delay = 1000;
  reg CLK,reset,resetclk;
  wire [7:0] P0,P1,P2,P3;  
  
  top uut(.CLK(CLK),.reset(reset),.resetclk(resetclk),.MHz12(),/*.P0(),*/.P1(P1)/*,.P2(),.P3()*/);
  
  initial begin
	// Initialize Inputs
	CLK = 0;
  end
  always #(DELAY/2) CLK=~CLK;
  
  initial begin
    resetclk = 1'b1;
    #(DELAY*2);
    resetclk = 1'b0;
	#(DELAY*500);
	reset = 1'b1;
	#delay;
	reset = 1'b0;
	#(delay*50);
	$stop;
  end
  
endmodule