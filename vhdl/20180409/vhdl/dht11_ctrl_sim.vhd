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
use ieee.math_real.all;

entity dht11_ctrl_sim is
  generic(
    value: bit_vector(39 downto 0) := "1011010001010100101001010010110101000010";
    freq:  positive range 1 to 1000 := 2;
    init:  natural := 200;
    tmax:  natural := 1000;
    cmax:  natural := 42
  ) ;
end entity dht11_ctrl_sim;

architecture sim of dht11_ctrl_sim is

    signal data:     std_logic;
    signal clk:      std_ulogic;
    signal sresetn:  std_ulogic;
    signal start:    std_ulogic;
    signal data_in:  std_ulogic;
    signal data_drv: std_ulogic;
    signal busy:     std_ulogic;
    signal err:      std_ulogic;
    signal do:       std_ulogic_vector(39 downto 0);
    signal timeout:  boolean;

    constant period: time := (1.0e3 * 1 ns) / real(freq);

begin

  process
  begin
    clk <= '0';
    wait for period / 2.0;
    clk <= '1';
    wait for period / 2.0;
  end process;

  -- Tri-state buffer.
  data <= '0' when data_drv = '1' else 'H';

  -- Convert data line to 'X', '0', '1'. Add delay to force protocol error if timeout.
  data_in <= to_x01(data) when not timeout else '1';

  u_dht11_ctrl: entity work.dht11_ctrl(rtl)
    generic map(
      freq    => freq,
      init    => init,
      tmax    => tmax,
      cmax    => cmax
    )
    port map(
      clk      => clk,
      sresetn  => sresetn,
      data_in  => data_in,
      start    => start,
      data_drv => data_drv,
      busy     => busy,
      err      => err,
      do       => do
    );

  u_dht11: entity work.dht11(beh)
    generic map(
      value => value,
      init  => init
    )
    port map(
      data           => data
    );

  process
    constant nmax:  positive := 1000;
    variable seed1: positive := 1;
    variable seed2: positive := 1;
    variable rnd:   real;
  begin
    sresetn <= '0';
    start   <= '0';
    timeout <= false;
    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    sresetn <= '1';
    wait until rising_edge(clk) and busy = '0';
    for n in 1 to nmax loop
      uniform(seed1, seed2, rnd);
      for i in 0 to integer(rnd * 10.0) loop
        wait until rising_edge(clk);
      end loop;
      start <= '1';
      timeout <= n = nmax;
      wait until rising_edge(clk);
      start <= '0';
      wait until rising_edge(clk) and busy = '0';
    end loop;
    wait;
  end process;

end architecture sim;

