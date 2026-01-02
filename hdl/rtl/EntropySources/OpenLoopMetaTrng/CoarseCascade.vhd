-----------------------------------------------------------------------------------------------------------------------
-- entity: CoarseCascade
--
-- library: ostrngs
--
-- description:
--       
--
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity CoarseCascade is
    generic (
        cNumStages : natural := 64;
        cSimulatedDelay_ps : natural := 100
    );
    port (
        i_clk  : in std_logic;
        i_ctrc : in std_logic_vector(cNumStages - 1 downto 0);
        i_ctrd : in std_logic_vector(cNumStages - 1 downto 0);
        o_c    : out std_logic;
        o_d    : out std_logic
    );
end entity CoarseCascade;

architecture rtl of CoarseCascade is
    signal c : std_logic_vector(cNumStages downto 0) := (others => '0');
    signal d : std_logic_vector(cNumStages downto 0) := (others => '0');

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of c : signal is "true";
    attribute DONT_TOUCH of d : signal is "true";
begin
    
    -- Make this synthesizable. Only know how to force this to be a LUT with a DONT_TOUCH
    c(0) <= transport i_clk after cSimulatedDelay_ps * 1 ps;
    d(0) <= transport i_clk after cSimulatedDelay_ps * 1 ps;

    gCascade: for g_ii in 0 to cNumStages - 1 generate

        Mux21_Clk: process(i_ctrc(g_ii), c(g_ii), i_clk)
        begin
            if (i_ctrc(g_ii) = '0') then
                c(g_ii + 1) <= transport c(g_ii) after cSimulatedDelay_ps * 1 ps;
            else
                c(g_ii + 1) <= i_clk;
            end if;            
        end process Mux21_Clk;

        Mux21_Data: process(i_ctrd(g_ii), d(g_ii), i_clk)
        begin
            if (i_ctrd(g_ii) = '0') then
                d(g_ii + 1) <= transport d(g_ii) after cSimulatedDelay_ps * 1 ps;
            else
                d(g_ii + 1) <= i_clk;
            end if;            
        end process Mux21_Data;

    end generate gCascade;

    o_c <= c(cNumStages);
    o_d <= d(cNumStages);
    
end architecture rtl;