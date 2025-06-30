library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity SelfTimedRing is
    generic (
        cNumStages : natural := 45
    );
    port (
        i_mode : in std_logic;
        i_set  : in std_logic_vector(cNumStages - 1 downto 0);
        o_c    : out std_logic_vector(cNumStages - 1 downto 0)
    );
end entity SelfTimedRing;

architecture rtl of SelfTimedRing is
    signal f : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal r : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal c : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
begin
    
    f <= transport c(cNumStages - 2 downto 0) & c(cNumStages - 1) after 100 ps;
    r <= transport c(0) & c(cNumStages - 1 downto 1) after 100 ps; -- Not sure if this needs to be inverted or not?

    gStrGeneration: for g_ii in 0 to cNumStages - 2 generate
        eMuller : entity ostrngs.MullerC
        port map (
            i_mode => i_mode,
            i_set  => i_set(g_ii),
            i_f    => f(g_ii),
            i_r    => r(g_ii),
            o_c    => c(g_ii)
        );
    end generate gStrGeneration;

    o_c <= c;
    
end architecture rtl;