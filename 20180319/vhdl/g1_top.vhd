-- G1 wrapper

library ieee;
use ieee.std_logic_1164.all;

entity g1_top is
    generic(
    freq: positive -- Clock frequency (MHz)
);
port(
        clk:      in    std_ulogic; -- 125 MHz clock
        srst:     in    std_ulogic; -- Active high synchronous reset (push-button 0)
        a:        in    std_ulogic; -- Start signal (push-button 1)
        s:        out   std_ulogic  -- G1 output (LED 0)
    );
end entity g1_top;

architecture arc of g1_top is

    signal srstn: std_ulogic;
    signal ce:    std_ulogic;

    constant cntmax: natural := freq * 100000;
--constant cntmax: natural := freq * 12500000; --if clock was really 125Mhz

begin

    u0: entity work.g1(arc)
    port map(
                clk   => clk,
                srstn => srstn,
                ce    => ce,
                a     => a,
                s     => s
            );

    srstn <= not srst;

    process(clk)
        variable cnt: natural range 0 to cntmax;
    begin
        if rising_edge(clk) then
            ce <= '0';
            --if srstn = '0' then
            --cnt := 0;
            if cnt = cntmax then
                cnt := 0;
                ce <= '1';
            else
                cnt := cnt + 1;
            end if;
        --end if;
        end if;
    end process;

end architecture arc;
