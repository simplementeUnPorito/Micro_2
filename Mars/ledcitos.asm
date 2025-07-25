



.data
#LED: 0xFFFF8000     # Dirección mapeada a los leds (solo para referencia)

.text
.globl main

main:
	li $a0,1

loopInfinito:
	jal blinkLeds
	move $a0, $v0
	jal delay1S
j loopInfinito




#BlinkLeds
#Funcion que hará que los leds se prendan
#prototipo en C
# unsigned int blinkLeds(led = a0)
# {
#    if(led == 1 || led == 2 || led == 4 o|| led == 8){
# 	if(led!=8)
#	 led = led<<1;
#       else
#        led = 1;
#       LED = led;
#    return led;
#    }
#   return 0;
#}
# 

blinkLeds:
if_valido:
#    if(led == 1 || led == 2 || led == 4 o|| led == 8){
	beq $a0,1, then_valido
	beq $a0,2, then_valido
	beq,$a0,4, then_valido
	beq,$a0,8, then_valido
else_valido:
	li $v0,0
	jr $ra
then_valido:
if_es_ocho:
	beq $a0,8,then_es_ocho
else_es_ocho:
	sll $a0,$a0,1
	j   fin_es_ocho
then_es_ocho:
	li  $a0,1
fin_es_ocho:
	li $t0, 0xFFFF8000
	sw $a0, 0($t0)
	move $v0,$a0
	jr $ra
#delay1S
delay1S:
    li $t0, 50000000         # 37.5 millones de iteraciones
     #li $t0, 2
delay_loop:
    addi $t0, $t0, -1	      #1 operacion
    bnez $t0, delay_loop      #1 operaciones
    jr $ra                    #1 operacion