library ieee;
use ieee.std_logic_1164.all;

entity edge is
    port(
            clk:      in  std_ulogic;
            sresetn:  in  std_ulogic;
            data_in:  in  std_ulogic;
            re:       out std_ulogic;
            fe:       out std_ulogic
        );
end entity edge;

architecture rtl of edge is

    signal sync: std_ulogic_vector(0 to 2);

begin
    fe <= not(sync(1)) and sync(2);
    re <= not(sync(2)) and sync(1);
    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' then
                sync <= (others => '0');
            else
                sync(0) <= data_in;
                sync(1 to 2) <= sync(0 to 1);

            end if;
        end if;

    end process;

-- Add your code here

end architecture rtl;

