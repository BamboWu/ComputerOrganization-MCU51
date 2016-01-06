`timescale 1ns / 1ps
module ALU_tb();
  parameter DELAY = 10;
  reg clk;
  
    parameter	 alu_inc  =  4'b0000;
    parameter	 alu_dec  =  4'b0001;
    parameter	 alu_add  =  4'b0010;
    parameter	 alu_addc =  4'b0011;
    parameter	 alu_orl  =  4'b0100;
    parameter	 alu_anl  =  4'b0101;
    parameter	 alu_xrl  =  4'b0110;
	parameter    alu_cpl  =  4'b0111;
	parameter    alu_da   =  4'b1000;
    parameter	 alu_subb =  4'b1001;
	parameter    alu_rr   =  4'b1100;
	parameter    alu_rrc  =  4'b1101;
	parameter    alu_rl   =  4'b1110;
	parameter    alu_rlc  =  4'b1111;
  
  reg [7:0] A,Value1,Value2;
  reg [3:0] ALUCode;
  reg A_used,Cy,AC;
  wire [7:0] Result;
  wire Carry,AssistantCarry,OVerflow;
  ALU uut(.ALUCode(ALUCode[3:0]),.A(A_used?A[7:0]:Value1[7:0]),.B(Value2[7:0]),.Cy(Cy),.AC(AC),
          .Result(Result[7:0]),.Carry(Carry),.AssistantCarry(AssistantCarry),.OVerflow(OVerflow));
  
  initial begin
	// Initialize Inputs
	clk = 0;
  end
  always #(DELAY/2) clk=~clk;
  
  initial begin
    // initial
    A = 8'h00; Value1 = 8'h00; Value2 = 8'h00;
	ALUCode = 4'b0000;
	A_used = 1'b1;
	#DELAY;
	
	// ADD
	#DELAY;
	ALUCode = alu_add; A = 8'h01; Value2 = 8'h09; Cy = 1'b1; AC =1'b0;
	A_used = 1'b1;
	#DELAY;
	ALUCode = alu_add; Value1 = 8'h02; Value2 = 8'h08;
	A_used = 1'b0;
	#DELAY;
	// ADDC
	ALUCode = alu_addc; Value1 = 8'h03; Value2 = 8'h07; Cy = 1'b0;
	A_used = 1'b0;
	#DELAY;
	ALUCode = alu_addc; Value1 = 8'h04; Value2 = 8'h06; Cy = 1'b1;
	A_used = 1'b1;
	#DELAY;
	// SUBB
	ALUCode = alu_subb; A = 8'h05; Value2 = 8'h05; Cy = 1'b0;
	A_used = 1'b1;
	#DELAY;
	ALUCode = alu_subb; Value1 = 8'h04; Value2 = 8'h06; Cy = 1'b0;
	A_used = 1'b0;
	#DELAY;
    // INC DEC
	ALUCode = alu_inc; A = 8'hFF; Value2 = 8'h07; Cy = 1'b1;
	A_used = 1'b1;
	#DELAY;
	ALUCode = alu_dec; A = 8'h00; Value2 = 8'h08; Cy = 1'b1;
	#DELAY;
	// LOGIC
	ALUCode = alu_cpl; A = 8'h55; Value2 = 8'h09; Cy = 1'b0;
	#DELAY;
    ALUCode = alu_anl; A = 8'h56; Value2 = 8'h0F; Cy = 1'b0;
	#DELAY;
	ALUCode = alu_orl; A = 8'h65; Value2 = 8'hF0; Cy = 1'b0;
	#DELAY;
	ALUCode = alu_xrl; A = 8'hAA; Value2 = 8'h55; Cy = 1'b0;
	#DELAY;
	// RR
	ALUCode = alu_rr ; A = 8'hC3; Cy = 1'b0;
	#DELAY;
	// RRC
	ALUCode = alu_rrc; A = 8'hC3; Cy = 1'b0;
	#DELAY;
	// RL
	ALUCode = alu_rl ; A = 8'h7E; Cy = 1'b1;
	#DELAY;
    // RLC
	ALUCode = alu_rlc; A = 8'h7E; Cy = 1'b1;
	#DELAY;
    // DA
	ALUCode = alu_da;  A = 8'h0A; Cy = 1'b0; AC = 1'b0;
	#DELAY;
	ALUCode = alu_da;  A = 8'h22; Cy = 1'b0; AC = 1'b1;
	#DELAY;
	ALUCode = alu_da;  A = 8'h22; Cy = 1'b1; AC = 1'b0;
	#DELAY;
	ALUCode = alu_da;  A = 8'hA2; Cy = 1'b0; AC = 1'b0;
	#DELAY;
	// test OV
	ALUCode = alu_add; A = 8'h79; Value2 = 8'h07; Cy = 1'b1;
	#DELAY;
	ALUCode = alu_add; A = 8'h79; Value2 = 8'h77;
	#DELAY;
	ALUCode = alu_add; A = 8'h87; Value2 = 8'h07;
	#DELAY;
	ALUCode = alu_subb;A = 8'h79; Value2 = 8'h7A;
	#DELAY;
	ALUCode = alu_subb;A = 8'h79; Value2 = 8'h87;
	#DELAY;
	ALUCode = alu_subb;A = 8'h87; Value2 = 8'h0E;
	#DELAY;
	#DELAY;
	$stop;
  end
  
endmodule