library ieee;
use ieee.std_logic_1164.all;

entity g1_count is
    port(clk: in  std_ulogic;
         a:   in  std_ulogic;
         res:   in  std_ulogic;
         s:   out std_ulogic);
end entity g1_count;

architecture arc of g1 is

    signal states: unsigned(4 downto 0) := "00000";
    signal s_local: std_ulogic;

begin

    s <= s_local;

    comb_reg: process(clk) --combinational and register process
    begin 
        if rising_edge(clk) then
            if res='0' then
                states <="00000";
            elsif a='1' and states=0 then 
                states <= states+1 ;
            elsif a='1' and states="11111" then
                states <= "00001";
            elsif states /= "00000" then 
                states <= states + 1;
            end if;
        end if;
    end process comb_reg;

    comb_out: process(states) --combinational process
    begin
        case states is 
            when "00000" => 
                s_local <= '0';
            when "00001" => 
                s_local <= '1';
            when "10001" =>
                s_local <= not s_local;
            when "11001" => 
                s_local <= not s_local;
            when "11101" => 
                s_local <= not s_local;
            when "11111" => 
                s_local <= not s_local;
            when others => null;
        end case;
    end process comb_out;

end architecture arc;

