library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity synt3 is
port( 
	  address1	: in signed (5 downto 0);
	  stoixeio1	: out signed (80-1 downto 0)
);
end synt3;


architecture struct of synt3 is

    type rom_type is array (35 downto 0) of signed (79 downto 0);
    constant stoixeia : rom_type :=("00000000000000000000110001110001011000100100001011101011001101110001101100000000",
"00000000000000000000110010100010000100000110000010100000010100111100100000000000",
"00000000000000000000110011010101000010000000010010110001001111111010100010000000",
"00000000000000000000110100001010011111010011000110000100000001101000101010000000",
"00000000000000000000110101000010101000100011101111111111100010101000111100000000",
"00000000000000000000110101111101101100011101110010000110011111100011010000000000",
"00000000000000000000110110111011111100001101110001110110100011011111110000000000",
"00000000000000000000110111111101101010101011101100101010000011010001101000000000",
"00000000000000000000111001000011001101010000100011110110010010001100011100000000",
"00000000000000000000111010001100111011110110011100101011100010000100010000000000",
"00000000000000000000111011011011010010111110101110010000110111010011001010000000",
"00000000000000000000111100101110110010111100010101100101110100000011111010000000",
"00000000000000000000111110001000000000001110101011100001100010101100101000000000",
"00000000000000000000111111100111100111010011001010101011010011011111011100000000",
"00000000000000000001000001001110011001101001010101100000010011101111010100000000",
"00000000000000000001000010111101010100100000010110000110010100011011111000000000",
"00000000000000000001000100110101011110010101111010010000101011110000111100000000",
"00000000000000000001000110111000001101100011110011010010111011110010011000000000",
"00000000000000000001001001000111001001010101100001111111000111010001011100000000",
"00000000000000000001001011100100010000110000101100010111100010110011011100000000",
"00000000000000000001001110010010000000010001111011100011111100001101011000000000",
"00000000000000000001010001010011011011110001001011011101010100100101011000000000",
"00000000000000000001010100101100011001000000110000011001000100101111011000000000",
"00000000000000000001011000100001110010100101010100100011010010000000010000000000",
"00000000000000000001011100111001111010010010111111011001111000100101111100000000",
"00000000000000000001100001111100110000010001101110111110101000100110100000000000",
"00000000000000000001100111110100001010111011011001100111001011111011101000000000",
"00000000000000000001101110101010100110110100100110011101000000100000010000000000",
"00000000000000000001110110100011110100101101100001111111100010000111011000000000",
"00000000000000000001111110110110001101001101101011010011000111111100110100000000",
"00000000000000000010000010001110000001000011101000100001011000111111111000000000",
"00000000000000000001001011000001101000110101001101101001110110000110100100000000",
"00000000000000001110100101001111010100111011101100101000111100010001100000000000",
"11111111110111000101110001111110001010000010010000001000000000000000000000000000",
"11111111111110101001110011001111011010111110001110000000000000000000000000000000",
"11111111111010000101000100100110111010010111100011011000000000000000000000000000");

begin

stoixeio1<=stoixeia(to_integer((unsigned(address1))));
end struct;
