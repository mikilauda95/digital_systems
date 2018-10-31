-- DTH11 controller wrapper, standalone version, top level

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

entity dht11_ctrl_sa is
    generic(
    freq:    positive range 1 to 1000;
    init:    natural;
    tmax:    natural;
    cmax:    natural
);
port(
        clk:      in    std_ulogic;
        areset:   in    std_ulogic;
        btn:      in    std_ulogic;
        sw:       in    std_ulogic_vector(3 downto 0);
        data:     inout std_logic;
        led:      out   std_ulogic_vector(3 downto 0)
    );
end entity dht11_ctrl_sa;

architecture rtl of dht11_ctrl_sa is

    signal data_in:   std_ulogic;
    signal data_drv:  std_ulogic;
    signal data_drvn: std_ulogic;
    signal s_sresetn: std_ulogic;
    signal sresetn: std_ulogic;
    signal start: std_ulogic;
    signal busy: std_ulogic;
    signal err: std_ulogic;
    signal do: std_ulogic_vector(39 downto 0);

-- Add your code here




begin

    -- process for the syncronization and negation of the reset 
    process (clk)
    begin
        if rising_edge(clk) then
            s_sresetn <= not areset; 
            sresetn <= s_sresetn; 
        end if;
    end process;

    process (sw)
    begin
        case sw is
            when "0000" =>
                led <= do(3 downto 0);
            when "0001" =>
                led <= do(7 downto 4);
            when "0010" => 
                led <= do(11 downto 8);
            when "0011" =>
                led <= do(15 downto 12);
            when "0100" =>
                led <= do(19 downto 16);
            when "0101" =>
                led <= do(23 downto 20);
            when "0110" =>
                led <= do(27 downto 24);
            when "0111" =>
                led <= do(31 downto 28);
            when "1111" =>
                led <= "00"& busy & err;
            when others =>
                led <= "1010";

        end case;

    end process;

  -- Tristate buffer instance
    u1 : iobuf
    generic map (
                    drive => 12,
                    iostandard => "lvcmos33",
                    slew => "slow")
    port map (
                 o  => data_in,
                 io => data,
                 i  => '0',
                 t  => data_drvn
             );

    data_drvn <= not data_drv;

  -- Instance of the edge detector for the start 

    edge_0 : entity work.edge(rtl)
    port map (
                 clk => clk,
                 sresetn => sresetn,
                 data_in => btn,
                 re => start
             );


    -- instance of the dht11_ctl controller
    dht11_ctrl_0 : entity work.dht11_ctrl(rtl)
    generic map (
                    freq => freq,
                    init => init,
                    tmax => tmax,
                    cmax => cmax
                )
    port map (
                 clk => clk,
                 sresetn => sresetn,
                 data_in => data_in,
                 start => start,
                 data_drv => data_drv,
                 busy => busy,
                 err => err,
                 do => do
             );




end architecture rtl;

