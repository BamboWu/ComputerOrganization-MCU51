module ClkU(clk,reset,IR,Phase,ALE,PSEN,cycles);

  input clk,reset;
  input [7:0] IR;
  
  output reg Phase,ALE,PSEN;
  output reg [1:0] cycles;

  wire clk_n;
  assign clk_n = ~clk;
  always@(posedge clk_n)
    Phase <= reset ? 1'b0 : ~Phase;

  wire MOVX;
  assign MOVX = (IR[7:5]==3'b111)&(IR[3:2]==2'b00)&(IR[1]|~IR[0]); 
  
  reg [4:0] num = 9;
  always@(posedge clk_n)
    casex({reset,MOVX,num[4:0]})
	7'b1xxxxxx : num <= 9;
	7'b0101100 : num <= 13;
	7'b0001100 : num <= 1;
	7'b0x11000 : num <= 1;
	default : num <= num+1;
	endcase
  
  always@(num[4:0])
    casex(num[4:0])
	5'd2,5'd3,5'd8,5'd9,5'd20,5'd21 : begin ALE <= 1'b1; PSEN <= 1'b1; end
	5'd1,5'd5,5'd6,5'd7,5'd23,5'd24 : begin ALE <= 1'b0; PSEN <= 1'b0; end
	5'd11,5'd12 : begin ALE <= 1'b0; PSEN <= MOVX; end
	default : begin ALE <= 1'b0; PSEN <= 1'b1; end
	endcase
  
  // decode for cycles
  always@(clk)
    casex(IR[7:0])
	default : cycles <= 2'b00;
	endcase
	
endmodule