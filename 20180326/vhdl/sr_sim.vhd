-- vim: set textwidth=0:

use std.env.all; -- to use stop and finish

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types
use ieee.numeric_std.all; -- to use to_unsigned
use ieee.math_real.all; -- to use random generator

-- Simulation environments are frequently back boxes
entity sr_sim is
end entity sr_sim;

architecture sim of sr_sim is

	signal clk:      std_ulogic;
	signal sresetn:  std_ulogic;
	signal shift:    std_ulogic;
	signal di:       std_ulogic;
	signal do:       std_ulogic_vector(3 downto 0);

begin

	-- entity instantiation of the Design Under Test
	dut: entity work.sr(arc)
		port map(
			clk     => clk,
			sresetn => sresetn,
			shift   => shift,
			di      => di,
			do      => do
		);

	-- clock generator
	process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	-- input stimulus (shift and di)
	process
		variable seed1: positive := 1; -- for the random generator
		variable seed2: positive := 1; -- for the random generator
		variable rnd:   real; -- for the random generator
	begin
		sresetn <= '0'; -- assert reset low
		for i in 1 to 10 loop -- wait 10 clock periods
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1'; -- assert reset high
		for i in 1 to 100 loop -- 100 clock periods of test
			uniform(seed1, seed2, rnd); -- throw dice
			(shift, di) <= to_unsigned(integer(floor(4.0 * rnd)), 2); -- convert [0..1[ random real to two random std_ulogic
			wait until rising_edge(clk);
		end loop;
		stop; -- end simulation
	end process;

end architecture sim;
