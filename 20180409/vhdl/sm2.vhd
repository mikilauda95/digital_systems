library ieee;
use ieee.std_logic_1164.all;

entity sm2 is
    generic(
    init: natural;
    tmax: natural;
    cmax: natural
);
port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        start:    in  std_ulogic;
        busy:     out std_ulogic;
        err:      out std_ulogic;
        data_drv: out std_ulogic;
        tz:       out std_ulogic;
        t:        in  natural range 0 to tmax;
        cz:       out std_ulogic;
        c:        in  natural range 0 to cmax;
        inc:      out std_ulogic;
        di:       out std_ulogic;
        re:       in  std_ulogic;
        fe:       in  std_ulogic
    );
end entity sm2;

architecture rtl of sm2 is

    type states is (IDLE, STARTING, RECEIVING);
    signal NextState, CurrState, PrevState : states;
    signal tz_s : std_ulogic;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' then CurrState <= IDLE; else
            CurrState <= NextState; 
            PrevState <= CurrState;
        end if;
    end if;

end process;

-- Next state process
process (CurrState, start, t, c, re, fe)
begin
    case CurrState is
        when IDLE   =>
            if  t /= tmax then
                NextState <= IDLE ;
            elsif t = tmax and start = '1' then
                NextState <= STARTING ;
            end if;
        when STARTING    =>
            if  t /= init then
                NextState <= STARTING;
            elsif t = init then
                NextState <= RECEIVING;
            end if;
        when RECEIVING   =>
            if t = init and PrevState=RECEIVING then
                NextState <= IDLE;
            elsif  c /= cmax then
                NextState <= RECEIVING ;
            elsif c = cmax and re = '1' then
                NextState <= IDLE ;
            end if;
    end case;

end process;

-- OUTPUT PROCESS
process (CurrState, NextState, start, t, c, re, fe)
begin
    case CurrState is

        when IDLE   =>
            data_drv <= '0';
            tz <= '0';
            cz <= '0';
            busy <= '1';
            inc <= '0';
            err <= '0';
            di <= '0';
            if t = tmax then
               busy <= '0'; 
            end if;

            if t = tmax and NextState = STARTING then
                tz <= '1';
            end if;

        when STARTING    =>

            data_drv <= '1';
            busy <= '1';
            inc <= '0';
            di <= '0';
            tz <= '0';
            cz <= '0';
            err <= '0';

            if t = init then
                tz <= '1';
                cz <= '1';
            end if;

        when RECEIVING   =>
            data_drv <= '0';
            busy <= '1';
            tz <= '0';
            cz <= '0';
            inc <= '0';
            err <= '0';
            if t = init and PrevState = RECEIVING then
                tz <= '1';
                err <= '1'; 
            end if;

            if fe = '1' then
                if t < 100 then
                    di <= '0';
                else
                    di <= '1';
                end if;
                tz <= '1';
                inc <= '1';
            end if;
            if c = cmax and re = '1' then
                cz <= '1';
                tz <= '1';
            end if;
    end case;
end process;

end architecture rtl;

