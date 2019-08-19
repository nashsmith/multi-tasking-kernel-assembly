.text

.global main

main:	
	#Set interupt enabled bit and timer interupt mask
	addui $3, $0, 0x0042
	movsg $4, $cctrl
	or $4, $3, $4
	movgs $cctrl, $4
	
	#enable timer
	addui $3, $0, 3
	#set timer enabled bit and automatic restart bit
	sw $3, 0x72000($0)
	
	#set load (2400 per second/100 = 24)
	addui $3, $0, 24
	sw $3, 0x72001($0)
	
	#backup old interrupt handler
	movsg $3, $evec
	sw $3, old_handler($0)
	#set new handler
	la $3, interrupt_handler
	movgs $evec, $3
	
	jal serial_main
	
interrupt_handler:
	#check if its timer interrupt
	movsg $13, $estat
	andi $13, $13, 0x0040
	#if not go to old handler
	beqz $13, old_handler
	#if it is, go to timer handler
	j timer_handler
	
	
	
timer_handler:
	#backup 2 registers so i can use them
	subui $sp, $sp, 2
	sw $12, 0($sp)
	sw $11, 1($sp)
	
	#handler
	lw $12, counter($0)
	addui $12, $12, 1
	sw $12, counter($0)

	#restore registers
	lw $12, 0($sp)
	lw $11, 1($sp)
	addui $sp, $sp, 2
	
	#acknowledge interrupt
	lw $13, 0x72003($0)
	andi $13, $13, 2
	sw $13, 0x72003($0)
	
	rfe
	
.data
	old_handler: .word 0
