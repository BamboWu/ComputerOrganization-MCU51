module CU(clk,reset,IR,direct,
          // output control signal
		  ALE,PSEN,
		  Bb,position,Rn_ext,Ri_at,
          P0_CON,P1_CON,P2_CON,P3_CON,
		  PC_CON,CODE_CS,IR_en,
		  R_Vt1_CON,R_Vt2_CON,
		  ALU_oe,
		  A_CON,B_CON,PSW_CON,
		  XDATA_CON,DATA_CON
		  );
  
  input clk,reset;
  input [7:0] IR;
  input [7:0] direct;
  
  output ALE;                    // Address Latch Enable, High pulse effective
  output PSEN;                   // Program Strobe Enable, Low pulse effective
  output wire Bb;                // Byte/bit, H Byte, L bit
  output wire [7:0] position;    // position of bit
  output wire Rn_ext;            // Rn address extension
  output wire Ri_at;             // Ri indirect addressing
  
  output wire [3:0] P0_CON,P1_CON,P2_CON,P3_CON; // {PX_oe,PX_en,PX_src,PX_re};
  output wire [3:0] PC_CON; // {PC_en,Jump_flag,PC_add_rel,rel_en};
  output reg  CODE_CS;      // CODE Chip Select, Low effective
  output wire IR_en;        // enter a new Instruction to IR
  output wire [1:0] R_Vt1_CON,R_Vt2_CON; // {R_Vtx_en,R_Vtx_oe};
  output wire ALU_oe;
  output wire [1:0] A_CON,B_CON;         // {A/B_en,A/B_oe};
  output wire [1:0] PSW_CON;             // {PSW_en,PSW_oe};
  output reg  [1:0] XDATA_CON,DATA_CON;  // {X/DATA_RW,X/DATA_CS}
  
  // Clock Unit
  wire Phase;
  reg [1:0] cycles;
  wire [1:0] cycles_decoded;
  ClkU ClockUnit(.clk(clk),.reset(reset),.IR(IR[7:0]),.Phase(Phase),.ALE(ALE),.PSEN(PSEN),.cycles(cycles_decoded[1:0]));
  
  reg [2:0] state,state_next;
  // states lists
  parameter PC_out_latch        = 3'b000;  // S2
  parameter Data_wait_valid     = 3'b010;  // S3
  parameter Data_load_use       = 3'b110;  // S4
  parameter PC_out_latch_2nd    = 3'b111;  // S5
  parameter Data_wait_valid_2nd = 3'b101;  // S6-1
  parameter Data_load_use_2nd   = 3'b100;  // S1-1
  parameter Opcode_wait_valid   = 3'b011;  // S6-0
  parameter Opcode_load_decode  = 3'b001;  // S1-0
  // Finite States Machine
  always@(negedge Phase)
    state <= reset?PC_out_latch_2nd:state_next[2:0];
  always@(posedge Phase)
    casex({reset,state[2:0],cycles[1:0]})
	 6'b1xxxxx                       : state_next <= Opcode_wait_valid;
	{1'b0,PC_out_latch_2nd   ,2'b00} : state_next <= Opcode_wait_valid;
	{1'b0,Opcode_wait_valid  ,2'b00} : state_next <= Opcode_load_decode;
	{1'b0,Opcode_load_decode ,2'bxx} : state_next <= PC_out_latch;
	{1'b0,PC_out_latch       ,2'bxx} : state_next <= Data_wait_valid;
	{1'b0,Data_wait_valid    ,2'bxx} : state_next <= Data_load_use;
	{1'b0,Data_load_use      ,2'bxx} : state_next <= PC_out_latch_2nd;
	{1'b0,PC_out_latch_2nd   ,2'b11},
    {1'b0,PC_out_latch_2nd   ,2'b10},
	{1'b0,PC_out_latch_2nd   ,2'b01} : state_next <= Data_wait_valid_2nd;
	{1'b0,Data_wait_valid_2nd,2'b11} ,
	{1'b0,Data_wait_valid_2nd,2'b10} ,
	{1'b0,Data_wait_valid_2nd,2'b01} : state_next <= Data_load_use_2nd;
	{1'b0,Data_load_use_2nd  ,2'b11} ,
	{1'b0,Data_load_use_2nd  ,2'b10} ,
	{1'b0,Data_load_use_2nd  ,2'b01} : state_next <= PC_out_latch;
	default                          : state_next <= Opcode_wait_valid;	
	endcase
  always@(posedge clk)
    casex({reset,state[2:0]})
	 4'b1xxx                  : cycles <= 2'b00;
	{1'b0,Opcode_load_decode} : cycles <= cycles_decoded[1:0];
	{1'b0,Data_wait_valid_2nd}: cycles <= Phase?cycles-1:cycles;
	default                   : cycles <= cycles[1:0];
	endcase

  // Address Unit
  wire discard;
  wire [4:0] ChipSel; // {XDATA_W,XDATA_CS,DATA_W,DATA_CS,CODE_CS}
  AddrU AddressUnit(.state(state[2:0]),.cycles(cycles[1:0]),.IR(IR[7:0]),.direct(direct[7:0]),
                    .discard(discard),.Bb(Bb),.position(position[7:0]),
					.Rn_ext(Rn_ext),.Ri_at(Ri_at), // Rn address extension and Ri indirect addressing
					.ChipSel(ChipSel[4:0]),       // {XDATA_W,XDATA_CS,DATA_W,DATA_CS,CODE_CS}
					
					.Addr_src({R_Vt1_CON[0],R_Vt2_CON[0],ALU_oe,
					           P0_CON[0],P1_CON[0],P2_CON[0],P3_CON[0],PSW_CON[0],A_CON[0],B_CON[0]}),
					
					.Addr_dst({rel_en,IR_en,R_Vt1_CON[1],R_Vt2_CON[1],
					           P0_CON[2],P1_CON[2],P2_CON[2],P3_CON[2],PSW_CON[1],A_CON[1],B_CON[1]}));
  always@(ChipSel[4:0])	
    begin
	  XDATA_CON <= ~ChipSel[4:3]|PSEN;
	  DATA_CON <= ~ChipSel[2:1]|PSEN;
	  CODE_CS <= ~ChipSel[0]|PSEN;
	end
	
  // no jump first
  assign PC_CON[2:0] = 2'b000;
  assign PC_CON[3] = ALE&((state==Opcode_load_decode)|(state==Data_load_use))&(~discard);
    
endmodule