library ieee;
use ieee.std_logic_1164.all;

entity timer2 is
    generic(
    freq: positive range 1 to 1000;
    tmax: natural
);
port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        tz:       in  std_ulogic;
        t:        out natural range 0 to tmax
    );
end entity timer2;

architecture rtl of timer2 is

    signal cnt:     natural range 0 to freq - 1;
    signal t_local: natural range 0 to tmax;

begin

    t <= t_local;

            -- Add your code here
    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0'  then
                cnt <= 0;
            else
                if tz = '1' then
                    cnt <= 0; 
                else
                    if t_local /= tmax then
                        if cnt = freq-1 then
                            cnt <= 0;
                        else
                            cnt <= cnt + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;

    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0'  then
                t_local <= 0;
            else
                if tz = '1' then
                    t_local <= 0; 
                else
                    if t_local /= tmax and cnt = freq-1 then
                        t_local <= t_local + 1; 
                    end if;
                end if;
            end if;
        end if;

    end process;
end architecture rtl;

