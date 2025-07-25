library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity reciever_fifo is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        rx         : in  std_logic;
        tick       : in  std_logic;
        data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        fifo_empty : out std_logic;
        fifo_full  : out std_logic;
        en_data_out: in std_logic;
        state      : inout state_r
    );
end reciever_fifo;

architecture Behavioral of reciever_fifo is

    signal rx_data   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rx_done   : std_logic;
    signal fifo_wr   : std_logic;
    signal fifo_out  : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

    -- Instancia del receptor UART
    URX: entity work.Reciever
        port map (
            clk    => clk,
            rst    => rst,
            input  => rx,
            tick   => tick,
            output => rx_data,
            done   => rx_done,
            state  => state
        );

    -- Instancia del FIFO
    FIFO_RX: entity work.FIFO
        port map (
            clk    => clk,
            rst    => rst,
            input  => rx_data,
            output => data_out,
            write  => fifo_wr,
            read   => en_data_out,
            empty  => fifo_empty,
            full   => fifo_full
            
        );

    -- El receptor escribe al FIFO cuando done = '1'
    fifo_wr <= rx_done;

end Behavioral;
