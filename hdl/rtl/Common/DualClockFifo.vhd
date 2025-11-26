-----------------------------------------------------------------------------------------------------------------------
-- entity: DualClockFifo
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
    use ieee.math_real.all;

library ostrngs;

entity DualClockFifo is
    generic (
        cDepth        : natural := 4096;
        cDataWidth_b  : natural := 8
    );
    port (
        i_clka    : in std_logic;
        i_clkb    : in std_logic;
        i_aresetn : in std_logic;

        i_data_a  : in std_logic_vector(cDataWidth_b - 1 downto 0);
        i_valid_a : in std_logic;

        i_pop_b   : in std_logic;
        o_data_b  : out std_logic_vector(cDataWidth_b - 1 downto 0);
        o_valid_b : out std_logic;

        o_fifo_full   : out std_logic;
        o_fifo_afull  : out std_logic;
        o_fifo_aempty : out std_logic;
        o_fifo_empty  : out std_logic
    );
end entity DualClockFifo;

architecture rtl of DualClockFifo is
    function bin2gray(b : std_logic_vector) return std_logic_vector is
        variable g : std_logic_vector(b'range);
    begin
        g := b;
        g := g xor std_logic_vector(shift_right(unsigned(g), 1));
        return g;
    end function;

    function gray2bin(g : std_logic_vector) return std_logic_vector is
        variable b : std_logic_vector(g'range);
    begin
        b(g'length - 1) := g(g'length - 1);
        for ii in g'length - 2 downto 0 loop
            b(ii) := b(ii + 1) xor g(ii);
        end loop;
        return b;
    end function;

    constant cAddressWidth_b : natural := natural(ceil(log2(real(cDepth))));
    signal wptr : unsigned(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal rptr : unsigned(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal wptr_s : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal rptr_s : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');

    signal wptr_g    : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal wptr_g_s0 : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal wptr_g_s1 : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');

    signal rptr_g    : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal rptr_g_s0 : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal rptr_g_s1 : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');

    signal wptr_b : unsigned(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal rptr_a : unsigned(cAddressWidth_b - 1 downto 0) := (others => '0');

    signal fifo_empty  : std_logic := '1';
    signal fifo_aempty : std_logic := '0';
    signal fifo_afull  : std_logic := '0';
    signal fifo_full   : std_logic := '0';

    signal resetn_a : std_logic := '0';
    signal resetn_b : std_logic := '0';
begin
    
    o_fifo_full   <= fifo_full;
    o_fifo_afull  <= fifo_afull;
    o_fifo_aempty <= fifo_aempty;
    o_fifo_empty  <= fifo_empty;

    eBram : entity ostrngs.DualClockBram
    generic map (
        cAddressWidth_b => cAddressWidth_b,
        cMaxAddress     => cDepth - 1,
        cDataWidth_b    => cDataWidth_b
    ) port map (
        i_clka => i_clka,
        i_clkb => i_clkb,

        i_addra  => wptr_s,
        i_ena    => i_valid_a,
        i_wena   => i_valid_a,
        i_wdataa => i_data_a,
        o_rdataa => open,

        i_addrb  => rptr_s,
        i_enb    => i_pop_b,
        i_wenb   => '0',
        i_wdatab => (others => '0'),
        o_rdatab => o_data_b
    );

    WptrCtrl: process(i_clka)
    begin
        if (i_aresetn = '0') then
            wptr <= (others => '0');
        elsif rising_edge(i_clka) then
            if (i_valid_a = '1' and fifo_full = '0') then
                wptr <= wptr + 1;
            end if;
        end if;
    end process WptrCtrl;

    wptr_s <= std_logic_vector(wptr);
    wptr_g <= bin2gray(wptr_s);

    BSideWptrConversion: process(i_clkb, i_aresetn)
    begin
        if (i_aresetn = '0') then
            wptr_g_s0 <= (others => '0');
            wptr_g_s1 <= (others => '0');
        elsif rising_edge(i_clkb) then
            wptr_g_s0 <= wptr_g;
            wptr_g_s1 <= wptr_g_s0;
        end if;
    end process BSideWptrConversion;

    wptr_b <= unsigned(gray2bin(wptr_g_s1));

    BSideStatusSignals: process(i_clkb, i_aresetn)
    begin
        if (i_aresetn = '0') then
            fifo_empty  <= '1';
            fifo_aempty <= '0';
        elsif rising_edge(i_clkb) then
            if (wptr_b = rptr) then
                fifo_empty <= '1';
            else
                fifo_empty  <= '0';
            end if;
            
            if (rptr = wptr_b - 1) then
                fifo_aempty <= '1';
            else
                fifo_aempty <= '0';
            end if;
        end if;
    end process BSideStatusSignals;

    ASidePulseExtender: process(i_clka, i_aresetn)
        variable timer : natural range 0 to 2 := 2;
    begin
        if (i_aresetn = '0') then
            resetn_a <= '0';
            timer := 2;
        elsif rising_edge(i_clka) then
            if (timer = 0) then
                resetn_a <= '1';
            else
                timer := timer - 1;
            end if;
        end if;
    end process ASidePulseExtender;

    BSidePulseExtender: process(i_clkb, i_aresetn)
        variable timer : natural range 0 to 2 := 2;
    begin
        if (i_aresetn = '0') then
            resetn_b <= '0';
            timer := 2;
        elsif rising_edge(i_clkb) then
            if (timer = 0) then
                resetn_b <= '1';
            else
                timer := timer - 1;
            end if;
        end if;
    end process BSidePulseExtender;

    RptrCtrl: process(i_clkb, i_aresetn)
    begin
        if (i_aresetn = '0') then
            rptr <= (others => '0');
        elsif rising_edge(i_clkb) then
            o_valid_b <= i_pop_b and not fifo_empty;
            if (i_pop_b = '1' and fifo_empty = '0') then
                rptr <= rptr + 1;
            end if;
        end if;
    end process RptrCtrl;

    rptr_s <= std_logic_vector(rptr);
    rptr_g <= bin2gray(rptr_s);

    ASideRptrConversion: process(i_clka, i_aresetn)
    begin
        if (i_aresetn = '0') then
            rptr_g_s0 <= (others => '0');
            rptr_g_s1 <= (others => '0');
        elsif rising_edge(i_clka) then
            rptr_g_s0 <= rptr_g;
            rptr_g_s1 <= rptr_g_s0;
        end if;
    end process ASideRptrConversion;

    rptr_a <= unsigned(gray2bin(rptr_g_s1));

    ASideStatusSignals: process(i_clka, i_aresetn)
    begin
        if (i_aresetn = '0') then
            fifo_full <= '0';
            fifo_afull <= '0';
        elsif rising_edge(i_clka) then
            if (wptr = rptr_a - 1) then
                fifo_full <= '1';
            else
                fifo_full <= '0';
            end if;
            
            if (wptr = rptr_a - 2) then
                fifo_afull <= '1';
            else
                fifo_afull <= '0';
            end if;
        end if;
    end process ASideStatusSignals;
    
end architecture rtl;