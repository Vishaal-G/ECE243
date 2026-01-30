/* Program to Count the number of 1’s and Zeroes in a sequence of 32-bit words,
and determines the largest of each */
.global _start
.equ LEDs, 0xFF200000
_start:
/* Your code here */

#Create the stack pointer
li sp, 0x20000

#Register to keep track of value of input to shift each time
la s2, TEST_NUM

#s0 is biggest 1's, s1 is biggest 0's
li s0, 0
li s1, 0

#Loop while value in array is not 0
notZero:
	#load word and see if word is zero
	lw s3, 0(s2)
	beq s3, x0, done
	
	#call subroutine will return current number's 1 in a0 
	mv a0, s3
	call ONES
	
	#If current max > then return value, just skip ahead
	bge s0, a0, skip1
	mv s0, a0

skip1:
	#count zeros
	lw s4, 0(s2)
	
	#Flip bit so we can use the same one's calling subroutine
	xori s4, s4,-1
	
	#call subroutine will return current number's 0 in a0
	mv a0, s4
	call ONES
	
	bge s1, a0, skip2
	mv s1,a0

skip2:
	#Go to next word and loop back
	addi s2,s2,4
	j notZero
	

done:
	#Use t3 to store address of Answer in memory and then write to a0
	la t3, LargestOnes
	sw s0, 0(t3)

	#Use a4 to store LargestZeroes
	la t4, LargestZeroes
	sw s1, 0(t4)
		
la s2, LEDs
display:
	#Display LargestOnes, and copy only 10 lower order bits
	andi t0, s0, 0x3FF
  	sw t0,0(s2)
	call Delay

	
	#Display LargestZeroes
	andi t1, s1, 0x3FF
  	sw t1,0(s2)
	
	call Delay
	
	j display


#Subroutines
ONES:
    addi sp, sp, -4
    sw   ra, 0(sp)

    li t2, 0

loop:
    andi t1, a0, 1
    add  t2, t2, t1
    srli a0, a0, 1
    bne  a0, x0, loop
	
	#convention to store return value in registers a0-a7
	mv a0, t2
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

Delay:
	#Put big number and just wait until it runs out
    li t0, 10000000   

dloop:
    addi t0, t0, -1
    bne  t0, x0, dloop
    ret

#Real processor is faster as CPULator is emulator and simulates each instruction in software, where as real CPU can execute the instruction directly from the hardware





.data
TEST_NUM: .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
.word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
.word 0 # end of list
LargestOnes: .word 0
LargestZeroes: .word 0