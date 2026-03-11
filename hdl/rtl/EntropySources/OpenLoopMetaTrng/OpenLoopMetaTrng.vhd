-----------------------------------------------------------------------------------------------------------------------
-- entity: OpenLoopMetaTrng
--
-- library: ostrngs
--
-- description:
--       
--
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library unisim;
    use unisim.vcomponents.all;

library ostrngs;

entity OpenLoopMetaTrng is
    generic (
        cSimFineDelay_ps   : natural := 50;
        cSimCoarseDelay_ps : natural := 100;
        cNumCoarseStages   : natural := 64;
        cNumFineStages     : natural := 16
    );
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(0 downto 0);
        o_valid  : out std_logic
    );
end entity OpenLoopMetaTrng;

architecture rtl of OpenLoopMetaTrng is
    -- constant cNumFineStages   : natural := 16;
    constant cNumFineBits     : natural := cNumFineStages * 4;
    -- constant cNumCoarseStages : natural := 64;

    signal c_init : std_logic := '0';
    signal d_init : std_logic := '0';

    signal carries_c       : std_logic_vector(cNumFineBits - 1 downto 0) := (others => '0');
    signal carries_c_delay : std_logic_vector(cNumFineBits - 1 downto 0) := (others => '0');
    signal carries_d       : std_logic_vector(cNumFineBits - 1 downto 0) := (others => '0');
    signal carries_d_delay : std_logic_vector(cNumFineBits - 1 downto 0) := (others => '0');

    signal d_latch : std_logic_vector(cNumFineBits - 1 downto 0) := (others => '0');
    signal d_reg   : std_logic_vector(cNumFineBits - 1 downto 0) := (others => '0');
    signal merge_d : std_logic := '0';

    signal ctrc : std_logic_vector(cNumCoarseStages - 1 downto 0) := (others => '0');
    signal ctrd : std_logic_vector(cNumCoarseStages - 1 downto 0) := (others => '0');
    type counter_array_t is array (0 to cNumFineBits - 1) of unsigned(7 downto 0);
    signal counters : counter_array_t  := (others => (others => '0'));
    signal health_reg : natural range 0 to cNumFineBits := 0;

    type state_t is (RESET, ACTIVE);
    signal state : state_t := ACTIVE;

    constant cUpperBound : natural := 128 + 50;
    constant cLowerBound : natural := 128 - 50;

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of c_init    : signal is "true";
    attribute DONT_TOUCH of d_init    : signal is "true";
    attribute DONT_TOUCH of carries_c : signal is "true";
    attribute DONT_TOUCH of carries_d : signal is "true";
