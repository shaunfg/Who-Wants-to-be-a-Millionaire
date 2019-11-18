
	#include p18f87k22.inc
	
	global	Send_Ans_LCD,Check_Answers,Q_A_Setup
	global	Send_Next_Answer
	global	Send_UART_Next_Question
	extern	UART_Transmit_Message,LCD_Write_Message, UART_Transmit_Byte
	extern	LCD_Cursor_A,LCD_Cursor_B,LCD_Cursor_C,LCD_Cursor_D
	extern	LCD_Clear_A,LCD_Clear_B,LCD_Clear_C,LCD_Clear_D
	extern	LCD_Cursor_Remove,LCD_Cursor_AnsC,LCD_Cursor_AnsW
	extern	wait_press, LCD_Clear_Display, LED_Correct,delay_L
	extern	rand_0_to_2
	extern	zero,one,two,three
	extern	my_ext_mem_Q, ext_mem_read_Q,add_H,add_M,add_L
	extern	Q_CNT
	
	

acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; counter to iterate through messages when sending
answer_add  res 1   ; address of correct answer
fifty_fifty_var res 1	; stores 0x10, which corresponds to the recorded button press on keypad
call_friend_var res 1	; stores 0x20, which corresponds to the recorded button press on keypad
audience_var    res 1	; stores 0x30, which corresponds to the recorded button press on keypad
A_ans_var    res 1	; stores 0x0A, which corresponds to the recorded button press on keypad
B_ans_var    res 1	; stores 0x0B, which corresponds to the recorded button press on keypad
C_ans_var    res 1	; stores 0x0C, which corresponds to the recorded button press on keypad
D_ans_var    res 1	; stores 0x0D, which corresponds to the recorded button press on keypad
W_check	    res 1	; variable to check value stored in W by using 'movwf W_check'
Q_add_H	    res 1	; stores address of current question (high)
Q_add_L	    res 1	; stores address of current question (low)
A_add_H	    res 1	; stores address of answer to current question (high)
A_add_L	    res 1	; stores address of answer to current question (low)
	    
wc_labels   udata	0x350    ; reserve data anywhere in RAM (here at 0x350)
myResponse  res 0x20    ; reserve 128 bytes for message data

LCD_table   udata	0x600    ; reserve data anywhere in RAM (here at 0x600)
myLCD	    res 0x80    ; reserve 128 bytes for message data
  
atables	    udata	0x300    ; reserve data anywhere in RAM (here at 0x300)
myAnswers   res 0x10    ; reserve 128 bytes for message data 	

 
pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
	
	; Stores all keypad response answers in hex (correlates to definitions in KEYBOARD.asm) 
answers db	    0x0B,0x0C,0x0C,0x0D,0x0A,0x0A,0x0A,0x0D 
	constant    n_answers=.8	; length of data
	
	; Stores all answers options in blocks of 4 characters (limited by LCD size)
A_1	data	    "PMW PMS PSM PS4 89  91  93  85  10  11  12  13  32m 45m 60m 53m x400x2A0x420x36019481901192319604.7 5.0 3.5 4.3 480 270 300 350 "	; message, plus carriage return
	constant    options_1=.4	; length of data
	
	; Stores 'Incorrect!' message
myWrong data	    "Incorrect!"	
	constant    myWrong_1=.10	; length of data
	
	; Stores 'Correct!' message
myCorrect data	    "Correct!"		
	constant    myCorrect_1=.8	; length of data
	
	
Q_A    code	
	
Q_A_Setup
	; defines what the button presses correlate to
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
	    
	; Loads relevant data (questions, options and answer) from PM into DM
	lfsr	FSR0, myAnswers ; loads data in
	lfsr	FSR1, myAnswers 

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
	
;######################## Send Question to Screen #############################

Send_UART_Next_Question
	movff	Q_CNT, add_M
	call	ext_mem_read_Q
	movlw	0x28	; output message to UART
	lfsr	FSR2, my_ext_mem_Q
	call	UART_Transmit_Message
	return		

;########################## Special Functions ##############################

; fifty-fifty special function
fifty_fifty
	movf	INDF1, W ; moves correct answer into W to ensure that correct answer is not removed by 50-50.
	
	; checks what the correct answer is
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

	; clears 2 random answers that are not the correct answer.
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

fifty_fifty_done    ; returns to wait for button input by user
	call	delay_L
	call	wait_press
	call	Check_Answers

	return
	
 
call_friend	; Call a friend special function
	call	wait_press
	call	Check_Answers

	return
	
audience    ; transmitts the correct answer via UART
	movf	INDF1, W
	call	UART_Transmit_Byte
	movlw	0x0A	; line break
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
	lfsr	FSR0, myResponse; Load FSR0 with address in RAM	
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
	
	lfsr	FSR2, myResponse
	call	LCD_Cursor_AnsW
	movlw	myWrong_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message
	
	goto	$
	return
	
Correct_Answer
	call	LCD_Clear_Display
	lfsr	FSR0, myResponse; Load FSR0 with address in RAM	
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
	
	lfsr	FSR2, myResponse
	call	LCD_Cursor_AnsC
	movlw	myCorrect_1	; output message to LCD (leave out "\n")
	call	LCD_Write_Message
	
	call	LED_Correct
	
	call	delay_L
	call	LCD_Clear_Display
	
;	call	wait_press
;	BRA	Wrong_Answer
	
	return
;######################## Send Answer to LCD #############################
Send_Ans_LCD
	lfsr	FSR0, myLCD	; Load FSR0 with address in RAM	
	movlw	upper(A_1)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(A_1)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(A_1)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	options_1*4*8	; bytes to read
	movwf 	counter		; our counter register

loop_2 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop_2		; keep going until finished
	
	movlw	options_1	; output message to UART
	lfsr	FSR2, myLCD
	call	_LCD_write_ABCD
	movff	FSR2H, A_add_H
	movff	FSR2L, A_add_L
	return
	
Send_Next_Answer
	movff	A_add_L,FSR2L
	movff	A_add_H,FSR2H
	movlw	options_1	; output message to UART
	call	_LCD_write_ABCD
	movff	FSR2H, A_add_H
	movff	FSR2L, A_add_L
	return		; goto current line in code
	
_LCD_write_ABCD
	;lfsr	FSR2, myLCD
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