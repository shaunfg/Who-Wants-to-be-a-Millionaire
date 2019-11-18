	#include p18f87k22.inc

	
	global Timer_setup
	extern LCD_Clear_Display, GLCD_clear, GLCD_show_progress, one, Time_Up_Disp
    
acs5	udata_acs   ; reserve data space in access ram
timer	res 1	    ; Times 
save_w	res 1	    ; Used to store the W value before and after the interrupt
twenty	res 1	    ; == 20
	
 ;######################## INTERRUPT #############################    
int_hi	code	0x0008		; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	movwf	save_w
	
	; Display timer on the GLCD
	call	GLCD_show_progress
	
	; Counts 16 seconds and ends game when time is up
	incf	timer		; increment PORTD	
	movlw	0x10		; 20 second timer!!!
	cpfslt	timer
	call	end_game
	
	bcf	INTCON,TMR0IF	; clear interrupt flag
	movf	save_w,W
	retfie	FAST		; fast return from interrupt

DAC	code

end_game    ; End the game
	call	LCD_Clear_Display
	call	Time_Up_Disp
	bcf	T0CON,TMR0ON
	goto	$
	return
	

Timer_setup ; Starts timer to time the question
	movlw	0x0
	movwf	timer
	
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	
	return
	
	end
