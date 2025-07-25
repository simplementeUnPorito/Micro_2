.macro printInt(%reg)
	move $a0, %reg
	li   $v0, 1
	syscall
.end_macro



.data
matrix: .word	1,2,3
	    	4,5,6
	    	7,8,10
.text
.eqv dir $a0
.eqv N	 $a1
.eqv result $v0
main:
	la dir,matrix
	li N, 3
	jal sumDiag
	printInt(result)
	li $v0,10
	syscall
	

#Cada elemento de la matriz M(x,y) = *(M+x+N*y) 
#donde N es el orden de la matriz
#la diagonal es cuando x e y son iguales, M(x,y) = *(M+n+N*n) = *(M+n*(N+1)) 
.eqv N1 $t0
.eqv element $t1
.eqv diagDir $t2
sumDiag:
	add N1, N, 1
	li  result, 0
sumDiag_loop:
	beq  N,$0,sumDiag_endLoop
	addi N,N, -1
	mul  diagDir, N1, N
	sll  diagDir,diagDir,2
	add  diagDir, diagDir, dir
	lw   element, 0(diagDir)
	add  result, result, element
	j sumDiag_loop
sumDiag_endLoop:
	jr $ra
	
