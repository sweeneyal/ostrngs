library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

library ostrngs;

entity TrngControllerCore is
    generic (
        cClockFrequency_Hz : positive;
        cUartBaudRate_bps  : positive := 115200
    );
    port (
        -- system clock
        i_clk    : in std_logic;
        -- active low reset synchronous to the system clock
        i_resetn : in std_logic;

        -- uart interface
        o_uart_tx : out std_logic;
        i_uart_rx : out std_logic;

        ----------------------------------------------------------------------
        -- Master AXI Lite Interface
        ----------------------------------------------------------------------
        -- master axi write address channel
        o_m_axi_awaddr  : out std_logic_vector(31 downto 0);
        -- master axi write address protection level
        o_m_axi_awprot  : out std_logic_vector(2 downto 0);
        -- master axi write address bus valid signal
        o_m_axi_awvalid : out std_logic;
        -- master axi write address bus ready-to-accept signal
        i_m_axi_awready : in std_logic;

        -- master axi write data channel
        o_m_axi_wdata   : out std_logic_vector(31 downto 0);
        -- master axi write strobe channel (indicates valid bytes in word)
        o_m_axi_wstrb   : out std_logic_vector(3 downto 0);
        -- master axi write bus valid signal
        o_m_axi_wvalid  : out std_logic;
        -- master axi write ready-to-accept signal
        i_m_axi_wready  : in std_logic;

        -- master axi write response indicator
        i_m_axi_bresp   : in std_logic_vector(1 downto 0);
        -- master axi write response valid signal
        i_m_axi_bvalid  : in std_logic;
        -- master axi write response ready-to-accept signal
        o_m_axi_bready  : out std_logic;

        -- master axi read address channel
        o_m_axi_araddr  : out std_logic_vector(31 downto 0);
        -- master axi read address protection level
        o_m_axi_arprot  : out std_logic_vector(2 downto 0);
        -- master axi read address valid signal
        o_m_axi_arvalid : out std_logic;
        -- master axi read address ready-to-accept signal
        i_m_axi_arready : in std_logic;

        -- master axi read data channel
        i_m_axi_rdata   : in std_logic_vector(31 downto 0);
        -- master axi read response indicator
        i_m_axi_rresp   : in std_logic_vector(1 downto 0);
        -- master axi read valid signal
        i_m_axi_rvalid  : in std_logic;
        -- master axi read ready signal
        o_m_axi_rready  : out std_logic
    );
end entity TrngControllerCore;

architecture rtl of TrngControllerCore is
    constant cPacketSize_B : natural := 10;
    constant cWordSize_B   : natural := 4;
    constant cGetHeader    : std_logic_vector(7 downto 0) := x"0A";
    constant cSetHeader    : std_logic_vector(7 downto 0) := x"A0";
    constant cError        : std_logic_vector(7 downto 0) := x"FF";
    signal rx_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_valid : std_logic := '0';

    signal tx_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_valid : std_logic := '0';
    signal tx_ready : std_logic := '0';
    signal idx      : natural := 0;
    signal sum      : unsigned(7 downto 0) := (others => '0');
    signal busy     : std_logic := '0';
    signal packet   : std_logic_vector(79 downto 0) := (others => '0');
    signal bresp    : std_logic_vector(1 downto 0) := (others => '0');

    signal m_axi_awvalid : std_logic := '0';
    signal m_axi_wvalid  : std_logic := '0';
    signal m_axi_bready  : std_logic := '0';
    signal m_axi_arvalid : std_logic := '0';
    signal m_axi_rready  : std_logic := '0';

    signal header  : std_logic_vector(7 downto 0)  := (others => '0');
    signal address : std_logic_vector(31 downto 0) := (others => '0');
    signal data    : std_logic_vector(31 downto 0) := (others => '0');
    signal crc     : std_logic_vector(7 downto 0)  := (others => '0');
    signal rdata   : std_logic_vector(31 downto 0) := (others => '0');

    type state_t is (
        IDLE, RECEIVE_PACKET, PARSE_PACKET, ACK_VALID, ACK_ERROR, 
        GET_ADDRESS, SEND_DATA, STALL, SEND_CRC, 
        SET_ADDRESS, EVALUATE_RESP);

    signal state : state_t := IDLE;
