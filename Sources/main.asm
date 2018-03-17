	INCLUDE 'MC9S08JM16.INC' 
	
LOCK	EQU		6    ; Verificar el enganche del reloj
LEDV	EQU     2
LEDA    EQU     3
LEDR    EQU     4

		ORG 	0B0H  ;Direccion de memoria de variables
			
AUTOSET DS 1
V1      DS 1
A1      DS 1
R1      DS 1 
V2 		DS 1
AUX     DS 1
CONT    DS 1 

		ORG		0C000H; Direccion de memoria para programa

INICIO:	CLRA 				      ;Limpiar acumulador
		STA		SOPT1		      ;Desbilitar
		LDHX	#4B0H 		      ;Reubicar pila
		TXS 			          ;Lo que esta en x a la posicion de la pila
		MOV		#0AAH,MCGTRM;	
		MOV		#6,MCGC1		  ;Ajuste frecuencia del oscilador interno
		BRCLR	LOCK,MCGSC,*      ;Espere a que el oscilador se enganche
		MOV		#00011100B,PTBDD  ;PUERTO B SALIDA 3 PINES DE SALIDA   
		LDA		#00000011B        ;PARA RESISTENCIA DE PULL-UP  00011000
		STA		PTBPE 			  ;PUERTO B ENTRADA /
		CLR 	AUTOSET           ;--------------------------
		MOV 	#6H, V1
		MOV 	#5H, AUX           ; Valores de la secuencia 1
		MOV 	#4H, R1
		MOV 	#1H, A1
		MOV 	#2H, V2           ;--------------------------	
		BSET    LEDV,PTBD
		BSET    LEDA,PTBD
		BSET    LEDR,PTBD
		JSR      SUB_T
		BCLR    LEDV,PTBD
		BCLR    LEDA,PTBD
		BCLR    LEDR,PTBD
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
		CBEQA   #6H,VALORES_2      ; Si el tiempo de verde es 6s salta a rutina 
		MOV 	#6H, V1
		MOV 	#5H, AUX
		MOV 	#4H, R1
		MOV 	#1H, A1
		MOV 	#2H, V2
		JMP     LOOP
VALORES_2:MOV 	#4H, V1
		MOV 	#4H, AUX
		MOV 	#6H, R1
		MOV 	#1H, A1
		MOV 	#3H, V2
		JMP     LOOP	
;--------------------------------------------------------------
;-----------------SUBRUTINA SEMAFORO---------------------------
;--------------------------------------------------------------
S_SEM:  LDA      AUTOSET
	    CBEQA    #1H,MANUAL
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
	    BSET     LEDV,PTBD
	    BSET     LEDA,PTBD
	    LDA      V2
	    JSR      SUB_T
	    BCLR     LEDV,PTBD
	    BCLR     LEDA,PTBD
	    RTS                         ; RETORNA A LOOP    
MANUAL: CLR      CONT               ; Limpia contador
		CLRA                        ; Inicializa el contador
		BCLR     LEDA,PTBD
		BSET     LEDV,PTBD          ; PRENDE LED VERDE
LEER:	LDA      PTBD               ; LEE puerto
		AND 	 #00000011B         ; Enmasara puerto
		CBEQA    #1H, REG2          ; Si oprime auto --> salta a REG2
		CBEQA    #3H, LEER          ; si no se oprime nada , vulve a preguntar
		CBEQA    #0H, LEER          ; si oprime los dos vulve a preguntar
		;SI ES 2 --> oprimio pasar al siguiente led
ESPERA:	LDA 	 PTBD             ; lee puerto
		AND      #00000011B       ; enmascara
		CBEQA	 #3H,M_M          ; si suelta el boton pasa a modo manual
		JMP      ESPERA           ;
M_M:	LDA 	 CONT             ; incrementa en 1 contador
		ADD      #1H              ;
PRE:	STA      CONT             ;
    	CBEQA    #1H, MODO1
		CBEQA    #3H, MODO3
		CBEQA    #4H, MODO4	
		JMP      MANUAL
MODO1:  BCLR     LEDV,PTBD
		JSR      SUB_P
    	LDA      AUTOSET
		CBEQA    #0H,AUTO2
        BSET     LEDR,PTBD
