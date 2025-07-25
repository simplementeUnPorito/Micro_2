library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity tb_reciever_fifo is
end tb_reciever_fifo;

architecture Behavioral of tb_reciever_fifo is

  signal clk          : std_logic := '0';
  signal rst          : std_logic := '1';
  signal rx           : std_logic := '1';
  signal tick         : std_logic := '0';
  signal data_out     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal fifo_empty   : std_logic;
  signal fifo_full    : std_logic;
  signal en_data_out  : std_logic := '0';
  signal state        : state_r;
  signal tick_counter : integer := 0;

  constant CLK_PERIOD : time := 10 ns;

  procedure wait_ticks(n: natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(tick);
    end loop;
  end procedure;

  procedure send_uart_byte(
    signal uart_in : out std_logic;
    b : std_logic_vector(DATA_WIDTH - 1 downto 0)
  ) is
  begin
    uart_in <= '0'; -- START
    wait_ticks(TICKS_PER_DATA);
    for i in 0 to DATA_WIDTH - 1 loop
      uart_in <= b(i);
      wait_ticks(TICKS_PER_DATA);
    end loop;
    uart_in <= '1'; -- STOP
    wait_ticks(TICKS_PER_DATA);
  end procedure;

begin

  -- Instancia del módulo reciever_fifo
  uut: entity work.reciever_fifo
    port map (
      clk          => clk,
      rst          => rst,
      rx           => rx,
      tick         => tick,
      data_out     => data_out,
      fifo_empty   => fifo_empty,
      fifo_full    => fifo_full,
      en_data_out  => en_data_out,
      state        => state
    );

  -- Clock
  clk_process: process
  begin
    while now < 10 ms loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
    wait;
  end process;

  -- Baud tick (16x oversampling)
  tick_process: process
  begin
    while now < 10 ms loop
      wait for CLK_PERIOD;
      if tick_counter = 0 then
        tick <= '1';
      else
        tick <= '0';
      end if;
      tick_counter <= (tick_counter + 1) mod TICKS_PER_DATA;
    end loop;
    wait;
  end process;

  stim_proc: process
  begin
    rst <= '1';
    rx <= '1';
    wait_ticks(5);
    rst <= '0';

    -- Enviar datos UART
    send_uart_byte(rx, x"5A");
    wait_ticks(20);

    send_uart_byte(rx, x"F0");
    wait_ticks(30);

    -- Leer si hay datos
    wait until fifo_empty = '0';
    en_data_out <= '1';
    wait for CLK_PERIOD;
    en_data_out <= '0';
    wait for CLK_PERIOD;
    report "Dato leído: " & integer'image(to_integer(unsigned(data_out)));

    wait until fifo_empty = '0';
    en_data_out <= '1';
    wait for CLK_PERIOD;
    en_data_out <= '0';
    wait for CLK_PERIOD;
    report "Dato leído: " & integer'image(to_integer(unsigned(data_out)));

    wait;

  end process;

end Behavioral;
