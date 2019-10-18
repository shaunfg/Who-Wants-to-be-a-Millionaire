	#include p18f87k22.inc
	
	code
	org 0x0
	goto	main
	
	org 0x100		    ; Main code starts here at address 0x100


main	call	SPI_MasterInit
	movlw	0xab
	call	SPI_MasterTransmit
	call	Wait_Transmit

	call	SPI_MasterInit
	movlw	0x01
	call	SPI_MasterTransmit
	call	Wait_Transmit
loop
	goto	loop


SPI_MasterInit ; Set Clock edge to negative
	bcf	SSP2STAT, CKE
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)

	movlw	(1<<SSPEN)|(1<<CKP)|(0x02)    ; tells how to consruct a byte ; SSPEN defined, << shift left by SSPEN - 2*SSPEN, | logical or, setting 3 bits. 
	movwf	SSP2CON1	    ;constructs a number, to set SSP2CON1 for a certain function. 
	; written this way 
	
	; SDO2 output; SCK2 output
	bcf	TRISD, SDO2		    ; SDO2 predefined as RD4??
	bcf	TRISD, SCK2
	return

SPI_MasterTransmit ; Start transmission of data (held in W)
	movwf	SSP2BUF		    ;moves byte from W to SFR
	return

Wait_Transmit ; Wait for transmission to complete - checks if transmission is complete
	btfss	PIR2, SSP2IF	    ; PIR2 is a FR, SSP2IF is a bit in PIR2, skips if bit 'b' in register 'f' is 1, becomes one when SSP2BUF is finished.
	bra	Wait_Transmit
	bcf	PIR2, SSP2IF	    ; clear interrupt flag
	return	

delay	movff	0x20, 0x26
	call	delay1
	decfsz	0x22 ; decrement until zero
	bra	delay
	return
	
delay1	decfsz	0x26 ; decrement until zero
	bra	delay1
	return
	
test_light
	movlw 	0x00
	movwf	TRISD, ACCESS	    ; Port C all outputs, sets C to zero, TRISC - sets into not 0/1, to control
	
	movlw	0x54
	movwf	PORTD
	end