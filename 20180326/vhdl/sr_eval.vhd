-- vim: set textwidth=0:

library ieee;
use ieee.std_logic_1164.all;

entity sr_ref is
	port(
	    clk:      in  std_ulogic;
	    sresetn:  in  std_ulogic;
	    shift:    in  std_ulogic;
	    di:       in  std_ulogic;
	    do:       out std_ulogic_vector(3 downto 0)
	);
end entity sr_ref;

architecture arc of sr_ref is
	signal reg: std_ulogic_vector(3 downto 0);
begin
	do <= reg;

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				reg <= (others => '0');
			elsif shift = '1'  then
				reg <= di & reg(3 downto 1);
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

entity sr_eval is
end entity sr_eval;

architecture eval of sr_eval is

	signal clk:     std_ulogic;
	signal sresetn:  std_ulogic;
	signal shift:    std_ulogic;
	signal di:       std_ulogic;
	signal do:       std_ulogic_vector(3 downto 0);
	signal do_ref:   std_ulogic_vector(3 downto 0);

begin

	dut: entity work.sr(arc)
		port map(
			clk     => clk,
			sresetn => sresetn,
			shift   => shift,
			di      => di,
			do      => do
		);

	dut_ref: entity work.sr_ref(arc)
		port map(
			clk     => clk,
			sresetn => sresetn,
			shift   => shift,
			di      => di,
			do      => do_ref
		);

	postponed process(do, do_ref)
    variable l: line;
	begin
    if do /= do_ref then
      write(l, string'("NON REGRESSION TEST FAILED: DO=") & to_string(do) & string'(" (SHOULD BE ") & to_string(do_ref) & string'(")"));
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
		variable seed1: positive := 1;
		variable seed2: positive := 1;
		variable rnd:   real;
    variable l:     line;
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
    write(l, string'("NON REGRESSION TEST PASSED"));
    writeline(output, l);
		stop;
	end process;

end architecture eval;
