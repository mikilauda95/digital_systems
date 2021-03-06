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
    -- Signal array for implementing the shift register
    signal shift_reg_s: std_ulogic_vector(30 downto 0) := "1001111000000001111111111111111";
    -- For enabling the shifting
    signal en_shift_reg: std_ulogic;

begin

    s <= s_local; -- Output s is a copy of s_local

    p: process(clk, res, en_shift_reg, shift_reg_s)
    begin
        -- If reset is low, then reset to the initial state 
        if res = '0' then
            s_local <= '0';
            en_shift_reg <= '0';
            shift_reg_s(30 downto 0) <= "1001111000000001111111111111111";
        else
            -- At the rising edge
            if rising_edge(clk) then
                -- If the activation signal arrives, start the shifting
                if a='1' and  (shift_reg_s = "1001111000000001111111111111111" or shift_reg_s = "0011110000000011111111111111111") then
                    en_shift_reg <= '1';
                    shift_reg_s <= "1001111000000001111111111111111";
                    --shift_reg_s(30) <= shift_reg_s(0);
                    --shift_reg_s(29 downto 0) <= shift_reg_s(30 downto 1);
                    --s_local <= shift_reg_s (0);
                elsif en_shift_reg = '1' then
                    -- We are done
                    if shift_reg_s = "0011110000000011111111111111111" then
                        en_shift_reg <= '0';
                        --s_local <= '0';
                    else
                    -- We are running a macro cycle so we shift
                        shift_reg_s(30) <= shift_reg_s(0);
                        shift_reg_s(29 downto 0) <= shift_reg_s(30 downto 1);
                        --s_local <= shift_reg_s (0);
                    end if;
                else
                    --if the enable is 0, we are waiting for 'a'
                    en_shift_reg <= '0';
                end if;
            end if;
            --Output is always equal to the and of enable and last bit of the register (the one that goes out first)
            s_local <= shift_reg_s(0) and en_shift_reg;
        end if;
    end process p;
end architecture arc;
