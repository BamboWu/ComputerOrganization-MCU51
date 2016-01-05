`timescale 1ns / 1ps
module top_tb();
  parameter DELAY = 10;
  parameter delay = 1000;
  reg CLK,resetn,reset;
  wire [7:0] P0,P1,P2,P3;  
  
  top uut(.CLK(CLK),.resetn(resetn),.reset(reset),.P0(P0),.P1(P1),.P2(P2),.P3(P3));
  
  initial begin
	// Initialize Inputs
	CLK = 0;
  end
  always #(DELAY/2) CLK=~CLK;
  
  initial begin
    resetn = 1'b0;
    #(DELAY*2);
    resetn = 1'b1;
	#(DELAY*500);
	reset = 1'b1;
	#delay;
	reset = 1'b0;
	#(delay*25);
	$stop;
  end
  
endmodule