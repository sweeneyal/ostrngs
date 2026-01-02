-----------------------------------------------------------------------------------------------------------------------
-- entity: LwxnorLutTrng
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

library ostrngs;

entity LwxnorLutTrng is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(0 downto 0);
        o_valid  : out std_logic
    );
end entity LwxnorLutTrng;

architecture rtl of LwxnorLutTrng is
    signal q : std_logic_vector(15 downto 0) := (others => '0');
    signal rng : std_logic := '0';
begin
    
    gLwxnorLuts: for g_ii in 0 to 15 generate
        eLwxnorLut : entity ostrngs.LwxnorLut
        port map (
            i_resetn => i_resetn,
            o_q      => q(g_ii)
        );
    end generate gLwxnorLuts;
    
    XorDecomp: process(q)
        variable tmp : std_logic := '0';
    begin
        tmp := q(0);
        for ii in 1 to 15 loop
            tmp := tmp xor q(ii);
        end loop;
        rng <= tmp;
    end process XorDecomp;

    SamplingRegister: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                o_rng(0) <= '0';
                o_valid  <= '0';
            else
                o_rng(0) <= rng;
                o_valid  <= '1';
            end if;
        end if;
    end process SamplingRegister;

end architecture rtl;