module MCU51(XTAL1,XTAL2,RST,EA,ALE,PSEN,P0,P1,P2,P3);

  input XTAL1,RST;   // 12MHz clock in and reset;
  output XTAL2;      // 12MHz clock out invsersely
  input EA;          // External Access Enable,  H internal ROM, L external ROM
  output ALE;        // Address Latch Enable,  High pulse when address effective
  output PSEN;       // Program Strobe Enable,  Low pulse to select external ROM
  inout [7:0] P0,P1,P2,P3;  // four 8-pins I/O port
  
  // clock ports
  wire clk;          // 12MHz clock MCU51 used
  assign clk = XTAL1;
  assign XTAL2 = ~XTAL1;
  
  wire Phase1,Phase2;
 
  wire Bb;                 // Byte/bit,   H Byte, L bit
  wire [7:0] position;     // position of bit
  wire [8:0] BUS;          // Bus for addresses,datas
  
  /*** four 8-pins I/O ports: P0~P3 ***/
  wire P0_io;                     // input/output enable of P0; H output, L input
  wire [7:0] P0_reg;              // 
  assign P0 = P0_io ? P0_reg[7:0] : 8'hzz;
  buffer buf_P0(.in(P0[7:0]),.en(~P0_io),.out(BUS[7:0]));
  wire P0_en;                     // enter a new value to SFR_P0
  wire P0_oe;                     // output enable of SFR_P0;
  SFR SFR_P0(.clk(clk),.reset(RST),.en(P0_en),.oe(P0_oe),.Bb(Bb),.position(position[7:0]),
         .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(P0_reg[7:0]));
  wire P1_io;                     // input/output enable of P1; H output, L input
  wire [7:0] P1_reg;              // 
  assign P1 = P1_io ? P1_reg[7:0] : 8'hzz;
  buffer buf_P1(.in(P1[7:0]),.en(~P1_io),.out(BUS[7:0]));
  wire P1_en;                     // enter a new value to SFR_P1
  wire P1_oe;                     // output enable of SFR_P1;
  SFR SFR_P1(.clk(clk),.reset(RST),.en(P1_en),.oe(P1_oe),.Bb(Bb),.position(position[7:0]),
         .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(P1_reg[7:0]));
  wire P2_io;                     // input/output enable of P2; H output, L input
  wire [7:0] P2_reg;              // 
  assign P2 = P2_io ? P2_reg[7:0] : 8'hzz;
  buffer buf_P2(.in(P2[7:0]),.en(~P2_io),.out(BUS[7:0]));
  wire P2_en;                     // enter a new value to SFR_P2
  wire P2_oe;                     // output enable of SFR_P2;
  SFR SFR_P2(.clk(clk),.reset(RST),.en(P2_en),.oe(P2_oe),.Bb(Bb),.position(position[7:0]),
         .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(P2_reg[7:0]));
  wire P3_io;                     // input/output enable of P3; H output, L input
  wire [7:0] P3_reg;              // 
  assign P3 = P3_io ? P3_reg[7:0] : 8'hzz;
  buffer buf_P3(.in(P3[7:0]),.en(~P3_io),.out(BUS[7:0]));
  wire P3_en;                     // enter a new value to SFR_P3
  wire P3_oe;                     // output enable of SFR_P3;
  SFR SFR_P3(.clk(clk),.reset(RST),.en(P3_en),.oe(P3_oe),.Bb(Bb),.position(position[7:0]),
         .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(P3_reg[7:0]));
  
  /*** Program Counter ***/
  wire PC_en;              // enter a new PC
  wire [15:0] PC_in,PC;    // next PC and current PC
  SFR PCH(.clk(clk),.reset(RST),.en(PC_en),.oe(1'b0),.Bb(1'b1),.position(8'h00),
          .din(PC_in[15:8]),.bin(1'b0),.dout(),.bout(),.cout(PC[15:8]));
  SFR PCL(.clk(clk),.reset(RST),.en(PC_en),.oe(1'b0),.Bb(1'b1),.position(8'h00),
          .din(PC_in[7:0]),.bin(1'b0),.dout(),.bout(),.cout(PC[7:0]));
  // MUX for PC_in
  wire Jump_flag;                  // H take jump, L no jump !!!including rel!!!
  wire [15:0] PC_Jump,PC_next;     // new PC for jump taken or untaken
  assign PC_in = Jump_flag?PC_Jump[15:0]:PC_next[15:0];
  // Register for rel. rel is different from addr11/addr16/direct/data for it take add
  wire rel_en;                     // enter a new rel
  wire [7:0] rel;                  // current rel out from R_rel
  SFR R_rel(.clk(clk),.reset(RST),.en(rel_en),.oe(1'b0),.Bb(1'b1),.position(8'h00),
          .din(BUS[7:0]),.bin(1'b0),.dout(),.bout(),.cout(rel[7:0]));
  // adder for PC_next
  wire PC_add_rel;                 // control PC to add rel or not,  H add rel, L add 1
  wire Cy_PC_next;                 // Carry from PCL to PCH
  adder_8bits adder_PCH_next(.a(PC[15:8]),.b({8{PC_add_rel&rel[7]}}),     // signal extension for rel
                             .ci(Cy_PC_next),.s(PC_next[15:8]),.co());    // PC_add_rel switch 8'h00 to rel
  adder_8bits adder_PCL_next(.a(PC[7:0]),.b(({8{PC_add_rel}}&rel[7:0])),  // PC_add_rel switch 8'h00 to rel
                             .ci(1'b1),.s(PC_next[7:0]),.co(Cy_PC_next)); // always add 1 including rel is added
  
  /*** Code ROM internal ***/
  wire CODE_CS;        // CODE Chip Select 
  Byte_Mem_pregramed CODE(.clk(clk),.CS(CODE_CS&EA),.addr(PC[7:0]),.dout(BUS[7:0]));
  
  /*** Instruction Register ***/
  wire IR_en;              // enter a new Instruction
  wire [7:0] IR;           // current IR
  SFR R_IR(.clk(clk),.reset(RST),.en(IR_en),.oe(1'b0),.Bb(1'b1),.position(8'h00),
           .din(BUS[7:0]),.bin(1'b0),.dout(),.bout(),.cout(IR[7:0]));
  
  /*** Registers for values temporary ***/
  // Register for Value1(address) temporary
  wire R_V1t_en;            // enter a new temp value
  wire R_V1t_oe;            // output current temp value in R_V1t
  //wire [7:0] R_V1t_in;      // temp value to enter R_V1t
  wire [7:0] Value1;        // current temp value in R_V1t for special using
  SFR R_V1t(.clk(clk),.reset(RST),.en(R_V1t_en),.oe(R_V1t_oe),.Bb(Bb),.position(position[7:0]),
            .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(Value1[7:0]));
  // Register for Value2(data) temporary
  wire R_V2t_en;            // enter a new temp value
  wire R_V2t_oe;            // output current temp value in R_V2t
  //wire [7:0] R_V2t_in;      // temp value to enter R_V2t
  wire [7:0] Value2;        // current temp value in R_V2t for special using
  SFR R_V2t(.clk(clk),.reset(RST),.en(R_V2t_en),.oe(R_V2t_oe),.Bb(Bb),.position(position[7:0]),
            .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(Value2[7:0]));
  
  /*** Program State Word ***/
  wire PSW_en,PSW_oe;
  wire [7:0] PSW_in;
  wire Cy,AC,F0,RS1,RS0,OV,F1,P;
  wire Phase;//reg  Cy2ALU,AC2ALU;
  SFR PSW(.clk(clk),.reset(RST),.en(PSW_en|(ALU_oe&Phase)),.oe(PSW_oe),.Bb(Bb),.position(position[7:0]),
          .din(PSW_in[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout({Cy,AC,F0,RS1,RS0,OV,F1,P}));
  assign PSW_in = PSW_en ? BUS[7:0] : 
                          {8{~ALU_oe}}&{Cy,AC,F0,RS1,RS0,OV,F1,^A}|
						  {8{ ALU_oe}}&{Carry,AssistantCarry,F0,RS1,RS0,OVerflow,F1,^A};
  //always@(negedge ALU_oe) begin Cy2ALU <= Cy; AC2ALU <= AC; end

  /*** Arithmetic Logic Unit ***/
  wire [3:0] ALUCode;
  wire A_used;
  reg  [7:0] A2ALU;
  wire [7:0] Result;
  wire Carry,AssistantCarry,OVerflow;
  ALU ALUin51(.ALUCode(ALUCode[3:0]),.A(A_used?A2ALU[7:0]:BUS[7:0]),.B(Value2[7:0]),.Cy(Cy),.AC(AC),
              .Result(Result[7:0]),.Carry(Carry),.AssistantCarry(AssistantCarry),.OVerflow(OVerflow));
  /*** B ***/
  wire B_en,B_oe;
  wire [7:0] B;
  SFR SFR_B(.clk(clk),.reset(RST),.en(B_en),.oe(B_oe),.Bb(Bb),.position(position[7:0]),
            .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(B[7:0]));
  
  /*** A ***/
  wire A_en,A_oe;
  wire [7:0] A_in,A;
  SFR SFR_A(.clk(clk),.reset(RST),.en(A_en),.oe(A_oe),.Bb(Bb),.position(position[7:0]),
            .din(A_in[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(A[7:0]));
  assign A_in = ALU_oe ? Result[7:0] : BUS[7:0];
  always@(negedge clk)    A2ALU <= A[7:0];
  // to hold the results of ALU discarded by A
  wire R_ALU_oe;  // recall the result of ALU
  wire [7:0] ALU_reged;
  SFR R_ALU(.clk(clk),.reset(RST),.en(ALU_oe),.oe(R_ALU_oe),.Bb(Bb),.position(position[7:0]),
            .din(Result[7:0]),.bin(1'bz),.dout(BUS[7:0]),.bout(BUS[8]),.cout(ALU_reged[7:0]));			
  
  wire  ZA,ZALU;
  assign ZA   = ~(|A[7:0]);
  assign ZALU = ~(|ALU_reged[7:0]);
  
  /*** Data RAM internal ***/
  wire DATA_CS,DATA_RW;
  reg [7:0] DATA_addr;
  DATARAM DATA(.clk(clk),.CS(DATA_CS),.RW(DATA_RW),.Bb(Bb),.addr(DATA_addr[7:0]),.position(position[7:0]),
               .din(BUS[7:0]),.dout(BUS[7:0]),.bin(BUS[8]),.bout(BUS[8]));
  // Copy of Ri
  wire [3:0] group_decode;   // decode from addr[4:3] to group select signals
  assign group_decode = {(DATA_addr[4:3]==2'b11),
                         (DATA_addr[4:3]==2'b10),
                         (DATA_addr[4:3]==2'b01),
                         (DATA_addr[4:3]==2'b00)};
  wire [1:0] Ri_decode;      // decode from addr[2:0] to Ri select signals
  assign Ri_decode = {(DATA_addr[2:0]==3'b001),
                      (DATA_addr[2:0]==3'b000)};					  
  wire [7:0] Ri_en;          // enter for Ri copy
  assign Ri_en = {{Ri_decode[1],Ri_decode[0]}&{2{group_decode[3]}},
                  {Ri_decode[1],Ri_decode[0]}&{2{group_decode[2]}},
                  {Ri_decode[1],Ri_decode[0]}&{2{group_decode[1]}},
                  {Ri_decode[1],Ri_decode[0]}&{2{group_decode[0]}}}&{8{(DATA_addr[7:5] == 3'b000)&~(DATA_CS|DATA_RW)}};
  wire [7:0] R1_at_out,R0_at_out;
  SFR R31(.clk(clk),.reset(RST),.en(Ri_en[7]),.oe(RS1&RS0),   .Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R1_at_out),.bout(),.cout());
  SFR R30(.clk(clk),.reset(RST),.en(Ri_en[6]),.oe(RS1&RS0),   .Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R0_at_out),.bout(),.cout());
  SFR R21(.clk(clk),.reset(RST),.en(Ri_en[5]),.oe(RS1&~RS0),  .Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R1_at_out),.bout(),.cout());
  SFR R20(.clk(clk),.reset(RST),.en(Ri_en[4]),.oe(RS1&~RS0),  .Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R0_at_out),.bout(),.cout());
  SFR R11(.clk(clk),.reset(RST),.en(Ri_en[3]),.oe(~RS1&RS0),  .Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R1_at_out),.bout(),.cout());
  SFR R10(.clk(clk),.reset(RST),.en(Ri_en[2]),.oe(~RS1&RS0),  .Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R0_at_out),.bout(),.cout());
  SFR R01(.clk(clk),.reset(RST),.en(Ri_en[1]),.oe(~(RS1&RS0)),.Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R1_at_out),.bout(),.cout());
  SFR R00(.clk(clk),.reset(RST),.en(Ri_en[0]),.oe(~(RS1&RS0)),.Bb(Bb),.position(position[7:0]),.din(BUS[7:0]),.bin(BUS[8]),.dout(R0_at_out),.bout(),.cout());
  // Register for direct
  wire direct_en;                     // enter a new direct
  wire [7:0] direct;                  // current direct out from R_direct
  SFR R_direct(.clk(clk),.reset(RST),.en(direct_en),.oe(1'b0),.Bb(1'b1),.position(8'h00),
               .din(BUS[7:0]),.bin(1'b0),.dout(),.bout(),.cout(direct[7:0]));
  // Register for rel. rel is different from addr11/addr16/direct/data for it take add
  wire bit_en;                     // enter a new bit address
  wire [7:0] bit_addr;             // current bit address out from R_bit.  bit is a keep word!!! so bit_addr used!!!
  SFR R_bit(.clk(clk),.reset(RST),.en(bit_en),.oe(1'b0),.Bb(1'b1),.position(8'h00),
            .din(BUS[7:0]),.bin(1'b0),.dout(),.bout(),.cout(bit_addr[7:0]));
  // addressing: direct or Rn extension or Ri indirect or bit 
  wire Rn_ext,Ri_at;
  always@(clk)
    case({Rn_ext,Ri_at,Bb})
	3'b001   : DATA_addr   <= direct[7:0];                    // direct addressing
	3'b101   : DATA_addr   <= {3'b000,RS1,RS0,IR[2:0]};       // Rn addressing
	3'b011   : DATA_addr   <= IR[0]?R1_at_out[7:0]:R0_at_out; // Ri indirect addressing
	3'b000   : DATA_addr   <= {4'h2,bit_addr[6:3]};
	default  : DATA_addr   <= 8'hzz;
	endcase

  /*** CLR Register and SWAP Register ***/
  wire CLR_oe,SWAP_oe;
  SFR SFR_CLR(.clk(clk),.reset(RST),.en(~CLR_oe),.oe(CLR_oe),.Bb(Bb),.position(position[7:0]),
              .din(8'h00),.bin(1'b0),.dout(BUS[7:0]),.bout(BUS[8]),.cout());
  SFR SFR_SWAP(.clk(clk),.reset(RST),.en(~SWAP_oe),.oe(SWAP_oe),.Bb(1'b1),.position(8'h00),
               .din({A[3:0],A[7:4]}),.bin(1'b0),.dout(BUS[7:0]),.bout(),.cout());  

  /*** Control Unit ***/
  wire PSEN_EA;
  CU ControlUnit(.clk(clk),.reset(RST),.IR(IR[7:0]),.direct(direct[7:0]),.ZA(ZA),.ZALU(ZALU),
          // output control signal
		  .Phase(Phase),.ALE(ALE),.PSEN(PSEN_EA),.RD(),.WR(),
		  .PC_CON({PC_en,Jump_flag,PC_add_rel}),
		  .CODE_CS(CODE_CS),.IR_en(IR_en),
		  .Bb(Bb),.position(position[7:0]),
		  .Rn_ext(Rn_ext),.Ri_at(Ri_at),
		  .XDATA_CON(),.DATA_CON({DATA_RW,DATA_CS}),
		  .rel_en(rel_en),
		  .direct_en(direct_en),.bit_en(bit_en),
		  .R_V1t_CON({R_V1t_en,R_V1t_oe}),
		  .R_V2t_CON({R_V2t_en,R_V2t_oe}),
		  .ALU_CON({R_ALU_oe,A_used,ALUCode[3:0],ALU_oe}),
		  .A_CON({A_bypass,A_en,A_oe}),.B_CON({B_en,B_oe}),
		  .PSW_CON({PSW_en,PSW_oe}),
		  .CLR_oe(CLR_oe),.SWAP_oe(SWAP_oe),
          .P0_CON({P0_io,P0_en,P0_oe}),
          .P1_CON({P1_io,P1_en,P1_oe}),
          .P2_CON({P2_io,P2_en,P2_oe}),
          .P3_CON({P3_io,P3_en,P3_oe})
		  );
  assign PSEN = PSEN_EA|EA;
endmodule
/*   wire P1_oe;               // output enable of P1;
  wire [7:0] P1_in,P1_out;  // use normally when input or output respectivly
  assign P1 = P1_oe ? P1_out[7:0] : 8'hzz;
  assign P1_in = P1[7:0];
  wire P1_en;                     // enter a new value to SFR_P1
  wire P1_src;                    // select source to enter SFR_P1, H internal, L external
  wire P1_re;                     // read enable of SFR_P1;
  SFR SFR_P1(.clk(clk),.reset(RST),.en(P1_en),.oe(P1_re),.Bb(Bb),.position(position[7:0]),
         .din(P1_src?BUS[7:0]:P1_in[7:0]),.bin(BUS[8]),
  		 .dout(BUS[7:0]),.bout(BUS[8]),.cout(P1_out[7:0]));
  wire P2_oe;               // output enable of P2;
  wire [7:0] P2_in,P2_out;  // use normally when input or output respectivly
  assign P2 = P2_oe ? P2_out[7:0] : 8'hzz;
  assign P2_in = P2[7:0];
  wire P2_en;                     // enter a new value to SFR_P2
  wire P2_src;                    // select source to enter SFR_P2, H internal, L external
  wire P2_re;                     // read enable of SFR_P2;
  SFR SFR_P2(.clk(clk),.reset(RST),.en(P2_en),.oe(P2_re),.Bb(Bb),.position(position[7:0]),
         .din(P2_src?BUS[7:0]:P2_in[7:0]),.bin(BUS[8]),
  		 .dout(BUS[7:0]),.bout(BUS[8]),.cout(P2_out[7:0]));
  wire P3_oe;               // output enable of P3;
  wire [7:0] P3_in,P3_out;  // use normally when input or output respectivly
  assign P3 = P3_oe ? P3_out[7:0] : 8'hzz;
  assign P3_in = P3[7:0];
  wire P3_en;                     // enter a new value to SFR_P3
  wire P3_src;                    // select source to enter SFR_P3, H internal, L external
  wire P3_re;                     // read enable of SFR_P3;
  SFR SFR_P3(.clk(clk),.reset(RST),.en(P3_en),.oe(P3_re),.Bb(Bb),.position(position[7:0]),
         .din(P3_src?BUS[7:0]:P3_in[7:0]),.bin(BUS[8]),
  		 .dout(BUS[7:0]),.bout(BUS[8]),.cout(P3_out[7:0])); */