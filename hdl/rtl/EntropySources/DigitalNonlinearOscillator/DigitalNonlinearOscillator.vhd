library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

entity DigitalNonlinearOscillator is
    port (
        i_resetn : in std_logic;
        i_excite : in std_logic;
        o_taps   : out std_logic_vector(0 to 2)
    );
end entity DigitalNonlinearOscillator;

architecture rtl of DigitalNonlinearOscillator is
    signal x        : std_logic;
    signal x_delay0 : std_logic;
    signal x_delay1 : std_logic;

    signal y        : std_logic;
    signal y_delay0 : std_logic;
    signal y_delay1 : std_logic;

    signal z        : std_logic;
    signal z_delay0 : std_logic;
    signal z_delay1 : std_logic;

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of x : signal is "true";
    attribute DONT_TOUCH of y : signal is "true";
    attribute DONT_TOUCH of z : signal is "true";

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of x : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of y : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of z : signal is "true";

    attribute RLOC : string;
    attribute RLOC of x : signal is "X0Y0";
    attribute RLOC of y : signal is "X0Y1";
    attribute RLOC of z : signal is "X0Y2";
begin
    
    x <= i_resetn and (x_delay0 xor z_delay0);
    y <= i_resetn and (not (y_delay0 xor z_delay1));
    z <= i_resetn and (i_excite xor x_delay1 xor y_delay1);

    x_delay0 <= transport x after 1000 ps;
    x_delay1 <= transport x after 1500 ps;

    y_delay0 <= transport x after 1200 ps;
    y_delay1 <= transport x after 1400 ps;

    z_delay0 <= transport z after 1100 ps;
    z_delay1 <= transport z after 1300 ps;

    o_taps <= x & y & z;
    
end architecture rtl;