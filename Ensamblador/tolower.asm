.data
c:    .byte    'A'   
dist: .byte	32
.text
    # Cargar valor
    lb    $a0, c
    jal   tolower   # Llamada a la función
  
    # Imprimir el resultado
    move  $a0, $v0  
    li    $v0, 11   
    syscall

    # Salir del programa
    li    $v0, 10
    syscall
    

    
# tolower: si recibe un caracter en mayuscula, retorna su minuscula.
#prototipo en C:
#	int tolower (int c){
#		int r = c;
#		if('A'<=c && c<='Z')
#			r = r+'a'-'A';  //'a'-'A' es igual a 32
#		return r;
#	}
# Parámetros:  
#	$a0(c) -> caracter entrante
# Retorno:
#	$v0(r) -> caracter salida  

tolower:
	#int r = c;
	move $v0,$a0
	#if('A'<=c && c<='Z') -> if(!(c<'A') || !(c>'Z))
	blt $v0,'A',tolower_return
	bgt $v0,'Z',tolower_return
	#r = r+'a'-'A';  //'a'-'A' es igual a 32
	addi $v0,$v0,32
tolower_return:
	#return r;
	jr $ra
	