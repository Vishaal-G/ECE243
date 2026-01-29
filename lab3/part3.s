/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

.global _start
_start:

/* Your code here  */
la s0, TEST_NUM # Pointer to first element of array
li s1, 0 # store max number of ones
li s2, 0 # Store max number of zeros

la s3, LargestOnes # Load address of LargestOnes into reg s3
la s4, LargestZeroes # Load address of LargestOnes into reg s4

loop:
    lw a0, 0(s0) # Load current word in array into register
    beq a0, zero, done # Reached the end of the array
    call ONES # Call ONES subroutine on current word
    ble a0, s1, zeroes # Go straight to counting zeroes if no new max # of ones
    mv s1, a0 # Store the new max # of ones into s1
    
zeroes:
    lw a0, 0(s0) # Load current word again since a0 was modified
    xori a0, a0, -1 # Flip bits of current word
    call ONES # Call ONES subroutine on flipped bits of current word (returns # of zeroes)
    addi s0, s0, 4 # Increase index to the next word in array
    ble a0, s2, loop # Immediately loop if no new max # of zeroes
    mv s2, a0 # Store the new max # of zeroes into s2
    j loop 

done:
    sw s1, (s3) # Store max # of ones at address LargestOnes
    sw s2, (s4) # Store max # of zeroes at address LargestZeroes

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
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0