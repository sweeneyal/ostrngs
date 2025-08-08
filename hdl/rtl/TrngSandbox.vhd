-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngSandbox is
    generic (
        -- Sets the total number of entropy sources to instantiate
        cNumEntropySources : positive range 1 to 8 := 8;
        -- Provides a mechanism to instantiate various unique entropy sources
        cEntropySource00   : string := "MeshCoupledXor";
        cEntropySource01   : string := "MeshCoupledXor";
        cEntropySource02   : string := "MeshCoupledXor";
        cEntropySource03   : string := "MeshCoupledXor";
        cEntropySource04   : string := "MeshCoupledXor";
        cEntropySource05   : string := "MeshCoupledXor";
        cEntropySource06   : string := "MeshCoupledXor";
        cEntropySource07   : string := "MeshCoupledXor";
        -- Sets the standard data width in bytes for the entropy source output
        cDataWidth_B       : positive := 1;
        -- Fifo width in samples for optimal storage
        cFifoWidth         : positive := 1;
        -- Fifo depth in groups of samples
        cFifoDepth         : positive := 1024
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- entropy source selection
        i_rng_addr   : in std_logic_vector(7 downto 0);
        -- entropy source sample clock
        o_rng_clk    : out std_logic;
        -- entropy sample output 
        o_rng_data   : out std_logic_vector(8 * cDataWidth_B - 1 downto 0);
        -- indicator that entropy sample is valid
        o_rng_dvalid : out std_logic;

        -- external fifo pop signal to output stored TRNG data
        i_fifo_pop    : in std_logic;
        -- external fifo output data bus
        o_fifo_data   : out std_logic_vector(cFifoWidth * cDataWidth_B * 8 - 1 downto 0);
        -- external fifo output data valid indicator
        o_fifo_dvalid : out std_logic;
        -- external fifo full indicator
        o_fifo_full   : out std_logic;
        -- external fifo almost-full indicator
        o_fifo_afull  : out std_logic;
        -- external fifo almost-empty indicator
        o_fifo_aempty : out std_logic;
        -- external fifo empty indicator
        o_fifo_empty  : out std_logic;

        -- pll dynamic reconfiguration port address bus
        i_pll_daddr  : in std_logic_vector(6 downto 0);
        -- pll dynamic reconfiguration port enable signal
        i_pll_den    : in std_logic;
        -- pll dynamic reconfiguration port write enable signal
        i_pll_dwe    : in std_logic;
        -- pll dynamic reconfiguration port write data bus
        i_pll_di     : in std_logic_vector(15 downto 0);
        -- pll dynamic reconfiguration port data ready signal
        o_pll_drdy   : out std_logic;
        -- pll dynamic reconfiguration port read data bus
        o_pll_do     : out std_logic_vector(15 downto 0);
        -- pll lock indicator
        o_pll_locked : out std_logic
    );
end entity TrngSandbox;

architecture rtl of TrngSandbox is
    signal rng_clk    : std_logic := '0';
    signal rng_data   : std_logic_vector(8 * cDataWidth_B - 1 downto 0) := (others => '0');
    signal rng_dvalid : std_logic := '0';
begin

    eTrngs : entity ostrngs.TrngGenerator
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
        cDataWidth_B       => cDataWidth_B
    ) port map (
        i_clk    => i_clk,
        i_resetn => i_resetn,

        i_rng_addr   => i_rng_addr,
        o_rng_clk    => rng_clk,
        o_rng_data   => rng_data,
        o_rng_dvalid => rng_dvalid,

        i_pll_daddr  => i_pll_daddr,
        i_pll_den    => i_pll_den,
        i_pll_dwe    => i_pll_dwe,
        i_pll_di     => i_pll_di,
        o_pll_drdy   => o_pll_drdy,
        o_pll_do     => o_pll_do,
        o_pll_locked => o_pll_locked
    );

    o_rng_clk    <= rng_clk;
    o_rng_data   <= rng_data;
    o_rng_dvalid <= rng_dvalid;

    eFifo : entity ostrngs.TrngStorage
    generic map (
        cDataWidth_B => cDataWidth_B,
        cFifoWidth   => cFifoWidth,
        cFifoDepth   => cFifoDepth
    ) port map (
        i_resetn     => i_resetn,

        i_rng_clk    => rng_clk,
        i_rng_data   => rng_data,
        i_rng_dvalid => rng_dvalid,
        
        i_fifo_clk    => i_clk,
        i_fifo_pop    => i_fifo_pop,
        o_fifo_data   => o_fifo_data,
        o_fifo_dvalid => o_fifo_dvalid,

        o_fifo_full   => o_fifo_full,
        o_fifo_afull  => o_fifo_afull,
        o_fifo_aempty => o_fifo_aempty,
        o_fifo_empty  => o_fifo_empty
    );
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------