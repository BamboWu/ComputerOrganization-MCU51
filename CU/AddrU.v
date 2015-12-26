module AddrU(state,cycles,IR,dirct,Addr_src,Addr_dst,Bb,position,Rn_ext);
  
  input [2:0] state;         // current state
  input [1:0] cycles;        // cycles remained
  input [7:0] IR;
  input [7:0] direct;
  
  output reg Bb;             // Byte/bit, H Byte, L bit
  output reg [7:0] position; // position of bit
  output reg Rn_ext;         // Rn address extension
  output reg [13:0] Addr_src;
  // {R_Vt1_oe,R_Vt2_oe,ALU_oe,XDATA_oe,XCODE_oe,DATA_oe,CODE_oe}
  parameter   Vt1_src = 7'b1000000;
  parameter   Vt2_src = 7'b0100000;
  parameter   ALU_src = 7'b0010000;
  parameter XDATA_src = 7'b0001000;
  parameter XCODE_src = 7'b0000100;
  parameter  DATA_src = 7'b0000010;
  parameter  CODE_src = 7'b0000001;
  parameter   SFR_src = 7'b0000000;
  //+{P0_re,SP_oe,DPL_oe,DPH_oe,PCON_oe,TCON_oe,TMOD_oe,TL0_oe,TL1_oe,TH0_oe,TH1_oe,P1_re,SCON_oe,SBUF_oe,P2_re,IE_oe,P3_re,IP_oe,PSW_oe,A_oe,B_oe}
  parameter    P0_src = 7'b1000000;
  parameter    P1_src = 7'b0100000;
  parameter    P2_src = 7'b0010000;
  parameter    P3_src = 7'b0001000;
  parameter   PSW_src = 7'b0000100;
  parameter     A_src = 7'b0000010;
  parameter     B_src = 7'b0000001;
  parameter  SFR_srcs = 7;
  output reg [12:0] Addr_dst;
  // {rel_en,IR_en,R_Vt1_en,R_Vt2_en,XDATA_en,DATA_en}
  parameter   rel_dst = 6'b100000;
  parameter    IR_dst = 6'b010000;
  parameter R_Vt1_dst = 6'b001000;
  parameter R_Vt2_dst = 6'b000100;
  parameter XDATA_dst = 6'b000010;
  parameter  DATA_dst = 6'b000001;
  parameter   SFR_dst = 6'b000000;
  //+{P0_en,SP_en,DPL_en,DPH_en,PCON_en,TCON_en,TMOD_en,TL0_en,TL1_en,TH0_en,TH1_en,P1_en,SCON_en,SBUF_en,P2_en,IE_en,P3_en,IP_en,PSW_en,A_en,B_en}
  parameter    P0_dst = 7'b1000000;
  parameter    P1_dst = 7'b0100000;
  parameter    P2_dst = 7'b0010000;
  parameter    P3_dst = 7'b0001000;
  parameter   PSW_dst = 7'b0000100;
  parameter     A_dst = 7'b0000010;
  parameter     B_dst = 7'b0000001;
  parameter  SFR_dsts = 7;
  
  // decode Addr_src
  always@(clk)
    casex({IR[7:0],direct[7:0]})
	16'hE5
	default : {14{1'b0}};
	endcase
  // decode Addr_dst
  always@(clk)
    casex({IR[7:0],direct[7:0]})
	
	default : {13{1'b0}};
	endcase
endmodule