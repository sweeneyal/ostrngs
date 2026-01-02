-----------------------------------------------------------------------------------------------------------------------
-- entity: LwxnorLut
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

library unisim;
    use unisim.vcomponents.all;

entity LwxnorLut is
    port (
        i_resetn : in std_logic;
        o_q : out std_logic
    );
end entity LwxnorLut;

architecture rtl of LwxnorLut is
    signal q     : std_logic := '0';
    signal o5    : std_logic := '0';
    signal q_dl  : std_logic := '0';
    signal o5_dl : std_logic := '0';

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of eLut5_LwxnorLut : label is "true";
    attribute DONT_TOUCH of eLut6_LwxnorLut : label is "true";
    attribute DONT_TOUCH of q : signal is "true";
    attribute DONT_TOUCH of o5 : signal is "true";
    
    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of q : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of o5 : signal is "true";

    attribute RLOC : string;
    attribute RLOC of eLut5_LwxnorLut : label is "X0Y0";
    attribute RLOC of eLut6_LwxnorLut : label is "X0Y0";

    attribute BEL : string;
    attribute BEL of eLut5_LwxnorLut : label is "A5LUT";
    attribute BEL of eLut6_LwxnorLut : label is "A6LUT";
begin
    
    o_q   <= q;
    q_dl  <= transport q after 100 ps;
    o5_dl <= transport o5 after 100 ps;

    eLut6_LwxnorLut : LUT6
    generic map (
        INIT => x"FF99FFFF60600000"
    ) port map (
        O  => q,
        I0 => o5_dl,
        I1 => q_dl,
        I2 => q_dl,
        I3 => o5_dl,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_LwxnorLut : LUT5
    generic map (
        INIT => x"60600000"
    ) port map (
        O  => o5,
        I0 => o5_dl,
        I1 => q_dl,
        I2 => q_dl,
        I3 => o5_dl,
        I4 => i_resetn
    );
    
end architecture rtl;