module DATARAM(clk,reset,CS,RW,Bb,addr,position,din,dout,bin,bout);
  
  input clk,reset;
  input CS;  // Chip Select, L valid
  input RW;  // Read/Write,  H Read, L Write
  input Bb;  // Byte/bit,    H Byte, L bit
  input [7:0] addr;
  input [7:0] position;      // bit position, H valid
  input [7:0] din;
  input bin;
  
  output reg [7:0] dout;
  output reg bout;
  
  wire RnCS,BitCS,ByteCS;    // where the address belongs to
  assign RnCS = ~(addr[7:5] == 3'b000)|CS;
  assign BitCS = ~(addr[7:4] == 3'b0010)|CS;
  assign ByteCS = ~(addr[7]|addr[6]|(addr[5]&addr[4]))|CS;

  wire [7:0] RnCSbits,BitCSbits;   // CS signals for Rn area and bits area
  assign RnCSbits = ~({8{Bb}}|position[7:0])|{8{RnCS}};
  assign BitCSbits = ~({8{Bb}}|position[7:0])|{8{BitCS}};
    
  // input for Rn area and bits area
  wire [7:0] bits;
  assign bits = ({8{Bb}}&din[7:0])|({8{~Bb&bin}});
  
  // Bytes Area
  wire [7:0] Byte;    // output of byte area
  Byte_Mem #(.ADDRWIDTH(8)) ByteReg(.clk(clk),.CS(ByteCS),.RW(RW),.addr(addr[7:0]),.din(din[7:0]),.dout(Byte));
  // Bits Area
  wire [7:0] Bits;    // output of bits area
  Bit_Mem #(.ADDRWIDTH(4)) Bits7(.clk(clk),.CS(BitCSbits[7]),.RW(RW),.addr(addr[3:0]),.din(bits[7]),.dout(Bits[7]));
  Bit_Mem #(.ADDRWIDTH(4)) Bits6(.clk(clk),.CS(BitCSbits[6]),.RW(RW),.addr(addr[3:0]),.din(bits[6]),.dout(Bits[6]));
  Bit_Mem #(.ADDRWIDTH(4)) Bits5(.clk(clk),.CS(BitCSbits[5]),.RW(RW),.addr(addr[3:0]),.din(bits[5]),.dout(Bits[5]));
  Bit_Mem #(.ADDRWIDTH(4)) Bits4(.clk(clk),.CS(BitCSbits[4]),.RW(RW),.addr(addr[3:0]),.din(bits[4]),.dout(Bits[4]));
  Bit_Mem #(.ADDRWIDTH(4)) Bits3(.clk(clk),.CS(BitCSbits[3]),.RW(RW),.addr(addr[3:0]),.din(bits[3]),.dout(Bits[3]));
  Bit_Mem #(.ADDRWIDTH(4)) Bits2(.clk(clk),.CS(BitCSbits[2]),.RW(RW),.addr(addr[3:0]),.din(bits[2]),.dout(Bits[2]));
  Bit_Mem #(.ADDRWIDTH(4)) Bits1(.clk(clk),.CS(BitCSbits[1]),.RW(RW),.addr(addr[3:0]),.din(bits[1]),.dout(Bits[1]));
  Bit_Mem #(.ADDRWIDTH(4)) Bits0(.clk(clk),.CS(BitCSbits[0]),.RW(RW),.addr(addr[3:0]),.din(bits[0]),.dout(Bits[0])); 
  // Working Registers Group
  wire [7:0] Rnbits;  // output of Rn area
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup7(.clk(clk),.CS(RnCSbits[7]),.RW(RW),.addr(addr[4:0]),.din(bits[7]),.dout(Rnbits[7]));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup6(.clk(clk),.CS(RnCSbits[6]),.RW(RW),.addr(addr[4:0]),.din(bits[6]),.dout(Rnbits[6]));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup5(.clk(clk),.CS(RnCSbits[5]),.RW(RW),.addr(addr[4:0]),.din(bits[5]),.dout(Rnbits[5]));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup4(.clk(clk),.CS(RnCSbits[4]),.RW(RW),.addr(addr[4:0]),.din(bits[4]),.dout(Rnbits[4]));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup3(.clk(clk),.CS(RnCSbits[3]),.RW(RW),.addr(addr[4:0]),.din(bits[3]),.dout(Rnbits[3]));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup2(.clk(clk),.CS(RnCSbits[2]),.RW(RW),.addr(addr[4:0]),.din(bits[2]),.dout(Rnbits[2]));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup1(.clk(clk),.CS(RnCSbits[1]),.RW(RW),.addr(addr[4:0]),.din(bits[1]),.dout(Rnbits[1]));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup0(.clk(clk),.CS(RnCSbits[0]),.RW(RW),.addr(addr[4:0]),.din(bits[0]),.dout(Rnbits[0]));

  // output
  wire Rnbit,Bit;  // Rnbit and Bit is one bit of Rnbits and Bits respectively
  assign Rnbit = |(position[7:0]&Rnbits[7:0]);
  assign Bit   = |(position[7:0]&Bits[7:0]);
  always@(Bb or RW or ByteCS or BitCS or RnCS or Rnbits or Rnbit or Bits or Bit or Byte)
    case({Bb,ByteCS,BitCS,RnCS,RW})
	  5'bxxxx0 : begin dout <= 8'hzz;       bout <= 1'bz;         end
	  5'b11101 : begin dout <= Rnbits[7:0]; bout <= 1'bz;         end
	  5'b11011 : begin dout <= Bits[7:0];   bout <= 1'bz;         end
	  5'b10111 : begin dout <= Byte[7:0];   bout <= 1'bz;         end
	  5'b01101 : begin bout <= Rnbit;       dout <= 8'bzzzzzzzz;  end
	  5'b01011 : begin bout <= Bit;         dout <= 8'bzzzzzzzz;  end
	  default  : begin bout <= 1'bz;        dout <= 8'bzzzzzzzz;  end
	endcase
endmodule
/*   // Copy of Ri
  SFR R31(.clk(clk),.reset(1'b0),.en(Ri_en[7]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R31_out[7:0]));
  SFR R30(.clk(clk),.reset(1'b0),.en(Ri_en[6]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R30_out[7:0]));
  SFR R21(.clk(clk),.reset(1'b0),.en(Ri_en[5]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R21_out[7:0]));
  SFR R20(.clk(clk),.reset(1'b0),.en(Ri_en[4]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R20_out[7:0]));
  SFR R11(.clk(clk),.reset(1'b0),.en(Ri_en[3]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R11_out[7:0]));
  SFR R10(.clk(clk),.reset(1'b0),.en(Ri_en[2]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R10_out[7:0]));
  SFR R01(.clk(clk),.reset(1'b0),.en(Ri_en[1]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R01_out[7:0]));
  SFR R00(.clk(clk),.reset(1'b0),.en(Ri_en[0]),.oe(1'b0),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.bin(bin),.dout(),.bout(),.cout(R00_out[7:0]));
 */
/*   wire [3:0] group_decode;   // decode from addr[4:3] to group select signals
  assign group_decode = {(addr[4:3]==2'b11),
                         (addr[4:3]==2'b10),
                         (addr[4:3]==2'b01),
                         (addr[4:3]==2'b00)};
  wire [1:0] Ri_decode;      // decode from addr[2:0] to Ri select signals
  assign Ri_decode = {(addr[2:0]==3'b001),
                      (addr[2:0]==3'b000)};
					  
  wire [7:0] Ri_en;          // enter for Ri copy
  assign Ri_en = {{Ri_decode[1],Ri_decode[0]}&{2{group_decode[3]}},
                  {Ri_decode[1],Ri_decode[0]}&{2{group_decode[2]}},
                  {Ri_decode[1],Ri_decode[0]}&{2{group_decode[1]}},
                  {Ri_decode[1],Ri_decode[0]}&{2{group_decode[0]}}}&{8{~RnCS}};
 */
/* wire Rnbit;
wire [7:0] RnByte;  // output of Rn area
SFR R7Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R6Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R5Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R4Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R3Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R2Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R1Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R0Group3(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R7Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R6Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R5Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R4Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R3Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R2Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R1Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R0Group2(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R7Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R6Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R5Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R4Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R3Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R2Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R1Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R0Group1(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R7Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R6Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R5Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R4Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R3Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R2Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R1Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout());
SFR R0Group0(.clk(clk),.reset(reset),.en(),.oe(),.Bb(Bb),.position(position[7:0]),.din(din[7:0]),.dout(RnByte[7:0]),.bin(bin),.bout(Rnbit),.cout()); */