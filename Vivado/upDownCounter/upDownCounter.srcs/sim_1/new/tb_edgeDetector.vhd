library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_edgeDetector is
end tb_edgeDetector;

architecture testbench of tb_edgeDetector is
    -- Señales
    signal clk     : STD_LOGIC := '0';
    signal reset   : STD_LOGIC := '0';
    signal enable  : STD_LOGIC := '0';
    signal input   : STD_LOGIC := '0';
    signal output  : STD_LOGIC;

    -- Período del reloj
    constant clk_period : time := 10 ns;

    -- Instancia del módulo bajo prueba
    component edgeDetector
        Port ( clk   : in STD_LOGIC;
               enable: in STD_LOGIC;
               input : in STD_LOGIC;
               output : out STD_LOGIC;
               reset : in STD_LOGIC);
    end component;

begin
    -- Instancia del detector de flancos
    DUT: edgeDetector 
        port map (
            clk    => clk,
            reset  => reset,
            enable => enable,
            input  => input,
            output => output
        );

    -- Generación del reloj
    process
    begin
        while now < 800 ns loop  -- Simulación hasta 200 ns
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;
    
     process
    begin
        while now < 500 ns loop  -- Simulación hasta 200 ns
            enable <= '0';
            wait for clk_period *8;
            enable <= '1';
            wait for clk_period;
        end loop;
        wait;
    end process;


    -- Estímulos de prueba
    process
    begin
        -- 1. Aplicar reset y verificar que el estado vuelve a IDLE
        reset <= '1';
        wait for 20 ns;  -- Esperar 2 ciclos
        reset <= '0';

       

        -- 3. Generar un flanco de subida en la señal de entrada
        
        input <= '1';
        wait for 15 ns;
        input <= '0';  -- Flanco de subida
        wait for 12 ns;
        input <= '1';
        wait for 24 ns;
        input <= '0';  -- Flanco de subida
        wait for 22 ns;
        input <= '1';
        wait for 200 ns;
        input <= '0';  -- Flanco de bajada
        wait for 20 ns;
        input <= '1';  -- Flanco de subida
        wait for 22 ns;
        input <= '0';  -- Flanco de bajada
        wait for 14 ns;
        input <= '1';  -- Flanco de subida
        wait for 9 ns;
        input <= '0';  -- Flanco de subida
        
       

        
        wait;
    end process;

end testbench;
