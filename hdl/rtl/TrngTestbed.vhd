-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library ostrngs;

entity TrngTestbed is
    generic (
        -- Sets the total number of entropy sources to instantiate
        cNumEntropySources : positive range 1 to 8 := 8;
        -- Provides a mechanism to instantiate various unique entropy sources
        cEntropySource00   : string := "MeshCoupledXor";
        cEntropySource01   : string := "MeshCoupledXor";
        cEntropySource02   : string := "MeshCoupledXor";
        cEntropySource03   : string := "MeshCoupledXor";
        cEntropySource04   : string := "MeshCoupledXor";
        cEntropySource05   : string := "MeshCoupledXor";
        cEntropySource06   : string := "MeshCoupledXor";
        cEntropySource07   : string := "MeshCoupledXor";
        -- Fifo depth in groups of samples
        cFifoDepth         : positive := 1024
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- 
        i_s_axi_awaddr  : in std_logic_vector(9 downto 0);
        --
        i_s_axi_awprot  : in std_logic_vector(2 downto 0);
        --
        i_s_axi_awvalid : in std_logic;
        --
        o_s_axi_awready : out std_logic;

        --
        i_s_axi_wdata   : in std_logic_vector(31 downto 0);
        --
        i_s_axi_wstrb   : in std_logic_vector(3 downto 0);
        --
        i_s_axi_wvalid  : in std_logic;
        --
        o_s_axi_wready  : out std_logic;

        --
        o_s_axi_bresp   : out std_logic_vector(1 downto 0);
        --
        o_s_axi_bvalid  : out std_logic;
        --
        i_s_axi_bready  : in std_logic;

        -- 
        i_s_axi_araddr  : in std_logic_vector(9 downto 0);
        --
        i_s_axi_arprot  : in std_logic_vector(2 downto 0);
        --
        i_s_axi_arvalid : in std_logic;
        --
        o_s_axi_arready : out std_logic;

        --
        o_s_axi_rdata   : out std_logic_vector(31 downto 0);
        --
        o_s_axi_rresp   : out std_logic_vector(1 downto 0);
        --
        o_s_axi_rvalid  : out std_logic;
        --
        i_s_axi_rready  : in std_logic
    );
end entity TrngTestbed;

architecture rtl of TrngTestbed is
    constant cDataWidth_B : positive := 1;
    constant cFifoWidth   : positive := 4;
    type state_t is (IDLE, WRITE_SEQUENCE, WRITE_RESPONSE, READ_SEQUENCE, READ_RESPONSE);
    signal state : state_t := IDLE;

    signal rng_addr   : std_logic_vector(7 downto 0) := (others => '0');
    signal rng_data   : std_logic_vector(8 * cDataWidth_B - 1 downto 0) := (others => '0');
    signal rng_dvalid : std_logic := '0';

    signal fifo_pop    : std_logic := '0';
    signal fifo_data   : std_logic_vector(8 * cDataWidth_B * cFifoWidth - 1 downto 0) := (others => '0');
    signal fifo_dvalid : std_logic := '0';

    signal pll_den  : std_logic := '0';
    signal pll_dwe  : std_logic := '0';
    signal pll_drdy : std_logic := '0';
    signal pll_do   : std_logic_vector(15 downto 0) := (others => '0');

    signal addr   : std_logic_vector(9 downto 0) := (others => '0');
    signal status : std_logic_vector(31 downto 0) := (others => '0');
