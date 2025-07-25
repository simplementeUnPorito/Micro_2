library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_frecDivisor is
end tb_frecDivisor;

architecture test of tb_frecDivisor is
    constant m : natural := 8;

    -- Señales para instanciar el DUT
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal finalValue   : std_logic_vector(m-1 downto 0);
    signal enableUpdate : std_logic := '0';
    signal output       : std_logic;

    -- Tiempo de simulación
   -- constant clk_frec   : real := 150_000_000.0;  -- 150 MHz
    constant clk_period : time := 6.6666666 ns;

    constant total_cycles : natural := 2000;
    constant sim_time     : time := clk_period * total_cycles;

begin

    -- Instancia del divisor de frecuencia
    uut: entity work.frecDivisor
        generic map (m => m)
        port map (
            clk          => clk,
            reset        => reset,
            finalValue   => finalValue,
            enableUpdate => enableUpdate,
            output       => output
        );

    -- Generador de reloj
    clk_process : process
    begin
        while now < sim_time loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Proceso de estimulación
    stim_proc: process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Valor 1: 19
        finalValue <= std_logic_vector(to_unsigned(19, m));
        enableUpdate <= '1';
        wait for clk_period;
        enableUpdate <= '0';

        wait for (2*19+3)*clk_period;

        -- Valor 2: 40
        finalValue <= std_logic_vector(to_unsigned(40, m));
        enableUpdate <= '1';
        wait for clk_period;
        enableUpdate <= '0';

        wait for (2*40+3)*clk_period;

        -- Valor 3: 121
        finalValue <= std_logic_vector(to_unsigned(121, m));
        enableUpdate <= '1';
        wait for clk_period;
        enableUpdate <= '0';

        wait for (3+2*121)*clk_period;

        -- Valor 4: 243
        finalValue <= std_logic_vector(to_unsigned(243, m));
        enableUpdate <= '1';
        wait for clk_period;
        enableUpdate <= '0';

        wait for (3+2*243)*clk_period;

        wait;
    end process;

end test;
