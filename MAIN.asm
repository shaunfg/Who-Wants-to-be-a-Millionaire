	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex,LCD_Send_Byte_D,Send_Ans_LCD	    ; external LCD subroutines
	extern	Key_In,wait_press,LED_Setup,LCD_Clear_Display
	extern	Q_A_Setup,Check_Answers, delay_L
	extern	tools_setup,rand_0_to_2, wait_press_main
	extern	Send_Next_Answer
	extern 	ext_memory_setup, ext_store, ext_read
	extern	add_H,add_M,add_L,data_RT
	extern	Send_Next_Question, ext_mem_read_Q
	extern	Q_CNT, my_ext_mem_Q, ext_write
	extern	GLCD_clear, GLCD_show_progress
	extern	End_Game_Disp, LCD_Cursor_Remove


rst	code	0    ; reset vector
	goto	start

main	code
	
start	
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	Q_A_Setup	; setup Questions and Answers
	call	LED_Setup	; setup question indication LED
	call	tools_setup	; setup useful tools (delay)
	call	ext_memory_setup    ; setup external memory (FRAM 2 Click)
	
	call	GLCD_clear

	; Question 1
	call	Send_Next_Question
	call	Send_Ans_LCD	
	call	wait_press_main
	call	Check_Answers
	
	
	; Questions 2-8
	call	Next_Question	    
	call	Next_Question
	call	Next_Question
	call	Next_Question
	call	Next_Question
	call	Next_Question
	call	Next_Question
winner_loop
	call	End_Game_Disp
	call	delay_L
	call	LCD_Clear_Display
	call	LCD_Cursor_Remove
	call	delay_L
	bra	winner_loop
	goto	$
	
Next_Question	; prepares the next question if the correct answer has been selected
	call	GLCD_clear	    ; Clears GLCD screen
	call	Send_Next_Question  ; Sends next question to UART
	call	Send_Next_Answer    ; Sends the options to LCD
	call	wait_press_main	    ; Waits and records player response
	call	Check_Answers	    ; Compares button press to check if correct
	return

	end
