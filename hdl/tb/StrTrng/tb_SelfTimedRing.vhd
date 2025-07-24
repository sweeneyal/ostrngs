library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity tb_SelfTimedRing is
    generic (runner_cfg : string);
end entity tb_SelfTimedRing;

architecture rtl of tb_SelfTimedRing is
    signal mode : std_logic := '0';
    signal set  : std_logic_vector(4 downto 0) := (others => '0');
    signal c    : std_logic_vector(4 downto 0) := (others => '0');

    function image_slv(s : std_logic_vector) return string is
        variable st : string(1 to s'length) := (others => ' ');
    begin
        for ii in s'range loop
            case s(ii) is
                when '0' =>
                    st(ii + 1) := '0';
                when '1' =>
                    st(ii + 1) := '1';
                when others =>
                    st(ii + 1) := 'x';
            end case;
        end loop;
        return st;
    end function;
begin

    eDut : entity ostrngs.SelfTimedRing
    generic map (
        cNumStages => 5,
        cSim_TransportDelay_ps => 100
    ) port map (
        i_mode => mode,
        i_set  => set,
        o_c    => c
    );
    
    TestRunner : process
    begin
        test_runner_setup(runner, runner_cfg);
  
        while test_suite loop
            if run("t_selftimedring_demo") then
                wait for 100 ps;
                check(c = "00000");
                mode <= '1';
                set  <= "01010";
                wait for 100 ps;
                check(c = "01010");
                mode <= '0';

                for ii in 0 to 100 loop
                    wait for 100 ps;
                    report image_slv(c);
                end loop;
            end if;
        end loop;
    
        test_runner_cleanup(runner);
    end process;
    
end architecture rtl;