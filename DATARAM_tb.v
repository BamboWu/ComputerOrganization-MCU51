`timescale 1ns / 1ps
module DATARAM_tb();
  parameter DELAY = 100;
  reg clk,CS,RW,Bb,bin;
  reg [7:0] addr,position,din;
  wire bout;
  wire [7:0] dout;  
  
  DATARAM uut(.clk(clk),.CS(CS),.RW(RW),.Bb(Bb),.addr(addr),.position(position),
              .din(din),.dout(dout),.bin(bin),.bout(bout));
  
  initial begin
	// Initialize Inputs
	clk = 0;
	#(DELAY*15) $stop;
  end
  always #(DELAY/2) clk=~clk;
  
  initial begin
    CS = 1'b0; RW = 1'b0; Bb = 1; position = 8'h01;
	addr = 8'h07; din = 8'h78; bin = 1;
	#DELAY;
	addr = 8'h22; din = 8'h87;
	#DELAY;
	addr = 8'h30; din = 8'h55;
	#DELAY;
	Bb = 0; position = 8'h02;
	addr = 8'h08; bin = 1'b1;
	#DELAY;
	addr = 8'h07; bin = 1'b1;
	#DELAY;
	addr = 8'h22; bin = 1'b0;
	#DELAY;
	RW = 1'b1;
	addr = 8'h08;
	#DELAY;
	Bb = 1;
	addr = 8'h07;
	#DELAY;
	addr = 8'h22;
	#DELAY;
	addr = 8'h30;
	#DELAY;
  end
  
endmodule