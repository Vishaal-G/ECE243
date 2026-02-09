.global _start
_start:


.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
.equ PUSH_BUTTON, 0xFF200050

#Your code goes below here:

#Your code should:

#Turn off interrupts in case an interrupt is called before correct set up
csrw mstatus, zero # Turn off bit 3 of mstatus - the MIE bit

#Initialize the stack pointer
li sp, 0x20000 

#activate interrupts from IRQ18 (Pushbuttons)
li   t0, 0x40000 # Load mask with bit 18 set in t0
csrs mie, t0 # Sets bit 18 of the mie register to 1

#Set the mtvec register to be the interrupt_handler location
la t0, interrupt_handler
csrw mtvec, t0

/*Allow interrupts on the pushbutton's interrupt mask register, and any 
#additional set up for the pushbuttons */
li t1, PUSH_BUTTON # Address of KEY registers base into t1
li t0, 0b1111 # Enable all keys
sw t0, 8(t1) # Set interrupt enable in interrupt mask reg for Key 1
sw t0, 12(t1) # Clear Edge Capture bit of Key 1 in case it is already on

#Now that everything is set, turn on Interrupts in the mstatus register
li   t0, 0b1000 # Turn on bit 3 of reg t0   
csrs mstatus, t0 # Turn on bit 3 of mstatus to re-enable interrupts

IDLE: j IDLE #Infinite loop while waiting on interrupt

interrupt_handler:
	addi sp, sp, -12
	
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw ra, 8(sp)
	
	li s0, 0x7FFFFFFF  
	csrr s1, mcause
	
	and s1, s1, s0
	li  s0,18
	bne s1, s0, end_interrupt
	
	jal KEY_ISR # If so call KEY_ISR
	
	end_interrupt:

	
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	
	addi sp, sp, 12
	

mret

KEY_ISR: 

#Your KEY_ISR code here

# Save registers used in the interrupt service routine on stack
    addi sp, sp, -36
    sw   ra, 0(sp)
    sw   t0, 4(sp)
    sw   t1, 8(sp)
    sw   t2, 12(sp)
    sw   t3, 16(sp)
    sw   t4, 20(sp)
    sw   t5, 24(sp)
    sw   a0, 28(sp)
    sw   a1, 32(sp)

	# Checking for key press
	li t0, PUSH_BUTTON
	lw t1, 12(t0) # Read the edge capture
	andi t1, t1, 0xF # Only keep bits for key 3->0
	beq t1, zero, after_key # If no key exit loop

	sw t1, 12(t0) # Clear edge capture

	# Read current HEX display values
	li t2, HEX_BASE1
    lw t3, 0(t2)    

	j check_0 # Proceed to checking which key was pressed

check_0:
    andi t4, t1, 0x1 # Check if key 0 pressed 
    beq  t4, zero, check_1

    andi t5, t3, 0xFF # Get HEX0 byte
    bne  t5, zero, blank_0 # Blank if not blanked 
    li   a1, 0 # Use HEX0
    li   a0, 0 # Display 0 on it
    call HEX_DISP
    j check_1

blank_0:
    li   a1, 0 # Set HEX0 to blank
    li   a0, 0x10
    call HEX_DISP
    j check_1

check_1:
    andi t4, t1, 0x2 # Check if key 1 pressed 
    beq  t4, zero, check_2

    srli t5, t3, 8 # Move HEX1 byte into low bits
    andi t5, t5, 0xFF # Get HEX1 byte
    bne  t5, zero, blank_1 # Blank if not blanked
    li   a1, 1 # Use HEX1
    li   a0, 1 # Display 1 on it
    call HEX_DISP
    j check_2

blank_1:
    li   a1, 1 # Set HEX1 to blank
    li   a0, 0x10
    call HEX_DISP
    j check_2

check_2:
    andi t4, t1, 0x4 # Check if key 2 pressed
    beq  t4, zero, check_3

    srli t5, t3, 16 # Move HEX2 byte into low bits
    andi t5, t5, 0xFF # Get HEX2 byte
    bne  t5, zero, blank_2 # Blank if not blanked
    li   a1, 2 # Use HEX2
    li   a0, 2 # Display 2 on it
    call HEX_DISP
    j check_3

blank_2:
    li   a1, 2 # Set HEX2 to blank
    li   a0, 0x10
    call HEX_DISP
    j check_3

check_3:
    andi t4, t1, 0x8 # Check if key 3 pressed 
    beq  t4, zero, after_key

    srli t5, t3, 24 # Move HEX3 byte into low bits
    andi t5, t5, 0xFF # Get HEX3 byte
    bne  t5, zero, blank_3 # Blank if not blanked
    li   a1, 3 # Use HEX3
    li   a0, 3 # Display 3 on it
    call HEX_DISP
    j after_key
blank_3:
    li   a1, 3 # Set HEX3 to blank
    li   a0, 0x10
    call HEX_DISP

after_key:

	# Restore saved registers and return
    lw   ra, 0(sp)
    lw   t0, 4(sp)
    lw   t1, 8(sp)
    lw   t2, 12(sp)
    lw   t3, 16(sp)
    lw   t4, 20(sp)
    lw   t5, 24(sp)
    lw   a0, 28(sp)
    lw   a1, 32(sp)
    addi sp, sp, 36
    ret

#From previously given code
HEX_DISP:   
		addi sp, sp, -16           # store the 4 registers being used in this subroutine on the stack
		sw s0,0(sp)
		sw s1,0x4(sp)
		sw s2,0x8(sp)
		sw s3,0xC(sp)
	
		la   s0, BIT_CODES         # starting address of the bit codes
	    andi     s1, a0, 0x10	       # get bit 4 of the input into r6
	    beq      s1, zero, not_blank 
	    mv      s2, zero
	    j       DO_DISP
not_blank:  andi     a0, a0, 0x0f	   # r4 is only 4-bit
            add      a0, a0, s0        # add the offset to the bit codes
            lb      s2, 0(a0)         # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			la       s0, HEX_BASE1         # load address
			li       s1,  4
			blt      a1,s1, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      a1, a1, s1            # if hex4 or hex5, we need to adjust the shift
			addi     s0, s0, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     a1, a1, 3             # hex*8 shift is needed
			addi     s3, zero, 0xff        # create bit mask so other values are not corrupted
			sll      s3, s3, a1 
			li     	 a0, -1
			xor      s3, s3, a0  
    		sll      a0, s2, a1            # shift the hex code we want to write
			lw    	 a1, 0(s0)             # read current value       
			and      a1, a1, s3            # and it with the mask to clear the target hex
			or       a1, a1, a0	           # or with the hex code
			sw    	 a1, 0(s0)		       # store back
END:			
			mv 		 a0, s2				   # put bit pattern on return register
			
			
			lw s0,0(sp)			# restore those same 4 registers from the stack.
			lw s1,0x4(sp)
			lw s2,0x8(sp)
			lw s3,0xC(sp)
			addi sp, sp, 16
			ret


.data
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end