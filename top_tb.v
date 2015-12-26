`timescale 1ns / 1ps
module top_tb();
  parameter DELAY = 100;
  reg CLK,reset,prog;
  wire [7:0] P0,P1,P2,P3;  
  
  top uut(.CLK(CLK),.reset(reset),.P0(P0),.P1(P1),.P2(P2),.P3(P3));
  
  initial begin
	// Initialize Inputs
	CLK = 0;
	#(DELAY*30) $stop;
  end
  always #(DELAY/2) CLK=~CLK;
  
  initial begin
    #(DELAY/2);
    reset = 1'b1;
    #(DELAY*2);
	reset = 1'b0;
	#(DELAY*2);
	
	#(DELAY*2);
	
	#(DELAY*2);
    
	#(DELAY*2);
	
	#(DELAY*2);
	
	#(DELAY*2);
	
	#(DELAY*2);
	
	#(DELAY*2);
    
	#(DELAY*2);
    
	#(DELAY*2);
	
	
  end
  
endmodule