library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

entity FIFO is
    Port ( 
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        input   : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        output  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0):= (others=> '0');
        write   : in  STD_LOGIC;
        read    : in  STD_LOGIC;
        empty   : out STD_LOGIC;
        full    : out STD_LOGIC
    );
end FIFO;

architecture Behavioral of FIFO is

    type ram_type is array (0 to QUEUE_LEN - 1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal queue : ram_type := (others => (others => '0'));

    subtype index is natural range 0 to QUEUE_LEN - 1;
    signal head, tail : index := 0;

    signal s_empty, s_full : std_logic;
    signal inc_head, inc_tail : std_logic := '0';

    -- Función de incremento circular
    function incr(i : index) return index is
    begin
        if i = index'high then
            return index'low;
        else
            return i + 1;
        end if;
    end function;

begin

    -- Proceso de lógica de control (estado siguiente)
    process(write, read, s_empty, s_full)
    begin
        inc_head <= '0';
        inc_tail <= '0';

        if (write = '1' and s_full = '0') then
            inc_head <= '1';
        end if;

        if (read = '1' and s_empty = '0') then
            inc_tail <= '1';
        end if;
    end process;

    -- Proceso secuencial (actualización de estado)
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                head   <= 0;
                tail   <= 0;
                queue  <= (others => (others => '0'));
                output <= (others => '0');
            else
                if inc_head = '1' then
                    queue(head) <= input;
                    head <= incr(head);
                end if;

                if inc_tail = '1' then
                    output <= queue(tail);
                    tail <= incr(tail);
                end if;
            end if;
        end if;
    end process;

    -- Flags de estado
    s_empty <= '1' when head = tail else '0';
    s_full  <= '1' when incr(head) = tail else '0';

    -- Salidas
    empty <= s_empty;
    full  <= s_full;

end Behavioral;
