-- vim: set textwidth=0:

library ieee;
use ieee.std_logic_1164.all;

entity lb_ref is
	generic(
		freq:    positive range 1 to 1000	:= 100;
		timeout: positive range 1 to 1000000	:= 500000
	);
	port(
		clk:      in  std_ulogic;
		areset:   in  std_ulogic;
		led:      out std_ulogic_vector(3 downto 0)
	);
end entity lb_ref;

architecture arc of lb_ref is
	signal sresetn:		std_ulogic;
	signal pulse:		std_ulogic;
	signal di:		std_ulogic;
	signal first_di:	std_ulogic;
	signal led_local:	std_ulogic_vector(3 downto 0);
begin
	led <= led_local;
	di  <= led_local(0) or (first_di and pulse);

	u0: entity work.sr(arc)
	port map(
		clk	=> clk,
		sresetn	=> sresetn,
		shift	=> pulse,
		di	=> di,
		do	=> led_local
	);

	u1: entity work.timer(arc)
	generic map(
		freq	=> freq,
		timeout	=> timeout
	)
	port map(
		clk	=> clk,
		sresetn	=> sresetn,
		pulse	=> pulse
	);

	process(clk)
		variable tmp: std_ulogic;
	begin
		if rising_edge(clk) then
			sresetn <= tmp;
			tmp := not areset;
		end if;
	end process;

	process(clk)
		variable first_time: boolean;
	begin
		if rising_edge(clk) then
			if sresetn = '0' then -- synchronous, active low, reset
				first_di <= '1';
			elsif pulse = '1' then
				first_di <= '0';
			end if;
		end if;
	end process;
end architecture arc;

use std.textio.all;
use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity lb_eval is
end entity lb_eval;

architecture eval of lb_eval is

	signal clk:       std_ulogic;
	signal areset:    std_ulogic;
	signal led:       std_ulogic_vector(0 to 3);
	signal led_ref:   std_ulogic_vector(0 to 3);

	constant freq:           positive range 1 to 1000    := 10;
	constant timeout:        positive range 1 to 1000000 := 50;
	constant period:         real := 1000.0 / real(freq); -- ns
	constant pulse_interval: real := real(timeout) * 1000.0; -- ns

begin

	dut: entity work.lb(arc)
		generic map(
			freq	=> freq,
			timeout	=> timeout
		)
		port map(
			clk     => clk,
			areset  => areset,
			led     => led
		);

	dut_ref: entity work.lb_ref(arc)
		generic map(
			freq	=> freq,
			timeout	=> timeout
		)
		port map(
			clk     => clk,
			areset  => areset,
			led     => led_ref
		);

	postponed process(led, led_ref)
    variable l: line;
	begin
    if led /= led_ref then
			write(l, string'("NON REGRESSION TEST FAILED: LED=") & to_string(led) & string'(" (SHOULD BE ") & to_string(led_ref) & string'(")"));
			writeline(output, l);
      stop;
    end if;
	end process;

	process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	process
    variable l: line;
	begin
		areset <= '1';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		areset <= '0';
		for i in 1 to 100000 loop
			wait until rising_edge(clk);
		end loop;
		write(l, string'("NON REGRESSION TEST PASSED"));
    writeline(output, l);
		stop;
	end process;

end architecture eval;
