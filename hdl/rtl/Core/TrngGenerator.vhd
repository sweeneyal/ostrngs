-----------------------------------------------------------------------------------------------------------------------
-- entity: TrngGenerator
--
-- library: ostrngs
--
-- description:
--       Core generative file that instantiates all supported types of entropy sources. Uses VHDL-2008 
--       techniques, and as such often requires a wrapper file for instantiation in Vivado block diagrams.
--       Provides an address interface to select which entropy source is being output on the o_rng_* busses,
--       and provides DRP access to the sampling clock PLL on the [io]_pll* busses.
--
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library ostrngs;

entity TrngGenerator is
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
        cDataWidth_B       : positive := 1
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- entropy source selection
        i_rng_addr   : in std_logic_vector(7 downto 0);
        -- entropy source enable signals
        i_rng_enable : in std_logic_vector(7 downto 0);
        -- entropy source sample clock
        o_rng_clk    : out std_logic;
        -- entropy sample output 
        o_rng_data   : out std_logic_vector(8 * cDataWidth_B - 1 downto 0);
        -- indicator that entropy sample is valid
        o_rng_dvalid : out std_logic;

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
end entity TrngGenerator;

architecture rtl of TrngGenerator is
    function padded(s: string; len: positive) return string is
        variable s_out: string(1 to len) := (others => ' ');
    begin
        if s'length >= len then
            s_out := s(1 to len); --- truncate the source string
        else
            s_out(1 to s'length) := s;
            s_out(s'length+1 to len) := (others => ' ');
        end if;
        return s_out;
    end;

    type string_array_t is array (0 to cNumEntropySources - 1) of string(1 to 256);
    constant cEntropySources : string_array_t := (
        padded(cEntropySource00, 256),
        padded(cEntropySource01, 256),
        padded(cEntropySource02, 256),
        padded(cEntropySource03, 256),
        padded(cEntropySource04, 256),
        padded(cEntropySource05, 256),
        padded(cEntropySource06, 256),
        padded(cEntropySource07, 256)
    );

    type rng_matrix_t is array (0 to cNumEntropySources - 1) of std_logic_vector(8 * cDataWidth_B - 1 downto 0);
    
    signal rng        : rng_matrix_t := (others => (others => '0'));
    signal rng_dvalid : std_logic_vector(cNumEntropySources - 1 downto 0) := (others => '0');
    
    constant cNumClocks : natural := 6;
    type sel_matrix_t is array (0 to cNumEntropySources - 1) of std_logic_vector(cNumClocks - 2 downto 0);
    signal clks       : std_logic_vector(cNumClocks - 1 downto 0) := (others => '0');
    signal sel        : sel_matrix_t := (others => (others => '0'));
    signal clk_sel    : std_logic_vector(cNumClocks - 2 downto 0) := (others => '0');
    signal rng_clk    : std_logic := '0';
    signal rng_resetn : std_logic := '0';
begin

    -- Each clock (there being 6 clocks) is dedicated to a type of entropy source. The multiplexor allows for
    -- different clocks to be changed individually without changing the active clock being used for 
    -- the currently selected entropy source.
    eClockManager : entity ostrngs.ClockManager
    port map (
        i_clk    => i_clk,
        i_resetn => i_resetn,

        i_pll_daddr => i_pll_daddr,
        i_pll_den   => i_pll_den,
        i_pll_dwe   => i_pll_dwe,
        i_pll_di    => i_pll_di,
        o_pll_drdy  => o_pll_drdy,
        o_pll_do    => o_pll_do,

        o_pll_clks   => clks,
        o_pll_locked => o_pll_locked
    );

    clk_sel <= sel(to_integer(unsigned(i_rng_addr)));

    eClockMux : entity ostrngs.ClockMux
    generic map (
        cNumClocks => cNumClocks
    ) port map (
        i_clks => clks,
        i_sel  => clk_sel,
        o_clk  => rng_clk
    );
    
    o_rng_clk    <= rng_clk;
    o_rng_data   <= rng(to_integer(unsigned(i_rng_addr)));
    o_rng_dvalid <= rng_dvalid(to_integer(unsigned(i_rng_addr)));

    gEntropySourceInstantiation: for g_ii in 0 to cNumEntropySources - 1 generate
        gMeshCoupledXor: if (cEntropySources(g_ii) = padded("MeshCoupledXor", 256)) generate
            signal local_rng : std_logic_vector(5 downto 0) := (others => '0');
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;

            eMeshCoupledXor : entity ostrngs.MeshCoupledXor
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gMeshCoupledXor;

        gOpenLoopMetaTrng: if (cEntropySources(g_ii) = padded("OpenLoopMetaTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;

            eOpenLoopMeta : entity ostrngs.OpenLoopMetaTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gOpenLoopMetaTrng;

        gStrTrng: if (cEntropySources(g_ii) = padded("StrTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;
        
            eStrTrng : entity ostrngs.StrTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

            -- This entropy source generates a new random sample every clock cycle it is active.
            rng_dvalid(g_ii) <= local_resetn;
        end generate gStrTrng;

        gXorRingTrng: if (cEntropySources(g_ii) = padded("XorRingTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;
        
            eXorRingTrng : entity ostrngs.XorRingTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gXorRingTrng;

        gDnoTrng: if (cEntropySources(g_ii) = padded("DigitalNonlinearOscillator", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;
        
            eDnoTrng : entity ostrngs.DnoTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gDnoTrng;

        gHybridFfsrTrng: if (cEntropySources(g_ii) = padded("HybridFfsrTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;
        
            eHybridFfsrTrng : entity ostrngs.HybridFfsrTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gHybridFfsrTrng;

        gLwxnorLutTrng: if (cEntropySources(g_ii) = padded("LwxnorLutTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;
        
            eLwxnorLutTrng : entity ostrngs.LwxnorLutTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gLwxnorLutTrng;

        gLwxnorTrng: if (cEntropySources(g_ii) = padded("LwxnorTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;
        
            eLwxnorTrng : entity ostrngs.LwxnorTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gLwxnorTrng;

        gRoLdceTrng: if (cEntropySources(g_ii) = padded("RoLdceTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
            signal local_resetn : std_logic;
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;
        
            eRoLdceTrng : entity ostrngs.RoLdceTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => local_resetn,
                o_rng    => local_rng,
                o_valid  => rng_dvalid(g_ii)
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 8 * cDataWidth_B));

        end generate gRoLdceTrng;

        -- Synthesizable test counter that increments once per clock cycle
        gTestSource: if (cEntropySources(g_ii) = padded("Test", 256)) generate
            signal local_rng    : unsigned(8 * cDataWidth_B - 1 downto 0) := (others => '1');
            signal local_resetn : std_logic := '0';
        begin

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;

            TestCounter: process(i_clk)
            begin
                if rising_edge(i_clk) then
                    if (local_resetn = '0') then
                        -- Reset to all '1's so first valid output is all '0's
                        local_rng <= (others => '1');
                        rng_dvalid(g_ii) <= '0';
                    else
                        local_rng <= local_rng + 1;
                        rng_dvalid(g_ii) <= '1';
                    end if;
                end if;
            end process TestCounter;

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit into the o_rng_data bus.
            rng(g_ii) <= std_logic_vector(local_rng);

        end generate gTestSource;

        -- Nonsynthesizable simulated entropy source that allows sim testing with randomness.
        gNonSynth: if (cEntropySources(g_ii) = padded("Simulation", 256)) generate
            signal local_resetn : std_logic;
        begin

            -- synthesis_translate off

            RngResetnPulseExtender: process(rng_clk, i_resetn, i_rng_enable(g_ii))
                variable timer : natural range 0 to 2 := 2;
            begin
                if ((i_resetn and i_rng_enable(g_ii)) = '0') then
                    local_resetn <= '0';
                    timer := 2;
                elsif rising_edge(rng_clk) then
                    if (timer = 0) then
                        local_resetn <= '1';
                    else
                        timer := timer - 1;
                    end if;
                end if;
            end process RngResetnPulseExtender;

            SimulatedEntropySource: process(rng_clk)
                variable seed1, seed2 : integer := 999 / (g_ii + 1);

                impure function rand_slv(len : integer) return std_logic_vector is
                    variable r : real;
                    variable slv : std_logic_vector(len - 1 downto 0);
                begin
                    for i in slv'range loop
                        uniform(seed1, seed2, r);
                        slv(i) := '1' when r > 0.5 else '0';
                    end loop;
                    return slv;
                end function;
            begin
                if rising_edge(rng_clk) then
                    -- generate a random slv every clock cycle
                    rng(g_ii) <= rand_slv(8 * cDataWidth_B);
                    -- 
                    -- This entropy source generates a new random sample every clock cycle it is active.
                    rng_dvalid(g_ii) <= local_resetn and i_rng_enable(g_ii);
                end if;
            end process SimulatedEntropySource;

            -- synthesis_translate on

            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

        end generate gNonSynth;
    end generate gEntropySourceInstantiation;
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------