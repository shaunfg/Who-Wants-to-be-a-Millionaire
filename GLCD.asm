	#include p18f87k22.inc
	
	code
acs0	udata_acs   ; reserve data space in access ram
delay_count res 1   ; reserve one byte for counter in the delay routine
delay_count2 res 1
delay_count3 res 1

glcd	code
 
start
	movlw	0xff
	movwf	delay_count
	
	; Sets port D and B to outputs
	movlw	0x00
	movwf	TRISD
	movwf	TRISB
	; Sets RST to 1
	bsf	LATB,RB5
	
	; Turns on upper half of glcd
	bsf	LATB,RB1
	; Turns off lower half of glcd
	bcf	LATB,RB0
	call	delay

	movlw	b'00111111'
	movwf	PORTD
	call	cmd_write
	call	delay

	movlw	0xBB
	movwf	PORTD
	call	cmd_write

	movlw	0x40
	movwf	PORTD
	call	cmd_write

	movlw	0xAB
	movwf	PORTD
	call	data_write
	
	movlw	0x45
	movwf	PORTD
	call	data_write
	
	movlw	0x68
	movwf	PORTD
	call	data_write
	
	call	delay
	
	; chip select signal, to select and enbable which half you want
	; E pulsed from low to high.
	; rst pin
	goto 	$		    ; Re-run program from start

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
	; Sets R/W to 0
	bcf	LATB, RB3
	; Sets E to 1 to 0
	bsf	LATB,RB4
	call	delay
	bcf	LATB,RB4
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
	end



