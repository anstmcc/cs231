.data

array: 		.word 	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
greeting: 	.asciiz "Enter the number of elements between 1 and 20: "
errorBelow:	.asciiz "ERROR: Array cannot be less than 1 element\n"
errorAbove:	.asciiz "ERROR: Array cannot be more than 20 elements\n"
errorNotDiv:	.asciiz " is not divisible by 3. "
entryReq: 	.asciiz "Enter an integer for index "
indexNeg:	.asciiz "ERROR: Index cannot be negative\n"
indexNotThree:	.asciiz "ERROR: Index must be divisible by 3\n"
output: 	.asciiz "The values of the array indices in original order are\n"
outputReverse:	.asciiz "The values of the array indices in reverse order are\n"
newLine: 	.asciiz "\n"
space: 	.asciiz ": "
space2:	.asciiz " "

.text

main:	
	la $s0, array		#set pointer to the beginning of the array

	jal readNum
	add  $a1, $v0, $0		#move user input to $a1
	jal verifySize
	add  $t0, $0, $0		#initialize $t0 to 0 as counter
	addi $t1, $0,  1		#initialize $t1. used to display which index user is inputting		
	bne  $v1, $0, createArray
next:
	add  $t0, $0, $0		#reset $t0 to 0 as counter
	la   $s0, array		#reset pointer to the beginning of the array
	li   $v0, 4			#ask user how many indices they need
	la   $a0, output		#display message to user about original array
	syscall	
	jal printArray
	add  $t0, $0, $0		#reset $t0 to 0 as counter
	add  $t1, $0, $0		#reset $t1 to 0 as counter
	la   $s0, array		#set pointer for the head of the array
	la   $s1, array		#set pointer for the tail of the array
	jal reverseArray
	add  $t0, $0, $0		#reset $t0 to 0 as counter
	la   $s0, array		#set pointer to the beginning of the array
	li   $v0, 4			#display message to user about reversed array
	la   $a0, outputReverse
	syscall	
	jal printArray
exit:					#block to exit program
	li $v0, 10
	syscall
############################################################################################################
readNum:
	li $v0, 4			#ask user how many indices they need
	la $a0, greeting
	syscall	
	
	li $v0, 5			#receive input of number of indices
	syscall
	jr $ra			#jump back to main after input value is received into $v0
verifySize:
	addi $t0, $0, 20 		#set upper limit for error check
	slt  $v1, $0, $a1
	beq  $v1, $0, errorNeg
	slt  $v1, $a1, $t0
	beq  $v1, $0, errorPos
	jr $ra			#jump back to main after input value is validated
createArray:
	beq $t0, $a1, next	#check condition if need to run loop
					#if not jump back to next1 in main, otherwise execute loop
	li $v0, 4			#display input request to user
	la $a0, entryReq
	syscall	
	
	add $a0, $t0, $0
	li $v0, 1			#display which index is being assigned
	syscall	
	
	li   $v0, 4			#space inserted
	la   $a0, space
	syscall	
	
	li   $v0, 5			#receive input from user
	syscall
	add  $a2, $v0, $0
	add  $v1, $0, $0		#reset value of $v1 for validation
	jal checkNumPos
	
	sw   $v0, 0($s0)		#store $v0 into array at pointer
	addi $s0, $s0, 4		#more pointer down 4 bytes
	addi $t0, $t0, 1		#increment counter
	j createArray
reverseArray:
	beq $t0, $a1, setBack	#move $s1 to the end of the array
	addi $s1, $s1, 4
	addi $t0, $t0, 1
	j reverseArray
setBack:				#intermediate area needed to move pointer
	addi $s1, $s1, -4		#back from the "next" index to the last index
reverse:
	add $t0, $0, $0		#clear values to be used as temporary containers
	add $t1, $0, $0
	lw   $t0, 0($s0)		#$t2 is temporary storage for swap
	lw   $t1, 0($s1)		#$t2 is temporary storage for swap
	sw   $t0, 0($s1)		# store head in $t2, tail in $s0, $t2 in tail
	sw   $t1, 0($s0)
	addi $s0, $s0, 4		#add 4 to head, subtract 4 from tail
	addi $s1, $s1, -4		
	sle  $t3, $s0, $s1	#check if head is less than or equal to tail
	bne  $t3, $0, reverse
	jr $ra
printArray:
	lw $a0, 0($s0)		#load contents of array into $a0 for output
	li $v0, 1			#print number in array
	syscall	
	li $v0, 4			#insert space between each index of array
	la $a0, space2
	syscall	
	addi $s0, $s0, 4		#more pointer down 4 bytes
	addi $t0, $t0, 1		#increment counter
	bne $t0, $a1, printArray#loop until counter equals $a1
	li $v0, 4			#move carriage to next line
	la $a0, newLine
	syscall	
	la $a0, newLine		#move carriage to next line
	syscall	
	jr $ra
checkNumPos:
	slt  $t9, $0, $a2
	beq  $t9, $0, indexNegBlock
	subi $sp, $sp, 4		#push address into stack pointer
	sw $ra, 0($sp)
	jal divByThree
	lw $ra, 0($sp)		#load address in stack pointer into $ra
	addi $sp, $sp, 4		#pop back stack pointer
	jr $ra
divByThree:
	addi $t1, $0, 3
	div  $a2, $t1
	mfhi $v1
	bne  $v1, $0, indexThreeBlock
	jr $ra
indexThreeBlock:
	li $v0, 4
	la $a0, indexNotThree
	syscall	
	j createArray
indexNegBlock:			#error block if index is less than 1
	li $v0, 4
	la $a0, indexNeg
	syscall	
	j createArray
errorNeg:				#error block if index count is less than 1
	li $v0, 4
	la $a0, errorBelow
	syscall	
	j main
errorPos:				#error block if index count is greater than 20
	li $v0, 4
	la $a0, errorAbove
	syscall	
	j main
