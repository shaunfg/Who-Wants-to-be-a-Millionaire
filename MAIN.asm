	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex,LCD_Send_Byte_D,Send_Ans_LCD	    ; external LCD subroutines
;	extern	Convert_Hex_Decimal,LCD_Set_Cursor
	extern	Key_In,wait_press,LED_Setup,LCD_Clear_Display
	extern	Q_A_Setup,Check_Answers, delay_L
	extern	tools_setup,rand_0_to_2, wait_press_main
	extern	Send_Next_Answer
	;extern	timer0_setup,
	extern	DAC_setup, DAC_setup_2
	extern 	ext_memory_setup, ext_store, ext_read
	extern	add_H,add_M,add_L,data_RT
	extern	Send_UART_Next_Question, ext_mem_read_Q
	extern	Q_CNT, my_ext_mem_Q

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
	;call	UART_Setup	; setup UART
	;call	LCD_Setup	; setup LCD
	;call	Q_A_Setup	; setup Questions and Answers
	call	LED_Setup	; setup question indication LED
	;call	tools_setup	; setup useful tools (delay)
	call	ext_memory_setup    ; setup external memory (FRAM 2 Click)
	;call	DAC_setup
	;call	DAC_setup_2
	;call	timer0_setup
	
	movff	Q_CNT, add_M
	movlw	0x00
	movwf	add_L
	movlw	0x57
	movwf	data_RT	
	call	ext_store
	
	movlw	0x01
	movwf	add_L
	movlw	0x68
	movwf	data_RT	
	call	ext_store
	
	movlw	0x02
	movwf	add_L
	movlw	0x61
	movwf	data_RT	
	call	ext_store
	
	movlw	0x03
	movwf	add_L
	movlw	0x74
	movwf	data_RT	
	call	ext_store
	
	lfsr	FSR0, my_ext_mem_Q
	movff	Q_CNT, add_M
	movlw	0x00
	movwf	add_L
	call	ext_read
	movff	data_RT, POSTINC0
	movlw	0x01
	movwf	add_L
	call	ext_read
	movff	data_RT, POSTINC0
	movlw	0x02
	movwf	add_L
	call	ext_read
	movff	data_RT, POSTINC0
	movlw	0x03
	movwf	add_L
	call	ext_read
	movff	data_RT, POSTINC0
	;call	ext_mem_read_Q
	;movlw	0x4	; output message to UART
	;lfsr	FSR2, my_ext_mem_Q
	;call	UART_Transmit_Message
	
	;call	Next_Question	    
	;call	Next_Question
	;call	Next_Question
	;call	Next_Question
	;call	Next_Question
	;call	Next_Question
	;call	Next_Question
	;call	Next_Question
	
	;check if answer is correct,store values, check if same, comapare & branch
	; Wrong answer subroutine that ends game
	goto	$
	;Questions in data structures
	;Answers in data structures
	;LCD initialisation
	;UART initialisation
	;Port D for LED control (prize)
	
Next_Question	; prepares the next question if the correct answer has been selected
	call	Send_UART_Next_Question ; Sends next question to UART
	call	Send_Next_Answer    ; Sends the options to LCD
	call	wait_press_main	    ; Waits and records player response
	call	Check_Answers	    ; Compares button press to check if correct
	return

	end
