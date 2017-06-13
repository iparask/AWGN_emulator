library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity s_in_par_out_reg is
generic (n: integer:=16);
port(    clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        s_in : in std_logic;
        par_out : out std_logic_vector (n-1 downto 0)
    );
end s_in_par_out_reg;

architecture struct of s_in_par_out_reg is

signal temp: std_logic_vector ( n-1 downto 0);

begin

pr1:process(clk)
begin
   if clk='1' and clk'event then
      if rst='0' then 
         temp <=(others => '0');
      elsif (en='1') then
     temp(n-1 downto 1)<=temp(n-2 downto 0);
         temp(0)<=s_in;
      end if;
   end if;
end process;

par_out<=temp;

end struct;