begin

    eRx : entity ostrngs.UartRx
    generic map (
        cClockFrequency_Hz => cClockFrequency_Hz,
        cBaudRate_bps      => cUartBaudRate_bps
    ) port map (
        i_clk   => i_clk,
        i_rx    => i_uart_rx,
        o_byte  => rx_data,
        o_valid => rx_valid
    );

    StateMachine: process(i_clk)
        variable seq : std_logic_vector(2 downto 0) := "000";
    begin
        if rising_edge(i_clk) then
            if (i_resetn = '0') then
                state <= IDLE;
                
                seq           := "000";
                m_axi_awvalid <= '0';
                m_axi_wvalid  <= '0';
                m_axi_bready  <= '0';
                m_axi_arvalid <= '0';
                m_axi_rready  <= '0';

                tx_valid <= '0';
                idx      <= 0;
            else
                case state is
                    when IDLE =>
                        m_axi_awvalid <= '0';
                        m_axi_wvalid  <= '0';
                        m_axi_bready  <= '0';
                        m_axi_arvalid <= '0';
                        m_axi_rready  <= '0';
                        tx_valid      <= '0';

                        if (rx_valid = '1') then
                            packet(7 downto 0) <= rx_data;
                            sum   <= unsigned(rx_data);
                            state <= RECEIVE_PACKET;
                            idx   <= 1;
                        end if;

                    when RECEIVE_PACKET =>
                        if (rx_valid = '1') then
                            packet(8 * idx + 7 downto 8 * idx) <= rx_data;
                            idx <= idx + 1;
                            sum <= sum + unsigned(rx_data);
                            if (idx = cPacketSize_B - 1) then
                                state <= PARSE_PACKET;
                            end if;
                        end if;
                    
                    when PARSE_PACKET =>
                        idx     <= 0;
                        header  <= packet(7 downto 0);
                        address <= packet(39 downto 8);
                        data    <= packet(71 downto 40);
                        crc     <= packet(79 downto 72);
                        state   <= ACK_VALID;
                    
                    when ACK_VALID =>
                        if (unsigned(crc) = sum) then
                            case header is
                                when cGetHeader =>
                                    state <= GET_ADDRESS;
                                when cSetHeader =>
                                    state <= SET_ADDRESS;
                                when others =>
                                    state <= ACK_ERROR;
                            end case;
                        else
                            state <= ACK_ERROR;
                        end if;

                    when ACK_ERROR =>
                        tx_data <= cError;
                        tx_valid <= '1';
                        state <= IDLE;

                    when GET_ADDRESS =>
                        o_m_axi_araddr  <= address;
                        m_axi_arvalid <= '1';
                        if (seq(0) = '1' or (m_axi_arvalid and i_m_axi_arready) = '1') then
                            seq(0) := '1';
                            m_axi_arvalid <= '0';
                        end if;

                        m_axi_rready <= '1';
                        if (seq(1) = '1' or (m_axi_rready and i_m_axi_rvalid) = '1') then
                            seq(1)       := '1';
                            m_axi_rready <= '0';
                            if ((m_axi_rready and i_m_axi_rvalid) = '1') then
                                rdata <= i_m_axi_rdata;
                            end if;
                        end if;

                        if (seq = "011") then
                            seq   := "000";
                            state <= SEND_DATA;
                            sum   <= (others => '0');
                        end if;

                    when SEND_DATA =>
                        if (tx_ready = '1') then
                            tx_data  <= rdata(8 * idx + 7 downto 8 * idx);
                            sum      <= sum + unsigned(rdata(8 * idx + 7 downto 8 * idx));
                            tx_valid <= '1';
                            state <= STALL;
                        end if;

                    when STALL =>
                        tx_valid <= '0';
                        if (idx < cWordSize_B - 1) then
                            idx   <= idx + 1;
                            state <= SEND_DATA;
                        else
                            state <= SEND_CRC;
                            idx   <= 0;
                        end if;

                    when SEND_CRC =>
                        if (tx_ready = '1') then
                            tx_data  <= std_logic_vector(sum);
                            tx_valid <= '1';
                            state <= IDLE;
                        end if;

                    when SET_ADDRESS =>
                        o_m_axi_awaddr  <= address;
                        m_axi_awvalid <= '1';
                        if (seq(0) = '1' or (m_axi_awvalid and i_m_axi_awready) = '1') then
                            seq(0) := '1';
                            m_axi_awvalid <= '0';
                        end if;

                        o_m_axi_wdata <= data;
                        m_axi_wvalid <= '1';
                        if (seq(1) = '1' or (m_axi_wvalid and i_m_axi_wready) = '1') then
                            seq(1) := '1';
                            m_axi_wvalid <= '0';
                        end if;

                        m_axi_bready <= '1';
                        if (seq(2) = '1' or (m_axi_bready and i_m_axi_bvalid) = '1') then
                            seq(2) := '1';
                            bresp  <= i_m_axi_bresp;
                            m_axi_bready <= '0';
                        end if;

                        if (seq = "111") then
                            seq   := "000";
                            state <= EVALUATE_RESP;
                        end if;

                    when EVALUATE_RESP =>
                        if (bresp = "00") then
                            tx_valid <= '1';
                            tx_data  <= cSetHeader;
                        else
                            tx_valid <= '1';
                            tx_data  <= cError;
                        end if;
                        state <= IDLE;
                
                end case;
            end if;
        end if;
    end process StateMachine;

    eTx : entity ostrngs.UartTx
    generic map (
        cClockFrequency_Hz => cClockFrequency_Hz,
        cBaudRate_bps      => cUartBaudRate_bps
    ) port map (
        i_clk    => i_clk,
        i_resetn => i_resetn,
        i_byte   => tx_data,
        i_valid  => tx_valid,
        o_busy   => busy,
        o_tx     => o_uart_tx
    );

    tx_ready <= not busy;
    
end architecture rtl;