library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use WORK.sha256_pack.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
use std.textio.ALL;



entity sha256_wrapsim is
    end entity sha256_wrapsim;


architecture behav of sha256_wrapsim is


    signal s_aclk : std_ulogic := '0';	
    signal s_aresetn : std_ulogic := '0';
    signal FINAL_HASH : word_vect(1 to 8) := (others => "00000000000000000000000000000000");
    signal status_reg : word;

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



    --constant blocks : word_vect(15 downto 0):=
    --(
    --X"61626380", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
    --X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000018"
    --);
    constant new_msg_status    : std_ulogic_vector(31 downto 0) := "00000000000000000000000000000010";
    constant not_new_msg_status    : std_ulogic_vector(31 downto 0) := "00000000000000000000000000000000";

    constant block1 : word_vect(1 to 16) :=

    (X"61626364", X"62636465", X"63646566", X"64656667", X"65666768", X"66676869", X"6768696a", X"68696a6b",
    X"696a6b6c", X"6a6b6c6d", X"6b6c6d6e", X"6c6d6e6f", X"6d6e6f70", X"6e6f7071", X"80000000", X"00000000");

    constant block2 : word_vect(1 to 16) :=

    (X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"000001c0");

    --constant block1 : word_vect(1 to 16) :=

    --(X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
    --X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");

    --constant block2 : word_vect(1 to 16) :=

    --(X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
    --X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");
    constant blocks : message_t(1 to 2) := (block1, block2);

--constant blocks : message_t(1 to 2):=
--(
--(X"61626364", X"62636465", X"63646566", X"64656667", X"65666768", X"66676869", X"6768696a", X"68696a6b",
--X"696a6b6c", X"6a6b6c6d", X"6b6c6d6e", X"6c6d6e6f", X"6d6e6f70", X"6e6f7071", X"80000000", X"00000000"),

--(X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
--X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"000001c0")
--);


begin

    sha256_wrap_0 : entity work.sha256_wrap(rtl)
    port map (
                 aclk => s_aclk,
                 aresetn => s_aresetn,
                 s0_axi_araddr => s0_axi_araddr,
                 s0_axi_arprot => s0_axi_arprot,
                 s0_axi_arvalid => s0_axi_arvalid,
                 s0_axi_rready => s0_axi_rready,
                 s0_axi_awaddr => s0_axi_awaddr,
                 s0_axi_awprot => s0_axi_awprot,
                 s0_axi_awvalid => s0_axi_awvalid,
                 s0_axi_wdata => s0_axi_wdata,
                 s0_axi_wstrb => s0_axi_wstrb,
                 s0_axi_wvalid => s0_axi_wvalid,
                 s0_axi_bready => s0_axi_bready,
                 s0_axi_arready => s0_axi_arready,
                 s0_axi_rdata => s0_axi_rdata,
                 s0_axi_rresp => s0_axi_rresp,
                 s0_axi_rvalid => s0_axi_rvalid,
                 s0_axi_awready => s0_axi_awready,
                 s0_axi_wready => s0_axi_wready,
                 s0_axi_bresp => s0_axi_bresp,
                 s0_axi_bvalid => s0_axi_bvalid
             );


    process
    begin
        s_aclk <= '0';
        wait for 1 ns;
        s_aclk <= '1';
        wait for 1 ns;
    end process;

    process
        variable address : std_ulogic_vector(11 downto 0) := "000000001000";
    begin
        for i in 1 to 10 loop
            wait until rising_edge(s_aclk);
        end loop;
        s_aresetn <= '1';
        --wait until rising_edge(s_aclk);

        --s_new_mess <= '1';

        --Write status registe to notify it is the first block
        s0_axi_awaddr <= "000000000100";
        s0_axi_wdata <= new_msg_status;
        s0_axi_wstrb <= (others => '1');
        s0_axi_awvalid <= '1';
        s0_axi_wvalid <= '1';
        wait until rising_edge(s_aclk);
        s0_axi_bready <= '1';
        s0_axi_awvalid <= '0';
        s0_axi_wvalid <= '0';
        wait until rising_edge(s_aclk);
        ----------

        for i in blocks'range loop
            for j in blocks(i)'range loop
                --write at address 0
                s0_axi_awaddr <= (others => '0');
                s0_axi_wdata <= blocks(i)(j);
                s0_axi_wstrb <= (others => '1');
                s0_axi_awvalid <= '1';
                s0_axi_wvalid <= '1';
                wait until rising_edge(s_aclk);
                s0_axi_bready <= '1';
                s0_axi_awvalid <= '0';
                s0_axi_wvalid <= '0';
                --wait for some clock cycles before next data
                for i in 0 to 10 loop
                    wait until rising_edge(s_aclk);
                end loop;
            end loop;

            loop
                s0_axi_araddr <= "000000000100";
                s0_axi_arvalid <= '1';
                wait until rising_edge(s_aclk);
                wait until s0_axi_rvalid = '1';
                s0_axi_rready <= '1';
                s0_axi_arvalid <= '0';
                status_reg <= s0_axi_rdata;
                wait until rising_edge(s_aclk);
                exit when status_reg(0) = '0';
            end loop;

            if i = 1 then
                -- New message is false now
                s0_axi_awaddr <= "000000000100";
                s0_axi_wdata <= not_new_msg_status;
                s0_axi_wstrb <= (others => '1');
                s0_axi_awvalid <= '1';
                s0_axi_wvalid <= '1';
                wait until rising_edge(s_aclk);
                s0_axi_bready <= '1';
                s0_axi_awvalid <= '0';
                s0_axi_wvalid <= '0';
                wait until rising_edge(s_aclk);
            end if;
            -----------
            --s_M_in <= (others => '1');

            --wait until it is not busy anymore
        end loop;

        -- read the hash
        for i in 1 to 8 loop
                s0_axi_araddr <= address;
                s0_axi_arvalid <= '1';
                wait until rising_edge(s_aclk);
                address := std_ulogic_vector(unsigned(address) + 4);
                wait until s0_axi_rvalid = '1';
                s0_axi_rready <= '1';
                s0_axi_arvalid <= '0';
                FINAL_HASH(i) <= s0_axi_rdata;
        end loop;

        for i in 1 to 100 loop
            wait until rising_edge(s_aclk);
        end loop;
    end process;





end behav;
