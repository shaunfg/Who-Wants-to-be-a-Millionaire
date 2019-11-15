	#include p18f87k22.inc

	
	global DAC_setup,DAC_setup_2
	extern LCD_Clear_Display
    
acs5	udata_acs   ; reserve data space in access ram
timer	res 1
save_w	res 1
twenty	res 1
	
int_hi	code	0x0008		; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	movwf	save_w
	btg	LATB,RB6
	
	incf	timer		; increment PORTD
	movlw	0xFF		; 20 second timer!!!
	cpfslt	timer	
	call	end_game
	bcf	INTCON,TMR0IF	; clear interrupt flag
	movf	save_w,W
	retfie	FAST		; fast return from interrupt
	
DAC	code

end_game   
	call	LCD_Clear_Display
	return
	
DAC_setup_2
	
	clrf	LATD
	movlw	0x0
	movwf	timer
	
	clrf	TRISB
	bcf	LATB,RB6
	bsf	T0CON,T08BIT
	bcf	T0CON,T0CS
	bcf	T0CON,PSA
	
	;movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	;movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	T0CON,T0PS0
	bsf	T0CON,T0PS1
	bsf	T0CON,T0PS2
	bsf	T0CON,TMR0ON
	
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	
	return
	
DAC_setup; question answer time
	clrf	TRISD		; Set PORTD as all outputs
	clrf	LATD		; Clear PORTD outputs	
	movlw	0x0
	movwf	timer
	
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T1CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR1IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts

	return
		
	end
