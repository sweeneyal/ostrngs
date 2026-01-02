-----------------------------------------------------------------------------------------------------------------------
-- entity: TrngTestbed
--
-- library: ostrngs
--
-- description:
--       This file is a wrapper around the fundamental core of the TrngTestbed. It "translates" the AXI interfaces 
--       to and from the AMD-Xilinx expected naming convention of ports at the block-diagram level, and my preferred
--       naming convention that adds additional indicators to the direction of the port.
--
--       The s_axi_trng* ports are designated for a master controller (e.g. processor) to provide commands to the IP
--       core and configure it to perform the different modes, or change different configurations.
--
--       The m_axi_mem* ports are designated for the IP core to access a downstream AXI memory component with shared
--       access (managed external to this IP core) between a master controller and this IP core. The premise is that
--       this IP core will generate a requested amount of entropy, store it to memory at a provided memory address
--       range, and then assert a flag that the requested amount of entropy has been collected and provided.
--
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngTestbed is
    generic (
        -- Sets the total number of entropy sources to instantiate
        cNumEntropySources    : positive range 1 to 8 := 8;
        -- Provides a mechanism to instantiate various unique entropy sources
        cEntropySource00      : string := "MeshCoupledXor";
        cEntropySource01      : string := "OpenLoopMetaTrng";
        cEntropySource02      : string := "LwxnorLutTrng";
        cEntropySource03      : string := "XorRingTrng";
        cEntropySource04      : string := "DigitalNonlinearOscillator";
        cEntropySource05      : string := "HybridFfsrTrng";
        cEntropySource06      : string := "LwxnorTrng";
        cEntropySource07      : string := "RoLdceTrng";
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
        s_axi_trng_awaddr  : in std_logic_vector(9 downto 0);
        -- peripheral axi write address protection level
        s_axi_trng_awprot  : in std_logic_vector(2 downto 0);
        -- peripheral axi write address bus valid signal
        s_axi_trng_awvalid : in std_logic;
        -- peripheral axi write address bus ready-to-accept signal
        s_axi_trng_awready : out std_logic;

        -- peripheral axi write data channel
        s_axi_trng_wdata   : in std_logic_vector(31 downto 0);
        -- peripheral axi write strobe channel (indicates valid bytes in word)
        s_axi_trng_wstrb   : in std_logic_vector(3 downto 0);
        -- peripheral axi write bus valid signal
        s_axi_trng_wvalid  : in std_logic;
        -- peripheral axi write ready-to-accept signal
        s_axi_trng_wready  : out std_logic;

        -- peripheral axi write response indicator
        s_axi_trng_bresp   : out std_logic_vector(1 downto 0);
        -- peripheral axi write response valid signal
        s_axi_trng_bvalid  : out std_logic;
        -- peripheral axi write response ready-to-accept signal
        s_axi_trng_bready  : in std_logic;

        -- peripheral axi read address channel
        s_axi_trng_araddr  : in std_logic_vector(9 downto 0);
        -- peripheral axi read address protection level
        s_axi_trng_arprot  : in std_logic_vector(2 downto 0);
        -- peripheral axi read address valid signal
        s_axi_trng_arvalid : in std_logic;
        -- peripheral axi read address ready-to-accept signal
        s_axi_trng_arready : out std_logic;

        -- peripheral axi read data channel
        s_axi_trng_rdata   : out std_logic_vector(31 downto 0);
        -- peripheral axi read response indicator
        s_axi_trng_rresp   : out std_logic_vector(1 downto 0);
        -- peripheral axi read valid signal
        s_axi_trng_rvalid  : out std_logic;
        -- peripheral axi read ready signal
        s_axi_trng_rready  : in std_logic;

        ----------------------------------------------------------------------
        -- TrngTestbed-To-DdrRam AXI Lite Interface
        ----------------------------------------------------------------------
        -- master axi write address channel
        m_axi_mem_awaddr  : out std_logic_vector(31 downto 0);
        -- master axi write address protection level
        m_axi_mem_awprot  : out std_logic_vector(2 downto 0);
        -- master axi write address bus valid signal
        m_axi_mem_awvalid : out std_logic;
        -- master axi write address bus ready-to-accept signal
        m_axi_mem_awready : in std_logic;

        -- master axi write data channel
        m_axi_mem_wdata   : out std_logic_vector(8 * cFifoWidth - 1 downto 0);
        -- master axi write strobe channel (indicates valid bytes in word)
        m_axi_mem_wstrb   : out std_logic_vector(cFifoWidth - 1 downto 0);
        -- master axi write bus valid signal
        m_axi_mem_wvalid  : out std_logic;
        -- master axi write ready-to-accept signal
        m_axi_mem_wready  : in std_logic;

        -- master axi write response indicator
        m_axi_mem_bresp   : in std_logic_vector(1 downto 0);
        -- master axi write response valid signal
        m_axi_mem_bvalid  : in std_logic;
        -- master axi write response ready-to-accept signal
        m_axi_mem_bready  : out std_logic;

        -- master axi read address channel
        m_axi_mem_araddr  : out std_logic_vector(31 downto 0);
        -- master axi read address protection level
        m_axi_mem_arprot  : out std_logic_vector(2 downto 0);
        -- master axi read address valid signal
        m_axi_mem_arvalid : out std_logic;
        -- master axi read address ready-to-accept signal
        m_axi_mem_arready : in std_logic;

        -- master axi read data channel
        m_axi_mem_rdata   : in std_logic_vector(8 * cFifoWidth - 1 downto 0);
        -- master axi read response indicator
        m_axi_mem_rresp   : in std_logic_vector(1 downto 0);
        -- master axi read valid signal
        m_axi_mem_rvalid  : in std_logic;
        -- master axi read ready signal
        m_axi_mem_rready  : out std_logic
    );
