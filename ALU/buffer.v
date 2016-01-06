module buffer(in,en,out);
  parameter WIDTH = 8;
  input [WIDTH-1:0] in;
  input en;
  output reg [WIDTH-1:0] out;
  always@(*)
    if(en) out <= in[WIDTH-1:0];
	else   out <= {WIDTH{1'bz}};
endmodule