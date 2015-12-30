//******************************************************************************
// MCU51 verilog model
//
// ALU.v
//
// The ALU performs all the arithmetic/logical integer operations 
// specified by the ALUsel from the decoder. 
// 
// verilog written QMJ
// modified by Baby Panda
//
//******************************************************************************

module ALU (
	// Outputs
	Result,Carry,AssistantCarry
	// Inputs
	ALUCode, A, B , Ci
);

	input [3:0]	ALUCode;				// Operation select
	input [7:0] A, B;
	input Ci;                           // current Cy

	output reg[7:0]	Result;
	output Carry,AssistantCarry;

    // Decoded ALU operation select (ALUsel) signals
    parameter	 alu_inc  =  4'b0000;
    parameter	 alu_dec  =  4'b0001;
    parameter	 alu_add  =  4'b0010;
    parameter	 alu_addc =  4'b0011;
    parameter	 alu_orl  =  4'b0100;
    parameter	 alu_anl  =  4'b0101;
    parameter	 alu_xrl  =  4'b0110;
    parameter	 alu_subb =  4'b1001;
	
	// 8 bits adder
	wire[7:0] sum;
    wire B;
    assign Binvert = ~(ALUCode==alu_add);   // B inversed for subtract
	adder_8bits adder_ALU(.a(A),.b(B^{32{Binvert}}),.ci(Binvert),.s(sum),.co(Carry));

	reg [7:0] Res_ALU;
	always@(*)
    case(ALUCode)
	  alu_add  : Res_ALU = sum[7:0];
	  alu_sub  : Res_ALU = sum[7:0];
      alu_and  : Res_ALU = A[7:0] & B[7:0];	  
      alu_xor  : Res_ALU = A[7:0] ^ B[7:0];	  
      alu_or   : Res_ALU = A[7:0] | B[7:0];	  
      alu_nor  : Res_ALU = ~(A[7:0] | B[7:0]);  
      alu_andi : Res_ALU = A & {16'd0,B[15:0]};
      alu_xori : Res_ALU = A ^ {16'd0,B[15:0]};
      alu_ori  : Res_ALU = A | {16'd0,B[15:0]};
      alu_sll  : Res_ALU = B << A;
      alu_srl  : Res_ALU = B >> A;
      alu_sra  : Res_ALU = B_reg >>> A;
      alu_slt  : Res_ALU = A[7]&&(~B[7]) || (A[7]~^B[7])&&sum[7];
      alu_sltu : Res_ALU = {7'd0,~Carry};
      default  : Res_ALU = {32{1'bz}};
    endcase	  

	
//******************************************************************************
// Shift operation: ">>>" will perform an arithmetic shift, but the operand
// must be reg signed
//******************************************************************************
	reg signed [7:0] B_reg;
	
	always @(B) begin
		B_reg = B;
	end

	
   
  
  
   
   

	
//******************************************************************************
// ALU Result datapath
//******************************************************************************

   wire[7:0] Res_and,Res_xor,Res_or,Res_nor,Res_andi,Res_xori,Res_ori;
   wire[7:0] Res_sll,Res_srl,Res_sra,Res_slt,Res_sltu;
   
   adder_32bits adder_ALU(.a(A),.b(B^{32{Binvert}}),.ci(Binvert),.s(sum),.co(Carry));
   
	  
endmodule