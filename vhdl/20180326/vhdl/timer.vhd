-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity timer is
    generic(
    freq:    positive range 1 to 1000;
    timeout: positive range 1 to 1000000
);
port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        pulse:    out std_ulogic
    );
end entity timer;


architecture arc of timer is

    signal tick : std_ulogic;
    signal counter1 : natural range 0 to freq-1 := freq-1; 
    signal counter2 : natural range 0 to timeout-1 := timeout-1; 

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn='0' then
                tick <= '0';
                counter1 <= freq-1;
            else
                if counter1 = 0 then
                    tick <= '1';
                elsif counter1 = freq-1 then
                    tick <= '0';
                end if;
                if counter1 = 0 then
                    counter1 <= freq-1;
                else
                    counter1 <= counter1 -1;
                end if;
            end if;
        end if;

    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            pulse <= '0';
            if sresetn='0' then
                counter2 <= timeout-1;            
                pulse <= '0';
            elsif tick = '1' then
                if counter2 = 0 then
                    counter2 <= timeout-1;
                else
                    counter2 <= counter2 -1;
                end if;
                if counter2 = 0 then
                    pulse <= '1';
                end if;
            end if;
        end if;

    end process;

end arc;
