.data
v:    .asciiz    "abC"   
a:    .asciiz    "abc"

.text
    # Cargar direcciones de las cadenas
    la    $a0, v
    la    $a1, a
    li    $a2, 8
    jal   strncmp   # Llamada a la función
  
    # Imprimir el resultado de strncmp
    move  $a0, $v0   # Cargar el resultado de strncmp en $a0
    li    $v0, 1     # Código de syscall para imprimir un número entero
    syscall

    # Salir del programa
    li    $v0, 10
    syscall

   
# Memset: pone un valor en posiciones de memoria.
# Parámetros:
#     $a0 -> dirección de inicio de la memoria
#    $a1 -> valor a guardar+
#    $a2 -> cantidad de posiciones de memoria a escribir
# Retorno:
#    $v0 -> Dirección de inicio de la memoria
memset:
    move    $v0, $a0    # pongo el valor de retorno
memset_mientras:
    beq    $a2, $0, memset_finmientras
    sb    $a1, 0($a0)    # guardamos el valor
    addi    $a0, $a0, 1    # siguiente posición
    addi    $a2, $a2, -1    # número de posiciones -1
    j    memset_mientras
   
memset_finmientras:
    jr    $ra        # retornar
    
    
# Memcpy: Copia un vector a otro.
# Parámetros:
#	$a0 -> destino donde se copiaran los datos
#	$a1 -> origen de donde se copian los datos
#	$a2 -> cantidad de datos a copiar
# Retorno:
#	$v0 -> Dirección donde se copio 
# Temporales:
#	t0 -> Valor apuntado por a1
memcpy:
	move $v0,$a0 #Guardamos el valor de retorno
memcpy_mientras:
	beq $a2,$0, memcpy_finmientras
	lb  $t0, ($a1)		#obtenemos el valor apuntado por a1
	sb    $t0, 0($a0)    	# guardamos el valor en destino
	addi    $a0, $a0, 1    # siguiente posición destino
	addi    $a1, $a1, 1    # siguiente posición origen
    	addi    $a2, $a2, -1    # número de posiciones -1
    	j    memcpy_mientras

memcpy_finmientras:
	jr    $ra        # retornar
    
    
# strncmp: Compara n caracteres de un vector str1 con un vector str2.
# Prototipo en c
# int strncmp(char *str1,char *str2,size_t n){
#	char cmp = 0;
#	char char1,char2;
#	while(n--){
#		char1 = *str1++;
#		char2 = *str2++;
#		cmp = char1 - char2;
#		if(char1==0 ||char2 == 0 ||cmp!=0)
#			break;
#	}
#	return cmp;
#}
# Parámetros:
#	$a0(str1)  -> puntero a str1
#	$a1(str2)  -> puntero a str2
#	$a2(n)     -> cantidad de datos a copiar
# Retorno:
#	$v0(cmp)   -> diferencia entre el primer caracter de str1 que sea distinto a str2
# Temporales:
#	$t0(char1) -> caracter almacenado en str1
#	$t1(char2) -> caracter almacenado en str2
strncmp:
	#char cmp = 0;
	move $v0,$zero 
#while(n--)
strncmp_mientras: 
	beqz $a2,strncmp_finmientras
	addi $a2,$a2,-1
	#char1 = *str1++;
	lb  $t0, 0($a0)
	addi $a0,$a0,1
	#char2 = *str2++;
	lb  $t1, 0($a1)
	addi $a1,$a1,1
	#cmp = char1 - char2;
	sub $v0,$t0,$t1
	#if(char1==0 ||char2 == 0 ||cmp!=0) break;
	beqz $t0,strncmp_finmientras
	beqz $t1,strncmp_finmientras
	bnez $v0,strncmp_finmientras
	
	j strncmp_mientras
strncmp_finmientras:
	#return cmp;
	jr    $ra        
