.global _start

.equ KEY, 0xff20005C
.equ LED, 0xff200000
.equ COUNTER_DELAY, 1000000
.equ TIMER_BASE, 0xff202000


_start:
	la sp, 0x20000
	la s0, LED               
	la s1, KEY    
	mv s3, zero #init the seconds
	mv s5, zero #init the hundreths of seconds
	li s4, 1 #running/paused
 
	
	la s2, TIMER_BASE # Interval timer
	sw zero, (s2) # make sure to init to zero incase there was something there before
	
	li t0, COUNTER_DELAY
	
	sw t0, 8(s2) # store low 16 bits
	
	srli t0, t0, 16
	sw t0, 12(s2) # store high 16 bits
	
	li t0, 0b0110 # cont=1 start=1
	sw t0, 4(s2) # put the above into the control register
	
	poll:
		lw t0, (s2)
		andi t0, t0, 1 # isolate the 0th bit
		beqz t0, poll
		
		sw zero, (s2) # reset TO after detecting a 1

		mv a0, s1 # move EDGECAPTURE address before checking if key was pressed
		call check_press # see if a key was pressed
		beq a0, zero, after_key

		xori s4, s4, 1 # toggle running/paused

	after_key:
		beq s4, zero, poll   # we're paused so dont increase the countn and poll TO again

		# not paused
		mv a0, s3 
		mv a1, s5
		call count # increse the count for the LEDS
		mv s3, a0
		mv s5, a1

		mv t1, s3
		slli t1, t1, 7
		add t1, t1, s5
		
		sw t1, (s0) # update the count to the LEDS
		j poll
		


	count:
		mv t0, a0 # get the seconds
		mv t1, a1 # get the hundreths
		
		
		li t2, 99 #constant
		
		bne t1, t2, increment_hundreth # if we dont reach 99 hundreths, then increment
		
		increment_second: # means we have 99 hundreths
			li t3, 7
			mv a1, zero # set hundreths to 0
			beq t0, t3, reset_time # see if we reached 7 seconds
			addi t0, t0, 1 #increase seconds
			
			mv a0, t0
			ret
		
		reset_time: # go from 7.99 to 0 seconds
			mv a0, zero 
			ret
		
		increment_hundreth: addi t1, t1, 1
		# return numbers
		mv a1, t1
		mv a0, t0
		ret		
	
	
	check_press: 
		lw t0, (a0)
		andi t0, t0, 15 # get bottom 4 bits
		
		beqz t0, not_pressed
		
		# check each bit and then reset only that bit
		li t1, 1
		beq t0, t1, reset_capture 

		li t1, 2
		beq t0, t1, reset_capture

		li t1, 4
		beq t0, t1, reset_capture

		li t1, 8
		beq t0, t1, reset_capture
		
		reset_capture: 
			sw t1, (a0)
			li a0, 1
			ret
		not_pressed:
			mv a0, zero
			ret
		
		
		
			
			
			
			
			
			
			
		
