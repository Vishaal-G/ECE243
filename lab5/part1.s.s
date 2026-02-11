/*    The code below is a 'main program' followed by a subroutine to display a four-bit quantity as a hex digits (from 0 to F) 
      on one of the six HEX 7-segment displays on the DE1_SoC.
*
 *    Parameters: the low-order 4 bits of register a0 contain the digit to be displayed
		  if bit 4 of a1 is a one, then the display should be blanked
 *    		  the low order 3 bits of a0 say which HEX display number 0-5 to put the digit on
 *    Returns: a0 = bit patterm that is written to HEX display
 */
 
 # a0 is the digit vlaue to show in low 4 bits
#a0 bit 4 used as a flag to check when the display should get blanked
#a1 tells me which HEX display to write to

.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030

li sp, 0x20000    # set up stack pointer

#Your code Here:

#Use t0 for digit choosing and t1 for display index on the HEX, t4 is used to check if its HEX3
li t0,0
li t1,0
li t4, 3

main:
    # If t1 == 3, blank HEX3, else display digit t0
    beq t1, t4, do_blank

    mv a0, t0         # a0 = digit
    mv a1, t1         # a1 = display
    call HEX_DISP
    j after_disp

do_blank:
    li a0, 0x10       # bit4=1 => blank
    mv a1, t1         # blank HEX3 (since t1==3)
    call HEX_DISP

after_disp:
    # delay
    li t2, 1500000
delay:
    addi t2, t2, -1
    bnez t2, delay

    # increment digit (0..F)
    addi t0, t0, 1
    andi t0, t0, 0x0F

    # increment display (0..5)
    addi t1, t1, 1
    li t3, 6
    blt t1, t3, main
    li t1, 0
    j main
	
#Subroutine is here:

HEX_DISP:   
		addi sp, sp, -16           # store the 4 registers being used in this subroutine on the stack
		sw s0,0(sp)
		sw s1,0x4(sp)
		sw s2,0x8(sp)
		sw s3,0xC(sp)
	
		#Decides whether to blank or display digit
		la   s0, BIT_CODES         # starting address of the bit codes
	    andi     s1, a0, 0x10	       # extract bit 4 and check if its 1 to blank 
	    beq      s1, zero, not_blank 
	    mv      s2, zero
	    j       DO_DISP
not_blank:  andi     a0, a0, 0x0f	   # keeps the low 4 bits
            add      a0, a0, s0        # adds number digit to a0 address giving me the bit codes of the correct digit
            lb      s2, 0(a0)         # load correct bit code in

#Display it on the target HEX display
DO_DISP:    
			la       s0, HEX_BASE1         # load address
			li       s1,  4
			blt      a1,s1, FIRST_SET      # if display < 4, use HEX_BASE1
			sub      a1, a1, s1            # if hex4 or hex5, we need to convert a1 index to be 0 or 1
			addi     s0, s0, 0x0010        # Adjust address so it points to secondf register
FIRST_SET:
			slli     a1, a1, 3             # shifts by 8 bits as each HEX is seperated by 8 bits
			addi     s3, zero, 0xff        # extract only a one byte sample
			sll      s3, s3, a1 		   #Shifts extracted byte into requested HEX
			li     	 a0, -1
			xor      s3, s3, a0  		   #Makes target byte = 0 and everything else = 1
    		sll      a0, s2, a1            # shift the hex code we want to write
			lw    	 a1, 0(s0)             # read current hex register value       
			and      a1, a1, s3            # clear only the target byte
			or       a1, a1, a0	           # insert the new byte
			sw    	 a1, 0(s0)		       # write back to the hardware
END:			
			mv 		 a0, s2				   # put bit pattern on return register
			
			
			lw s0,0(sp)			# restore those same 4 registers from the stack.
			lw s1,0x4(sp)
			lw s2,0x8(sp)
			lw s3,0xC(sp)
			addi sp, sp, 16
			ret


#Stores 7 segment bit patter for each hex digit
.data
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
			
