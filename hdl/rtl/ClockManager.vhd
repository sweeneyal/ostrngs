-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library unisim;
    use unisim.vcomponents.all;

entity ClockManager is
    port (
        i_clk    : in std_logic; 
        i_resetn : in std_logic;

        i_pll_daddr : in std_logic_vector(6 downto 0);
        i_pll_den   : in std_logic;
        i_pll_dwe   : in std_logic;
        i_pll_di    : in std_logic_vector(15 downto 0);
        o_pll_drdy  : out std_logic;
        o_pll_do    : out std_logic_vector(15 downto 0);

        o_pll_clks   : out std_logic_vector(5 downto 0);
        o_pll_locked : out std_logic
    );
end entity ClockManager;

architecture rtl of ClockManager is
    signal clkfbout : std_logic := '0';
begin
    
    -- PLLE2_ADV: Advanced Phase Locked Loop (PLL)
    --            7 Series
    -- Xilinx HDL Language Template, version 2025.1

    PLLE2_ADV_inst : PLLE2_ADV
    generic map (
        BANDWIDTH      => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
        CLKFBOUT_MULT  => 2,        -- Multiply value for all CLKOUT, (2-64)
        CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).

        -- CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
        CLKIN1_PERIOD => 0.0,
        CLKIN2_PERIOD => 0.0,

        -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
        CLKOUT0_DIVIDE => 1,
        CLKOUT1_DIVIDE => 1,
        CLKOUT2_DIVIDE => 1,
        CLKOUT3_DIVIDE => 1,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,

        -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT4_DUTY_CYCLE => 0.5,
        CLKOUT5_DUTY_CYCLE => 0.5,

        -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 0.0,
        CLKOUT2_PHASE => 0.0,
        CLKOUT3_PHASE => 0.0,
        CLKOUT4_PHASE => 0.0,
        CLKOUT5_PHASE => 0.0,
        COMPENSATION => "ZHOLD",   -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
        DIVCLK_DIVIDE => 2,        -- Master division value (1-56)

        -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
        REF_JITTER1  => 0.0,
        REF_JITTER2  => 0.0,
        STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
    )
    port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => o_pll_clks(0),   -- 1-bit output: CLKOUT0
        CLKOUT1 => o_pll_clks(1),   -- 1-bit output: CLKOUT1
        CLKOUT2 => o_pll_clks(2),   -- 1-bit output: CLKOUT2
        CLKOUT3 => o_pll_clks(3),   -- 1-bit output: CLKOUT3
        CLKOUT4 => o_pll_clks(4),   -- 1-bit output: CLKOUT4
        CLKOUT5 => o_pll_clks(5),   -- 1-bit output: CLKOUT5
        
        -- DRP Ports: Dynamic reconfiguration ports
        DCLK  => i_clk,       -- 1-bit input: DRP clock
        DADDR => i_pll_daddr, -- 7-bit input: DRP address
        DEN   => i_pll_den,   -- 1-bit input: DRP enable
        DI    => i_pll_di,    -- 16-bit input: DRP data
        DWE   => i_pll_dwe,   -- 1-bit input: DRP write enable
        DO    => o_pll_do,    -- 16-bit output: DRP data
        DRDY  => o_pll_drdy,  -- 1-bit output: DRP ready
        
        
        -- Clock Inputs: 1-bit (each) input: Clock inputs
        CLKIN1 => i_clk, -- 1-bit input: Primary clock
        CLKIN2 => '0',   -- 1-bit input: Secondary clock
        
        -- Control Ports: 1-bit (each) input: PLL control ports
        CLKINSEL => '1',      -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
        PWRDWN   => '0',      -- 1-bit input: Power-down
        RST      => i_resetn, -- 1-bit input: Reset
        
        
        -- Feedback Clocks: Clock feedback ports
        CLKFBOUT => clkfbout,     -- 1-bit output: Feedback clock
        LOCKED   => o_pll_locked, -- 1-bit output: LOCK
        CLKFBIN => clkfbout       -- 1-bit input: Feedback clock
    );

    -- End of PLLE2_ADV_inst instantiation
    
end architecture rtl;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------