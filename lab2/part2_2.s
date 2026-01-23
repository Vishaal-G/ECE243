.global _start
_start:

# s3 should contain the grade of the person with the student number, -1 if not found
# s0 has the student number being searched

    li s0, 718293
	li t0, 0 # Set a register to hold the index
	la t1, Snumbers # Pointer to array of student numbers
	la s1, result # Pointer to where grade is stored

# Your code goes below this line and above iloop

# Connect output to LEDs
.equ LEDs, 0xFF200000

myloop:
	lw t2, 0(t1) # Load current student number into register t2
	beq t2, zero, failed # Didn't find student number
	beq t2, s0, found # Found the student number
	addi t0, t0, 1 # Increase the index
	addi t1, t1, 4 # Go to the next student number
	j myloop # Loop again

found:
    la t3, Grades # Pointer to array of student grades
    add  t3, t3, t0 # Pointer to student 718293's grade
    lb s3, 0(t3) # Load the grade byte into s3
    sb  s3, 0(s1) # Store the grade into result

    # Display result on LEDs
    li  t4, LEDs
    lb  t5, 0(s1)      
    sw  t5, 0(t4)
   
    j iloop
   
failed:
    li  s3, -1  # Return -1
    sb  s3, 0(s1) # Store -1 into result

    # Display result on LEDs
    li  t4, LEDs
    lb  t5, 0(s1)      
    sw  t5, 0(t4)  
   
iloop: j iloop

/* result should hold the grade of the student number put into s0, or
-1 if the student number isn't found */

result: .byte 0 # Result is a byte
.skip 3
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .byte 99, 68, 90, 85, 91, 67, 80
        .byte 66, 95, 91, 91, 99, 76, 68  
        .byte 69, 93, 90, 72