----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.05.2024 19:33:00
-- Design Name: 
-- Module Name: mips_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mips_tb is
--  Port ( );
end mips_tb;

architecture Behavioral of mips_tb is
    COMPONENT MIPS is
	port (
		clk         : in std_logic;
		-- pines de reset externos los pines west y east de alrededor de la perilla de la placa
		reset_boton : in std_logic;
		-- entrada de los dos pulsadores de alrededor de la perilla de la placa
		salida      : out std_logic_vector(3 downto 0);
		botones     : in  std_logic_vector(3 downto 0);
		llaves      : in  std_logic_vector(3 downto 0);
		-- puerto serial
		rx          : in std_logic;
		tx          : out std_logic;
		atn         : in std_logic);
        
    end component;
    signal clk50mhz : std_logic;
    signal reset_boton : std_logic;
    signal salida : std_logic_vector (3 downto 0);
    signal botones : std_logic_vector(3 downto 0);
    signal llaves :  std_logic_vector(3 downto 0);
    signal rx : std_logic;
	signal tx : std_logic;
	signal atn : std_logic;
	
    constant TbPeriod : time := 8 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin
    dut : mips port map (
        clk => clk50mhz,
        reset_boton => reset_boton,
        salida => salida,
        botones => botones,
        llaves => llaves,
        rx => rx,
        tx => tx,
        atn => atn
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk50mhz <= TbClock;

    stimuli : process
        variable i : integer;
        variable dato1 : std_logic_vector (7 downto 0) := "10100011";
        variable dato2 : std_logic_vector (7 downto 0) := "01010101";
    begin
        -- EDIT Adapt initialization as needed
        reset_boton <= '1';
        wait for TbPeriod * 2;
        reset_boton <= '0';
        wait for TbPeriod * 2;        
        
        wait for TbPeriod * 100;  
     
        wait;
    end process;
    
    
end Behavioral;
