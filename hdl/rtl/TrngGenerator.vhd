-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngGenerator is
    generic (
        cNumEntropySources : positive range 1 to 255 := 8;
        cEntropySource00   : string := "MeshCoupledXor";
        cEntropySource01   : string := "MeshCoupledXor";
        cEntropySource02   : string := "MeshCoupledXor";
        cEntropySource03   : string := "MeshCoupledXor";
        cEntropySource04   : string := "MeshCoupledXor";
        cEntropySource05   : string := "MeshCoupledXor";
        cEntropySource06   : string := "MeshCoupledXor";
        cEntropySource07   : string := "MeshCoupledXor"
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- entropy source selection
        i_rng_addr  : in std_logic_vector(7 downto 0);
        -- entropy source sample clock
        o_rng_clk   : out std_logic;
        -- entropy sample output 
        o_rng_data  : out std_logic_vector(31 downto 0);
        -- indicator that entropy sample is valid
        o_rng_valid : out std_logic;

        -- pll dynamic reconfiguration port address bus
        i_pll_daddr : in std_logic_vector(6 downto 0);
        -- pll dynamic reconfiguration port enable signal
        i_pll_den   : in std_logic;
        -- pll dynamic reconfiguration port write enable signal
        i_pll_dwe   : in std_logic;
        -- pll dynamic reconfiguration port write data bus
        i_pll_di    : in std_logic_vector(15 downto 0);
        -- pll dynamic reconfiguration port data ready signal
        o_pll_drdy  : out std_logic;
        -- pll dynamic reconfiguration port read data bus
        o_pll_do    : out std_logic_vector(15 downto 0);
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

    type rng_matrix_t is array (0 to cNumEntropySources - 1) of std_logic_vector(31 downto 0);
    
    signal rng       : rng_matrix_t := (others => (others => '0'));
    signal rng_valid : std_logic_vector(cNumEntropySources - 1 downto 0) := (others => '0');
    
    constant cNumClocks : natural := 6;
    type sel_matrix_t is array (0 to cNumEntropySources - 1) of std_logic_vector(cNumClocks - 2 downto 0);
    signal clks       : std_logic_vector(cNumClocks - 1 downto 0) := (others => '0');
    signal sel        : sel_matrix_t := (others => (others => '0'));
    signal clk_sel    : std_logic_vector(cNumClocks - 2 downto 0) := (others => '0');
    signal rng_clk    : std_logic := '0';
    signal rng_resetn : std_logic := '0';
begin

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
    
    o_rng_clk   <= rng_clk;
    o_rng_data  <= rng(to_integer(unsigned(i_rng_addr)));
    o_rng_valid <= rng_valid(to_integer(unsigned(i_rng_addr)));

    gEntropySourceInstantiation: for g_ii in 0 to cNumEntropySources - 1 generate
        gMeshCoupledXor: if (cEntropySources(g_ii) = padded("MeshCoupledXor", 256)) generate
            signal local_rng : std_logic_vector(5 downto 0) := (others => '0');
        begin

            eMeshCoupledXor : entity ostrngs.MeshCoupledXor
            port map (
                i_clk    => rng_clk,
                i_resetn => rng_resetn,
                o_rng    => local_rng
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(0, cNumClocks - 1));

            -- Resize the random sample to fit a 32 bit word
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 32));

            -- This entropy source generates a new random sample every clock cycle it is active.
            rng_valid(g_ii) <= rng_resetn;
        end generate gMeshCoupledXor;

        gOpenLoopMetaTrng: if (cEntropySources(g_ii) = padded("OpenLoopMetaTrng", 256)) generate
            signal local_rng : std_logic_vector(0 downto 0) := "0";
        begin

            eOpenLoopMeta : entity ostrngs.OpenLoopMetaTrng
            port map (
                i_clk    => rng_clk,
                i_resetn => rng_resetn,
                o_rng    => local_rng
            );

            -- Makes a constant select value to be selected by the i_rng_addr bus to the mux.
            sel(g_ii) <= std_logic_vector(to_unsigned(1, cNumClocks - 1));

            -- Resize the random sample to fit a 32 bit word
            rng(g_ii) <= std_logic_vector(resize(unsigned(local_rng), 32));

            -- This entropy source generates a new random sample every clock cycle it is active.
            rng_valid(g_ii) <= rng_resetn;
        end generate gOpenLoopMetaTrng;

        -- gStrTrng: if (str_eq(cEntropySources(g_ii), "StrTrng")) generate
            
        -- end generate gStrTrng;
    end generate gEntropySourceInstantiation;
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------