-----------------------------------------------------------------------------------------------------------------------
-- entity: CxUnit
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

entity CxUnit is
    generic (
        cSim_TransportDelay_ps : natural := 100
    );
    port (
        i_resetn : in std_logic;
        i_in0    : in std_logic;
        i_in1    : in std_logic;
        o_out0   : out std_logic;
        o_out1   : out std_logic
    );
end entity CxUnit;

architecture rtl of CxUnit is
    signal in0 : std_logic :='0';
    signal in1 : std_logic :='0';
    signal out0 : std_logic :='0';
    signal out1 : std_logic :='0';

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of out1 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out0 : signal is "true";
begin
    
    out0 <= transport i_resetn and (i_in0 xor out1) after cSim_TransportDelay_ps * 1 ps;
    out1 <= transport i_resetn and (i_in1 xor out0) after cSim_TransportDelay_ps * 1 ps;

    o_out0 <= out0;
    o_out1 <= out1;
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------