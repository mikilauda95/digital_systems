-- File g1_doublecomb.vhd

-- Library ieee contains package std_logic_1164 that provides definition of the std_ulogic type and overloads operators for std_ulogic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g1_doublecomb is
    port(
            clk: in  std_ulogic;
            a:   in  std_ulogic;
            res: in  std_ulogic;            
            s:   out std_ulogic
        );
end entity g1_doublecomb;

architecture arc of g1_doublecomb is

    -- Internal copy; the output s will be a copy of this signal
    signal s_local: std_ulogic;
    signal state: unsigned(4 downto 0) := "00000";

begin

    s <= s_local; -- Output s is a copy of s_local

    p: process(clk)
    begin
        -- Synchronous behavior, execute if rising edge
        if rising_edge(clk) then
            if res = '0' then
                state <="00000";
            elsif state = "11111" and a='1' then
                state <= "00001";
            elsif state /= "00000" then
                state <= state + 1;
            elsif a ='1' and state = "00000" then
                state <= state + 1;
            end if;

        end if;
    end process p;

    -- Combinational process
    process (state)
    begin

        case state is
            when "00000" =>
                s_local <= '0';
            when "00001"  =>
                s_local <='1';
            when "10001" =>
                s_local <= not s_local;
            when "11001" =>
                s_local <=not s_local;
            when "11101" =>
                s_local <=not s_local;
            when "11111" =>
                s_local <=not s_local;
            when others =>
                null;
        end case;
    end process;

end architecture arc;
