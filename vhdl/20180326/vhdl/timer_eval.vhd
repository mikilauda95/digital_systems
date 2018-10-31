-- vim: set textwidth=0:

library ieee;
use ieee.std_logic_1164.all;

entity timer_ref is
	generic(
		freq:    positive range 1 to 1000;
		timeout: positive range 1 to 1000000
	);
	port(
		clk:      in  std_ulogic;
		sresetn:  in  std_ulogic;
		pulse:    out std_ulogic
	);
end entity timer_ref;

architecture arc of timer_ref is
	signal cnt1: natural range 0 to freq - 1;
	signal cnt2: natural range 0 to timeout - 1;
	signal tick: std_ulogic;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			tick <= '0';
			if sresetn = '0' then -- synchronous, active low, reset
				cnt1 <= freq - 1;
			elsif cnt1 = 0 then
				cnt1 <= freq - 1;
				tick <= '1';
			else
				cnt1 <= cnt1 - 1;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			pulse <= '0';
			if sresetn = '0' then -- synchronous, active low, reset
				cnt2 <= timeout - 1;
			elsif tick = '1' then
				if cnt2 = 0 then
					cnt2 <= timeout - 1;
					pulse <= '1';
				else
					cnt2 <= cnt2 - 1;
				end if;
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

entity timer_eval is
end entity timer_eval;

architecture eval of timer_eval is

	signal clk:           std_ulogic;
	signal sresetn:       std_ulogic;
	signal pulse_1_1:     std_ulogic;
	signal pulse_ref_1_1: std_ulogic;
	signal pulse_7_5:     std_ulogic;
	signal pulse_ref_7_5: std_ulogic;

begin

	dut_1_1: entity work.timer(arc)
		generic map(
			freq	  => 1,
			timeout	=> 1
		)
		port map(
			clk     => clk,
			sresetn => sresetn,
			pulse   => pulse_1_1
		);

	dut_ref_1_1: entity work.timer_ref(arc)
		generic map(
			freq	  => 1,
			timeout	=> 1
		)
		port map(
			clk     => clk,
			sresetn => sresetn,
			pulse   => pulse_ref_1_1
		);

	postponed process(pulse_1_1, pulse_ref_1_1)
    variable l: line;
	begin
    if pulse_1_1 /= pulse_ref_1_1 then
			write(l, string'("NON REGRESSION TEST FAILED: PULSE=") & to_string(pulse_1_1) & string'(" (SHOULD BE ") & to_string(pulse_ref_1_1) & string'(")"));
      writeline(output, l);
      stop;
    end if;
	end process;

	dut_7_5: entity work.timer(arc)
		generic map(
			freq	  => 7,
			timeout	=> 5
		)
		port map(
			clk     => clk,
			sresetn => sresetn,
			pulse   => pulse_7_5
		);

	dut_ref_7_5: entity work.timer_ref(arc)
		generic map(
			freq	  => 7,
			timeout	=> 5
		)
		port map(
			clk     => clk,
			sresetn => sresetn,
			pulse   => pulse_ref_7_5
		);

	postponed process(pulse_7_5, pulse_ref_7_5)
    variable l: line;
	begin
    if pulse_7_5 /= pulse_ref_7_5 then
			write(l, string'("NON REGRESSION TEST FAILED: PULSE=") & to_string(pulse_7_5) & string'(" (SHOULD BE ") & to_string(pulse_ref_7_5) & string'(")"));
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
    variable cnt_1_1: natural := 0;
    variable cnt_7_5: natural := 0;
    variable l:       line;
	begin
		sresetn <= '0';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1';
    loop
			wait until rising_edge(clk) and (pulse_1_1 = '1' or pulse_7_5 = '1');
      if pulse_1_1 = '1' then
        cnt_1_1 := cnt_1_1 + 1;
      end if;
      if pulse_7_5 = '1' then
        cnt_7_5 := cnt_7_5 + 1;
      end if;
      exit when cnt_1_1 > 10 and cnt_7_5 > 10;
		end loop;
		write(l, string'("NON REGRESSION TEST PASSED"));
    writeline(output, l);
		stop;
	end process;

end architecture eval;
