/* Part 2: Binary counter with delay loops + edge-capture toggle (run/stop) */

.global _start
_start:

# Define the LEDs
.equ LEDs, 0xFF200000

# Define the KEY buttons
.equ KEY_BASE, 0xFF200050
.equ KEY_EDGE, 0xC 

li s0, 0 # Set counter value to 0 by default
li t2, LEDs
sw s0, 0(t2) # Display initial counter value on LEDs
la t0, KEY_BASE     
li s1, 0 # Register holding state (counting or stopped)

myloop:
    lw t1, KEY_EDGE(t0) # Read edge-capture 
    beq t1, zero, check # If no key event, skip toggle
    xori s1, s1, 1 # Toggle running flag
    sw t1, KEY_EDGE(t0) # Clear edge-capture bits by writing 1s (rewrite what was set)

check:
    beq s1, zero, delay # If stopped, do not increment counter
    addi s0, s0, 1 # Increment counter
    andi s0, s0, 0xFF # Keep lower 8 bits
    sw s0, 0(t2) # Update LEDs with new counter value

delay:
    call DELAY
    j myloop # Repeat forever

DELAY:
    li t3, 5000000 # Upper bound for delay
dloop:
    addi t3, t3, -1 # Countdown
    bne t3, zero, dloop # Loop until counter hits 0
    ret                  
