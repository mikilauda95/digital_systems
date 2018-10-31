use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sr2_sim is
end entity sr2_sim;

architecture sim of sr2_sim is

  signal clk:      std_ulogic;
  signal sresetn:  std_ulogic;
  signal shift:    std_ulogic;
  signal di:       std_ulogic;
  signal do:       std_ulogic_vector(3 downto 0);

begin

  dut: entity work.sr2(rtl)
    port map(
      clk     => clk,
      sresetn => sresetn,
      shift   => shift,
      di      => di,
      do      => do
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
      (shift, di) <= to_unsigned(integer(floor(4.0 * rnd)), 2);
      wait until rising_edge(clk);
    end loop;
    stop;
  end process;

end architecture sim;

