-- DTH11 controller wrapper, AXI lite version, top level

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_pkg.all;

entity dht11_ctrl_axi is
    generic(
    freq:    positive range 1 to 1000;
    init:    natural;
    tmax:    natural;
    cmax:    natural
);
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
        data:           inout std_logic
    );
end entity dht11_ctrl_axi;

architecture rtl of dht11_ctrl_axi is

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
    signal start:      std_ulogic;
    signal busy:       std_ulogic;
    signal err:        std_ulogic;
    signal perr_reg:   std_ulogic;
    signal first_start:std_ulogic;
    signal do:         std_ulogic_vector(39 downto 0);
    signal data_reg:   std_ulogic_vector(31 downto 0);
    signal status_reg: std_ulogic_vector(31 downto 0);
    signal tocheck:    std_ulogic_vector(7 downto 0);

begin

    -- Assigned the 28 MSBs to 0 as they are not used
    status_reg(31 downto 4) <= (others => '0');
    data_drvn <= not data_drv;
    tocheck <= std_ulogic_vector(unsigned(do(39 downto 32)) + unsigned(do(31 downto 24)) + unsigned(do(23 downto 16)) + unsigned(do(15 downto 8))); 

    -- instance of the dht11_ctl controller
    dht11_ctrl_0 : entity work.dht11_ctrl(rtl)
    generic map (
                    freq => freq,
                    init => init,
                    tmax => tmax,
                    cmax => cmax
                )
    port map (
                 clk => aclk,
                 sresetn => aresetn,
                 data_in => data_in,
                 start => start,
                 data_drv => data_drv,
                 busy => busy,
                 err => err,
                 do => do
             );


    u1 : iobuf
    generic map (
                    drive      => 12,
                    iostandard => "lvcmos33",
                    slew       => "slow")
    port map (
                 o  => data_in,
                 io => data,
                 i  => '0',
                 t  => data_drvn
             );

-- process for checking the first start after the reset
process (aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
           first_start <= '0' ;
        end if;
        if first_start = '0' then
             if start = '1'  then
                 first_start <= '1';
             end if;
        end if;
    end if;
end process;


    -- process for storing the error protocol in an internal register   
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                perr_reg <= '0';
            else
                if err = '1' then
                    perr_reg <= '1'; 
                elsif start = '1' then
                    perr_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    -- process for storing the output of the controller to the internal data register
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                data_reg <= (others => '0');
            else
                if start = '1' then
                    data_reg <= do(39 downto 8); 
                end if;
            end if;
        end if;
    end process;

    -- process for driving the control status register 4 LSBs
    process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                status_reg(3 downto 0) <= (others => '0');
            else
                status_reg(0) <= busy;
                if start = '1' then
                    status_reg(2) <= perr_reg;
                    if first_start = '0' then
                        status_reg(1) <= '0'; 
                    else
                        status_reg(1) <= '1';
                    end if;
                    if tocheck /= do(7 downto 0) then
                        status_reg(3) <= '1';
                    else
                        status_reg(3) <= '0';
                    end if;
                    
                end if;
            end if;
        end if;
    end process;

process (busy, status_reg(0))
begin
        if busy = '0' and status_reg(0) = '1' then
            start <= '1';
        else
            start <= '0';
        end if;
end process;


    addr_r_aligned <= s0_axi_araddr(11 downto 2);
    addr_w_aligned <= s0_axi_awaddr(11 downto 2);

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
                    if addr_r_aligned = "0000000000" then
                        s0_axi_rresp <= axi_resp_okay;
                        s0_axi_rdata <= data_reg;
                    elsif addr_r_aligned = "0000000001" then
                        s0_axi_rdata <= status_reg;
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
                s0_axi_bresp <= (others => '0');
            else
                if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and CurrStateW = IDLE then
                    if  addr_w_aligned = "0000000000" or addr_w_aligned = "0000000001"then                        
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
