library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity DynamicSampler is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_sel    : out std_logic_vector(1 downto 0);
        o_dff    : out std_logic_vector(1 downto 0)
    );
end entity DynamicSampler;

architecture rtl of DynamicSampler is
    signal ro1e : std_logic := '0';
    signal ro1f : std_logic := '0';
    signal ros  : std_logic_vector(1 downto 0) := (others => '0');

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of ro1e : signal is "true";
    attribute DONT_TOUCH of ro1f : signal is "true";

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of ro1e : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro1f : signal is "true";
begin
    
    ro1e <= transport i_resetn and (not ro1e) after 1000 ps;
    ro1f <= transport i_resetn and (not ro1f) after 1000 ps;

    ros <= ro1f & ro1e;

    o_sel <= ros;
    
    DffSampling: process(i_clk)
    begin
        if rising_edge(i_clk) then
            o_dff <= ros;
        end if;
    end process DffSampling;
    
end architecture rtl;