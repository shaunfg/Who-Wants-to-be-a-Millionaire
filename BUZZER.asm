	#include p18f87k22.inc

	global	Buzzer_Setup
buzzer	code
	
Buzzer_Setup
	
	movlw	b'11111111'
	movwf	PR2	    ; timer value
	
	movlw	b'00101100' ; single output, PWM duty cycle, PWM mode
	movwf	CCP4CON	    ; Use CCP #4
	
	movlw	0xab
	movwf	CCPR4L	    ; Sets duty cycle
	
	;movlw	0xab
	;movwf	CCP4CON<5:4>
	
	movlw	0x0
	movwf	TRISB
	
	movlw	b'10000011'	; Set timer0 to 16-bit, Fosc/4/256; Prescaler
	movwf	T2CON		; = 62.5KHz clock rate, approx 1sec rollover
	;bsf	INTCON,TMR2IE	; Enable timer0 interrupt
	;bsf	INTCON,GIE	; Enable all interrupts
	

Buzzer 	

	
end