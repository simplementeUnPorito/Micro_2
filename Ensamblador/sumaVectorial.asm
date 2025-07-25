.macro	incr (%reg,%n)
	addi %reg, %reg, %n
.end_macro


.data

N: .word	5
A: .word 	1, 2, 3,4,5
B: .word 	2,-3,-5,6,1
C: .space 	5		
	       #3,-1,-2,10,6


.text
	la	$a0, A
	la	$a1, B
	la	$a2, C
	lw	$a3, N
	jal	vsum   # Llamada a la función
	
	# Salir del programa
    	li    $v0, 10
    	syscall



#vsum: Suma vectorial de 2 sumandos
#Prototipo en C:
#	void vsum(int* A,int* B,int* C,unsigned int N)
#	{
#		int t0,t1,t2;
#		while(N--){
#			t0 = *A++;
#			t1 = *B++;
#			t2 = t0+t1;
#			*C++ = t2;	
#		}
#		return;
#	}
#Parámetros:
#	$a0(*A) -> Vector A (primer sumando)
#	$a1(*B) -> Vector B (segundo sumando)
#	$a2(*C) -> Vector C (Suma)
#	$a3(N)  -> longitud N
#Retorno:
#	ninguno -> Se carga el resultado en C
vsum:
	#while(N--){
vsum_mientras:
	beqz	$a3, vsum_finmientras
	addi	$a3, $a3, -1
	#t0 = *A++;
	lw	$t0, 0($a0)
	incr	$a0, 4
	#t1 = *B++;
	lw	$t1, 0($a1)
	incr	$a1, 4
	#t2 = t0+t1;
	add	$t2, $t1, $t0
	#*C++ = t2;
	sw	$t2, ($a2)
	incr	$a2, 4
	j    vsum_mientras
vsum_finmientras:
	#return;
	jr    $ra