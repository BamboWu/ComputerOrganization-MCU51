module ClkU(clk,reset,EA,IR,Phase,ALE,PSEN,cycles);

  input clk,reset,EA;
  input [7:0] IR;
  
  output reg Phase,ALE,PSEN;
  output reg [1:0] cycles;
  
  wire clk_n;
  assign clk_n = ~clk;
  always@(posedge clk_n)
    Phase <= reset ? 1'b0 : ~Phase;

  wire MOVX;
  assign MOVX = (IR[7:5]==3'b111)&(IR[3:2]==2'b00)&(IR[1]|~IR[0]); 

  reg [4:0] num = 8;
  always@(posedge clk_n)
    casex({reset,MOVX,num[4:0]})
	7'b1xxxxxx : num <= 8;
	7'b0101100 : num <= 13;
	7'b0001100 : num <= 1;
	7'b0x11000 : num <= 1;
	default : num <= num+1;
	endcase
  
  always@(num[4:0])
    casex(num[4:0])
	5'd2,5'd3,5'd8,5'd9,5'd20,5'd21 : begin ALE <= 1'b1; PSEN <= 1'b1; end
	5'd1,5'd5,5'd6,5'd7,5'd23,5'd24 : begin ALE <= 1'b0; PSEN <= EA; end
	5'd11,5'd12 : begin ALE <= 1'b0; PSEN <= EA|MOVX; end
	default : begin ALE <= 1'b0; PSEN <= 1'b1; end
	endcase

/*	
  reg [3:0] num=4;
  always @(posedge Phase or posedge reset)
	    begin
		    casex({reset,num})
			5'b1xxxx :          begin num <= 4; ALE <= 1'b1; end
			5'b00100 :          begin num <= 5; ALE <= 1'b0; end
			5'b00101 :          begin num <= 6; ALE <= 1'b0; end
			5'b00110 : if(MOVX) begin num <= 7; ALE <= 1'b0; end
                	   else     begin num <= 1; ALE <= 1'b1; end
			5'b00111 :          begin num <= 8; ALE <= 1'b0; end
			5'b01000 :          begin num <= 9; ALE <= 1'b0; end
			5'b01001 :          begin num <= 10; ALE <= 1'b1; end
			5'b01010 :          begin num <= 11; ALE <= 1'b0; end
			5'b01011 :          begin num <= 12; ALE <= 1'b0; end
			5'b01100 :          begin num <= 1; ALE <= 1'b1; end
			5'b00001 :          begin num <= 2; ALE <= 1'b0; end
			5'b00010 :          begin num <= 3; ALE <= 1'b0; end
			5'b00011 :          begin num <= 4; ALE <= 1'b1; end
			default  :          begin num <= 4; ALE <= 1'b1; end
			endcase
		end
  
  reg [1:0] delay;
  reg PSEN_tmp;
  always @(posedge clk_n or posedge reset)
       begin
	       casex({reset,ALE,delay})
		   3'b1xxx :          begin PSEN_tmp <= 1'b1; delay <= 2'b11; end
		   3'b0111 :          begin PSEN_tmp <= 1'b1; delay <= 2'b11; end
		   3'b0011 : if(MOVX) begin PSEN_tmp <= 1'b1; delay <= 2'b10; end
		             else     begin PSEN_tmp <= 1'b1; delay <= 2'b01; end
		   3'b0010 :          begin PSEN_tmp <= 1'b1; delay <= 2'b10; end
		   3'b0110 :          begin PSEN_tmp <= 1'b1; delay <= 2'b00; end
		   3'b0100 :          begin PSEN_tmp <= 1'b1; delay <= 2'b00; end
		   3'b0000 :          begin PSEN_tmp <= 1'b1; delay <= 2'b01; end
		   3'b0001 :          begin PSEN_tmp <= 1'b0; delay <= 2'b01; end
		   3'b0101 :          begin PSEN_tmp <= 1'b1; delay <= 2'b11; end
		   default :          begin PSEN_tmp <= 1'b1; delay <= 2'b11; end
		   endcase
	   end
  
  always @(PSEN_tmp or EA)
      PSEN <= PSEN_tmp | EA;
  */
  
  // decode for cycles
  always@(clk)
    casex(IR[7:0])
	
	default : cycles <= 2'b00;
	endcase
	
endmodule