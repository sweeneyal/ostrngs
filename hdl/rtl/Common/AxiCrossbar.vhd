-----------------------------------------------------------------------------------------------------------------------
-- entity: AxiCrossbar
--
-- library: ostrngs
--
-- description:
--       AXI Crossbar interconnect that is generically controlled. This allows iterative generation with several 
--       masters and peripherals.
--
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;
    use ostrngs.AxiUtility.all;

entity AxiCrossbar is
    generic (
        -- AXI port address width for the entire crossbar
        cAddressWidth_b : positive;
        -- AXI port data width in bytes for the entire crossbar
        cDataWidth_B    : positive;
        -- Total number of masters that need access to the peripherals
        cNumMasters     : positive;
        -- Total number of peripherals that need to be accessed.
        cNumPeripherals : positive;
        -- Array of addresses for each peripheral
        cPeripheralAddresses : address_array_t
            (0 to cNumPeripherals - 1)(cAddressWidth_b - 1 downto 0);
        -- Array of masks for each peripheral's address range
        cPeripheralMasks : mask_array_t
            (0 to cNumPeripherals - 1)(cAddressWidth_b - 1 downto 0)
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        ----------------------------------------------------------------------
        -- peripheral axi write address channel
        i_s_axi_awaddr  : in std_logic_vector(cNumMasters * cAddressWidth_b - 1 downto 0);
        -- peripheral axi write address protection level
        i_s_axi_awprot  : in std_logic_vector(cNumMasters * 3 - 1 downto 0);
        -- peripheral axi write address bus valid signal
        i_s_axi_awvalid : in std_logic_vector(cNumMasters - 1 downto 0);
        -- peripheral axi write address bus ready-to-accept signal
        o_s_axi_awready : out std_logic_vector(cNumMasters - 1 downto 0);

        -- peripheral axi write data channel
        i_s_axi_wdata   : in std_logic_vector(cNumMasters * 8 * cDataWidth_B - 1 downto 0);
        -- peripheral axi write strobe channel (indicates valid bytes in word)
        i_s_axi_wstrb   : in std_logic_vector(cNumMasters * cDataWidth_B - 1 downto 0);
        -- peripheral axi write bus valid signal
        i_s_axi_wvalid  : in std_logic_vector(cNumMasters - 1 downto 0);
        -- peripheral axi write ready-to-accept signal
        o_s_axi_wready  : out std_logic_vector(cNumMasters - 1 downto 0);

        -- peripheral axi write response indicator
        o_s_axi_bresp   : out std_logic_vector(cNumMasters * 2 - 1 downto 0);
        -- peripheral axi write response valid signal
        o_s_axi_bvalid  : out std_logic_vector(cNumMasters - 1 downto 0);
        -- peripheral axi write response ready-to-accept signal
        i_s_axi_bready  : in std_logic_vector(cNumMasters - 1 downto 0);

        -- peripheral axi read address channel
        i_s_axi_araddr  : in std_logic_vector(cNumMasters * cAddressWidth_b - 1 downto 0);
        -- peripheral axi read address protection level
        i_s_axi_arprot  : in std_logic_vector(cNumMasters * 3 - 1 downto 0);
        -- peripheral axi read address valid signal
        i_s_axi_arvalid : in std_logic_vector(cNumMasters - 1 downto 0);
        -- peripheral axi read address ready-to-accept signal
        o_s_axi_arready : out std_logic_vector(cNumMasters - 1 downto 0);

        -- peripheral axi read data channel
        o_s_axi_rdata   : out std_logic_vector(cNumMasters * 8 * cDataWidth_B - 1 downto 0);
        -- peripheral axi read response indicator
        o_s_axi_rresp   : out std_logic_vector(cNumMasters * 2 - 1 downto 0);
        -- peripheral axi read valid signal
        o_s_axi_rvalid  : out std_logic_vector(cNumMasters - 1 downto 0);
        -- peripheral axi read ready signal
        i_s_axi_rready  : in std_logic_vector(cNumMasters - 1 downto 0);

        ----------------------------------------------------------------------
        -- master axi write address channel
        i_m_axi_awaddr  : in std_logic_vector(cNumPeripherals * cAddressWidth_b - 1 downto 0);
        -- master axi write address protection level
        i_m_axi_awprot  : in std_logic_vector(cNumPeripherals * 3 - 1 downto 0);
        -- master axi write address bus valid signal
        i_m_axi_awvalid : in std_logic_vector(cNumPeripherals - 1 downto 0);
        -- master axi write address bus ready-to-accept signal
        o_m_axi_awready : out std_logic_vector(cNumPeripherals - 1 downto 0);

        -- master axi write data channel
        i_m_axi_wdata   : in std_logic_vector(cNumPeripherals * 8 * cDataWidth_B - 1 downto 0);
        -- master axi write strobe channel (indicates valid bytes in word)
        i_m_axi_wstrb   : in std_logic_vector(cNumPeripherals * cDataWidth_B - 1 downto 0);
        -- master axi write bus valid signal
        i_m_axi_wvalid  : in std_logic_vector(cNumPeripherals - 1 downto 0);
        -- master axi write ready-to-accept signal
        o_m_axi_wready  : out std_logic_vector(cNumPeripherals - 1 downto 0);

        -- master axi write response indicator
        o_m_axi_bresp   : out std_logic_vector(cNumPeripherals * 2 - 1 downto 0);
        -- master axi write response valid signal
        o_m_axi_bvalid  : out std_logic_vector(cNumPeripherals - 1 downto 0);
        -- master axi write response ready-to-accept signal
        i_m_axi_bready  : in std_logic_vector(cNumPeripherals - 1 downto 0);

        -- master axi read address channel
        i_m_axi_araddr  : in std_logic_vector(cNumPeripherals * cAddressWidth_b - 1 downto 0);
        -- master axi read address protection level
        i_m_axi_arprot  : in std_logic_vector(cNumPeripherals * 3 - 1 downto 0);
        -- master axi read address valid signal
        i_m_axi_arvalid : in std_logic_vector(cNumPeripherals - 1 downto 0);
        -- master axi read address ready-to-accept signal
        o_m_axi_arready : out std_logic_vector(cNumPeripherals - 1 downto 0);

        -- master axi read data channel
        o_m_axi_rdata   : out std_logic_vector(cNumPeripherals * 8 * cDataWidth_B - 1 downto 0);
        -- master axi read response indicator
        o_m_axi_rresp   : out std_logic_vector(cNumPeripherals * 2 - 1 downto 0);
        -- master axi read valid signal
        o_m_axi_rvalid  : out std_logic_vector(cNumPeripherals - 1 downto 0);
        -- master axi read ready signal
        i_m_axi_rready  : in std_logic_vector(cNumPeripherals - 1 downto 0)
    );
end entity AxiCrossbar;

architecture rtl of AxiCrossbar is
    -- Grant status indicates that the master M is connected to the peripheral P if grant[M][P] = '1'
    type grant_status_t is array (0 to cNumMasters - 1) of std_logic_vector(cNumPeripherals - 1 downto 0);
    signal wgrant  : grant_status_t := (others => (others => '0'));
    signal rgrant  : grant_status_t := (others => (others => '0'));
    -- MGrant indicates that the master M is connected to any peripheral if mgrant[M] = '1'
    signal mwgrant : std_logic_vector(cNumMasters - 1 downto 0) := (others => '0');
    signal mrgrant : std_logic_vector(cNumMasters - 1 downto 0) := (others => '0');


begin
    
    
    
end architecture rtl;