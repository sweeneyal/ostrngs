library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngTestbed is
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
        -- entropy sample output 
        o_rng_data  : out std_logic_vector(31 downto 0);
        -- indicator that entropy sample is valid
        o_rng_valid : out std_logic
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
        o_rng_data  => o_rng_data,
        o_rng_valid => o_rng_valid
    );
    
end architecture rtl;