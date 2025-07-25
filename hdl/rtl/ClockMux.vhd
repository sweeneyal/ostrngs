library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

entity ClockMux is
    generic (
        cNumClocks : positive := 4
    );
    port (
        i_clks : in std_logic_vector(cNumClocks - 1 downto 0);
        i_sel  : in std_logic_vector(natural(ceil(log2(real(cNumClocks)))) - 1 downto 0);
        o_clk  : out std_logic
    );
end entity ClockMux;

architecture rtl of ClockMux is
    
begin
    
    
    
end architecture rtl;