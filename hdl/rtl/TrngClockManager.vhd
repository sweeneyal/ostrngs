library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library unisim;
    use unisim.vcomponents.all;

entity TrngClockManager is
    port (
        i_clk : in std_logic; 

        o_clk_mcx : out std_logic;
        o_clk_str : out std_logic;
        o_clk_olm : out std_logic
    );
end entity TrngClockManager;

architecture rtl of TrngClockManager is
begin
    
    -- Instantiate a clocking manager for each frequency as determined by each implementation
    -- mcx ~ 400 MHz
    -- str ~ 60 MHz
    -- ...
    
end architecture rtl;