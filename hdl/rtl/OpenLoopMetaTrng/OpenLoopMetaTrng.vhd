library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity OpenLoopMetaTrng is
    generic (
        cNumFineStages : natural := 64;
        cNumCoarseStages : natural := 64;
        cSimFineDelay_ps : natural := 50;
        cSimCoarseDelay_ps : natural := 100
    );
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        i_ctrc   : in std_logic_vector(cNumCoarseStages - 1 downto 0);
        i_ctrd   : in std_logic_vector(cNumCoarseStages - 1 downto 0);
        o_rbit   : out std_logic
    );
end entity OpenLoopMetaTrng;

architecture rtl of OpenLoopMetaTrng is
    signal c       : std_logic_vector(cNumFineStages downto 0) := (others => '0');
    signal d       : std_logic_vector(cNumFineStages downto 0) := (others => '0');
    signal d_reg   : std_logic_vector(cNumFineStages - 1 downto 0) := (others => '0');
    signal merge_d : std_logic := '0';
begin
    
    eCascade : entity ostrngs.CoarseCascade
    generic map (
        cNumStages => cNumCoarseStages,
        cSimulatedDelay_ps => cSimCoarseDelay_ps
    ) port map (
        i_clk => i_clk,
        i_ctrc => i_ctrc,
        i_ctrd => i_ctrd,
        o_c => c(0),
        o_d => d(0)
    );

    gFineDelayGeneration: for g_ii in 0 to cNumFineStages - 1 generate
        
        c(g_ii + 1) <= transport c(g_ii) after cSimFineDelay_ps * 1 ps;
        d(g_ii + 1) <= transport d(g_ii) after cSimFineDelay_ps * 1 ps;

        SampleFlops: process(c(g_ii))
        begin
            if rising_edge(c(g_ii)) then
                if (i_resetn = '0') then
                    d_reg(g_ii) <= '0';
                else
                    d_reg(g_ii) <= d(g_ii);
                end if;
            end if;
        end process SampleFlops;

    end generate gFineDelayGeneration;

    Merge: process(d_reg)
        variable sum : std_logic;
    begin
        sum := d_reg(0);
        for ii in 1 to cNumFineStages - 1 loop
            sum := sum xor d_reg(ii);
        end loop;
        merge_d <= sum;
    end process Merge;

    FinalSampler: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                o_rbit <= '0';
            else
                o_rbit <= merge_d;
            end if;
        end if;
    end process FinalSampler;
    
end architecture rtl;