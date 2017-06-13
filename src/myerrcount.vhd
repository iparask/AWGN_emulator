library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity myerrcount is
port ( clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        err : in std_logic_vector (1 downto 0);
        count : out std_logic_vector (63 downto 0)
        );
end entity;


architecture struct of myerrcount is

signal cnt,err1,err2 : std_logic_vector (63 downto 0);

begin
err1<="000000000000000000000000000000000000000000000000000000000000000"&err(0);
err2<="000000000000000000000000000000000000000000000000000000000000000"&err(1);

pr1:process (clk) 
begin
   if clk='1' and clk'event then
      if rst='0' then 
         cnt <=(others => '0');
      elsif en='1' then
         cnt <=cnt+err1+err2;
     end if;
   end if;
end process;

count<=cnt;

end struct;
