.global _start
_start:

#Load address of LED's data register into S0
.equ LEDs, 0xFF200000
li s0, LEDs

#Load address of KEY's data register into s1
.equ KEYs, 0xFF200050
li s1, KEYs

#Initalize register to count number displayed on LED, and write it once
li s2, 1
sw s2, (s0)

#s3 is used to determine whether display should be blanked or not (1 is blanked, 0 is normal)
li s3,0


#Polling loop
isKeyPressed:
	#Loading data register of Key to t1 so it can be changed
	lw t1, (s1)
	
	#Reading each bit from KEY data register with 1 being KEY0, 2 being KEY1, etc.
	beqz t1, isKeyPressed
	beq t1, 1, setOne
	beq t1, 2, incrementNum
	beq t1, 4, decrementNum
	beq t1, 8, blankLED

	
	
#Function of KEY0, checking if restoring from blank is needed first
setOne:
	beq s3, 1, restoreFromBlank
	li s2, 0x1
	sw s2, (s0)
	
	j keyRemove

#Function of KEY1 to add but ensure number less than 15
incrementNum:
	beq s3, 1, restoreFromBlank
	bge s2,15, keyRemove
	addi s2, s2, 1
	sw s2, (s0)
	
	j keyRemove
	
#Function of KEY2 to subtract but ensure number greater than 1
decrementNum:
	beq s3, 1, restoreFromBlank
	beq s2, 1, keyRemove
	addi s2,s2,-1
	sw s2, (s0)
	
	j keyRemove

#Function of KEY3 to display 0 on the LED
blankLED:
	li s2,0
	li s3, 1
	sw s2, (s0)
	
	j keyRemove
	

#Infinite polling loop to determine when key is released
keyRemove:
	lw t1, (s1)
	beqz t1, isKeyPressed
	j keyRemove

#If s3 = 1, then restore from 0 to display 1 on LED
restoreFromBlank:
	li s3, 0
	li s2, 1
	sw s2, (s0)
	j keyRemove


	
	
	
	
	



	