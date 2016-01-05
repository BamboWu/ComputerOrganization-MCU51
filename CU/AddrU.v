module AddrU(IR,direct,
             cycles,S,Phase,
			 // output
			 PC_en,PC_add_rel,Jump_flag,
			 Bb,position,Rn_ext,Ri_at,
			 Addr_src,Addr_dst);
  
/************************************** PORTS *****************************************/		  
  input [7:0] IR;
  input [7:0] direct;
  
  input [1:0] cycles;        // cycles remained
  input [2:0] S;             // current S
  input       Phase;         // current Phase
  
  output reg PC_en;          // enter a new PC
  output reg PC_add_rel;     // switch PC+1 to PC+rel
  output reg Jump_flag;      // switch PC_next to PC_Jump  
  
  output reg Bb;             // Byte/bit, H Byte, L bit
  output reg [7:0] position; // position of bit
  output reg Rn_ext;         // Rn address extension
  output reg Ri_at;          // Ri indirect addressing 
  
  output reg [12:0] Addr_src;
  // {CODE_src,DATA_src,XDATA_src} Memory
  parameter  CODE_src = 3'b100;
  parameter  DATA_src = 3'b010;
  parameter XDATA_src = 3'b001;
  parameter  SSFR_src = 3'b000;
  //+{R_Vt1_oe,R_Vt2_oe,ALU_oe}   Super Special Function Registers
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
  
  output reg [14:0] Addr_dst;
  // {DATA_dst,XDATA_dst} Memory
  parameter   DATA_dst = 2'b10;
  parameter  XDATA_dst = 2'b01;
  parameter   SSFR_dst = 2'b00;
  //+{rel_en,IR_en,direct_en,bit_en,R_Vt1_en,R_Vt2_en}  Super Special Function Registers
  parameter    rel_dst = 6'b100000;
  parameter     IR_dst = 6'b010000;
  parameter direct_dst = 6'b001000;
  parameter    bit_dst = 6'b000100;
  parameter  R_Vt1_dst = 6'b000010;
  parameter  R_Vt2_dst = 6'b000001;
  parameter    SFR_dst = 6'b000000;
  //+{P0_en,SP_en,DPL_en,DPH_en,PCON_en,TCON_en,TMOD_en,TL0_en,TL1_en,TH0_en,TH1_en,P1_en,SCON_en,SBUF_en,P2_en,IE_en,P3_en,IP_en,PSW_en,A_en,B_en}    User Special Function Registers
  parameter     P0_dst = 7'b1000000;
  parameter     P1_dst = 7'b0100000;
  parameter     P2_dst = 7'b0010000;
  parameter     P3_dst = 7'b0001000;
  parameter    PSW_dst = 7'b0000100;
  parameter      A_dst = 7'b0000010;
  parameter      B_dst = 7'b0000001;
  
