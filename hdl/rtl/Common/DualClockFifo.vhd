library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;
    use ostrngs.InterfaceTypes.all;
    use ostrngs.CommonUtility.all;

entity DualClockFifo is
    generic (
        cAddressWidth_b : natural;
        cDataWidth_b    : natural;
        cVerboseMode    : boolean := false;
        cRamID          : string  := "DCF_A"
    );
    port (
        i_clka    : in std_logic;
        i_resetna : in std_logic;
        i_push    : in std_logic;
        i_wdata   : in std_logic_vector(cDataWidth_b - 1 downto 0);
        o_full    : out std_logic;

        i_clkb    : in std_logic;
        i_resetnb : in std_logic;
        i_pop     : in std_logic;
        o_rdata   : out std_logic_vector(cDataWidth_b - 1 downto 0);
        o_empty   : out std_logic
    );
end entity DualClockFifo;

architecture rtl of DualClockFifo is
    -- https://github.com/eleven-in/Dual-Clock-Asynchronous-FIFO

    signal wbin  : unsigned(cAddressWidth_b downto 0) := (others => '0');
    signal wgray : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');
    signal wfull : std_logic := '0';

    signal rbin   : unsigned(cAddressWidth_b downto 0) := (others => '0');
    signal rgray  : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');
    signal rempty : std_logic := '0';

    signal w2r_wptr : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');
    signal w2r_wptr_s0 : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');

    signal r2w_rptr : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');
    signal r2w_rptr_s0 : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');

    signal waddr : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');
    signal raddr : std_logic_vector(cAddressWidth_b - 1 downto 0) := (others => '0');

    signal resetna : std_logic := '0';
    signal resetna_s0 : std_logic := '0';
    signal resetnb : std_logic := '0';
    signal resetnb_s0 : std_logic := '0';
begin

    WritePtr: process(i_clka)
        variable wbinnext : unsigned(cAddressWidth_b downto 0) := (others => '0');
        variable wgraynext : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');
    begin
        if rising_edge(i_clka) then
            if (resetna = '0') then
                wbin  <= (others => '0');
                wgray <= (others => '0');
                wfull <= '0';
            else
                if ((i_push and not wfull) = '1') then
                    wbinnext  := wbin + 1;
                    wbin      <= wbinnext;
                    wgraynext := std_logic_vector(('0' & wbinnext(cAddressWidth_b downto 1)) xor wbinnext);
                    wgray     <= wgraynext;
                end if;

                wfull <= bool2bit(
                    wgraynext = ((not (r2w_rptr(cAddressWidth_b downto cAddressWidth_b - 1))) & r2w_rptr(cAddressWidth_b - 2 downto 0)));
            end if;
        end if;
    end process WritePtr;

    o_full  <= wfull;
    o_empty <= rempty;

    ReadPtr: process(i_clkb)
        variable rbinnext : unsigned(cAddressWidth_b downto 0) := (others => '0');
        variable rgraynext : std_logic_vector(cAddressWidth_b downto 0) := (others => '0');
    begin
        if rising_edge(i_clkb) then
            if (resetnb = '0') then
                rbin  <= (others => '0');
                rgray <= (others => '0');
                rempty <= '1';
            else
                if ((i_pop and not rempty) = '1') then
                    rbinnext := rbin + 1;
                    rbin <= rbinnext;
                    rgraynext := std_logic_vector(('0' & rbinnext(cAddressWidth_b downto 1)) xor rbinnext);
                    rgray <= rgraynext;
                end if;

                rempty <= bool2bit(rgraynext = w2r_wptr);
            end if;
        end if;
    end process ReadPtr;

    R2W_Sync: process(i_clka)
    begin
        if rising_edge(i_clka) then
            if (resetna = '0') then
                r2w_rptr <= (others => '0');
                r2w_rptr_s0 <= (others => '0');
            else
                r2w_rptr <= r2w_rptr_s0;
                r2w_rptr_s0 <= rgray;
            end if;
        end if;
    end process R2W_Sync;

    W2R_Sync: process(i_clkb)
    begin
        if rising_edge(i_clkb) then
            if (resetnb = '0') then
                w2r_wptr <= (others => '0');
                w2r_wptr_s0 <= (others => '0');
            else
                w2r_wptr <= w2r_wptr_s0;
                w2r_wptr_s0 <= wgray;
            end if;
        end if;
    end process W2R_Sync;
    
    waddr <= std_logic_vector(wbin(cAddressWidth_b - 1 downto 0));
    raddr <= std_logic_vector(rbin(cAddressWidth_b - 1 downto 0));

    eBram : entity ostrngs.DualClockBram
    generic map (
        cAddressWidth_b => cAddressWidth_b,
        cMaxAddress     => 2 ** cAddressWidth_b - 1,
        cDataWidth_b    => cDataWidth_b,
        cVerboseMode    => cVerboseMode,
        cRamID          => cRamID
    ) port map (
        i_clka   => i_clka,
        i_addra  => waddr,
        i_ena    => i_push,
        i_wena   => i_push,
        i_wdataa => i_wdata,
        o_rdataa => open,

        i_clkb   => i_clkb,
        i_addrb  => raddr,
        i_enb    => i_pop,
        i_wenb   => '0',
        i_wdatab => (others => '0'),
        o_rdatab => o_rdata
    );

    W2R_ResetSync: process(i_clkb)
    begin
        if rising_edge(i_clkb) then
            if (i_resetnb = '0') then
                resetnb <= '0';
                resetnb_s0 <= '0';
            else
                resetnb <= resetnb_s0;
                resetnb_s0 <= i_resetna;
            end if;
        end if;
    end process W2R_ResetSync;

    R2W_ResetSync: process(i_clka)
    begin
        if rising_edge(i_clka) then
            if (i_resetna = '0') then
                resetna <= '0';
                resetna_s0 <= '0';
            else
                resetna <= resetna_s0;
                resetna_s0 <= i_resetnb;
            end if;
        end if;
    end process R2W_ResetSync;

end architecture rtl;