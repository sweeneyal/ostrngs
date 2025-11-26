-----------------------------------------------------------------------------------------------------------------------
-- entity: TrngTestbedCore
--
-- library: ostrngs
--
-- description:
--       This file is the fundamental core of the TrngTestbed. It handles the AXI interfaces, as well as the internal
--       logic contained within the TrngSandbox, such as the PLL, the TRNG selector, and the data collector FIFO. This
--       is where the system-level registers are defined and managed, and a translation interface between the AXI 
--       signals and management of the system resources occurs in this file.
--
-----------------------------------------------------------------------------------------------------------------------


library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngTestbedCore is
    generic (
        -- Sets the total number of entropy sources to instantiate
        cNumEntropySources    : positive range 1 to 8 := 8;
        -- Provides a mechanism to instantiate various unique entropy sources
        cEntropySource00      : string := "MeshCoupledXor";
        cEntropySource01      : string := "MeshCoupledXor";
        cEntropySource02      : string := "MeshCoupledXor";
        cEntropySource03      : string := "MeshCoupledXor";
        cEntropySource04      : string := "MeshCoupledXor";
        cEntropySource05      : string := "MeshCoupledXor";
        cEntropySource06      : string := "MeshCoupledXor";
        cEntropySource07      : string := "MeshCoupledXor";
        -- Fifo depth in groups of samples
        cFifoDepth            : positive := 1024;
        -- Fifo width in samples
        cFifoWidth            : positive := 16;
        -- Memory access generic for default address samples are stored at
        cMemoryDefaultAddress : std_logic_vector(31 downto 0) := x"FF000000"
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- interrupt signalling end of data collection, set high for 5 cc
        o_ttb_intr : out std_logic;

        ----------------------------------------------------------------------
        -- Processor-To-TrngTestbed AXI Lite Interface
        ----------------------------------------------------------------------
        -- peripheral axi write address channel
        i_s_axi_awaddr  : in std_logic_vector(9 downto 0);
        -- peripheral axi write address protection level
        i_s_axi_awprot  : in std_logic_vector(2 downto 0);
        -- peripheral axi write address bus valid signal
        i_s_axi_awvalid : in std_logic;
        -- peripheral axi write address bus ready-to-accept signal
        o_s_axi_awready : out std_logic;

        -- peripheral axi write data channel
        i_s_axi_wdata   : in std_logic_vector(31 downto 0);
        -- peripheral axi write strobe channel (indicates valid bytes in word)
        i_s_axi_wstrb   : in std_logic_vector(3 downto 0);
        -- peripheral axi write bus valid signal
        i_s_axi_wvalid  : in std_logic;
        -- peripheral axi write ready-to-accept signal
        o_s_axi_wready  : out std_logic;

        -- peripheral axi write response indicator
        o_s_axi_bresp   : out std_logic_vector(1 downto 0);
        -- peripheral axi write response valid signal
        o_s_axi_bvalid  : out std_logic;
        -- peripheral axi write response ready-to-accept signal
        i_s_axi_bready  : in std_logic;

        -- peripheral axi read address channel
        i_s_axi_araddr  : in std_logic_vector(9 downto 0);
        -- peripheral axi read address protection level
        i_s_axi_arprot  : in std_logic_vector(2 downto 0);
        -- peripheral axi read address valid signal
        i_s_axi_arvalid : in std_logic;
        -- peripheral axi read address ready-to-accept signal
        o_s_axi_arready : out std_logic;

        -- peripheral axi read data channel
        o_s_axi_rdata   : out std_logic_vector(31 downto 0);
        -- peripheral axi read response indicator
        o_s_axi_rresp   : out std_logic_vector(1 downto 0);
        -- peripheral axi read valid signal
        o_s_axi_rvalid  : out std_logic;
        -- peripheral axi read ready signal
        i_s_axi_rready  : in std_logic;

        ----------------------------------------------------------------------
        -- TrngTestbed-To-DdrRam AXI Lite Interface
        ----------------------------------------------------------------------
        -- master axi write address channel
        o_m_axi_awaddr  : out std_logic_vector(31 downto 0);
        -- master axi write address protection level
        o_m_axi_awprot  : out std_logic_vector(2 downto 0);
        -- master axi write address bus valid signal
        o_m_axi_awvalid : out std_logic;
        -- master axi write address bus ready-to-accept signal
        i_m_axi_awready : in std_logic;

        -- master axi write data channel
        o_m_axi_wdata   : out std_logic_vector(8 * cFifoWidth - 1 downto 0);
        -- master axi write strobe channel (indicates valid bytes in word)
        o_m_axi_wstrb   : out std_logic_vector(cFifoWidth - 1 downto 0);
        -- master axi write bus valid signal
        o_m_axi_wvalid  : out std_logic;
        -- master axi write ready-to-accept signal
        i_m_axi_wready  : in std_logic;

        -- master axi write response indicator
        i_m_axi_bresp   : in std_logic_vector(1 downto 0);
        -- master axi write response valid signal
        i_m_axi_bvalid  : in std_logic;
        -- master axi write response ready-to-accept signal
        o_m_axi_bready  : out std_logic;

        -- master axi read address channel
        o_m_axi_araddr  : out std_logic_vector(31 downto 0);
        -- master axi read address protection level
        o_m_axi_arprot  : out std_logic_vector(2 downto 0);
        -- master axi read address valid signal
        o_m_axi_arvalid : out std_logic;
        -- master axi read address ready-to-accept signal
        i_m_axi_arready : in std_logic;

        -- master axi read data channel
        i_m_axi_rdata   : in std_logic_vector(8 * cFifoWidth - 1 downto 0);
        -- master axi read response indicator
        i_m_axi_rresp   : in std_logic_vector(1 downto 0);
        -- master axi read valid signal
        i_m_axi_rvalid  : in std_logic;
        -- master axi read ready signal
        o_m_axi_rready  : out std_logic
    );
