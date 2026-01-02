library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity tb_Lwxnor is
    generic (runner_cfg : string);
end entity tb_Lwxnor;

architecture rtl of tb_Lwxnor is
    signal resetn_i : std_logic := '0';
    signal q_o : std_logic := '0';
begin
    
    eDut : entity ostrngs.Lwxnor
    port map (
        i_resetn => resetn_i,
        o_q => q_o
    );

    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_demo") then
                resetn_i <= '0';
                wait for 10 ns;
                resetn_i <= '1';
                wait for 200 ns;
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture rtl;