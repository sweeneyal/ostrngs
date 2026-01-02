library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity FeedforwardShiftRegister is
    port (
        i_clk : in std_logic;
        i_resetn : in std_logic;
        i_sel : in std_logic;
        i_sig : in std_logic;
        o_dff : out std_logic
    );
end entity FeedforwardShiftRegister;

architecture rtl of FeedforwardShiftRegister is
    signal dffs : std_logic_vector(5 downto 0) := (others => '0');
begin
    
    ShiftReg: process(i_clk, i_resetn)
    begin
        if (i_resetn = '0') then
            dffs <= (others => '0');
        elsif rising_edge(i_clk) then
            dffs(0) <= i_sig;
            for ii in 1 to 5 loop
                dffs(ii) <= dffs(ii - 1);
            end loop;
        end if;
    end process ShiftReg;

    LastReg: process(i_clk, i_resetn)
    begin
        if (i_resetn = '0') then
            o_dff <= '0';
        elsif rising_edge(i_clk) then
            if (i_sel = '0') then
                o_dff <= dffs(0);
            else
                o_dff <= dffs(5);
            end if;
        end if;
    end process LastReg;
    
end architecture rtl;