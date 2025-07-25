.data
pedirDist:    .asciiz "Introduzca la distancia de la Diana: \n"
pedirAng:   .asciiz "Introduzca el angulo para lanzar: \n"
pedirVel:      .asciiz "Introduzca la velocidad para lanzar: \n"
ganaste:     .asciiz "Ganaste.\n"
perdiste:    .asciiz "Perdiste\n"
again:     .asciiz "Intenta nuevamente, te alejaste un total de: "
f_neg_0_1: .float -0.1
f_pos_0_1: .float 0.1
PI:	   .float 3.14
GRAVEDAD: .float 9.8
float_90: .float 90.0
float_1: .float 1

.text

.eqv arg_f $f0
.eqv arg_i $a0
.eqv result_f $f0
.eqv result_i $v0
.eqv intentosRestantes $s0
.eqv MAX_INTENTOS 5
.eqv distancia $f31
.eqv velocidad $f30
.eqv angulo    $f29
.eqv aux0      $f28
.eqv aux1      $f27
.eqv aux2      $f26
.eqv lanzamiento $f25
.eqv diferencia $f24
.eqv porcentaje_diferencia $f23
.eqv constante $f22
.eqv num       $f21
.eqv den       $f20
.eqv powerN    $t0
.eqv n         $t1
.eqv arg_seno  $f19
.eqv result_seno $f18
.macro push(%reg)
	addi $sp, $sp, -4     # Reservar espacio (bajar stack pointer)
	sw %reg, 0($sp)        # Guardar el valor de $t0 en la cima de la pila
.end_macro
.macro pop(%reg)
	lw %reg, 0($sp)        # Recuperar dato a $t0
	addi $sp, $sp, 4      # Liberar espacio (subir $sp)

.end_macro
.macro puts(%string)
	li $v0,4
	la $a0, %string
	syscall
.end_macro

.macro scanf(%float)
    	li $v0, 6
    	syscall
    	mov.s %float, $f0
.end_macro
.macro fin_programa()
	li $v0,10
	syscall
.end_macro
.macro printf(%float)
	li $v0,2
	mov.s $f0,%float
	syscall
	
.end_macro
.globl main
main:
	#    i = MAX_INTENTOS;
	li intentosRestantes, MAX_INTENTOS
	#   puts("Introduzca la distancia de la Diana: ");
	puts(pedirDist)
	#    scanf("%f", &d);
	scanf(distancia)
	#   while(i > 0)==> while(!(i<=0)
	while_main:
	blez intentosRestantes,	end_while_main
		#        puts("Introduzca el angulo para lanzar: ");
		puts(pedirAng)
		#        scanf("%f", &a);
		scanf(angulo)
		#        puts("Introduzca la velocidad para lanzar: ");
		puts(pedirVel)
		#        scanf("%f", &v);
		scanf(velocidad)
		#        calcularDist();
		jal calcularDist
		#        aux1 = d - d_lanzada;
		sub.s diferencia,distancia,lanzamiento
		#        aux1 = aux1 / d;
		div.s porcentaje_diferencia,diferencia,distancia
		#        if(aux1 >= -0.1) ==> if(!(aux1<-0.1))
		if_main_1:
		l.s constante,f_neg_0_1
		c.lt.s porcentaje_diferencia, constante
		bc1f end_if_main_1
			#            if(aux1 <= 0.1)
			if_main_2:
			l.s constante, f_pos_0_1
			c.le.s porcentaje_diferencia,constante
			bc1f end_if_main_2
				#                puts("ganaste.");
				puts(ganaste)
				#                return 0;
				fin_programa()
			end_if_main_2:
		end_if_main_1:
		#        puts("Intenta nuevamente.");
		puts(again)
		printf(diferencia)
		#        i = i - 1;
		addi intentosRestantes,intentosRestantes,-1
	j while_main
	end_while_main:
	#    puts("Perdiste");
	puts(perdiste)
	#    return 0;
	fin_programa()
	

calcularDist:
	push($ra)
	#    aux1 = power(v, 2);
	li arg_i,2
	mov.s arg_f,velocidad
	jal power
	mov.s aux0,result_f 
	#    aux2 = PI * a;
	l.s aux1, PI
	#    aux2 = PI * a;
	mul.s aux1, aux1,angulo
	#    aux2 = aux2 / 90;
	l.s aux2, float_90
	div.s aux1,aux1,aux2
	#    aux3 = seno_taylor(aux2, 3);
	li arg_i,15
	mov.s arg_f,aux1
	jal seno_taylor
	mov.s aux2,result_f
	#    d_lanzada = aux1 * aux3;
	mul.s lanzamiento, aux0,aux2
	#    d_lanzada = d_lanzada / GRAVEDAD;
	l.s aux0,GRAVEDAD
	div.s lanzamiento,lanzamiento,aux0
	pop($ra)
	jr $ra

power:
	#    result = 1;
	push(aux0)
	push(arg_i)
	mov.s aux0,arg_f
	l.s result_f,1
	#    while(n > 0) ==> while(!(n<=0))
	while_power:
	blez arg_i end_while_power
		#  result = result * arg;
		mul.s result_f,result_f,aux0
		# n = n - 1;
		addi arg_i,arg_i,-1
	end_while_power:
	#    return result;
	pop(arg_i)
	pop(aux0)
	jr $ra

factorial:
	push(arg_i)
	#    result = 1;
	l.s result_i,1
	#    while(n > 1) ==> !(n<1)
	while_factorial:
	blt arg_i,1,end_while_factorial
		#        result = result * n;
		mult result_i,result_i,arg_i
		mflo result_i
		#        n = n - 1;
		addi arg_i,arg_i,-1
	j while_factorial
	end_while_factorial:
	#    return result;
	pop(arg_i)
	jr $ra

seno_taylor:
	push($ra)
	li result_seno,0
	mov.s arg_seno, arg_f
	while_seno_taylor:
		sll powerN,n,1
		addi powerN,powerN,1
		move arg_i,powerN
		mov.s arg_f, arg_seno
		jal seno_taylor
		mov.s num, result_f
		move arg_i,poweN
		jal factorial
		mtc1 result_i,den
		cvt.s.w den,den
		div.s num,num,den
		li $t4, 2
		div result_i,$t4
		mfhi result_i
		bnez den, seno_taylor_par
			l.s den,-1
			mul.s num,num,den
		seno_taylor_par:
		add.s result_seno,result_seno,num
	j while_seno_taylor
	end_while_seno_taylor:
	pop($ra)
	jr $ra
	
	