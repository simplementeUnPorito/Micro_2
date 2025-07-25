library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.general.all;

entity md_io is
    Port (
        address   : in  STD_LOGIC_VECTOR (31 downto 0);
        writedata : in  STD_LOGIC_VECTOR (31 downto 0);
        memwrite  : in  STD_LOGIC;
        memread   : in  STD_LOGIC;
        tipoAcc   : in  STD_LOGIC_VECTOR (2 downto 0);
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        botones   : in  std_logic_vector(3 downto 0);
        llaves    : in  std_logic_vector(3 downto 0);
        salida    : out std_logic_vector(3 downto 0);
        readdata  : out STD_LOGIC_VECTOR (31 downto 0);
        tx        : out std_logic;
        rx        : in std_logic
    );
end md_io;

architecture Behavioral of md_io is

    COMPONENT UART
        Port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            finalValue  : in  std_logic_vector(5 downto 0);
            en_tx_write : in  std_logic;
            en_rx_read  : in  std_logic;
            tx_data_in  : in  std_logic_vector(7 downto 0);
            tx          : out std_logic;
            rx          : in  std_logic;
            rx_data_out : out std_logic_vector(7 downto 0);
            FLAGS       : out std_logic_vector(7 downto 0)
        );
    END COMPONENT;

    COMPONENT entrada
        Port (
            btn    : in  STD_LOGIC_VECTOR(3 downto 0);
            sw     : in  STD_LOGIC_VECTOR(3 downto 0);
            alMIPS : out STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;

    COMPONENT decodificador
        Port (
            ent       : in  STD_LOGIC_VECTOR (31 downto 0);
            csMem     : out STD_LOGIC;
            csParPort : out STD_LOGIC;
            csEntrada : out STD_LOGIC;
            csUART    : out STD_LOGIC
        );
    END COMPONENT;

    COMPONENT md
        Port (
            dir      : STD_LOGIC_VECTOR (NUM_BITS_MEMORIA_DATOS -1 +2 downto 0);
            datain   : in  STD_LOGIC_VECTOR (31 downto 0);
            cs       : in  STD_LOGIC;
            memwrite : in  STD_LOGIC;
            memread  : in  STD_LOGIC;
            tipoAcc  : in  STD_LOGIC_VECTOR (2 downto 0);
            clk      : in  STD_LOGIC;
            dataout  : out STD_LOGIC_VECTOR (31 downto 0)
        );
    END COMPONENT;

    COMPONENT salida_par
        Port (
            sel        : in  STD_LOGIC;
            write_cntl : in  STD_LOGIC;
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            data       : in  STD_LOGIC_VECTOR(3 downto 0);
            salida     : out STD_LOGIC_VECTOR(3 downto 0)
        );
    END COMPONENT;

    -- Señales internas
    signal csMem       : STD_LOGIC;
    signal csSalidaPar : STD_LOGIC;
    signal csEntrada   : STD_LOGIC;
    signal csUART      : STD_LOGIC;
    signal datosMem    : STD_LOGIC_VECTOR (31 downto 0);
    signal datosEntrada: STD_LOGIC_VECTOR (7 downto 0);

    -- UART internals
    signal uart_ctrl     : std_logic_vector(7 downto 0);
    signal uart_tx_data  : std_logic_vector(7 downto 0);
    signal uart_rx_data  : std_logic_vector(7 downto 0);
    signal uart_flags    : std_logic_vector(7 downto 0);

    -- Señales desglosadas
    signal finalValue    : std_logic_vector(5 downto 0);
    signal en_rx_read    : std_logic;
    signal en_tx_write   : std_logic;

begin

    -- Multiplexor de lectura
    readdata <= datosMem when csMem = '1' and memread = '1' else
                x"000000" & datosEntrada when csEntrada = '1' and memread = '1' else
                x"000000" & uart_rx_data when csUART = '1' and memread = '1' and address(1 downto 0) = "01" else
                x"000000" & uart_flags   when csUART = '1' and memread = '1' and address(1 downto 0) = "11" else
                (others => '0');

    -- Entrada de botones/llaves
    Inst_entrada: entrada PORT MAP (
        btn    => botones,
        sw     => llaves,
        alMIPS => datosEntrada
    );

    -- Decodificador de dirección
    Inst_decodificador: decodificador PORT MAP (
        ent       => address,
        csMem     => csMem,
        csParPort => csSalidaPar,
        csEntrada => csEntrada,
        csUART    => csUART
    );

    -- Memoria de datos
    Inst_md: md PORT MAP (
        dir      => address(NUM_BITS_MEMORIA_DATOS -1+2 downto 0),
        datain   => writedata,
        cs       => csMem,
        memwrite => memwrite,
        memread  => memread,
        tipoAcc  => tipoAcc,
        clk      => clk,
        dataout  => datosMem
    );

    -- Salida paralela
    Inst_salida_par: salida_par PORT MAP (
        sel        => csSalidaPar,
        write_cntl => memwrite,
        clk        => clk,
        reset      => reset,
        data       => writedata(3 downto 0),
        salida     => salida
    );

    -- Escritura UART
    process(clk)
    begin
        if rising_edge(clk) then
            if memwrite = '1' and csUART = '1' then
                case address(1 downto 0) is
                    when "00" => uart_ctrl    <= writedata(7 downto 0);
                    when "10" => uart_tx_data <= writedata(7 downto 0);
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- Control UART
    en_tx_write <= uart_ctrl(0);
    en_rx_read  <= uart_ctrl(1);
    finalValue  <= uart_ctrl(7 downto 2);

    -- Instanciación UART
    Inst_UART: UART
        port map (
            clk         => clk,
            rst         => reset,
            finalValue  => finalValue,
            en_tx_write => en_tx_write,
            en_rx_read  => en_rx_read,
            tx_data_in  => uart_tx_data,
            tx          => tx,
            rx          => rx,
            rx_data_out => uart_rx_data,
            FLAGS       => uart_flags
        );

end Behavioral;
