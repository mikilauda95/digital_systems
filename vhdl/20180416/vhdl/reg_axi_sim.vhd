use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_pkg.all;
use work.rnd_pkg.all;

entity reg_axi_sim is
  generic(
    n: positive := 10000
  );
end entity reg_axi_sim;

architecture sim of reg_axi_sim is

  signal aclk:            std_ulogic;
  signal aresetn:         std_ulogic;
  signal s0_axi_araddr:   std_ulogic_vector(11 downto 0);
  signal s0_axi_arprot:   std_ulogic_vector(2 downto 0);
  signal s0_axi_arvalid:  std_ulogic;
  signal s0_axi_rready:   std_ulogic;
  signal s0_axi_awaddr:   std_ulogic_vector(11 downto 0);
  signal s0_axi_awprot:   std_ulogic_vector(2 downto 0);
  signal s0_axi_awvalid:  std_ulogic;
  signal s0_axi_wdata:    std_ulogic_vector(31 downto 0);
  signal s0_axi_wstrb:    std_ulogic_vector(3 downto 0);
  signal s0_axi_wvalid:   std_ulogic;
  signal s0_axi_bready:   std_ulogic;
  signal s0_axi_arready:  std_ulogic;
  signal s0_axi_rdata:    std_ulogic_vector(31 downto 0);
  signal s0_axi_rresp:    std_ulogic_vector(1 downto 0);
  signal s0_axi_rvalid:   std_ulogic;
  signal s0_axi_awready:  std_ulogic;
  signal s0_axi_wready:   std_ulogic;
  signal s0_axi_bresp:    std_ulogic_vector(1 downto 0);
  signal s0_axi_bvalid:   std_ulogic;
  signal sw:              std_ulogic_vector(3 downto 0);
  signal led:             std_ulogic_vector(3 downto 0);

begin

  process
  begin
    aclk <= '0';
    wait for 1 ns;
    aclk <= '1';
    wait for 1 ns;
  end process;

  dut: entity work.reg_axi(rtl)
  port map(
    aclk           => aclk,
    aresetn        => aresetn,
    s0_axi_araddr  => s0_axi_araddr,
    s0_axi_arprot  => s0_axi_arprot,
    s0_axi_arvalid => s0_axi_arvalid,
    s0_axi_rready  => s0_axi_rready,
    s0_axi_awaddr  => s0_axi_awaddr,
    s0_axi_awprot  => s0_axi_awprot,
    s0_axi_awvalid => s0_axi_awvalid,
    s0_axi_wdata   => s0_axi_wdata,
    s0_axi_wstrb   => s0_axi_wstrb,
    s0_axi_wvalid  => s0_axi_wvalid,
    s0_axi_bready  => s0_axi_bready,
    s0_axi_arready => s0_axi_arready,
    s0_axi_rdata   => s0_axi_rdata,
    s0_axi_rresp   => s0_axi_rresp,
    s0_axi_rvalid  => s0_axi_rvalid,
    s0_axi_awready => s0_axi_awready,
    s0_axi_wready  => s0_axi_wready,
    s0_axi_bresp   => s0_axi_bresp,
    s0_axi_bvalid  => s0_axi_bvalid,
    sw             => sw,
    led            => led
  );

  process
    variable rnd: rnd_generator;
  begin
    rnd.rnd_init(1, 1);
    aresetn <= '0';
    s0_axi_araddr  <= (others => '0');
    s0_axi_arprot  <= (others => '0');
    s0_axi_arvalid <= '0';
    s0_axi_rready  <= '0';
    s0_axi_awaddr  <= (others => '0');
    s0_axi_awprot  <= (others => '0');
    s0_axi_awvalid <= '0';
    s0_axi_wdata   <= (others => '0');
    s0_axi_wstrb   <= (others => '0');
    s0_axi_wvalid  <= '0';
    s0_axi_bready  <= '0';
    sw             <= (others => '0');
    for i in 1 to 10 loop
      wait until rising_edge(aclk);
    end loop;
    aresetn <= '1';
    for i in 1 to n loop
      wait until rising_edge(aclk);
      s0_axi_rready <= rnd.rnd_std_ulogic;
      s0_axi_bready <= rnd.rnd_std_ulogic;
      sw            <= rnd.rnd_std_ulogic_vector(4);
      if s0_axi_arvalid = '0' or s0_axi_arready = '1' then
        if rnd.rnd_integer(0, 9) = 9 then
          s0_axi_araddr <= rnd.rnd_std_ulogic_vector(12);
        else
          s0_axi_araddr(11 downto 4) <= (others => '0');
          s0_axi_araddr(3 downto 2)  <= std_ulogic_vector(to_unsigned(rnd.rnd_integer(0, 2), 2));
          s0_axi_araddr(1 downto 0)  <= rnd.rnd_std_ulogic_vector(2);
        end if;
        s0_axi_arprot  <= rnd.rnd_std_ulogic_vector(3);
        s0_axi_arvalid <= rnd.rnd_std_ulogic;
      end if;
      if s0_axi_awvalid = '0' or s0_axi_awready = '1' then
        if rnd.rnd_integer(0, 9) = 9 then
          s0_axi_awaddr <= rnd.rnd_std_ulogic_vector(12);
        else
          s0_axi_awaddr(11 downto 4) <= (others => '0');
          s0_axi_awaddr(3 downto 2)  <= std_ulogic_vector(to_unsigned(rnd.rnd_integer(0, 2), 2));
          s0_axi_awaddr(1 downto 0)  <= rnd.rnd_std_ulogic_vector(2);
        end if;
        s0_axi_awprot  <= rnd.rnd_std_ulogic_vector(3);
        s0_axi_awvalid <= rnd.rnd_std_ulogic;
      end if;
      if s0_axi_wvalid = '0' or s0_axi_wready = '1' then
        s0_axi_wdata  <= rnd.rnd_std_ulogic_vector(32);
        s0_axi_wstrb  <= rnd.rnd_std_ulogic_vector(4);
        s0_axi_wvalid <= rnd.rnd_std_ulogic;
      end if;
    end loop;
    stop;
  end process;

end architecture sim;

