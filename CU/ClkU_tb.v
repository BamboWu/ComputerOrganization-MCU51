`timescale 1ns / 1ps
module ClkU_tb();
  parameter DELAY = 100;
  reg CLK,reset,EA;
  reg [7:0] IR;
  wire Phase,ALE,PSEN;
  
  ClkU uut(.clk(CLK),.reset(reset),.EA(EA),.IR(IR),.Phase(Phase),.ALE(ALE),.PSEN(PSEN));
  
  initial begin
	// Initialize Inputs
	CLK = 0;
	#(DELAY*100) $stop;
  end
  always #(DELAY/2) CLK=~CLK;
  
  initial begin
    reset = 1'b1;
	EA = 1'b0;
	#(DELAY);
	reset = 1'b0;
	#(DELAY*4);
	#(DELAY/2);
	IR = 8'h00;
	#(DELAY*24);
	IR = 8'hf0;
	#(DELAY*24);
	EA = 1'b1;
	#(DELAY*12);
    IR = 8'he3;
	#(DELAY*24);
	
	#(DELAY*2);
	
	#(DELAY*2);
	
	#(DELAY*2);
	
	#(DELAY*2);
    
	#(DELAY*2);
    
	#(DELAY*2);
	
	
  end
  
endmodule