library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity tb_CxUnit is
    generic (runner_cfg : string);
end entity tb_CxUnit;

architecture rtl of tb_CxUnit is
    signal in0  : std_logic;
    signal in1  : std_logic;
    signal out0 : std_logic;
    signal out1 : std_logic;
begin
    
    eDut : entity ostrngs.CxUnit
    generic map (
        cSim_TransportDelay_ps => 100
    ) port map (
        i_in0  => in0,
        i_in1  => in1,
        o_out0 => out0,
        o_out1 => out1
    );

    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_cxunit_demo") then
                in0 <= '0';
                in1 <= '0';

                wait for 100 ps;
                report std_logic'image(out0);
                report std_logic'image(out1);
                check(out0 = '0');
                check(out1 = '0');

                in0 <= '1';
                in1 <= '0';

                wait for 100 ps;
                report std_logic'image(out0);
                report std_logic'image(out1);
                check(out0 = '0');
                check(out1 = '0');

                in0 <= '1';
                in1 <= '0';

                wait for 100 ps;
                report std_logic'image(out0);
                report std_logic'image(out1);
                check(out0 = '1');
                check(out1 = '0');

                in0 <= '1';
                in1 <= '0';

                wait for 100 ps;
                report std_logic'image(out0);
                report std_logic'image(out1);
                check(out0 = '1');
                check(out1 = '1');

                in0 <= '1';
                in1 <= '0';

                wait for 100 ps;
                report std_logic'image(out0);
                report std_logic'image(out1);
                check(out0 = '0');
                check(out1 = '1');

                in0 <= '1';
                in1 <= '0';

                wait for 100 ps;
                report std_logic'image(out0);
                report std_logic'image(out1);
                check(out0 = '0');
                check(out1 = '0');
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture rtl;