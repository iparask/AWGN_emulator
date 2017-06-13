library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity count is
port(
		clk: in std_logic;
		rst: in std_logic;
		output : out signed (15 downto 0)
		);
end count;


architecture struct of count is

signal counter: signed (15 downto 0);
begin

process (clk) 
begin
   if clk='1' and clk'event then
      if rst='0' then 
         counter <= (others => '0');
      else
         counter <= counter + 1;
      end if;
   end if;
end process; 

output<=counter;

end struct;

---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity tb_logcos is
end tb_logcos;

architecture beh of tb_logcos is

component count is
port(
		clk: in std_logic;
		rst: in std_logic;
		output : out signed (15 downto 0)
		);
end component;

component mycos is
port(	clk		: in std_logic;
		rst		: in std_logic;
		wen		: in std_logic;
		eisodos	: in signed (31 downto 0);
		eksodos	: out signed (39 downto 0)
		);
end component;

component mylog2 is
port(	clk		: in std_logic;
		rst		: in std_logic;
		wen		: in std_logic;
		eisodos	: in signed (31 downto 0);
		eksodos	: out signed (39 downto 0)
	);
end component;

	constant period : time := 10 ns;

	signal clk1 : std_logic:='0';
	signal rst1,ready2,freeze : std_logic;
	signal x1,x2 : signed (15 downto 0);
	signal y1,y2 : signed ( 39 downto 0 );
	signal x11,x21 : signed (31 downto 0);
	begin
		
		x11<=x1&"0000000000000000";
		u1: component mylog2 port map (clk1,rst1,freeze,x11,y1);
		u2: component mycos port map (clk1,rst1,freeze,x11,y2);
		
		u3: component count port map (clk1,rst1,x1);
		
		clk1 <= not clk1 after period/2;
		process
		begin
			rst1    <= '0';
			freeze <='1';
			wait for 200 ns;
			rst1<='1';
			wait for 2000 ns;
			wait;
		end process ;
end beh;
