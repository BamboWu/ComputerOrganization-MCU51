`timescale 1ns / 1ps
module CU_tb();
  parameter DELAY = 1000/12;
  reg clk,reset;
  reg [7:0] IR,direct;
  
  wire Phase,ALE,PSEN;
  wire PC_en,PC_add_rel,Jump_flag,CODE_CS,IR_en;
  wire Bb;
  wire [7:0] position;
  wire Rn_ext,Ri_at;
  wire DATA_CS,DATA_RW;
  wire rel_en,direct_en,bit_en;	  
  
  CU uut(.clk(clk),.reset(reset),.IR(IR[7:0]),.direct(direct[7:0]),
          // output control signal
		  .Phase(Phase),.ALE(ALE),.PSEN(PSEN),.RD(),.WR(),
		  .PC_CON({PC_en,Jump_flag,PC_add_rel}),
		  .CODE_CS(CODE_CS),.IR_en(IR_en),
		  .Bb(Bb),.position(position[7:0]),
		  .Rn_ext(Rn_ext),.Ri_at(Ri_at),
		  .XDATA_CON(),.DATA_CON({DATA_RW,DATA_CS}),
		  .rel_en(rel_en),
		  .direct_en(direct_en),.bit_en(bit_en),
		  .R_Vt1_CON(/*{R_Vt1_en,R_Vt1_oe}*/),
		  .R_Vt2_CON(/*{R_Vt2_en,R_Vt2_oe}*/),
		  .ALU_CON(),
		  .A_CON(/*{A_en,A_oe}*/),.B_CON(/*{B_en,B_oe}*/),
		  .PSW_CON(/* {PSW_en,PSW_oe} */),
          .P0_CON(/* {P0_oe,P0_en,P0_src,P0_re} */),
          .P1_CON(/* {P1_oe,P1_en,P1_src,P1_re} */),
          .P2_CON(/* {P2_oe,P2_en,P2_src,P2_re} */),
          .P3_CON(/* {P3_oe,P3_en,P3_src,P3_re} */)
		  );
  
  initial begin
	// Initialize Inputs
	clk = 0;
	#(DELAY*144) $stop;
  end
  always #(DELAY/2) clk=~clk;
  
  initial begin
    reset = 1'b1;
    #(DELAY*12);
	IR = 8'h00;
    reset = 1'b0;
	#(DELAY*3);
	#(DELAY/2);
	IR = 8'h00;
	direct = 8'h00;
	#(DELAY*12);
	IR = 8'h74;
	#(DELAY*4);
	IR = 8'h55;
	#(DELAY*8);
	IR = 8'hE2;
	#(DELAY*12);
	#(DELAY*12);
	IR = 8'hE3;
	#(DELAY*12);
	        
	#(DELAY*12);
            
	#(DELAY*12);
	        
	#(DELAY*12);
	        
	#(DELAY*12);
	        
	#(DELAY*12);
	        
	#(DELAY*12);
            
	#(DELAY*12);
            
	#(DELAY*12);
	
  end
  
endmodule