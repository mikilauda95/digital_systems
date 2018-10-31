-- File g1.vhd

-- Library ieee contains package std_logic_1164 that provides definition of the std_ulogic type and overloads operators for std_ulogic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g1 is
    port(
            clk: in  std_ulogic;
            a:   in  std_ulogic;
            srstn: in std_ulogic; -- active on '0'
            ce : in std_ulogic; 
            s:   out std_ulogic
        );
end entity g1;

architecture arc of g1 is

    -- Internal copy; the output s will be a copy of this signal
    signal s_local: std_ulogic;

begin

    s <= s_local; -- Output s is a copy of s_local

    p: process(clk, ce)
        variable cnt: unsigned(4 downto 0) := "00000";
    begin
        -- Synchronous behavior, execute if rising edge
        if ce='0' then
            null;
        elsif rising_edge(clk) then
            -- Check the srstnet at the rising edge of the clock (low active srstnet)
            if srstn = '0' then
                cnt := "00000";
                s_local <= '0';
            else
                -- if the activation signal is active and the counter the macro cycle is finished or at the very end (borderline case)
                if a = '1' and (cnt=0 or cnt=31) then
                    s_local <= '1';
                    cnt := "00000";
                    cnt := cnt + 1;
                -- Switch the output after 16 clock cycles 
                elsif cnt = 16 then
                    s_local <= not s_local;
                    cnt := cnt + 1;
                -- Switch the output after 8 clock cycles 
                elsif cnt = 24 then
                    s_local <= not s_local;
                    cnt := cnt + 1;
                -- Switch the output after 4 clock cycles 
                elsif cnt = 28 then
                    s_local <= not s_local;
                    cnt := cnt + 1;
                -- 4witch the output after 2 clock cycles 
                elsif cnt = 30 then
                    s_local <= not s_local;
                    cnt := cnt + 1;
                -- Switch the output after 1 clock cycles 
                elsif cnt = 31 then
                    s_local <= not s_local;
                    cnt := cnt + 1;
                -- increment the output if cnt has been initialized
                elsif cnt /= 0 then
                    cnt := cnt + 1;
                end if;
            end if;
        end if;
end process p;

end architecture arc;
