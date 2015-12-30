`timescale 1ns / 1ps
module top_tb();
  parameter DELAY = 10;
  parameter delay = DELAY*(100/12);
  reg CLK,resetn,reset;
  wire [7:0] P0,P1,P2,P3;  
  
  top uut(.CLK(CLK),.resetn(resetn),.reset(reset),.P0(P0),.P1(P1),.P2(P2),.P3(P3));
  
  initial begin
	// Initialize Inputs
	CLK = 0;
	#(delay*300) $stop;
  end
  always #(DELAY/2) CLK=~CLK;
  
  initial begin
    resetn = 1'b0;
    #(delay*2);
    resetn = 1'b1;
	#(delay*100);
	reset = 1'b1;
	#(delay*2);
	reset = 1'b0;
	#(delay*15);
	#(DELAY*12);
	        
	#(DELAY*12);
            
	#(DELAY*12);
	        
	#(DELAY*12);
	        
	#(DELAY*12);
	        
	#(DELAY*12);
	        
	#(DELAY*12);
            
	#(DELAY*12);
            
	#(DELAY*12);
	
  end
  
endmodule