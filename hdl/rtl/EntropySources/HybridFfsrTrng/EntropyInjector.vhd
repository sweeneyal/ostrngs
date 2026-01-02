library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity EntropyInjector is
    port (
        i_resetn : in std_logic;
        i_sel    : in std_logic_vector(1 downto 0);
        o_ro     : out std_logic;
        o_ro1a   : out std_logic
    );
end entity EntropyInjector;

architecture rtl of EntropyInjector is
    signal ro1a : std_logic := '0';
    signal ro1b : std_logic := '0';
    signal ro1c : std_logic := '0';
    signal ro1d : std_logic := '0';

    signal ros : std_logic_vector(3 downto 0) := (others => '0');

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of ro1a : signal is "true";
    attribute DONT_TOUCH of ro1b : signal is "true";
    attribute DONT_TOUCH of ro1c : signal is "true";
    attribute DONT_TOUCH of ro1d : signal is "true";

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of ro1a : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro1b : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro1c : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro1d : signal is "true";
begin
    
    ro1a <= transport i_resetn and (not ro1a) after 1000 ps;
    ro1b <= transport i_resetn and (not ro1b) after 1000 ps;
    ro1c <= transport i_resetn and (not ro1c) after 1000 ps;
    ro1d <= transport i_resetn and (not ro1d) after 1000 ps;
    
    ros <= ro1d & ro1c & ro1b & ro1a;

    o_ro   <= ros(to_integer(unsigned(i_sel)));
    o_ro1a <= ro1a;
    
end architecture rtl;