.global _start
_start:

#Load address of LED's data register into s0
.equ LEDs, 0xFF200000
li s0, LEDs

#Load address of KEY's data register into s1
.equ KEYs, 0xFF200050
li s1, KEYs

#Load address of KEY's edge capture register into s2
.equ edgeCapture, 0xFF20005C
li s2, edgeCapture

#Load address of timer status register into s5
.equ timerRegisters, 0xFF202000
li s5, timerRegisters

#Initalize register s3 to display LED counter number, and write it once
li s3, 0
sw s3, (s0)

#s4 is used to determine whether key button press stops or starts timer (1 = start, 0 = stop)
li s4, 1



#Timer Loop
Timer:
	#Loading data register of Key to t1 so it can be changed
	lw t1, (s2)
	
	
	#Check if any bit in edge capture register is 1, as thats how we know some key was pressed
	beqz t1, checkRun
	
	
	#If we get here, means some bit was 1 in edge capture. Flip the running state and write back value of t1 to edge capture register
	xori s4, s4, 1
	sw t1, (s2)

	j Timer

#Check if timer is start (1) or stop (0). If stop, go back to timer.
checkRun:
	beq s4, x0, Timer
	
	#Call subroutine
	call Delay
	
	#Display to LED's
	addi s3,s3,1 
	
	#keep counter to wrap after 255 to 0
	andi s3, s3, 0xFF
	sw s3, (s0) 
	
	j Timer
	


#Subroutine to create 0.25 second delay
Delay:
	#Use registers to store upper and lower bits of delay number
	li t0, 0x7840
	sw t0, 8(s5)
	
	li t0, 0x017D
	sw t0, 12(s5)
	
	#Set enable bit start in control register to 1 to start the timer
	li t0, 4
	sw t0, 4(s5)
	
	#Poll T0 bit in status register as that tells me when the counter is done
	poll:
		lw t0, (s5)
	
		#Extract TO bit
		andi t0,t0,1
		
		beqz t0, poll
	
	sw zero, (s5)
	
	ret
	
	
	





	
	