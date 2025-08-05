-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity TrngStorage is
    generic (
        -- Allows use of the fifo ports to perform readout, instead of forwarding to DDR
        cEnableExternalControl : boolean := true;
        -- Data width in bytes for each sample
        cDataWidth_B : positive := 1;
        -- Fifo width in samples for optimal storage
        cFifoWidth   : positive := 1;
        -- Fifo depth in groups of samples
        cFifoDepth   : positive := 1024
    );
    port (
        -- entropy source sampling clock
        i_rng_clk    : in std_logic;
        -- entropy source data bus
        i_rng_data   : in std_logic_vector(8 * cDataWidth_B - 1 downto 0);
        -- entropy source data valid indicator
        i_rng_dvalid : in std_logic;
        
        -- external fifo measurement clock (only used if cEnableExternalControl is true)
        i_fifo_clk    : in std_logic;
        -- external fifo pop signal 
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
        o_fifo_empty  : out std_logic
    );
end entity TrngStorage;

architecture rtl of TrngStorage is
    
begin
    
    -- Implement a FIFO here that can be externally controlled

    -- FIFO is a Dual clock FIFO with an initial component registering the outputs of the entropy sources
    -- into a storage register between the FIFO and the entropy source. This will allow somewhat arbitrary
    -- widths of consecutive samples to be logged into the FIFO, sort of reducing the throughput requirement.

    -- The initial application of this is to generate a depth of samples, then dump the samples out over the 
    -- external fifo interface to either a processor or other interface with a host PC. The expected end 
    -- application however is to use the FIFO to buffer samples going to external DDR memory and then use a 
    -- processor or other interface to read out the DDR memory, thereby leveraging the FIFO as a form of DMA.
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------