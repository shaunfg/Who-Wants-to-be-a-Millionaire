	#include p18f87k22.inc
	
	global	GLCD_clear, GLCD_show_progress
	
acs0	udata_acs   ; reserve data space in access ram
delay_count res 1   ; reserve one byte for counter in the delay routine
delay_count2 res 1
delay_count3 res 1
delay_count4 res 1
delay_count5 res 1
value	res 1
row	res 1
col	res 1
page_count  res 1

glcd	code
 
GLCD_clear
	movlw	0xff
	movwf	delay_count
	
	movlw	0xB8
	movwf	row
	
	movlw	0x0
	movwf	col
	movwf	page_count
	
	; Sets port D and B to outputs
	movlw	0x00
	movwf	TRISD
	movwf	TRISB
	; Sets RST to 1
	bcf	LATB,RB5
	bsf	LATB,RB5
	
	call	first_page


reset_screen
	movff	row,PORTD
	call	cmd_write
	incf	row
	
	;move cursor to zero
	movlw	0x40
	movwf	PORTD
	call	cmd_write
	
	call	row_loop
	
	movlw	0xBF
	cpfsgt	row
	bra	reset_screen

	call	second_page

reset_screen_2
	movff	row,PORTD
	call	cmd_write
	incf	row
	
	;move cursor to zero
	movlw	0x40
	movwf	PORTD
	call	cmd_write
	
	call	row_loop
	
	movlw	0xBF
	cpfsgt	row
	bra	reset_screen_2
	bra	show_screen
row_loop
	movlw	0x00	   ; CHANGE TIS VALUE
	movwf	PORTD
	
	call	data_write
	incf	col
	
	movlw	0x63
	cpfseq	col
	bra	row_loop
	return
	
	
show_screen
	movlw	0xB8
	movwf	row
	
	movlw	0x0
	movwf	col
	
	call	first_page
	return

GLCD_show_progress
	incf	page_count
	
	movlw	0x09
	subwf	page_count,0
	BZ	new_page
	bra	_display
new_page
	call	second_page
_display
	movff	row,PORTD
	call	cmd_write
	incf	row
	
	;move cursor to zero
	movlw	0x40
	movwf	PORTD
	call	cmd_write
	
	call	row_loop_2
	return
	
row_loop_2
	movlw	0xBA	   ; CHANGE TIS VALUE
	movwf	PORTD
	
	call	data_write
	incf	col
	
	movlw	0x63
	cpfseq	col
	bra	row_loop_2
	return
	
data_write		
	; Sets RS to 1
	bsf	LATB, RB2
	; Sets R/w to 0
	bcf	LATB, RB3	
	; High to low pulse on enable
	bsf	LATB,RB4
	call	delay
	bcf	LATB,RB4
	return

cmd_write
	; Sets RS to 0
	bcf	LATB, RB2
	call	delay

	; Sets R/W to 0
	bcf	LATB, RB3
	call	delay

	; Sets E to 1 to 0
	bsf	LATB,RB4
	call	delay
	bcf	LATB,RB4
	return

first_page	
	; Turns on upper half of glcd
	bsf	LATB,RB1
	; Turns off lower half of glcd
	bcf	LATB,RB0
	call	delay

	movlw	b'00111111'
	movwf	PORTD
	call	cmd_write
	call	delay
	return
	
second_page
	movlw	0xB8
	movwf	row
	
	movlw	0x0
	movwf	col
	
	; Turns on upper half of glcd
	bcf	LATB,RB1
	; Turns off lower half of glcd
	bsf	LATB,RB0
	call	delay

	movlw	b'00111111'
	movwf	PORTD
	call	cmd_write
	call	delay
	return
		
delay	movlw	0x11
	movwf	delay_count
	movwf	delay_count2

delay_1	movff	delay_count,delay_count3
	call	delay_2
	decfsz	delay_count2
	bra	delay_1
	return
	
delay_2	decfsz	delay_count3
	bra delay_2
	return
	
	
Ldelay	movlw	0xFF
	movwf	delay_count
	movwf	delay_count2

Ldelay_1	
	movff	delay_count,delay_count3
	call	Ldelay_2
	decfsz	delay_count2
	bra	Ldelay_1
	return

Ldelay_2
	movff	delay_count,delay_count4
	call	Ldelay_4
	decfsz	delay_count3
	bra	Ldelay_2
	return

Ldelay_4	
    	decfsz	delay_count4
	bra	Ldelay_4
	return
	end