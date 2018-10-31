--library unisim;
--use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_pkg.all;
use work.sha256_pack.all;

entity sha256_wrap is
    port(
            aclk:           in    std_ulogic;
            aresetn:        in    std_ulogic;
            s0_axi_araddr:  in    std_ulogic_vector(11 downto 0);
            s0_axi_arprot:  in    std_ulogic_vector(2 downto 0);
            s0_axi_arvalid: in    std_ulogic;
            s0_axi_rready:  in    std_ulogic;
            s0_axi_awaddr:  in    std_ulogic_vector(11 downto 0);
            s0_axi_awprot:  in    std_ulogic_vector(2 downto 0);
            s0_axi_awvalid: in    std_ulogic;
            s0_axi_wdata:   in    std_ulogic_vector(31 downto 0);
            s0_axi_wstrb:   in    std_ulogic_vector(3 downto 0);
            s0_axi_wvalid:  in    std_ulogic;
            s0_axi_bready:  in    std_ulogic;
            s0_axi_arready: out   std_ulogic;
            s0_axi_rdata:   out   std_ulogic_vector(31 downto 0);
            s0_axi_rresp:   out   std_ulogic_vector(1 downto 0);
            s0_axi_rvalid:  out   std_ulogic;
            s0_axi_awready: out   std_ulogic;
            s0_axi_wready:  out   std_ulogic;
            s0_axi_bresp:   out   std_ulogic_vector(1 downto 0);
            s0_axi_bvalid:  out   std_ulogic
        );
end entity sha256_wrap;

architecture rtl of sha256_wrap is

    -- Type declaration for encoding the states for the axi lite
    type statesR is (IDLE, VALIDREQ, WAITACK);
    type statesW is (IDLE, VALIDREQ, WAITACK);

    -- Internal signals
    signal NextStateR, CurrStateR : statesR;
    signal NextStateW, CurrStateW : statesW;

    -- signals representing the upper part of the address
    signal addr_r_aligned : std_ulogic_vector(9 downto 0);
    signal addr_w_aligned : std_ulogic_vector(9 downto 0);



    -- Useful signals
    signal data_in:    std_ulogic;
    signal data_drv:   std_ulogic;
    signal data_drvn:  std_ulogic;
    signal s_new_data, new_data: std_ulogic;
    signal s_busy:       std_ulogic;
    signal err:        std_ulogic;
    signal perr_reg:   std_ulogic;
    signal first_start:std_ulogic;
    signal do:         std_ulogic_vector(39 downto 0);
    signal status_reg: std_ulogic_vector(31 downto 0);
    signal s_HASH:		word_vect(1 to 8);
    signal s_M_in:		word;
    signal s_new_mess:	std_ulogic;

