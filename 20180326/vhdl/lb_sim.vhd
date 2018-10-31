-- vim: set textwidth=0:

use std.env.all; -- to use stop and finish

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

-- Simulation environments are frequently back boxes
entity lb_sim is
end entity lb_sim;

architecture sim of lb_sim is

	signal clk:      std_ulogic;
	signal areset:   std_ulogic;
	signal led:      std_ulogic_vector(3 downto 0);

	constant freq:           positive range 1 to 1000    := 10;
	constant timeout:        positive range 1 to 1000000 := 50;
	constant period:         real := 1000.0 / real(freq); -- ns
	constant pulse_interval: real := real(timeout) * 1000.0; -- ns

begin

	-- entity instantiation of the Design Under Test
	dut: entity work.lb(arc)
		generic map(
			freq    => freq,
			timeout => timeout
		)
		port map(
			clk     => clk,
			areset  => areset,
			led     => led
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
		areset <= '1'; -- assert reset low
		for i in 1 to 10 loop -- wait 10 clock periods
			wait until rising_edge(clk);
		end loop;
		areset <= '0'; -- assert reset high
		wait for pulse_interval * 10 ns;
		stop; -- end simulation
	end process;

end architecture sim;
