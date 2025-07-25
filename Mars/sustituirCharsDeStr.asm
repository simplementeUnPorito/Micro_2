.macro printString(%string)
	la $a0, %string
	li $v0,4
	syscall
.end_macro

.macro terminate
	li $v0,10
	syscall
.end_macro

.data
	string: .asciiz "hola que tal como estas"

.text
.eqv dir $a0
.eqv char_old $a1
.eqv char_new $a2
.globl main
main:
	la dir, string
	li char_old, 'a'
	li char_new, 'A'
	jal str_sustitute
	printString(string)
	terminate













.eqv char_value $t0
.eqv null	0
str_sustitute:
	lb char_value, 0(dir)
	beq char_value, null ,str_sustitute_end
		addi dir,dir, 1
		bne char_value,char_old,str_sustitute #no hay que sustituir, saltamos
			sb char_new, -1(dir)
			 
	j str_sustitute
str_sustitute_end:
	jr $ra