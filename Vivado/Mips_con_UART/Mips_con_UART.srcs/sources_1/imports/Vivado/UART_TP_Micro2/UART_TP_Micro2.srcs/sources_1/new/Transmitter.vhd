library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity Transmitter is
    Port (
        input  : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        output : out STD_LOGIC;
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        start_t  : in  STD_LOGIC;
        tick   : in  STD_LOGIC;
        done   : out STD_LOGIC;
        state  : out state_t
    );
end Transmitter;

architecture Behavioral of Transmitter is

    signal std, nxt_std : state_t := IDLE;

    constant TICKS_WIDTH : natural := minBitsRequired(TICKS_PER_DATA);
    signal cont_ticks, nxt_cont_ticks : unsigned(TICKS_WIDTH-1 downto 0) := (others => '0');
    constant TICKS_PER_DATAu : unsigned(TICKS_WIDTH-1 downto 0) := to_unsigned(TICKS_PER_DATA-1, TICKS_WIDTH);
    constant TICKS_FOR_STOPu : unsigned(TICKS_WIDTH-1 downto 0) := to_unsigned(TICKS_FOR_STOP-1, TICKS_WIDTH);

    constant BITS_WIDTH : natural := minBitsRequired(DATA_WIDTH);
    signal cont_bits, nxt_cont_bits : unsigned(BITS_WIDTH-1 downto 0) := (others => '0');
    constant MAX_COUNTER_BITS : unsigned(BITS_WIDTH-1 downto 0) := to_unsigned(DATA_WIDTH-1, BITS_WIDTH);

    signal data, nxt_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal tx_reg, nxt_tx_reg : std_logic := '1';
    signal sdone, nxt_done : std_logic := '0';

begin

    ----------------------------------------------------------------
    -- Siguiente estado
    ----------------------------------------------------------------
    NEXT_STATE: process(std, start_t, tick, cont_ticks, cont_bits, data)
    begin
        -- Defaults
        nxt_std        <= std;
        nxt_cont_ticks <= cont_ticks;
        nxt_cont_bits  <= cont_bits;
        nxt_data       <= data;
        nxt_tx_reg     <= tx_reg;
        nxt_done       <= '0';

        case std is
            when IDLE =>
                nxt_tx_reg <= '1';
                if start_t = '1' then
                    nxt_std        <= START;
                    nxt_data       <= input;
                    nxt_cont_ticks <= (others => '0');
                end if;

            when START =>
                nxt_tx_reg <= '0';
                if tick = '1' then
                    if cont_ticks = TICKS_PER_DATAu then
                        nxt_std        <= SEND;
                        nxt_cont_ticks <= (others => '0');
                        nxt_cont_bits  <= (others => '0');
                    else
                        nxt_cont_ticks <= cont_ticks + 1;
                    end if;
                end if;

            when SEND =>
                nxt_tx_reg <= data(0);  -- enviar LSB
                if tick = '1' then
                    if cont_ticks = TICKS_PER_DATAu then
                        nxt_data       <= '0' & data(DATA_WIDTH - 1 downto 1);  -- shift right
                        nxt_cont_ticks <= (others => '0');
                        nxt_cont_bits  <= cont_bits + 1;
                        if cont_bits = MAX_COUNTER_BITS then
                            nxt_std <= STOP;
                        end if;
                    else
                        nxt_cont_ticks <= cont_ticks + 1;
                    end if;
                end if;

            when STOP =>
                nxt_tx_reg <= '1';
                if tick = '1' then
                    if cont_ticks = TICKS_FOR_STOPu then
                        nxt_std        <= IDLE;
                        nxt_cont_ticks <= (others => '0');
                        nxt_done       <= '1';
                    else
                        nxt_cont_ticks <= cont_ticks + 1;
                    end if;
                end if;
        end case;
    end process;

    ----------------------------------------------------------------
    -- Registro de estado
    ----------------------------------------------------------------
    MEM: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                std         <= IDLE;
                cont_ticks  <= (others => '0');
                cont_bits   <= (others => '0');
                data        <= (others => '0');
                tx_reg      <= '1';
                sdone       <= '0';
            else
                std         <= nxt_std;
                cont_ticks  <= nxt_cont_ticks;
                cont_bits   <= nxt_cont_bits;
                data        <= nxt_data;
                tx_reg      <= nxt_tx_reg;
                sdone       <= nxt_done;
            end if;
        end if;
    end process;

    -- Salidas
    output <= tx_reg;
    done   <= sdone;
    state  <= std;

end Behavioral;
