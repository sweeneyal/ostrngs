library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity tb_StrTrng is
    generic (runner_cfg : string);
end entity tb_StrTrng;

architecture rtl of tb_StrTrng is
    signal clk    : std_logic;
    signal resetn : std_logic;
    signal mode   : std_logic;
    signal set    : std_logic_vector(44 downto 0);
    signal rng    : std_logic_vector(0 downto 0);
begin

    eDut : entity ostrngs.StrTrng
    port map (
        i_clk    => clk,
        i_resetn => resetn,
        o_rng    => rng
    );
    
    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_strtrng_demo") then
                check(false);
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture rtl;