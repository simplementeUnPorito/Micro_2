library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_upDownCounter is
end tb_upDownCounter;

architecture testbench of tb_upDownCounter is
    -- Parámetros
    constant n : natural := 2;  -- Ancho del contador
    constant clk_period : time := 10 ns;  -- Periodo del reloj

    -- Señales
    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '0';
    signal up      : STD_LOGIC := '0';
    signal down    : STD_LOGIC := '0';
    signal output  : STD_LOGIC_VECTOR (n-1 downto 0);

    -- Instancia del módulo bajo prueba
    component upDownCounter
        generic (n : natural);
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               up : in STD_LOGIC;
               down : in STD_LOGIC;
               output : out STD_LOGIC_VECTOR (n-1 downto 0));
    end component;

begin
    -- Instancia del contador
    DUT: upDownCounter 
        generic map ( n => n )
        port map (
            clk    => clk,
            rst    => rst,
            up     => up,
            down   => down,
            output => output
        );

    -- Generación del reloj
    process
    begin
        while now < 500 ns loop  -- Simulación hasta 200 ns
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
        wait for 20 ns;  -- Espera unos ciclos
        rst <= '0';

        -- 2. Contar hacia arriba (incrementar)
        up <= '1';
        wait for 70 ns;  -- Debería incrementar varias veces
        up <= '0';

        -- 3. Contar hacia abajo (decrementar)
        down <= '1';
        wait for 70 ns;  -- Debería decrementar varias veces
        down <= '0';

        -- 4. Prueba de activación simultánea de `up` y `down` (el contador no debe cambiar)
        up <= '1';
        down <= '1';
        wait for 20 ns;
        up <= '0';
        down <= '0';

        -- 5. Otra serie de incrementos y decrementos
        up <= '1';
        wait for 30 ns;
        up <= '0';

        down <= '1';
        wait for 30 ns;
        down <= '0';

        -- Finaliza la simulación
        wait;
    end process;

end testbench;
