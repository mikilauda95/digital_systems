use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity timer2_sim is
  generic(
    freq: positive range 1 to 1000 := 2;
    tmax: natural := 3
  );
end entity timer2_sim;

architecture sim of timer2_sim is

  signal clk:      std_ulogic;
  signal sresetn:  std_ulogic;
  signal tz:       std_ulogic;
  signal t:        natural range 0 to tmax;

begin

  dut: entity work.timer2(rtl)
    generic map(
      freq => freq,
      tmax => tmax
    )
    port map(
      clk     => clk,
      sresetn => sresetn,
      tz      => tz,
      t       => t
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
    tz      <= '0';
    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    sresetn <= '1';
    for i in 1 to 100 loop
      uniform(seed1, seed2, rnd);
      tz <= '1' when rnd < 0.1 else '0';
      wait until rising_edge(clk);
    end loop;
    stop;
  end process;

end architecture sim;

