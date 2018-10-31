library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_pkg.all;

entity reg_axi is
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
            s0_axi_bvalid:  out   std_ulogic;
            sw:             in    std_ulogic_vector(3 downto 0);
            led:            out   std_ulogic_vector(3 downto 0)
        );
end entity reg_axi;

architecture rtl of reg_axi is

    -- Type declaration for encoding the states
    type statesR is (IDLE, VALIDREQ, WAITACK);
    type statesW is (IDLE, VALIDREQ, WAITACK);

    -- Internal signals
    signal NextStateR, CurrStateR : statesR;
    signal NextStateW, CurrStateW : statesW;

    -- Signals modeling the ReadOnly and ReadWrite registers
    signal ro : std_ulogic_vector(31 downto 0);
    signal rw : std_ulogic_vector(31 downto 0);

    -- signals representing the upper part of the address
    signal addr_r_aligned : std_ulogic_vector(9 downto 0);
    signal addr_w_aligned : std_ulogic_vector(9 downto 0);

begin

    addr_r_aligned <= s0_axi_araddr(11 downto 2);
    addr_w_aligned <= s0_axi_awaddr(11 downto 2);

    -- process for incrementing the read only register by one at each clock cycle and saturating when reached the maximum value
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0'  then
                ro <=  (others => '0');
            else
                if ro /= "11111111111111111111111111111111" then
                    ro <= std_ulogic_vector(to_unsigned(to_integer(unsigned( ro )) + 1, 32));
                else
                    ro <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- Process for driving read byte using the switches
    process (sw, ro, rw)
    begin
        case sw is
            when "0000" =>
                led <= ro(3 downto 0);
            when "0001" =>
                led <= ro(7 downto 4);
            when "0010" => 
                led <= ro(11 downto 8);
            when "0011" =>
                led <= ro(15 downto 12);
            when "0100" =>
                led <= ro(19 downto 16);
            when "0101" =>
                led <= ro(23 downto 20);
            when "0110" =>
                led <= ro(27 downto 24);
            when "0111" =>
                led <= ro(31 downto 28);
            when "1000" =>
                led <= rw(3 downto 0);
            when "1001" =>
                led <= rw(7 downto 4);
            when "1010" => 
                led <= rw(11 downto 8);
            when "1011" =>
                led <= rw(15 downto 12);
            when "1100" =>
                led <= rw(19 downto 16);
            when "1101" =>
                led <= rw(23 downto 20);
            when "1110" =>
                led <= rw(27 downto 24);
            when "1111" =>
                led <= rw(31 downto 28);
            when others =>
                led <= "1010";
        end case;

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

    -- Process for driving the ro signal to the output rdata    
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                s0_axi_rdata <=  (others => '0');
                s0_axi_rresp <= (others => '0');
            else
                if s0_axi_arvalid = '1' and CurrStateR = IDLE then
                    if addr_r_aligned = "0000000000" then
                        s0_axi_rresp <= axi_resp_okay;
                        s0_axi_rdata <= ro;
                    elsif addr_r_aligned = "0000000001" then
                        s0_axi_rdata <= rw;
                        s0_axi_rresp <= axi_resp_okay;
                    else
                        s0_axi_rdata <= (others => '0');
                        s0_axi_rresp <= axi_resp_decerr;
                    end if;
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


    -- writing on the register
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                rw <= (others => '0');
                s0_axi_bresp <= (others => '0');
            else
                if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and CurrStateW = IDLE then
                    if addr_w_aligned = "0000000001" then
                        s0_axi_bresp <= axi_resp_okay;
                        if s0_axi_wstrb(0) = '1' then
                            rw(7 downto 0) <= s0_axi_wdata(7 downto 0); 
                        end if;
                        if s0_axi_wstrb(1) = '1' then
                            rw(15 downto 8) <= s0_axi_wdata(15 downto 8); 
                        end if;
                        if s0_axi_wstrb(2) = '1' then
                            rw(23 downto 16) <= s0_axi_wdata(23 downto 16); 
                        end if;
                        if s0_axi_wstrb(3) = '1' then
                            rw(31 downto 24) <= s0_axi_wdata(31 downto 24); 
                        end if;
                    elsif  addr_w_aligned = "0000000000"then                        
                        s0_axi_bresp <= axi_resp_slverr;
                        s0_axi_bresp <= axi_resp_slverr;
                    else
                        s0_axi_bresp <= axi_resp_decerr;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
