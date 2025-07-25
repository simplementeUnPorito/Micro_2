.macro char_print(%r)
	#addi	$sp,$sp,-4
	#sw	$a0
	
	li	$v0,11
	move	$a0,%r
	syscall
	
	#lw	$a0, 0($sp)
	#addi	$sp,$sp,4
.end_macro

.macro char_printi(%c)
	#addi	$sp,$sp,-4
	#sw	$a0
	
	li	$v0,11
	li	$a0,%c
	syscall
	
	#lw	$a0, 0($sp)
	#addi	$sp,$sp,4
.end_macro

.macro int_print(%r)
	#addi	$sp,$sp,-4
	#sw	$a0
	
	li	$v0,1
	move	$a0,%r
	syscall
	
	#lw	$a0, 0($sp)
	#addi	$sp,$sp,4
.end_macro


.macro st_print (%string)
	#addi	$sp,$sp,-4
	#sw	$a0
	
	li	$v0,4
	la	$a0,%string
	syscall
	
	#lw	$a0, 0($sp)
	#addi	$sp,$sp,4
.end_macro

.macro int_scan (%r)
	li	$v0,5
	syscall
	move	%r,$v0
.end_macro

.data
	solicitud:	.asciiz	"Ingrese un numero: "
#prototipo en c
#	int t0,t1,t2;
#	int main(){
#		printf("Ingrese un numero: ");
#	 	scanf("%i",&t0);
#		t1 = 1;
#		while(t1<=t0){
#			t2 = 1;
#			repetir:
#			printf("%i ",t2);
#			if(t2<t1){
#				t2++;
#				goto repetir;}
#			printf("\n");
#			t1++;
#		}
#		return 0;
#	}
.text
	
	st_print 	solicitud		#printf("Ingrese un numero: ");
	int_scan	$t0			#scanf("%i",&t0);
	li		$t1,1			#t1 = 1;
	while:
		bgtu	$t1,$t0,end_while	#while(t1<=t0)=>while(!(t1>t0))
		li	$t2,1			#2 = 1;
		repetir:
		int_print	$t2		#printf("%i ",t2);
		char_printi	' '
		bgeu		$t2,$t1,end_if	#if(t2<t1)=>if(!(t2>=t1))
			addi	$t2,$t2,1	#t2++
			j	repetir		#goto	repetir;
		end_if:
		li	$t2,'\n'		#printf("\n");
		char_print	$t2		
		addi		$t1,$t1,1	#t1++
	j		while	
end_while:
	li	$v0, 10				#return 0;
	syscall
	

	
