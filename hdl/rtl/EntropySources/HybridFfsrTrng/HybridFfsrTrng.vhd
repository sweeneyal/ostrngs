library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity HybridFfsrTrng is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(0 downto 0);
        o_valid  : out std_logic
    );
end entity HybridFfsrTrng;

architecture rtl of HybridFfsrTrng is
    signal sel    : std_logic_vector(1 downto 0) := (others => '0');
    signal sel_ro : std_logic := '0';
    signal sig    : std_logic := '0';
    signal dffs   : std_logic_vector(1 downto 0) := (others => '0');
    signal dff0   : std_logic := '0';
begin
    
    eInjector : entity ostrngs.EntropyInjector
    port map (
        i_resetn => i_resetn,
        i_sel    => sel,
        o_ro     => sel_ro,
        o_ro1a   => sig
    );

    eFfsr : entity ostrngs.FeedforwardShiftRegister
    port map (
        i_clk => i_clk,
        i_resetn => i_resetn,
        i_sel => sel_ro,
        i_sig => sig,
        o_dff => dff0
    );

    eSampler : entity ostrngs.DynamicSampler
    port map (
        i_clk    => i_clk,
        i_resetn => i_resetn,
        o_sel    => sel,
        o_dff    => dffs
    );

    o_rng(0) <= dffs(1) xor dffs(0) xor dff0;

    -- This is added since at reset the shift register is primed with non-entropic zeros.
    -- This waits until the non-entropic zeros are replaced with entropic symbols.
    ValidSignal: process(i_clk, i_resetn)
        variable timer : natural range 0 to 6 := 6;
    begin
        if (i_resetn = '0') then
            o_valid <= '0';
            timer := 6;
        elsif rising_edge(i_clk) then
            if (timer = 0) then
                o_valid <= '1';
            else
                timer := timer - 1;
            end if;
        end if;
    end process ValidSignal;
    
end architecture rtl;