/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	
	/* Put your code here */
    la t0, InputWord # Load the address of InputWord into reg t0
    lw a0, (t0) # Load word given at address InputWord
    call ONES
    la s0, Answer # Load address of Answer into reg s0
    sw a0, (s0)

stop: j stop

ONES:
    li t2, 0 # Count all ones
    li t3, 32 # Total number of bits (upper limit of loop)
    myloop: 
        beq t3, zero, finished # Condition if all bits are counted
        andi t4, a0, 1 # AND between LSB and binary 1
        add t2, t2, t4 # Increase counter if LSB = 1 or do nothing
        srli a0, a0, 1  # Shift to check the next bit
        addi t3, t3, -1 # Count down from 32 
        j myloop
    finished: 
        mv a0, t2 # a0 now stores number of 1's
        ret

.data
InputWord: .word 0x4a01fead

Answer: .word 0