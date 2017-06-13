library ieee;
library Encoder_2K_mqam;
library Decoder_2K_mqam;
use Encoder_2K_mqam.ldpcenc2k_constants.all;
use Decoder_2K_mqam.decoder_constants.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;


entity en_chan_dec is
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
end en_chan_dec;

architecture struct of en_chan_dec is 

    component ldpcenc2k is
      port(
        rst_n       : in     std_logic;
        srst        : in     std_logic;
        clk         : in     std_logic;
        din         : in     std_logic_vector(7 downto 0);
        din_val     : in     std_logic;
        bin_str     : in     std_logic;
        bin_end     : in     std_logic;
        stall_in    : in     std_logic;
        code_rate   : in     std_logic_vector(7  downto 0);
        modulation  : in     std_logic_vector(2  downto 0);
        parity_size : in     std_logic_vector(12 downto 0);
        block_size  : in     std_logic_vector(12 downto 0);
        cmode       : in     std_logic_vector(2  downto 0);
        cout_end    : out    std_logic;
        cout_str    : out    std_logic;
        dout        : out    std_logic_vector(7 downto 0);
        dout_val    : out    std_logic;
        stall_out   : out    std_logic
    );
    end  component;

    component mysystem is
    port(   clk         : in std_logic;
        rst     : in std_logic;
        dinready: in std_logic;
        datain  : in signed (1 downto 0);
        sigma1  : in signed (39 downto 0);
        sigma2  : in signed (39 downto 0);
        doutready: out std_logic;
        dataout11: out std_logic_vector (5 downto 0);
        dataout21: out std_logic_vector (5 downto 0)
            );
    end component;

    component ldpcdec2kp1 is
      generic(
        n :  integer := 6);
      port(
        rst_n       : in     std_logic;
        srst        : in     std_logic;
        clk         : in     std_logic;
        dllr0       : in     std_logic_vector(n-1 downto 0);
        dllr1       : in     std_logic_vector(n-1 downto 0);
        dllr2       : in     std_logic_vector(n-1 downto 0);
        dllr3       : in     std_logic_vector(n-1 downto 0);
        dllr4       : in     std_logic_vector(n-1 downto 0);
        dllr5       : in     std_logic_vector(n-1 downto 0);
        dllr6       : in     std_logic_vector(n-1 downto 0);
        dllr7       : in     std_logic_vector(n-1 downto 0);
        din_val     : in     std_logic;
        cin_str     : in     std_logic;
        cin_end     : in     std_logic;
        n_iter      : in     std_logic_vector(7 downto 0);
        dout        : out    std_logic_vector(7 downto 0);
        dout_val    : out    std_logic;
        idout_str   : out    std_logic;
        idout_end   : out    std_logic;
        convergence : out    std_logic;
        err_cnt     : out    std_logic_vector(15 downto 0);
        cmode       : in     std_logic_vector(2 downto 0);
        block_size  : in     std_logic_vector(12 downto 0);
        code_rate   : in     std_logic_vector(7 downto 0);
        modulation  : in     std_logic_vector(2 downto 0);
        iter_conv   : out    std_logic_vector(7 downto 0));

    end component;

    component myerrcount is
    port ( clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            err : in std_logic_vector (1 downto 0);
            count : out std_logic_vector (63 downto 0)
            );
    end component;

    component mylfsr2 is
    port ( starting: in std_logic_vector (7 downto 0);
        lfsr2_out: out std_logic_vector(7 downto 0);
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic);
    end component;

    component myreg2 is
    generic(n: integer:=40);
    port(   clk : in std_logic;
            rst : in std_logic;
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

    component snrlut is
    port ( SNR: in std_logic_vector (5 downto 0);
        sigma: out signed(39 downto 0);
        sigma2: out signed(39 downto 0));
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

    constant miden : signed (63 downto 0):=(others=>'0');
    signal errhappened1: std_logic_vector (63 downto 0);
    signal olderr,err_ex : signed (63 downto 0);
    signal readyen,readyout,ready_data,restart,restart2,false_f,fra_en,conv,starting,diafor1,diafor,dec_fin1: std_logic;
    signal dataforch,dataforchreged: signed (1 downto 0);
    signal s1,s2 : signed (39 downto 0);
    signal data1,data2,din1,data3: std_logic_vector (7 downto 0);
    signal dfordec1,dfordec2: std_logic_vector (5 downto 0);
    signal sfalma : std_logic_vector (1 downto 0);
    signal rst2: std_logic;

begin

    rst2<=not rst;
    dataforch<=signed(data1(1 downto 0));
    ready_data<=start or restart;
    sfalma<= data3(1 downto 0) xor data2(1 downto 0);
    false_f<=(not conv) and restart2;
    err_ex<=signed(errhappened1) xor olderr;
    diafor1<='0' when err_ex = miden else '1';
    diafor<=diafor1 and dec_fin1;

    U_lt1: snrlut port map (SNR=>snr,
                        sigma=>s1,
                        sigma2=>s2
                        );
                        
    U_cn1: mycount generic map (n=>36) port map (clk=>clk,
                                                rst=>rst,
                                                en=>fra_en,
                                                cnt=>fram_pass
                                                ); -- frames passed
                                                
    U_df1: mydff port map (clk=>clk,
                        rst=>rst,
                        eisod=>starting,
                        deigma=>restart2
                        );
                        
    U_cn2: mycount generic map (n=>13) port map (clk=>clk,
                                                rst=>rst,
                                                en=>false_f,
                                                cnt=>fr_no_conv
                                                ); -- frames without convergence
                                                
    U_re1: myreg2 generic map (n=>2) port map (clk=>clk,
                                            rst=>rst,
                                            eisod=>dataforch,
                                            deigma=>dataforchreged
                                            );
                                            
    U_lf1: mylfsr2 port map (starting=>"00000001",
                            lfsr2_out=>din1,
                            clk=>clk,
                            rst=>rst,
                            en=>ready_data
                            );    --lfsr ton 8bit gia eisodo ston encoder;
                            
    U_lf2: mylfsr2 port map (starting=>"00000001",
                            lfsr2_out=>data3,
                            clk=>clk,
                            rst=>rst,
                            en=>restart
                            ); --lfsr ton 8bit gia sigkrisi me tin eksodo tou decoder
                            
    U_ch1: mysystem port map (clk=>clk,
                            rst=>rst,
                            dinready=>readyen,
                            datain=>dataforchreged,
                            sigma1=>s1,
                            sigma2=>s2,
                            doutready=>readyout,
                            dataout11=>dfordec1,
                            dataout21=>dfordec2
                            );
    
    U_er1: myerrcount port map (clk=>clk,
                            rst=>rst,
                            en=>restart,
                            err=>sfalma,
                            count=>errhappened1
                            );
                            
    U_rgerr: myreg generic map (n=>64) port map ( clk=>clk,
                                                    rst=>rst,
                                                    wen=>diafor,
                                                    eisod=>signed(errhappened1),
                                                    deigma=>olderr
                                                    );
    
    U_cn3: mycount generic map (n=>16) port map (clk=>clk,
                                                rst=>rst,
                                                en=>diafor,
                                                cnt=>fr_err
                                                );
                            
    U_en1: ldpcenc2k port map ( rst_n=>'1',
                                        srst=>rst2,
                                        clk=>clk,
                                        din=>din1,
                                        din_val=>ready_data,
                                        bin_str=>'0',
                                        bin_end=>'0',
                                        stall_in=>'0',
                                        dout=>data1,
                                        dout_val=>readyen,
                                        cmode=>"000",
                                        block_size=>"0010111101000",
                                        parity_size=>"0000000000000",
                                        code_rate=>"00000000",
                                        modulation=>"000",
                                        cout_str=>fra_en
                                                        );
                                                        
    U_de1: ldpcdec2kp1 generic map (6) port map (   rst_n=>rst2,
                                                            srst=>'0',
                                                            clk=>clk,
                                                            dllr0=>dfordec1,
                                                            dllr1=>dfordec2,
                                                            dllr2=>"000000",
                                                            dllr3=>"000000",
                                                            dllr4=>"000000",
                                                            dllr5=>"000000",
                                                            dllr6=>"000000",
                                                            dllr7=>"000000",
                                                            din_val=>readyout,
                                                            cin_str=>'0',
                                                            cin_end=>'0',
                                                            n_iter=>iter,
                                                            dout=>data2,
                                                            dout_val=>restart,
                                                            convergence=>conv,
                                                            cmode=>"000",
                                                            block_size=>"0010111101000",
                                                            code_rate=>"00000000",
                                                            modulation=>"000",
                                                            idout_str=>starting,
                                                            err_cnt=>error_count,
                                                            idout_end=>dec_fin1
                                                            );

    convergence<=conv;
    dout<=restart;
    lfsr_out1<=din1;
    lfsr_out2<=data3;
    errhappened<=errhappened1;
    dec_fin<=dec_fin1;
                                                        
end struct;
