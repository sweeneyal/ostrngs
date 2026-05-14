library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library osvvm;
    use osvvm.TbUtilPkg.all;

library ostrngs;
    use ostrngs.CommonUtility.all;

library tb_ostrngs;

entity tb_DualClockFifo is
    generic (runner_cfg : string);
end entity tb_DualClockFifo;

architecture tb of tb_DualClockFifo is
    signal clka_i    : std_logic := '1';
    signal resetna_i : std_logic := '0';
    signal push_i    : std_logic := '0';
    signal wdata_i   : std_logic_vector(10 downto 0) := (others => '0');
    signal full_o    : std_logic := '0';

    signal clkb_i    : std_logic := '1';
    signal resetnb_i : std_logic := '0';
    signal pop_i     : std_logic := '0';
    signal rdata_o   : std_logic_vector(10 downto 0) := (others => '0');
    signal empty_o   : std_logic := '0';
begin

    CreateClock(clk=>clka_i, period=>2.623 ns);
    CreateClock(clk=>clkb_i, period=>10 ns);
    
    eDut : entity ostrngs.DualClockFifo
    generic map (
        cAddressWidth_b => 10,
        cDataWidth_b    => 11,
        cVerboseMode    => true,
        cRamID          => "DCF_DUT"
    ) port map (
        i_clka    => clka_i,
        i_resetna => resetna_i,
        i_push    => push_i,
        i_wdata   => wdata_i,
        o_full    => full_o,

        i_clkb    => clkb_i,
        i_resetnb => resetnb_i,
        i_pop     => pop_i,
        o_rdata   => rdata_o,
        o_empty   => empty_o
    );

    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);  
        while test_suite loop
            if run("t_basic") then
                resetna_i <= '0';
                resetnb_i <= '0';

                wait until rising_edge(clka_i);
                resetna_i <= '1';
                
                wait until rising_edge(clkb_i);
                resetnb_i <= '1';

                wait until rising_edge(clkb_i);
                wait until rising_edge(clkb_i);
                check(empty_o = '1');

                wait until rising_edge(clka_i);
                check(full_o = '0');

                wait for 100 ps;

                for ii in 0 to 1023 loop
                    wdata_i <= to_slvu(ii, 11);
                    push_i  <= '1';
                    wait until rising_edge(clka_i);
                    wait for 100 ps;
                end loop;
                push_i <= '0';

                wait until rising_edge(clkb_i);
                for ii in 0 to 1023 loop
                    pop_i <= '1';
                    wait until rising_edge(clkb_i);
                    wait for 100 ps;
                    report to_hstring(rdata_o);
                    check(rdata_o = to_slvu(ii, 11));
                end loop;
                pop_i <= '0';
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 100 us);
    
end architecture tb;