begin
    
    eCascade : entity ostrngs.CoarseCascade
    generic map (
        cNumStages => cNumCoarseStages,
        cSimulatedDelay_ps => cSimCoarseDelay_ps
    ) port map (
        i_clk  => i_clk,
        i_ctrc => ctrc,
        i_ctrd => ctrd,
        o_c    => c_init,
        o_d    => d_init
    );

    eFirstCarry_D : CARRY4
    port map (
        CI     => '0',
        CYINIT => d_init,
        CO     => carries_d(3 downto 0),
        O      => open,
        DI     => "0000",
        S      => "1111"
    );

    eFirstCarry_C : CARRY4
    port map (
        CI     => '0',
        CYINIT => c_init,
        CO     => carries_c(3 downto 0),
        O      => open,
        DI     => "0000",
        S      => "1111"
    );

    gFineDelayGeneration: for g_ii in 1 to cNumFineStages - 1 generate
        eCarry_D : CARRY4
        port map (
            CI     => carries_d(4 * (g_ii - 1) + 3),
            CYINIT => '0',
            CO     => carries_d(4 * g_ii + 3 downto 4 * g_ii),
            O      => open,
            DI     => "0000",
            S      => "1111"
        );

        eCarry_C : CARRY4
        port map (
            CI     => carries_c(4 * (g_ii - 1) + 3),
            CYINIT => '0',
            CO     => carries_c(4 * g_ii + 3 downto 4 * g_ii),
            O      => open,
            DI     => "0000",
            S      => "1111"
        );
    end generate gFineDelayGeneration; 

    SimulateDelay: process(carries_c, carries_d)
    begin
        for ii in 0 to cNumFineBits - 1 loop
            carries_d_delay(ii) <= transport carries_d(ii) after (ii + 1) * cSimFineDelay_ps * 1 ps;
            carries_c_delay(ii) <= transport carries_c(ii) after (ii + 1) * cSimFineDelay_ps * 1 ps;
        end loop;
    end process SimulateDelay;

    gSampleLatches: for g_ii in 0 to cNumFineBits - 1 generate
        SampleLatches: process(i_resetn, carries_c_delay)
        begin
            if (i_resetn = '0') then
                d_latch(g_ii) <= '0';
            elsif (carries_c_delay(g_ii) = '0') then
                d_latch(g_ii) <= carries_d_delay(g_ii);
            end if;
        end process SampleLatches;
    end generate gSampleLatches;

    SamplingFlops: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                d_reg <= (others => '0');
            else
                d_reg <= d_latch;
            end if;
        end if;
    end process SamplingFlops;

    -- This component is unique to our implementation, and seeks to identify the configuration
    -- with the most good random bits for application in the final xor summer.
    -- This is also implemented to standardize the interface to the TRNG, thereby removing 
    -- additional unnecessary controls from the top level implementation.
    StateMachine: process(i_clk)
        variable ctrc_bit   : natural range 0 to cNumCoarseStages - 1 := 0;
        variable ctrd_bit   : natural range 0 to cNumCoarseStages - 1 := 0;
        variable timer      : natural range 0 to 255 := 255;
        variable health     : natural range 0 to cNumFineBits := 0;
        variable max_health : natural range 0 to cNumFineBits := 0;
        variable max_ctrc   : std_logic_vector(cNumCoarseStages - 1 downto 0) := (others => '0');
        variable max_ctrd   : std_logic_vector(cNumCoarseStages - 1 downto 0) := (others => '0');
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                counters   <= (others => (others => '0'));
                state      <= RESET;
                timer      := 255;
                ctrc_bit   := 0;
                ctrd_bit   := 0;
                health     := 0;
                max_health := 0;
                o_valid    <= '0';
            else
                case state is
                    when RESET =>
                        if (timer > 0) then
                            timer := timer - 1;
                            
                            for ii in 0 to cNumFineStages - 1 loop
                                if (d_reg(ii) = '1') then
                                    counters(ii) <= counters(ii) + 1;
                                end if;
                            end loop;
                        else
                            timer := 255;

                            for ii in 0 to cNumFineBits - 1 loop
                                if (counters(ii) < cUpperBound and counters(ii) > cLowerBound) then
                                    health := health + 1;
                                end if;
                            end loop;

                            counters <= (others => (others => '0'));

                            if (health >= max_health) then
                                max_health := health;
                                max_ctrc   := ctrc;
                                max_ctrd   := ctrd;
                            end if;

                            health := 0;

                            ctrc(ctrc_bit) <= '1';
                            ctrd(ctrd_bit) <= '1';

                            if ctrd_bit < cNumCoarseStages - 1 then
                                ctrd_bit := ctrd_bit + 1;
                            else
                                ctrd_bit := 0;
                                ctrd <= (others => '0');
                                if (ctrc_bit < cNumCoarseStages - 1) then
                                    ctrc_bit := ctrc_bit + 1;
                                else
                                    state <= ACTIVE;
                                    ctrc  <= max_ctrc;
                                    ctrd  <= max_ctrd;
                                end if;
                            end if;
                        end if;
                
                    when ACTIVE =>
                        o_valid <= '1';
                        if (timer > 0) then
                            health := 0;
                            timer  := timer - 1;
                            
                            for ii in 0 to cNumFineBits - 1 loop
                                if (d_reg(ii) = '1') then
                                    counters(ii) <= counters(ii) + 1;
                                end if;
                            end loop;
                        else
                            timer := 255;

                            for ii in 0 to cNumFineBits - 1 loop
                                if (counters(ii) < cUpperBound and counters(ii) > cLowerBound) then
                                    health := health + 1;
                                end if;
                            end loop;

                            health_reg <= health;
                            counters   <= (others => (others => '0'));
                        end if;
                end case;
            end if;
        end if;
    end process StateMachine;

    Merge: process(d_reg)
        variable sum : std_logic;
    begin
        sum := d_reg(0);
        for ii in 1 to cNumFineBits - 1 loop
            sum := sum xor d_reg(ii);
        end loop;
        merge_d <= sum;
    end process Merge;

    FinalSampler: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                o_rng(0) <= '0';
            else
                o_rng(0) <= merge_d;
            end if;
        end if;
    end process FinalSampler;
    
end architecture rtl;