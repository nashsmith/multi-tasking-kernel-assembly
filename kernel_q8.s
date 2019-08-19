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
	#TASK1
	la $1, task1_pcb #$1 = address of the task1 pcb
	#set the stack pointer for the task
	la $2, task1_stack
	sw $2, pcb_sp($1)
	#set return address, goes to a subroutine which removes the task from the stack
	la $2, disable_task
	sw $2, pcb_ra($1)
	#set entry point for task ($ear because when we return from exception, $ear is put into $pc)
	la $2, rocks_main
	sw $2, pcb_ear($1)
	#set cctrl for task1
	addui $2, $0, 0x4d #timer enable, kernel enable, OK 1, IE 0, OI 1, 
	sw $2, pcb_cctrl($1)
	#set link for task1
	la $3, task2_pcb
	sw $3, pcb_link($1)
	#set the time slice for the task
	addui $3, $0, 20
	sw $3, pcb_slice($1)
	#set the task to enabled
	addui $3, $0, 1
	sw $3, pcb_enabled($1)
	
	#TASK2
	la $1, task2_pcb #$1 = address of the task2 pcb
	#set the stack pointer for the task
	la $2, task2_stack
	sw $2, pcb_sp($1)
	#set return address, goes to a subroutine which removes the task from the stack
	la $2, disable_task
	sw $2, pcb_ra($1)
	#set entry point for task ($ear because when we return from exception, $ear is put into $pc)
	la $2, parallel_main
	sw $2, pcb_ear($1)
	#set cctrl for task2
	addui $2, $0, 0x4d #timer enable, kernel enable, OK 1, IE 0, OI 1, 
	sw $2, pcb_cctrl($1)
	#set link for task2
	la $3, task1_pcb
	sw $3, pcb_link($1)
	#set the time slice for the task
	addui $3, $0, 2
	sw $3, pcb_slice($1)
	#set the task to enabled
	addui $3, $0, 1
	sw $3, pcb_enabled($1)
	
	#TASK3
	la $1, task3_pcb #$1 = address of the task2 pcb
	#set the stack pointer for the task
	la $2, task3_stack
	sw $2, pcb_sp($1)
	#set return address, goes to a subroutine which removes the task from the stack
	la $2, disable_task
	sw $2, pcb_ra($1)
	#set entry point for task ($ear because when we return from exception, $ear is put into $pc)
	la $2, serial_main
	sw $2, pcb_ear($1)
	#set cctrl for task2
	addui $2, $0, 0x4d #timer enable, kernel enable, OK 1, IE 0, OI 1, 
	sw $2, pcb_cctrl($1)
	#set link for task2
	la $3, task1_pcb
	sw $3, pcb_link($1)
	#set the time slice for the task
	addui $3, $0, 2
	sw $3, pcb_slice($1)
	#set the task to enabled
	addui $3, $0, 1
	sw $3, pcb_enabled($1)
	
	
	#set current task to pcb1
	la $1, task1_pcb
	sw $1, current_task($0)
	
	#set cctrl
	#addui $1, $0, 0x4d
	#movgs $cctrl, $1
	
	#initalise timer
	#set load
	addui $1, $0, 24 #2400/100 = 24 (interrupt 100 times per second)
	sw $1, 0x72001($0)
	#enable timer, enable automatic restart
	addui $1, $0, 3
	sw $1, 0x72000($0)
	
	
	#load first task
	j load_context

disable_task:
	lw $13, current_task($0)
	sw $0, pcb_enabled($13)
	j dispatcher

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
	j scheduler
	
scheduler:
	#choose the next task
	lw $13, current_task($0)
	lw $13, pcb_link($13)
	sw $13, current_task($0)
	#check if its enabled
	lw $13, pcb_enabled($13)
	#if disabled find new task to run
	beqz $13, scheduler
	j load_context

load_context:
	lw $13, current_task($0)
	#set tasks time slice amount
	lw $13, pcb_slice($13)
	sw $13, time_remaining($0)
	
	lw $13, current_task($0)
	#restore context of chosen task
	#cctrl
	addui $1, $0, 0x4d
	movgs $cctrl, $1
	#reg13, ers will be moved to $13 after rfe
	lw $1, pcb_reg13($13)
	movgs $ers, $1
	#ear
	lw $1, pcb_ear($13)
	movgs $ear, $1
	
	
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
	andi $13, $13, 0x40
	#if it was the timer go to old handler
	bnez $13, timer_handler
	#else go to timer handler
	lw $13, old_handler($0)
	jr $13
	
timer_handler:

	#acknowledge interrupt
	lw $13, 0x72003($0)
	andi $13, $13, 2
	sw $13, 0x72003($0)
	
	#decrease tasks time remaining
	lw $13, time_remaining($0)
	subui $13, $13, 1
	sw $13, time_remaining($0)
	#if time remaining is 0
	#andi $13, $13, 0xFFFF
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
	.equ pcb_slice, 18
	.equ pcb_enabled, 19
	
.bss
current_task: 
	.word
old_handler: 
	.word
task1_pcb: 
	.space 20
	
	.space 500
task1_stack:
task2_pcb: 
	.space 20
	
	.space 100
task2_stack:
task3_pcb: 
	.space 20
	
	.space 500
task3_stack:
