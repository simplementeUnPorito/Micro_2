.data
    uno:     .double 1.0
    dato:   .double 3.0

.text
.globl main
main:
	l.d $f10,dato
	jal     factorial
	li      $v0, 3      # syscall para imprimir double
    	mov.d   $f12, $f0
    	syscall
	# Salir
    	li      $v0, 10
    	syscall


#factorial(%f10-f11->n)=>$f0-1->result
factorial:
	l.d $f0,uno
	c.le.d $f10,$f0
	bc1t return_factorial
	mov.d $f2,$f0
	while_factorial:
	c.lt.d $f2,$f10
	bc1f return_factorial
		mul.d $f0,$f0,$f10
		sub.d $f10,$f10,$f2
	j while_factorial
return_factorial:
	jr $ra