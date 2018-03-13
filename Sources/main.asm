	INCLUDE 'MC9S08JM16.INC' 
	
LOCK	EQU		6; Verificar el enganche del reloj
		ORG 	0B0H; Direccion de memoria de variables	

AUTOSET DS 1
V1      DS 1
A1      DS 1
R1      DS 1 
V2 		DS 1

		ORG		0C000H; Direccion de memoria para programa
INICIO:

		CLRA 				      ;Limpiar acumulador
		STA		SOPT1		      ;Desbilitar
		LDHX	#4B0H 		      ;Reubicar pila
		TXS 			          ;Lo que esta en x a la posicion de la pila
		MOV		#0AAH,MCGTRM;	
		MOV		#6,MCGC1		  ;Ajuste frecuencia del oscilador interno 
		BRCLR	LOCK,MCGSC,*      ;Espere a que el oscilador se enganche
		MOV		#07H,PTBDD        ;PUERTO B SALIDA 3 PINES DE SALIDA   00000111
		LDA		#00011000         ;PARA RESISTENCIA DE PULL-UP  00011000
		STA		PTBPE 			  ;PUERTO E ENTRADA /


		CLR 	AUTOSET 
		MOV 	#6H, V1
		MOV 	#5H, A1
		MOV 	#4H, R1
		MOV 	#2H, V2
		
LOOP:	JSR     SUBRUTINA_SEMAFORO
		LDA 	PTBD
		AND 	#00011000
		
		
		
		
;------------CONFIGURACION TIERRAS----
