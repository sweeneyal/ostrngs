library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library unisim;
    use unisim.vcomponents.all;

entity Lwxnor is
    port (
        i_resetn : in std_logic;
        o_q : out std_logic
    );
end entity Lwxnor;

architecture rtl of Lwxnor is
    signal ldce_q  : std_logic := '0';
    signal pre_clr : std_logic := '0';
    signal ldpe_q  : std_logic := '0';

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of eLdce : label is "true";
    attribute DONT_TOUCH of eLdpe : label is "true";
    attribute DONT_TOUCH of pre_clr : signal is "true";

    attribute RLOC : string;
    attribute RLOC of eLdce : label is "X0Y0";
    attribute RLOC of eLdpe : label is "X0Y0";
    attribute RLOC of pre_clr : signal is "X0Y0";

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of pre_clr : signal is "true";
begin
    
    eLdpe : LDPE 
    generic map (
        INIT => '1'
    ) port map (
        Q   => ldpe_q,
        PRE => pre_clr,
        D   => ldce_q,
        G   => '1',
        GE  => '1'
    );

    eLdce : LDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ldce_q,
        CLR => pre_clr,
        D   => ldpe_q,
        G   => '1',
        GE  => '1'
    );

    pre_clr <= transport (not i_resetn) or (not (ldce_q xor ldpe_q)) after 1000 ps;

    o_q <= ldpe_q;
    
end architecture rtl;