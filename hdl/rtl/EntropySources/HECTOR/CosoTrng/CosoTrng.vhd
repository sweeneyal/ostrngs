library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library hector_trng_designs;

entity CosoTrng is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(0 downto 0);
        o_valid  : out std_logic
    );
end entity CosoTrng;

architecture rtl of CosoTrng is
    signal ro_ena       : std_logic := '0';
    signal ro1_out_s    : std_logic := '0';
    signal ro2_out_s    : std_logic := '0';
    signal sampling_clk : std_logic := '0';

    signal Tbeat   : std_logic := '1';
    signal cnt     : std_logic := '0';
    signal rng_out : std_logic := '0';

    signal sampling_clk_r0 : std_logic := '0';
    signal rng_out_r0      : std_logic := '0';
    signal sampling_clk_r1 : std_logic := '0';
    signal rng_out_r1      : std_logic := '0';
begin
    
    -- Original implementation by Petura et. al.

    ro_ena <= not i_resetn;

    ro1_inst : entity hector_trng_designs.RO_core
    generic map (
        length => 20
    ) port map (
        ena     => ro_ena,
        osc_out => ro1_out_s
    );

    ro2_inst : entity hector_trng_designs.RO_core
    generic map (
        length => 20
    ) port map (
        ena     => ro_ena,
        osc_out => ro2_out_s
    );

    sampling_clk <= ro2_out_s;

    TBeatDff: process(sampling_clk)
    begin
        if (i_resetn = '0') then
            Tbeat <= '1';
        elsif rising_edge(sampling_clk) then
            Tbeat <= ro1_out_s;
        end if;
    end process TBeatDff;

    TffCounter: process(sampling_clk, Tbeat)
    begin
        if (Tbeat = '1') then
            cnt <= '0';
        elsif rising_edge(sampling_clk) then
            cnt <= not cnt;
        end if;
    end process TffCounter;

    RngBit: process(i_resetn, Tbeat)
    begin
        if (i_resetn = '0') then
            rng_out <= '0';
        elsif rising_edge(Tbeat) then
            rng_out <= cnt;
        end if;
    end process RngBit;

    -- Additional hardware added to integrate with TrngGenerator

    SamplingStateMachine: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                o_rng(0) <= '0';
                o_valid  <= '0';
            else
                o_valid <= '0';

                -- Sample the clock and random bit twice to find the rising edge, 
                -- and then pass that bit to the downstream logic.

                -- This assumes the sampling clock is much slower than the running clock.
                sampling_clk_r0 <= sampling_clk;
                rng_out_r0 <= rng_out;

                sampling_clk_r1 <= sampling_clk_r0;
                rng_out_r1 <= rng_out_r0;
                if (sampling_clk_r0 = '1' and sampling_clk_r1 = '0') then
                    o_rng(0) <= rng_out_r0;
                    o_valid  <= '1';
                end if;
            end if;
        end if;
    end process SamplingStateMachine;
    
end architecture rtl;