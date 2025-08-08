-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngStorage is
    generic (
        -- Data width in bytes for each sample
        cDataWidth_B : positive := 1;
        -- Fifo width in samples for optimal storage
        cFifoWidth   : positive := 1;
        -- Fifo depth in groups of samples
        cFifoDepth   : positive := 1024
    );
    port (
        -- reset signal to reset the FIFO logic
        i_resetn : in std_logic;

        -- entropy source sampling clock
        i_rng_clk    : in std_logic;
        -- entropy source data bus
        i_rng_data   : in std_logic_vector(8 * cDataWidth_B - 1 downto 0);
        -- entropy source data valid indicator
        i_rng_dvalid : in std_logic;
        
        -- external fifo measurement clock
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
    signal rng_data   : std_logic_vector(8 * cDataWidth_B * cFifoWidth - 1 downto 0) := (others => '0');
    signal rng_dvalid : std_logic := '0';
begin
    
    SampleAggregator: process(i_rng_clk)
        variable idx : natural range 0 to cFifoWidth - 1 := 0;
    begin
        if rising_edge(i_rng_clk) then
            rng_dvalid <= '0';
            if (i_rng_dvalid = '1') then
                rng_data(
                    8 * cDataWidth_B * (idx + 1) - 1 downto 
                    8 * cDataWidth_B * idx) <= i_rng_data;

                if (idx = cFifoWidth - 1) then
                    idx := 0;
                    rng_dvalid <= '1';
                else
                    idx := idx + 1;
                end if;
            end if;
        end if;
    end process SampleAggregator;

    eFifo : entity ostrngs.DualClockFifo
    generic map (
        cDepth       => cFifoDepth,
        cDataWidth_b => cFifoWidth * cDataWidth_B * 8
    ) port map (
        i_clka   => i_rng_clk,
        i_clkb   => i_fifo_clk,
        i_resetn => '1',

        i_data_a  => rng_data,
        i_valid_a => rng_dvalid,

        i_pop_b   => i_fifo_pop,
        o_data_b  => o_fifo_data,
        o_valid_b => o_fifo_dvalid,

        o_fifo_full   => o_fifo_full,
        o_fifo_afull  => o_fifo_afull,
        o_fifo_aempty => o_fifo_aempty,
        o_fifo_empty  => o_fifo_empty
    );

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