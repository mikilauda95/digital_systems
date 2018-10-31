library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity dht11 is
  generic(
    value: bit_vector(39 downto 0); -- Read value
    init:  natural
  );
  port(
    data: inout std_logic
  );
end entity dht11;

architecture beh of dht11 is

  signal data_in: x01;

  constant initl_min: time := (init - init / 10) * 1 us; -- Minimum of init low phase
  constant initl_max: time := (init + init / 10) * 1 us; -- Maximum of init low phase
  constant inith_min: time := 20 us;       -- Minimum of init high phase
  constant inith_max: time := 40 us;       -- Maximum of init high phase
  constant ackl_min:  time := 80 us;       -- Minimum of acknowledge low phase
  constant ackl_max:  time := 80 us;       -- Maximum of acknowledge low phase
  constant ackh_min:  time := 80 us;       -- Minimum of acknowledge high phase
  constant ackh_max:  time := 80 us;       -- Maximum of acknowledge high phase
  constant bit0l_min: time := 50 us;       -- Minimum of bit 0 low phase
  constant bit0l_max: time := 50 us;       -- Maximum of bit 0 low phase
  constant bit0h_min: time := 26 us;       -- Minimum of bit 0 high phase
  constant bit0h_max: time := 28 us;       -- Maximum of bit 0 high phase
  constant bit1l_min: time := 50 us;       -- Minimum of bit 1 low phase
  constant bit1l_max: time := 50 us;       -- Maximum of bit 1 low phase
  constant bit1h_min: time := 70 us;       -- Minimum of bit 1 high phase
  constant bit1h_max: time := 70 us;       -- Maximum of bit 1 high phase
  constant eotl_min: time  := 50 us;       -- Minimum of end-of-transfer low phase
  constant eotl_max: time  := 50 us;       -- Maximum of end-of-transfer low phase

begin

  data_in <= to_x01(data);

  process
    variable seed1: positive := 1;
    variable seed2: positive := 1;
    variable rnd:   real;
    variable t:     time;
    variable delta: time;
  begin
    data   <= 'Z';
    wait until falling_edge(data_in);
    t := now;
    wait until rising_edge(data_in);
    delta := now - t;
    if initl_min <= delta and delta <= initl_max then
      uniform(seed1, seed2, rnd);
      delta := inith_min + rnd * (inith_max - inith_min);
      wait for delta;
      data <= '0';
      uniform(seed1, seed2, rnd);
      delta := ackl_min + rnd * (ackl_max - ackl_min);
      wait for delta;
      data <= 'Z';
      uniform(seed1, seed2, rnd);
      delta := ackh_min + rnd * (ackh_max - ackh_min);
      wait for delta;
      for b in 39 downto 0 loop
        if value(b) = '0' then
          data <= '0';
          uniform(seed1, seed2, rnd);
          delta := bit0l_min + rnd * (bit0l_max - bit0l_min);
          wait for delta;
          data <= 'Z';
          uniform(seed1, seed2, rnd);
          delta := bit0h_min + rnd * (bit0h_max - bit0h_min);
          wait for delta;
        else
          data <= '0';
          uniform(seed1, seed2, rnd);
          delta := bit1l_min + rnd * (bit1l_max - bit1l_min);
          wait for delta;
          data <= 'Z';
          uniform(seed1, seed2, rnd);
          delta := bit1h_min + rnd * (bit1h_max - bit1h_min);
          wait for delta;
        end if;
      end loop;
      data <= '0';
      uniform(seed1, seed2, rnd);
      delta := eotl_min + rnd * (eotl_max - eotl_min);
      wait for delta;
      data <= 'Z';
    end if;
  end process;

end architecture beh;

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.axi_pkg.all;
use work.rnd_pkg.all;

entity dht11_ctrl_axi_sim is
  generic(
    n:     positive := 10;
    value: bit_vector(39 downto 0) := X"320C192178";
    freq:  positive range 1 to 1000 := 2;
    init:  natural := 200;
    tmax:  natural := 300;
    cmax:  natural := 42
  ) ;
end entity dht11_ctrl_axi_sim;

architecture sim of dht11_ctrl_axi_sim is

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
  signal data:            std_logic;
  signal dso:             std_ulogic;

  signal timeout:  boolean;

  constant period: time := (1.0e3 * 1 ns) / real(freq);

