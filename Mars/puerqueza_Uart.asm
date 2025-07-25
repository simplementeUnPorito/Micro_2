.eqv UART_CTRL_ADDR   0xFFFFC000
.eqv UART_RX_ADDR     0xFFFFC001
.eqv UART_TX_ADDR     0xFFFFC002
.eqv UART_FLAGS_ADDR  0xFFFFC003
.eqv LEDS_ADDR        0xFFFF8000

.eqv MASK_EN_TX_WRITE 0x01
.eqv MASK_EN_RX_READ  0x02
.eqv MASK_RX_EMPTY    0x01
.eqv MASK_TX_FULL     0x08

.eqv BPS9600          40

.eqv ENTER            0x0A
.eqv CR               0x0D


.text
.macro cargarBPS(%reg_val)
    li $t0, UART_CTRL_ADDR
    lb $t1, 0($t0)

    sll %reg_val, %reg_val, 2        # desplazar a bits [7:2]
    andi $t1, $t1, 0x03              # mantener solo flags
    or $t1, $t1, %reg_val
    sb $t1, 0($t0)
.end_macro

.macro uartSetBit(%mask_val)
    li $t0, UART_CTRL_ADDR
    lb $t1, 0($t0)

    ori $t1, $t1, %mask_val
    sb $t1, 0($t0)

    li $t2, %mask_val
    nor $t2, $t2, $zero
    and $t1, $t1, $t2
    sb $t1, 0($t0)
.end_macro

.macro leerFlags(%dest)
    li $t0, UART_FLAGS_ADDR
    lb %dest, 0($t0)
.end_macro

.macro leerRX(%dest)
    li $t0, UART_RX_ADDR
    lb %dest, 0($t0)
.end_macro

.macro escribirTX(%src)
    li $t0, UART_TX_ADDR
    sb %src, 0($t0)
.end_macro

.macro mostrarEnLEDs(%src)
    li $t0, LEDS_ADDR
    sw %src, 0($t0)
.end_macro


main:
    # Inicializar velocidad
    li $s0, BPS9600
    cargarBPS($s0)

    li $s1, 0  # Dato recibido
    li $s2, 0  # FLAGS

loop:
    leerFlags($s2)
    andi $t1, $s2, MASK_RX_EMPTY
    bne $t1, $zero, loop

    uartSetBit(MASK_EN_RX_READ)
    leerRX($s1)
    mostrarEnLEDs($s1)
    #a<=s1 and s1<=z ==> !s1<a and !z<s1
    li $t1,'a'
    slt $t0,$s1,$t1 #s1<a?
    bne $t0,$0,wait_tx  #saltar si el valor esta por debajo de 'a'
     #el valor esta por encima de a
    li $t1,'z'
    slt $t0,$t1,$s1
    bne $t0,$0,wait_tx #saltar si el valor esta por encima de 'z'
    #el valor esta por debajo de z 
    addi $s1,$s1,-32 #restamos 20 para pasar a mayusculas
     
wait_tx:
    leerFlags($s2)
    andi $t1, $s2, MASK_TX_FULL
    bne $t1, $zero, wait_tx
    escribirTX($s1)
    uartSetBit(MASK_EN_TX_WRITE)
    bne $s1,CR,loop
    li  $s1, ENTER
send_enter:
    leerFlags($s2)
    andi $t1,$s2,MASK_TX_FULL
    bne $t1,$zero,send_enter
    escribirTX($s1)
    uartSetBit(MASK_EN_TX_WRITE)
    j loop

