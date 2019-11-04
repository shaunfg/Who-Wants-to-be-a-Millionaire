

	#include p18f87k22.inc
	
	global	Send_UART_Question_1, Send_Ans_LCD,Check_Answers,Q_A_Setup
	extern	UART_Transmit_Message,LCD_Write_Message
	extern	LCD_Cursor_A,LCD_Cursor_B,LCD_Cursor_C,LCD_Cursor_D
	extern	LCD_Cursor_Remove,LCD_Cursor_AnsC,LCD_Cursor_AnsW
	extern	wait_press, LCD_Clear_Display


acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
 
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data
myAnswers res 0x10    ; reserve 128 bytes for message data
 	
pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****v
	
myTable data	    "What are the Initials of Blackett?\n"	; message, plus carriage return
	constant    myTable_l=.35	; length of data

answers db	    0x0A,0x0B,0x0C,0x0D,0x0A,0x0B,0x0C,0x0D 	; message, plus carriage return
	constant    n_answers=.8	; length of data
	
A_1	data	    "PMWPMSPSMPS4"	; message, plus carriage return
	constant    options_1=.3	; length of data
	
myWrong data	    "Incorrect!"	; message, plus carriage return
	constant    myWrong_1=.10	; length of data
	
myCorrect data	    "Correct!"	; message, plus carriage return
	constant    myCorrect_1=.8	; length of data
	
Q_A    code	
	
Q_A_Setup
	lfsr	FSR0, myAnswers ; loads data in
	lfsr	FSR1, myAnswers ; loads data in

	movlw	upper(answers)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(answers)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(answers)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	n_answers	; bytes to read
	movwf 	counter		; our counter register

loop_a 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop_a
	
	return
	
Check_Answers

	movff	POSTINC1,0x55
	subwf	0x55
	BZ	Correct_Answer


Wrong_Answer
	call	LCD_Clear_Display
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myWrong)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myWrong)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myWrong)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myWrong_1	; bytes to read
	movwf 	counter		; our counter register

loop_w 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop_w		; keep going until finished
	
	lfsr	FSR2, myArray
	call	LCD_Cursor_AnsW
	movlw	myWrong_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message
	
	goto	$
	
	goto	0x0
	return
	
Correct_Answer
	call	LCD_Clear_Display
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myCorrect)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myCorrect)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myCorrect)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myCorrect_1	; bytes to read
	movwf 	counter		; our counter register

loop_c 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop_c		; keep going until finished
	
	lfsr	FSR2, myArray
	call	LCD_Cursor_AnsC
	movlw	myCorrect_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message
	
;	call	wait_press
;	BRA	Wrong_Answer
	
	return
	
    ;Sends question to screen
Send_UART_Question_1
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register

loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message

	return		; goto current line in code

; Writes answer options on LCD
Send_Ans_LCD
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(A_1)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(A_1)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(A_1)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	options_1*4	; bytes to read
	movwf 	counter		; our counter register

loop_2 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop_2		; keep going until finished
	
	lfsr	FSR2, myArray
	call	LCD_Cursor_A
	movlw	options_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message

	call	LCD_Cursor_B
	movlw	options_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message
	
	call	LCD_Cursor_C
	movlw	options_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message
	
	call	LCD_Cursor_D
	movlw	options_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message

	call	LCD_Cursor_Remove
	return

; Checking if answer is correct
Check_Answer
	end