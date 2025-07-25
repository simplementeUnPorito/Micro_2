library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity tb_FIFO is
end tb_FIFO;

architecture sim of tb_FIFO is

    -- Constantes de prueba
    constant CLK_PERIOD   : time := 10 ns;

    -- Component declaration
    component FIFO
        Port ( 
            clk     : in STD_LOGIC;
            rst     : in STD_LOGIC;
            input   : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            output  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            write   : in STD_LOGIC;
            read    : in STD_LOGIC;
            empty   : out STD_LOGIC;
            full    : out STD_LOGIC
        );
    end component;

    -- Señales internas
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal input   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal output  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal write   : std_logic := '0';
    signal read    : std_logic := '0';
    signal empty   : std_logic;
    signal full    : std_logic;

    -- Test data
    type data_array is array (0 to 7) of std_logic_vector(DATA_WIDTH-1 downto 0);
    constant test_data : data_array := (
        x"11", x"22", x"33", x"44", x"55", x"66", x"77", x"88"
    );

begin

    -- Instancia del FIFO
    uut: FIFO
        port map (
            clk     => clk,
            rst     => rst,
            input   => input,
            output  => output,
            write   => write,
            read    => read,
            empty   => empty,
            full    => full
        );

    -- Clock generator
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Estímulo de prueba
    stim_proc: process
    begin
        -- Reset inicial
        wait for 20 ns;
        rst <= '0';
        wait for CLK_PERIOD;

        -- Escribir los primeros 4 datos (hasta que se llene)
        for i in 0 to 3 loop
            input <= test_data(i);
            write <= '1';
            wait for CLK_PERIOD;
        end loop;

        write <= '0';
        wait for CLK_PERIOD;

        -- Leer los 4 datos
        for i in 0 to 4 loop
            read <= '1';
            wait for CLK_PERIOD;
        end loop;
        read <= '0';
        wait for CLK_PERIOD;
        --leer 3 datos
        for i in 0 to 7 loop
            input <= test_data(i);
            write <= '1';
            wait for CLK_PERIOD;
        end loop;
        write <= '0';
        wait for CLK_PERIOD;
        
        for i in 0 to 4 loop
            read <= '1';
            wait for CLK_PERIOD;
        end loop;
        read <= '0';
        wait for CLK_PERIOD;
        
        for i in 0 to 7 loop
            input <= test_data(i);
            write <= '1';
            wait for CLK_PERIOD;
        end loop;
        
        write <= '0';
        wait for CLK_PERIOD;

        
        wait;

    end process;

end sim;
