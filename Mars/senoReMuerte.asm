# Primera parte: Segmento .data y etiquetas necesarias
.data
pedirDist:    .asciiz "Introduzca la distancia de la Diana: \n"
pedirAng:     .asciiz "Introduzca el angulo para lanzar: \n"
pedirVel:     .asciiz "Introduzca la velocidad para lanzar: \n"
ganaste:      .asciiz "Ganaste.\n"
perdiste:     .asciiz "Perdiste\n"
again:        .asciiz "Intenta nuevamente, te alejaste un total de: "
f_neg_0_1:    .float -0.1
f_pos_0_1:    .float 0.1
PI:           .float 3.14
GRAVEDAD:     .float 9.8
FLOAT_90:     .float 90.0
FLOAT_1:      .float 1.0


# Segunda parte: Segmento .text y macros
.text
.globl main

# Alias
.eqv MAX_INTENTOS 5

# Macros
.macro puts(%str)
    li $v0, 4
    la $a0, %str
    syscall
.end_macro

.macro read_float(%freg)
    li $v0, 6
    syscall
    mov.s %freg, $f0
.end_macro

.macro print_float(%freg)
    li $v0, 2
    mov.s $f12, %freg
    syscall
.end_macro

.macro exit_program()
    li $v0, 10
    syscall
.end_macro

# Función: power_v2 - calcula base^exp usando multiplicaciones
# Entrada: $f12 = base (float), $a0 = exp (int)
# Salida: $f2 = resultado
power_v2:
    li $t0, 1          # resultado entero inicializado a 1
    li $t1, 0          # contador
    mtc1 $t0, $f2      # resultado en float = 1.0
    cvt.s.w $f2, $f2
    mtc1 $a0, $f4      # copiar exp para comparación
    cvt.s.w $f4, $f4
    blez $a0, end_power_v2
pow_loop:
    mul.s $f2, $f2, $f12
    addi $a0, $a0, -1
    bgtz $a0, pow_loop
end_power_v2:
    jr $ra

# factorial (entero)
# Entrada: $a0 = n
# Salida: $v0 = resultado
factorial:
    li $v0, 1
    li $t1, 1
factorial_loop:
    ble $a0, 1, factorial_end
    mul $v0, $v0, $a0
    addi $a0, $a0, -1
    j factorial_loop
factorial_end:
    jr $ra

# seno_taylor (apróx de sin(x)) usando 5 términos
# Entrada: $f12 = ángulo en radianes
# Salida: $f2 = sin(x)
seno_taylor:
    li $t1, 0              # n = 0
    li $t2, 5              # términos
    li $v0, 0              # limpiamos por si acaso
    li $t4, 1              # (-1)^n
    li $t5, 2              # para mod 2
    mtc1 $zero, $f2
    cvt.s.w $f2, $f2       # resultado acumulado = 0.0
seno_loop:
    bge $t1, $t2, seno_fin
    sll $t3, $t1, 1        # powerN = 2n
    addi $t3, $t3, 1       # powerN = 2n + 1
    move $a0, $t3
    mov.s $f14, $f12       # x
    jal power_v2
    mov.s $f6, $f2         # num = x^(2n+1)
    move $a0, $t3
    jal factorial
    mtc1 $v0, $f8
    cvt.s.w $f8, $f8       # den = factorial
    div.s $f6, $f6, $f8    # num = num / den
    rem $t6, $t1, $t5
    beqz $t6, seno_pos
    neg.s $f6, $f6
seno_pos:
    add.s $f2, $f2, $f6
    addi $t1, $t1, 1
    j seno_loop
seno_fin:
    jr $ra

main:
    li $s0, MAX_INTENTOS
    puts(pedirDist)
    read_float($f1)             # distancia objetivo

main_loop:
    blez $s0, game_over
    puts(pedirAng)
    read_float($f2)             # angulo
    puts(pedirVel)
    read_float($f3)             # velocidad

    # Calcular distancia del disparo
    mov.s $f4, $f3              # v
    jal power_v2
    mov.s $f6, $f0              # aux1 = v^2

    l.s $f7, PI
    mul.s $f7, $f7, $f2         # aux2 = PI * a
    l.s $f8, FLOAT_90
    div.s $f7, $f7, $f8         # aux2 = aux2 / 90

    mov.s $f12, $f7
    li $a0, 7                   # términos seno
    jal seno_taylor
    mov.s $f9, $f0              # aux3 = seno(PI*a/90)

    mul.s $f10, $f6, $f9        # d_lanzada = aux1 * aux3
    l.s $f11, GRAVEDAD
    div.s $f10, $f10, $f11

    # Comparar d_lanzada con distancia
    sub.s $f20, $f1, $f10       # diferencia = d - d_lanzada
    div.s $f21, $f20, $f1       # porcentaje = diferencia / d

    l.s $f22, f_neg_0_1
    c.lt.s $f21, $f22
    bc1t not_close

    l.s $f23, f_pos_0_1
    c.le.s $f21, $f23
    bc1t you_win

not_close:
    puts(again)
    print_float($f20)
    addi $s0, $s0, -1
    j main_loop

you_win:
    puts(ganaste)
    exit_program()

game_over:
    puts(perdiste)
    exit_program()

