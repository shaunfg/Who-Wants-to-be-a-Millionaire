	#include p18f87k22.inc
	
	global	LED_Setup, Q_CNT, LED_Correct
	
acs5	udata_acs   ; reserve data space in access ram
Q_CNT	res 1
Q_dec	res 1
Light_dis   res 1
Light_add   res 1
	
LED	code
	
LED_Setup
	movlw	0x00
	movwf	TRISJ, A
	movwf	Q_CNT
	movwf	Light_dis
	movwf	PORTJ
	return
	
LED_Correct
	movlw	0x01
	movwf	Light_add
	
	movff	Q_CNT,Q_dec

loop	rlncf	Light_add
	decfsz	Q_dec
	bra	loop
	
	movf	Light_add,W
	addwf	Light_dis,1
	movff	Light_dis,PORTJ
	
	incf	Q_CNT
	return
	
	end