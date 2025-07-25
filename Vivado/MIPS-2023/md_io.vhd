----------------------------------------------------------------------------------
-- Company: Universidad Católica
-- Engineer: Vicente González
-- 
-- Create Date:    14:44:35 06/14/2017 
-- Design Name: 
-- Module Name:    md_io - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use work.general.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity md_io is
    Port ( address   : in  STD_LOGIC_VECTOR (31 downto 0);
           writedata : in  STD_LOGIC_VECTOR (31 downto 0);
           memwrite  : in  STD_LOGIC;
           memread   : in  STD_LOGIC;
		   tipoAcc   : in  STD_LOGIC_VECTOR (2 downto 0); --tipo de operación a realizar, cargar bytes, half word y word
           clk       : in  STD_LOGIC;
		   reset     : in  STD_LOGIC;
		   botones   : in  std_logic_vector(3 downto 0);
		   llaves    : in  std_logic_vector(3 downto 0);
           salida    : out std_logic_vector(3 downto 0);
           readdata  : out STD_LOGIC_VECTOR (31 downto 0));
end md_io;

architecture Behavioral of md_io is
	COMPONENT entrada
    Port ( btn    : in   STD_LOGIC_VECTOR(3 downto 0);
           sw     : in   STD_LOGIC_VECTOR (3 downto 0);
           alMIPS : out  STD_LOGIC_VECTOR (7 downto 0));
	END COMPONENT;

	COMPONENT decodificador
    Port ( ent       : in  STD_LOGIC_VECTOR (31 downto 0);
           csMem     : out  STD_LOGIC;
           csParPort : out  STD_LOGIC;
		   csEntrada : out STD_LOGIC
			);
	END COMPONENT;

	COMPONENT md
    Port ( dir      : STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_DATOS -1 +2 downto 0);
           datain   : in  STD_LOGIC_VECTOR (31 downto 0);
           cs       : in  STD_LOGIC;
           memwrite : in  STD_LOGIC;
           memread  : in  STD_LOGIC;
		   tipoAcc  : in STD_LOGIC_VECTOR (2 downto 0);
           clk      : in  STD_LOGIC;
           dataout  : out  STD_LOGIC_VECTOR (31 downto 0)
			);
	END COMPONENT;

	COMPONENT salida_par
    Port ( sel         : in  STD_LOGIC;
           write_cntl  : in  STD_LOGIC;
           clk         : in  STD_LOGIC;
           reset       : in  STD_LOGIC;
           data        : in  STD_LOGIC_VECTOR (3 downto 0);     -- dato que viene del MIPS
           salida      : out STD_LOGIC_VECTOR (3 downto 0));   -- pines externos
	END COMPONENT;

-- Definimos señales para interconexión interna en este módulo
	signal csMem       : STD_LOGIC;
	signal csSalidaPar : STD_LOGIC;
	signal csEntrada   : STD_LOGIC;
	signal datosMem    : STD_LOGIC_VECTOR (31 downto 0);
	signal datosEntrada: STD_LOGIC_VECTOR (7 downto 0);
	
begin

	-- Multiplexor de salida
	readdata  <= datosMem                 when csMem = '1' and memread = '1' else
			     x"000000" & datosEntrada when csEntrada = '1' and memread = '1' else
			     (others => '0');

	Inst_entrada: entrada PORT MAP (
		btn    => botones,
		sw     => llaves,
		alMIPS => datosEntrada
	);
	
	Inst_decodificador: decodificador PORT MAP(
		ent       => address(31 downto 0),
        csMem     => csMem,
		csParPort => csSalidaPar,
		csEntrada => csEntrada
	);

	Inst_md: md PORT MAP(
		dir      => address(NUM_BITS_MEMORIA_DATOS -1+2 downto 0),
        datain   => writedata,
        cs       => csMem,
        memwrite => memwrite,
        memread  => memread,
		tipoAcc  => tipoAcc,
        clk      => clk,
        dataout  => datosMem
	);

	Inst_salida_par: salida_par PORT MAP(
		sel        => csSalidaPar,
        write_cntl => memwrite,
        clk        => clk,
        reset      => reset,
        data       => writedata(3 downto 0),
        salida     => salida
	);

end Behavioral;

