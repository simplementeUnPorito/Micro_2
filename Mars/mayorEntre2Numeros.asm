.eqv syscallCode $v0
.eqv result      $v0
.eqv arg	 $a0
.macro getIntInto(%regDest)
	li syscallCode, 5
	syscall
	move %regDest, result
.end_macro

.macro printString(%string)
	la arg, %string
	li syscallCode, 4
	syscall
.end_macro

.macro terminate
	li syscallCode, 10
	syscall
.end_macro

.macro printInt(%reg)
	move arg, %reg
	li syscallCode,1
	syscall
.end_macro

.data
	askn0: .asciiz "Ingrese el primer numero: "
	askn1: .asciiz "Ingrese el segundo numero: "
	answerB: .asciiz "El numero mayor entre los 2 ingresados es: "
	answerE: .asciiz "Ambos numeros son iguales."
.text
	.globl main
	.eqv n0 $t0
	.eqv n1 $t1
	.eqv nmax $t2
main:
	printString(askn0)
	getIntInto(n0)
	
	printString(askn1)
	getIntInto(n1)
	
	
	bgt n1,n0, main_n1GTn0
	bgt n0,n1, main_n0GTn1
main_n1EQn0:
	printString(answerE)
	j main_endOfProgram
main_n1GTn0:
	printString(answerB)
	printInt(n1)
	j main_endOfProgram
main_n0GTn1:
	printString(answerB)
	printInt(n0)
	j main_endOfProgram
main_endOfProgram:
	terminate