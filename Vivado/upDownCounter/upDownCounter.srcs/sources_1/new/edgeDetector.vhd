library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edgeDetector is

    Port ( clk   : in STD_LOGIC;
           enable: in STD_LOGIC;
           input : in STD_LOGIC;
           output : out STD_LOGIC;
           reset : in STD_LOGIC
           );
end edgeDetector;

architecture Behavioral of edgeDetector is
    type state is (IDLE,MAYBE_EDGE,IS_EDGE,WAIT_ZERO,MAYBE_ZERO);
    signal std, next_std : state := IDLE; -- Se asegura la actualización del estado
begin

    

    -- Circuito de estado siguiente
    process(input,std, enable)
    begin
            case std is
                when IDLE =>
                    if enable = '1' and input = '1' then
                        next_std <= MAYBE_EDGE;
                    else
                        next_std <= IDLE;
                    end if;
                when MAYBE_EDGE =>
                    
                    if input = '1' and enable = '1' then
                        next_std <= IS_EDGE;
                    elsif input = '0' and enable = '1' then
                        next_std <= IDLE;
                    else 
                        next_std<=MAYBE_EDGE;
                    end if;
                    
    
                when IS_EDGE =>
                    next_std <= WAIT_ZERO;
    
                when WAIT_ZERO =>
                    if enable = '1' and input = '0' then
                        next_std <= MAYBE_ZERO;
                    else
                        next_std <= WAIT_ZERO;
                    end if;
                    
                    
                 when MAYBE_ZERO =>
                    if input = '0' and enable = '1' then
                        next_std <= IDLE;
                    elsif input = '1' and enable = '1' then
                        next_std <= WAIT_ZERO;
                    else 
                        next_std<=MAYBE_ZERO;
                    end if;
            end case;
    end process;
    
    
    
    -- Circuito de actualizacion de memoria
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                std <= IDLE;
            else
                std <= next_std;
            end if;
        end if;
    end process;
    
    --Circuito de salida
    output <= '1' when std = IS_EDGE else '0';

end Behavioral;