end entity TrngTestbed;

architecture rtl of TrngTestbed is
begin
    
    eCore : entity ostrngs.TrngTestbedCore
    generic map (
        -- Sets the total number of entropy sources to instantiate
        cNumEntropySources    => cNumEntropySources,
        -- Provides a mechanism to instantiate various unique entropy sources
        cEntropySource00      => cEntropySource00,
        cEntropySource01      => cEntropySource01,
        cEntropySource02      => cEntropySource02,
        cEntropySource03      => cEntropySource03,
        cEntropySource04      => cEntropySource04,
        cEntropySource05      => cEntropySource05,
        cEntropySource06      => cEntropySource06,
        cEntropySource07      => cEntropySource07,
        -- Fifo depth in groups of samples
        cFifoDepth            => cFifoDepth,
        -- Fifo width in samples
        cFifoWidth            => cFifoWidth,
        -- Memory access generic for default address samples are stored at
        cMemoryDefaultAddress => cMemoryDefaultAddress
    ) port map (
        -- system clock
        i_clk    => i_clk,
        -- active low reset synchronous to the system clock
        i_resetn => i_resetn,

        ----------------------------------------------------------------------
        -- Processor-To-TrngTestbed AXI Lite Interface
        ----------------------------------------------------------------------
        -- peripheral axi write address channel
        i_s_axi_awaddr  => s_axi_trng_awaddr,
        -- peripheral axi write address protection level
        i_s_axi_awprot  => s_axi_trng_awprot,
        -- peripheral axi write address bus valid signal
        i_s_axi_awvalid => s_axi_trng_awvalid,
        -- peripheral axi write address bus ready-to-accept signal
        o_s_axi_awready => s_axi_trng_awready,

        -- peripheral axi write data channel
        i_s_axi_wdata   => s_axi_trng_wdata,
        -- peripheral axi write strobe channel (indicates valid bytes in word)
        i_s_axi_wstrb   => s_axi_trng_wstrb,
        -- peripheral axi write bus valid signal
        i_s_axi_wvalid  => s_axi_trng_wvalid,
        -- peripheral axi write ready-to-accept signal
        o_s_axi_wready  => s_axi_trng_wready,

        -- peripheral axi write response indicator
        o_s_axi_bresp   => s_axi_trng_bresp,
        -- peripheral axi write response valid signal
        o_s_axi_bvalid  => s_axi_trng_bvalid,
        -- peripheral axi write response ready-to-accept signal
        i_s_axi_bready  => s_axi_trng_bready,

        -- peripheral axi read address channel
        i_s_axi_araddr  => s_axi_trng_araddr,
        -- peripheral axi read address protection level
        i_s_axi_arprot  => s_axi_trng_arprot,
        -- peripheral axi read address valid signal
        i_s_axi_arvalid => s_axi_trng_arvalid,
        -- peripheral axi read address ready-to-accept signal
        o_s_axi_arready => s_axi_trng_arready,

        -- peripheral axi read data channel
        o_s_axi_rdata   => s_axi_trng_rdata,
        -- peripheral axi read response indicator
        o_s_axi_rresp   => s_axi_trng_rresp,
        -- peripheral axi read valid signal
        o_s_axi_rvalid  => s_axi_trng_rvalid,
        -- peripheral axi read ready signal
        i_s_axi_rready  => s_axi_trng_rready,

        ----------------------------------------------------------------------
        -- TrngTestbed-To-DdrRam AXI Lite Interface
        ----------------------------------------------------------------------
        -- master axi write address channel
        o_m_axi_awaddr  => m_axi_mem_awaddr,
        -- master axi write address protection level
        o_m_axi_awprot  => m_axi_mem_awprot,
        -- master axi write address bus valid signal
        o_m_axi_awvalid => m_axi_mem_awvalid,
        -- master axi write address bus ready-to-accept signal
        i_m_axi_awready => m_axi_mem_awready,

        -- master axi write data channel
        o_m_axi_wdata   => m_axi_mem_wdata,
        -- master axi write strobe channel (indicates valid bytes in word)
        o_m_axi_wstrb   => m_axi_mem_wstrb,
        -- master axi write bus valid signal
        o_m_axi_wvalid  => m_axi_mem_wvalid,
        -- master axi write ready-to-accept signal
        i_m_axi_wready  => m_axi_mem_wready,

        -- master axi write response indicator
        i_m_axi_bresp   => m_axi_mem_bresp,
        -- master axi write response valid signal
        i_m_axi_bvalid  => m_axi_mem_bvalid,
        -- master axi write response ready-to-accept signal
        o_m_axi_bready  => m_axi_mem_bready,

        -- master axi read address channel
        o_m_axi_araddr  => m_axi_mem_araddr,
        -- master axi read address protection level
        o_m_axi_arprot  => m_axi_mem_arprot,
        -- master axi read address valid signal
        o_m_axi_arvalid => m_axi_mem_arvalid,
        -- master axi read address ready-to-accept signal
        i_m_axi_arready => m_axi_mem_arready,

        -- master axi read data channel
        i_m_axi_rdata   => m_axi_mem_rdata,
        -- master axi read response indicator
        i_m_axi_rresp   => m_axi_mem_rresp,
        -- master axi read valid signal
        i_m_axi_rvalid  => m_axi_mem_rvalid,
        -- master axi read ready signal
        o_m_axi_rready  => m_axi_mem_rready
    );
    
end architecture rtl;