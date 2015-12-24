module DATARAM(clk,CS,RW,Bb,addr,position,din,dout,bin,bout);
  
  input clk;
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
  wire [7:0] Byte;
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
  wire Rnbit,Bit;
  assign Rnbit = |(position[7:0]&Rnbits[7:0]);
  assign Bit   = |(position[7:0]&Bits[7:0]);
  always@(Bb,ByteCS,BitCS,RnCS,Rnbits,Rnbit,Bits,Bit)
    case({Bb,ByteCS,BitCS,RnCS})
	  4'b1110 : begin dout <= Rnbits[7:0]; bout <= 1'bz;   end
	  4'b1101 : begin dout <= Bits[7:0]; bout <= 1'bz;     end
	  4'b1011 : begin dout <= Byte[7:0]; bout <= 1'bz;     end
	  4'b0110 : begin bout <= Rnbit; dout <= 8'bzzzzzzzz;  end
	  4'b0101 : begin bout <= Bit; dout <= 8'bzzzzzzzz;    end
	  default : begin bout <= 1'bz; dout <= 8'bzzzzzzzz;   end
	endcase
endmodule