library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library hector_trng_designs;

entity EroTrng is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(0 downto 0);
        o_valid  : out std_logic
    );
end entity EroTrng;

architecture rtl of EroTrng is
    signal ro_ena       : std_logic := '0';
    signal ro1_out_s    : std_logic := '0';
    signal ro2_out_s    : std_logic := '0';
    signal sampling_clk : std_logic := '0';

    signal cnt     : unsigned(15 downto 0) := (others => '0');
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
        length => 5
    ) port map (
        ena     => ro_ena,
        osc_out => ro1_out_s
    );

    ro2_inst : entity hector_trng_designs.RO_core
    generic map (
        length => 5
    ) port map (
        ena     => ro_ena,
        osc_out => ro2_out_s
    );

    SampleClockCounter: process(ro2_out_s, i_resetn)
    begin
        if (i_resetn = '0') then
            cnt <= (others => '0');
        elsif rising_edge(ro2_out_s) then
            if cnt = 20000 then
                cnt <= (others => '0');
                sampling_clk <= '1';
            else
                cnt <= cnt + 1;
                -- Extending the sampling_clk to ensure we catch the pulse.
                if (cnt > 2) then
                    sampling_clk <= '0';
                end if;
            end if;
        end if;
    end process SampleClockCounter;

    SamplingFlop: process(sampling_clk, i_resetn)
    begin
        if (i_resetn = '0') then
            rng_out <= '0';
        elsif rising_edge(sampling_clk) then
            rng_out <= ro1_out_s;
        end if;
    end process SamplingFlop;

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