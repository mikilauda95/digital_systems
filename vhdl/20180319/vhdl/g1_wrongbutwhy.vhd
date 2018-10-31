-- File g1_ares_shift.vhd

-- Library ieee contains package std_logic_1164 that provides definition of the std_ulogic type and overloads operators for std_ulogic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g1_ares_shift is
    port(
            clk: in  std_ulogic;
            a:   in  std_ulogic;
            res: in std_ulogic; -- active on '0'
            s:   out std_ulogic
        );
end entity g1_ares_shift;

architecture arc of g1_ares_shift is

    -- Internal copy; the output s will be a copy of this signal
    signal s_local: std_ulogic;
    signal shift_reg_s: std_ulogic_vector(30 downto 0) := "0000000000000000000000000000000";
    signal out_shift, input_shift: std_ulogic;

begin

    s <= s_local; -- Output s is a copy of s_local
    shift_reg_s(30) <= input_shift ;

    p: process(clk, res)
    begin
        if res = '0' then
            s_local <= '0';
        else
            if rising_edge(clk) then
                if a = '1' and ((shift_reg_s = "0000000000000000000000000000000") or (shift_reg_s = "1111111111111111111111111111111")) then
                    s_local <= '1';
                    input_shift <= '1';
                elsif shift_reg_s = "1111111111111111000000000000000" then
                    s_local <= not s_local;
                elsif shift_reg_s = "1111111111111111111111110000000" then
                    s_local <= not s_local;
                elsif shift_reg_s = "1111111111111111111111111111000" then
                    s_local <= not s_local;
                elsif shift_reg_s = "1111111111111111111111111111110" then
                    s_local <= not s_local;
                elsif shift_reg_s = "1111111111111111111111111111111" then
                    s_local <= not s_local;
                end if;
            end if;
        end if;
    end process p;

    -- If Enable is high then behave as a shift register, else load the default configuration
    process (clk, res)
    begin
        if res = '0' then
            shift_reg_s(29 downto 0) <= "000000000000000000000000000000";
        else
            if rising_edge(clk) then
                for i in 30 downto 1 loop
                    shift_reg_s(i-1) <= shift_reg_s(i);
                end loop;
                out_shift <= shift_reg_s(0);
            end if;
        end if;
    end process;

end architecture arc;
