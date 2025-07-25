library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;  -- Para usar log2

entity frecDivisor is
    generic ( n : natural := 4);
    Port ( clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           output : out STD_LOGIC); 
end frecDivisor;

architecture Behavioral of frecDivisor is
    -- Calcular el número de bits necesario
    constant m : natural := integer(ceil(log2(real(n))));  
    signal counter,next_counter : unsigned(m-1 downto 0) := (others => '0');
    constant n_unsigned: unsigned (m-1 downto 0) := to_unsigned(n-1, m);
begin

    --Circuito de estado siguiente
    process(counter)
    begin
        case counter is
            when n_unsigned =>
                next_counter <= (others => '0');
            when others =>
                next_counter <= counter + 1;
        end case;
    end process;


    --Circuito de actualización de estado
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= (others => '0');
            else
                counter <= next_counter;
            end if;
        end if;
    end process;
    
    -- Circuito de Salida
    output <= '1' when counter = n_unsigned else '0';

end Behavioral;
