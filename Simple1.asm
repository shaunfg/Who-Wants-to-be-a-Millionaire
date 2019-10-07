	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start
	movlw 	0x0
	movwf	TRISC, ACCESS	    ; Port C all outputs, sets C to zero
	bra 	test		    ; 
loop	movff 	0x06, PORTC	    ; outputs, to port C
	incf 	0x06, W, ACCESS	    ; +=1, moves f+1 into W memm
test	movwf	0x06, ACCESS	    ; 06 arbitary memory location Test for end of loop condition
	movlw 	0xFF		    ; sets literal value into w
	cpfsgt 	0x06, ACCESS	    ; compare to file f, skip if greater than
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start, jumps back to org 0x0
	
	end
; W special register - arithmetic operations, f file, l literal value, ACCESS BANK GOOD,