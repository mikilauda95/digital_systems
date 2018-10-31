library ieee;
use ieee.std_logic_1164.all;

entity sm is
    port(
            clk:      in  std_ulogic;
            sresetn:  in  std_ulogic;
            go:       in  std_ulogic;
            stp:      in  std_ulogic;
            spin:     in  std_ulogic;
            up:       out std_ulogic
        ); end entity sm;

architecture rtl of sm is
        -- Add your code here
    type states is (IDLE, RUN, HALT);
    signal NextState, CurrState : states;



begin

        -- Add your code here
    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' then CurrState <= IDLE; else
            CurrState <= NextState; 
        end if;
    end if;

end process;

                                                                                        -- Next state process
process (CurrState, go, stp, spin)
begin
    case CurrState is
        when IDLE   =>
            if  go = '0' then
                NextState <= IDLE ;
            elsif go = '1' then
                NextState <= RUN ;
            end if;
        when RUN    =>
            if  stp = '0' then
                NextState <= RUN ;
            elsif stp = '1' then
                NextState <= HALT ;
            end if;
        when HALT   =>
            if  go = '1' and spin = '0' then
                NextState <= RUN ;
            elsif go = '0' and spin = '0' then
                NextState <= IDLE ;
            elsif spin = '1' then
                NextState <= HALT ;
            end if;
    end case;


end process;

process (CurrState)
begin
    case CurrState is
        when IDLE   =>
            up <= '0';
        when RUN    =>
            up <= '1';
        when HALT   =>
            up <= '0';

    end case;
end process;

end architecture rtl;

