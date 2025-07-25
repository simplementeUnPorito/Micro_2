	.data
	.eqv	SEG60MHZ	60000000
	.eqv	SEG120MHZ	120000000
	.text
#	int cont = 0;
#	while (1){
#		mostrar(cont);
#		esperar(1seg);
#		cont++;
#		if (cont > 15) cont = 0;
#	}
 	addi	$s0, $0, 0	# $s0 es cont
 	lui	$s1, 0xFFFF
 	ori	$s1, $s1, 0x8000 # dirección de salida
 while:
 	# mostrar contador
 	sw 	$s0, 0($s1)
 	# esperar 1 seg
 	#lui	$t1, 0x262
 	#ori	$t1, $t1, 0x5a00 # contador de segundos
 	li	$t1, SEG60MHZ
while2:
 	beq	$t1, $0, finwhile2
 	addi	$t1, $t1, -1
 	j	while2
 finwhile2:
 	addi	$s0, $s0, 1	# cont++
 	ble	$s0, 15, finsi
 	add	$s0, $0, $0
 finsi:
 	j	while
