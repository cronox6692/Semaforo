	INCLUDE 'MC9S08JM16.INC' 
	
LOCK	EQU		6; Verificar el enganche del reloj
LEDV	EQU     0
LEDA    EQU     1
LEDR    EQU     2

		ORG 	0B0H; Direccion de memoria de variables	

AUTOSET DS 1
V1      DS 1
A1      DS 1
R1      DS 1 
V2 		DS 1
AUX     DS 1
CONT    DS 1 

		ORG		0C000H; Direccion de memoria para programa
INICIO:
		CLRA 				      ;Limpiar acumulador
		STA		SOPT1		      ;Desbilitar
		LDHX	#4B0H 		      ;Reubicar pila
		TXS 			          ;Lo que esta en x a la posicion de la pila
		MOV		#0AAH,MCGTRM;	
		MOV		#6,MCGC1		  ;Ajuste frecuencia del oscilador interno
		BRCLR	LOCK,MCGSC,*      ;Espere a que el oscilador se enganche
		MOV		#00011100B,PTBDD  ;PUERTO B SALIDA 3 PINES DE SALIDA   
		LDA		#00000011B        ;PARA RESISTENCIA DE PULL-UP  00011000
		STA		PTBPE 			  ;PUERTO E ENTRADA /


		CLR 	AUTOSET           ;--------------------------
		MOV 	#6H, V1
		MOV 	#5H, AUX           ; Valores de la secuencia 1
		MOV 	#4H, R1
		MOV 	#2H, V2           ;--------------------------
		
LOOP:	JSR     S_SEM 
		LDA 	PTBD
		AND 	#00000011B
		CBEQA   #0H,LOOP		  ;Lee el puerto si se oprime un AUTO sigue a 
		CBEQA   #3H,LOOP          ;SALTO_1 si se oprimer TEMP salta SALTO_2
		CBEQA   #2H,SALTO_A       ;-------------------------
		;SI ES IGUAL A 1 SIGUE
SALTO_M:LDA 	PTBD              ;-------------------------
		AND 	#00000011B		  ; se hace un ciclo while infinito hasta que
		CBEQA   #3H,AUTO          ; se suelte el boton AUTO
		JMP     SALTO_M           ;----------------

AUTO:	MOV     #1H,AUTOSET       ; una vez se suelta el boton se carga autoset con 1
		JMP     LOOP              ; regresa a verificar entradas

SALTO_A:LDA 	PTBD              ;-----------------------------------
		AND 	#00000011B        ; Se hace un ciclo while infinito hasta que 
		CBEQA   #3H,VALORES		  ; se suelte el boton TEMP
		JMP     SALTO_A           ;-----------------------------------------

VALORES:LDA     V1                ; Carga en acomulador el valor de V1
		CBEQA   #6,VALORES_2      ; Si el tiempo de verde es 6s salta a rutina 
		MOV 	#6H, V1
		MOV 	#5H, AUX
		MOV 	#4H, R1
		MOV 	#2H, V2
		JMP     LOOP
		
VALORES_2:MOV 	#4H, V1
		MOV 	#4H, AUX
		MOV 	#6H, R1
		MOV 	#3H, V2
		JMP     LOOP
		
;--------------------------------------------------------------
;-----------------SUBRUTINA SEMAFORO---------------------------
;--------------------------------------------------------------
S_SEM:  LDA      AUTO
	    CBEQA    #1,MANUAL
	    BSET     LEDV,PTBD
	    LDA      V1
	    JSR      SUB_T
	    BCLR     LEDV,PTBD
	    LDA      A1
	    JSR      SUB_P 
	    LDA      R1
	    BSET     LEDR,PTBD
	    JSR      SUB_T
	    BCLR     LEDR,PTBD
	    JSR      SUB_T
	    BSET     LEDV,PTBD
	    BSET     LEDA,PTBD
	    LDA      V2
	    JSR      SUB_T
	    BCLR     LEDV,PTBD
	    BCLR     LEDA,PTBD
	    RTS                         ; RETORNA A LOOP
	    
MANUAL:

		RTS	                        ; RETORNA A LOOP
		
;--------------------------------------------------------------
;-----------------SUBRUTINA TIEMPO---------------------------
;--------------------------------------------------------------
SUB_T:	LDX     #20         ; Carga x con 20
		MUL                 ; se multiplica Acomulador con 20 para obtener tiempo en S
TIEMPO: LDHX    #50000D     ; Tiempo de 50ms
CICLOT: AIX		#-1         ; pierde tiempo
		CPHX	#0          ; compara HX con 0
		BNE		CICLOT      ; Si hx es igual a 0 sigue
		DBNZA   TIEMPO      ; si acomulador es igual a 0 sigue 
		RTS                 ; retorna
;--------------------------------------------------------------
;-----------------SUBRUTINA PARPADEO---------------------------
;--------------------------------------------------------------
	
SUB_P:  LDA     AUTO        ; carga valor de auto 
		CBEQA   #1,P_M      ; pregunta valor de auto (modo)
		LDA     #1          ; carga acomulador con 1 para 1s
CICLO_P:BSET    LEDA,PTBD   ; prende led amarillo
		JSR     SUB_T       ; espera 1s
		BCLR    LEDA,PTBD   ; apaga led amarillo
		JSR     SUB_T       ; espera 1s
		DBNZ    AUX,CICLO_P ; pregunta cantidad de parpadeos , si faltan salta
		RTS
		
P_M:    LDA     #1          ; carga acomulador con 1 para 1s
		BSET    LEDA,PTBD   ; Prende amarillo
		JSR     SUB_T       ; espera 1s
		BCLR    LEDA,PTBD   ; apaga led amarillo
		JSR     SUB_T       ; espera 1s
        LDA 	PTBD        ; lee puerto B
		AND 	#00000011B  ; Enmascarar 
		CBEQA   #0H,P_M	    ; Si no oprime nada sigue parpadeando
		CBEQA   #3H,P_M     ; si oprime los dos pulsadores sigue parpandeando
		CBEQA   #1H,REG
		;SI ES IGUAL A 2
SOST_P: LDA 	PTBD              
		AND 	#00000011B        
		CBEQA   #3H,SOLT_P 
		JMP     SOST_P           
SOLT_P: LDA     #1
		ADD     CONT
		STA     CONT        
		RTS                       ; RETORNA A SUBRUTINA SEMAFORO
REG:    LDA 	PTBD              ;-----------------------------------
		AND 	#00000011B        ; Se hace un ciclo while infinito hasta que 
		CBEQA   #3H,AUTO_REG	  ; se suelte el boton TEMP
		JMP     REG               ;-----------------------------------------
AUTO_REG:
		MOV     #0H,AUTOSET       ; una vez se suelta el boton se carga autoset con 1
		RTS                       ; regresa a subrutina semaforo
		
		ORG     0FFFFEH
		FDB		INICIO

	
		
		
		
		
		
		
		
;------------CONFIGURACION TIERRAS----
