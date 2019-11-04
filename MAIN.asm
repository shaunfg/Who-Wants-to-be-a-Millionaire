	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex,LCD_Send_Byte_D	    ; external LCD subroutines
;	extern	Convert_Hex_Decimal,LCD_Set_Cursor
	extern	Key_In
	extern	LCD_Cursor_A,LCD_Cursor_B,LCD_Cursor_C,LCD_Cursor_D
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

	
start	
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	
	call	LCD_Cursor_A
	call	LCD_Cursor_B
	call	LCD_Cursor_C
	call	LCD_Cursor_D

	goto	start

	;Questions in data structures
	;Answers in data structures
	;LCD initialisation
	;UART initialisation
	;Port D for LED control (prize)

	end
