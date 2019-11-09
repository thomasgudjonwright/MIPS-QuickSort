#studentName:	Thomas Wright
#studentID:	260769898

# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
#any any data you need be after this line
welcome: .asciiz "Welcome to QuickSort! Please enter your array and a command.\n"
thesort: .asciiz "\nThe sorted array is:  "
reanit: .asciiz "\nThe array has been reinitialized!\n"
.align 2
array: .space 40	# this will hold the integer array
string:	.space 31	# this holds the int array converted to a string
int: .space 4	# temp buffer for each integer we are adding to the array

	.text
	.globl main
#-------------------------------------------------------------------
main:	# all subroutines you create must come below "main"
	la $s0, array	# s0 contains int array
	la $s1, int	# s1 contains value changing to integer
	la $s2, welcome	# welcome message
	la $s3, thesort	# sorted message
	la $s4, reanit	# reanitialized message
	la $s5, string	# s5 contains string of array contents
	li $s6, 0	# s6 will be the current length of the array
	
	
prntwel:	lb $a0, 0($s2)	# printing welcome message
		beq $a0, $zero, echo
		jal write
		addi $s2, $s2, 1
		j prntwel
#-------------------------------------------------------------------			
echo:	jal read		# reading and writing using MMIO
	add $a0,$v0,$zero	# in an infinite loop
	
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	jal addtoint	# adding character to turn into an integer
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	beq $a0, 99, reinitialize	# <c>
	beq $a0, 113, quit	# <q>
	beq $a0, 115, sort	# <s>
	jal write
	j echo
#---------------------------------------------------------
read:  	lui $t0, 0xffff 	# stores ffff0000 in t0
loop1:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,loop1
	lw $v0, 4($t0) 		#data	
	jr $ra

write:  lui $t0, 0xffff 	#ffff0000
loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,loop2
	sw $a0, 12($t0) 	#data
	jr $ra
#----------------------------------------------------------------
# this section adds an input to an integer and adds it to the int array:	
addtoint:	ble $a0, 47, gotint
		bge $a0, 58, gotint	# if char isn't an int then we have full integer
		sb $a0, 0($s1)	# storing the bit to int
		addi $s1, $s1, 1	# increment temp buffer pointer
		jr $ra
		
gotint:		la $t0, int	# reset pointer to start of temp
		sub $t0, $s1, $t0	# if not a digit and at start of array
		beq $t0, 0, storedint	# not an integer to add 

		li $a0, 32
		sb $a0, 0($s1)	# storing the bit to int
		la $s1, int 	# pointing back to the start
		lb $t3, 1($s1)
		blt $t3, 48, onedig
		bgt $t3, 57, onedig
		
twodig:		lb $t2, 0($s1)	# 10's digit
		lb $t3, 1($s1)	# 1's digit
		addi $t2, $t2, -48	#  adding the int
		mul $t2, $t2, 10
		add $t2, $t2, $t3
		addi $t2, $t2, -48	# t2 holds int value as ascii
		mul $s6, $s6, 4
		add $s0, $s0, $s6
		sw $t2, 0($s0)	# saving integer to array
		sub $s0, $s0, $s6	
		div $s6, $s6, 4
		addi $s6, $s6, 1	# incrementing length of array
		j storedint
		
onedig:		lb $t2, 0($s1)
		addi $t2, $t2, -48	#  # t2 holds int value as ascii
		mul $s6, $s6, 4
		add $s0, $s0, $s6
		sw $t2, 0($s0)	# saving integer to array
		sub $s0, $s0, $s6	
		div $s6, $s6, 4	
		addi $s6, $s6, 1	# incrementing length of array
storedint:	jr $ra
#------------------------------------------------------------------
#-------------------------------- this section sorts the array:
sort:	la $s0, array
tells:	lb $a0, 0($s3)	# printing sorted message
	beq $a0, $zero, donetells
	jal write
	addi $s3, $s3, 1
	j tells
donetells:	addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		sw $t2, 16($sp)
		sw $t3, 20($sp)
		sw $ra, 24($sp)
		li $a0, 0	# low is 0
		addi $a1, $s6, -1	# high is array size
		beq $a1, -1, echo	# if array empty stop
		jal quicksort		# QUICKSORT
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $t2, 16($sp)
		lw $t3, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		# recursion has completed
		addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		sw $t2, 16($sp)
		sw $t3, 20($sp)
		sw $ra, 24($sp)
		jal backtostring	# print the array 
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $t2, 16($sp)
		lw $t3, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		j echo 	# return to main
#----
quicksort:	# quicksort will take a0 as low and a1 as high
		li $t0, 0	# t0 will be the pivot
		ble $a1, $a0, donesort	# if high < low
		addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		sw $t2, 16($sp)
		sw $t3, 20($sp)
		sw $ra, 24($sp)
		jal partition	#low is already in a0 and high is in a1
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $t2, 16($sp)
		lw $t3, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		
		addi $t0, $v0, 0	# updating pivot
		
		addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		sw $t2, 16($sp)
		sw $t3, 20($sp)
		sw $ra, 24($sp)
		addi $t0, $t0, -1
		addi $a1, $t0, 0	
		jal quicksort	# quicksort(low, pivot-1)
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $t2, 16($sp)
		lw $t3, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
	
		addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		sw $t2, 16($sp)
		sw $t3, 20($sp)
		sw $ra, 24($sp)
		addi $t0, $t0, 1
		addi $a0, $t0, 0
		jal quicksort	# quicksort(pivot+1, high)
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $t2, 16($sp)
		lw $t3, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28

