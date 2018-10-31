use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity edge_sim is
end entity edge_sim;

architecture sim of edge_sim is

  signal clk:      std_ulogic;
  signal sresetn:  std_ulogic;
  signal data_in:  std_ulogic;
  signal re:       std_ulogic;
  signal fe:       std_ulogic;

begin

  dut: entity work.edge(rtl)
    port map(
      clk     => clk,
      sresetn => sresetn,
      data_in => data_in,
      re      => re,
      fe      => fe
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
    data_in <= '0';
    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    sresetn <= '1';
    for i in 1 to 100 loop
      uniform(seed1, seed2, rnd);
      data_in <= '0' when rnd < 0.5 else '1';
      wait until rising_edge(clk);
    end loop;
    stop;
  end process;

end architecture sim;

