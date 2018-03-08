	INCLUDE 'MC9S08JM16.INC' 
	
LOCK	EQU		6; Verificar el enganche del reloj
		ORG 	0B0H; Direccion de memoria de variables	
CONTROL	DS	1; Definir control como variable con posiciones de memoria byte

		ORG		0C000H; Direccion de memoria para programa
INICIO:
		CLR		CONTROL; Limpiar control es bueno limpiar las variables 
		CLRA ;Limpiar acumulador
		STA		SOPT1; Desbilitar
		MOV		#40H,MCGC2; Que oscilador tomar
		MOV		#6,MCGC1; Divisor de frecuencia 
		BRCLR	LOCK,MCGSC,* ; Espere a que quede a 8 Mhz
		LDHX	#4B0H ;Reubicar pila
		TXS ;Lo que esta en x a la posicion de la pila
		
		MOV		#7FH,PTBDD ;PUERTO B SALIDA 6 PINES DE SALIDA LED1-LED6
		MOV		#7FH,PTCDD ;PUERTO C SALIDA 6 PINES DE SALIDA LED7-LED12
		MOV		#7FH,PTGDD ;PUERTO B SALIDA 6 PINES DE SALIDA LED13-LED16
		MOV		#7FH,PTFDD ;PUERTO F SALIDA 4 PINES DE SALIDA TIERRAS
		MOV		#00H,PTEDD ;PUERTO E NO-SALIDA 8 PINES DE 8 00H 
		LDA		#7FH
		STA		PTEPE ; PUERTO E ENTRADA
;------------CONFIGURACION TIERRAS----