end entity TrngTestbedCore;

architecture rtl of TrngTestbedCore is
    constant cDataWidth_B : positive := 1;
    type axi_state_t is (IDLE, WRITE_SEQUENCE, WRITE_RESPONSE, READ_SEQUENCE, READ_RESPONSE);
    signal axi_state : axi_state_t := IDLE;

    signal rng_addr   : std_logic_vector(7 downto 0) := (others => '0');
    signal rng_data   : std_logic_vector(8 * cDataWidth_B - 1 downto 0) := (others => '0');
    signal rng_dvalid : std_logic := '0';

    signal fifo_pop     : std_logic := '0';
    signal fifo_pop_reg : std_logic := '0';
    signal fifo_data    : std_logic_vector(8 * cDataWidth_B * cFifoWidth - 1 downto 0) := (others => '0');
    signal fifo_dvalid  : std_logic := '0';
    signal fifo_empty   : std_logic := '0';
    signal fifo_aempty  : std_logic := '0';

    signal pll_den  : std_logic := '0';
    signal pll_dwe  : std_logic := '0';
    signal pll_drdy : std_logic := '0';
    signal pll_do   : std_logic_vector(15 downto 0) := (others => '0');

    signal addr   : std_logic_vector(9 downto 0) := (others => '0');

    type status_t is record
        -- Mode the TrngTestbed is in
        --   0 is FIFO readout mode
        --   1 is DDR DMA mode
        mode  : std_logic_vector(7 downto 0);
        -- Enable is the colocated RNG enable, which allows RNGs to run.
        enable : std_logic_vector(7 downto 0);
        -- Total is the number of samples desired for Mode 1 to collect
        total : unsigned(23 downto 0);
        -- Count is the number of samples collected during Mode 1 thus far
        count : unsigned(23 downto 0);
        -- RNG Address is the selected entropy source
        rng_addr : std_logic_vector(7 downto 0);
        -- Starting memory address for where to place entropy samples
        mem_addr : std_logic_vector(31 downto 0);
        -- Health and status, e.g. PLL lock status
        health   : std_logic_vector(7 downto 0);
    end record status_t;

    signal status : status_t := status_t'(
        -- Mode and enable are colocated in order to have them 
        -- update simultaneously.
        mode     => (others => '0'), 
        enable   => (others => '0'),
        total    => (others => '0'),
        count    => (others => '0'),
        rng_addr => (others => '0'),
        mem_addr => cMemoryDefaultAddress,
        health   => (others => '0')
    );

    type state_t is (IDLE, COLLECTING, POP_FIFO, SENDING);
    signal state : state_t := IDLE;

    signal axi_awready : std_logic := '0';
    signal axi_wready  : std_logic := '0';
    signal axi_awaddr  : unsigned(31 downto 0) := (others => '0');
    signal pll_locked  : std_logic := '0';

    signal ttb_intr : std_logic := '0';

    signal resetn : std_logic := '0';

    -- We need the ability to clear the FIFO anytime mode gets written.
    -- This allows us to safely remove other results from clogging the 
    -- FIFO.
    signal fifo_clear : std_logic := '0';
