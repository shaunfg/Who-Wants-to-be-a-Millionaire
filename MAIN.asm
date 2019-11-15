	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex,LCD_Send_Byte_D,Send_Ans_LCD	    ; external LCD subroutines
;	extern	Convert_Hex_Decimal,LCD_Set_Cursor
	extern	Key_In,wait_press,LED_Setup,LCD_Clear_Display
	extern	Q_A_Setup,Send_UART_Question_1,Check_Answers, delay_L
	extern	tools_setup,rand_0_to_2, Send_Next_Question, wait_press_main
	extern	Buzzer_Setup,Send_UART_Question_5, Send_Next_Answer
	extern	timer0_setup
	extern 	ext_memory_setup, ext_store, ext_read
	extern	add_H,add_M,add_L,data_RT

rst	code	0    ; reset vector
	goto	start

main	code
	
start	movlw	0x03
	movwf	0x80
	
	movlw	0x50
	subwf	0x80,0 ; stores in W
	movwf	0x55
	
	
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	Q_A_Setup
	call	LED_Setup
	call	tools_setup
	;call	timer0_setup
	call	ext_memory_setup

	;movlw	0x06
	;movwf	add_L
	
	;movlw	0x23
	;movwf	data_RT
	;call	ext_store
	
	movlw	0x06
	movwf	add_L
	
	call	ext_read
	movff	data_RT,0x45
	
	; Question 1
	call	Send_UART_Question_1
	call	Send_Ans_LCD	
	call	wait_press_main
	call	Check_Answers
	
	call	Next_Question
	call	Next_Question
	call	Next_Question

	; Question 5
	call	Send_UART_Question_5
	call	Send_Next_Answer
	call	wait_press_main
	call	Check_Answers	
	
	call	Next_Question
	call	Next_Question
	call	Next_Question
	
	;check if answer is correct,store values, check if same, comapare & branch
	; Wrong answer subroutine that ends game
	goto	$
	;Questions in data structures
	;Answers in data structures
	;LCD initialisation
	;UART initialisation
	;Port D for LED control (prize)
Next_Question
	call	Send_Next_Question
	call	Send_Next_Answer
	call	wait_press_main
	call	Check_Answers	
	return

	end
