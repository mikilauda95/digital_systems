library ieee;
use ieee.std_logic_1164.all;

entity dht11_ctrl is
    generic(
    freq: positive range 1 to 1000;
    init: natural;
    tmax: natural;
    cmax: natural
);
port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        data_in:  in  std_ulogic;
        start:    in  std_ulogic;
        data_drv: out std_ulogic;
        busy:     out std_ulogic;
        err:      out std_ulogic;
        do:       out std_ulogic_vector(39 downto 0)
    );
end entity dht11_ctrl;

architecture rtl of dht11_ctrl is

    signal cz, inc, tz,  di, re, fe : std_ulogic;
    signal c: natural range 0 to cmax;
    signal t: natural range 0 to tmax;

begin

    counter_0 : entity work.counter(rtl)
    generic map (
                    cmax => cmax
                )
    port map (
                 clk => clk,
                 sresetn => sresetn,
                 cz => cz,
                 inc => inc,
                 c => c
             );


    sm2_0 : entity work.sm2(rtl)
    generic map (
                    init => init,
                    tmax => tmax ,
                    cmax => 42
                )
    port map (
                 clk => clk,
                 sresetn => sresetn,
                 start => start,
                 busy => busy,
                 err => err,
                 data_drv => data_drv,
                 tz => tz,
                 t => t,
                 cz => cz,
                 c => c,
                 inc => inc,
                 di => di,
                 re => re,
                 fe => fe
             );


    sr2_0 : entity work.sr2(rtl)
    generic map (
                    n => 40 )
    port map (
                 clk => clk,
                 sresetn => sresetn,
                 shift => inc,
                 di => di,
                 do => do
             );


    edge_0 : entity work.edge(rtl)
    port map (
                 clk => clk,
                 sresetn => sresetn,
                 data_in => data_in,
                 re => re,
                 fe => fe
             );


    timer2_0 : entity work.timer2(rtl)
    generic map (
    freq => freq,
    tmax => tmax
)
port map (
        clk => clk,
        sresetn => sresetn,
        tz => tz,
        t => t
    );



end architecture rtl;

