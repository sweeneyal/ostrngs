-----------------------------------------------------------------------------------------------------------------------
-- entity: DualClockBram
--
-- library: ostrngs
--
-- description:
--       
--
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

entity DualClockBram is
    generic (
        cAddressWidth_b : natural := 30;
        cMaxAddress     : natural := 4095;
        cDataWidth_b    : natural := 32;
        cVerboseMode    : boolean := false;
        cRamID          : string  := "A"
    );
    port (
        i_clka   : in std_logic;
        i_addra  : in std_logic_vector(cAddressWidth_b - 1 downto 0);
        i_ena    : in std_logic;
        i_wena   : in std_logic;
        i_wdataa : in std_logic_vector(cDataWidth_b - 1 downto 0);
        o_rdataa : out std_logic_vector(cDataWidth_b - 1 downto 0);

        i_clkb   : in std_logic;
        i_addrb  : in std_logic_vector(cAddressWidth_b - 1 downto 0);
        i_enb    : in std_logic;
        i_wenb   : in std_logic;
        i_wdatab : in std_logic_vector(cDataWidth_b - 1 downto 0);
        o_rdatab : out std_logic_vector(cDataWidth_b - 1 downto 0)
    );
end entity DualClockBram;

architecture rtl of DualClockBram is
    type ram_t is array (0 to cMaxAddress) of std_logic_vector(cDataWidth_b - 1 downto 0);

    shared variable ram : ram_t := (others => (others => '0'));
begin
    
    RamAddrAControl: process(i_clka)
    begin
        if rising_edge(i_clka) then
            if (i_ena = '1') then
                o_rdataa <= ram(to_integer(unsigned(i_addra)));
                if (i_wena = '1') then
                    ram(to_integer(unsigned(i_addra))) := i_wdataa;
                    if (cVerboseMode) then
                        report "RAM_" & cRamID & "[" & to_hstring(i_addra) & "]=" & to_hstring(i_wdataa);
                    end if;
                end if;
            end if;
        end if;
    end process RamAddrAControl;

    RamAddrBControl: process(i_clkb)
    begin
        if rising_edge(i_clkb) then
            if (i_enb = '1') then
                o_rdatab <= ram(to_integer(unsigned(i_addrb)));
                if (i_wenb = '1') then
                    ram(to_integer(unsigned(i_addrb))) := i_wdatab;
                    if (cVerboseMode) then
                        report "RAM_" & cRamID & "[" & to_hstring(i_addra) & "]=" & to_hstring(i_wdataa);
                    end if;
                end if;
            end if;
        end if;
    end process RamAddrBControl;

end architecture rtl;