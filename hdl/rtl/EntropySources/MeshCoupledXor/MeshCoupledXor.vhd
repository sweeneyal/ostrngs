-----------------------------------------------------------------------------------------------------------------------
-- entity: MeshCoupledXor
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

library unisim;
    use unisim.vcomponents.all;

entity MeshCoupledXor is
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;
        o_rng    : out std_logic_vector(5 downto 0);
        o_valid  : out std_logic;
        o_taps   : out std_logic_vector(23 downto 0)
    );
end entity MeshCoupledXor;

architecture rtl of MeshCoupledXor is
    -- ro signals
    signal ro0 : std_logic := '0';
    signal ro1 : std_logic := '0';
    signal ro2 : std_logic := '0';
    signal ro3 : std_logic := '0';
    signal ro4 : std_logic := '0';
    signal ro5 : std_logic := '0';
    signal ro6 : std_logic := '0';
    signal ro7 : std_logic := '0';

    signal ro0_in : std_logic := '0';
    signal ro1_in : std_logic := '0';
    signal ro2_in : std_logic := '0';
    signal ro3_in : std_logic := '0';
    signal ro4_in : std_logic := '0';
    signal ro5_in : std_logic := '0';
    signal ro6_in : std_logic := '0';
    signal ro7_in : std_logic := '0';

    -- configurator output signals
    signal config0 : std_logic := '0';
    signal config1 : std_logic := '0';
    signal config2 : std_logic := '0';
    signal config3 : std_logic := '0';
    signal config4 : std_logic := '0';
    signal config5 : std_logic := '0';
    signal config6 : std_logic := '0';
    signal config7 : std_logic := '0';

    -- input signals to cx units
    signal in0 : std_logic := '0';
    signal in1 : std_logic := '0';
    signal in2 : std_logic := '0';
    signal in3 : std_logic := '0';
    signal in4 : std_logic := '0';
    signal in5 : std_logic := '0';
    signal in6 : std_logic := '0';
    signal in7 : std_logic := '0';
    signal in8 : std_logic := '0';
    signal in9 : std_logic := '0';
    signal in10 : std_logic := '0';
    signal in11 : std_logic := '0';
    signal in12 : std_logic := '0';
    signal in13 : std_logic := '0';
    signal in14 : std_logic := '0';
    signal in15 : std_logic := '0';
    signal in16 : std_logic := '0';
    signal in17 : std_logic := '0';
    signal in18 : std_logic := '0';
    signal in19 : std_logic := '0';
    signal in20 : std_logic := '0';
    signal in21 : std_logic := '0';
    signal in22 : std_logic := '0';
    signal in23 : std_logic := '0';

    -- output signals from cx units
    signal out0 : std_logic := '0';
    signal out1 : std_logic := '0';
    signal out2 : std_logic := '0';
    signal out3 : std_logic := '0';
    signal out4 : std_logic := '0';
    signal out5 : std_logic := '0';
    signal out6 : std_logic := '0';
    signal out7 : std_logic := '0';
    signal out8 : std_logic := '0';
    signal out9 : std_logic := '0';
    signal out10 : std_logic := '0';
    signal out11 : std_logic := '0';
    signal out12 : std_logic := '0';
    signal out13 : std_logic := '0';
    signal out14 : std_logic := '0';
    signal out15 : std_logic := '0';
    signal out16 : std_logic := '0';
    signal out17 : std_logic := '0';
    signal out18 : std_logic := '0';
    signal out19 : std_logic := '0';
    signal out20 : std_logic := '0';
    signal out21 : std_logic := '0';
    signal out22 : std_logic := '0';
    signal out23 : std_logic := '0';

    signal out0_delay : std_logic := '0';
    signal out1_delay : std_logic := '0';
    signal out2_delay : std_logic := '0';
    signal out3_delay : std_logic := '0';
    signal out4_delay : std_logic := '0';
    signal out5_delay : std_logic := '0';
    signal out6_delay : std_logic := '0';
    signal out7_delay : std_logic := '0';
    signal out8_delay : std_logic := '0';
    signal out9_delay : std_logic := '0';
    signal out10_delay : std_logic := '0';
    signal out11_delay : std_logic := '0';
    signal out12_delay : std_logic := '0';
    signal out13_delay : std_logic := '0';
    signal out14_delay : std_logic := '0';
    signal out15_delay : std_logic := '0';
    signal out16_delay : std_logic := '0';
    signal out17_delay : std_logic := '0';
    signal out18_delay : std_logic := '0';
    signal out19_delay : std_logic := '0';
    signal out20_delay : std_logic := '0';
    signal out21_delay : std_logic := '0';
    signal out22_delay : std_logic := '0';
    signal out23_delay : std_logic := '0';

    -- named cx output signals for eventual use in sampling
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

    -- named registered output cx signals
    signal bc1_reg : std_logic := '0';
    signal bc2_reg : std_logic := '0';
    signal ab2_reg : std_logic := '0';
    signal ab1_reg : std_logic := '0';
    signal bf1_reg : std_logic := '0';
    signal bf2_reg : std_logic := '0';
    signal cd2_reg : std_logic := '0';
    signal cd1_reg : std_logic := '0';
    signal ad1_reg : std_logic := '0';
    signal ad2_reg : std_logic := '0';
    signal ae1_reg : std_logic := '0';
    signal ae2_reg : std_logic := '0';
    signal ef1_reg : std_logic := '0';
    signal ef2_reg : std_logic := '0';
    signal dh1_reg : std_logic := '0';
    signal dh2_reg : std_logic := '0';
    signal eh1_reg : std_logic := '0';
    signal eh2_reg : std_logic := '0';
    signal cg1_reg : std_logic := '0';
    signal cg2_reg : std_logic := '0';
    signal gh2_reg : std_logic := '0';
    signal gh1_reg : std_logic := '0';
    signal fg1_reg : std_logic := '0';
    signal fg2_reg : std_logic := '0';

    -- rng xor result signals
    signal rng0 : std_logic := '0';
    signal rng1 : std_logic := '0';
    signal rng2 : std_logic := '0';
    signal rng3 : std_logic := '0';
    signal rng4 : std_logic := '0';
    signal rng5 : std_logic := '0';

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of rtl : architecture is "true";

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of ro0 : signal is "true";
    attribute DONT_TOUCH of ro1 : signal is "true";
    attribute DONT_TOUCH of ro2 : signal is "true";
    attribute DONT_TOUCH of ro3 : signal is "true";
    attribute DONT_TOUCH of ro4 : signal is "true";
    attribute DONT_TOUCH of ro5 : signal is "true";
    attribute DONT_TOUCH of ro6 : signal is "true";
    attribute DONT_TOUCH of ro7 : signal is "true";

    attribute DONT_TOUCH of out0 : signal is "true";
    attribute DONT_TOUCH of out1 : signal is "true";
    attribute DONT_TOUCH of out2 : signal is "true";
    attribute DONT_TOUCH of out3 : signal is "true";
    attribute DONT_TOUCH of out4 : signal is "true";
    attribute DONT_TOUCH of out5 : signal is "true";
    attribute DONT_TOUCH of out6 : signal is "true";
    attribute DONT_TOUCH of out7 : signal is "true";
    attribute DONT_TOUCH of out8 : signal is "true";
    attribute DONT_TOUCH of out9 : signal is "true";
    attribute DONT_TOUCH of out10 : signal is "true";
    attribute DONT_TOUCH of out11 : signal is "true";
    attribute DONT_TOUCH of out12 : signal is "true";
    attribute DONT_TOUCH of out13 : signal is "true";
    attribute DONT_TOUCH of out14 : signal is "true";
    attribute DONT_TOUCH of out15 : signal is "true";
    attribute DONT_TOUCH of out16 : signal is "true";
    attribute DONT_TOUCH of out17 : signal is "true";
    attribute DONT_TOUCH of out18 : signal is "true";
    attribute DONT_TOUCH of out19 : signal is "true";
    attribute DONT_TOUCH of out20 : signal is "true";
    attribute DONT_TOUCH of out21 : signal is "true";
    attribute DONT_TOUCH of out22 : signal is "true";
    attribute DONT_TOUCH of out23 : signal is "true";

    attribute ALLOW_COMBINATORIAL_LOOPS : string;
    attribute ALLOW_COMBINATORIAL_LOOPS of ro0 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro1 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro2 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro3 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro4 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro5 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro6 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of ro7 : signal is "true";

    attribute ALLOW_COMBINATORIAL_LOOPS of out0 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out1 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out2 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out3 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out4 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out5 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out6 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out7 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out8 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out9 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out10 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out11 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out12 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out13 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out14 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out15 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out16 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out17 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out18 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out19 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out20 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out21 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out22 : signal is "true";
    attribute ALLOW_COMBINATORIAL_LOOPS of out23 : signal is "true";

    attribute HU_SET : string;
    attribute HU_SET of eLut6_RoPair0 : label is "huset0";
    attribute HU_SET of eLut5_RoPair0 : label is "huset0";
    attribute HU_SET of eLut6_RoPair1 : label is "huset0";
    attribute HU_SET of eLut5_RoPair1 : label is "huset0";
    attribute HU_SET of eLut6_RoPair2 : label is "huset0";
    attribute HU_SET of eLut5_RoPair2 : label is "huset0";
    attribute HU_SET of eLut6_RoPair3 : label is "huset0";
    attribute HU_SET of eLut5_RoPair3 : label is "huset0";

    attribute HU_SET of eLut5_Config_0 : label is "huset0";
    attribute HU_SET of eLut5_Config_1 : label is "huset0";
    attribute HU_SET of eLut5_Config_2 : label is "huset0";
    attribute HU_SET of eLut5_Config_3 : label is "huset0";
    attribute HU_SET of eLut5_Config_4 : label is "huset0";
    attribute HU_SET of eLut5_Config_5 : label is "huset0";
    attribute HU_SET of eLut5_Config_6 : label is "huset0";
    attribute HU_SET of eLut5_Config_7 : label is "huset0";

    attribute HU_SET of eLut6_CxUnit_0 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_0 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_1 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_1 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_2 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_2 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_3 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_3 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_4 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_4 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_5 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_5 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_6 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_6 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_7 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_7 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_8 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_8 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_9 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_9 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_10 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_10 : label is "huset0";
    attribute HU_SET of eLut6_CxUnit_11 : label is "huset0";
    attribute HU_SET of eLut5_CxUnit_11 : label is "huset0";

    attribute HU_SET of eBC1 : label is "huset0";
    attribute HU_SET of eBC2 : label is "huset0";
    attribute HU_SET of eAB2 : label is "huset0";
    attribute HU_SET of eAB1 : label is "huset0";
    attribute HU_SET of eBF1 : label is "huset0";
    attribute HU_SET of eBF2 : label is "huset0";
    attribute HU_SET of eCD2 : label is "huset0";
    attribute HU_SET of eCD1 : label is "huset0";
    attribute HU_SET of eAD1 : label is "huset0";
    attribute HU_SET of eAD2 : label is "huset0";
    attribute HU_SET of eAE1 : label is "huset0";
    attribute HU_SET of eAE2 : label is "huset0";
    attribute HU_SET of eEF1 : label is "huset0";
    attribute HU_SET of eEF2 : label is "huset0";
    attribute HU_SET of eDH1 : label is "huset0";
    attribute HU_SET of eDH2 : label is "huset0";
    attribute HU_SET of eEH1 : label is "huset0";
    attribute HU_SET of eEH2 : label is "huset0";
    attribute HU_SET of eCG1 : label is "huset0";
    attribute HU_SET of eCG2 : label is "huset0";
    attribute HU_SET of eGH2 : label is "huset0";
    attribute HU_SET of eGH1 : label is "huset0";
    attribute HU_SET of eFG1 : label is "huset0";
    attribute HU_SET of eFG2 : label is "huset0";

    attribute HU_SET of eLut4_Xor_0 : label is "huset0";
    attribute HU_SET of eLut4_Xor_1 : label is "huset0";
    attribute HU_SET of eLut4_Xor_2 : label is "huset0";
    attribute HU_SET of eLut4_Xor_3 : label is "huset0";
    attribute HU_SET of eLut4_Xor_4 : label is "huset0";
    attribute HU_SET of eLut4_Xor_5 : label is "huset0";

    attribute HU_SET of eRng0 : label is "huset0";
    attribute HU_SET of eRng1 : label is "huset0";
    attribute HU_SET of eRng2 : label is "huset0";
    attribute HU_SET of eRng3 : label is "huset0";
    attribute HU_SET of eRng4 : label is "huset0";
    attribute HU_SET of eRng5 : label is "huset0";

    attribute RLOC : string;
    attribute RLOC of eLut6_RoPair0 : label is "X0Y0";
    attribute RLOC of eLut5_RoPair0 : label is "X0Y0";

    attribute RLOC of eLut6_RoPair1 : label is "X0Y1";
    attribute RLOC of eLut5_RoPair1 : label is "X0Y1";
    attribute RLOC of eLut6_RoPair2 : label is "X0Y1";
    attribute RLOC of eLut5_RoPair2 : label is "X0Y1";

    attribute RLOC of eLut6_RoPair3 : label is "X0Y2";
    attribute RLOC of eLut5_RoPair3 : label is "X0Y2";

    attribute BEL : string;
    attribute BEL of eLut6_RoPair0 : label is "B6LUT";
    attribute BEL of eLut5_RoPair0 : label is "B5LUT";
    attribute BEL of eLut6_RoPair1 : label is "A6LUT";
    attribute BEL of eLut5_RoPair1 : label is "A5LUT";
    attribute BEL of eLut6_RoPair2 : label is "D6LUT";
    attribute BEL of eLut5_RoPair2 : label is "D5LUT";
    attribute BEL of eLut6_RoPair3 : label is "C6LUT";
    attribute BEL of eLut5_RoPair3 : label is "C5LUT";
    
    attribute RLOC of eLut5_Config_0 : label is "X0Y0";
    attribute RLOC of eLut5_Config_1 : label is "X0Y0";
    attribute RLOC of eLut5_Config_2 : label is "X0Y0";

    attribute RLOC of eLut5_Config_3 : label is "X0Y1";
    attribute RLOC of eLut5_Config_4 : label is "X0Y1";

    attribute RLOC of eLut5_Config_5 : label is "X0Y2";
    attribute RLOC of eLut5_Config_6 : label is "X0Y2";
    attribute RLOC of eLut5_Config_7 : label is "X0Y2";

    attribute BEL of eLut5_Config_0 : label is "A6LUT";
    attribute BEL of eLut5_Config_1 : label is "C6LUT";
    attribute BEL of eLut5_Config_2 : label is "D6LUT";
    attribute BEL of eLut5_Config_3 : label is "B6LUT";
    attribute BEL of eLut5_Config_4 : label is "C6LUT";
    attribute BEL of eLut5_Config_5 : label is "A6LUT";
    attribute BEL of eLut5_Config_6 : label is "B6LUT";
    attribute BEL of eLut5_Config_7 : label is "D6LUT";

    attribute RLOC of eLut6_CxUnit_0 : label is "X1Y0";
    attribute RLOC of eLut5_CxUnit_0 : label is "X1Y0";
    attribute RLOC of eLut6_CxUnit_1 : label is "X1Y0";
    attribute RLOC of eLut5_CxUnit_1 : label is "X1Y0";
    attribute RLOC of eLut6_CxUnit_2 : label is "X1Y0";
    attribute RLOC of eLut5_CxUnit_2 : label is "X1Y0";
    attribute RLOC of eLut6_CxUnit_3 : label is "X1Y0";
    attribute RLOC of eLut5_CxUnit_3 : label is "X1Y0";

    attribute RLOC of eLut6_CxUnit_4 : label is "X1Y1";
    attribute RLOC of eLut5_CxUnit_4 : label is "X1Y1";
    attribute RLOC of eLut6_CxUnit_5 : label is "X1Y1";
    attribute RLOC of eLut5_CxUnit_5 : label is "X1Y1";
    attribute RLOC of eLut6_CxUnit_6 : label is "X1Y1";
    attribute RLOC of eLut5_CxUnit_6 : label is "X1Y1";
    attribute RLOC of eLut6_CxUnit_7 : label is "X1Y1";
    attribute RLOC of eLut5_CxUnit_7 : label is "X1Y1";

    attribute RLOC of eLut6_CxUnit_8 : label is "X1Y2";
    attribute RLOC of eLut5_CxUnit_8 : label is "X1Y2";
    attribute RLOC of eLut6_CxUnit_9 : label is "X1Y2";
    attribute RLOC of eLut5_CxUnit_9 : label is "X1Y2";
    attribute RLOC of eLut6_CxUnit_10 : label is "X1Y2";
    attribute RLOC of eLut5_CxUnit_10 : label is "X1Y2";
    attribute RLOC of eLut6_CxUnit_11 : label is "X1Y2";
    attribute RLOC of eLut5_CxUnit_11 : label is "X1Y2";

    attribute BEL of eLut6_CxUnit_0 : label is "A6LUT";
    attribute BEL of eLut5_CxUnit_0 : label is "A5LUT";
    attribute BEL of eLut6_CxUnit_1 : label is "B6LUT";
    attribute BEL of eLut5_CxUnit_1 : label is "B5LUT";
    attribute BEL of eLut6_CxUnit_2 : label is "C6LUT";
    attribute BEL of eLut5_CxUnit_2 : label is "C5LUT";
    attribute BEL of eLut6_CxUnit_3 : label is "D6LUT";
    attribute BEL of eLut5_CxUnit_3 : label is "D5LUT";
    attribute BEL of eLut6_CxUnit_4 : label is "A6LUT";
    attribute BEL of eLut5_CxUnit_4 : label is "A5LUT";
    attribute BEL of eLut6_CxUnit_5 : label is "B6LUT";
    attribute BEL of eLut5_CxUnit_5 : label is "B5LUT";
    attribute BEL of eLut6_CxUnit_6 : label is "C6LUT";
    attribute BEL of eLut5_CxUnit_6 : label is "C5LUT";
    attribute BEL of eLut6_CxUnit_7 : label is "D6LUT";
    attribute BEL of eLut5_CxUnit_7 : label is "D5LUT";
    attribute BEL of eLut6_CxUnit_8 : label is "A6LUT";
    attribute BEL of eLut5_CxUnit_8 : label is "A5LUT";
    attribute BEL of eLut6_CxUnit_9 : label is "B6LUT";
    attribute BEL of eLut5_CxUnit_9 : label is "B5LUT";
    attribute BEL of eLut6_CxUnit_10 : label is "C6LUT";
    attribute BEL of eLut5_CxUnit_10 : label is "C5LUT";
    attribute BEL of eLut6_CxUnit_11 : label is "D6LUT";
    attribute BEL of eLut5_CxUnit_11 : label is "D5LUT";

    attribute RLOC of eBC1 : label is "X0Y0";
    attribute RLOC of eBC2 : label is "X0Y0";
    attribute RLOC of eAB2 : label is "X0Y0";
    attribute RLOC of eAB1 : label is "X0Y0";
    attribute RLOC of eBF1 : label is "X0Y1";
    attribute RLOC of eBF2 : label is "X0Y1";
    attribute RLOC of eCD2 : label is "X0Y1";
    attribute RLOC of eCD1 : label is "X0Y1";
    attribute RLOC of eAD1 : label is "X0Y2";
    attribute RLOC of eAD2 : label is "X0Y2";
    attribute RLOC of eAE1 : label is "X0Y2";
    attribute RLOC of eAE2 : label is "X0Y2";
    attribute RLOC of eEF1 : label is "X1Y0";
    attribute RLOC of eEF2 : label is "X1Y0";
    attribute RLOC of eDH1 : label is "X1Y0";
    attribute RLOC of eDH2 : label is "X1Y0";
    attribute RLOC of eEH1 : label is "X1Y1";
    attribute RLOC of eEH2 : label is "X1Y1";
    attribute RLOC of eCG1 : label is "X1Y1";
    attribute RLOC of eCG2 : label is "X1Y1";
    attribute RLOC of eGH2 : label is "X1Y2";
    attribute RLOC of eGH1 : label is "X1Y2";
    attribute RLOC of eFG1 : label is "X1Y2";
    attribute RLOC of eFG2 : label is "X1Y2";

    attribute BEL of eBC1 : label is "AFF";
    attribute BEL of eBC2 : label is "BFF";
    attribute BEL of eAB2 : label is "CFF";
    attribute BEL of eAB1 : label is "DFF";
    attribute BEL of eBF1 : label is "AFF";
    attribute BEL of eBF2 : label is "BFF";
    attribute BEL of eCD2 : label is "CFF";
    attribute BEL of eCD1 : label is "DFF";
    attribute BEL of eAD1 : label is "AFF";
    attribute BEL of eAD2 : label is "BFF";
    attribute BEL of eAE1 : label is "CFF";
    attribute BEL of eAE2 : label is "DFF";
    attribute BEL of eEF1 : label is "AFF";
    attribute BEL of eEF2 : label is "BFF";
    attribute BEL of eDH1 : label is "CFF";
    attribute BEL of eDH2 : label is "DFF";
    attribute BEL of eEH1 : label is "AFF";
    attribute BEL of eEH2 : label is "BFF";
    attribute BEL of eCG1 : label is "CFF";
    attribute BEL of eCG2 : label is "DFF";
    attribute BEL of eGH2 : label is "AFF";
    attribute BEL of eGH1 : label is "BFF";
    attribute BEL of eFG1 : label is "CFF";
    attribute BEL of eFG2 : label is "DFF";

    attribute RLOC of eLut4_Xor_0 : label is "X2Y0";
    attribute RLOC of eLut4_Xor_1 : label is "X2Y0";
    attribute RLOC of eLut4_Xor_2 : label is "X2Y1";
    attribute RLOC of eLut4_Xor_3 : label is "X2Y1";
    attribute RLOC of eLut4_Xor_4 : label is "X2Y2";
    attribute RLOC of eLut4_Xor_5 : label is "X2Y2";

    attribute BEL of eLut4_Xor_0 : label is "A6LUT";
    attribute BEL of eLut4_Xor_1 : label is "C6LUT";
    attribute BEL of eLut4_Xor_2 : label is "A6LUT";
    attribute BEL of eLut4_Xor_3 : label is "C6LUT";
    attribute BEL of eLut4_Xor_4 : label is "A6LUT";
    attribute BEL of eLut4_Xor_5 : label is "C6LUT";

    attribute RLOC of eRng0 : label is "X2Y0";
    attribute RLOC of eRng1 : label is "X2Y0";
    attribute RLOC of eRng2 : label is "X2Y1";
    attribute RLOC of eRng3 : label is "X2Y1";
    attribute RLOC of eRng4 : label is "X2Y2";
    attribute RLOC of eRng5 : label is "X2Y2";

    attribute BEL of eRng0 : label is "D5FF";
    attribute BEL of eRng1 : label is "B5FF";
    attribute BEL of eRng2 : label is "D5FF";
    attribute BEL of eRng3 : label is "B5FF";
    attribute BEL of eRng4 : label is "D5FF";
    attribute BEL of eRng5 : label is "B5FF";

    signal clr : std_logic := '0';

    signal valid : std_logic := '0';
