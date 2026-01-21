.global _start
_start: 
	li t0, 1	# Start at 1
	li t1, 30	# Add all numbers up to including 30
	li s1, 0	# Register storing sum
myloop: 
	add s1, s1, t0		# Add reg 0 value into sum reg
	addi t0, t0, 1		# Increase index/next number
	ble t0, t1, myloop	# Check if reg t0 < t1, if so loop again
done: 
 	j done	# Otherwise infinitely run done command
	