begin
    
    eSandbox : entity ostrngs.TrngSandbox
    generic map (
        cNumEntropySources => cNumEntropySources,
        cEntropySource00   => cEntropySource00,
        cEntropySource01   => cEntropySource01,
        cEntropySource02   => cEntropySource02,
        cEntropySource03   => cEntropySource03,
        cEntropySource04   => cEntropySource04,
        cEntropySource05   => cEntropySource05,
        cEntropySource06   => cEntropySource06,
        cEntropySource07   => cEntropySource07,
        cDataWidth_B       => cDataWidth_B,
        cFifoWidth         => cFifoWidth,
        cFifoDepth         => cFifoDepth
    ) port map (
        i_clk    => i_clk,
        i_resetn => i_resetn,

        i_rng_addr   => status.rng_addr,
        i_rng_enable => status.enable,
        o_rng_clk    => open,
        o_rng_data   => rng_data,
        o_rng_dvalid => rng_dvalid,

        i_fifo_clear  => fifo_clear,
        i_fifo_pop    => fifo_pop,
        o_fifo_data   => fifo_data,
        o_fifo_dvalid => fifo_dvalid,
        o_fifo_full   => open,
        o_fifo_afull  => open,
        o_fifo_aempty => fifo_aempty,
        o_fifo_empty  => fifo_empty,

        i_pll_daddr  => addr(8 downto 2),
        i_pll_den    => pll_den,
        i_pll_dwe    => pll_dwe,
        i_pll_di     => i_s_axi_wdata(15 downto 0),
        o_pll_drdy   => pll_drdy,
        o_pll_do     => pll_do,
        o_pll_locked => pll_locked
    );

    PllAccessSignals: process(axi_state, addr, i_s_axi_wstrb, fifo_dvalid, fifo_pop_reg)
    begin
        if (axi_state = WRITE_SEQUENCE or axi_state = READ_SEQUENCE) then
            pll_den <= not addr(9);
        else
            pll_den <= '0';
        end if;

        if (axi_state = READ_SEQUENCE and addr = "1000000000" and status.mode = x"00") then
            fifo_pop <= not fifo_dvalid;
        else
            fifo_pop <= fifo_pop_reg;
        end if;

        pll_dwe <= i_s_axi_wstrb(0) and 
                   i_s_axi_wstrb(1) and 
                   not i_s_axi_wstrb(2) and 
                   not i_s_axi_wstrb(3);
    end process PllAccessSignals;

    StateMachine: process(i_clk)
        variable seq : std_logic_vector(2 downto 0) := (others => '0');
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                state <= IDLE;

                o_s_axi_awready <= '0';
                o_s_axi_wready  <= '0';
                o_s_axi_bvalid  <= '0';
                o_s_axi_arready <= '0';
                o_s_axi_rvalid  <= '0';

                resetn <= '0';
                seq := (others => '0');
            else
                -- Default the fifo clear signal to '0' so we only clear it
                -- when the RNG or the MODE changes.
                fifo_clear <= '0';

                case axi_state is
                    when IDLE =>                        
                        if (i_s_axi_awvalid = '1') then
                            axi_state <= WRITE_SEQUENCE;
                            addr  <= i_s_axi_awaddr;

                            o_s_axi_awready <= '1';
                            o_s_axi_wready  <= '1';
                        elsif (i_s_axi_arvalid = '1') then
                            axi_state <= READ_SEQUENCE;
                            addr  <= i_s_axi_araddr;

                            o_s_axi_arready <= '1';
                        end if;

                    when WRITE_SEQUENCE =>
                        o_s_axi_awready <= '0';
                        if (i_s_axi_wvalid = '1') then
                            o_s_axi_wready <= '0';

                            -- We don't handle any wstrb here...

                            o_s_axi_bvalid <= '1';
                            axi_state      <= WRITE_RESPONSE;
                            case (addr) is
                                -- Not expecting misaligned reads/writes
                                when "0-------00" =>
                                    -- OKAY RESPONSE
                                    o_s_axi_bresp <= "00";
                                when "1000000000" =>
                                    -- SLVERR RESPONSE (Read only)
                                    o_s_axi_bresp <= "10";
                                when "1000000100" =>
                                    -- OKAY RESPONSE
                                    status.mode   <= i_s_axi_wdata(7 downto 0);
                                    status.enable <= i_s_axi_wdata(15 downto 8);
                                    o_s_axi_bresp <= "00";

                                    -- Clear the FIFO since we might have changed mode or enable.
                                    fifo_clear <= '1';

                                when "1000001000" =>
                                    -- OKAY RESPONSE
                                    status.total  <= unsigned(i_s_axi_wdata(23 downto 0));
                                    o_s_axi_bresp <= "00";
                                when "1000001100" =>
                                    -- SLVERR RESPONSE (status.count is read only)
                                    o_s_axi_bresp <= "10";
                                when "1000010000" =>
                                    -- OKAY RESPONSE
                                    status.rng_addr <= i_s_axi_wdata(7 downto 0);
                                    o_s_axi_bresp   <= "00";

                                    -- Clear the FIFO since we might have changed selected RNG.
                                    fifo_clear <= '1';

                                when "1000010100" =>
                                    -- OKAY RESPONSE
                                    status.mem_addr <= i_s_axi_wdata;
                                    o_s_axi_bresp   <= "00";
                                when "1000011000" =>
                                    -- SLVERR RESPONSE (status.health is read only)
                                    o_s_axi_bresp <= "10";
                                when others =>
                                    -- DECERR RESPONSE (Nothing at these addresses)
                                    o_s_axi_bresp <= "11";
                            end case;
                        end if;

                    when READ_SEQUENCE =>
                        o_s_axi_arready <= '0';
                        case (addr) is
                            -- Not expecting misaligned reads/writes
                            when "0-------00" =>
                                o_s_axi_rvalid <= pll_drdy;
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00"; 
                                if (pll_drdy = '1') then
                                    o_s_axi_rdata <= (others => '0');
                                    o_s_axi_rdata(15 downto 0) <= pll_do;

                                    axi_state <= READ_RESPONSE;
                                end if;

                            -- Not expecting misaligned reads/writes
                            when "1000000000" =>
                                o_s_axi_rvalid <= fifo_dvalid;
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                if (fifo_dvalid = '1') then
                                    -- Grab only one sample out of the fifo data
                                    o_s_axi_rdata <= std_logic_vector(
                                        resize(unsigned(fifo_data(8 * cDataWidth_B - 1 downto 0)), 32));

                                    axi_state <= READ_RESPONSE;
                                end if;

                            -- Not expecting misaligned reads/writes
                            when "1000000100" =>
                                o_s_axi_rvalid <= '1';
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                o_s_axi_rdata  <= x"0000" & status.enable & status.mode;

                                axi_state <= READ_RESPONSE;

                            -- Not expecting misaligned reads/writes
                            when "1000001000" =>
                                o_s_axi_rvalid <= '1';
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                o_s_axi_rdata  <= x"00" & std_logic_vector(status.total);

                                axi_state <= READ_RESPONSE;

                            -- Not expecting misaligned reads/writes
                            when "1000001100" =>
                                o_s_axi_rvalid <= '1';
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                o_s_axi_rdata  <= x"00" & std_logic_vector(status.count);

                                axi_state <= READ_RESPONSE;

                            -- Not expecting misaligned reads/writes
                            when "1000010000" =>
                                o_s_axi_rvalid <= '1';
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                o_s_axi_rdata  <= x"000000" & status.rng_addr;

                                axi_state <= READ_RESPONSE;

                            -- Not expecting misaligned reads/writes
                            when "1000010100" =>
                                o_s_axi_rvalid <= '1';
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                o_s_axi_rdata  <= status.mem_addr;

                                axi_state <= READ_RESPONSE;

                            -- Not expecting misaligned reads/writes
                            when "1000011000" =>
                                o_s_axi_rvalid <= '1';
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                o_s_axi_rdata  <= x"000000" & status.health;

                                axi_state <= READ_RESPONSE;

                            when others =>
                                -- DECERR (INVALID ADDRESS)
                                o_s_axi_rvalid <= '1';
                                o_s_axi_rresp  <= "11";

                                axi_state <= READ_RESPONSE;
                        end case;

                    when WRITE_RESPONSE =>
                        if (i_s_axi_bready = '1') then
                            o_s_axi_bvalid <= '0';

                            axi_state <= IDLE;
                        end if;

                    when READ_RESPONSE =>
                        if (i_s_axi_rready = '1') then
                            o_s_axi_rvalid <= '0';

                            axi_state <= IDLE;
                        end if;
                end case;

                -- Clear the interrupt signal.
                ttb_intr <= '0';

                case state is
                    when IDLE =>
                        fifo_pop_reg <= '0';
                        axi_awaddr   <= unsigned(status.mem_addr);
                        if (status.mode /= x"00") then
                            state <= COLLECTING;
                            status.count <= (others => '0');
                        end if;

                    when COLLECTING =>
                        if (fifo_aempty = '1' or fifo_empty = '1') then
                            fifo_pop_reg <= '0';
                        else
                            fifo_pop_reg <= '1';
                            state        <= POP_FIFO;
                        end if;

                    when POP_FIFO =>
                        fifo_pop_reg <= '0';
                        seq := (others => '0');
                        if (fifo_dvalid = '1') then
                            o_m_axi_awaddr  <= std_logic_vector(axi_awaddr);
                            o_m_axi_awvalid <= '1';
                            o_m_axi_wdata   <= fifo_data;
                            o_m_axi_wstrb   <= (others => '1');
                            o_m_axi_wvalid  <= '1';
                            o_m_axi_bready  <= '1';

                            state        <= SENDING;
                            axi_awaddr   <= axi_awaddr + cFifoWidth * cDataWidth_B;
                        elsif (fifo_aempty = '1' or fifo_empty = '1') then
                            state <= COLLECTING;
                        end if;
                    
                    when SENDING =>
                        if (i_m_axi_awready = '1') then
                            seq(0) := '1';
                            o_m_axi_awvalid <= '0';
                        end if;

                        if (i_m_axi_wready = '1') then
                            seq(1) := '1';
                            o_m_axi_wvalid <= '0';
                        end if;

                        if (i_m_axi_bvalid = '1') then
                            seq(2) := '1';
                            o_m_axi_bready <= '0';
                        end if;

                        if (seq = "111") then
                            seq := (others => '0');
                            if status.count < status.total then
                                status.count <= status.count + cFifoWidth;
                                state        <= COLLECTING;
                            else
                                status.mode  <= x"00";
                                state        <= IDLE;
                                ttb_intr     <= '1';
                            end if;
                        end if;
                end case;

                status.health(0) <= pll_locked;
            end if;
        end if;
    end process StateMachine;

    InterruptPulseExtender: process(i_clk)
        variable count : natural range 0 to 5 := 0;
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                o_ttb_intr <= '0';
            else
                if (ttb_intr = '1') then
                    o_ttb_intr <= '1';
                    count := 5;
                elsif (count > 0) then
                    count := count - 1;
                else
                    o_ttb_intr <= '0';
                end if;
            end if;
        end if;
    end process InterruptPulseExtender;
    
end architecture rtl;