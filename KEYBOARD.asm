	#include p18f87k22.inc
	
	global	Key_In, wait_press
	extern	zero,one,two,three

acs2	udata_acs   ; reserve data space in access ram
dly1	res 1
dly2	res 1
dly3	res 1
row	res 1
col	res 1
		 
KEYBOARD    code	

    
Key_In	
	movlw	0x0f		 ;set pins 0-3 to input, 4-7 as output
	movwf	TRISE, A
	banksel PADCFG1
	bsf	PADCFG1,REPU,BANKED	;pull-ups for PORT E
	
	clrf	LATE
	
	movlw	0xff
	movwf	dly1
	movff	dly1, dly2
	call	delay
	
	movff	PORTE,row
	
	movlw	0xf0		   ;set pins 0-3 to output, 4-7 as input
	movwf	TRISE, A	    
	banksel PADCFG1		    
	bsf	PADCFG1,REPU,BANKED	;pull-ups for PORT E
	
	clrf	LATE

	movlw	0xff
	movwf	dly1
	movff	dly1, dly2
	call	delay
		
	movff	PORTE,col

	call	check_row	   ;

output	movwf	0x15
	return
	
check_row ;row data is stored in 0x10
	
	movlw	0x07
	subwf	row, 0
	BZ  col_1
	
	movlw	0x0B
	subwf	row, 0
	BZ  col_2
	
	movlw	0x0D
	subwf	row, 0
	BZ  col_3
	
	movlw	0x0E
	subwf	row, 0
	BZ  col_4

	movlw 0x0
	
	return
	
col_1	movlw	0xE0
	subwf	col, 0
	BZ	S_1
	movlw	0x0A
	BRA	output

S_1	movlw	0x10
	BRA	output

col_2	movlw	0xE0
	subwf	col, 0
	BZ	S_2
	movlw	0x0B
	BRA	output

S_2	movlw	0x20
	BRA	output
	
col_3	movlw	0xE0
	subwf	col, 0
	BZ	S_3
	movlw	0x0C
	BRA	output

S_3	movlw	0x30
	BRA	output

	
col_4	movlw	0xE0
	subwf	col, 0
	BZ	S_4
	movlw	0x0D
	BRA	output
	
S_4	movlw	0x40
	BRA	output
	
delay	movff	dly1, dly3
	call delay1
	decfsz dly2 ; decrement until zero
	bra delay
	return

delay1	decfsz dly3 ; decrement until zero
	bra delay1
	return
	
wait_press
	movlw	0x0
	movwf	zero
	
	call	Key_In
	
	cpfslt	zero, 0
	bra	wait_press
	return
	
	end
	

	; W special register - arithmetic operations, f file, l literal value, ACCESS BANK GOOD,