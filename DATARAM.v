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
  assign RnCS = ~(addr[7:5] == 3'b000);
  assign BitCS = ~(addr[7:5] == 3'b001);
  assign ByteCS = ~(addr[7] | addr[6]);

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
  wire Bit7,Bit6,Bit5,Bit4,Bit3,Bit2,Bit1,Bit0,Bit;
  Bit_Mem #(.ADDRWIDTH(4)) Bits7(.clk(clk),.CS(BitCSbits[7]),.RW(RW),.addr(addr[4:0]),.din(bits[7]),.dout(Bit7));
  Bit_Mem #(.ADDRWIDTH(4)) Bits6(.clk(clk),.CS(BitCSbits[6]),.RW(RW),.addr(addr[4:0]),.din(bits[6]),.dout(Bit6));
  Bit_Mem #(.ADDRWIDTH(4)) Bits5(.clk(clk),.CS(BitCSbits[5]),.RW(RW),.addr(addr[4:0]),.din(bits[5]),.dout(Bit5));
  Bit_Mem #(.ADDRWIDTH(4)) Bits4(.clk(clk),.CS(BitCSbits[4]),.RW(RW),.addr(addr[4:0]),.din(bits[4]),.dout(Bit4));
  Bit_Mem #(.ADDRWIDTH(4)) Bits3(.clk(clk),.CS(BitCSbits[3]),.RW(RW),.addr(addr[4:0]),.din(bits[3]),.dout(Bit3));
  Bit_Mem #(.ADDRWIDTH(4)) Bits2(.clk(clk),.CS(BitCSbits[2]),.RW(RW),.addr(addr[4:0]),.din(bits[2]),.dout(Bit2));
  Bit_Mem #(.ADDRWIDTH(4)) Bits1(.clk(clk),.CS(BitCSbits[1]),.RW(RW),.addr(addr[4:0]),.din(bits[1]),.dout(Bit1));
  Bit_Mem #(.ADDRWIDTH(4)) Bits0(.clk(clk),.CS(BitCSbits[0]),.RW(RW),.addr(addr[4:0]),.din(bits[0]),.dout(Bit0)); 
  // Working Registers Group
  wire Rnbit7,Rnbit6,Rnbit5,Rnbit4,Rnbit3,Rnbit2,Rnbit1,Rnbit0,Rnbit;
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup7(.clk(clk),.CS(RnCSbits[7]),.RW(RW),.addr(addr[4:0]),.din(bits[7]),.dout(Rnbit7));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup6(.clk(clk),.CS(RnCSbits[6]),.RW(RW),.addr(addr[4:0]),.din(bits[6]),.dout(Rnbit6));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup5(.clk(clk),.CS(RnCSbits[5]),.RW(RW),.addr(addr[4:0]),.din(bits[5]),.dout(Rnbit5));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup4(.clk(clk),.CS(RnCSbits[4]),.RW(RW),.addr(addr[4:0]),.din(bits[4]),.dout(Rnbit4));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup3(.clk(clk),.CS(RnCSbits[3]),.RW(RW),.addr(addr[4:0]),.din(bits[3]),.dout(Rnbit3));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup2(.clk(clk),.CS(RnCSbits[2]),.RW(RW),.addr(addr[4:0]),.din(bits[2]),.dout(Rnbit2));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup1(.clk(clk),.CS(RnCSbits[1]),.RW(RW),.addr(addr[4:0]),.din(bits[1]),.dout(Rnbit1));
  Bit_Mem #(.ADDRWIDTH(5)) RnGroup0(.clk(clk),.CS(RnCSbits[0]),.RW(RW),.addr(addr[4:0]),.din(bits[0]),.dout(Rnbit0));
  
  // output
  assign Rnbit = |(position[7:0]&{Rnbit7,Rnbit6,Rnbit5,Rnbit4,Rnbit3,Rnbit2,Rnbit1,Rnbit0});
  assign Bit   = |(position[7:0]&{Bit7,Bit6,Bit5,Bit4,Bit3,Bit2,Bit1,Bit0});
  always@(*)
    case({Bb,ByteCS,BitCS,RnCS})
	  4'b1110 : begin dout = {Rnbit7,Rnbit6,Rnbit5,Rnbit4,Rnbit3,Rnbit2,Rnbit1,Rnbit0}; bout = 1'bz;  end
	  4'b1101 : begin dout = {Bit7,Bit6,Bit5,Bit4,Bit3,Bit2,Bit1,Bit0}; bout = 1'bz;                  end
	  4'b1011 : begin dout = Byte[7:0]; bout = 1'bz;     end
	  4'b0110 : begin bout = Rnbit; dout = 8'bzzzzzzzz;  end
	  4'b0101 : begin bout = Bit; dout = 8'bzzzzzzzz;    end
	  default : begin bout = 1'bz; dout = 8'bzzzzzzzz;   end
	endcase
endmodule