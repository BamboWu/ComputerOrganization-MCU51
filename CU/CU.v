module CU(clk,reset,IR,direct,
          // output control signal
		  Phase,ALE,PSEN,RD,WR,
		  PC_CON,CODE_CS,IR_en,
		  Bb,position,
		  Rn_ext,Ri_at,
		  XDATA_CON,DATA_CON,
		  rel_en,
		  direct_en,bit_en,
		  R_V1t_CON,R_V2t_CON,
		  ALU_CON,
		  A_CON,B_CON,PSW_CON,
          P0_CON,P1_CON,P2_CON,P3_CON
		  );

/************************************** PORTS *****************************************/		  
  input clk,reset;
  input [7:0] IR;
  input [7:0] direct;
  
  output reg  Phase;                 // Phase
  output reg  ALE;                   // Address Latch Enable, High pulse effective
  output reg  PSEN;                  // Program Strobe Enable, Low pulse effective
  output reg  RD,WR;
  
  output wire [2:0] PC_CON;          // {PC_en,Jump_flag,PC_add_rel};
  output reg  CODE_CS;               // CODE Chip Select, Low effective
  output wire IR_en;                 // enter a new Instruction to IR

  output wire Bb;                    // Byte/bit, H Byte, L bit
  output wire [7:0] position;        // position of bit
  
  output wire Rn_ext;                // Rn address extension
  output wire Ri_at;                 // Ri indirect addressing
  
  output reg  [1:0] XDATA_CON,DATA_CON;          // {X/DATA_RW,X/DATA_CS}
  
  output wire rel_en;                            // enter a new rel
  output wire direct_en,bit_en;                  // enter a new direct/bit address
  
  output wire [1:0] R_V1t_CON,R_V2t_CON;         // {R_Vxt_en,R_Vxt_oe};
  output wire [1:0] ALU_CON;                     // {ALU_opcode,ALU_oe};
  output wire [1:0] PSW_CON;                     // {PSW_en,PSW_oe};
  output wire [1:0] A_CON,B_CON;                 // {A/B_en,A/B_oe};
  output wire [3:0] P0_CON,P1_CON,P2_CON,P3_CON; // {PX_oe,PX_en,PX_src,PX_re};

/************************************** STATE *****************************************/ 
  // reg [:] State = {cycles,S,Microp,Addr_src,Addr_dst};
  reg [1:0] cycles,cycles_next,cycles_decoded;  // 00-no cycle remains; 01-1 cycle remains; 10-2 cycles remain; 11-3 cycles remain;
  reg [2:0] S,S_next;           //
  // S1~S6
  parameter S1 = 3'b001;
  parameter S2 = 3'b011;
  parameter S3 = 3'b010;
  parameter S4 = 3'b000;
  parameter S5 = 3'b100;
  parameter S6 = 3'b101;
  reg [1:0] Microp,Microp_next;  // micro-operation
  // Microp list
  parameter Addr_out_latch     = 2'b00;
  parameter Opcode_wait_valid  = 2'b01;
  parameter Opcode_load_decode = 2'b11;
  parameter Data_flow          = 2'b10;

/************************************** PHASE *****************************************/  
  // Phase produce
  always@(negedge clk)
    if(reset)
	  Phase <= 1'b0;
	else
	  Phase <= ~Phase;
  wire Phase1,Phase2;
  assign Phase1 = ~Phase;
  assign Phase2 =  Phase;
 
