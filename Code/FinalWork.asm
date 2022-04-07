;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Source File:	Project #4: 16F877A PICMicro programming under MPLAB
;
;				**** Fun binary counter  ****		
;	Author:		Maen Khdour 1171944 
;	Sec:		2	         
;	Date:		16-12-21      
;	Due-Date: 	7/1/2022
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;Include Libararies:

#include p16f877a.inc

	PROCESSOR 16F877	; Define MCU type
	__CONFIG 0x3733		; Set config fuses


; Register Label Equates....................................

PORTB      EQU    0x06	; Port B Data Register        
PORTD      EQU    0x08	; Port D Data Register  
TRISD	   EQU	  0x88	; Port D Direction Register
STATUS	   EQU    0x03	; STATUS
BUTTON_C1  EQU 	  0x21  ; counter for button1 to know how many time we pressed it.
BUTTON_C2  EQU    0x22  ; counter for button 2 
TMR0	   EQU	  0x01	; Hardware Timer Register
INTCON	   EQU	  0x0B	; Interrupt Control Register
OPTREG	   EQU	  0x81	; Option Register
D1		   EQU	  0x30  ; Define D1 TO D3 GPR for make 1 sec Dealy 
D2		   EQU	  0x31
D3		   EQU    0x32
delay_c2   EQU    0x33  ; GPR for store value of Button_c2 and make cal on it

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	Initialise Memory:

	ORG	000				; Start of program memory
	NOP					; For ICD mode
	GOTO	init		; Jump to main program

; Interrupt Service Routine ................................

	ORG		004  		; start from ISR Table 
	BTFSC	INTCON,1	; set INTCON bit 1 , Skip if it clear  
	CALL	CAL_1		; call Interrupt for button1 
	BTFSC	INTCON,0	; set INTCON bit 0 , Skip if it clear  
	CALL	CAL_2		; call Interrupt for button2 
	
	BCF		INTCON,2	; Reset TMR0 interrupt flag
	
	RETFIE			    ; Return from interrupt	

; Initialise Port D (Port B defaults to inputs).............
        
init:	NOP				; BANKSEL cannot be labelled
		BANKSEL	TRISD		; Select bank 1
       	MOVLW   0x0   	; Port B Direction Code
    	MOVWF	TRISD          	; Load the DDR coe into F86
		
; Initialise Timer0,Inteurrputs and Button_c1,c2 ........................................

	MOVLW	b'11011000'	; TMR0 initialisation code
	MOVWF	OPTREG		; Int clock, no prescale	
	BANKSEL	PORTD		; Select bank 0
	MOVLW	b'10100000'	; INTCON init. code
	MOVWF	INTCON		; Enable TMR0 interrupt
	NOP					; NOP instruction 
	BCF 	INTCON, 1	; clear bit 1 in INTCON (clear for RB0 Flag)
	BSF 	INTCON, 7	; set bit 7 in INTCON (Enable Global Interrupt)
	BSF 	INTCON, 4	; set bit 4 in INTCON (Enable external Interrupt on RB0)
	
	MOVLW 	0x01		; put 1 on Button_c1 initail
	MOVWF	BUTTON_C1
	NOP
	MOVLW 	0x01
	MOVWF	BUTTON_C2	; put 1 on Button_c2 initail


; Start main loop ...........................................	

reset   
		CLRF    PORTD  		; Clear Port B Data 
		CALL	DELAY		; Call Delay 1 sec 

start:   

		CLRF	TMR0		; Reset timer
wait	BTFSS	INTCON,2	; Check for time out
		GOTO	wait		; Wait if not
		


stepin:	
		MOVLW   0x1F 		; Put 31 on Register W
		SUBWF   PORTD,0 	; sub the value on PortD from W and store value on W
		BTFSS   STATUS,0	; bit test STATUS, Skip if set 
		GOTO	count		; GO to Lable count
		GOTO    reset		; Go to reset if Skip

count:
		MOVF	BUTTON_C1,0	; put the value of button_C1 in W
		ADDWF 	PORTD, 1	; add the value of portD with W and store in port D
		MOVF 	BUTTON_C2,0	; put the value of button_C2 in W 

		MOVWF 	delay_c2 	; Move content of W to Dela
		
del_c2: 
		CALL 	DELAY		
		DECFSZ	delay_c2 	; Decrement dela , Skip if 0
		GOTO 	del_c2			
        GOTO   	start       ; Repeat main loop always
		

; Function make a DELAY 1 SECOND using 3 insted loops and GPR 
DELAY:		MOVLW 0x40   	; put 45hex in W to D1 = 69 In Decimal 
			MOVWF D1
	LOOP3:	MOVLW 0x40 		; put 45hex in W to D2
			MOVWF D2
	LOOP2:  MOVLW 0x40
			MOVWF D3		; put 45hex in W to D3
	LOOP1:	DECFSZ D3       ; Decrement D3 skip if 0
			GOTO LOOP1
			DECFSZ D2
			GOTO LOOP2
			DECFSZ D1
			GOTO LOOP3
	RETURN


; Make Calculation and set, reset the INTCON of ISR

; Cal and ISR for Buuton1 counter the NUMBER LEDS increment 
CAL_1: 
		INCF	BUTTON_C1,1	; Button_C1 and store the value on it
		MOVLW   0x06		; Put 6 in W
		SUBWF   BUTTON_C1,0 ; sub the value of BUTTON_C1 from W and store the result in W
		BTFSS   STATUS,0	; test the set of STATUS skip if set 
		GOTO 	ISR1		; Goto ISR1 if not set 
	
		MOVLW 	0x01		; Put 1 again in BUTTON_C1 if it skipped 
		MOVWF	BUTTON_C1	; BUTTON_C1 = 1

; ISR of BUTTON1 to set and reset the interrupt
	ISR1:
		BCF INTCON, 1   	; clear bit 1 --> clear Flag of RB0 
		BSF INTCON, 7		; set bit 7 --> Enable GIE (Global Interrupt Enable)
		BSF INTCON, 4		; set bit 4 --> Enable RB0

	RETURN

; Cal and ISR for Buuton2 counter the DELAY increment 
CAL_2:
		INCF	BUTTON_C2,1	; increment BUTTON_C2 and store the value on it
		MOVLW   0x06		; put 6 in the W
		SUBWF   BUTTON_C2,0 ; subtract the value of BUTTON_C2 from W and store in W
		BTFSS   STATUS,0	; test the set of STATUS skip if set  
		GOTO 	ISR2		; Goto ISR2 if not set
	
		MOVLW 	0x01		; put 1 in W if STATUS set then move it to BUTTON_C2
		MOVWF	BUTTON_C2	; BUTTON_C2 = 1

; ISR of BUTTON2 to set and reset the interrupt of DELAY 
	ISR2	
		MOVF PORTB,1	; Move the value of PortB and store it on it self 
		MOVLW 0			; Put 0 to W
		MOVWF PORTB		; Move 0 to Port B to reset it 
		BCF INTCON, 0	; clear Bit0 Flag for RB4 TO RB7 pins
		BSF INTCON, 3	; set bit 3 to Enable the Interrupt of RB4 TO RB7 pins
		BSF INTCON, 4	; Enable interrupt on RB0 
		BSF INTCON, 7	; Enable GIE (Global Interrupt Enable)
	
	RETURN

; End Program 
	END