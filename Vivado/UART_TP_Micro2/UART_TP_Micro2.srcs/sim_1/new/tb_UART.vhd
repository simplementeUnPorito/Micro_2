library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity tb_UART_Top is
end tb_UART_Top;

architecture sim of tb_UART_Top is

    -- Señales del DUT
    signal clk                : std_logic := '0';
    signal rst                : std_logic := '1';
    signal Rx                 : std_logic := '1';
    signal Data_Transmit      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal En_Transmit        : std_logic := '0';
    signal Baud_Selector      : std_logic_vector(5 downto 0) := (others => '0');

    signal Tx                 : std_logic;
    signal Data_Receive       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal En_Receive         : std_logic;
    signal FIFO_Receive_Empty : std_logic;
    signal FIFO_Receive_Full  : std_logic;

    constant CLK_PERIOD : time := 10 ns;
    type mem_array is array(0 to 2) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sent_data : mem_array := (X"05", X"15", X"25");

    -- Contador de ticks simulados
    signal tick_counter : integer := 0;

    procedure wait_ticks(n: natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

begin

    --------------------------------
    -- Instancia del DUT (UART_Top)
    --------------------------------
    uut: entity work.UART_Top
        port map (
            clk                => clk,
            rst                => rst,
            Rx                 => Rx,
            Data_Transmit      => Data_Transmit,
            En_Transmit        => En_Transmit,
            Baud_Selector      => Baud_Selector,
            Tx                 => Tx,
            Data_Receive       => Data_Receive,
            En_Receive         => En_Receive,
            FIFO_Receive_Empty => FIFO_Receive_Empty,
            FIFO_Receive_Full  => FIFO_Receive_Full
        );

    -- Cortocircuito Tx a Rx
    Rx <= Tx;

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

    -- Estímulo
    stim_proc: process
    begin
        -- Reset inicial
        rst <= '1';
        wait_ticks(10);
        rst <= '0';

        -- Configurar BaudRate (por ejemplo, 10)
        Baud_Selector <= std_logic_vector(to_unsigned(10, 6));
        wait_ticks(10);

        -- Cargar 3 datos al FIFO del transmisor
        for i in 0 to 2 loop
            Data_Transmit <= sent_data(i);
            En_Transmit <= '1';
            wait_ticks(1);
            En_Transmit <= '0';
            wait_ticks(10);
        end loop;

        -- Esperar suficiente tiempo para que se transmitan y reciban los 3 datos
        wait for 3 ms;

        -- Verificar que se recibieron los mismos datos
        for i in 0 to 2 loop
            if FIFO_Receive_Empty = '0' then
                assert Data_Receive = sent_data(i)
                report "Dato recibido OK: " & integer'image(to_integer(unsigned(Data_Receive)))
                severity note;
            else
                report "ERROR: FIFO vacío al intentar leer el dato " & integer'image(i)
                severity error;
            end if;
            wait_ticks(2);
        end loop;

        wait;
    end process;

end sim;