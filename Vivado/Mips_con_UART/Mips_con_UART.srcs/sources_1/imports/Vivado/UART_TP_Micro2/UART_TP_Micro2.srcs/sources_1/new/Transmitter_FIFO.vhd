library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity transmitter_fifo is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        data_in     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        en_write    : in  std_logic;
        tick        : in  std_logic;
        tx          : out std_logic;
        fifo_empty  : out std_logic;
        fifo_full   : out std_logic;
        state_out   : inout state_t
    );
end transmitter_fifo;

architecture Behavioral of transmitter_fifo is

    type state_type is (IDLE, LOAD, SEND);
    signal state, next_state : state_type := IDLE;

    signal fifo_out       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_read      : std_logic := '0';
    signal tx_done        : std_logic;
    signal tx_start       : std_logic := '0';
    signal fifo_is_empty  : std_logic;

begin

    FIFO_TX: entity work.FIFO
        port map (
            clk    => clk,
            rst    => rst,
            input  => data_in,
            output => fifo_out,
            write  => en_write,
            read   => fifo_read,
            empty  => fifo_is_empty,
            full   => fifo_full
        );

    UTX: entity work.Transmitter
        port map (
            input   => fifo_out,  -- directamente desde el FIFO
            output  => tx,
            clk     => clk,
            rst     => rst,
            start_t => tx_start,
            tick    => tick,
            done    => tx_done,
            state   => state_out
        );

    process(state, fifo_is_empty, tx_done)
    begin
        -- Defaults
        fifo_read  <= '0';
        tx_start   <= '0';
        next_state <= state;

        case state is
            when IDLE =>
                if fifo_is_empty = '0' then
                    fifo_read  <= '1';
                    next_state <= LOAD;
                end if;
            when LOAD =>
                tx_start   <= '1';
                next_state <= SEND;

            when SEND =>
                if tx_done = '1' then
                    if fifo_is_empty = '0' then
                        fifo_read  <= '1';
                        next_state <= LOAD;
                    else
                        next_state <= IDLE;
                    end if;
                end if;
        end case;
    end process;

    -- Registrar estado
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    fifo_empty <= fifo_is_empty;

end Behavioral;