/************************************** ADDRS TAB *****************************************/		  
  // S1~S6
  parameter S1 = 3'b001;
  parameter S2 = 3'b011;
  parameter S3 = 3'b010;
  parameter S4 = 3'b000;
  parameter S5 = 3'b100;
  parameter S6 = 3'b101;
  // instructions list
  
  // control PC
  always@(IR[7:0] or cycles[1:0] or S[2:0] or Phase)
    casex({IR[7:0],cycles[1:0],S[2:0],Phase})
	{8'bxxxxxxxx,2'b11,S1,1'b1} : begin PC_en <= 1'b1; PC_add_rel <= 1'b0; Jump_flag <= 1'b0; end
	/******************************* PC add for next Inst. **********************************/
	{8'b01110100,2'b00,S5,1'b0} : begin PC_en <= 1'b1; PC_add_rel <= 1'b0; Jump_flag <= 1'b0; end // MOV A,#
	default : begin PC_en <= 1'b0; PC_add_rel <= 1'b0; Jump_flag <= 1'b0; end
	endcase
  
  // decode Bb,position,Rn_ext,Ri_at
  always@(IR[7:0] or cycles[1:0] or S[2:0])
    casex({IR[7:0],cycles[1:0],S[2:0]})
	{8'b11111xxx,2'b00,S3} : begin Bb <= 1'b1; position <= 8'h00; Rn_ext <= 1'b1; Ri_at <= 1'b0; end  // MOV Rn,A
	default : begin Bb <= 1'b1; position <= 8'h00; Rn_ext <= 1'b0; Ri_at <= 1'b0; end
	endcase  
  
  // decode Addr_src
  always@(IR[7:0] or cycles[1:0] or S[2:0])
    casex({IR[7:0],cycles[1:0],S[2:0],direct[7:0]})
	{8'bxxxxxxxx,2'b00,S6,8'bxxxxxxxx} : Addr_src <= {CODE_src,SFR_src,{SFR_ennum{1'b0}}};
	/******************************* Opcode wiat valid **********************************/
	{8'b01110100,2'b00,S3,8'bxxxxxxxx} : Addr_src <= {CODE_src,SFR_src,{SFR_ennum{1'b0}}}; // MOV A,#
	{8'b11111xxx,2'b00,S3,8'bxxxxxxxx} : Addr_src <= {SSFR_src,SFR_src,{A_src}};           // MOV Rn,A
	default : Addr_src <= {SSFR_src,SFR_src,{SFR_ennum{1'b0}}};
	endcase
  // decode Addr_dst
  always@(IR[7:0] or cycles[1:0] or S[2:0] or Phase)
    casex({IR[7:0],cycles[1:0],S[2:0],direct[7:0],Phase})
	{8'bxxxxxxxx,2'b00,S6,8'bxxxxxxxx,1'b1} : Addr_dst <= {SSFR_dst,IR_dst,{SFR_ennum{1'b0}}};
	/******************************* Opcode wiat valid **********************************/
	{8'b01110100,2'b00,S3,8'bxxxxxxxx,1'b1} : Addr_dst <= {SSFR_dst,SFR_dst,A_dst};             // MOV A,#
	{8'b11111xxx,2'b00,S3,8'bxxxxxxxx,1'b1} : Addr_dst <= {DATA_dst,SFR_dst,{SFR_ennum{1'b0}}}; // MOV Rn,A
	default : Addr_dst <= {SSFR_dst,SFR_dst,{SFR_ennum{1'b0}}};
	endcase

endmodule
/*   always@(state[2:0])
    discard <= (ChipSel==NONE_CS)&(Addr_src=={SFR_src,{SFR_ennum{1'b0}}});
   */
/*   // states lists
  parameter PC_out_latch        = 3'b000;  // S2
  parameter Data_wait_valid     = 3'b010;  // S3
  parameter Data_load_use       = 3'b110;  // S4
  parameter PC_out_latch_2nd    = 3'b111;  // S5
  parameter Data_wait_valid_2nd = 3'b101;  // S6-1
  parameter Data_load_use_2nd   = 3'b100;  // S1-1
  parameter Opcode_wait_valid   = 3'b011;  // S6-0
  parameter Opcode_load_decode  = 3'b001;  // S1-0 */
/*   output reg [4:0] ChipSel;
  // {XDATA_W,XDATA_CS,DATA_W,DATA_CS,CODE_CS}
  parameter XDATA_W  = 5'b11000;
  parameter XDATA_R  = 5'b01000;
  parameter  DATA_W  = 5'b00110;
  parameter  DATA_R  = 5'b00010;
  parameter  CODE_CS = 5'b00001;
  parameter  NONE_CS = 5'b00000; */
/*   // decode ChipSel
  always@(state[2:0])
    casex({state[2:0],IR[7:0],direct[7:0]})
	{Opcode_wait_valid ,8'hxx,8'hxx} : ChipSel <= CODE_CS;  // EA choose then
	{Opcode_load_decode,8'hxx,8'hxx} : ChipSel <= CODE_CS;  // EA choose then
	/*******************************************************/
	/*{Data_wait_valid   ,8'h74,8'hxx} : ChipSel <= CODE_CS;
	{Data_load_use     ,8'h74,8'hxx} : ChipSel <= CODE_CS;
	{Data_wait_valid   ,8'b11101xxx,8'hxx} : ChipSel <= DATA_R;
	{Data_load_use     ,8'b11101xxx,8'hxx} : ChipSel <= DATA_R;
	{Data_wait_valid   ,8'b01111xxx,8'hxx} : ChipSel <= CODE_CS;
	{Data_load_use     ,8'bx1111xxx,8'hxx} : ChipSel <= DATA_W;
	default : ChipSel <= NONE_CS;
	endcase */