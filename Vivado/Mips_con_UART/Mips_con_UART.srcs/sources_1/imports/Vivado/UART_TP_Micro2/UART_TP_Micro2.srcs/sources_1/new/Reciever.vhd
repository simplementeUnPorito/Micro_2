library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity Reciever is
    Port (
        clk    : in STD_LOGIC;
        rst    : in STD_LOGIC;
        input  : in STD_LOGIC;
        tick   : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        done   : out STD_LOGIC;
        state : out state_r
    );
end Reciever;

architecture Behavioral of Reciever is

    signal prv_input : std_logic := '1';  -- ❌ Ya no lo usamos realmente, pero lo mantengo por compatibilidad

    signal std, nxt_std : state_r := IDLE;

    -- CONTADORES Y CONSTANTES (sin cambios)
    constant COUNTER_TICKS_WIDTH : natural := minBitsRequired(max(TICKS_PER_DATA, TICKS_FOR_STOP));
    signal cont_ticks, nxt_cont_ticks : unsigned(COUNTER_TICKS_WIDTH-1 downto 0) := (others => '0');
    constant TICKS_PER_DATAu       : unsigned(COUNTER_TICKS_WIDTH-1 downto 0) := to_unsigned(TICKS_PER_DATA-1, COUNTER_TICKS_WIDTH);
    constant HALF_TICKS_PER_DATAu  : unsigned(COUNTER_TICKS_WIDTH-1 downto 0) := to_unsigned((TICKS_PER_DATA-1)/2, COUNTER_TICKS_WIDTH);
    constant TICKS_FOR_STOPu       : unsigned(COUNTER_TICKS_WIDTH-1 downto 0) := to_unsigned(TICKS_FOR_STOP-1, COUNTER_TICKS_WIDTH);

    constant COUNTER_BITS_WIDTH : natural := minBitsRequired(DATA_WIDTH);
    signal cont_bits, nxt_cont_bits : unsigned(COUNTER_BITS_WIDTH-1 downto 0) := (others => '0');
    constant MAX_COUNTER_BITS : unsigned(COUNTER_BITS_WIDTH-1 downto 0) := to_unsigned(DATA_WIDTH-1, COUNTER_BITS_WIDTH);

    signal data, nxt_data : std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal nxt_done, sdone : std_logic := '0';

begin

    -- 🔁 CAMBIO 1: se elimina dependencia del flanco descendente manual, y se simplifica la lógica de estado
    NEXT_STATE: process(rst, tick, std, cont_ticks, cont_bits, data, input)
    begin
        -- valores por defecto (igual que antes)
        nxt_std        <= std;
        nxt_cont_ticks <= cont_ticks;
        nxt_cont_bits  <= cont_bits;
        nxt_data       <= data;
        nxt_done       <= '0';  -- ✅ CAMBIO 2: done ahora solo se activa en STOP

        case std is
            when IDLE =>
                if input = '0' then  -- ✅ CAMBIO 3: ya no usamos prv_input para detectar flanco
                    nxt_std        <= START;
                    nxt_cont_ticks <= (others => '0');
                end if;

            when START =>
                if tick = '1' then
                    if cont_ticks = HALF_TICKS_PER_DATAu then
                        nxt_std        <= READ;
                        nxt_cont_ticks <= (others => '0');
                        nxt_cont_bits  <= (others => '0');
                        nxt_data       <= (others => '0');
                    else
                        nxt_cont_ticks <= cont_ticks + 1;
                    end if;
                end if;

            when READ =>
                if tick = '1' then
                    if cont_ticks = TICKS_PER_DATAu then
                        nxt_data       <= input & data(DATA_WIDTH-1 downto 1);  -- shift-in como antes
                        nxt_cont_bits  <= cont_bits + 1;
                        nxt_cont_ticks <= (others => '0');

                        if cont_bits = MAX_COUNTER_BITS then
                            nxt_std <= STOP;
                        end if;
                    else
                        nxt_cont_ticks <= cont_ticks + 1;
                    end if;
                end if;

            when STOP =>
                if tick = '1' then
                    if cont_ticks = TICKS_FOR_STOPu then
                        nxt_std        <= IDLE;
                        nxt_done       <= '1';  -- ✅ CAMBIO 4: done activado al final del STOP
                        nxt_cont_ticks <= (others => '0');
                        nxt_cont_bits  <= (others => '0');
                    else
                        nxt_cont_ticks <= cont_ticks + 1;
                    end if;
                end if;

            when others =>
                nxt_std <= IDLE;
        end case;
    end process;

    -- MEM: igual que antes, salvo que removimos prv_input (lo dejamos, pero ya no se usa)
    MEM: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                std         <= IDLE;
                cont_ticks  <= (others => '0');
                cont_bits   <= (others => '0');
                data        <= (others => '0');
                sdone       <= '0';
            else
                std         <= nxt_std;
                cont_ticks  <= nxt_cont_ticks;
                cont_bits   <= nxt_cont_bits;
                data        <= nxt_data;
                sdone       <= nxt_done;
            end if;
        end if;
    end process;

    -- Salidas
    output <= data;
    done   <= sdone;
    state  <= std;

end Behavioral;
