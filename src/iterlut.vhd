library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity iterlut is
port ( iter: in std_logic_vector (1 downto 0);
	epan: out std_logic_vector(7 downto 0)
	);
end iterlut;

architecture struct of iterlut is

signal iter1: std_logic_vector(7 downto 0);

begin

process(iter)
begin
case iter is
	when "00" => iter1<="00000000"; 
	when "01" => iter1<="00001010";
	when "10" => iter1<="00010100";
	when "11" => iter1<="00011110";
	when others => iter1 <= (others=>'0');
end case;
end process;

epan<=iter1;

end struct;
