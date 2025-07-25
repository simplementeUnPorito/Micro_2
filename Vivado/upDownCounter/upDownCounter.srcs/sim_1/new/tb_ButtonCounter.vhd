library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb1_ButtonCounter is
end tb1_ButtonCounter;

architecture testbench of tb1_ButtonCounter is
    -- Parámetros de prueba
    constant n : natural := 4;
    constant delta : natural := 4;
    constant clk_period : time := 10 ns;  -- Periodo del reloj

    -- Señales
    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '0';
    signal up      : STD_LOGIC := '0';
    signal down    : STD_LOGIC := '0';
    signal output  : STD_LOGIC_VECTOR(n-1 downto 0);

    -- Instancia del módulo bajo prueba
    component ButtonCounter
        generic (n  : natural;
                 delta: natural);
        Port ( clk    : in  STD_LOGIC;
               rst    : in  STD_LOGIC;
               up     : in  STD_LOGIC;
               down   : in  STD_LOGIC;
               output : out STD_LOGIC_VECTOR(n-1 downto 0));
    end component;

begin
    -- Instancia del contador de botones
    DUT: ButtonCounter
        generic map ( n => n, delta => delta )
        port map (
            clk    => clk,
            rst    => rst,
            up     => up,
            down   => down,
            output => output
        );

    -- Generación del reloj principal
    process
    begin
        while now < 8000 ns loop  -- Simulación hasta 2000 ns
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Estímulos de prueba
    process
    begin
        -- 1. Aplicar reset y verificar que el contador se reinicia a 0
        rst <= '1';
        up<= '0';
        down <= '0';
        wait for 20 ns;
        rst <= '0';
        wait for 50 ns;
        
        -- 2. Pulsaciones rápidas (3 ciclos de reloj cada una) - 20 veces para UP
        down <= '0';
        for i in 1 to 20 loop
            up <= '1';
            wait for clk_period/4; -- Mantiene el botón presionado 3 ciclos de reloj
            up <= '0';
            wait for 10 * clk_period/4; -- Tiempo de espera entre pulsaciones
        end loop;

        wait for 100 ns;
        
        -- 3. Pulsaciones rápidas (3 ciclos de reloj cada una) - 20 veces para DOWN
        up<= '0';
        for i in 1 to 20 loop
            down <= '1';
            wait for clk_period/4;
            down <= '0';
            wait for 10 * clk_period/4;
        end loop;

        wait for 200 ns;

        -- 4. Pulsaciones lentas (7 ciclos de reloj cada una) - 20 veces para UP
        down <= '0';
        for i in 1 to 20 loop
            up <= '1';
            wait for 10* clk_period; -- Mantiene el botón presionado 7 ciclos de reloj
            up <= '0';
            wait for 10* clk_period; -- Tiempo de espera entre pulsaciones
        end loop;

        wait for 200 ns;

        -- 5. Pulsaciones lentas (7 ciclos de reloj cada una) - 20 veces para DOWN
        up<= '0';
        for i in 1 to 20 loop
            down <= '1';
            wait for 7 * clk_period;
            down <= '0';
            wait for 7 * clk_period;
        end loop;
        
        
        -- 5. Pulsaciones lentas (7 ciclos de reloj cada una) - 20 veces para DOWN y UP a la VEZ
        up<= '1';
        for i in 1 to 20 loop
            down <= '1';
            wait for 7 * clk_period;
            down <= '0';
            wait for 7 * clk_period;
        end loop;

        -- Finalizar la simulación
        up<= '0';
        down<='0';
        wait;
    end process;

end testbench;




