.global _start
_start:

	.equ LEDs, 0xFF200000
	.equ TIMER, 0xFF202000

	#Set up the stack pointer
	li sp, 0x20000 # set up stack pointer

	jal    CONFIG_TIMER        # configure the Timer
    jal    CONFIG_KEYS         # configure the KEYs port
	
	/*Enable Interrupts in the NIOS V processor, and set up the address handling
	location to be the interrupt_handler subroutine*/
	    
	# Set mtvec to interrupt handler
	la t0, interrupt_handler
	csrw mtvec, t0

	li t0, 0b1000 # Turn on bit 3 of reg t0   
	csrs mstatus, t0 # Turn on bit 3 of mstatus to re-enable interrupts

	la s0, LEDs
	la s1, COUNT
	
	LOOP:
		lw     s2, 0(s1)          # Get current count
		sw     s2, 0(s0)          # Store count in LEDs
	j      LOOP

interrupt_handler:
	#Code not shown

	# Save regs used in interrupt_handler on stack
	addi sp, sp, -12
	sw t0, 0(sp)
	sw t1, 4(sp)
	sw ra, 8(sp)

	csrr t1, mcause # Read mcause to find interrupt source
	li t0, 0x7FFFFFFF 
	and t1, t1, t0 # Get the top bit (the interrupt type)

	# Check if interrupt came from timer
	li t0, 16
	beq t1, t0, cause_timer

	# Check if interrupt came from keys
	li t0, 18
	beq t1, t0, cause_keys

	j end_interrupt

cause_timer: # The cause was the timer, so jump to handler
	jal TIMER_ISR
	j end_interrupt

cause_keys: # The cause was the key, so jump to handler
	jal KEY_ISR

end_interrupt:

	# Restore registers used in routine from stack
	lw t0, 0(sp)
	lw t1, 4(sp)
	lw ra, 8(sp)
	addi sp, sp, 12
	mret

KEY_ISR:

	# Save registers used in KEY_ISR on stack
	addi sp, sp, -20
	sw ra, 0(sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	sw t3, 16(sp)

	# Read which key causes interrupt
	li t0, 0xFF200050 # KEY_BASE
	lw t1, 12(t0) # Read edge capture reg
	andi t1, t1, 0xF # Keep only lower 4 bits
	beq t1, zero, key_done # Key was not pressed
	sw t1, 12(t0) # Clear edge capture

	# Toggle run
	la t2, RUN
	lw t3, 0(t2)
	xori t3, t3, 1
	sw t3, 0(t2)

key_done:

	# Restored registers used from the stack
	lw ra, 0(sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	lw t2, 12(sp)
	lw t3, 16(sp)
	addi sp, sp, 20
	ret

TIMER_ISR:

	# Save registers used in TIMER_ISR
	addi sp, sp, -20
	sw ra, 0(sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	sw t3, 16(sp)

	li t0, TIMER
	sw zero, 0(t0) # Clear TO bit

	# Check RUN value 
	la t1, RUN
	lw t2, 0(t1)
	beq t2, zero, timer_done # If run=0 do nothing

	# If run=1, we increase count
	la t1, COUNT
	lw t3, 0(t1)
	li t2, 255
	beq t3, t2, reset_count # If the count = 255, reset
	addi t3, t3, 1 # Increase count
	sw t3, 0(t1)
	j timer_done

reset_count:
	sw zero, 0(t1)

timer_done:
	# Restore registers used in stack
	lw ra, 0(sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	lw t2, 12(sp)
	lw t3, 16(sp)
	addi sp, sp, 20
	ret

CONFIG_TIMER:

	#Code not shown
	li t1, TIMER # Interval timer base
	sw zero, 0(t1) # Clear status in case it was set
	li t0, 12500000 # 0.25s, 50 MHz

	sw t0, 8(t1) # Writing low into PERIODL
	srli t0, t0, 16 # Shift over to high 16
	sw t0, 12(t1) # Writing high 16 bits into PERIODH

	li t0, 0b0111 # Set ITO=1, CONT=1, START=1
	sw t0, 4(t1) # Write control register

	# Enable timer interrupts on CPU side 
	li t0, 0x00010000
	csrs mie, t0 # Set bit 16 of mie to 1
	ret

CONFIG_KEYS:

	#Code not shown
	li t1, 0xFF200050 # Address of KEY registers base into t1
	li t0, 0b1111 # Enable all keys
	sw t0, 8(t1) # Set interrupt enable in interrupt mask reg for Keys
	sw t0, 12(t1) # Clear Edge Capture bit of Keys in case it is already on

	# Enable KEY interrupts in mie (KEYs are IRQ18)
	li t1, 0x40000 
	csrs mie, t1
	ret


.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end
