library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
library osvvm;
    use osvvm.TbUtilPkg.all;
    
library ostrngs;

entity tb_OpenLoopMetaTrng is
    generic (runner_cfg : string);
end entity tb_OpenLoopMetaTrng;

architecture rtl of tb_OpenLoopMetaTrng is
    signal clk_i    : std_logic := '0';
    signal resetn_i : std_logic := '0';
    signal rng_o    : std_logic_vector(0 downto 0) := "0";
    signal valid_o  : std_logic := '0';
begin

    CreateClock(clk=>clk_i, period=>10 ns);

    eDut : entity ostrngs.OpenLoopMetaTrng
    generic map (
        cSimCoarseDelay_ps => 3000,
        cSimFineDelay_ps   => 100,
        cNumCoarseStages   => 10,
        cNumFineStages     => 4
    ) port map (
        i_clk    => clk_i,
        i_resetn => resetn_i,
        o_rng    => rng_o,
        o_valid  => valid_o
    );
    
    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("t_openloopmetatrng_demo") then
                resetn_i <= '0';
                wait until rising_edge(clk_i);
                wait for 100 ps;
                resetn_i <= '1';

                wait until valid_o = '1';
            end if;
        end loop;
        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 2 ms);
    
end architecture rtl;