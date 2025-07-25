.eqv RESULT $v0
.eqv N   $a0
.eqv TEMP $t0

.macro printString (%string)
	la $a0, %string
	li $v0, 4
	syscall
.end_macro

.macro printInt (%reg)
	move $a0, %reg
	li $v0, 1
	syscall
.end_macro

.macro getInt
	li $v0,5
	syscall
.end_macro

.macro terminate
	li $v0,10
	syscall
.end_macro

.data
	question: .asciiz  "Elija un numero para sumar hasta ahí: "
	answer:   .asciiz  "\nLa suma resulta en: "

.text
.globl main
main:
	printString(question)
	getInt
	move N, RESULT
	jal sumaN
	move TEMP, RESULT
	printString(answer)
	printInt(TEMP)
	terminate
	
sumaN:
	li RESULT, 0
sumaN_loop:
	add RESULT, RESULT, N
	addi N, N, -1
	bgtz N, sumaN_loop
	jr $ra
