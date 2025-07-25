library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity UART_led is
    Port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        rx    : in  std_logic;
        leds  : out std_logic_vector(3 downto 0)
    );
end UART_led;

architecture Behavioral of UART_led is

    -- Señal del generador de tick
    signal tick          : std_logic;
    constant FINAL_VALUE : std_logic_vector(BITS_DIVISOR-1 downto 0) :=
        std_logic_vector(to_unsigned(50, BITS_DIVISOR));  -- para 9600 baudios a 125MHz

    -- UART receiver internals
    signal data_out     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_empty   : std_logic;
    signal fifo_full    : std_logic;
    signal en_data_out  : std_logic := '0';
    signal state_uart   : state_r;
    signal latch_data   : std_logic_vector(3 downto 0) := (others => '0');
    signal read_pending : std_logic := '0';
    
    
     type fsm_state is (RESET, WAIT_1_CYCLE, ENABLE_TICK, DISABLE_TICK);
    signal state : fsm_state := RESET;

    signal enableUpdate : std_logic := '0';
    
    type state_led is (IDLE,WAITING, CATCHING);
    signal state_LD:state_led :=IDLE;

begin

    -- Generador de ticks
    TickGen: entity work.frecDivisor
        generic map (m => BITS_DIVISOR)
        port map (
            clk          => clk,
            reset        => rst,
            finalValue   => FINAL_VALUE,
            enableUpdate => enableUpdate,
            output       => tick
        );

    -- UART Receiver con FIFO
    uart_rx: entity work.reciever_fifo
        port map (
            clk          => clk,
            rst          => rst,
            rx           => rx,
            tick         => tick,
            data_out     => data_out,
            fifo_empty   => fifo_empty,
            fifo_full    => fifo_full,
            en_data_out  => en_data_out,
            state        => state_uart
        );

  process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            state_ld<=IDLE;
        else
            case state_ld is
                when IDLE =>
                    if fifo_empty = '0' then
                        state_ld<=waiting;
                    end if;
                when waiting =>
                    if tick = '1' then
                        state_ld<=CATCHING;
                    end if;
                when catching =>
                    en_data_out<='1';
                    latch_data <=data_out(3 downto 0);
               end case;  
        end if;
    end if;
end process;


    -- LED output
    leds <= latch_data;



    -- FSM para controlar enableUpdate
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state        <= RESET;
                enableUpdate <= '0';
            else
                case state is
                    when RESET =>
                        state <= WAIT_1_CYCLE;

                    when WAIT_1_CYCLE =>
                        state        <= ENABLE_TICK;

                    when ENABLE_TICK =>
                        enableUpdate <= '1';
                        state        <= DISABLE_TICK;

                    when DISABLE_TICK =>
                        enableUpdate <= '0';
                        -- se mantiene en DISABLE_TICK

                    when others =>
                        state <= RESET;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
