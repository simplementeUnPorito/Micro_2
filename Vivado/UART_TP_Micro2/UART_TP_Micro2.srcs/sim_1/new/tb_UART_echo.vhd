library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity tb_UART_led is
end tb_UART_led;

architecture Behavioral of tb_UART_led is

  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal rx    : std_logic := '1';
  signal leds  : std_logic_vector(3 downto 0);

  constant CLK_PERIOD : time := 8 ns;
  constant BAUD_RATE  : integer := 9600;
  constant BIT_TIME   : time := 1 sec / BAUD_RATE;

  procedure send_uart_byte(
    signal uart_in : out std_logic;
    b : std_logic_vector(DATA_WIDTH - 1 downto 0)
  ) is
  begin
    uart_in <= '0';  -- START
    wait for BIT_TIME;

    for i in 0 to DATA_WIDTH - 1 loop
      uart_in <= b(i);
      wait for BIT_TIME;
    end loop;

    uart_in <= '1';  -- STOP
    wait for BIT_TIME;
  end procedure;

begin

  -- DUT instanciado
  uut: entity work.UART_led
    port map (
      clk  => clk,
      rst  => rst,
      rx   => rx,
      leds => leds
    );

  -- Clock a 100 MHz
  clk_process : process
  begin
    while now < 10 ms loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
    wait;
  end process;

  -- Estímulo
  stim_proc : process
  begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';

    wait for 2 ms;

    -- Enviar 0x5A = 01011010 → leds = "1010"
    send_uart_byte(rx, x"5A");
    wait for 2 ms;

    -- Enviar 0x0F = 00001111 → leds = "1111"
    send_uart_byte(rx, x"0F");
    wait for 2 ms;

    -- Enviar 0x3C = 00111100 → leds = "1100"
    send_uart_byte(rx, x"3C");
    wait for 2 ms;

    wait;
  end process;

end Behavioral;
