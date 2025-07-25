library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.utilities.all;

entity tb_transmitter_fifo is
end tb_transmitter_fifo;

architecture Behavioral of tb_transmitter_fifo is

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal data_in    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal en_write   : std_logic := '0';
  signal tick       : std_logic := '0';
  signal tx         : std_logic;
  signal fifo_empty : std_logic;
  signal fifo_full  : std_logic;

  signal tick_counter : integer := 0;
  constant CLK_PERIOD : time := 10 ns;

  type data_array is array(0 to 2) of std_logic_vector(DATA_WIDTH-1 downto 0);
  constant test_data : data_array := (X"A5", X"3C", X"7E");

  -- ✅ Procedimiento que espera una cantidad de ticks reales
  procedure wait_ticks(n: natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(tick);
    end loop;
  end procedure;

begin

  -- Instancia del módulo transmitter_fifo
  uut: entity work.transmitter_fifo
    port map (
      clk        => clk,
      rst        => rst,
      data_in    => data_in,
      en_write   => en_write,
      tick       => tick,
      tx         => tx,
      fifo_empty => fifo_empty,
      fifo_full  => fifo_full
    );

  -- Clock principal
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

  -- Generador de tick UART
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

  -- Estímulo
  stim_proc: process
  begin
    -- RESET
    rst <= '1';
    wait_ticks(5);
    rst <= '0';
    wait_ticks(10);

    -- Escribir 3 datos al FIFO
    for i in 0 to 2 loop
      data_in  <= test_data(i);
      en_write <= '1';
      wait for clk_period;
      en_write <= '0';
      wait for clk_period;
    end loop;

    -- Esperar transmisiones completas
    wait_ticks(100);
    wait;
  end process;

end Behavioral;
