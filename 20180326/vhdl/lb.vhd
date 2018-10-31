-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity lb is
    generic(
    freq:    positive range 1 to 1000	:= 100;
    timeout: positive range 1 to 1000000	:= 500000
);
port(
        clk:      in  std_ulogic;
        areset:   in  std_ulogic;
        led:      out std_ulogic_vector(3 downto 0)
    );
end entity lb;


architecture arc of lb is


    signal s_sresetn_vector:  std_ulogic_vector(1 downto 0);
    signal s_sresetn:  std_ulogic;
    signal s_pulse: std_ulogic;
    signal s_clk: std_ulogic;
    signal s_shift: std_ulogic;
    signal s_di: std_ulogic;
    signal s_do: std_ulogic_vector(3 downto 0);
    signal s_not_areset : std_ulogic;


begin

    s_clk <= clk;
    s_not_areset <= not areset;

    s_shift <= s_pulse;

    s_sresetn <= s_sresetn_vector(0);
    led <= s_do;

    sr_0: entity work.sr(arc)
    generic map(
                   N => 2
               )
    port map(
                clk     => s_clk,
                sresetn  => '1',
                shift => '1',
                di => s_not_areset,
                do => s_sresetn_vector
            );

    sr_1: entity work.sr(arc)
    generic map(
                   N => 4
               )
    port map(
                clk => s_clk,
                sresetn => s_sresetn,
                shift => s_shift,
                di => s_di,
                do => s_do
            );
    timer_0: entity work.timer(arc)
    generic map(
                   freq => freq,
                   timeout => timeout
               )
    port map(
                clk => s_clk,
                sresetn => s_sresetn,
                pulse => s_pulse
            );


    process (clk)
    begin
        if rising_edge(clk) then
            if s_do = "0000" then
                s_di <= '1';  
            else
                s_di <= s_do(0);  
        end if;

        end if;

    end process;
end arc;
