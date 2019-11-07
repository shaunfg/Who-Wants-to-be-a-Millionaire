	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex,LCD_Send_Byte_D,Send_Ans_LCD	    ; external LCD subroutines
;	extern	Convert_Hex_Decimal,LCD_Set_Cursor
	extern	Key_In,wait_press,LED_Setup,LCD_Clear_Display
	extern	Q_A_Setup,Send_UART_Question_1,Check_Answers, delay_L
 
rst	code	0    ; reset vector
	goto	start

main	code
	
start	
	
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	Q_A_Setup
	call	LED_Setup
	
	call	Send_UART_Question_1
	call	Send_Ans_LCD
	
	call	wait_press
	call	Check_Answers


	
	call	Send_UART_Question_1
	call	Send_Ans_LCD
	
	call	wait_press
	call	Check_Answers
	
	;check if answer is correct,store values, check if same, comapare & branch
	; Wrong answer subroutine that ends game
	goto	$
	;Questions in data structures
	;Answers in data structures
	;LCD initialisation
	;UART initialisation
	;Port D for LED control (prize)

	end