module AddrU(state,cycles,IR,direct,
             discard,Bb,position,Rn_ext,Ri_at,
			 ChipSel,Addr_src,Addr_dst);
  
  input [2:0] state;         // current state
  input [1:0] cycles;        // cycles remained
  
  input [7:0] IR;
  input [7:0] direct;
  
  output reg discard;        // discard fetch, PC no increase
  output reg Bb;             // Byte/bit, H Byte, L bit
  output reg [7:0] position; // position of bit
  output reg Rn_ext;         // Rn address extension
  output reg Ri_at;          // Ri indirect addressing
  
  output reg [4:0] ChipSel;
  // {XDATA_W,XDATA_CS,DATA_W,DATA_CS,CODE_CS}
  parameter XDATA_W  = 5'b11000;
  parameter XDATA_R  = 5'b01000;
  parameter  DATA_W  = 5'b00110;
  parameter  DATA_R  = 5'b00010;
  parameter  CODE_CS = 5'b00001;
  parameter  NONE_CS = 5'b00000;
  
  output reg [9:0] Addr_src;
  // {R_Vt1_oe,R_Vt2_oe,ALU_oe}   Super Special Function Registers
  parameter   Vt1_src = 3'b100;
  parameter   Vt2_src = 3'b010;
  parameter   ALU_src = 3'b001;
  parameter   SFR_src = 3'b000;
  //+{P0_re,SP_oe,DPL_oe,DPH_oe,PCON_oe,TCON_oe,TMOD_oe,TL0_oe,TL1_oe,TH0_oe,TH1_oe,P1_re,SCON_oe,SBUF_oe,P2_re,IE_oe,P3_re,IP_oe,PSW_oe,A_oe,B_oe}    User Special Function Registers
  parameter    P0_src = 7'b1000000;
  parameter    P1_src = 7'b0100000;
  parameter    P2_src = 7'b0010000;
  parameter    P3_src = 7'b0001000;
  parameter   PSW_src = 7'b0000100;
  parameter     A_src = 7'b0000010;
  parameter     B_src = 7'b0000001;
  
  // number for User Special Function Registers enabled
  parameter  SFR_ennum = 7;
  
  output reg [10:0] Addr_dst;
  // {rel_en,IR_en,R_Vt1_en,R_Vt2_en}  Super Special Function Registers
  parameter   rel_dst = 4'b1000;
  parameter    IR_dst = 4'b0100;
  parameter R_Vt1_dst = 4'b0010;
  parameter R_Vt2_dst = 4'b0001;
  parameter   SFR_dst = 4'b0000;
  //+{P0_en,SP_en,DPL_en,DPH_en,PCON_en,TCON_en,TMOD_en,TL0_en,TL1_en,TH0_en,TH1_en,P1_en,SCON_en,SBUF_en,P2_en,IE_en,P3_en,IP_en,PSW_en,A_en,B_en}    User Special Function Registers
  parameter    P0_dst = 7'b1000000;
  parameter    P1_dst = 7'b0100000;
  parameter    P2_dst = 7'b0010000;
  parameter    P3_dst = 7'b0001000;
  parameter   PSW_dst = 7'b0000100;
  parameter     A_dst = 7'b0000010;
  parameter     B_dst = 7'b0000001;
  
  // states lists
  parameter PC_out_latch        = 3'b000;  // S2
  parameter Data_wait_valid     = 3'b010;  // S3
  parameter Data_load_use       = 3'b110;  // S4
  parameter PC_out_latch_2nd    = 3'b111;  // S5
  parameter Data_wait_valid_2nd = 3'b101;  // S6-1
  parameter Data_load_use_2nd   = 3'b100;  // S1-1
  parameter Opcode_wait_valid   = 3'b011;  // S6-0
  parameter Opcode_load_decode  = 3'b001;  // S1-0
  
  // decode Bb,position,Rn_ext,Ri_at
  always@(state[2:0])
    casex({state[2:0],IR[7:0],direct[7:0]})
	{Data_wait_valid   ,8'b11101xxx,8'hxx} : begin Bb <= 1'b1; position <= 8'h00; Rn_ext <= 1'b1; Ri_at <= 1'b0; end
	{Data_load_use     ,8'bx1111xxx,8'hxx} : begin Bb <= 1'b1; position <= 8'h00; Rn_ext <= 1'b1; Ri_at <= 1'b0; end
	default : begin  Bb <= 1'b1; position <= 8'h00; Rn_ext <= 1'b0; Ri_at <= 1'b0; end
	endcase
  
  // decode ChipSel
  always@(state[2:0])
    casex({state[2:0],IR[7:0],direct[7:0]})
	{Opcode_wait_valid ,8'hxx,8'hxx} : ChipSel <= CODE_CS;  // EA choose then
	{Opcode_load_decode,8'hxx,8'hxx} : ChipSel <= CODE_CS;  // EA choose then
	/*******************************************************/
	{Data_wait_valid   ,8'h74,8'hxx} : ChipSel <= CODE_CS;
	{Data_load_use     ,8'h74,8'hxx} : ChipSel <= CODE_CS;
	{Data_wait_valid   ,8'b11101xxx,8'hxx} : ChipSel <= DATA_R;
	{Data_load_use     ,8'b11101xxx,8'hxx} : ChipSel <= DATA_R;
	{Data_wait_valid   ,8'b01111xxx,8'hxx} : ChipSel <= CODE_CS;
	{Data_load_use     ,8'bx1111xxx,8'hxx} : ChipSel <= DATA_W;
	default : ChipSel <= NONE_CS;
	endcase
  
  // decode Addr_src
  always@(state[2:0])
    casex({state[2:0],IR[7:0],direct[7:0]})
	{Data_wait_valid   ,8'h74,8'hxx} : Addr_src <= {SFR_src,{SFR_ennum{1'b0}}};
	{Data_load_use     ,8'h74,8'hxx} : Addr_src <= {SFR_src,{SFR_ennum{1'b0}}};
	{Data_load_use     ,8'b11111xxx,8'hxx} : Addr_src <= {SFR_src,A_src};
	default : Addr_src <= {SFR_src,{SFR_ennum{1'b0}}};
	endcase
  // decode Addr_dst
  always@(state[2:0])
    casex({state[2:0],IR[7:0],direct[7:0]})
	{Opcode_load_decode,8'hxx,8'hxx} : Addr_dst <= {IR_dst,{SFR_ennum{1'b0}}};  // EA choose then
	/***************************************************************************/
	{Data_load_use     ,8'h74,8'hxx} : Addr_dst <= {SFR_dst,A_dst};
	{Data_load_use     ,8'b11101xxx,8'hxx} : Addr_dst <= {SFR_dst,A_dst};
	{Data_load_use     ,8'bx1111xxx,8'hxx} : Addr_dst <= {SFR_dst,{SFR_ennum{1'b0}}};
	default : Addr_dst <= {SFR_dst,{SFR_ennum{1'b0}}};
	endcase

  always@(state[2:0])
    discard <= (ChipSel==NONE_CS)&(Addr_src=={SFR_src,{SFR_ennum{1'b0}}});
  
endmodule