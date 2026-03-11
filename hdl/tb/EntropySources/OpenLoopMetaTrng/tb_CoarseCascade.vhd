library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library osvvm;
    use osvvm.TbUtilPkg.all;

library ostrngs;

entity tb_CoarseCascade is
    generic (runner_cfg : string);
end entity tb_CoarseCascade;

architecture rtl of tb_CoarseCascade is
    constant cNumStages : natural := 64;
    signal clk  : std_logic := '0';
    signal ctrc : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal ctrd : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal c    : std_logic := '0';
    signal d    : std_logic := '0';
begin

    CreateClock(clk=>clk, period=>20 ns);

    eDut : entity ostrngs.CoarseCascade
    port map (
        i_clk  => clk,
        i_ctrc => ctrc,
        i_ctrd => ctrd,
        o_c    => c,
        o_d    => d
    );
    
    TestRunner : process
        variable tic : time;
        variable toc : time;
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_coarsecascade_demo") then
                info("Checking that each coarse delay chain works as expected for a simulated 100 ps delay.");
                for ii in 0 to cNumStages - 1 loop
                    ctrd <= (others => '0');
                    wait for 1 fs;
                    for jj in 0 to cNumStages - 1 loop
                        info("Running iteration (ii, jj): (" & natural'image(ii) & ", " & natural'image(jj) & ")");
                        info("> ctrc = " & to_hstring(ctrc));
                        info("> ctrd = " & to_hstring(ctrd));
                        wait until rising_edge(clk);
                        if ii >= jj then
                            wait until c = '1';
                            tic := now;
                            if (d /= '1') then
                                wait until d = '1';
                            end if;
                            toc := now;
                            report real'image((real(toc / 1 ps) - real(tic / 1 ps))/ 1000.0);
                            report real'image((1.05 * real(ii - jj) * 0.100));
                            report real'image((0.95 * real(ii - jj) * 0.100));
                            check((real(toc / 1 ps) - real(tic / 1 ps))/ 1000.0 <= (1.05 * real(ii - jj) * 0.100), 
                                "-> Failed ii <= jj; time delta is greater than 1.05.");
                            check((real(toc / 1 ps) - real(tic / 1 ps))/ 1000.0 >= (0.95 * real(ii - jj) * 0.100), 
                                "-> Failed ii <= jj; time delta is less than 0.95.");
                        else
                            wait until d = '1';
                            tic := now;
                            if (c /= '1') then
                                wait until c = '1';
                            end if;
                            toc := now;
                            report real'image((real(toc / 1 ps) - real(tic / 1 ps))/ 1000.0);
                            report real'image((1.05 * real(jj - ii) * 0.100));
                            report real'image((0.95 * real(jj - ii) * 0.100));
                            check((real(toc / 1 ps) - real(tic / 1 ps))/ 1000.0 <= (1.05 * real(jj - ii) * 0.100), 
                                "-> Failed ii > jj; time delta is greater than 1.05.");
                            check((real(toc / 1 ps) - real(tic / 1 ps))/ 1000.0 >= (0.95 * real(jj - ii) * 0.100), 
                                "-> Failed ii > jj; time delta is less than 0.95.");
                        end if;
    
                        ctrd(jj) <= '1';
                    end loop;

                    ctrc(ii) <= '1';
                end loop;
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture rtl;