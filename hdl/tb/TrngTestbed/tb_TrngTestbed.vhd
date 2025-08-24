library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library osvvm;
    use osvvm.TbUtilPkg.all;

library ostrngs;

library tb_ostrngs;

entity tb_TrngTestbed is
    generic (runner_cfg : string);
end entity tb_TrngTestbed;

architecture tb of tb_TrngTestbed is
    type ms_axi_lite_t is record
        awaddr  : std_logic_vector;
        awprot  : std_logic_vector(2 downto 0);
        awvalid : std_logic;

        wdata   : std_logic_vector;
        wstrb   : std_logic_vector;
        wvalid  : std_logic;

        bready  : std_logic;

        araddr  : std_logic_vector;
        arprot  : std_logic_vector(2 downto 0);
        arvalid : std_logic;

        rready  : std_logic;
    end record ms_axi_lite_t;

    type sm_axi_lite_t is record
        awready : std_logic;

        wready  : std_logic;

        bresp   : std_logic_vector(1 downto 0);
        bvalid  : std_logic;

        arready : std_logic;

        rdata   : std_logic_vector;
        rresp   : std_logic_vector(1 downto 0);
        rvalid  : std_logic;
    end record sm_axi_lite_t;

    signal in_s_axi : ms_axi_lite_t(
        awaddr(9 downto 0), 
        wdata(31 downto 0), 
        wstrb(3 downto 0), 
        araddr(9 downto 0)
    );

    signal out_m_axi : ms_axi_lite_t(
        awaddr(31 downto 0), 
        wdata(127 downto 0), 
        wstrb(15 downto 0), 
        araddr(31 downto 0)
    );

    signal out_s_axi : sm_axi_lite_t(
        rdata(31 downto 0)
    );

    signal in_m_axi : sm_axi_lite_t(
        rdata(127 downto 0)
    );

    signal clk    : std_logic := '0';
    signal resetn : std_logic := '0';

    procedure axi_write(
        signal mosi_axi : inout ms_axi_lite_t;
        signal miso_axi : in sm_axi_lite_t;
        constant addr   : in std_logic_vector;
        constant prot   : in std_logic_vector;
        constant data   : in std_logic_vector;
        constant strb   : in std_logic_vector
    ) is 
        variable awready : std_logic := '0';
        variable wready  : std_logic := '0';
        variable bvalid  : std_logic := '0';
    begin
        -- clear state variables
        awready := '0';
        wready  := '0';
        bvalid  := '0';

        -- set the address fields for the address write channel
        mosi_axi.awaddr  <= addr;
        mosi_axi.awprot  <= prot;
        mosi_axi.awvalid <= '1';

        -- set the data fields for the write channel
        mosi_axi.wdata   <= data;
        mosi_axi.wstrb   <= strb;
        mosi_axi.wvalid  <= '1';

        -- set the response ready signal
        mosi_axi.bready  <= '1';

        -- as long as one of the three channels havent been accepted, loop
        while (awready = '0' or wready = '0' or bvalid = '0') loop
            -- Wait until something on these three signals update.
            wait until ((miso_axi.awready = '1') or (miso_axi.wready = '1') or (miso_axi.bvalid = '1'));

            -- If its the address write channel, clean up after the address write.
            if (miso_axi.awready = '1' and mosi_axi.awvalid = '1') then
                awready := '1';
            end if;

            -- If its the write channel, clean up after the write.
            if (miso_axi.wready = '1' and mosi_axi.wvalid = '1') then
                wready := '1';
            end if;

            -- If its the response channel, clean up after the response.
            if (miso_axi.bvalid = '1' and mosi_axi.bready = '1') then
                bvalid := '1';
            end if;

            wait until rising_edge(clk);
            mosi_axi.awvalid <= not awready;
            mosi_axi.wvalid  <= not wready;
            mosi_axi.bready  <= not bvalid;
        end loop;
    end procedure;

    procedure axi_read(
        signal mosi_axi : inout ms_axi_lite_t;
        signal miso_axi : in sm_axi_lite_t;
        constant addr   : in std_logic_vector;
        constant prot   : in std_logic_vector;
        variable data   : out std_logic_vector
    ) is 
        variable arready : std_logic := '0';
        variable rvalid  : std_logic := '0';
    begin
        -- clear state variables
        arready := '0';
        rvalid  := '0';

        -- set the address fields for the address write channel
        mosi_axi.araddr  <= addr;
        mosi_axi.arprot  <= prot;
        mosi_axi.arvalid <= '1';

        -- set the read ready signal
        mosi_axi.rready  <= '1';

        -- as long as one of the two channels havent been accepted, loop
        while (arready = '0' or rvalid = '0') loop
            -- Wait until something on these three signals update.
            wait until ((miso_axi.arready = '1') or (miso_axi.rvalid = '1'));

            -- If its the address write channel, clean up after the address write.
            if (miso_axi.arready = '1' and mosi_axi.arvalid = '1') then
                arready := '1';
            end if;

            -- If its the response channel, clean up after the response.
            if (miso_axi.rvalid = '1' and mosi_axi.rready = '1') then
                data   := miso_axi.rdata;
                rvalid := '1';
            end if;

            wait until rising_edge(clk);
            mosi_axi.arvalid <= not arready;
            mosi_axi.rready  <= not rvalid;
        end loop;
    end procedure;
