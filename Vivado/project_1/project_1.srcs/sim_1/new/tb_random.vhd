library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_randomizador is
end entity;

architecture testbench of tb_randomizador is

    constant CLK_PERIOD : time := 10 ns;
    constant N          : natural := 48;
    constant BITS_OUT   : integer := integer(ceil(log2(real(N))));

    -- Señales para conectar al DUT
    signal clk          : std_logic := '0';
    signal rand         : std_logic := '0';
    signal chaos        : std_logic := '0';
    signal read         : std_logic := '0';
    signal randomNumber : unsigned(BITS_OUT - 1 downto 0);
    signal done         : std_logic;

    -- Componente bajo prueba
    component randomizador
        generic (
            N : integer := 100
        );
        port (
            clk          : in  std_logic;
            rand         : in  std_logic;
            chaos        : in  std_logic;
            read         : in  std_logic;
            randomNumber : out unsigned(BITS_OUT - 1 downto 0);
            done         : out std_logic
        );
    end component;

begin

    -- Instancia del DUT
    DUT: randomizador
        generic map (
            N => N
        )
        port map (
            clk          => clk,
            rand         => rand,
            chaos        => chaos,
            read         => read,
            randomNumber => randomNumber,
            done         => done
        );

    -- Generador de reloj
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

     stim_proc : process
    begin
        wait for 20 ns;

        for i in 0 to 14 loop  -- 15 generaciones
            -- Activar caos aleatoriamente 1 a 3 veces antes de cada rand
            for j in 0 to (i mod 3) loop
                chaos <= '1';
                wait for CLK_PERIOD;
                chaos <= '0';
                wait for 10 ns + 5 ns * j;
            end loop;

            -- Generar número aleatorio
            rand <= '1';
            wait for CLK_PERIOD;
            rand <= '0';
            wait for 20 ns;

            -- Leer el valor para bajar done
            read <= '1';
            wait for CLK_PERIOD;
            read <= '0';

            -- Esperar antes de la próxima iteración (espaciado variable)
            wait for 40 ns + 10 ns * i;
        end loop;

        wait;
    end process;

end architecture;
