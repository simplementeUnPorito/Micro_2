library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.utilities.all;

entity tb_Reciever is
end tb_Reciever;

architecture Behavioral of tb_Reciever is
  signal clk     : std_logic := '0';
  signal rst     : std_logic := '1';
  signal input   : std_logic := '1';
  signal tick    : std_logic := '0';
  signal output  : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal done    : std_logic;

  signal tick_counter : integer := 0;

  constant CLK_PERIOD : time := 10 ns;

  -- ✅ Procedimiento que espera una cantidad de ticks reales
  procedure wait_ticks(n: natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(tick);
    end loop;
  end procedure;

  -- ✅ Procedimiento que encapsula la lógica UART (igual que antes)
  procedure send_uart_byte(
    signal uart_in : out std_logic;
    b : std_logic_vector(DATA_WIDTH - 1 downto 0)
  ) is
  begin
    -- START BIT
    uart_in <= '0';
    wait_ticks(TICKS_PER_DATA);

    -- DATA BITS (LSB first)
    for i in 0 to DATA_WIDTH - 1 loop
      uart_in <= b(i);
      wait_ticks(TICKS_PER_DATA);
    end loop;

    -- STOP BIT
    uart_in <= '1';
    wait_ticks(TICKS_PER_DATA);
  end procedure;

begin

  -- Instancia del receptor
  uut: entity work.Reciever
    port map (
      clk    => clk,
      rst    => rst,
      input  => input,
      tick   => tick,
      output => output,
      done   => done
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

  -- Tick generator
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

  -- Estímulo UART con varios mensajes
  stim_proc: process
  begin
    -- RESET
    input <= '1';
    rst <= '1';
    wait_ticks(5 * TICKS_PER_DATA);
    rst <= '0';
    wait for clk_Period*1.798;
    -- Enviar múltiples mensajes UART
    send_uart_byte(input, X"AB");
    wait for clk_Period*3.231;
    send_uart_byte(input, X"C8");
    wait for clk_Period*13.231;
    send_uart_byte(input, X"01");
    wait for clk_Period*514.1;
    send_uart_byte(input, X"F0");
    wait for clk_Period*421.1;
    send_uart_byte(input, X"55");
    wait for clk_Period*1.231;
    send_uart_byte(input, X"AA");
    wait for clk_Period*134.5;
    send_uart_byte(input, X"0F");
    wait for clk_Period*341.1;
    send_uart_byte(input, X"3C");
    wait for clk_Period*3.1415;
    send_uart_byte(input, X"81");
    wait for clk_Period*41.1;
    send_uart_byte(input, X"7E");

    wait_ticks(10 * TICKS_PER_DATA);
    wait;
  end process;

end Behavioral;
