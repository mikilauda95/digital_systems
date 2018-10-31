library ieee;
use ieee.std_logic_1164.all;

entity sr2 is
    generic(n: positive := 4);
    port(
            clk:      in  std_ulogic;
            sresetn:  in  std_ulogic;
            shift:    in  std_ulogic;
            di:       in  std_ulogic;
            do:       out std_ulogic_vector(n-1 downto 0)
        );
end entity sr2;

architecture rtl of sr2 is

    signal reg: std_ulogic_vector(n-1 downto 0);

begin

    do <= reg;

            -- Add your code here

    process (clk)
    begin
        if rising_edge(clk) then

            if sresetn = '0'  then
                reg <= (others => '0');
            else
                if shift = '1' then
                    reg <= reg(n-2 downto 0) & di;
                end if;

            end if;
        end if;
    end process;

end architecture rtl;
