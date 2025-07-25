library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity UART_test_sender is
    Port (
        clk : in  std_logic;
        rst : in  std_logic;
        tx  : out std_logic;
        rx  : in  std_logic
    );
end UART_test_sender;

architecture Behavioral of UART_test_sender is

    constant FINAL_VAL : std_logic_vector(BITS_DIVISOR-1 downto 0) := std_logic_vector(to_unsigned(202, BITS_DIVISOR));
    signal en_tx_write : std_logic := '0';
    signal tx_data_in  : std_logic_vector(DATA_WIDTH-1 downto 0) := x"55";

    -- Señales dummy
    signal dummy_rx       : std_logic := '1';
    signal dummy_read     : std_logic := '0';
    signal dummy_flags    : std_logic_vector(3 downto 0);
    signal dummy_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    -- Pulsos simples de escritura alternados
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                en_tx_write <= '0';
            else
                en_tx_write <= not en_tx_write;
            end if;
        end if;
    end process;

    -- Instancia del UART
    uart_tx_inst: entity work.UART
        port map (
            clk         => clk,
            rst         => rst,
            finalValue  => FINAL_VAL,
            en_tx_write => en_tx_write,
            en_rx_read  => dummy_read,
            tx_data_in  => tx_data_in,
            tx          => tx,
            rx          => rx,
            rx_data_out => dummy_data_out,
            FLAGS       => dummy_flags
        );

end Behavioral;
