	#include p18f87k22.inc
	
	global	add_H,add_M,add_L,data_RT
	global	ext_memory_setup, ext_store, ext_read, ext_write
	global	my_ext_mem_Q, ext_mem_read_Q
	global	add_H,add_M,add_L
	

acs6	udata_acs   ; reserve data space in access ram
add_H	res 1
add_M	res 1
add_L	res 1
data_RT	res 1
counter	res 1
counterQ res 1
dly1	res 1


ext_mem_read	udata	0xA00    ; reserve data anywhere in RAM (here at 0xA00)
my_ext_mem_Q	res	0x80    ; reserve 80 bytes for message data

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****v
	
myTable data	    "What are the Initials of Blackett?     \nHow old is the Queen Elizabeth?        \nHow many floors are there in Blackett? \nHow tall is the Albert Memorial?       \n"
	constant    myTable_l=.40*4	; length of data
	constant    n_question=.40
	
myTable2 data	    "What is 0x20 times 0x20 in HEX?        \nWhen did Blackett win the Nobel Prize? \nWhat is tower bridge's google rating?  \nHow many acres is hyde park?           \n"	; message, plus carriage return
	constant    myTable_l=.40*4	; length of data
	constant    n_question=.40
	
EXT_MEMORY    code

ext_memory_setup
	bsf	SSP1STAT, CKE
	bcf	SSP1STAT, SMP
	
	movlw	(1<<SSPEN)|(0x02)
	movwf	SSP1CON1
	bcf	SSP1CON1,CKP
	bcf	TRISC,SDO1
	bcf	TRISC,SCK1
	bsf	TRISC,SDI1
	bcf	TRISC,RC2
	bsf	PORTC,RC2
	
	movlw	0x00
	movwf	add_H
	movwf	add_M
	movwf	add_L	
	
	call ext_mem_store_Q1_4
	call ext_mem_store_Q5_8
	
	return
	
	
	
ext_mem_store_Q1_4
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	0x04		; questions to read
	movwf 	counter		; our counter register		
	
loop_1_4
	movlw	n_question
	movwf 	counterQ
	movlw	0x00
	movwf	add_L
loop_1_4_ind
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT,data_RT
	call	ext_store	
	incf	add_L
	decfsz	counterQ
	bra	loop_1_4_ind
	
	incf	add_M
	decfsz	counter
	bra	loop_1_4
	
	return
	
ext_mem_store_Q5_8
	movlw	upper(myTable2)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable2)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable2)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	0x04		; questions to read
	movwf 	counter		; our counter register		
	
loop_5_8
	movlw	n_question
	movwf 	counterQ
	movlw	0x00
	movwf	add_L
loop_5_8_ind
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT,data_RT
	call	ext_store	
	incf	add_L
	decfsz	counterQ
	bra	loop_5_8_ind
	
	incf	add_M
	decfsz	counter
	bra	loop_5_8
	
	return

ext_mem_read_Q
	lfsr	FSR0, my_ext_mem_Q
	movlw	n_question
	movwf	counter
	movlw	0x00
	movwf	add_L
loop_ext_read
	call	ext_read
	movff	data_RT, POSTINC0
	incf	add_L
	decfsz	counter
	bra	loop_ext_read	
	
	return
	
	
ext_write
	movwf	SSP1BUF
wait_transmitt
	btfss	PIR1,SSP1IF
	bra	wait_transmitt
	bcf	PIR1,SSP1IF
	
	return
	
ext_store
	
	bcf	PORTC,RC2
	movlw	0x06
	call	ext_write
	bsf	PORTC,RC2
	
	call	delay
	
	bcf	PORTC,RC2
	
	movlw	0x02
	call	ext_write
	
	movf	add_H,W
	call	ext_write
	movf	add_M,W
	call	ext_write
	movf	add_L,W
	call	ext_write
	
	movf	data_RT,W
	call	ext_write	
	
	bsf	PORTC,RC2
	
	call	delay

	return
	
ext_read
	bsf	SSP1STAT, CKE
	bcf	PORTC,RC2
	
	movlw	0x03
	call	ext_write
	
	movf	add_H,W
	call	ext_write
	movf	add_M,W
	call	ext_write
	movf	add_L,W
	call	ext_write

	movlw	0x00
	call	ext_write	

	movf	SSP1BUF,W
	movwf	data_RT
	
	bsf	PORTC,RC2
	
	call	delay
	
	return

	
delay	movlw	0xff
	movwf	dly1
loop_dly
	decfsz dly1 
	bra loop_dly
	return
	
	end