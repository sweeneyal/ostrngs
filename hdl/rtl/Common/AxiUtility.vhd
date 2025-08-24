-----------------------------------------------------------------------------------------------------------------------
-- package: AxiUtility
--
-- library: ostrngs
--
-- description:
--       This package is created to make the types required to define the addresses and masks for the AxiCrossbar
--       globally available.
--
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package AxiUtility is
    
    type address_array_t is array (natural range <>) of std_logic_vector;
    type mask_array_t is array (natural range <>) of std_logic_vector;
    
end package AxiUtility;