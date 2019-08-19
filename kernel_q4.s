.text

.global main

#setup code
main:
	#backup old handler address
	movsg $1, $evec
	sw $1, old_handler($0)
	#set handler to my handler
	la $1, interrupt_handler
	movgs $evec, $1
	
	#initialise tasks
	la $1, task1_pcb #$1 = address of the task1 pcb
	#set the stack pointer for the task
	la $2, task1_stack
	sw $2, pcb_sp($1)
	#set return address, goes to a subroutine which removes the task from the stack
	la $2, remove_from_queue
	sw $2, pcb_ra($1)
	#set entry point for task ($ear because when we return from exception, $ear is put into $pc)
	la $2, serial_main
	sw $2, pcb_ear($1)
	#set cctrl for task1
	addui $2, $0, 0x4d #timer enable, kernel enable, OK 1, IE 0, OI 1, 
	sw $2, pcb_cctrl($1)
	#set link for task1
	sw $1, pcb_link($1)
	
	#set current task to pcb1
	sw $1, current_task($0)
	
	#initalise timer
	#set load
	addui $1, $0, 24 #2400/100 = 24 (interrupt 100 times per second)
	sw $1, 0x72001($0)
	#enable timer, enable automatic restart
	addui $1, $0, 3
	sw $1, 0x72000($0)
	
	
	#load first task
	j load_context

remove_from_queue:
	

#Dispatcher
dispatcher:
	#save context
	#address of the current tasks pcb $13
	lw $13, current_task($0)
	#save general registers
	sw $1, pcb_reg1($13)
	sw $2, pcb_reg2($13)
	sw $3, pcb_reg3($13)
	sw $4, pcb_reg4($13)
	sw $5, pcb_reg5($13)
	sw $6, pcb_reg6($13)
	sw $7, pcb_reg7($13)
	sw $8, pcb_reg8($13)
	sw $9, pcb_reg9($13)
	sw $10, pcb_reg10($13)
	sw $11, pcb_reg11($13)
	sw $12, pcb_reg12($13)
	#reg 13 is in ers
	movsg $1, $ers
	sw $1, pcb_reg13($13)
	#other general registers
	#sp
	sw $sp, pcb_sp($13)
	#ra
	sw $ra, pcb_ra($13)
	#ear
	movsg $1, $ear
	sw $1, pcb_ear($13)
	#cctrl
	movsg $1, $cctrl
	sw $1, pcb_cctrl($13)
	

scheduler:
	#choose the next task
	lw $13, current_task($0)
	lw $13, pcb_link($13)
	sw $13, current_task($0)

load_context:
	#set tasks time slice amount
	addui $13, $0, 2
	sw $13, time_remaining($0)
	
	lw $13, current_task($0)
	#restore context of chosen task
	#reg13, ers will be moved to $13 after rfe
	lw $1, pcb_reg13($13)
	movgs $ers, $1
	#ear
	lw $1, pcb_ear($13)
	movgs $ear, $1
	#cctrl
	lw $1, pcb_cctrl($13)
	movgs $cctrl, $1
	
	#general registers
	lw $1, pcb_reg1($13)
	lw $2, pcb_reg2($13)
	lw $3, pcb_reg3($13)
	lw $4, pcb_reg4($13)
	lw $5, pcb_reg5($13)
	lw $6, pcb_reg6($13)
	lw $7, pcb_reg7($13)
	lw $8, pcb_reg8($13)
	lw $9, pcb_reg9($13)
	lw $10, pcb_reg10($13)
	lw $11, pcb_reg11($13)
	lw $12, pcb_reg12($13)
	
	#return from exception
	rfe

interrupt_handler:
	#check cause of interrupt
	movsg $13, $estat
	andi $13, $13, 0x0040
	#if it wasnt the timer go to old handler
	beqz $13, old_handler
	
	#else go to timer handler
timer_handler:
	#acknowledge interrupt
	lw $13, 0x72003($0)
	andi $13, $13, 2
	sw $13, 0x72003($0)
	#increment counter
	lw $13, counter($0)
	addui $13, $13, 1
	sw $13, counter($0)
	#decrease tasks time remaining
	lw $13, time_remaining($0)
	subui $13, $13, 1
	sw $13, time_remaining($0)
	#if time remaining is 0
	andi $13, $13, 0xFFFF
	#jump to dispatcher for the next task
	beqz $13, dispatcher
	
	#else return from exception
	rfe


.data
time_remaining: .word 0

	.equ pcb_link, 0
	.equ pcb_reg1, 1
	.equ pcb_reg2, 2
	.equ pcb_reg3, 3
	.equ pcb_reg4, 4
	.equ pcb_reg5, 5
	.equ pcb_reg6, 6
	.equ pcb_reg7, 7
	.equ pcb_reg8, 8
	.equ pcb_reg9, 9
	.equ pcb_reg10, 10
	.equ pcb_reg11, 11
	.equ pcb_reg12, 12
	.equ pcb_reg13, 13
	.equ pcb_sp, 14
	.equ pcb_ra, 15
	.equ pcb_ear, 16
	.equ pcb_cctrl, 17
	
.bss
current_task: .word
old_handler: .word
task1_pcb: .space 18
	.space 500
task1_stack:
task_queue: .space 50
