library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use WORK.sha256_pack.ALL;


entity msched is
    port (
             clk  : in std_ulogic;
             aresetn  : in std_ulogic;
             enable : in std_ulogic;
             fill : in std_ulogic;
             M_in : in word;
             Wout : out word
         );
end entity msched;

architecture behav of msched is


    signal W_shift : word_vect(15 downto 0);
    signal Wout_s, W16_64, partial_0, partial_1 : word;
    signal W_0, next_W : word;

begin
    -- Assign the first register to the output of the entity
    Wout <= W_shift(0);

    -- Shift register implementation
    process (clk)
    begin
        if rising_edge(clk) then
            if aresetn = '0' then
                W_shift <= (others => "00000000000000000000000000000000");
            else
                if enable = '1' then
                    for i in 0 to 14 loop
                        W_shift(i+1) <= W_shift(i);
                        W_shift(0) <= W_0;
                    end loop;
                end if;
            end if;
        end if;
    end process;

    -- Compute the next words (used only if we are not filling)
    next_W <= std_ulogic_vector(unsigned(S_sigma1(W_shift(1))) + unsigned(partial_0));
    partial_0 <= std_ulogic_vector(unsigned(W_shift(6)) + unsigned(partial_1));
    partial_1 <= std_ulogic_vector(unsigned(S_sigma0(W_shift(14))) + unsigned(W_shift(15)));

    W_0 <= M_in when fill = '1' else
           next_W;


end behav;
