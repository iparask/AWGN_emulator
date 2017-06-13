library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity count is
port(
		clk: in std_logic;
		rst: in std_logic;
		output : out signed (31 downto 0)
		);
end count;


architecture struct of count is

signal counter: signed (31 downto 0);
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

-----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity tb_myawgn is
end tb_myawgn;

architecture beh of tb_myawgn is

component myawgn is
port(   clk : in std_logic;
		rst : in std_logic;
		fre	: in std_logic;
		ready	: out std_logic;
		deigma1 : out signed (39 downto 0);
		deigma2	: out signed (39 downto 0)
		);
end component;


component count is
port(
		clk: in std_logic;
		rst: in std_logic;
		output : out signed (31 downto 0)
		);
end component;

	constant period : time := 10 ns;

	signal clk1 : std_logic:='0';
	signal rst1,ready2,freeze : std_logic;
	signal y1,y2 : signed ( 39 downto 0 );
	signal pipe : signed (31 downto 0);
	begin
		
		u1: component myawgn port map (clk1,rst1,freeze,ready2,y1,y2);
		u2: component count port map (clk1,ready2,pipe);
		clk1 <= not clk1 after period/2;
		process
		begin
			rst1    <= '0';
			freeze <='0';
			wait;
		end process ;
end beh;
