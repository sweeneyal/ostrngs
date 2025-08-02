-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library unisim;
    use unisim.vcomponents.all;

entity ClockMux is
    generic (
        cNumClocks : positive := 6
    );
    port (
        -- set of possible clocks
        i_clks : in std_logic_vector(cNumClocks - 1 downto 0);
        -- select signals to determine clock output
        i_sel  : in std_logic_vector(cNumClocks - 2 downto 0);
        -- output selected clock
        o_clk  : out std_logic
    );
end entity ClockMux;

architecture rtl of ClockMux is
    signal clk_staged : std_logic_vector(cNumClocks - 1 downto 0) := (others => '0');
begin
    
    clk_staged(0) <= i_clks(0);

    gCascadingMuxes: for g_ii in 0 to cNumClocks - 2 generate
    begin
        eMux : BUFGMUX
        port map (
            I0 => clk_staged(g_ii),
            I1 => i_clks(g_ii + 1),
            S  => i_sel(g_ii),
            O  => clk_staged(g_ii + 1)
        );
    end generate gCascadingMuxes;
    
    o_clk <= clk_staged(cNumClocks - 1);

end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------