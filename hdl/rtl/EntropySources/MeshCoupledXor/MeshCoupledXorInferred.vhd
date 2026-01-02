-----------------------------------------------------------------------------------------------------------------------
-- entity: MeshCoupledXorInferred
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

entity MeshCoupledXorInferred is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(5 downto 0);
        o_valid  : out std_logic;
        o_taps   : out std_logic_vector(23 downto 0)
    );
end entity MeshCoupledXorInferred;

architecture rtl of MeshCoupledXorInferred is
    signal ro     : std_logic_vector(7 downto 0)  := (others => '0');
    signal in_cx  : std_logic_vector(23 downto 0) := (others => '0');
    signal out_cx : std_logic_vector(23 downto 0) := (others => '0');
    signal xor_cx : std_logic_vector(23 downto 0) := (others => '0');

    signal bc1 : std_logic := '0';
    signal bc2 : std_logic := '0';
    signal ab2 : std_logic := '0';
    signal ab1 : std_logic := '0';
    signal bf1 : std_logic := '0';
    signal bf2 : std_logic := '0';
    signal cd2 : std_logic := '0';
    signal cd1 : std_logic := '0';
    signal ad1 : std_logic := '0';
    signal ad2 : std_logic := '0';
    signal ae1 : std_logic := '0';
    signal ae2 : std_logic := '0';
    signal ef1 : std_logic := '0';
    signal ef2 : std_logic := '0';
    signal dh1 : std_logic := '0';
    signal dh2 : std_logic := '0';
    signal eh1 : std_logic := '0';
    signal eh2 : std_logic := '0';
    signal cg1 : std_logic := '0';
    signal cg2 : std_logic := '0';
    signal gh2 : std_logic := '0';
    signal gh1 : std_logic := '0';
    signal fg1 : std_logic := '0';
    signal fg2 : std_logic := '0';

    signal valid : std_logic := '0';

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of ro     : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out_cx : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of in_cx  : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of xor_cx : signal is "true";

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of ro     : signal is "true";
    attribute DONT_TOUCH of out_cx : signal is "true";
    attribute DONT_TOUCH of in_cx  : signal is "true";
    attribute DONT_TOUCH of xor_cx : signal is "true";
begin
    
    o_taps <= out_cx;

    gRingOscillatorGeneration: for g_ii in 0 to 7 generate
        RingOsc: process(ro(g_ii))
        begin
            ro(g_ii) <= i_resetn and not ro(g_ii);
        end process RingOsc;
    end generate gRingOscillatorGeneration;

    gCxUnits: for g_ii in 0 to 11 generate
        eCxUnit : entity ostrngs.CxUnit
        port map (
            i_resetn => i_resetn,
            i_in0  => in_cx(2 * g_ii),
            o_out0 => out_cx(2 * g_ii),
            i_in1  => in_cx(2 * g_ii + 1),
            o_out1 => out_cx(2 * g_ii + 1)
        );
    end generate gCxUnits;

    xor_cx(0) <= i_resetn and (ro(0) xor out_cx(0) xor out_cx(2) xor out_cx(4));
    xor_cx(1) <= i_resetn and (ro(1) xor out_cx(1) xor out_cx(7) xor out_cx(18));
    xor_cx(2) <= i_resetn and (ro(2) xor out_cx(19) xor out_cx(21) xor out_cx(23));
    xor_cx(3) <= i_resetn and (ro(3) xor out_cx(5) xor out_cx(13) xor out_cx(22));

    xor_cx(4) <= i_resetn and (ro(4) xor out_cx(3) xor out_cx(8) xor out_cx(10));
    xor_cx(5) <= i_resetn and (ro(5) xor out_cx(6) xor out_cx(9) xor out_cx(14));
    xor_cx(6) <= i_resetn and (ro(6) xor out_cx(15) xor out_cx(17) xor out_cx(20));
    xor_cx(7) <= i_resetn and (ro(7) xor out_cx(11) xor out_cx(12) xor out_cx(16));

    in_cx(0) <= xor_cx(0);
    in_cx(1) <= xor_cx(1);

    in_cx(2) <= xor_cx(0);
    in_cx(3) <= xor_cx(4);

    in_cx(4) <= xor_cx(0);
    in_cx(5) <= xor_cx(3);

    in_cx(6) <= xor_cx(1);
    in_cx(7) <= xor_cx(5);

    in_cx(8) <= xor_cx(4);
    in_cx(9) <= xor_cx(5);

    in_cx(10) <= xor_cx(4);
    in_cx(11) <= xor_cx(7);

    in_cx(12) <= xor_cx(7);
    in_cx(13) <= xor_cx(3);

    in_cx(14) <= xor_cx(5);
    in_cx(15) <= xor_cx(6);

    in_cx(16) <= xor_cx(7);
    in_cx(17) <= xor_cx(6);

    in_cx(18) <= xor_cx(1);
    in_cx(19) <= xor_cx(2);

    in_cx(20) <= xor_cx(6);
    in_cx(21) <= xor_cx(2);

    in_cx(22) <= xor_cx(3);
    in_cx(23) <= xor_cx(2);

    
    BitGenerator: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                o_rng <= (others => '0');

                bc1 <= '0';
                bc2 <= '0';
                ab2 <= '0';
                ab1 <= '0';
                bf1 <= '0';
                bf2 <= '0';
                cd2 <= '0';
                cd1 <= '0';
                ad1 <= '0';
                ad2 <= '0';
                ae1 <= '0';
                ae2 <= '0';
                ef1 <= '0';
                ef2 <= '0';
                dh1 <= '0';
                dh2 <= '0';
                eh1 <= '0';
                eh2 <= '0';
                cg1 <= '0';
                cg2 <= '0';
                gh2 <= '0';
                gh1 <= '0';
                fg1 <= '0';
                fg2 <= '0';
            else
                bc1 <= out_cx(0);
                bc2 <= out_cx(1);
                ab2 <= out_cx(2);
                ab1 <= out_cx(3);
                bf1 <= out_cx(4);
                bf2 <= out_cx(5);
                cd2 <= out_cx(6);
                cd1 <= out_cx(7);
                ad1 <= out_cx(8);
                ad2 <= out_cx(9);
                ae1 <= out_cx(10);
                ae2 <= out_cx(11);
                ef1 <= out_cx(12);
                ef2 <= out_cx(13);
                dh1 <= out_cx(14);
                dh2 <= out_cx(15);
                eh1 <= out_cx(16);
                eh2 <= out_cx(17);
                cg1 <= out_cx(18);
                cg2 <= out_cx(19);
                gh2 <= out_cx(20);
                gh1 <= out_cx(21);
                fg1 <= out_cx(22);
                fg2 <= out_cx(23);

                o_rng(0) <= ab1 xor ae2 xor ef2 xor bf1;
                o_rng(1) <= ad2 xor dh2 xor eh1 xor ae1;
                o_rng(2) <= cd1 xor cg2 xor gh2 xor dh1;
                o_rng(3) <= bc2 xor cd2 xor ad1 xor ab2;
                o_rng(4) <= bc1 xor bf2 xor fg2 xor cg1;
                o_rng(5) <= eh2 xor gh1 xor fg1 xor ef1;
            end if;
        end if;
    end process BitGenerator;

    ValidSignalToggling: process(i_clk)
    begin
        if (i_resetn = '0') then
            o_valid <= '0';
            valid   <= '0';
        elsif rising_edge(i_clk) then
            valid <= '1';
            o_valid <= valid;
        end if;
    end process ValidSignalToggling;
   
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------