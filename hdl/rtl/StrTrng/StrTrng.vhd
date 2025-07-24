library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity StrTrng is
    generic (
        cNumStages : natural := 45
    );
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        i_mode   : in std_logic;
        i_set    : in std_logic_vector(cNumStages - 1 downto 0);
        o_rng    : out std_logic_vector(0 downto 0)
    );
end entity StrTrng;

architecture rtl of StrTrng is
    signal mode    : std_logic := '0';
    signal set     : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal c       : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal c_reg   : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal merge_c : std_logic := '0';
begin
    
    ModeAndSetCtrl: process(i_resetn, i_mode, i_set)
    begin
        if (i_resetn = '0') then
            mode <= '1';
            set  <= (others => '0');
        else
            mode <= i_mode;
            set  <= i_set; 
        end if;
    end process ModeAndSetCtrl;

    eStr : entity ostrngs.SelfTimedRing
    generic map (
        cNumStages => cNumStages
    ) port map (
        i_mode => i_mode,
        i_set => i_set,
        o_c   => c
    );

    Sampler: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                c_reg <= (others => '0');
            else
                c_reg <= c;
            end if;
        end if;
    end process Sampler;

    Merge: process(c_reg)
        variable sum : std_logic;
    begin
        sum := c_reg(0);
        for ii in 1 to cNumStages - 1 loop
            sum := sum xor c_reg(ii);
        end loop;
        merge_c <= sum;
    end process Merge;

    FinalSampler: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                o_rng(0) <= '0';
            else
                o_rng(0) <= merge_c;
            end if;
        end if;
    end process FinalSampler;
    
end architecture rtl;