# === Constantes ===
.eqv OUTPUT_ADDR    0xFFFF8000     # Dirección de los LEDs
.eqv INPUT_ADDR     0xFFFFD000     # Dirección de botones

.eqv MASK_INC       0x02           # Botón SUR = bit 1
.eqv MASK_RST       0x01           # Botón NORTE = bit 0

.eqv DELAY_N        50000          # Delay simple para evitar rebote

# === Registros simbólicos ===
.eqv CONT           $s0            # contador
.eqv IN_ADDR        $s1
.eqv OUT_ADDR       $s2
.eqv INPUT          $s3
.eqv LAST_INPUT     $s4

# === Temporales ===
.eqv TEMP           $t0
.eqv TEMP2          $t1
.eqv MASK_TEMP      $t2
.eqv DELAY_REG      $t3

.text
.globl main

main:
    li CONT, 0
    li IN_ADDR, INPUT_ADDR
    li OUT_ADDR, OUTPUT_ADDR
    li INPUT, 0
    li LAST_INPUT, 0

loop:
    # Leer botones
    lw TEMP, 0(IN_ADDR)

    # Detectar flanco de subida del botón INC (SUR, bit 1)
    li MASK_TEMP, MASK_INC
    and INPUT, TEMP, MASK_TEMP         # INPUT = TEMP & 0x02
    beq INPUT, LAST_INPUT, check_reset # Solo si hubo cambio

    # Confirmar flanco de subida (INPUT == 0x02 && LAST == 0x00)
    beq INPUT, $zero, skip_inc         # Si se soltó, no contar

    # Delay para rebote
    li DELAY_REG, DELAY_N
delay_loop:
    addiu DELAY_REG, DELAY_REG, -1
    bnez DELAY_REG, delay_loop

    # Releer para reconfirmar que sigue apretado
    lw TEMP, 0(IN_ADDR)
    and TEMP2, TEMP, MASK_INC
    beq TEMP2, $zero, skip_inc         # Se soltó, no contar

    # Incrementar
    addiu CONT, CONT, 1
    andi CONT, CONT, 0x0F              # Contador de 4 bits

skip_inc:
check_reset:
    li MASK_TEMP, MASK_RST
    and TEMP2, TEMP, MASK_TEMP
    beq TEMP2, $zero, save_and_write

    li CONT, 0                          # Resetear contador

save_and_write:
    move LAST_INPUT, INPUT
    sw CONT, 0(OUT_ADDR)

    j loop
