library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

library ostrngs;

entity TrngController is
    generic (
        cClockFrequency_Hz : positive;
        cUartBaudRate_bps  : positive := 115200
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- uart interface
        o_uart_tx : out std_logic;
        i_uart_rx : out std_logic;

        ----------------------------------------------------------------------
        -- Master AXI Lite Interface
        ----------------------------------------------------------------------
        -- master axi write address channel
        m_axi_awaddr  : out std_logic_vector(31 downto 0);
        -- master axi write address protection level
        m_axi_awprot  : out std_logic_vector(2 downto 0);
        -- master axi write address bus valid signal
        m_axi_awvalid : out std_logic;
        -- master axi write address bus ready-to-accept signal
        m_axi_awready : in std_logic;

        -- master axi write data channel
        m_axi_wdata   : out std_logic_vector(31 downto 0);
        -- master axi write strobe channel (indicates valid bytes in word)
        m_axi_wstrb   : out std_logic_vector(3 downto 0);
        -- master axi write bus valid signal
        m_axi_wvalid  : out std_logic;
        -- master axi write ready-to-accept signal
        m_axi_wready  : in std_logic;

        -- master axi write response indicator
        m_axi_bresp   : in std_logic_vector(1 downto 0);
        -- master axi write response valid signal
        m_axi_bvalid  : in std_logic;
        -- master axi write response ready-to-accept signal
        m_axi_bready  : out std_logic;

        -- master axi read address channel
        m_axi_araddr  : out std_logic_vector(31 downto 0);
        -- master axi read address protection level
        m_axi_arprot  : out std_logic_vector(2 downto 0);
        -- master axi read address valid signal
        m_axi_arvalid : out std_logic;
        -- master axi read address ready-to-accept signal
        m_axi_arready : in std_logic;

        -- master axi read data channel
        m_axi_rdata   : in std_logic_vector(31 downto 0);
        -- master axi read response indicator
        m_axi_rresp   : in std_logic_vector(1 downto 0);
        -- master axi read valid signal
        m_axi_rvalid  : in std_logic;
        -- master axi read ready signal
        m_axi_rready  : out std_logic
    );
end entity TrngController;

architecture rtl of TrngController is
begin
    
    eCore : entity ostrngs.TrngControllerCore
    generic map (
        cClockFrequency_Hz => cClockFrequency_Hz,
        cUartBaudRate_bps  => cUartBaudRate_bps
    ) port map (
        i_clk    => i_clk, 
        i_resetn => i_resetn, 

        o_uart_tx => o_uart_tx,
        i_uart_rx => i_uart_rx,

        o_m_axi_awaddr  => m_axi_awaddr,
        o_m_axi_awprot  => m_axi_awprot,
        o_m_axi_awvalid => m_axi_awvalid,
        i_m_axi_awready => m_axi_awready,

        o_m_axi_wdata   => m_axi_wdata,
        o_m_axi_wstrb   => m_axi_wstrb,
        o_m_axi_wvalid  => m_axi_wvalid,
        i_m_axi_wready  => m_axi_wready,

        i_m_axi_bresp   => m_axi_bresp,
        i_m_axi_bvalid  => m_axi_bvalid,
        o_m_axi_bready  => m_axi_bready,

        o_m_axi_araddr  => m_axi_araddr,
        o_m_axi_arprot  => m_axi_arprot,
        o_m_axi_arvalid => m_axi_arvalid,
        i_m_axi_arready => m_axi_arready,

        i_m_axi_rdata   => m_axi_rdata,
        i_m_axi_rresp   => m_axi_rresp,
        i_m_axi_rvalid  => m_axi_rvalid,
        o_m_axi_rready  => m_axi_rready
    );
    
end architecture rtl;