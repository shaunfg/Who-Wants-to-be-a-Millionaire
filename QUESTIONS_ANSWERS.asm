
	#include p18f87k22.inc
	
	global	Send_UART_Question_1, Send_Ans_LCD,Check_Answers,Q_A_Setup
	extern	UART_Transmit_Message,LCD_Write_Message, UART_Transmit_Byte
	extern	LCD_Cursor_A,LCD_Cursor_B,LCD_Cursor_C,LCD_Cursor_D
	extern	LCD_Clear_A,LCD_Clear_B,LCD_Clear_C,LCD_Clear_D
	extern	LCD_Cursor_Remove,LCD_Cursor_AnsC,LCD_Cursor_AnsW
	extern	wait_press, LCD_Clear_Display, LED_Correct,delay_L
	extern	rand_0_to_2
	extern	zero,one,two,three
	global	Send_Question
	

acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
answer_add  res 1
fifty_fifty_var res 1
call_friend_var res 1
audience_var    res 1
A_ans_var    res 1
B_ans_var    res 1
C_ans_var    res 1
D_ans_var    res 1
W_check	    res 1
  
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data
myAnswers res 0x10    ; reserve 128 bytes for message data 	
 
pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****v
	
myTable data	    "What are the Initials of Blackett?    \nWhat are the Initials of Tlackett?    \n"	; message, plus carriage return
	constant    myTable_l=.80	; length of data
	constant    n_characters=.40	; including 1 character for \n
answers db	    0x0A,0x0B,0x0C,0x0D,0x0A,0x0B,0x0C,0x0D 	; message, plus carriage return
	constant    n_answers=.8	; length of data
A_1	data	    "PMWPMSPSMPS4"	; message, plus carriage return
	constant    options_1=.3	; length of data
myWrong data	    "Incorrect!"	; message, plus carriage return
	constant    myWrong_1=.10	; length of data
myCorrect data	    "Correct!"		; message, plus carriage return
	constant    myCorrect_1=.8	; length of data
	
Q_A    code	
	
Q_A_Setup
	movlw	0x10
	movwf	fifty_fifty_var
	
	movlw	0x20
	movwf	call_friend_var
	
	movlw	0x30
	movwf	audience_var
	
	movlw	0x0A
	movwf	A_ans_var
	movlw	0x0B
	movwf	B_ans_var
	movlw	0x0C
	movwf	C_ans_var
	movlw	0x0D
	movwf	D_ans_var
	    
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
;########################## Special Functions ##############################

fifty_fifty
	movf	INDF1, W
	;movwf	W_check
	
	movff	A_ans_var,answer_add
	subwf	answer_add,1
	BZ	fif_A
	
	movff	B_ans_var,answer_add
	subwf	answer_add,1
	BZ	fif_B
	
	movff	C_ans_var,answer_add
	subwf	answer_add,1
	BZ	fif_C

	movff	D_ans_var,answer_add
	subwf	answer_add,1
	BZ	fif_D

fif_A	call	rand_0_to_2
	subwf	zero,1
	BZ	clr_BC	
	subwf	one,1
	BZ	clr_BD	
	subwf	two,1
	BZ	clr_CD	
	
fif_B	call	rand_0_to_2
	subwf	zero,1
	BZ	clr_AC	
	subwf	one,1
	BZ	clr_AD	
	subwf	two,1
	BZ	clr_CD
	
fif_C	call	rand_0_to_2
	subwf	zero,1
	BZ	clr_AB	
	subwf	one,1
	BZ	clr_AD	
	subwf	two,1
	BZ	clr_BD
	
fif_D	call	rand_0_to_2
	subwf	zero,1
	BZ	clr_AB	
	subwf	one,1
	BZ	clr_AC	
	subwf	two,1
	BZ	clr_BC
	
clr_AB	call	LCD_Clear_A
	call	LCD_Clear_B
	bra	fifty_fifty_done

clr_AC	call	LCD_Clear_A
	call	LCD_Clear_C
	bra	fifty_fifty_done
	
clr_AD	call	LCD_Clear_A
	call	LCD_Clear_D
	bra	fifty_fifty_done
	
clr_BC	call	LCD_Clear_B
	call	LCD_Clear_C
	bra	fifty_fifty_done

clr_BD	call	LCD_Clear_B
	call	LCD_Clear_D
	bra	fifty_fifty_done
	
clr_CD	call	LCD_Clear_C
	call	LCD_Clear_D
	bra	fifty_fifty_done

fifty_fifty_done
	call	delay_L
	call	wait_press
	call	Check_Answers

	return
	
call_friend
	
	
	call	wait_press
	call	Check_Answers

	return
	
audience
	movf	INDF1, W
	call	UART_Transmit_Byte
	movlw	0x0A
	call	UART_Transmit_Byte
	
	call	wait_press
	call	Check_Answers

	return
	
;########################## Check Answers ##############################
	
Check_Answers
	movff	fifty_fifty_var,answer_add
	subwf	answer_add,1
	BZ	fifty_fifty	;change to special function 
	
	movff	call_friend_var,answer_add
	subwf	answer_add,1
	BZ	call_friend

	movff	audience_var,answer_add
	subwf	answer_add,1
	BZ	audience

	movff	POSTINC1,answer_add
	subwf	answer_add
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
	
	call	LED_Correct
	
	call	delay_L
	call	LCD_Clear_Display
	
;	call	wait_press
;	BRA	Wrong_Answer
	
	return
	
;######################## Send Question to Screen #############################
	
Send_UART_Question_1
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
Send_Question	
	movlw	n_characters	; bytes to read
	movwf 	counter		; our counter register
loop
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message

	return		; goto current line in code

;######################## Send Answer to LCD #############################
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

	end