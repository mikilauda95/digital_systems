-- vim: set textwidth=0:

use std.env.all; -- to use stop and finish

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

-- Simulation environments are frequently back boxes
entity timer_sim is
end entity timer_sim;

architecture sim of timer_sim is

	signal clk:      std_ulogic;
	signal sresetn:  std_ulogic;
	signal pulse:    std_ulogic;

	constant freq:           positive range 1 to 1000    := 10;
	constant timeout:        positive range 1 to 1000000 := 50;
	constant period:         real := 1000.0 / real(freq); -- ns

begin

	-- entity instantiation of the Design Under Test
	dut: entity work.timer(arc)
		generic map(
			freq    => freq,
			timeout => timeout
		)
		port map(
			clk     => clk,
			sresetn => sresetn,
			pulse   => pulse
		);

	-- clock generator
	process
	begin
		clk <= '0';
		wait for (period / 2.0) * 1 ns;
		clk <= '1';
		wait for (period / 2.0) * 1 ns;
	end process;

	process
	begin
		sresetn <= '0'; -- assert reset low
		for i in 1 to 10 loop -- wait 10 clock periods
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1'; -- assert reset high
		for i in 1 to 10 loop -- wait 10 clock periods
			wait until rising_edge(clk) and pulse = '1';
		end loop;
		stop; -- end simulation
	end process;

end architecture sim;