begin

  process
  begin
    aclk <= '0';
    wait for period / 2;
    aclk <= '1';
    wait for period / 2;
  end process;

  -- Tri-state buffer.
  data <= 'H' when not timeout else '0';

  u_dht11: entity work.dht11(beh)
    generic map(
      value => value,
      init  => init
    )
    port map(
      data => data
    );

  dut: entity work.dht11_ctrl_axi(rtl)
  generic map(
    freq => freq,
    init => init,
    tmax => tmax,
    cmax => cmax
  )
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
    data           => data
  );

  process
    variable t: time;
  begin
    wait until rising_edge(aclk) and aresetn = '1';
    loop
      wait until falling_edge(data);
      t := now;
      wait until rising_edge(data);
      if now - t >= (init - init / 10) * 1 us then
        wait until rising_edge(aclk);
        dso <= '1';
        wait until rising_edge(aclk);
        dso <= '0';
      end if;
    end loop;
  end process;

  process
    variable rnd:         rnd_generator;
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
    for i in 1 to 10 loop
      wait until rising_edge(aclk);
    end loop;
    aresetn <= '1';
    loop
      wait until rising_edge(aclk);
      exit when dso = '1';
      s0_axi_rready <= rnd.rnd_std_ulogic;
      s0_axi_bready <= rnd.rnd_std_ulogic;
      if s0_axi_arvalid = '0' or s0_axi_arready = '1' then
        if rnd.rnd_integer(0, 9) = 9 then
          s0_axi_araddr <= rnd.rnd_std_ulogic_vector(12);
        else
          s0_axi_araddr(11 downto 3) <= (others => '0');
          s0_axi_araddr(2)           <= rnd.rnd_std_ulogic;
          s0_axi_araddr(1 downto 0)  <= rnd.rnd_std_ulogic_vector(2);
        end if;
        s0_axi_arprot  <= rnd.rnd_std_ulogic_vector(3);
        s0_axi_arvalid <= rnd.rnd_std_ulogic;
      end if;
      if s0_axi_awvalid = '0' or s0_axi_awready = '1' then
        if rnd.rnd_integer(0, 9) = 9 then
          s0_axi_awaddr <= rnd.rnd_std_ulogic_vector(12);
        else
          s0_axi_awaddr(11 downto 3) <= (others => '0');
          s0_axi_awaddr(2)           <= rnd.rnd_std_ulogic;
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
    s0_axi_rready  <= '1';
    s0_axi_bready  <= '1';
    s0_axi_arvalid <= '1';
    s0_axi_awvalid <= '1';
    s0_axi_wvalid  <= '1';
    loop
      if s0_axi_arvalid = '1' and s0_axi_arready = '1' then
        s0_axi_arvalid <= '0';
      end if;
      if s0_axi_awvalid = '1' and s0_axi_awready = '1' then
        s0_axi_awvalid <= '0';
      end if;
      if s0_axi_wvalid = '1' and s0_axi_wready = '1' then
        s0_axi_wvalid <= '0';
      end if;
      wait until rising_edge(aclk);
      exit when s0_axi_arvalid = '0' and s0_axi_awvalid = '0' and s0_axi_wvalid = '0';
    end loop;
    for i in 1 to n - 1 loop
      s0_axi_arvalid <= '1';
      s0_axi_araddr  <= X"000";
      wait until rising_edge(aclk) and s0_axi_arready = '1';
      s0_axi_araddr  <= X"004";
      wait until rising_edge(aclk) and s0_axi_arready = '1';
      s0_axi_arvalid <= '0';
      wait until rising_edge(aclk) and dso = '1';
    end loop;
    timeout        <= true;
    wait for init * 42 us;
    wait until rising_edge(aclk);
    s0_axi_arvalid <= '1';
    s0_axi_araddr  <= X"000";
    wait until rising_edge(aclk) and s0_axi_arready = '1';
    s0_axi_araddr  <= X"004";
    wait until rising_edge(aclk) and s0_axi_arready = '1';
    s0_axi_arvalid <= '0';
    for i in 1 to 10 loop
      wait until rising_edge(aclk);
    end loop;
    stop;
  end process;

end architecture sim;

