-- File g1_abort.vhd

entity g1_abort is
    port(clk: in  bit;
         a:   in  bit;
         s:   out bit);
end entity g1_abort;

architecture arc of g1_abort is

    -- Internal copy; the output s will be a copy of this signal
    signal s_local: bit;

begin

    s <= s_local; -- Output s is a copy of s_local

    p: process
    begin
        -- First, synchronize on a rising edge of clock where a is active
        if a='1' and clk='1' and clk'event then
            s_local <= '1';             -- A new macro-cycle starts (set s_local)
            for i in 4 downto 0 loop    -- A macro-cycle is made of 5 sequences
                for j in 1 to 2 ** i loop -- Wait for 2^i cycles
                    wait until clk = '1';
                    exit when a = '1';
                end loop;
                exit when a = '1';
                s_local <= not s_local;   -- Invert s_local
            end loop;
        else
            wait until clk='1' and clk'event;
        end if;
    end process;

end architecture arc;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0:
