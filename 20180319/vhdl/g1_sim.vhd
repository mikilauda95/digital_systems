-- File g1_sim.vhd

-- Provides the stop and finish procedures
use std.env.all;

-- Library ieee contains package std_logic_1164 that provides definition of the std_ulogic type and overloads operators for std_ulogic
library ieee;
use ieee.std_logic_1164.all;

-- The entity of a simulation environment usually has no input output ports.
entity g1_sim is
end entity g1_sim;

architecture sim of g1_sim is

  /* We declare signals to be connected to the instance of g1. the names of the
     signals are the same as the name of the ports of the entity g1 because it is
     much simpler but we could use different names and bind signal names to port
     names in the instanciation of g1. */
  signal clk, a, s: std_ulogic;

begin

  -- Generate a symmetrical clock with a period of 20 ns that will never stop.
  clock_generator: process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process clock_generator;

  -- Generate the input sequence for the signal a.
  a_generator: process
    type num_cycles_array is array(natural range 1 to 4) of positive;
    constant num_cycles: num_cycles_array := (5, 17, 21, 30);
  begin
    a <= '0';
    for i in num_cycles'range loop
      for j in 1 to num_cycles(i) loop
        wait until clk = '0' and clk'event;
      end loop;
      a <= '1';
      wait until clk = '0' and clk'event;
      a <= '0';
    end loop;
    for i in 1 to 64 loop
      wait until clk = '0' and clk'event;
    end loop;
    report "End of simulation";
    stop;
  end process a_generator;

  /* Instanciate the entity g1, architecture arc. Name the instance i_g1 and
     specify the association between port names and actual signals. */
  i_g1: entity work.g1(arc)
    port map(clk => clk,
             a   => a,
             s   => s);

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0:
