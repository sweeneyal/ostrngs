library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library osvvm;
    use osvvm.TbUtilPkg.all;

library ostrngs;

entity tb_TrngTestbed is
    generic (runner_cfg : string);
end entity tb_TrngTestbed;

architecture tb of tb_TrngTestbed is
    type axi_lite_t is record
        awaddr  : std_logic_vector;
        awprot  : std_logic_vector(2 downto 0);
        awvalid : std_logic;
        awready : std_logic;

        wdata   : std_logic_vector;
        wstrb   : std_logic_vector;
        wvalid  : std_logic;
        wready  : std_logic;

        bresp   : std_logic_vector(1 downto 0);
        bvalid  : std_logic;
        bready  : std_logic;

        araddr  : std_logic_vector;
        arprot  : std_logic_vector(2 downto 0);
        arvalid : std_logic;
        arready : std_logic;

        rdata   : std_logic_vector;
        rresp   : std_logic_vector(1 downto 0);
        rvalid  : std_logic;
        rready  : std_logic;
    end record axi_lite_t;

    signal s_axi : axi_lite_t(
        awaddr(9 downto 0), 
        wdata(31 downto 0), 
        wstrb(3 downto 0), 
        araddr(9 downto 0), 
        rdata(31 downto 0)
    );

    signal m_axi : axi_lite_t(
        awaddr(31 downto 0), 
        wdata(127 downto 0), 
        wstrb(15 downto 0), 
        araddr(31 downto 0), 
        rdata(127 downto 0)
    );

    signal clk    : std_logic := '0';
    signal resetn : std_logic := '0';
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

        i_s_axi_awaddr  => s_axi.awaddr,
        i_s_axi_awprot  => s_axi.awprot,
        i_s_axi_awvalid => s_axi.awvalid,
        o_s_axi_awready => s_axi.awready,

        i_s_axi_wdata   => s_axi.wdata,
        i_s_axi_wstrb   => s_axi.wstrb,
        i_s_axi_wvalid  => s_axi.wvalid,
        o_s_axi_wready  => s_axi.wready,

        o_s_axi_bresp   => s_axi.bresp,
        o_s_axi_bvalid  => s_axi.bvalid,
        i_s_axi_bready  => s_axi.bready,

        i_s_axi_araddr  => s_axi.araddr,
        i_s_axi_arprot  => s_axi.arprot,
        i_s_axi_arvalid => s_axi.arvalid,
        o_s_axi_arready => s_axi.arready,

        o_s_axi_rdata   => s_axi.rdata,
        o_s_axi_rresp   => s_axi.rresp,
        o_s_axi_rvalid  => s_axi.rvalid,
        i_s_axi_rready  => s_axi.rready,

        o_m_axi_awaddr  => m_axi.awaddr,
        o_m_axi_awprot  => m_axi.awprot,
        o_m_axi_awvalid => m_axi.awvalid,
        i_m_axi_awready => m_axi.awready,

        o_m_axi_wdata   => m_axi.wdata,
        o_m_axi_wstrb   => m_axi.wstrb,
        o_m_axi_wvalid  => m_axi.wvalid,
        i_m_axi_wready  => m_axi.wready,

        i_m_axi_bresp   => m_axi.bresp,
        i_m_axi_bvalid  => m_axi.bvalid,
        o_m_axi_bready  => m_axi.bready,

        o_m_axi_araddr  => m_axi.araddr,
        o_m_axi_arprot  => m_axi.arprot,
        o_m_axi_arvalid => m_axi.arvalid,
        i_m_axi_arready => m_axi.arready,

        i_m_axi_rdata   => m_axi.rdata,
        i_m_axi_rresp   => m_axi.rresp,
        i_m_axi_rvalid  => m_axi.rvalid,
        o_m_axi_rready  => m_axi.rready
    );
    
    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_demo") then
                check(false);
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture tb;