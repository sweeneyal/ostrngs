library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity tb_MullerC is
    generic (runner_cfg : string);
end entity tb_MullerC;

architecture rtl of tb_MullerC is
    signal mode : std_logic := '0';
    signal set  : std_logic := '0';
    signal f    : std_logic := '0';
    signal r    : std_logic := '0';
    signal c    : std_logic := '0';
begin

    eDut : entity ostrngs.MullerC
    port map (
        i_mode => mode,
        i_set  => set,
        i_f    => f,
        i_r    => r,
        o_c    => c
    );
    
    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_mullerc_demo") then
                check(c = '0');
                wait for 100 ps;
                check(c = '0');
                check(c'stable(100 ps));

                mode <= '1';
                set  <= '0';
                wait for 100 ps;
                mode <= '0';
                check(c = '0');
                check(c'stable(200 ps));

                wait for 100 ps;
                check(c = '0');
                check(c'stable(300 ps));

                mode <= '1';
                set  <= '1';
                wait for 100 ps;
                mode <= '0';
                check(c = '1');
                check(c'stable(100 ps));

                wait for 100 ps;
                check(c = '1');
                check(c'stable(200 ps));
                
                r <= '1';
                f <= '0';
                wait for 100 ps;
                check(c = '0');
                check(c'stable(100 ps));

                r <= '1';
                f <= '1';
                wait for 100 ps;
                check(c = '0');
                check(c'stable(200 ps));

                r <= '0';
                f <= '1';
                wait for 100 ps;
                check(c = '1');
                check(c'stable(100 ps));

                r <= '0';
                f <= '0';
                wait for 100 ps;
                check(c = '1');
                check(c'stable(200 ps));
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture rtl;