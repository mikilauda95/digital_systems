library ieee;
use ieee.std_logic_1164.all;

entity counter is
    generic(
    cmax: natural
);
port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        cz:       in  std_ulogic;
        inc:      in  std_ulogic;
        c:        out natural range 0 to cmax
    );
end entity counter;

architecture rtl of counter is

    signal c_local: natural range 0 to cmax;

begin

    c <= c_local;
    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' then

                c_local <=  0;
            else
                if cz = '1' then
                    c_local <= 0;
                else
                    if c_local /= cmax and inc = '1' then
                        c_local <= c_local + 1;
                    end if;
                end if;
            end if;
        end if;

    end process;

end architecture rtl;