begin

    s_new_mess <= status_reg(1);


    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                new_data <= '0';
            else
                new_data <= s_new_data;
            end if;
        end if;
    end process;

    s_new_data <= '1' when addr_w_aligned = "0000000000" and s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and CurrStateW = IDLE else 
                  '0';

    status_reg(31 downto 2) <= (others => '0');

    addr_r_aligned <= s0_axi_araddr(11 downto 2);
    addr_w_aligned <= s0_axi_awaddr(11 downto 2);

    sha256_block_0 : entity work.sha256_block
    port map (
                 clk   => aclk,
                 aresetn   => aresetn,
                 new_data  => new_data,
                 new_mess  => s_new_mess,
                 M_in  => s_M_in,
                 HASH  => s_HASH,
                 busy  => s_busy
             );

    -- process for driving the control status register 2 LSBs
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                status_reg(0) <= '0';
            else
                status_reg(0) <= s_busy;
            end if;
        end if;
    end process;

    -- READ OPERATION FSM

    -- States change for read
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                CurrStateR <= IDLE;
            else
                CurrStateR <= NextStateR;
            end if;
        end if;
    end process;

    --Compute next state for reads
    process (CurrStateR, s0_axi_arvalid, s0_axi_rready)
    begin
        case CurrStateR is
            when IDLE =>
                if s0_axi_arvalid = '0' then
                    NextStateR <= IDLE;
                elsif s0_axi_arvalid = '1' then
                    NextStateR <= VALIDREQ;
                end if;
            when VALIDREQ =>
                if s0_axi_rready = '1' then
                    NextStateR <= IDLE;
                elsif s0_axi_rready = '0' then
                    NextStateR <= WAITACK;
                end if;
            when WAITACK =>
                if s0_axi_rready = '1' then
                    NextStateR <= IDLE;
                elsif s0_axi_rready = '0' then
                    NextStateR <= WAITACK;
                end if;
        end case;
    end process;

    -- Compute output from states for reads
    process (CurrStateR)
    begin
        case CurrStateR is
            when IDLE =>
                s0_axi_arready <= '0';
                s0_axi_rvalid <= '0';
            when VALIDREQ =>
                s0_axi_arready <= '1';
                s0_axi_rvalid <= '1';
            when WAITACK =>
                s0_axi_arready <= '0';
                s0_axi_rvalid <= '1';
        end case;
    end process;

    -- Process for driving the status and data signal to the output rdata
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                s0_axi_rdata <=  (others => '0');
                s0_axi_rresp <= (others => '0');
            else
                if s0_axi_arvalid = '1' and CurrStateR = IDLE then
                    case addr_r_aligned is
                        when   "0000000001" => 
                            s0_axi_rdata <= status_reg;
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000000010" => 
                            s0_axi_rdata <= s_HASH(1);
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000000011" => 
                            s0_axi_rdata <= s_HASH(2);
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000000100" => 
                            s0_axi_rdata <= s_HASH(3);
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000000101" => 
                            s0_axi_rdata <= s_HASH(4);
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000000110" => 
                            s0_axi_rdata <= s_HASH(5);
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000000111" => 
                            s0_axi_rdata <= s_HASH(6);
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000001000" => 
                            s0_axi_rdata <= s_HASH(7);
                            s0_axi_rresp <= axi_resp_okay;
                        when   "0000001001" => 
                            s0_axi_rdata <= s_HASH(8);
                            s0_axi_rresp <= axi_resp_okay;
                        when others =>
                            s0_axi_rdata <= (others => '0');
                            s0_axi_rresp <= axi_resp_decerr;
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- WRITE OPERATION FSM

    -- States change for write
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                CurrStateW <= IDLE;
            else
                CurrStateW <= NextStateW;
            end if;
        end if;
    end process;

    -- Compute next state for writes
    process (CurrStateW, s0_axi_awvalid, s0_axi_wvalid, s0_axi_bready)
    begin
        case CurrStateW is
            when IDLE =>
                if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then
                    NextStateW <= VALIDREQ;
                else
                    NextStateW <= IDLE;
                end if;
            when VALIDREQ =>
                if s0_axi_bready = '1' then
                    NextStateW <= IDLE;
                elsif s0_axi_bready = '0' then
                    NextStateW <= WAITACK;
                end if;
            when WAITACK =>
                if s0_axi_bready = '1' then
                    NextStateW <= IDLE;
                elsif s0_axi_bready = '0' then
                    NextStateW <= WAITACK;
                end if;
        end case;
    end process;

    -- Compute output from state for writes
    process (CurrStateW)
    begin
        case CurrStateW is
            when IDLE =>
                s0_axi_awready <= '0';
                s0_axi_wready <= '0';
                s0_axi_bvalid <= '0';
            when VALIDREQ =>
                s0_axi_awready <= '1';
                s0_axi_wready <= '1';
                s0_axi_bvalid <= '1';
            when WAITACK =>
                s0_axi_awready <= '0';
                s0_axi_wready <= '0';
                s0_axi_bvalid <= '1';
        end case;
    end process;

    -- writing on the register at address 2 and 1
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                s0_axi_bresp <= (others => '0');
                status_reg(1) <= '0';
            else
                if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and CurrStateW = IDLE then
                    if  addr_w_aligned = "0000000000" then
                        s_M_in <= std_ulogic_vector(s0_axi_wdata);
                        s0_axi_bresp <= axi_resp_okay;
                    elsif addr_w_aligned = "0000000001" then 
                        status_reg(1) <= s0_axi_wdata(1);
                        s0_axi_bresp <= axi_resp_okay;
                    else
                        s0_axi_bresp <= axi_resp_decerr;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
