-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity Handshaker is
    generic (
        cDataWidth_b : positive := 1;
        cNumStages   : positive := 2
    );
    port (
        i_clka   : in std_logic;
        i_siga   : in std_logic_vector(cDataWidth_b - 1 downto 0);
        i_valida : in std_logic;
        o_busya  : out std_logic;

        i_clkb   : in std_logic;
        o_sigb   : out std_logic_vector(cDataWidth_b - 1 downto 0);
        o_validb : out std_logic
    );
end entity Handshaker;

architecture rtl of Handshaker is
    signal busya   : std_logic := '0';
    signal validba : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
    signal siga    : std_logic_vector(cDataWidth_b - 1 downto 0) := (others => '0');
    signal validb  : std_logic_vector(cNumStages - 1 downto 0) := (others => '0');
begin

    SideAReceiver: process(i_clka)
    begin
        if rising_edge(i_clka) then
            if (busya = '1' and validba(cNumStages-1) = '1') then
                busya <= '0';
            elsif (i_valida = '1' and busya = '0') then
                busya <= '1';
                siga  <= i_siga;
            end if;
        end if;
    end process SideAReceiver;

    o_busya <= busya;

    SideBFilterFlops: process(i_clkb)
    begin
        if rising_edge(i_clkb) then
            validb(0) <= busya;
            for ii in 1 to cNumStages - 1 loop
                validb(ii) <= validb(ii-1);
            end loop;
        end if;
    end process SideBFilterFlops;

    o_sigb   <= siga;
    o_validb <= validb(cNumStages - 1);

    SideAFilterFlops: process(i_clka)
    begin
        if rising_edge(i_clka) then
            validba(0) <= validb(cNumStages - 1);
            for ii in 1 to cNumStages - 1 loop
                validba(ii) <= validba(ii-1);
            end loop;
        end if;
    end process SideAFilterFlops;
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------