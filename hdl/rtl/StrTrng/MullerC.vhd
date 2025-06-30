library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity MullerC is
    port (
        i_mode : in std_logic;
        i_set  : in std_logic;
        i_f    : in std_logic;
        i_r    : in std_logic;
        o_c    : out std_logic
    );
end entity MullerC;

architecture rtl of MullerC is

begin
    
    MullerCLatch: process(i_mode = '1', i_f, i_r)
    begin
        if (i_mode = '1') then
            o_c <= i_set;
        elsif ((i_f xor i_r) = '1') then
            o_c <= i_f;
        end if;
    end process MullerCLatch;
    
end architecture rtl;