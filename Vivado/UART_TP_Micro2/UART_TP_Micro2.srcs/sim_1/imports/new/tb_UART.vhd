library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity tb_uart is
end tb_uart;

architecture sim of tb_uart is

  signal clk         : std_logic := '0';
  signal rst         : std_logic := '1';
  signal finalValue  : std_logic_vector(BITS_DIVISOR-1 downto 0);
  signal en_tx_write : std_logic := '0';
  signal en_rx_read  : std_logic := '0';
  signal tx_data_in  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal tx          : std_logic;
  signal rx          : std_logic;
  signal rx_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal FLAGS       : std_logic_vector(DATA_WIDTH-1 downto 0);

  constant CLK_PERIOD : time := 8 ns;
  type data_array is array(0 to 15) of std_logic_vector(DATA_WIDTH-1 downto 0);
  constant test_data : data_array := (
    X"00", X"11", X"22", X"33", X"44", X"55", X"66", X"77",
    X"88", X"99", X"AA", X"BB", X"CC", X"DD", X"EE", X"FF"
  );

  procedure wait_cycles(n : integer) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

begin

  -- DUT
  uut: entity work.UART
    port map (
      clk         => clk,
      rst         => rst,
      finalValue  => finalValue,
      en_tx_write => en_tx_write,
      en_rx_read  => en_rx_read,
      tx_data_in  => tx_data_in,
      tx          => tx,
      rx          => rx,
      rx_data_out => rx_data_out,
      FLAGS       => FLAGS
    );

  -- Cortocircuito TX a RX
  rx <= tx;

  -- Clock generation
  clk_process : process
  begin
    while now < 100 ms loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
    wait;
  end process;

  stim_proc: process
  begin
    -- Inicialización
    rst <= '1';
    finalValue <= std_logic_vector(to_unsigned(50, BITS_DIVISOR));
    wait_cycles(10);
    rst <= '0';
    wait_cycles(20);

    ---------------------------------------
    -- Enviar los primeros 11 bytes (hasta AA)
    ---------------------------------------
    for i in 0 to 7 loop
      tx_data_in <= test_data(i);
      en_tx_write <= '1';
      wait_cycles(1);
      en_tx_write <= '0';
      wait_cycles(2);
    end loop;

    wait_cycles(100);  -- Espera para vaciar parcialmente

    ---------------------------------------
    -- Leer 3 valores del FIFO
    ---------------------------------------
    for i in 0 to 2 loop
      if FLAGS(0) = '0' then -- FIFO no vacío
        en_rx_read <= '1';
        wait_cycles(1);
        en_rx_read <= '0';
        wait_cycles(1);
        report "Dato leído (etapa 1): " & integer'image(to_integer(unsigned(rx_data_out)));
      end if;
      wait_cycles(20);
    end loop;

    wait for 150 us; -- Deja que FIFO se actualice

    ---------------------------------------
    -- Enviar los últimos 5 bytes (BB hasta FF)
    ---------------------------------------
    for i in 8 to 10 loop
      tx_data_in <= test_data(i);
      en_tx_write <= '1';
      wait_cycles(1);
      en_tx_write <= '0';
      wait_cycles(160);
    end loop;

    wait_cycles(100);
    
    ---------------------------------------
    -- Leer 3 valores del FIFO
    ---------------------------------------
    for i in 0 to 2 loop
      if FLAGS(0) = '0' then -- FIFO no vacío
        en_rx_read <= '1';
        wait_cycles(1);
        en_rx_read <= '0';
        wait_cycles(1);
        report "Dato leído (etapa 1): " & integer'image(to_integer(unsigned(rx_data_out)));
      end if;
      wait_cycles(20);
    end loop;
    
    wait;

  end process;

end sim;