ESP:	LDA 	 PTBD             ; lee puerto
		AND      #00000011B       ; enmascara
		CBEQA	 #3H,LEER          ; si suelta el boton pasa a modo manual
		JMP      ESP    
MODO3:  BCLR     LEDR,PTBD
		BSET     LEDV,PTBD
		BSET     LEDA,PTBD
		MOV      #3H,CONT
		JMP      LEER	
MODO4: 	MOV      #0H,CONT
		JMP      MANUAL			  
REG2:   LDA 	 PTBD
		AND 	 #00000011B			;espera que lo suelte
		CBEQA	 #3H, AUTO2
		JMP      REG2
AUTO2:	CLR 	 AUTOSET
		MOV 	#6H, V1
		MOV 	#5H, AUX
		MOV 	#4H, R1
		MOV 	#1H, A1
		MOV 	#2H, V2
		BCLR 	LEDV, PTBD
		BCLR	LEDA, PTBD
		BCLR	LEDR, PTBD
		RTS	                        ; RETORNA A LOOP
;--------------------------------------------------------------
;-----------------SUBRUTINA TIEMPO---------------------------
;--------------------------------------------------------------
SUB_T:	LDX     #14H        ; Carga x con 20
		MUL                 ; se multiplica Acomulador con 20 para obtener tiempo en S
TIEMPO: LDHX    #50000D     ; Tiempo de 50ms
CICLOT: AIX		#-1D         ; pierde tiempo
		CPHX	#0H          ; compara HX con 0
		BNE		CICLOT      ; Si hx es igual a 0 sigue
		DBNZA   TIEMPO      ; si acomulador es igual a 0 sigue 
		LDA     #1H          ; carga acomulador con 1 para 1s
		RTS                 ; retorna
;--------------------------------------------------------------
;-----------------SUBRUTINA PARPADEO---------------------------
;--------------------------------------------------------------
	
SUB_P:  LDA     AUX
		PSHA  
		LDA     AUTOSET        ; carga valor de auto 
		CBEQA   #1H,P_M2      ; pregunta valor de auto (modo)
		LDA     #1H          ; carga acomulador con 1 para 1s
CICLO_P:BSET    LEDA,PTBD   ; prende led amarillo
		JSR     SUB_T       ; espera 1s
		BCLR    LEDA,PTBD   ; apaga led amarillo
		JSR     SUB_T       ; espera 1s
		DBNZ    AUX,CICLO_P ; pregunta cantidad de parpadeos , si faltan salta
		PULA
		STA     AUX			; Se obtiene de nuevo el valor de aux
		RTS
P_M2:	PULA
P_M:    LDA     #1H         ; carga acomulador con 1 para 1s
		BSET    LEDA,PTBD   ; Prende amarillo
		JSR     SUB_T       ; espera 1s
		BCLR    LEDA,PTBD   ; apaga led amarillo
		JSR     SUB_T       ; espera 1s
        LDA 	PTBD        ; lee puerto B
		AND 	#00000011B  ; Enmascarar 
		CBEQA   #0H,P_M	    ; Si no oprime nada sigue parpadeando
		CBEQA   #3H,P_M     ; si oprime los dos pulsadores sigue parpandeando
		CBEQA   #1H,REG		;
SOST_P: LDA 	PTBD              
		AND 	#00000011B        
		CBEQA   #3H,SOLT_P
		BCLR    LEDV,PTBD   ; apaga led amarillo
		BCLR    LEDA,PTBD   ; apaga led amarillo
		BCLR    LEDR,PTBD   ; apaga led amarillo
		JMP     SOST_P           
SOLT_P: MOV     #2H,CONT    ; contador igual a 2
		RTS 					  ; RETORNA A SUBRUTINA SEMAFORO
REG:    LDA 	PTBD              ;-----------------------------------
		AND 	#00000011B        ; Se hace un ciclo while infinito hasta que 
		CBEQA   #3H,AUTO_R	  ; se suelte el boton TEMP
		JMP     REG               ;-----------------------------------------
AUTO_R: MOV     #0H,AUTOSET       ; una vez se suelta el boton se carga autoset con 1
		RTS                       ; regresa a subrutina semaforo
		
		ORG     0FFFEH
		FDB		INICIO
