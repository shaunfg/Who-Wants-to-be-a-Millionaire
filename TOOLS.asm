	#include p18f87k22.inc

	global  delay_L,t_dly1,t_dly2,t_dly3,tools_setup,rand_0_to_2
	global	zero,one,two,three
	
acs4	udata_acs   ; reserve data space in access ram	
t_dly1	res 1
t_dly2	res 1
t_dly3	res 1
t_dly4	res 1
zero	res 1
one	res 1
two	res 1	
three	res 1
rando	res 1
	
tools    code
    
tools_setup
    	movlw	0x00
	movwf	zero
	movlw	0x01
	movwf	one
	movlw	0x02
	movwf	two
	movlw	0x03
	movwf	three
	
	movlw	b'11000001'	
	movwf	T0CON	; = 4MHz clock rate, 
	return
	
rand_0_to_2
	movlw	0x03
	movwf	three
	movlw	0x02
	movwf	two

	movf	TMR0L, W

remainder_loop
movwf	rando
	movlw	0x03
	subwf	rando,1 ; stores in variable
	movf	rando,W
	cpfsgt	three
	bra	remainder_loop
	return

delay_L	movlw	0xff
	movwf	t_dly1
	movwf	t_dly2
delayy 	movff	t_dly1, t_dly3
	call	delay1
	decfsz	t_dly2 ; decrement until zero
	bra	delayy
	return

delay1	movff	t_dly1, t_dly4
	call	delay2
	decfsz	t_dly3 ; decrement until zero
	bra	delay1
	return
	
delay2	decfsz	t_dly4 ; decrement until zero
	bra delay2
	return	
	
	end