library ieee;
use ieee.std_logic_1164.all;

entity g1 is
    port(clk: in  std_ulogic;
         a:   in  std_ulogic;
         res:   in  std_ulogic;
         s:   out std_ulogic);
end entity g1;

architecture arc of g1 is

    signal s_local, res_shift, first_shift: std_ulogic;
    signal shift_reg_s: std_ulogic_vector(30 downto 0);

begin

    s <= s_local;


    comb_reg: process(clk) --combinational and register process
    begin 
        if rising_edge(clk) then
            if res = '0' then
                res_shift <= '0';
            elsif a='1' and shift_reg_s = "0000000000000000000000000000000" then 
                first_shift <= '1';
                res_shift <= '1';
            elsif a='1' and shift_reg_s(0)='1' then
                first_shift <= '1';
                res_shift <= '1';
            else
                first_shift <= '0';
                res_shift <= '1';
            end if;
        end if;
    end process comb_reg;

    comb_out: process(shift_reg_s) --combinational process
    begin
        if shift_reg_s = "0000000000000000000000000000000" then
            s_local <= '0';
        elsif shift_reg_s(30)='1' then
            s_local <= '1';
        elsif shift_reg_s(14)='1' then
            s_local <= not s_local;
        elsif shift_reg_s(6)='1' then
            s_local <= not s_local;
        elsif shift_reg_s(2)='1' then
            s_local <= not s_local;
        elsif shift_reg_s(0)='1' then
            s_local <= not s_local;
        end if;
    end process comb_out;

    shift_pr: process (clk, first_shift)
    begin
        shift_reg_s(30) <= first_shift;
        if rising_edge(clk) then

            if res_shift = '0' then
                shift_reg_s(29 downto 0) <=  (others => '0');
            else
                for i in 30 downto 1 loop
                    shift_reg_s(i-1) <= shift_reg_s(i);
                end loop;
            end if;
        end if;
    end process;

end architecture arc;

