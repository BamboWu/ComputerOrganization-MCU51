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
	Result,Carry,AssistantCarry,OVerflow,
	// Inputs
	ALUCode, A , B , Cy , AC
);

	input [3:0]	ALUCode;				// Operation select
	input [7:0] A, B;
	input Cy,AC;                        // current Cy and AC

	output reg[7:0]	Result;
	output reg Carry,AssistantCarry;

    // Decoded ALU operation select (ALUsel) signals
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
	// 8 bits adder
	wire[7:0] sum;
    wire Binvert,B_used,Cy_used;
    assign Binvert = ~((ALUCode==alu_add)|(ALUCode==alu_addc)|(ALUCode==alu_inc));   // B inversed for subtract?
	assign B_used =  ~(((ALUCode == alu_inc)|(ALUCode == alu_dec)));
	assign Cy_used = (~B_used)|Cy;
	wire AC_tmp,Carry_tmp;
	adder_4bits adder_ALU_L(.a(A[3:0]),.b((B[3:0]&{4{B_used}})^{4{Binvert}}),.ci(Cy_used^Binvert),.s(sum[3:0]),.co(AC_tmp));
	adder_4bits adder_ALU_H(.a(A[7:4]),.b((B[7:4]&{4{B_used}})^{4{Binvert}}),.ci(AC_tmp),.s(sum[7:4]),.co(Carry_tmp));
	// Digital Adjustment
	wire[7:0] DA;
	wire Lneed,Hneed;
	assign Lneed = A[3]&(A[2]|A[1]); // A[3:0] > 9
	assign Hneed = A[7]&(A[6]|A[5]); // A[7:4] > 9
	wire DAC_tmp,DACarry_tmp;
	adder_4bits adder_DA_L(.a(A[3:0]),.b(4'h6&{4{Lneed}}),.ci(1'b0),   .s(DA[3:0]),.co(DAC_tmp));
	adder_4bits adder_DA_H(.a(A[7:4]),.b(4'h6&{4{Hneed}}),.ci(DAC_tmp),.s(DA[7:4]),.co(DACarry_tmp));

	always@(*)
    case(ALUCode)
	  alu_add,
	  alu_addc,
	  alu_subb,
	  alu_inc,
	  alu_dec  : begin Result[7:0] <= sum[7:0];        Carry <= Carry_tmp;      AssistantCarry <= AC_tmp;  end
      alu_orl  : begin Result[7:0] <= A[7:0] | B[7:0]; Carry <= Cy;             AssistantCarry <= AC;      end 
	  alu_anl  : begin Result[7:0] <= A[7:0] & B[7:0]; Carry <= Cy;             AssistantCarry <= AC;      end  
      alu_xrl  : begin Result[7:0] <= A[7:0] ^ B[7:0]; Carry <= Cy;             AssistantCarry <= AC;      end  
      alu_cpl  : begin Result[7:0] <= ~A;              Carry <= Cy;             AssistantCarry <= AC;      end
      alu_rr   : begin Result[7:0] <= {A[0],A[7:1]};   Carry <= Cy;             AssistantCarry <= AC;      end
      alu_rrc  : begin Result[7:0] <= {Cy,A[7:1]};     Carry <= A[0];           AssistantCarry <= AC;      end
      alu_ll   : begin Result[7:0] <= {A[6:0],A[7]};   Carry <= Cy;             AssistantCarry <= AC;      end
      alu_llc  : begin Result[7:0] <= {A[6:0],Cy};     Carry <= A[7];           AssistantCarry <= AC;      end
      alu_da   : begin Result[7:0] <= DA[7:0];         Carry <= Cy|DACarry_tmp; AssistantCarry <= 1'b0;    end
	  default  : begin Result[7:0] = {32{1'bz}};       Carry <= Carry_tmp;      AssistantCarry <= AC;      end
    endcase	  

endmodule