begin
    
    eSandbox : entity ostrngs.TrngSandbox
    generic map (
        cNumEntropySources => cNumEntropySources,
        cEntropySource00   => cEntropySource00,
        cEntropySource01   => cEntropySource01,
        cEntropySource02   => cEntropySource02,
        cEntropySource03   => cEntropySource03,
        cEntropySource04   => cEntropySource04,
        cEntropySource05   => cEntropySource05,
        cEntropySource06   => cEntropySource06,
        cEntropySource07   => cEntropySource07,
        cDataWidth_B       => cDataWidth_B,
        cFifoWidth         => cFifoWidth,
        cFifoDepth         => cFifoDepth
    ) port map (
        i_clk    => i_clk,
        i_resetn => i_resetn,

        i_rng_addr   => rng_addr,
        o_rng_clk    => open,
        o_rng_data   => rng_data,
        o_rng_dvalid => rng_dvalid,

        i_fifo_pop    => fifo_pop,
        o_fifo_data   => fifo_data,
        o_fifo_dvalid => fifo_dvalid,
        o_fifo_full   => open,
        o_fifo_afull  => open,
        o_fifo_aempty => open,
        o_fifo_empty  => open,

        i_pll_daddr  => addr(8 downto 2),
        i_pll_den    => pll_den,
        i_pll_dwe    => pll_dwe,
        i_pll_di     => i_s_axi_wdata(15 downto 0),
        o_pll_drdy   => pll_drdy,
        o_pll_do     => pll_do,
        o_pll_locked => open
    );

    PllAccessSignals: process(state, addr, i_s_axi_wstrb, fifo_dvalid)
    begin
        if (state = WRITE_SEQUENCE or state = READ_SEQUENCE) then
            pll_den <= not addr(9);
        else
            pll_den <= '0';
        end if;

        if (state = READ_SEQUENCE and addr = "1000000000") then
            fifo_pop <= not fifo_dvalid;
        else
            fifo_pop <= '0';
        end if;

        pll_dwe <= i_s_axi_wstrb(0) and 
                   i_s_axi_wstrb(1) and 
                   not i_s_axi_wstrb(2) and 
                   not i_s_axi_wstrb(3);
    end process PllAccessSignals;

    StateMachine: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                state <= IDLE;

                o_s_axi_awready <= '0';
                o_s_axi_wready  <= '0';
                o_s_axi_bvalid  <= '0';
                o_s_axi_arready <= '0';
                o_s_axi_rvalid  <= '0';
            else
                case state is
                    when IDLE =>                        
                        if (i_s_axi_awvalid = '1') then
                            state <= WRITE_SEQUENCE;
                            addr  <= i_s_axi_awaddr;

                            o_s_axi_awready <= '1';
                            o_s_axi_wready  <= '1';
                        elsif (i_s_axi_arvalid = '1') then
                            state <= READ_SEQUENCE;
                            addr  <= i_s_axi_araddr;

                            o_s_axi_arready <= '1';
                        end if;

                    when WRITE_SEQUENCE =>
                        o_s_axi_awready <= '0';
                        if (i_s_axi_wvalid = '1') then
                            o_s_axi_wready <= '0';

                            o_s_axi_bvalid <= '1';
                            state          <= WRITE_RESPONSE;
                            case (addr) is
                                -- Not expecting misaligned reads/writes
                                when "0-------00" =>
                                    -- OKAY RESPONSE
                                    o_s_axi_bresp <= "00";
                                when "1000000-00" =>
                                    -- SLVERR RESPONSE (Read only)
                                    o_s_axi_bresp <= "10";
                                when others =>
                                    -- DECERR RESPONSE (Nothing at these addresses)
                                    o_s_axi_bresp <= "11";
                            end case;
                        end if;

                    when READ_SEQUENCE =>
                        o_s_axi_arready <= '0';
                        case (addr) is
                            -- Not expecting misaligned reads/writes
                            when "0-------00" =>
                                o_s_axi_rvalid <= pll_drdy;
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00"; 
                                if (pll_drdy = '1') then
                                    o_s_axi_rdata <= (others => '0');
                                    o_s_axi_rdata(15 downto 0) <= pll_do;

                                    state <= READ_RESPONSE;
                                end if;

                            -- Not expecting misaligned reads/writes
                            when "1000000000" =>
                                o_s_axi_rvalid <= fifo_dvalid;
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                if (fifo_dvalid = '1') then
                                    o_s_axi_rdata <= fifo_data;

                                    state <= READ_RESPONSE;
                                end if;

                            -- Not expecting misaligned reads/writes
                            when "1000000100" =>
                                o_s_axi_rvalid <= '1';
                                -- OKAY RESPONSE
                                o_s_axi_rresp  <= "00";
                                o_s_axi_rdata  <= status;

                                state <= READ_RESPONSE;

                            when others =>
                                -- DECERR (INVALID ADDRESS)
                                o_s_axi_rvalid <= '1';
                                o_s_axi_rresp  <= "11";

                                state <= READ_RESPONSE;
                        end case;

                    when WRITE_RESPONSE =>
                        if (i_s_axi_bready = '1') then
                            o_s_axi_bvalid <= '0';

                            state <= IDLE;
                        end if;

                    when READ_RESPONSE =>
                        if (i_s_axi_rready = '1') then
                            o_s_axi_rvalid <= '0';

                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process StateMachine;
    
end architecture rtl;