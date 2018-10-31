use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity counter_sim is
  generic(
    cmax: natural := 5
  );
end entity counter_sim;

architecture sim of counter_sim is

  signal clk:      std_ulogic;
  signal sresetn:  std_ulogic;
  signal cz:       std_ulogic;
  signal inc:      std_ulogic;
  signal c:        natural range 0 to cmax;

begin

  dut: entity work.counter(rtl)
    generic map(
      cmax => cmax
    )
    port map(
      clk     => clk,
      sresetn => sresetn,
      cz      => cz,
      inc     => inc,
      c       => c
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
    cz      <= '0';
    inc     <= '0';
    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    sresetn <= '1';
    for i in 1 to 100 loop
      uniform(seed1, seed2, rnd);
      (cz, inc) <= to_unsigned(integer(floor(2.1 * rnd)), 2);
      wait until rising_edge(clk);
    end loop;
    stop;
  end process;

end architecture sim;

