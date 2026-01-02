library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library unisim;
    use unisim.vcomponents.all;

entity RoLdce is
    port (
        i_resetn : in std_logic;
        o_q : out std_logic
    );
end entity RoLdce;

architecture rtl of RoLdce is
    signal ldce_q : std_logic := '0';
    signal clr_q : std_logic := '0';

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of eLdce : label is "true";
    attribute DONT_TOUCH of clr_q : signal is "true";
    
    attribute RLOC : string;
    attribute RLOC of eLdce : label is "X0Y0";
    attribute RLOC of clr_q : signal is "X0Y0";

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of clr_q : signal is "true";
begin
    
    eLdce : LDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ldce_q,
        CLR => clr_q,
        D   => '1',
        G   => '1',
        GE  => '1'
    );

    clr_q <= i_resetn and ldce_q;

    o_q <= ldce_q;
    
end architecture rtl;