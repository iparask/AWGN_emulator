library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;


entity myfsm2 is
port (  clk		: in std_logic;
		rst		: in std_logic;
		dready	: in std_logic;
		mtready : in std_logic;
		addrmn1	: out signed (13 downto 0);
		addrmn2	: out signed (13 downto 0);
		wenmn1	: out std_logic;
		wenmn2	: out std_logic;
		stop	: out std_logic;
		mnread	: out std_logic
);
end entity;

----------------------------------------------
-- Simata pou 8a xrisimopoii8oun os eksodoi --
-- stop: pagose tin awgn i oxi				--
-- wenmn1: write enable tis mnimis eisodou	--
-- wenmn2: write enable tis mnimis eksodou	--
-- mnread: diabase apo tin eksodo			--
-- addrmn1: i diey8isni tis mnimis 1		--
-- addrmn2: i diey8isni tis mnimis 2		--
----------------------------------------------

architecture struct of myfsm2 is

type state_type is (a0,s0,s1,s2,s3,s4,s5,s6);
signal state: state_type;

--------------------------------------------------------------
-- Counters gia tin ilopoisi ton panton						--
-- cnt1: gia tin dieu8unsi tis mnimis1 (11 bit)				--
-- cnt2: gia tin dieu8unsi tis mnimmis2 (11 bit)			--
-- cnt3: gia ta epipeda pipeline tis awgn (2 bit)			--
-- cnt4: gia ta epipeda pipeline tou kanaliou (3 bit)		--
--------------------------------------------------------------

signal cnt1, cnt2: signed (13 downto 0);
signal cnt4: std_logic_vector (2 downto 0);
signal cnt3 : std_logic_vector (3 downto 0);
signal temp: signed (13 downto 0);

begin

	pr1:process(clk)
	begin
		if clk'event and clk='1' then
			if rst='0' then
				state<=a0;
				cnt1<="00000000000000";
				cnt2<="00000000000000";
				temp<="00000000000000";
				cnt3<="0000";
				cnt4<="000";
			else
				case state is
				when a0=>
					state<=s0;
				when s0=>
					if (mtready='1' and cnt3="1010") then
						state<=s1;
					else
						if (mtready='1') then
							cnt3<=cnt3 +1;
						end if;
						state<=s0;
					end if;
				when s1=>
					if (dready='1') then
						state<=s2;
					else
						state<=s1;
					end if;
				cnt1<="00000000000000";
				cnt2<="00000000000000";
				temp<="00000000000000";
				cnt4<="000";
				when s2=>
					if (dready='0') then
						state<=s3;
						temp<=temp;
						cnt1<="00000000000000";
					else
						state<=s2;
						cnt1<=cnt1+2;
						temp<=cnt1;
					end if;
				when s3=>
					if (cnt4 = "101") then
						state<=s4;
					else
						cnt4<=cnt4+1;
						state<=s3;
					end if;
					cnt1<=cnt1+1;
				when s4=>
					if (cnt1=temp+3) then
						state<=s5;
					else
						state<=s4;
						cnt1<=cnt1+1;
					end if;
						cnt2<=cnt2+1;
				when s5=>
					if (cnt2=temp+3) then
						state<=s6;
						cnt2<="00000000000000";
					else
						state<=s5;
						cnt2<=cnt2+1;
					end if;
				when s6=>
					if (cnt2=temp+2) then
						state<=s1;
					else
						cnt2<=cnt2+2;
						state<=s6;
					end if;
				when others=>
					state<=a0;
				end case; 
			end if;   
		end if;
	end process;

	pr2:process(state)
	begin   
		case state is 
			when a0=>	stop	<='1'; -- reset
						wenmn1	<='0';
						wenmn2	<='0';
						mnread	<='0';
			when s0=>	stop	<='0'; -- arxikopoisi
						wenmn1	<='0';
						wenmn2	<='0';
						mnread	<='0';
			when s1=>	stop	<='1'; -- anamoni
						wenmn1	<='0';
						wenmn2	<='0';
						mnread	<='0';
			when s2=>	stop	<='1'; -- dedomena stin eisodo
						wenmn1	<='1';
						wenmn2	<='0';
						mnread	<='0';
			when s3=>	stop	<='0'; -- epeksergasia 4 proton dedomenon
						wenmn1	<='0';
						wenmn2	<='0';
						mnread	<='0';
			when s4=>	stop	<='0'; -- epeksergasia & apothikeusi dedomenon
						wenmn1	<='0';
						wenmn2	<='1';
						mnread	<='0';
			when s5=>	stop	<='1'; -- apothikeusi teleutaion dedomenon
						wenmn1	<='0';
						wenmn2	<='1';
						mnread	<='0';
			when s6=>	stop	<='1'; -- apostoli dedomenon
						wenmn1	<='0';
						wenmn2	<='0';
						mnread	<='1';
			when others=> stop<='0';
		end case;
	end process;

addrmn1<=cnt1;
addrmn2<=cnt2;

end struct;
