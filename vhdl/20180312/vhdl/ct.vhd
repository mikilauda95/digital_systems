--import library needed
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Declaration of the entity
entity ct is
    port (
    switch0 :   in std_ulogic;
    wire_in :   in  std_ulogic;
    wire_out:   out std_ulogic;
    led     :   out std_ulogic_vector(3 downto 0)
    );
end ct;  

--Architecture declaraton
architecture arc of ct is

begin

    --Use a process with sensitivity list. Process can also be avoided in this case
    process (wire_in, switch0) --wake up process if any of the inputs change
    begin

        wire_out <= switch0;

        led(0) <= '1';
        led(1) <= '0';
        led(2) <= wire_in;
        led(3) <= not wire_in;
    end process;    

end arc;
