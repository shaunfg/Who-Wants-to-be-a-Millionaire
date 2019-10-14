	#include p18f87k22.inc
	
	code
	org 0x0
	goto	main
	
	org 0x100		    ; Main code starts here at address 0x100

main	;Set time for delay
	movlw	0x03		    
	movwf	0x20		    
	
	;Setup ports
	movlw 	0x0		    
	movwf	TRISD, ACCESS	    
	movwf	TRISC, ACCESS	    ; Port C all outputs, sets C to zero, TRISC - sets into not 0/1, to control
	movwf	TRISH, ACCESS	    
	
	;Resets output ports 
	movlw	0x00		    
	movwf	PORTE
	movlw	0x00		    
	movwf	PORTC
	movlw	0x00		   
	movwf	PORTH
	
	;Resets portD, so that no reading or writing
	movlw	0x0f		    
	movwf	PORTD
	
	;set E as output (to write into the memory)
	movlw 	0x0		    ; Sets E as  output
	movwf	TRISE, ACCESS	    ; Port C all outputs, sets C to zero, TRISC - sets into not 0/1, to control
	bsf	PADCFG1,REPU, A	    ; Turn on pull-ups for Port E, 
	
	;write into memory 1
	movlw	0xab		    ; stores arbitary value in E, for transfer
	movwf	PORTE	    
	movlw	0x0d		    ; Turns off CP1--> OE1 High only
	movwf	PORTD
	movff	0x20, 0x22	    ; prep delay
	call	delay
	movlw	0x0f		    ; Turns CP1,OE1 ON
	movwf	PORTD
	
	;write into memory 2
	movlw	0x54		    ; stores arbitary value in E, for transfer
	movwf	PORTE	    
	movlw	0x07		    ; Turns off CP2--> OE2 High only
	movwf	PORTD
	movff	0x20, 0x22	    ; prep delay
	call	delay
	movlw	0x0f		    ; Turns CP2,OE2 ON
	movwf	PORTD
	
	;set E as input (to read the memory)
	movlw	0xff		    ; sets E as input
	movwf	TRISE, A	    ; Port E Direction Register
	
	;read memory 1
	movlw	0x0e		    ; Sets OE1 low(for data read)
	movwf	PORTD	
	movff	PORTE,PORTC
	;read memory 2
	movlw	0x0b		    ; SETS OE2 low(for data read)
	movwf	PORTD
	movff	0x20, 0x22
	call	delay
	movff	PORTE,PORTH
	
	;resets Port D
	movlw	0x0f		    ; Resets so no reading/ writing
	movwf	PORTD
	
	goto	0x0
	
delay	movff	0x20, 0x26
	call	delay1
	decfsz	0x22 ; decrement until zero
	bra	delay
	return
delay1	decfsz	0x26 ; decrement until zero
	bra	delay1
	return
	end