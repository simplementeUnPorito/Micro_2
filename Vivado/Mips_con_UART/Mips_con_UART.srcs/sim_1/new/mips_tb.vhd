library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.general.all;

entity tb_mips_uart is
end tb_mips_uart;

architecture Behavioral of tb_mips_uart is

    component mips
        port (
            clk         : in  std_logic;
            reset_boton : in  std_logic;
            salida      : out std_logic_vector(3 downto 0);
            botones     : in  std_logic_vector(3 downto 0);
            llaves      : in  std_logic_vector(3 downto 0);
            rx1         : in  std_logic;
            tx1         : out std_logic;
            atn         : in  std_logic
        );
    end component;

    signal clk_tb         : std_logic := '0';
    signal reset_tb       : std_logic := '1';
    signal botones_tb     : std_logic_vector(3 downto 0) := (others => '0');
    signal llaves_tb      : std_logic_vector(3 downto 0) := (others => '0');
    signal rx_tb          : std_logic := '1';
    signal tx_tb          : std_logic;
    signal salida_tb      : std_logic_vector(3 downto 0);
    signal atn_tb         : std_logic := '1';

    constant CLK_PERIOD   : time := 8 ns;  -- 125 MHz
    constant bps          : natural := 9600;
    constant spb          : time    := 104166.66666666 ns;
    procedure send_uart_byte(signal uart_rx : out std_logic; b : std_logic_vector(7 downto 0)) is
    begin
        uart_rx <= '0';  -- start bit
        wait for spb;
        for i in 0 to 7 loop
            uart_rx <= b(i);
            wait for spb;
        end loop;
        uart_rx <= '1';  -- stop bit
        wait for spb;
    end procedure;

begin

    UUT: mips
        port map (
            clk         => clk_tb,
            reset_boton => reset_tb,
            salida      => salida_tb,
            botones     => botones_tb,
            llaves      => llaves_tb,
            rx1         => rx_tb,
            tx1         => tx_tb,
            atn         => atn_tb
        );

    clk_process : process
    begin
        while now < 5 ms loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    stim_proc : process
    begin
        wait for 200 ns;
        reset_tb <= '0';
        wait for 1600 ns;

        -- Enviar el byte 0x55 (esperamos que se reciba y reenvíe)
        send_uart_byte(rx_tb, x"55");

        wait;

    end process;
end Behavioral;
