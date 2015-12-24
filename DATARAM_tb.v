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
	#(DELAY*30) $stop;
  end
  always #(DELAY/2) clk=~clk;
  
  initial begin
    #(DELAY/2);
    // write byte to Rn
    CS = 1'b0; RW = 1'b0; Bb = 1; position = 8'h01;
	addr = 8'h07; din = 8'h78; bin = 1;
    #(DELAY*2);
	// write byte to bit area
	addr = 8'h22; din = 8'h87;
	#(DELAY*2);
	// write byte to byte area
	addr = 8'h30; din = 8'h55;
	#(DELAY*2);
	// write bit to Rn
	Bb = 0; position = 8'h02;
	addr = 8'h08; bin = 1'b1;
	#(DELAY*2);
    // modify bit of Rn
	addr = 8'h07; bin = 1'b1;
	#(DELAY*2);
	// modify bit in bit area
	addr = 8'h22; bin = 1'b0;
	#(DELAY*2);
	// read bit of Rn
	RW = 1'b1;
	addr = 8'h08;
	#(DELAY*2);
	// read byte of Rn
	Bb = 1;
	addr = 8'h07;
	#(DELAY*2);
	addr = 8'h22;
	#(DELAY*2);
    // read byte in bit area
	addr = 8'h30;
	#(DELAY*2);
    // read byte from byte area
	CS = 1'b1;
	#(DELAY*2);
	// trigate
  end
  
endmodule