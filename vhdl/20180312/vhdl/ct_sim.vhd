-- Import useful libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--testbench entity (void entity)
entity ct_sim is
end entity ct_sim;  


architecture sim of ct_sim is

    -- Define the "base-period" for signal changing
    constant PERIOD : time := 10 ns;

    -- Signal declaration
    signal s_switch0  : std_ulogic := '0';
    signal s_wire_in : std_ulogic := '0';
    signal s_wire_out : std_ulogic;
    signal s_led    : std_ulogic_vector(3 downto 0);

    -- import the component
    component ct is
        port (
                 switch0 :   in std_ulogic;
                 wire_in :   in  std_ulogic;
                 wire_out:   out std_ulogic;
                 led     :   out std_ulogic_vector(3 downto 0)
             );
    end component ct;  

begin


    -- Instantiate the component and set the interface
    ct_0 : ct
    port map (
                 switch0  => s_switch0,
                 wire_in  => s_wire_in,
                 wire_out => s_wire_out,
                 led      => s_led
             );



    -- create all the possible signal combinations
    s_switch0   <= not s_switch0 after PERIOD;
    s_wire_in     <= not s_wire_in after 2*PERIOD;


end sim;
