library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity frecDivisor is
    generic (
        m : natural := 8  -- Número de bits del contador
    );
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        finalValue  : in  STD_LOGIC_VECTOR(m-1 downto 0); 
        enableUpdate : in  STD_LOGIC;
        output       : out STD_LOGIC
    ); 
end frecDivisor;

architecture Behavioral of frecDivisor is
    signal counter, next_counter : unsigned(m-1 downto 0) := (others => '0');
    signal regFinalValue    : unsigned(m-1 downto 0) := (others => '1'); -- Inicialización segura al valor máximo
begin

    -- Circuito de cambio de estado
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                regFinalValue <= (others => '1');
                counter <= (others => '0');
            else
                --actualizar finalValue y contador
                if enableUpdate = '1' and unsigned(finalValue) /= to_unsigned(0, m) then
                    regFinalValue <= unsigned(finalValue);
                    counter <= (others => '0');
                else
                    --actualizar contador
                    counter <= next_counter;
                end if;
            end if;
        end if;
    end process;

    -- Circuito de estado siguiente
    process(counter, regFinalValue)
    begin
        if counter = regFinalValue then
            next_counter <= (others => '0');
        else
            next_counter <= counter + 1;
        end if;
    end process;
    
    -- Circuito de salida
    output <= '1' when counter = regFinalValue else '0';

end Behavioral;
