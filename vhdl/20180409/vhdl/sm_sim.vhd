use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sm_sim is
end entity sm_sim;

architecture sim of sm_sim is

  signal clk:      std_ulogic;
  signal sresetn:  std_ulogic;
  signal go:       std_ulogic;
  signal stp:      std_ulogic;
  signal spin:     std_ulogic;
  signal up:       std_ulogic;

begin

  dut: entity work.sm(rtl)
    port map(
      clk     => clk,
      sresetn => sresetn,
      go      => go,
      stp     => stp,
      spin    => spin,
      up      => up
    );

  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;

  process
    variable seed1: positive := 1;
    variable seed2: positive := 1;
    variable rnd:   real;
  begin
    sresetn <= '0';
    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    sresetn <= '1';
    for i in 1 to 100 loop
      uniform(seed1, seed2, rnd);
      (go, stp, spin) <= to_unsigned(integer(floor(8.0 * rnd)), 3);
      wait until rising_edge(clk);
    end loop;
    stop;
  end process;

end architecture sim;

