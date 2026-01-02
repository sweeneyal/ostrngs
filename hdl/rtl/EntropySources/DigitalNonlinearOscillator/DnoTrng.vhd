library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity DnoTrng is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(0 downto 0);
        o_valid  : out std_logic;
        o_taps   : out std_logic_vector(0 to 2)
    );
end entity DnoTrng;

architecture rtl of DnoTrng is
    signal taps  : std_logic_vector(0 to 2);
    signal tapsd : std_logic_vector(0 to 2);
    signal ro : std_logic_vector(2 downto 0) := (others => '0');

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of ro : signal is "true";

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of ro : signal is "true";

    attribute RLOC : string;
    attribute RLOC of ro : signal is "X0Y0";
begin

    RingOsc: process(i_resetn, ro)
    begin
        if (i_resetn = '0') then
            ro <= (others => '0');
        else
            ro(0) <= transport not ro(2) after 1000 ps;
            for ii in 1 to 2 loop
                ro(ii) <= transport not ro(ii - 1) after 1000 ps;
            end loop;
        end if;
    end process RingOsc;
    
    eDno : entity ostrngs.DigitalNonlinearOscillator
    port map (
        i_resetn => i_resetn,
        i_excite => ro(0),
        o_taps   => taps
    );

    o_taps <= taps;

    TapsFlops: process(i_clk)
    begin
        if (i_resetn = '0') then
            tapsd <= (others => '0');
            o_valid <= '0';
        elsif rising_edge(i_clk) then
            tapsd <= taps;
            o_valid <= '1';
        end if;
    end process TapsFlops;

    o_rng(0) <= tapsd(0) xor tapsd(1) xor tapsd(2);
    
end architecture rtl;