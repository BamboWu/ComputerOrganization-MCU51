module CU(clk,reset,EA,IR,
          // output control signal
		  ALE,PSEN,
		  Bb,position,Rn_ext,
          P0_CON,P1_CON,P2_CON,P3_CON,
		  PC_CON,IR_en,
		  R_Vt1_CON,R_Vt2_CON,
		  PSW_CON
		  );
  
  input clk,reset,EA;
  input [7:0] IR;
  
  output ALE;                    // Address Latch Enable, High pulse effective
  output PSEN;                   // Program Strobe Enable, Low pulse effective
  output wire Bb;                // Byte/bit, H Byte, L bit
  output wire [7:0] position;    // position of bit
  output wire Rn_ext;            // Rn address extension
  
  output wire [3:0] P0_CON,P1_CON,P2_CON,P3_CON; // {PX_oe,PX_en,PX_src,PX_re};
  output wire [2:0] PC_CON; // {PC_en,Jump_flag,PC_add_rel};
  output wire IR_en;
  output wire [1:0] R_Vt1_CON,R_Vt2_CON; // {R_Vtx_en,R_Vtx_oe};
  output wire [1:0] PSW_CON; // {PSW_en,PSW_oe};
  
  // Clock Unit
  wire Phase;
  wire [1:0] cycles_decoded;
  ClkU ClockUnit(.clk(clk),.reset(reset),.EA(EA),.IR(IR[7:0]),.Phase(Phase),.ALE(ALE),.PSEN(PSEN));
  AddrU AddressUnit(.state(state[2:0]),.cycles(cycles[1:0]),.IR(IR[7:0]),.dirct(dirct[7:0]),
                    .Bb(Bb),.position(position[7:0]),.Rn_ext(Rn_ext),
					.Addr_src(),
					.Addr_dst());
  
  reg [2:0] state,state_next;
  // states lists
  parameter PC_out_latch        = 3'b000;  // S2
  parameter Data_wait_valid     = 3'b010;  // S3
  parameter Data_load_use       = 3'b110;  // S4
  parameter PC_out_latch_2nd    = 3'b111;  // S5
  parameter Data_wait_valid_2nd = 3'b101;  // S6-1
  parameter Data_load_use_2nd   = 3'b100;  // S1-1
  parameter Opcode_wait_valid   = 3'b011;  // S6-0
  parameter Opcode_load_deecode = 3'b001;  // S1-0
  // Finite States Machine
  always@(negedge Phase)
    state <= reset?PC_out_latch:state_next[2:0];
  wire [1:0] cycles;
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
	 3'b1xxx                  : cycles <= 2'b00;
	{1'b0,Opcode_load_decode} : cycles <= cycles_decoded[1:0];
	{1'b0,PC_out_latch}       : cycles <= Phase?cycles-1:cycles;
	default                   : cycles <= cycles[1:0];
	endcase
	
  reg PC_en;	
  always@(posedge clk)
    PC_en <= ALE;
  assign PC_CON[2] = PC_en;
  /*
  parameter PC_out_last    = 8'b00000010;
  parameter PC_latch_last  = 8'b00000000;
  parameter wait_Opcode    = 8'b00000100;
  parameter Opcode_valid   = 8'b00000110;
  parameter lOpcode        = 8'b00000111;
  parameter decode         = 8'b00000011;
  parameter lValue         = 8'b00000111;
  parameter uValue         = 8'b00000101;
  parameter lDirect        = 8'b00001110;
  parameter Opcode_wait_valid  = 3'b001;
  parameter Opcode_load_decode = 3'b011;
  parameter PC_out_latch1_3    = 3'b011;
  parameter PC_out_latch2_3    = 3'b101;
  parameter Data_wait_valid2_3 = 3'b100;
  parameter Data_load_use2_3   = 3'b100;
  parameter PC_out_latch3_3    = 3'b110;
  parameter Data_wait_valid3_3 = 3'b010;
  parameter Data_load_use3_3   = 3'b000;
  */
endmodule