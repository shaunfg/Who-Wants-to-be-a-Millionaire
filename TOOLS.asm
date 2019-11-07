	#include p18f87k22.inc

	global  delay_L,t_dly1,t_dly2,t_dly3
	
acs4	udata_acs   ; reserve data space in access ram	
t_dly1	res 1
t_dly2	res 1
t_dly3	res 1
t_dly4	res 1
	
tools    code
    
   


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