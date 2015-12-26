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
 
  
 
  wire Bb;                 // Byte/bit,   H Byte, L bit
  wire [7:0] position;     // position of bit
  wire [8:0] BUS;          // Bus for addresses,datas
  
  // four 8-pins I/O ports: P0~P3
  wire P0_oe;                     // output enable of P0;
  wire [7:0] P0_in,P0_out;        // use normally when input or output respectivly
  assign P0 = P0_oe ? P0_out[7:0] : 8'hzz;
  assign P0_in = P0[7:0];
  wire P0_en;                     // enter a new value to SFR_P0
  wire P0_src;                    // select source to enter SFR_P0, H internal, L external
  wire P0_re;                     // read enable of SFR_P0;
  SFR SFR_P0(.clk(clk),.reset(RST),.en(P0_en),.oe(P0_re),.Bb(Bb),.position(position[7:0]),
         .din(P0_src?BUS[7:0]:P0_in[7:0]),.bin(BUS[8]),
  		 .dout(BUS[7:0]),.bout(BUS[8]),.cout(P0_out[7:0]));
  wire P1_oe;               // output enable of P1;
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
  		 .dout(BUS[7:0]),.bout(BUS[8]),.cout(P3_out[7:0]));
  
  // Program Counter
  wire PC_en;              // enter a new PC
  wire [15:0] PC_in,PC;    // next PC and current PC
  SFR PCH(.clk(clk),.reset(RST),.en(PC_en),.oe(1'b0),.Bb(1'b1),.position(8'hzz),
          .din(PC_in[15:8]),.bin(1'bz),.dout(),.bout(),.cout(PC[15:8]));
  SFR PCL(.clk(clk),.reset(RST),.en(PC_en),.oe(1'b0),.Bb(1'b1),.position(8'hzz),
          .din(PC_in[7:0]),.bin(1'bz),.dout(),.bout(),.cout(PC[7:0]));
  // MUX for PC_in
  wire Jump_flag;                  // H take jump, L no jump !!!including rel!!!
  wire [15:0] PC_Jump,PC_next;     // new PC for jump taken or untaken
  assign PC_in = Jump_flag?PC_Jump[15:0]:PC_next[15:0];
              //({16{Jump_flag}}&PC_Jump)|({16{~Jump_flag}}&PC_next);
  // Register for rel. rel is different from addr11/addr16/direct/data for it take add
  wire rel_en;         // enter a new rel
  wire [7:0] rel;      // current rel out from R_rel
  SFR R_rel(.clk(clk),.reset(RST),.en(rel_en),.oe(1'b0),.Bb(1'b1),.position(8'hzz),
          .din(BUS[7:0]),.bin(1'bz),.dout(),.bout(),.cout(rel[7:0]));
  // adder for PC_next
  wire PC_add_rel;     // control PC to add rel or not,  H add rel, L add 1
  wire Cy_PC_next;     // Carry from PCL to PCH
  adder_8bits adder_PCH_next(.a(PC[15:8]),.b({8{PC_add_rel&rel[7]}}),     // signal extension for rel
                             .ci(Cy_PC_next),.s(PC_next[15:8]),.co());    // PC_add_rel switch 8'h00 to rel
  adder_8bits adder_PCL_next(.a(PC[7:0]),.b(({8{PC_add_rel}}&rel[7:0])),  // PC_add_rel switch 8'h00 to rel
                             .ci(1'b1),.s(PC_next[7:0]),.co(Cy_PC_next)); // always add 1 including rel is added
  
  // Instruction Register
  wire IR_en;              // enter a new Instruction
  wire [15:0] IR;          // current IR
  SFR SFR_IR(.clk(clk),.reset(RST),.en(IR_en),.oe(1'b0),.Bb(1'b1),.position(8'hzz),
         .din(BUS[7:0]),.bin(1'bz),.dout(),.bout(),.cout(IR[7:0]));
  
  // Register for Value1(address) temporary
  wire R_V1t_en;            // enter a new temp value
  wire R_V1t_oe;            // output current temp value in R_V1t
  wire [7:0] R_V1t_in;      // temp value to enter R_V1t
  wire [7:0] Value1;        // current temp value in R_V1t for special using
  SFR R_V1t(.clk(clk),.reset(RST),.en(R_V1t_en),.oe(R_V1t_oe),.Bb(Bb),.position(position[7:0]),
            .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(Value1[7:0]));
  // Register for Value2(data) temporary
  wire R_V2t_en;            // enter a new temp value
  wire R_V2t_oe;            // output current temp value in R_V2t
  wire [7:0] R_V2t_in;      // temp value to enter R_V2t
  wire [7:0] Value2;        // current temp value in R_V2t for special using
  SFR R_V2t(.clk(clk),.reset(RST),.en(R_V2t_en),.oe(R_V2t_oe),.Bb(Bb),.position(position[7:0]),
            .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout(Value2[7:0]));
  			
  // Program State Word
  wire PSW_en,PSW_oe,Cy,AC,F0,RS1,RS0,OV,F1,P;
  SFR PSW(.clk(clk),.reset(RST),.en(PSW_en),.oe(PSW_oe),.Bb(Bb),.position(position[7:0]),
          .din(BUS[7:0]),.bin(BUS[8]),.dout(BUS[7:0]),.bout(BUS[8]),.cout({Cy,AC,F0,RS1,RS0,OV,F1,P}));

  CU ControlUnit(.clk(clk),.reset(reset),.EA(EA),.IR(IR[7:0]),
                 .Bb(Bb),.position(position[7:0]),
                 .P0_CON({P0_oe,P0_en,P0_src,P0_re}),
                 .P1_CON({P1_oe,P1_en,P1_src,P1_re}),
                 .P2_CON({P2_oe,P2_en,P2_src,P2_re}),
                 .P3_CON({P3_oe,P3_en,P3_src,P3_re}),
				 .PC_CON({PC_en,Jump_flag,PC_add_rel}),
				 .IR_en(IR_en),
				 .R_Vt1_CON({R_Vt1_en,R_Vt1_oe}),
				 .R_Vt2_CON({R_Vt2_en,R_Vt2_oe}),
				 .PSW_CON({PSW_en,PSW_oe})
				 );
endmodule