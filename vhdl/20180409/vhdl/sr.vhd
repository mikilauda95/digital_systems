-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types
use ieee.numeric_std.all;

entity sr is
   generic( size: positive := 4
   );
	port(
	    clk:      in  std_ulogic;
	    sresetn:  in  std_ulogic;
	    shift:    in  std_ulogic;
	    di:       in  std_ulogic;
	    do:       out std_ulogic_vector(size-1 downto 0)
	);
end entity sr;

architecture arc of sr is

signal reg : std_ulogic_vector(size-1 downto 0);

begin

--shift_register: process(clk, sresetn, shift)
--begin
--if(clk='1' AND clk'event) then
--  if(sresetn='0') then
--    reg<=(others=>'0');
--  elsif(shift='1') then
--   reg(3)<=di;
--   reg(2)<=reg(3);
--   reg(1)<=reg(2);
--   reg(0)<=reg(1);
--  end if;
--end if;
--end process shift_register;

do<=reg;

--version 2
shift_register: process(clk)
begin
if(clk='1' AND clk'event) then
  if(sresetn='0') then
    reg<=(others=>'0');
  elsif(shift='1') then
    reg<=di&reg(size-1 downto 1);
  end if;
end if;
end process shift_register;

end architecture arc;
