	#include p18f87k22.inc

	
	global DAC_setup, timer0_setup
	extern LCD_Clear_Display
    
acs5	udata_acs   ; reserve data space in access ram
timer	res 1
save_w	res 1
twenty	res 1
buzzer	res 1
	
int_hi	code	0x0008		; high vector, no low vector
	;timer 1, for question time
	btfss	INTCON,TMR1IF	; check that this is timer0 interrupt
	bra	Check_timer0		; if not then return
	movwf	save_w
	
	incf	timer		; increment PORTD
	movlw	0x14		; 20 second timer!!!
	cpfslt	timer
	call	end_game
	
	bcf	INTCON,TMR1IF	; clear interrupt flag
	movf	save_w,W
	retfie	FAST		; fast return from interrupt
	
Check_timer0	; Timer 0, for buzzer
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	movwf	save_w

	btg	LATB,RB6
	movf	save_w,W	
	bcf	INTCON,TMR0IF	; clear interrupt flag
	
	retfie	FAST		; fast return from interrupt

DAC	code

end_game   
	call	LCD_Clear_Display
	return

timer0_setup; buzzer
	clrf	TRISB
	clrf	LATB
	
	bsf	T0CON,T08BIT
	bcf	T0CON,T0CS
	bcf	T0CON,PSA
	
	bsf	T0CON,T0PS0
	bsf	T0CON,T0PS1
	bcf	T0CON,T0PS2
	bsf	T0CON,TMR0ON
	bsf	INTCON,TMR0IE
	bsf	INTCON,GIE
	return
	
DAC_setup; question answer time
	
	movlw	0x0
	movwf	buzzer
	
	movlw	0x0
	movwf	timer
	
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T1CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR1IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	
	return
	
	end


