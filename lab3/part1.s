/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	
	/* Put your code here */
    la t0, InputWord # Load the address of InputWord into reg t0
    lw t1, (t0) # Load word given at address InputWord
    la s0, Answer # Load address of Answer into reg s0
    li t2, 0 # Count all ones
    li t3, 32 # Total number of bits (upper limit of loop)

    myloop: 
        beq t3, zero, finished # Condition if all bits are counted
        andi t4, t1, 1 # AND between LSB and binary 1
        add t2, t2, t4 # Increase counter if LSB = 1 or do nothing
        srli t1, t1, 1  # Shift to check the next bit
        addi t3, t3, -1 # Count down from 32 
        j myloop
    finished: 
        sw t2, (s0) # Store count of 1's into the address given by Answer
        j stop
    stop: j stop

.data
InputWord: .word 0x4a01fead

Answer: .word 0