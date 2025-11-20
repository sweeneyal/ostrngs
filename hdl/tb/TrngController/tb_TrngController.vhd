library vunit_lib;
    context vunit_lib.vunit_context;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library osvvm;
    use osvvm.TbUtilPkg.all;

library ostrngs;

library tb_ostrngs;

entity tb_TrngController is
    generic (runner_cfg : string);
end entity tb_TrngController;

architecture tb of tb_TrngController is
    procedure uart_transmit (
        signal   i_clk    : in std_logic;
        variable i_data   : in std_logic_vector(7 downto 0);
        signal   o_tx     : out std_logic;
        constant clockfrequency_Hz : in natural;
        constant baudrate_bps      : in natural
    ) is
        constant cBitPeriod    : time := (1.0e9 / real(baudrate_bps) * 1 ns);
        variable vRxData       : std_logic_vector(7 downto 0);
    begin
        vRxData := i_data;
        o_tx    <= '0';
        wait for cBitPeriod;

        for ii in 0 to 7 loop
            o_tx <= vRxData(ii);
            wait for cBitPeriod;
        end loop;

        o_tx <= '1';
        wait for 1.5 * cBitPeriod;
    end procedure;

    procedure uart_receive (
        signal   i_clk  : in  std_logic;
        signal   i_rx   : in  std_logic;
        variable o_data : out std_logic_vector(7 downto 0);
        constant clockfrequency_Hz : in natural;
        constant baudrate_bps      : in natural
    ) is
        constant cBitPeriod    : time    := (1.0e9 / real(baudrate_bps) * 1 ns);
        variable vTxData       : std_logic_vector(7 downto 0);
    begin
        if (i_rx /= '0') then
            wait until i_rx = '0'; -- Depending on the baud rate, the extra clock period included here is a rounding error.
        end if;

        wait for cBitPeriod;
        assert (i_rx = '0') report "ERROR: Start bit needs to be 0" severity error;
        for ii in 0 to 7 loop
            wait for cBitPeriod; -- Depending on the baud rate, the extra clock period included here is a rounding error.
            vTxData(ii) := i_rx;
        end loop;

        wait for cBitPeriod; -- Depending on the baud rate, the extra clock period included here is a rounding error.
        assert (i_rx = '1') report "ERROR: Stop bit needs to be 1" severity error;
        wait for 0.5 * cBitPeriod;
        o_data := vTxData;
    end procedure;

    signal clk_i    : std_logic := '0';
    signal resetn_i : std_logic := '0';

    signal uart_tx_o : std_logic := '1';
    signal uart_rx_i : std_logic := '1';

    signal m_axi_awaddr  : std_logic_vector(31 downto 0) := (others => '0') ;
    signal m_axi_awprot  : std_logic_vector(2 downto 0) := (others => '0') ;
    signal m_axi_awvalid : std_logic := '0';
    signal m_axi_awready : std_logic := '0';

    signal m_axi_wdata   : std_logic_vector(31 downto 0) := (others => '0');
    signal m_axi_wstrb   : std_logic_vector(3 downto 0) := (others => '0');
    signal m_axi_wvalid  : std_logic := '0';
    signal m_axi_wready  : std_logic := '0';

    signal m_axi_bresp   : std_logic_vector(1 downto 0) := (others => '0');
    signal m_axi_bvalid  : std_logic := '0';
    signal m_axi_bready  : std_logic := '0';

    signal m_axi_araddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal m_axi_arprot  : std_logic_vector(2 downto 0) := (others => '0');
    signal m_axi_arvalid : std_logic := '0';
    signal m_axi_arready : std_logic := '0';

    signal m_axi_rdata   : std_logic_vector(31 downto 0) := (others => '0');
    signal m_axi_rresp   : std_logic_vector(1 downto 0) := (others => '0');
    signal m_axi_rvalid  : std_logic := '0';
    signal m_axi_rready  : std_logic := '0';

    function get_address(s : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable p : std_logic_vector(87 downto 0) := (others => '0');
    begin
        p(7 downto 0)   := x"0A";
        p(39 downto 8)  := s;
        p(71 downto 40) := (others => '0');
        p(79 downto 72) := (others => '0');
        for ii in 0 to 9 loop
            p(87 downto 80) := std_logic_vector(
                unsigned(p(87 downto 80)) + unsigned(p(8 * ii + 7 downto 8 * ii))
            );
        end loop;
        return p;
    end function;

    function set_address(s : std_logic_vector(31 downto 0); d : std_logic_vector(31 downto 0); wstrb : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable p : std_logic_vector(87 downto 0) := (others => '0');
    begin
        p(7 downto 0)   := x"A0";
        p(39 downto 8)  := s;
        p(71 downto 40) := d;
        p(79 downto 72) := "0000" & wstrb;
        for ii in 0 to 9 loop
            p(87 downto 80) := std_logic_vector(
                unsigned(p(87 downto 80)) + unsigned(p(8 * ii + 7 downto 8 * ii))
            );
        end loop;
        return p;
    end function;
begin
    
    CreateClock(clk=>clk_i, period=>10 ns);

    eDut : entity ostrngs.TrngController
    generic map (
        cClockFrequency_Hz => 100e6,
        cUartBaudRate_bps  => 12e6
    ) port map (
        i_clk    => clk_i,
        i_resetn => resetn_i,

        o_uart_tx => uart_tx_o,
        i_uart_rx => uart_rx_i,

        m_axi_awaddr  => m_axi_awaddr,
        m_axi_awprot  => m_axi_awprot,
        m_axi_awvalid => m_axi_awvalid,
        m_axi_awready => m_axi_awready,

        m_axi_wdata   => m_axi_wdata,
        m_axi_wstrb   => m_axi_wstrb,
        m_axi_wvalid  => m_axi_wvalid,
        m_axi_wready  => m_axi_wready,

        m_axi_bresp   => m_axi_bresp, 
        m_axi_bvalid  => m_axi_bvalid, 
        m_axi_bready  => m_axi_bready, 

        m_axi_araddr  => m_axi_araddr,
        m_axi_arprot  => m_axi_arprot,
        m_axi_arvalid => m_axi_arvalid,
        m_axi_arready => m_axi_arready,

        m_axi_rdata   => m_axi_rdata,
        m_axi_rresp   => m_axi_rresp,
        m_axi_rvalid  => m_axi_rvalid,
        m_axi_rready  => m_axi_rready
    );

    Stimuli: process
        variable packet : std_logic_vector(87 downto 0) := (others => '0');
        variable data_v : std_logic_vector(7 downto 0) := (others => '0');
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("t_uart_if") then
                wait until rising_edge(clk_i);
                wait for 100 ps;
                resetn_i <= '1';
                wait until rising_edge(clk_i);
                wait for 100 ps;

                packet := get_address(x"AA55AA55");

                for ii in 0 to 10 loop
                    data_v := packet(8 * ii + 7 downto 8 * ii);
                    report to_hstring(data_v);

                    uart_transmit(
                        i_clk  => clk_i,
                        i_data => data_v,
                        o_tx   => uart_rx_i,
    
                        clockfrequency_Hz => 100e6,
                        baudrate_bps      => 12e6
                    );
                end loop;

                for ii in 0 to 4 loop
                    uart_receive(
                        i_clk  => clk_i,
                        i_rx   => uart_tx_o,
                        o_data => data_v,
    
                        clockfrequency_Hz => 100e6,
                        baudrate_bps      => 12e6
                    );

                    report to_hstring(data_v);
                end loop;

                packet := set_address(x"AA55AA55", x"55AA55AA", "1111");

                for ii in 0 to 10 loop
                    data_v := packet(8 * ii + 7 downto 8 * ii);
                    report to_hstring(data_v);

                    uart_transmit(
                        i_clk  => clk_i,
                        i_data => data_v,
                        o_tx   => uart_rx_i,
    
                        clockfrequency_Hz => 100e6,
                        baudrate_bps      => 12e6
                    );
                end loop;

                uart_receive(
                    i_clk  => clk_i,
                    i_rx   => uart_tx_o,
                    o_data => data_v,

                    clockfrequency_Hz => 100e6,
                    baudrate_bps      => 12e6
                );

                report to_hstring(data_v);

                packet := get_address(x"AA55AA55");

                for ii in 0 to 10 loop
                    data_v := packet(8 * ii + 7 downto 8 * ii);
                    report to_hstring(data_v);

                    uart_transmit(
                        i_clk  => clk_i,
                        i_data => data_v,
                        o_tx   => uart_rx_i,
    
                        clockfrequency_Hz => 100e6,
                        baudrate_bps      => 12e6
                    );
                end loop;

                for ii in 0 to 4 loop
                    uart_receive(
                        i_clk  => clk_i,
                        i_rx   => uart_tx_o,
                        o_data => data_v,
    
                        clockfrequency_Hz => 100e6,
                        baudrate_bps      => 12e6
                    );

                    report to_hstring(data_v);
                end loop;
            end if;
        end loop;
        test_runner_cleanup(runner);
    end process Stimuli;

    eRam : entity tb_ostrngs.RandomAxiRam
    generic map (
        cAddressWidth_b     => 32,
        cCachelineSize_B    => 4,
        cCheckUninitialized => false,
        cVerboseMode        => false
    ) port map (
        i_clk    => clk_i,
        i_resetn => resetn_i,

        i_s_axi_awaddr  => m_axi_awaddr,
        i_s_axi_awprot  => m_axi_awprot,
        i_s_axi_awvalid => m_axi_awvalid,
        o_s_axi_awready => m_axi_awready,

        i_s_axi_wdata   => m_axi_wdata,
        i_s_axi_wstrb   => m_axi_wstrb,
        i_s_axi_wvalid  => m_axi_wvalid,
        o_s_axi_wready  => m_axi_wready,

        o_s_axi_bresp   => m_axi_bresp,
        o_s_axi_bvalid  => m_axi_bvalid,
        i_s_axi_bready  => m_axi_bready,

        i_s_axi_araddr  => m_axi_araddr,
        i_s_axi_arprot  => m_axi_arprot,
        i_s_axi_arvalid => m_axi_arvalid,
        o_s_axi_arready => m_axi_arready,

        o_s_axi_rdata   => m_axi_rdata,
        o_s_axi_rresp   => m_axi_rresp,
        o_s_axi_rvalid  => m_axi_rvalid,
        i_s_axi_rready  => m_axi_rready
    );
    
end architecture tb;