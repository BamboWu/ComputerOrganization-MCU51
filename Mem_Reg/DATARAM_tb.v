`timescale 1ns / 1ps
module DATARAM_tb();
  parameter DELAY = 10;
  reg clk,CS,RW,Bb,bin;
  reg [7:0] addr,position,din;
  wire bout;
  wire [7:0] dout;  
  
  DATARAM uut(.clk(clk),.CS(CS),.RW(RW),.Bb(Bb),.addr(addr[7:0]),.position(position[7:0]),
              .din(din[7:0]),.dout(dout[7:0]),.bin(bin),.bout(bout));
  
  initial begin
	// Initialize Inputs
	clk = 0;
	#(DELAY*3000) $stop;
  end
  always #(DELAY/2) clk=~clk;
  
  initial begin
    // write byte to Rn
    CS = 1'b0; RW = 1'b0; Bb = 1; position = 8'h01;
	addr = 8'h07; din = 8'h55; bin = 1;
	#DELAY;
	CS = 1'b1;
	// write byte to Ri
	#DELAY;
	CS = 1'b0; RW = 1'b0; Bb = 1; position = 8'h01;
	addr = 8'h00; din = 8'h07; bin = 1;
	#DELAY;
	CS = 1'b1;
    #(DELAY*2);
	// write byte to bit area
	CS = 1'b0; RW = 1'b0; Bb = 1; position = 8'h00;
	addr = 8'h20; din = 8'h87;
	#DELAY;
	CS = 1'b1;
	#(DELAY*2);
	// write byte to byte area
	CS = 1'b0; RW = 1'b0; Bb = 1; position = 8'h00;
	addr = 8'h30; din = 8'h55;
	#DELAY;
	CS = 1'b1;
	#(DELAY*2);
    // modify bit of Rn
	CS = 1'b0; RW = 1'b0; Bb = 0; position = 8'h02;
	addr = 8'h07; bin = 1'b1;
	#DELAY;
	CS = 1'b1;
	#(DELAY*2);
	// modify bit in bit area
	CS = 1'b0; RW = 1'b0; Bb = 0; position = 8'h02;
	addr = 8'h20; bin = 1'b0;
	#DELAY;
	CS = 1'b1;
	#(DELAY*2);
	
	// read bit of Rn
	CS = 1'b0; RW = 1'b1; Bb = 0; position = 8'h02;
	addr = 8'h07;
	#(DELAY*2);
	// read byte of Rn
	CS = 1'b0; RW = 1'b1; Bb = 1; position = 8'h02;
	addr = 8'h07;
	#(DELAY*2);
	CS = 1'b1;
	#(DELAY*2);
    // read byte in bit area
	CS = 1'b0; RW = 1'b1; Bb = 1; position = 8'h00;
	addr = 8'h20;
	#(DELAY*2);
    // read byte from byte area
	CS = 1'b0; RW = 1'b1; Bb = 1; position = 8'h02;
	addr = 8'h30;
	#(DELAY*2);
	// trigate
	CS = 1'b1;
	#(DELAY*2);
	$stop;
  end
  
endmodule