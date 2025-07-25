library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb2_ButtonCounter is
end tb2_ButtonCounter;

architecture testbench of tb2_ButtonCounter is
    -- Parámetros de prueba
    constant n : natural := 4;
    constant delta : natural := 6;
    constant clk_period : time := 10 ns;  -- Periodo del reloj

    -- Señales
    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '0';
    signal up      : STD_LOGIC := '0';
    signal down    : STD_LOGIC := '0';
    signal output  : STD_LOGIC_VECTOR(n-1 downto 0);

    -- Instancia del módulo bajo prueba
    component ButtonCounter
        generic (n  : natural := 4;
                 delta: natural :=4);
        Port ( clk    : in  STD_LOGIC;
               rst    : in  STD_LOGIC;
               up     : in  STD_LOGIC;
               down   : in  STD_LOGIC;
               output : out STD_LOGIC_VECTOR(n-1 downto 0));
    end component;

    -- Procedimiento para simular una pulsación con bouncing (subida y bajada)
    procedure simulate_button_press(
        signal btn         : out std_logic;
        active_level       : std_logic := '1';
        bounce_time        : time := 100 ns;
        press_time         : time := 500 ns
    ) is
        constant bounce_step : time :=  clk_period/4;
        variable t : time := 0 ns;
        constant inactive_level : std_logic := not active_level;
    begin
        -- Bouncing al presionar (0 → 1)
        while t < bounce_time loop
            btn <= inactive_level;
            wait for bounce_step;
            btn <= active_level;
            wait for bounce_step;
            t := t + 2 * bounce_step;
        end loop;

        -- Botón presionado de forma estable
        btn <= active_level;
        wait for press_time;

        -- Bouncing al soltar (1 → 0)
        t := 0 ns;
        while t < bounce_time loop
            btn <= active_level;
            wait for bounce_step;
            btn <= inactive_level;
            wait for bounce_step;
            t := t + 2 * bounce_step;
        end loop;

        btn <= inactive_level;
    end procedure;
    
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
    clk_process: process
    begin
        while now < 18000 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Estímulos de prueba con bouncing realista
    stim_proc: process
    begin
        -- Reset con rebote
        simulate_button_press(rst, '1', 30 ns, 200 ns);
        wait for 100 ns;

        
        -- Ruido en UP
        for i in 1 to 5 loop
            simulate_button_press(up, '1', 50 ns, 0 ns);
            wait for 300 ns;
        end loop;

        wait for 200 ns;
        
        -- Ruido en DOWN
         for i in 1 to 5 loop
            simulate_button_press(down, '1', 50 ns, 0 ns);
            wait for 300 ns;
        end loop;

        wait for 200 ns;

        -- Pulsaciones más lentas UP
        for i in 1 to 5 loop
            simulate_button_press(up, '1', 30 ns, 200 ns);
            wait for 300 ns;
        end loop;

        wait for 200 ns;

        -- Pulsaciones más lentas DOWN
        for i in 1 to 5 loop
            simulate_button_press(down, '1', 30 ns, 200 ns);
            wait for 300 ns;
        end loop;


        -- Pulsaciones simultáneas UP y DOWN
        for i in 1 to 5 loop
            wait for 200 ns;
            up <= '1';
            down <= '1';
            wait for 200 ns;
            up <= '0';
            down <= '0';
        end loop;

       

        -- Fin de simulación
        up <= '0';
        down <= '0';
        wait;
    end process;

end testbench;