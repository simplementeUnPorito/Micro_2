library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ButtonCounter is
    generic(n  :natural := 4;
            delta: natural := 1500000);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           up : in STD_LOGIC;
           down : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR(n-1 downto 0));
end ButtonCounter;

architecture Behavioral of ButtonCounter is
    -- señales intermedias
    signal divided_clk,up_edge,down_edge: std_logic;
    
begin
    DIVISOR: entity work.frecDivisor(Behavioral)
    generic map(n => delta) 
    port map (clk, rst,divided_clk);
    
    UP_BUTTON: entity work.edgeDetector(Behavioral)
    port map (clk, divided_clk,up,up_edge,rst);
    
    DOWN_BUTTON: entity work.edgeDetector(Behavioral)
    port map (clk, divided_clk,down,down_edge,rst);
    
    COUNTER: entity work.upDownCounter(Behavioral)
    generic map (n => n)
    port map(clk, rst, up_edge, down_edge, output);
           
    

end Behavioral;
