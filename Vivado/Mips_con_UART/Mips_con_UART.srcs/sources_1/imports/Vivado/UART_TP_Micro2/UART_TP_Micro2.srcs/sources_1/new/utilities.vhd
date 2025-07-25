-- utilities.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;

package utilities is
  type state_r is (IDLE, START, READ, STOP);
  type state_t is (IDLE, START, SEND, STOP);

  -- Ejemplo de generic compartido como constante
  constant DATA_WIDTH : natural := 8;
  constant QUEUE_LEN  : natural := 8;
  constant TICKS_PER_DATA : natural := 128;
  constant BITS_DIVISOR: natural := 6;
  constant TICKS_FOR_STOP : natural := TICKS_PER_DATA;

  -- Declaración de una función
  --function suma_logica(a, b : std_logic) return std_logic;
  function minBitsRequired(n : natural) return natural;
  function max(a, b : natural) return natural;

  -- Declaración de un procedimiento
  --procedure imprimir_vector(signal v : in std_logic_vector);

end package utilities;


package body utilities is

  --function suma_logica(a, b : std_logic) return std_logic is
  --begin
    --return a or b;
    --end function;
      function minBitsRequired(n : natural) return natural is
      begin
        return natural(ceil(log2(real(n))));
      end function;
      
      
      function max(a, b : natural) return natural is
      begin
        if a > b then
          return a;
        else
          return b;
        end if;
      end function;      
    --procedure imprimir_vector(signal v : in std_logic_vector) is
    --begin
    -- Esto es solo ejemplo: en simulación, se puede usar 'report'
      --report "Vector: " & to_string(v);
    --end procedure;

end package body utilities;