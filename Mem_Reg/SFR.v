module SFR(clk,reset,en,oe,Bb,position,din,bin,dout,bout,cout); 
    parameter WIDTH = 8;
	parameter INITV = {WIDTH{1'b0}};   // initial value after reset
	
	input clk,reset;
	input en;                          // enter a value
	input oe;                          // output enable
	input Bb;                          // Byte/bit,  H Byte, L bit
	input [WIDTH-1:0] din;             // data input 
	input [WIDTH-1:0] position;        // position of bit
	input bin;                         // bit input
	
	output reg [WIDTH-1:0] cout;       // control output
	output reg [WIDTH-1:0] dout;       // data output
	output reg bout;                   // bit output
	
	//wire clk_n;
	//assign clk_n = ~clk;
	
	wire [WIDTH-1:0] bits;
	assign bits = (cout[WIDTH-1:0]&(~position[WIDTH-1:0]))|({WIDTH{bin}}&position[WIDTH-1:0]);
	
	// modify
	always @(posedge clk)
        casex({reset,en,Bb})
		    3'b1xx : cout <= INITV;
			3'b011 : cout <= din[WIDTH-1:0];
			3'b010 : cout <= bits[WIDTH-1:0];
			default: ;
		endcase
	// output
	always @(posedge clk)
	    casex({en,oe,Bb})
		    3'b1xx : begin dout <= {WIDTH{1'bz}}; bout <= 1'bz;   end
			3'b00x : begin dout <= {WIDTH{1'bz}}; bout <= 1'bz;   end
			3'b011 : begin dout <= cout[WIDTH-1:0]; bout <= 1'bz; end
			3'b010 : begin dout <= {WIDTH{1'bz}}; bout <= |(position[WIDTH-1:0]&cout[WIDTH-1:0]);  end
			default: begin dout <= {WIDTH{1'bz}}; bout <= 1'bz;   end
		endcase
endmodule