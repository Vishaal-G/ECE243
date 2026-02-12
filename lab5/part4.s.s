.global _start
_start:

	.equ LEDs,  0xFF200000
	.equ TIMER, 0xFF202000
	.equ KEYs, 0xFF200050
	.equ MIN_LIMIT, 50000
	.equ MAX_LIMIT, 900000
	

	#Set up the stack pointer
	li sp, 0x20000
	
	jal    CONFIG_TIMER        # configure the Timer
    jal    CONFIG_KEYS         # configure the KEYs port
	
	/*Enable Interrupts in the NIOS V processor, and set up the address handling
	location to be the interrupt_handler subroutine*/
	la t0, interrupt_handler
	csrw mtvec, t0 #mtvec tells me the address to go to in case of interrupt
	
	li t0, 0x10000 #Enables bit 16 in mie register
	csrs mie, t0
	
	li t0, 0x40000    #Enables bit 18 in mie register
	csrs mie, t0
	
	csrsi mstatus, 0x8   # global interrupt enable


	li s0, LEDs
	la s1, COUNT #Whatever number should be displayed on counter
	la s3, RUN #Should the counter move or freeze gets toggled
	
	LOOP:
		lw     s2, 0(s1)          # Get current count
		sw     s2, 0(s0)          # Store count in LEDs
	j      LOOP



interrupt_handler:
    addi sp, sp, -16 #Create space on stack
    sw   s0, 0(sp)
    sw   s1, 4(sp)
    sw   ra, 8(sp)
    sw   s2, 12(sp)

    
    csrr t1, mcause     #Tells us which IRQ got interrupted
    li   t0, 0x7FFFFFFF
    and  t1, t1, t0          # keep only exception/irq code and remove interrupt bit

    li   t0, 16               # If IRQ is Timer's deal with it
    beq  t1, t0, handle_timer

    li   t0, 18               # if IRQ is Key's deal with it
    beq  t1, t0, handle_keys

    j    end_interrupt

handle_timer:
    jal  TIMER_ISR #Jumps to timer ISR and stores return address in ra
    j    end_interrupt

handle_keys:
    jal  KEY_ISR #Jumps to KEY ISR and stores return address in ra
    j    end_interrupt

end_interrupt:
    lw   s0, 0(sp) #Restore registers and free stack space
    lw   s1, 4(sp)
    lw   ra, 8(sp)
    lw   s2, 12(sp)
    addi sp, sp, 16
    mret


CONFIG_TIMER: 
    li  t0, TIMER #Loads the timer address into t0

    # load 32-bit period = ticks for 0.25s
	la t6, PERIOD
    lw  t1, 0(t6)       

    # write low 16 bits and high 16 bits to timer
    li  t2, 0xFFFF
    and t3, t1, t2            # low 16
    srli t4, t1, 16           # high 16
    sw  t3, 8(t0)             # store low order bits to timer
    sw  t4, 12(t0)            # store high order bits to timer

    # clear any pending timeout bit
    sw  zero, 0(t0)       

    # Enables START CONT and ITO bit
    li  t5, 0x7
    sw  t5, 4(t0)

    ret

TIMER_ISR:
    li  t0, TIMER #Load timer address
    sw  zero, 0(t0)      # clear TO timeout flag
    lw  t1, 0(s1)        # get current number in COUNT
    lw  t2, 0(s3)        # get current state of RUN bit
    add t1, t1, t2       # Add one more to counter
    andi t1, t1, 0xFF    # wrap counter at 255 -> 0
    sw  t1, 0(s1)        # store COUNT back to memory

    ret




CONFIG_KEYS: 
    li  t0, KEYs
    li  t1, 0xF            #Enables all KEY to be interrupted
    sw  t1, 8(t0)          # enable KEY interrupts
    sw  t1, 12(t0)         # clear edge capture registers
    ret


	
KEY_ISR:
	li  t4, KEYs 		#Load key into t4
	lw  t1, 12(t4)      # Checks whick key was pressed
	
	sw  t1, 12(t4)       # clear edge capture register
	
	#Check KEY0
	andi t2,t1, 1 
	bnez t2, key0
	
	#Check KEY1
	andi t2, t1, 2
	bnez t2, key1

	#Check KEY2
	andi t2, t1, 4
	bnez t2, key2



	


key0:
	lw  t0, 0(s3)        # Get RUN to flip the bit
	xori t0, t0, 1       # toggle the RUN bit
	sw  t0, 0(s3)	 # Store it back to memory
	j done

key1:

    # Stop timer
    li   t0, TIMER
    sw   zero, 4(t0)

    # Load PERIOD
    la   t6, PERIOD
    lw   t1, 0(t6)

    # Divide by 2
    srli t1, t1, 1 #Same as shifting right as each bit is 2^x

    # Check minimum limit
    li   t2, MIN_LIMIT
    blt  t1, t2, skip_update

    # Store new PERIOD
    sw   t1, 0(t6)

    # Split high/low
    li   t3, 0xFFFF #Isolates lower 16 bits
    and  t4, t1, t3 #Keeps only lower 16 bits
    srli t5, t1, 16 #Shifts to only kep upper 16 bits
    sw   t4, 8(t0) #Put lower bits in correct half
    sw   t5, 12(t0) #Put upper bits in correct half

skip_update:
    # Restart timer
    li   t2, 0x7 #Makes START=1, CONT=1, ITO=1
    sw   t2, 4(t0)

    j done

key2:
    # Stop timer
    li   t0, TIMER
    sw   zero, 4(t0)

    # Load PERIOD
    la   t6, PERIOD
    lw   t1, 0(t6)

    # Multiply by 2
    slli t1, t1, 1 #Same as shifting left as each bit is 2^x

    # Check max limit
    li   t2, MAX_LIMIT
    bgt  t1, t2, skip_update2

    # Store new PERIOD
    sw   t1, 0(t6)

    # Split high/low
    li   t3, 0xFFFF #Isolates lower 16 bits
    and  t4, t1, t3 #Keeps only lower 16 bits
    srli t5, t1, 16 #Shifts to only kep upper 16 bits
    sw   t4, 8(t0) #Put lower bits in correct half
    sw   t5, 12(t0) #Put upper bits in correct half

skip_update2:
    # Restart timer
    li   t2, 0x7 #Makes START=1, CONT=1, ITO=1
    sw   t2, 4(t0)

    j done



	
	
	
	
	
	
done:
	 ret


.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.global PERIOD
PERIOD: .word 25000000 #Create new global variable for period timer
.end
