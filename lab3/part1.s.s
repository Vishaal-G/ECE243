/* Program to Count the number of 1’s in a 32-bit word,
located at InputWord */
.global _start
_start:
/* Put your code here */

#Register to keep track of value of input to shift each time
lw t0, InputWord

#Have a resiger that counts numnber of 1's
li t2,0



ifScanning:
	#t1 will be used to extract bit
	andi t1,t0,1
	
	srli t0, t0,1
	
	#t1 gives me either 0 or 1 so just add that to counter
	add t2,t2,t1
	
	
	#Use zero register to see when number is done
	bne t0, x0, ifScanning
	

#Use t3 to store address of Answer in memory and then write to it
la t3, Answer
sw t2, (t3)
j stop

		

stop: j stop
.data
InputWord: .word 0x4a01fead
Answer: .word 0