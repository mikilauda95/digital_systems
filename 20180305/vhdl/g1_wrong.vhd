-- File g1.vhd

entity g1 is
    port(clk: in  bit;
         a:   in  bit;
         s:   out bit);
end entity g1;

architecture arc of g1 is

    -- Internal copy; the output s will be a copy of this signal
    signal s_local: bit;

begin

    s <= s_local; -- Output s is a copy of s_local

    p: process
    begin
        -- First, synchronize on a rising edge of clock where a is active
        wait until clk = '1' and clk'event and a = '1';
        s_local <= '1';             -- A new macro-cycle starts (set s_local)
        for i in 4 downto 0 loop    -- A macro-cycle is made of 5 sequences
            for j in 1 to 2 ** i loop -- Wait for 2^i cycles
                wait until clk = '1';
            end loop;
            s_local <= not s_local;   -- Invert s_local
        end loop;
    end process p;

end architecture arc;

