library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity tb_CoarseCascade is
    generic (runner_cfg : string);
end entity tb_CoarseCascade;

architecture rtl of tb_CoarseCascade is
    
begin
    
    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_coarsecascade_demo") then
                check(false);
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture rtl;