/************************************** STATE MACHINE *****************************************/  
  // cycles state machine
  always@(negedge Phase2)
    case(reset)
	1'b1 : cycles <= 2'b00;   // -1
	1'b0 : cycles <= cycles_next[1:0];
	endcase
  always@(negedge Phase1)
    casex({reset,cycles[1:0],S[2:0]})
	{1'b1,2'bxx,3'bxxx} : cycles_next <= 2'b00;
	{1'b0,2'b11,S1} : cycles_next <= cycles_decoded[1:0]; // lookup table at the end
	{1'b0,2'b00,S6} : cycles_next <= 2'b11;               // -1
	{1'b0,2'b01,S6} : cycles_next <= 2'b00;
	{1'b0,2'b10,S6} : cycles_next <= 2'b01;
	{1'b0,2'b11,S6} : cycles_next <= 2'b10;
	default         : cycles_next <= cycles_next;
	endcase
  
  // S state machine
  always@(negedge Phase2)
    case(reset)
	1'b1 : S <= S5;
	1'b0 : S <= S_next[2:0];
	endcase
  always@(negedge Phase1)
    casex({reset,S[2:0]})
	4'b1xxx   : S_next <= S6;
	{1'b0,S1} : S_next <= S2;
	{1'b0,S2} : S_next <= S3;
	{1'b0,S3} : S_next <= S4;
	{1'b0,S4} : S_next <= S5;
	{1'b0,S5} : S_next <= S6;
	{1'b0,S6} : S_next <= S1;
	default   : S_next <= S6;
	endcase

  // Microp state machine
  always@(negedge Phase2)
    case(reset)
    1'b1 : Microp <= Addr_out_latch;
    1'b0 : Microp <= Microp_next[1:0];
    endcase
  always@(negedge Phase1)
    casex({reset,IR[7:0],cycles[1:0],S[2:0]})
	14'b1xxxxxxxxxxxxx    : Microp_next <= Opcode_wait_valid;
	{1'b0,8'hxx,2'b00,S4} : Microp_next <= Addr_out_latch;
	{1'b0,8'hxx,2'b00,S5} : Microp_next <= Opcode_wait_valid;
	{1'b0,8'hxx,2'b00,S6} : Microp_next <= Opcode_load_decode;
    default : Microp_next <= Data_flow;
	endcase	

/************************************** ADDRS *****************************************/  
  // Address Unit
  wire XDATA_src,XDATA_dst,DATA_src,DATA_dst,CODE_src;
  AddrU AddressUnit(.IR(IR[7:0]),.direct(direct[7:0]),
                    .cycles(cycles[1:0]),.S(S[2:0]),.Phase(Phase),
					// output
					.PC_en(PC_CON[2]),.PC_add_rel(PC_CON[0]),.Jump_flag(PC_CON[1]),
					.Bb(Bb),.position(position[7:0]),
					.Rn_ext(Rn_ext),.Ri_at(Ri_at),  // Rn address extension and Ri indirect addressing
					.Addr_src({CODE_src,DATA_src,XDATA_src,
					           R_V1t_CON[0],R_V2t_CON[0],ALU_oe,
					           P0_CON[0],P1_CON[0],P2_CON[0],P3_CON[0],PSW_CON[0],A_CON[0],B_CON[0]}),
					
					.Addr_dst({DATA_dst,XDATA_dst,
					           rel_en,IR_en,direct_en,bit_en,
							   R_V1t_CON[1],R_V2t_CON[1],
					           P0_CON[2],P1_CON[2],P2_CON[2],P3_CON[2],PSW_CON[1],A_CON[1],B_CON[1]}));
							   
  always@(XDATA_src or XDATA_dst or DATA_src or DATA_dst or CODE_src)
    begin
	  XDATA_CON <= {~XDATA_dst,~(XDATA_src|XDATA_dst)};
	   DATA_CON <= {~ DATA_dst,~( DATA_src| DATA_dst)};
	   CODE_CS  <=  ~CODE_src;
	end
							   
/************************************** ALE PSEN WR *****************************************/
  // ALE PSEN produce
  wire MOVX;
  assign MOVX = (IR[7:5]==3'b111)&(IR[3:2]==2'b00)&(IR[1]|~IR[0]); 
  wire noALE,noPSEN;
  assign noALE  = MOVX&(cycles==2'b00);
  assign noPSEN = MOVX&(cycles==2'b01);
  always@(negedge clk)
    casex(S[2:0])
	S1 : begin ALE <= (~noALE);        PSEN <= 1'b1;                             end
	S2 : begin ALE <= 1'b0;            PSEN <= noALE|~Phase;                     end
	S3 : begin ALE <= 1'b0;            PSEN <= noALE;                            end
	S4 : begin ALE <= 1'b1;            PSEN <= 1'b1;                             end
	S5 : begin ALE <= 1'b0;            PSEN <= noPSEN|~Phase;                    end
	S6 : begin ALE <= 1'b0;            PSEN <= noPSEN;                           end
	default : begin ALE <= 1'b0; PSEN <= 1'b1; end
	endcase

/************************************** CYCLES TAB *****************************************/
	// logic circuit decode cycles
  always@(IR[7:0])
    casex(IR[7:0])
	8'b10X01xxx : cycles_decoded <= 2'b01; // MOV Rn,dir / MOV dir,Rn
	8'b10000101 : cycles_decoded <= 2'b01; // MOV dir,dir
	8'b1000011x : cycles_decoded <= 2'b01; // MOV dir,@Ri
	8'b01110101 : cycles_decoded <= 2'b01; // MOV dir,#
	8'b1010011x : cycles_decoded <= 2'b01; // MOV @Ri,dir
    8'b1110001x : cycles_decoded <= 2'b01; // MOVX A,@Ri
	default : cycles_decoded <= 2'b00;
	endcase
  
endmodule
/* 	
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
 */
/*   // ID
  wire ID_en;
  assign ID_en = (cycles=2'b00)&&(S==S6);
  reg [7:0] ID;
  always@(negedge Phase2)
    if(ID_en) ID <= IR[7:0];
    else ID <= ID[7:0];
   */
/*   always@(ChipSel[4:0])	
    begin
	  XDATA_CON <= ~ChipSel[4:3]|PSEN;
	  DATA_CON <= ~ChipSel[2:1]|PSEN;
	  CODE_CS <= ~ChipSel[0]|PSEN;
	end
	
  // no jump first
  assign PC_CON[2:0] = 2'b000;
  //assign PC_CON[3] = ALE&((Microp==Opcode_load_decode)|(Microp==Addr_out_latch));
   */
/************************************** PC CON *****************************************/
  // control PC
/*   assign PC_CON[2:0] = 2'b000;
  assign PC_CON[3] = ALE&((Phase&(S==S1))|(~Phase&(S=S5)))&;
 */    
/* 	{S1,1'b1,1'b0} : begin ALE <= ~(MOVX&(cycles==2'b00)); PSEN <= 1'b1; end
	{S1,1'b0,1'b1} : begin ALE <= ~(MOVX&(cycles==2'b00)); PSEN <= 1'b1; end
	{S2,1'b1,1'b0} : begin ALE <= 1'b0;                    PSEN <= 1'b1; end
	{S2,1'b0,1'b1} : begin ALE <= 1'b0;                    PSEN <= 1'b0; end
	{S3,1'b1,1'b0} : begin ALE <= 1'b0;                    PSEN <= 1'b0; end
	{S3,1'b0,1'b1} : begin ALE <= 1'b0;                    PSEN <= 1'b0; end
	{S4,1'b1,1'b0} : begin ALE <= 1'b1;                    PSEN <= 1'b1; end
	{S4,1'b0,1'b0} : begin ALE <= 1'b1;                    PSEN <= 1'b1; end
	{S5,1'b1,1'b0} : begin ALE <= 1'b0;                    PSEN <= 1'b1; end
	{S5,1'b0,1'b1} :                                       PSEN <= (MOVX&(cycles==2'b01)); */