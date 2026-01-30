/* Program to Count the number of 1’s in a 32-bit word,
located at InputWord */
.global _start
_start:
/* Put your code here */

#Register to keep track of value of input to shift each time
lw a0, InputWord

#Create the stack pointer
li sp, 0x20000

call ONES

#Use t3 to store address of Answer in memory and then write to a0
la t3, Answer
sw a0, 0(t3)

		
stop: j stop

#Subroutine
ONES:
	#Allocate space onto the stack, and save return address
	addi sp,sp,-4
	sw ra, 0(sp)
	
	#t2 is counter for number of 1's
	li t2,0
loop:
	#t1 will be used to extract bit
	andi t1,a0,1
	srli a0, a0,1
	
	#t1 gives me either 0 or 1 so just add that to counter
	add t2,t2,t1
	
	
	#Use zero register to see when number is done
	bne a0, x0, loop
	
	mv a0, t2
	
	#After subroutine, restore old return address
	lw ra, 0(sp)
	addi sp,sp,4
	ret
.data
InputWord: .word 0x4a01fead
Answer: .word 0