library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity kanali is
port(   clk : in std_logic;
        rst : in std_logic;
        str : in std_logic;
        --iteration_serial : in std_logic;
        forsnr : in std_logic_vector(5 downto 0);
        foriter : in std_logic_vector(1 downto 0);
        conv : out std_logic;
        dout : out std_logic;
        multiout : out signed (15 downto 0)
    );
end kanali;

architecture struct of kanali is 

    component en_chan_dec is
    port(   clk : in std_logic;
            rst : in std_logic;
            start: in std_logic;
            snr : in std_logic_vector (5 downto 0);
            iter : in std_logic_vector (7 downto 0);
            dout : out std_logic;
            convergence : out std_logic;
            dec_fin : out std_logic;
            lfsr_out1 : out std_logic_vector (7 downto 0);
            lfsr_out2 : out std_logic_vector (7 downto 0);
            fram_pass: out std_logic_vector (35 downto 0);
            fr_no_conv: out std_logic_vector (12 downto 0);
            fr_err: out std_logic_vector (15 downto 0);
            error_count: out std_logic_vector (15 downto 0);
            errhappened : out std_logic_vector (63 downto 0)
    );
    end component;

    component myreg is
    generic(n: integer:=40);
    port(   clk : in std_logic;
            rst : in std_logic;
            wen : in std_logic;
            eisod : in signed (n-1 downto 0);
            deigma : out signed (n-1 downto 0)
            );
    end component;

    component mycount is
    generic(n: integer:=40);
    port(   clk : in std_logic;
            rst : in std_logic;
            en  : in std_logic;
            cnt : out std_logic_vector (n-1 downto 0)
    );
    end component;

    component mydff is
    port(   clk : in std_logic;
            rst : in std_logic;
            eisod : in std_logic;
            deigma : out std_logic
            );
    end component;

    component mydff2 is
    port(   clk : in std_logic;
            rst : in std_logic;
            wen : in std_logic;
            eisod : in std_logic;
            deigma : out std_logic
            );
    end component;

    component iterlut is
    port ( iter: in std_logic_vector (1 downto 0);
        epan: out std_logic_vector(7 downto 0)
        );
    end component;

    constant hand : signed (13 downto 0):="00001111000011";
    constant miden : std_logic_vector (31 downto 0):="00000000000000000000000000000000";
    signal fram_pass1 : std_logic_vector ( 35 downto 0);
    signal fr_no_conv1: std_logic_vector ( 12 downto 0);
    signal errhappened1: std_logic_vector( 63 downto 0);
    signal fram_pass2,fr_no_conv2,fram_pass_reged,fr_no_conv_reged,hand2,iter2,err_cnt_reged,fr_err_reged: signed (15 downto 0);
    signal lfsr1_reged,lfsr2_reged,lfsr12,lfsr22  : signed (15 downto 0);
    signal errhappened2,errhappened_reged: signed (31 downto 0);
    signal err_cnt1,fra_err: std_logic_vector (15 downto 0);
    signal xronos : std_logic_vector (5 downto 0);
    signal iter,lfsr11,lfsr21 : std_logic_vector (7 downto 0);
    signal regit,over,fin1,fin2,regit2,dout1,conv1,over2,over3 : std_logic;

begin

    over<='0' when errhappened1(63 downto 32)=miden else '1';
    over2<='0' when err_cnt_reged="0000000000000000" else '1';
    hand2<=hand & over3  & over;
    fram_pass2<=signed(fram_pass1(35 downto 20));
    errhappened2<=signed(errhappened1(31 downto 0));
    fr_no_conv2<=signed("000"&fr_no_conv1);
    regit<='1' when fram_pass1(19 downto 0)="00000000000000000000" else '0';
    regit2<=regit  and fin2;
    iter2<=signed("00000000" & iter);
    lfsr22<=signed("00000000"&lfsr21);
    lfsr12<=signed("00000000"&lfsr11);
    
    U_lut1: iterlut port map (iter=>foriter,
                epan=>iter
                );
    

    U_en1: en_chan_dec port map ( clk=>clk,
                        rst=>rst,
                        start=>str,
                        snr=>forsnr,
                        iter=>iter,
                        dout=>dout1,
                        convergence=>conv1,
                        dec_fin=>fin1,
                        fram_pass=>fram_pass1,
                        fr_no_conv=>fr_no_conv1,
                        errhappened=>errhappened1,
                        lfsr_out1=>lfsr11,
                        lfsr_out2=>lfsr21,
                        error_count=>err_cnt1,
                        fr_err=>fra_err
                        );
                    
    U_rg1: myreg generic map (n=>16) port map (clk=>clk,
                                            rst=>rst,
                                            wen=>regit2,
                                            eisod=>fram_pass2,
                                            deigma=>fram_pass_reged
                                            );
                                            
    U_rg2: myreg generic map (n=>16) port map (clk=>clk,
                                            rst=>rst,
                                            wen=>regit2,
                                            eisod=>fr_no_conv2,
                                            deigma=>fr_no_conv_reged
                                            );
                                            
    U_rg3: myreg generic map (n=>32) port map (clk=>clk,
                                            rst=>rst,
                                            wen=>regit2,
                                            eisod=>errhappened2,
                                            deigma=>errhappened_reged
                                            );
                                            
    U_rg4: myreg generic map (n=>16) port map (clk=>clk,
                                            rst=>rst,
                                            wen=>regit2,
                                            eisod=>signed(err_cnt1),
                                            deigma=>err_cnt_reged
                                            );
                                            
    U_rg5: myreg generic map (n=>16) port map (clk=>clk,
                                            rst=>rst,
                                            wen=>regit2,
                                            eisod=>signed(fra_err),
                                            deigma=>fr_err_reged
                                            );
    
    U_rg6: myreg generic map (n=>16) port map (clk=>clk,
                                            rst=>rst,
                                            wen=>regit2,
                                            eisod=>lfsr12,
                                            deigma=>lfsr1_reged
                                            );
    
    -- U_rg6: myreg generic map (n=>16) port map (clk=>clk,
                                            -- rst=>rst,
                                            -- wen=>regit2,
                                            -- eisod=>lfsr22,
                                            -- deigma=>lfsr2_reged
                                            -- );
            
    U_cn1: mycount generic map (n=>6) port map (clk=>clk,
                                                rst=>rst,
                                                en=>'1',
                                                cnt=>xronos
                                                );
                                                
    U_df1: mydff port map (clk=>clk,
                        rst=>rst,
                        eisod=>fin1,
                        deigma=>fin2
                        );
                        
    U_df2: mydff port map (clk=>clk,
                        rst=>rst,
                        eisod=>dout1,
                        deigma=>dout
                        );
                        
    U_df3: mydff port map (clk=>clk,
                        rst=>rst,
                        eisod=>conv1,
                        deigma=>conv
                        );
                        
    U_df4: mydff2 port map (clk=>clk,
                        rst=>rst,
                        wen=>over2,
                        eisod=>'1',
                        deigma=>over3
                        );
    multiout<=hand2 when xronos(5 downto 3)="000" 
    else fram_pass_reged when xronos(5 downto 3)="001" 
    else errhappened_reged(31 downto 16) when xronos(5 downto 3)="010" 
    else errhappened_reged(15 downto 0) when xronos(5 downto 3)="011"
    else fr_no_conv_reged when xronos(5 downto 3)="100" 
    else fr_err_reged when xronos(5 downto 3)="101" 
    else err_cnt_reged  when xronos(5 downto 3)="110" 
    else lfsr1_reged;

end struct;
