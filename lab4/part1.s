/* Program to display binary numbers on LEDs using push buttons */

.global _start
_start:

# Define the LEDs
.equ LEDs, 0xFF200000
li s0, 0 # Store 0 (blank) by default in LEDs
li t2, LEDs
sw s0, 0(t2)

# Define the KEY buttons
.equ KEY_BASE, 0xFF200050
la t0, KEY_BASE

poll:
    lw t1, 0(t0) # Read register of key input
    beq t1, zero, poll # Repoll if no key pressed
    bne s0, zero, check_0 # Proceed to check which key was pressed
    li s0, 1 # If display is blank then make it 1 after key press
    sw s0, 0(t2) # Load onto LEDs
    j release
check_0:
    andi t3, t1, 0x1 # Check bit 0 
    beq  t3, zero, check_1 # If bit 0 is nonzero, key0 was pressed
    j    key_0

check_1:
    andi t3, t1, 0x2 # Check bit 1
    beq  t3, zero, check_2 # If bit 1 is nonzero, key1 pressed
    j    key_1

check_2:
    andi t3, t1, 0x4 # Check bit 2
    beq  t3, zero, check_3 # If bit 2 is nonzero, key2 pressed
    j    key_2

check_3:
    andi t3, t1, 0x8 # Check bit 3
    beq  t3, zero, release # If bit 3 is nonzero, key3 pressed
    j    key_3

key_0:                      
    li  s0, 1      
    sw  s0, 0(t2) # Load 1 on the LEDs
    j   release

key_1:                     
    li  t4, 15
    beq s0, t4, release # If LEDs already have 15, can't add more (do nothing)
    addi s0, s0, 1 # Increase otherwise
    sw  s0, 0(t2) # Store new value on LEDs
    j   release

key_2:                     
    li  t4, 1   
    beq s0, t4, release # If LEDs already have 1, can't subtract more (do nothing)
    addi s0, s0, -1 # Decrease otherwise
    sw  s0, 0(t2) # Store new value on LEDs
    j   release

key_3:                     
    li  s0, 0
    sw  s0, 0(t2) # Blank the display (0)
    j   release

release:                  
    lw  t1, 0(t0) # Read key register
    bne t1, zero, release # If its not zero, keep waiting for release
    j   poll
