	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex,LCD_Send_Byte_D	    ; external LCD subroutines
	extern	Convert_Hex_Decimal,LCD_Set_Cursor
	extern	Key_In

	extern ;delay, keypad, LCD

	code
	org 0x0
	goto	setup

	org 0x100		    ; Main code starts here at address 0x100


    setup	
	;Questions in data structures
	;Answers in data structures
	;LCD initialisation
	;UART initialisation
	;Port D for LED control (prize)
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	goto	start

	
	end