begin

    clr <= not i_resetn;

    -------------------------------------------------------------
    -- ring oscillators
    
    ro0_in <= transport ro0 after 1000 ps;
    ro1_in <= transport ro1 after 1000 ps;
    ro2_in <= transport ro2 after 1000 ps;
    ro3_in <= transport ro3 after 1000 ps;
    ro4_in <= transport ro4 after 1000 ps;
    ro5_in <= transport ro5 after 1000 ps;
    ro6_in <= transport ro6 after 1000 ps;
    ro7_in <= transport ro7 after 1000 ps;

    -- Vivado makes it borderline impossible to allow combinational
    -- loops on these things. It requires work in XDC, which given that
    -- Vivado's favorite pastime is giving signals inane names, renaming
    -- signals and entity instances, and just all around being a nuisance,
    -- I'm inclined to give it an instantiation it cannot refuse.

    -- eLut6_2_RoPair_0 : LUT6_2
    -- generic map (
    --     INIT => x"3333000055550000"
    -- ) port map (
    --     O6 => ro1,
    --     O5 => ro0,
    --     I0 => ro0_in,
    --     I1 => ro1_in,
    --     I2 => '0',
    --     I3 => '0',
    --     I4 => i_resetn,
    --     I5 => '1'
    -- );
    
    eLut6_RoPair0 : LUT6
    generic map (
        INIT => x"3333000055550000"
    ) port map (
        O  => ro1,
        I0 => ro0_in,
        I1 => ro1_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_RoPair0 : LUT5
    generic map (
        INIT => x"55550000"
    ) port map (
        O  => ro0,
        I0 => ro0_in,
        I1 => ro1_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn
    );

    eLut6_RoPair1 : LUT6
    generic map (
        INIT => x"3333000055550000"
    ) port map (
        O  => ro3,
        I0 => ro2_in,
        I1 => ro3_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_RoPair1 : LUT5
    generic map (
        INIT => x"55550000"
    ) port map (
        O  => ro2,
        I0 => ro2_in,
        I1 => ro3_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn
    );

    eLut6_RoPair2 : LUT6
    generic map (
        INIT => x"3333000055550000"
    ) port map (
        O  => ro5,
        I0 => ro4_in,
        I1 => ro5_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_RoPair2 : LUT5
    generic map (
        INIT => x"55550000"
    ) port map (
        O  => ro4,
        I0 => ro4_in,
        I1 => ro5_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn
    );

    eLut6_RoPair3 : LUT6
    generic map (
        INIT => x"3333000055550000"
    ) port map (
        O  => ro7,
        I0 => ro6_in,
        I1 => ro7_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_RoPair3 : LUT5
    generic map (
        INIT => x"55550000"
    ) port map (
        O  => ro6,
        I0 => ro6_in,
        I1 => ro7_in,
        I2 => '0',
        I3 => '0',
        I4 => i_resetn
    );

    ----------------------------------------------------------------------------
    -- cx units

    out0_delay <= transport out0 after 1000 ps;
    out1_delay <= transport out1 after 1000 ps;
    out2_delay <= transport out2 after 1000 ps;
    out3_delay <= transport out3 after 1000 ps;
    out4_delay <= transport out4 after 1000 ps;
    out5_delay <= transport out5 after 1000 ps;
    out6_delay <= transport out6 after 1000 ps;
    out7_delay <= transport out7 after 1000 ps;
    out8_delay <= transport out8 after 1000 ps;
    out9_delay <= transport out9 after 1000 ps;
    out10_delay <= transport out10 after 1000 ps;
    out11_delay <= transport out11 after 1000 ps;
    out12_delay <= transport out12 after 1000 ps;
    out13_delay <= transport out13 after 1000 ps;
    out14_delay <= transport out14 after 1000 ps;
    out15_delay <= transport out15 after 1000 ps;
    out16_delay <= transport out16 after 1000 ps;
    out17_delay <= transport out17 after 1000 ps;
    out18_delay <= transport out18 after 1000 ps;
    out19_delay <= transport out19 after 1000 ps;
    out20_delay <= transport out20 after 1000 ps;
    out21_delay <= transport out21 after 1000 ps;
    out22_delay <= transport out22 after 1000 ps;
    out23_delay <= transport out23 after 1000 ps;

    -- See above for why Vivado and I are not on speaking terms.

    -- eLut6_2_CxUnit_0 : LUT6_2
    -- generic map (
    --     INIT => x"0FF0000066660000"
    -- ) port map (
    --     O6 => out1,
    --     O5 => out0,
    --     I0 => out0_delay,
    --     I1 => in0,
    --     I2 => in1,
    --     I3 => out1_delay,
    --     I4 => i_resetn,
    --     I5 => '1'
    -- );

    ----

    eLut6_CxUnit_0 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out1,
        I0 => out0_delay,
        I1 => in0,
        I2 => in1,
        I3 => out1_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_0 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out0,
        I0 => out0_delay,
        I1 => in0,
        I2 => in1,
        I3 => out1_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_1 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out3,
        I0 => out2_delay,
        I1 => in2,
        I2 => in3,
        I3 => out3_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_1 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out2,
        I0 => out2_delay,
        I1 => in2,
        I2 => in3,
        I3 => out3_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_2 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out5,
        I0 => out4_delay,
        I1 => in4,
        I2 => in5,
        I3 => out5_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_2 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out4,
        I0 => out4_delay,
        I1 => in4,
        I2 => in5,
        I3 => out5_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_3 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out7,
        I0 => out6_delay,
        I1 => in6,
        I2 => in7,
        I3 => out7_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_3 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out6,
        I0 => out6_delay,
        I1 => in6,
        I2 => in7,
        I3 => out7_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_4 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out9,
        I0 => out8_delay,
        I1 => in8,
        I2 => in9,
        I3 => out9_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_4 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out8,
        I0 => out8_delay,
        I1 => in8,
        I2 => in9,
        I3 => out9_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_5 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out11,
        I0 => out10_delay,
        I1 => in10,
        I2 => in11,
        I3 => out11_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_5 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out10,
        I0 => out10_delay,
        I1 => in10,
        I2 => in11,
        I3 => out11_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_6 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out13,
        I0 => out12_delay,
        I1 => in12,
        I2 => in13,
        I3 => out13_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_6 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out12,
        I0 => out12_delay,
        I1 => in12,
        I2 => in13,
        I3 => out13_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_7 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out15,
        I0 => out14_delay,
        I1 => in14,
        I2 => in15,
        I3 => out15_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_7 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out14,
        I0 => out14_delay,
        I1 => in14,
        I2 => in15,
        I3 => out15_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_8 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out17,
        I0 => out16_delay,
        I1 => in16,
        I2 => in17,
        I3 => out17_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_8 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out16,
        I0 => out16_delay,
        I1 => in16,
        I2 => in17,
        I3 => out17_delay,
        I4 => i_resetn
    );

    ----

    eLut6_CxUnit_9 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out19,
        I0 => out18_delay,
        I1 => in18,
        I2 => in19,
        I3 => out19_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_9 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out18,
        I0 => out18_delay,
        I1 => in18,
        I2 => in19,
        I3 => out19_delay,
        I4 => i_resetn
    );

    ---

    eLut6_CxUnit_10 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out21,
        I0 => out20_delay,
        I1 => in20,
        I2 => in21,
        I3 => out21_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_10 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out20,
        I0 => out20_delay,
        I1 => in20,
        I2 => in21,
        I3 => out21_delay,
        I4 => i_resetn
    );

    ---- 

    eLut6_CxUnit_11 : LUT6
    generic map (
        INIT => x"0FF0000066660000"
    ) port map (
        O  => out23,
        I0 => out22_delay,
        I1 => in22,
        I2 => in23,
        I3 => out23_delay,
        I4 => i_resetn,
        I5 => '1'
    );

    eLut5_CxUnit_11 : LUT5
    generic map (
        INIT => x"66660000"
    ) port map (
        O  => out22,
        I0 => out22_delay,
        I1 => in22,
        I2 => in23,
        I3 => out23_delay,
        I4 => i_resetn
    );

    --------------------------------------------------------------
    -- configurators
    
    eLut5_Config_0 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config0,
        I0 => ro0_in,
        I1 => out0_delay,
        I2 => out2_delay,
        I3 => out4_delay,
        I4 => i_resetn
    );

    eLut5_Config_1 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config1,
        I0 => ro1_in,
        I1 => out1_delay,
        I2 => out7_delay,
        I3 => out18_delay,
        I4 => i_resetn
    );

    eLut5_Config_2 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config2,
        I0 => ro2_in,
        I1 => out19_delay,
        I2 => out21_delay,
        I3 => out23_delay,
        I4 => i_resetn
    );

    eLut5_Config_3 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config3,
        I0 => ro3_in,
        I1 => out5_delay,
        I2 => out13_delay,
        I3 => out22_delay,
        I4 => i_resetn
    );

    eLut5_Config_4 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config4,
        I0 => ro4_in,
        I1 => out3_delay,
        I2 => out8_delay,
        I3 => out10_delay,
        I4 => i_resetn
    );

    eLut5_Config_5 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config5,
        I0 => ro5_in,
        I1 => out6_delay,
        I2 => out9_delay,
        I3 => out14_delay,
        I4 => i_resetn
    );

    eLut5_Config_6 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config6,
        I0 => ro6_in,
        I1 => out15_delay,
        I2 => out17_delay,
        I3 => out20_delay,
        I4 => i_resetn
    );

    eLut5_Config_7 : LUT5
    generic map (
        INIT => x"69960000"
    ) port map (
        O  => config7,
        I0 => ro7_in,
        I1 => out11_delay,
        I2 => out12_delay,
        I3 => out16_delay,
        I4 => i_resetn
    );

    in0  <= transport config0 after 1000 ps;
    in1  <= transport config1 after 1000 ps;
    in2  <= transport config0 after 1000 ps;
    in3  <= transport config4 after 1000 ps;
    in4  <= transport config0 after 1000 ps;
    in5  <= transport config3 after 1000 ps;
    in6  <= transport config1 after 1000 ps;
    in7  <= transport config5 after 1000 ps;
    in8  <= transport config4 after 1000 ps;
    in9  <= transport config5 after 1000 ps;
    in10 <= transport config4 after 1000 ps;
    in11 <= transport config7 after 1000 ps;
    in12 <= transport config7 after 1000 ps;
    in13 <= transport config3 after 1000 ps;
    in14 <= transport config5 after 1000 ps;
    in15 <= transport config6 after 1000 ps;
    in16 <= transport config7 after 1000 ps;
    in17 <= transport config6 after 1000 ps;
    in18 <= transport config1 after 1000 ps;
    in19 <= transport config2 after 1000 ps;
    in20 <= transport config6 after 1000 ps;
    in21 <= transport config2 after 1000 ps;
    in22 <= transport config3 after 1000 ps;
    in23 <= transport config2 after 1000 ps;

    --------------------------------------------------------------------
    -- signal renaming and initial sampling flops

    bc1 <= out0_delay;
    bc2 <= out1_delay;
    ab2 <= out2_delay;
    ab1 <= out3_delay;
    bf1 <= out4_delay;
    bf2 <= out5_delay;
    cd2 <= out6_delay;
    cd1 <= out7_delay;
    ad1 <= out8_delay;
    ad2 <= out9_delay;
    ae1 <= out10_delay;
    ae2 <= out11_delay;
    ef1 <= out12_delay;
    ef2 <= out13_delay;
    dh1 <= out14_delay;
    dh2 <= out15_delay;
    eh1 <= out16_delay;
    eh2 <= out17_delay;
    cg1 <= out18_delay;
    cg2 <= out19_delay;
    gh2 <= out20_delay;
    gh1 <= out21_delay;
    fg1 <= out22_delay;
    fg2 <= out23_delay;

    eBC1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => bc1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => bc1
    );

    eBC2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => bc2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => bc2
    );

    eAB2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ab2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ab2
    );

    eAB1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ab1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ab1
    );

    eBF1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => bf1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => bf1
    );

    eBF2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => bf2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => bf2
    );

    eCD2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => cd2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => cd2
    );

    eCD1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => cd1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => cd1
    );

    eAD1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ad1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ad1
    );

    eAD2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ad2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ad2
    );

    eAE1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ae1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ae1
    );

    eAE2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ae2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ae2
    );

    eEF1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ef1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ef1
    );

    eEF2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => ef2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => ef2
    );

    eDH1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => dh1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => dh1
    );

    eDH2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => dh2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => dh2
    );

    eEH1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => eh1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => eh1
    );

    eEH2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => eh2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => eh2
    );

    eCG1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => cg1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => cg1
    );

    eCG2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => cg2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => cg2
    );

    eGH2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => gh2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => gh2
    );

    eGH1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => gh1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => gh1
    );

    eFG1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => fg1_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => fg1
    );

    eFG2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => fg2_reg,
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => fg2
    );

    eLut4_Xor_0 : LUT4
    generic map (
        INIT => x"6996"
    ) port map (
        O => rng0,
        I0 => ab1_reg,
        I1 => ae2_reg,
        I2 => ef2_reg,
        I3 => bf1_reg
    );

    eLut4_Xor_1 : LUT4
    generic map (
        INIT => x"6996"
    ) port map (
        O => rng1,
        I0 => ad2_reg,
        I1 => dh2_reg,
        I2 => eh1_reg,
        I3 => ae1_reg
    );

    eLut4_Xor_2 : LUT4
    generic map (
        INIT => x"6996"
    ) port map (
        O => rng2,
        I0 => cd1_reg,
        I1 => cg2_reg,
        I2 => gh2_reg,
        I3 => dh1_reg
    );

    eLut4_Xor_3 : LUT4
    generic map (
        INIT => x"6996"
    ) port map (
        O => rng3,
        I0 => bc2_reg,
        I1 => cd2_reg,
        I2 => ad1_reg,
        I3 => ab2_reg
    );

    eLut4_Xor_4 : LUT4
    generic map (
        INIT => x"6996"
    ) port map (
        O => rng4,
        I0 => bc1_reg,
        I1 => bf2_reg,
        I2 => fg2_reg,
        I3 => cg1_reg
    );

    eLut4_Xor_5 : LUT4
    generic map (
        INIT => x"6996"
    ) port map (
        O => rng5,
        I0 => eh2_reg,
        I1 => gh1_reg,
        I2 => fg1_reg,
        I3 => ef1_reg
    );

    ---------------------------------------------------
    -- final sampling flops

    eRng0 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => o_rng(0),
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => rng0
    );

    eRng1 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => o_rng(1),
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => rng1
    );

    eRng2 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => o_rng(2),
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => rng2
    );

    eRng3 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => o_rng(3),
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => rng3
    );

    eRng4 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => o_rng(4),
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => rng4
    );

    eRng5 : FDCE
    generic map (
        INIT => '0'
    ) port map (
        Q   => o_rng(5),
        C   => i_clk,
        CE  => '1',
        CLR => clr,
        D   => rng5
    );

    ------------------------
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