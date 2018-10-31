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

  -- Add your code here

begin

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

  -- Add your code here

end architecture rtl;