donesort:	la $s3, thesort	# resetting pointer to start of sort message
		#la $s0, array	# resetting pointer to start of array
		jr $ra
#----		
partition:	# partition will take a0 as low and a1 as high
		addi $t3, $a0, 0	# t3 is pivot_position
		mul $a0, $a0, 4
		add $s0, $s0, $a0
		lw $t0, 0($s0)		# t0 is a[pivot_pos]
		sub $s0, $s0, $a0	# resetting array
		div $a0, $a0, 4	
		addi $t1, $t3, 1	# t1 is our counter / index (i) starting at low+1
parloop:	bgt $t1, $a1, doneparloop	# for i = low+1 to high 
		mul $t1, $t1, 4	
		add $s0, $s0, $t1
		lw $t2, 0($s0)	# t2 is a[i}
		sub $s0, $s0, $t1
		div $t1, $t1, 4
		blt $t2, $t0, doswap
		addi $t1, $t1, 1	# i++
		j parloop
doswap:		addi $t3, $t3, 1	# incrementing pivot_pos
		addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		sw $t2, 16($sp)
		sw $t3, 20($sp)
		sw $ra, 24($sp)
		addi $a0, $t3, 0	# a0 holds pivot_pos
		addi $a1, $t1, 0	# a1 now holds i
		jal swap
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $t2, 16($sp)
		lw $t3, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		addi $t1, $t1, 1	# i++
		j parloop	
doneparloop:	addi $sp, $sp, -28
		sw $a0, 0($sp)
		sw $a1, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		sw $t2, 16($sp)
		sw $t3, 20($sp)
		sw $ra, 24($sp)
		addi $a0, $a0, 0	# a0 holds low
		addi $a1, $t3, 0	# a1 holds pivot_pos
		jal swap
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $t0, 8($sp)
		lw $t1, 12($sp)
		lw $t2, 16($sp)
		lw $t3, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		addi $v0, $t3, 0	# pivot_pos is return
		la $s0, array		# reset array pointer to start
		jr $ra	
#----
swap:	# takes a0 as index 1 and a1 as index 2
	mul $t1, $a0, 4	
	mul $t2, $a1, 4
	add $s0, $s0, $t1
	lw $t3, 0($s0)		# t3 is x	
	sub $s0, $s0, $t1
	add $s0, $s0, $t2
	lw $t4, 0($s0)		# t4 is y
	sw $t3, 0($s0)		# saving x where y was
	sub $s0, $s0, $t2
	add $s0, $s0, $t1
	sw $t4, 0($s0)		# saving y where x was
	sub $s0, $s0, $t1	# resetting s0 to point to start of the array
	la $s0, array
	jr $ra
#---------------------------------
#--------------------------------- this section reinitializes the array:	
reinitialize:
tellr:		lb $a0, 0($s4)
		beq $a0, $zero, doner
		jal write
		addi $s4, $s4, 1
		j tellr
doner:		
		la $s0, array	# resetting pointer to start of array
		la $s4, reanit	# resetting pointer to start of reanitialize message
		li $s6, 0	# resetting the length of int array to 0
		j echo
#-------------------------------------------------
#---- backtostring changes the int array back to one string to be able to print to MMIO output:	
backtostring:	la $s0, array
		li $t2, 32	# t2 is a space
		li $t3, 0	# t3 is a counter
bts:		lw $t0 0($s0)	# loading an integer at a time
		bge $t0, 10, tdig
odig:		addi $t0, $t0, 48
		sb $t0, 0($s5)	# storing first digit
		sb $t2, 1($s5)	# storing a space
		addi $s5, $s5, 2	
		addi $t3, $t3, 1	# updating counters / pointers
		addi $s0, $s0, 4
		bge $t3, $s6, stringified
		j bts
tdig:		li $t4, 10
		div $t0, $t4
		mflo $t0
		mfhi $t1
		addi $t0, $t0, 48	#converting second digit to ascii 
		addi $t1, $t1, 48	#converting first digit to ascii
		sb $t0, 0($s5)	# storing the 10's digit
		sb $t1, 1($s5)	# storing the 1's digit
		sb $t2, 2($s5)	# storing the space
		addi $s5, $s5, 3	
		addi $t3, $t3, 1	# updating counters / pointers
		addi $s0, $s0, 4
		bge $t3, $s6, stringified
		j bts
stringified:	li $t2, 10	# add a newline
		sb $t2, 0($s5)
		li $t2, 0	# end of string
		sb $t2, 1($s5)
		la $s0, array	# resetting pointer to front of array
		la $s5, string	# resetting pointer to start of string 
prntstr:	lb $a0, 0($s5)
		beq $a0, $0, doneprntstr		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal write	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		addi $s5, $s5, 1
		j prntstr
doneprntstr:	la $s5, string	# resetting string pointer		
		j echo
# --------------------------------------------------------------
quit:	li $v0, 10
	syscall
		
		
