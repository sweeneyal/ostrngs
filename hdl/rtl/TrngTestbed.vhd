-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngTestbed is
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
        cEntropySource07   : string := "MeshCoupledXor"
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- entropy source selection
        i_rng_addr  : in std_logic_vector(7 downto 0);
        -- entropy sample clock
        o_rng_clk   : out std_logic;
        -- entropy sample output synchronous to o_rng_clk
        o_rng_data  : out std_logic_vector(31 downto 0);
        -- indicator that entropy sample on rng_data is valid
        o_rng_valid : out std_logic;

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
end entity TrngTestbed;

architecture rtl of TrngTestbed is
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
        cEntropySource07   => cEntropySource07
    ) port map (
        i_clk    => i_clk,
        i_resetn => i_resetn,

        i_rng_addr  => i_rng_addr,
        o_rng_clk   => o_rng_clk,
        o_rng_data  => o_rng_data,
        o_rng_valid => o_rng_valid,

        i_pll_daddr  => i_pll_daddr,
        i_pll_den    => i_pll_den,
        i_pll_dwe    => i_pll_dwe,
        i_pll_di     => i_pll_di,
        o_pll_drdy   => o_pll_drdy,
        o_pll_do     => o_pll_do,
        o_pll_locked => o_pll_locked
    );
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------