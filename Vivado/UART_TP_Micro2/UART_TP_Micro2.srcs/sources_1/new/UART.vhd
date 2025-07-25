library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity UART is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        finalValue  : in  std_logic_vector(BITS_DIVISOR-1 downto 0);
        en_tx_write : in  std_logic;
        en_rx_read  : in  std_logic;
        tx_data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        tx          : out std_logic;
        rx          : in  std_logic;
        rx_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        FLAGS       : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end UART;

architecture Behavioral of UART is

    -- Señales internas
    signal tick            : std_logic;
    signal tx_empty_i      : std_logic;
    signal tx_full_i       : std_logic;
    signal rx_empty_i      : std_logic;
    signal rx_full_i       : std_logic;
    signal en_tx_write_reg : std_logic;
    signal FLAGS_reg       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal enableUpdate    : std_logic;
    signal state_Tr        : state_t;
    signal state_Re        : state_r;

begin

    -- Tick Generator
    TickGen: entity work.frecDivisor
        generic map (m => BITS_DIVISOR)
        port map (
            clk          => clk,
            reset        => rst,
            finalValue   => finalValue,
            enableUpdate => enableUpdate,
            output       => tick
        );

    -- Transmitter
    TX_Block: entity work.transmitter_fifo
        port map (
            clk        => clk,
            rst        => rst,
            data_in    => tx_data_in,
            en_write   => en_tx_write_reg,
            tick       => tick,
            tx         => tx,
            fifo_empty => tx_empty_i,
            fifo_full  => tx_full_i,
            state_out  => state_Tr
        );

    -- Receiver
    RX_Block: entity work.reciever_fifo
        port map (
            clk        => clk,
            rst        => rst,
            rx         => rx,
            tick       => tick,
            data_out   => rx_data_out,
            fifo_empty => rx_empty_i,
            en_data_out => en_rx_read,
            fifo_full  => rx_full_i,
            state      => state_Re
        );

    -- Flags y registros
    process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    FLAGS_reg        <= (others => '0');
                    en_tx_write_reg  <= '0';
                else
                    FLAGS_reg(0)     <= rx_empty_i;
                    FLAGS_reg(1)     <= rx_full_i;
                    FLAGS_reg(2)     <= tx_empty_i;
                    FLAGS_reg(3)     <= tx_full_i;
                    FLAGS_reg(5 downto 4) <= std_logic_vector(to_unsigned(state_r'pos(state_Re), 2));
                    FLAGS_reg(7 downto 6) <= std_logic_vector(to_unsigned(state_t'pos(state_Tr), 2));
                    en_tx_write_reg  <= en_tx_write;
                end if;
            end if;
        end process;


    -- Salidas
    enableUpdate <= '1' when (state_Tr = IDLE and state_Re = IDLE) else '0';
    FLAGS        <= FLAGS_reg;

end Behavioral;
