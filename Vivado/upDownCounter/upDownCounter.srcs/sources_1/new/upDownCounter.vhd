
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity upDownCounter is
    generic (n: natural := 4);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           up : in STD_LOGIC;
           down : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (n-1 downto 0));
end upDownCounter;

architecture Behavioral of upDownCounter is
    signal count,next_count : unsigned(n-1 downto 0) := (others => '0');    
begin
    --circuito de estado siguiente
    process(up,down,count)
    begin
        if up = '1' and down = '0' then
            next_count <= count + 1;
        elsif down = '1' and up = '0' then
            next_count <= count - 1;
        else 
            next_count <= count;
        end if;
    end process;
    
    --circuito de actualización
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count <= (others => '0');
            else
                count <= next_count;
            end if;
        end if;
    end process;

    output <= std_logic_vector(count);


end Behavioral;
