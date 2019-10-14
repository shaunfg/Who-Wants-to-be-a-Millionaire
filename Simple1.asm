	#include p18f87k22.inc
	
	code
	org 0x0
	goto	main
	
	org 0x100		    ; Main code starts here at address 0x100

main
	movlw	0xff		    ;Sets time for the delay
	movwf	0x20 ; store 0x10 in FR 0x20 
	
	movlw 	0x0		    ; Sets PORTD as output
	movwf	TRISD, ACCESS	    ; Port C all outputs, sets C to zero, TRISC - sets into not 0/1, to control
	
	movlw	0x03		    ; Sets OE1,CP1 as HIGH
	movwf	PORTD
	
	movlw 	0x0		    ; Sets E as output
	movwf	TRISE, ACCESS	    ; Port C all outputs, sets C to zero, TRISC - sets into not 0/1, to control
	
	movlw	0xab		    ; stores arbitary value in E, for transfer
	movwf	PORTE	    
	
	movlw	0x01		    ; Turns off CP1--> OE1 High only
	movwf	PORTD
	
	movff	0x20, 0x22	    ; prep delay
	call	delay
	
	movlw	0x03		    ; Turns CP1,OE1 ON
	movwf	PORTD
	
	movlw	0xff		    ; sets E as input
	movwf	TRISE, A	    ; Port E Direction Register
	bsf	PADCFG1,RDPU, A	    ; Turn on pull-ups for Port E
	
	movlw	0x02		    ; SETS OE1 low, CP1 High n(for data read)
	movwf	PORTD	
	
	call	delayL		    ; delay to observe result
	goto	0x0
	
delay	movff	0x20, 0x26
	call	delay1
	decfsz	0x22 ; decrement until zero
	bra	delay
	return
delay1	decfsz	0x26 ; decrement until zero
	bra	delay1
	return

delayL	movff	0x20, 0x26  ;long delay
	call	delay1L
	decfsz	0x22 ; decrement until zero
	bra	delayL
	return
delay1L	movff	0x20,0x24
	call	delay2L
	decfsz	0x26 ; decrement until zero
	bra	delay1L
	return
delay2L	decfsz	0x26 ; decrement until zero
	bra	delay1
	return	
	end
	

	; W special register - arithmetic operations, f file, l literal value, ACCESS BANK GOOD,