library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.utilities.all;

entity tb_Transmitter is
end tb_Transmitter;

architecture Behavioral of tb_Transmitter is

  signal clk     : std_logic := '0';
  signal rst     : std_logic := '1';
  signal start   : std_logic := '0';
  signal input   : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal output  : std_logic;
  signal tick    : std_logic := '0';
  signal done    : std_logic;

  signal tick_counter : integer := 0;

  constant CLK_PERIOD : time := 10 ns;

  -- ✅ Procedimiento para esperar una cantidad de ticks reales
  procedure wait_ticks(n: natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(tick);
    end loop;
  end procedure;

  -- ✅ Procedimiento que inicia la transmisión
  procedure transmit_byte(
    signal data_input : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal start_sig  : out std_logic;
    b : std_logic_vector(DATA_WIDTH - 1 downto 0)
  ) is
  begin
    data_input <= b;
    start_sig  <= '1';
    wait until rising_edge(clk);
    start_sig  <= '0';
  end procedure;

begin

  -- Instancia del transmisor
  uut: entity work.Transmitter
    port map (
      input  => input,
      output => output,
      clk    => clk,
      rst    => rst,
      start_t  => start,
      tick   => tick,
      done   => done
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

  -- Estímulo principal
  stim_proc: process
  begin
    -- Reset
    rst <= '1';
    wait_ticks(5);
    rst <= '0';

    -- Transmitir múltiples bytes
    transmit_byte(input, start, X"AB");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"C8");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"01");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"F0");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"55");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"AA");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"0F");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"3C");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"81");
    wait until done = '1';
    wait_ticks(2);

    transmit_byte(input, start, X"7E");
    wait until done = '1';
    wait_ticks(10);

    wait;
  end process;

end Behavioral;
