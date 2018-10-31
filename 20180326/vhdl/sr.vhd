-- vim: set textwidth=0:


library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity sr is
    generic (N : integer := 4);
    port(
            clk:      in  std_ulogic;
            sresetn:  in  std_ulogic;
            shift:    in  std_ulogic;
            di:       in  std_ulogic;
            do:       out std_ulogic_vector(N-1 downto 0)
        );
end entity sr;

architecture arc of sr is

    signal reg: std_ulogic_vector(N-1 downto 0);
    --signal clk_s: std_ulogic;


begin

    --clk_s <= not clk;
    do <= reg;
    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn= '0'  then
                reg <= (others => '0');  
            elsif  shift = '1' then
                reg <= di & reg(N-1 downto 1) ;
            end if;
        end if;

    end process;

end arc;


