--------------
-- LLRs=2.4 --
--------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity sat24 is
port(   eisodos	: in signed (79 downto 0);
		eksodos	: out signed (5 downto 0)
		);
end entity;

architecture struct of sat24 is

signal endiameso: signed (5 downto 0);
signal a: signed (13 downto 0);
signal b1,b: signed (1 downto 0);
signal c,c1: signed (3 downto 0);
constant miden : signed ( 13 downto 0):="00000000000000";
constant assoi : signed (13 downto 0) :="11111111111111";


begin
a<=eisodos(79 downto 66);
b1<=eisodos(65 downto 64);
c1<=eisodos(63 downto 60);
endiameso<=b&c;
eksodos<=endiameso;



pr1:process(a,b1,c1)
begin
if ((a=miden and b1(1)='0') or (a=assoi and b1(1)='1')) then
	b<=b1;
	c<=c1;
elsif (a(13)='0') then
	b<="0111";
	c<=(others=>'1');
else
	b<="1000";
	c<=(others=>'0');
end if;
end process;
