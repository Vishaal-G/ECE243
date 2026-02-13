.global _start
_start:

li s4, 0b0000 #s4 stores if each hex should be toggled (1 is display blank vs 0 is number)


.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030

.equ PUSH_BUTTON, 0xFF200050

#Your code goes below here:

#Your code should:

#Turn off interrupts in case an interrupt is called before correct set up
    csrci mstatus, 0x8          # clear MIE bit 3 (global interrupt enable)

#Initialize the stack pointer
    li   sp, 0x20000

#activate interrupts from IRQ18 (Pushbuttons)
    li t0,0x40000 #Sets bit 18 = 1
    csrs mie, t0                # mie is register for specific interrupt numbers, enable interrupt source 18, sets bits in mie that are 1 in t0

#Set the mtvec register to be the interrupt_handler location
    la   t0, interrupt_handler #Loads address of interrupt handler
    csrw mtvec, t0 #sets up interrupt vector

/*Allow interrupts on the pushbutton's interrupt mask register, and any 
#additional set up for the pushbuttons */
    la   t0, PUSH_BUTTON
    li   t1, 0xF                # enable KEY3-KEY0
    sw   t1, 8(t0)              # interrupt mask register (offset 8)
    sw   t1, 12(t0)             # clear any pending edge-capture (offset 12)

#Now that everything is set, turn on Interrupts in the mstatus register
    csrsi mstatus, 0x8          # set MIE bit (global interrupt enable) turn it on

IDLE: j IDLE #Infinite loop while waiting on interrupt

interrupt_handler:
	addi sp, sp, -12
	
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw ra, 8(sp)
	
	li s0, 0x7FFFFFFF  
	csrr s1, mcause
	
	and s1, s1, s0
	li  s0,18
	bne s1, s0, end_interrupt
	
	jal KEY_ISR # If so call KEY_ISR
	
	end_interrupt:

	
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	
	addi sp, sp, 12
	

mret

KEY_ISR: 

	#Your KEY_ISR code here
	
	#read edge capture register
	la t0, PUSH_BUTTON #Gets the push button data register into t0
	lw t1, 12(t0) #Puts push button edge capture register into t1
    
	#Check KEY0
	andi t2,t1, 1 
	bnez t2, key0
	
	#Check KEY1
	andi t2, t1, 2
	bnez t2, key1

	#CHeck KEY2
	andi t2, t1, 4
	bnez t2, key2

	#Check KEY3
	andi t2, t1, 8
	bnez t2, key3

    j exit                      # (prevents fall-through if nothing matched)
	
	
	key0:
		xori s4, s4, 1 #Flip toggled bit
		andi t2, s4, 1  #Check if blank or to display number
		li a1, 0 #load hex to be displayed on
		bnez t2, displayBlank
		li a0, 0 #load digit
		call HEX_DISP
		sw t1, 12(t0) #Clear edge capature register
		j exit
		
	
	key1:
		xori s4, s4, 2 #Flip toggled bit
		andi t2, s4, 2 #Check if blank or to display number
		li a1, 1 #load hex to be displayed on
		bnez t2, displayBlank
		li a0, 1 #load digit
		call HEX_DISP
		sw t1, 12(t0) #Clear edge capature register
		j exit
		
	key2:
		xori s4, s4, 4 #Flip toggled bit
		andi t2, s4, 4 #Check if blank or to display number
		li a1, 2 #load hex to be displayed on
		bnez t2, displayBlank
		li a0, 2 #load digit
		call HEX_DISP
		sw t1, 12(t0) #Clear edge capature register
		j exit
	key3:
		xori s4, s4, 8 #Flip toggled bit
		andi t2, s4, 8 #Check if blank or to display number
		li a1, 3 #load hex to be displayed on
		bnez t2, displayBlank
		li a0, 3 #load digit
		call HEX_DISP
		sw t1, 12(t0) #Clear edge capature register
		j exit
	
	displayBlank:
		li a0, 0x10 #blank flag in subroutine
		call HEX_DISP
		sw t1, 12(t0) #Clear edge capature register (needed when blank path taken)
		j exit
		
		
		
	exit:
		ret
