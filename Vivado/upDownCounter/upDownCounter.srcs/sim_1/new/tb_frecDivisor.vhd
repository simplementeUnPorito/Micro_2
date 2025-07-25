library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_frecDivisor is
end tb_frecDivisor;

architecture testbench of tb_frecDivisor is
    -- Declarar el DUT (Device Under Test)
    constant n : natural := 4;  -- Ajustable según la prueba
    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal output : STD_LOGIC;

    -- Periodo del clock
    constant clk_period : time := 10 ns;

    -- Instancia del divisor de frecuencia
    component frecDivisor
        generic ( n : natural );
        Port ( clk   : in STD_LOGIC;
               reset : in STD_LOGIC;
               output : out STD_LOGIC); 
    end component;

begin
    -- Instancia del módulo bajo prueba
    DUT: frecDivisor 
        generic map ( n => n )
        port map (
            clk   => clk,
            reset => reset,
            output => output
        );

    -- Generación de reloj
    process
    begin
        while now < 300 ns loop  -- Simulación hasta 200 ns
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
        reset <= '1';
        wait for 2*clk_period;
        reset <= '0';

     
        wait for ((2*n+2) * clk_period);
        reset <= '1';
        wait for  5*clk_period;
        reset <= '0';

        wait for (n * clk_period);
        
        wait;
    end process;

end testbench;