begin

    CreateClock(clk=>clk, period=>10 ns);

    eDut : entity ostrngs.TrngTestbed
    generic map (
        cEntropySource00 => "Simulation",
        cEntropySource01 => "Simulation",
        cEntropySource02 => "Simulation",
        cEntropySource03 => "Simulation",
        cEntropySource04 => "Simulation",
        cEntropySource05 => "Simulation",
        cEntropySource06 => "Simulation",
        cEntropySource07 => "Simulation"
    ) port map (
        i_clk    => clk,
        i_resetn => resetn,

        s_axi_trng_awaddr  => in_s_axi.awaddr,
        s_axi_trng_awprot  => in_s_axi.awprot,
        s_axi_trng_awvalid => in_s_axi.awvalid,
        s_axi_trng_awready => out_s_axi.awready,

        s_axi_trng_wdata   => in_s_axi.wdata,
        s_axi_trng_wstrb   => in_s_axi.wstrb,
        s_axi_trng_wvalid  => in_s_axi.wvalid,
        s_axi_trng_wready  => out_s_axi.wready,

        s_axi_trng_bresp   => out_s_axi.bresp,
        s_axi_trng_bvalid  => out_s_axi.bvalid,
        s_axi_trng_bready  => in_s_axi.bready,

        s_axi_trng_araddr  => in_s_axi.araddr,
        s_axi_trng_arprot  => in_s_axi.arprot,
        s_axi_trng_arvalid => in_s_axi.arvalid,
        s_axi_trng_arready => out_s_axi.arready,

        s_axi_trng_rdata   => out_s_axi.rdata,
        s_axi_trng_rresp   => out_s_axi.rresp,
        s_axi_trng_rvalid  => out_s_axi.rvalid,
        s_axi_trng_rready  => in_s_axi.rready,

        m_axi_mem_awaddr  => out_m_axi.awaddr,
        m_axi_mem_awprot  => out_m_axi.awprot,
        m_axi_mem_awvalid => out_m_axi.awvalid,
        m_axi_mem_awready => in_m_axi.awready,

        m_axi_mem_wdata   => out_m_axi.wdata,
        m_axi_mem_wstrb   => out_m_axi.wstrb,
        m_axi_mem_wvalid  => out_m_axi.wvalid,
        m_axi_mem_wready  => in_m_axi.wready,

        m_axi_mem_bresp   => in_m_axi.bresp,
        m_axi_mem_bvalid  => in_m_axi.bvalid,
        m_axi_mem_bready  => out_m_axi.bready,

        m_axi_mem_araddr  => out_m_axi.araddr,
        m_axi_mem_arprot  => out_m_axi.arprot,
        m_axi_mem_arvalid => out_m_axi.arvalid,
        m_axi_mem_arready => in_m_axi.arready,

        m_axi_mem_rdata   => in_m_axi.rdata,
        m_axi_mem_rresp   => in_m_axi.rresp,
        m_axi_mem_rvalid  => in_m_axi.rvalid,
        m_axi_mem_rready  => out_m_axi.rready
    );

    -- Build a crossbar interconnect here to allow both testbench control of the RAM
    -- and also TrngTestbed control

    eRam : entity tb_ostrngs.RandomAxiRam
    generic map (
        cAddressWidth_b     => 32,
        cCachelineSize_B    => 16,
        cCheckUninitialized => false,
        cVerboseMode        => false
    ) port map (
        i_clk    => clk,
        i_resetn => resetn,

        i_s_axi_awaddr  => out_m_axi.awaddr,
        i_s_axi_awprot  => out_m_axi.awprot,
        i_s_axi_awvalid => out_m_axi.awvalid,
        o_s_axi_awready => in_m_axi.awready,

        i_s_axi_wdata   => out_m_axi.wdata,
        i_s_axi_wstrb   => out_m_axi.wstrb,
        i_s_axi_wvalid  => out_m_axi.wvalid,
        o_s_axi_wready  => in_m_axi.wready,

        o_s_axi_bresp   => in_m_axi.bresp,
        o_s_axi_bvalid  => in_m_axi.bvalid,
        i_s_axi_bready  => out_m_axi.bready,

        i_s_axi_araddr  => out_m_axi.araddr,
        i_s_axi_arprot  => out_m_axi.arprot,
        i_s_axi_arvalid => out_m_axi.arvalid,
        o_s_axi_arready => in_m_axi.arready,

        o_s_axi_rdata   => in_m_axi.rdata,
        o_s_axi_rresp   => in_m_axi.rresp,
        o_s_axi_rvalid  => in_m_axi.rvalid,
        i_s_axi_rready  => out_m_axi.rready
    );
    
    TestRunner : process
        variable rdata : std_logic_vector(31 downto 0);
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            -- check that clock is configurable
            -- check that entropy source is configurable
            -- check that DMA access works
            -- check that FIFO access works
            if run("t_entropy_source_config") then
                wait until rising_edge(clk);
                wait for 100 ps;
                resetn <= '1';
                axi_write(in_s_axi, out_s_axi, "1000001000", "000", x"00FFFFFF", "1111");
                wait for 50 ns;
                axi_write(in_s_axi, out_s_axi, "1000010000", "000", x"00000003", "1111");
                wait for 50 ns;
                axi_write(in_s_axi, out_s_axi, "1000010100", "000", x"F0F00000", "1111");
                wait for 50 ns;
            elsif run("t_clock_config") then
                info("Checking that PLL is configurable from the AXI port");
                check(false);
            elsif run("t_rw_access") then
                info("Checking that expected access responses occur for subset of possible memory regions");
                check(false);
            elsif run("t_fifo_access") then
                info("Checking that access to the fifo returns a single byte of entropy");
                check(false);
            elsif run("t_dma_nist_testing") then
                info("Checking that testbed allows for appropriate data collection for NIST testing");
                wait until rising_edge(clk);
                wait for 100 ps;
                resetn <= '1';
                axi_write(in_s_axi, out_s_axi, "1000001000", "000", x"00000FFF", "1111");
                wait for 50 ns;
                axi_write(in_s_axi, out_s_axi, "1000010000", "000", x"00000003", "1111");

                while (rdata /= x"00000001") loop
                    wait for 25 ns;
                    axi_read(in_s_axi, out_s_axi, "1000011000", "000", rdata);
                end loop;

                wait for 50 ns;
                axi_write(in_s_axi, out_s_axi, "1000000100", "000", x"00000001", "1111");

                rdata := x"00000001";
                while (rdata = x"00000001") loop
                    wait for 50 ns;
                    axi_read(in_s_axi, out_s_axi, "1000000100", "000", rdata);
                end loop;

                -- Validate that performance worked here.
                -- Eyeball test shows that it works, just add validation.
                -- That will likely include checking address ranges and that we never
                -- exceeded the fifo.
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 us);
    
end architecture tb;