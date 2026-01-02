library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity XorRingTrng is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(0 downto 0);
        o_valid  : out std_logic
    );
end entity XorRingTrng;

architecture rtl of XorRingTrng is
    -- Oscillator implemented from Rosin's paper, section 5.3

    signal xor_net : std_logic_vector(15 downto 0) := (others => '0');
    signal ffs     : std_logic_vector(3 downto 0) := (others => '0');

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of xor_net : signal is "true";

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of xor_net : signal is "true";
begin
    
    XorNetwork: process(i_resetn, xor_net)
        variable tmp : std_logic := '0';
    begin
        for ii in xor_net'right + 1 to xor_net'left loop
            if (i_resetn = '0') then
                xor_net(ii) <= '0';
            else
                tmp := xor_net(ii);
                if (ii - 1 < xor_net'right) then
                    tmp := tmp xor xor_net(xor_net'left);
                else
                    tmp := tmp xor xor_net(ii - 1);
                end if;
    
                if (ii + 1 > xor_net'left) then
                    tmp := tmp xor xor_net(xor_net'right);
                else
                    tmp := tmp xor xor_net(ii + 1);
                end if;
    
                xor_net(ii) <= tmp;
            end if;
        end loop;
    end process XorNetwork;

    xor_net(xor_net'right) <= i_resetn and 
        (not (xor_net(xor_net'left) xor xor_net(xor_net'right) xor xor_net(xor_net'right + 1)));

    SamplingFlops: process(i_clk)
    begin
        if (i_resetn = '0') then
            ffs   <= (others => '0');
            o_valid <= '0';
        elsif rising_edge(i_clk) then
            for ii in 0 to 3 loop
                ffs(ii) <= xor_net(4 * ii);
            end loop;
            o_valid <= '1';
        end if;
    end process SamplingFlops;

    o_rng(0) <= ffs(0) xor ffs(1) xor ffs(2) xor ffs(3);

end architecture rtl;