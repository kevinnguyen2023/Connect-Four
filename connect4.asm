# A Stub to develop assembly code using QtSPIM

	# Declare main as a global function
	.globl main 

	# All program code is placed after the
	# .text assembler directive
	.text 		

# The label 'main' represents the starting point
main: 
	li $v0, 4
	la $a0, welcome	#Prints the welcome message
	syscall
	
	li $v0, 4
	la $a0, enter2		#prints the prompt to start entering numbers
	syscall
	
	li $v0, 4
	la $a0, number1	#prompt to enter first number
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0		#reads the first number into t0
	sw $t0, mw		#stores into first num into mw
	
	li $v0, 4
	la $a0, number2	#prompts to enter the second number
	syscall
	
	li $v0, 5
	syscall
	move $t1, $v0		#reads the second number into t1
	sw $t1, mz		#stores the second num into mz
	
	li $a0, 0
	li $a1, 100
	jal randomInRange	#gets a number in between 0-100
	move $t2, $v0		#stores the number in t2
	
	la $s3, fullColumns	#base address for fullCol
	la $s2, board		#base address for board
	lw $s0, gameOver	#s0 will be our gameOver
	
	bge $t2, 50, else	#if random number < 50
	li $s1, 0		#	then turn = 0
	j elseEnd		#skip else
else:	
	li $s1, 1		#else turn = 1

elseEnd:			
	
	move $a0, $s2
	jal fillBoard
	
	move $a0, $s2
	jal printBoard

		#Now to start while loop
while:	bne $s0, 0, endWhile	#while gameover == 0
				#Turn = 0 or $s1 is playerTurn
				#Turn = 1 or $s1 is computerTurn
	bne $s1, 0, elseIf	#if turn == 0
	li $s1, 1		#turn = 1
	
	li $v0, 4		#print "Enter a col"
	la $a0, enterCol
	syscall
	
	li $v0, 5		
	syscall
	move $s4, $v0		#scan col into s4
while1: blt $s4, 1, endWhile1	#while col < 1 or > 7
	bgt $s4, 7, endWhile1
	j skipWhile1
endWhile1:
	
	li $v0, 4		#print "InvalidColumn: Enter a col"
	la $a0, invalidCol
	syscall
	
	li $v0, 5		
	syscall
	move $s4, $v0		#scan col into s4
	j while1
	
skipWhile1:

	li $a0, 1		#load arguments for placecoin
	move $a1, $s2
	move $a2, $s3
	move $a3, $s4
	jal placeCoin
	move $s5, $v0		#return row where the coin was placed
while2: bne $s5, -1, endWhile2
	
	li $v0, 4		#print "ColumnFull: Enter a col"
	la $a0, fullCol
	syscall
	
	li $v0, 5		
	syscall
	move $s4, $v0		#scan col into s4
	
	li $a0, 1		#load arguments for placecoin
	move $a1, $s2
	move $a2, $s3
	move $a3, $s4
	jal placeCoin
	move $s5, $v0		#return row where the coin was placed
	j while2
endWhile2:
	
	j endIf
	
elseIf:
	bne $s1, 1, endIf	#else if turn = 1
	
	li $s1, 0		#turn = 0
	li $a0, 1
	li $a1, 7
	jal randomInRange
	move $s4, $v0		#col = s4 = v0 = return from randomInRange
	move $t9, $s4
	li $a0, 0		#first argument is 0 for the computer turn
	move $a1, $s2		#second argument is s2 for the base address of board
	move $a2, $s3		#third argument is s3 for  base address of fullcol
	move $a3, $s4		#fourth argument is s2 for the col	
	jal placeCoin
	move $s5, $v0		#return row where the coin was placed
endIf:
	
	lw $t0, rows
	lw $t1, cols
	addi $t1, $t1, -2
	mul $t0, $t0, $t1
	bne $s6, $t0, elseif1		#if check = total
	li $v0, 4
	la $a0, noWinner	#print tie
	syscall
	j end
	
elseif1:			#if checkwin
	move $a0, $s1
	move $a1, $s5
	move $a2, $s4
	move $a3, $s2
	jal checkWin
	move $t5, $v0
	bne $t5, 1, elseif2
	bne $s1, 1, elseif3
	li $v0, 4
	la $a0, humanWinner
	syscall
	li $s0, 1
	j elseif2
elseif3:
	li $v0, 4
	la $a0, computerWinner
	li $s0, 1
	syscall
	
elseif2:
	bne $s1, 0, skipprintComp
	move $a0, $s2
	jal printBoard		#print board only on human turn
	li $v0, 4		#print computer chose
	la $a0, compPlace
	syscall 
	li $v0, 1		#print row comp chose
	move $a0, $t9
	syscall
	li $v0, 4
	la $a0, newLine1
	syscall
	
skipprintComp:
	j while
endWhile:
	move $a0, $s2
	jal printBoard
	j end
#--------------------------------------------------------
placeCoin:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	
	lw $t0, rows
	addi $t0, $t0, -1	#rows - 1
	#s3 is the original address already loaded in main which is fullColumns
	addi $t6, $a3, -1	#col - 1
	mul $s0, $t6, 4	#s0 will hold the shift
	add $s1, $s3, $s0	#s1 will store the shifted address

	li $t7, 1		#t7 = 1, to mark that a column is full
	
	
while3: blt $t0, 0, endWhile3
	li $t2, 0		 #resets the shifted address
	mul $t2, $t0, 9
	add $t2, $t2, $a3	#t2 is the shift
	add $t2, $t2, $a1	#t2 += baseaddress
	lb $t3, 0($t2)		#t3 is the char at [i][col]
	lb $t4, dashChar	#t4 is "."
	
	bne $t3, $t4, elseIf1	#if t3 !- t4 jump
	bne $a0, 1, elseIf1	#if isHuman/turn != 1 then jump
	lb $t5, humanChar	#t5 = "H"
	sb $t5, 0($t2)		#board[i][col] = "H"
	addi $s6, $s6, 1
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	move $v0, $t0		#return i
	jr $ra
elseIf1:
	bne $t3, $t4, endIf2	#if t3 != t4 jump
	bne $a0, 0, endIf2	#if isHuman.turn != 0then jump
	lb $t5, computerChar	#t5 = "C"
	sb $t5, 0($t2)		#board[i][col] = H
	move $v0, $t0		#return i
	addi $s6, $s6, 1
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
endIf2:
	

	addi $t0, $t0, -1	#dec i
	j while3
	
endWhile3:
	sw $t7, 0($s1)
	li $v0, -1
	
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
#--------------------------------------------------------
checkWin:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	bne $a0, 1, else3
	lb $a0, humanChar
	j endelse
else3:
	lb $a0, computerChar
endelse:
	#registers a1-3 are the same
	jal checkVertical
	bne $v0, 1, or1
	#return v0 which is still 1 so i dont need to move it
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
or1:	jal checkHorizontal
	bne $v0, 1, or2
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
or2:	jal checkDiagonalLR
	bne $v0, 1, or3
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
or3:	jal checkDiagonalRL
	bne $v0, 1, endOr4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
endOr4:
	#If it reached here then the game hasnt ended and it should return 0
	li $v0, 0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#--------------------------------------------------------
checkVertical:
	
	#store a1&a2 they are changed and will be reused
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	
	#a0 has the char H or C
	#i will start as row which will still be in a1
	#s2 will always be the base add for board
	#
	li $t0, 0	#count to check for 5 in a row
	lw $t1, rows	#t1 = rows
	lw $t2, cols	#t2 = cols
	li $t6, 9
	

whilepos:		#while i < rows and at index i, col == a0
	bge $a1, $t1, endWhilepos
	mul $t3, $a1, $t6	#t3 = i * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhilepos
	
	li $t3, 0		#reset shift
	addi $a1, $a1, 1	#increment i
	j whilepos
	
endWhilepos:
	addi $a1, $a1, -1	#fix index i
whileneg:		#while i > 0 and index i, col is a2
	ble $a1, $zero, endWhileneg
	mul $t3, $a1, $t6	#t3 = i * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhileneg
	li $t3, 0		#reset shift
	addi $t0, $t0, 1	#increment count
	addi $a1, $a1, -1	#decerement i
	j whileneg

endWhileneg:
	lw $a2, 0($sp)
	addi $sp, $sp, 4
	lw $a1, 0($sp)
	addi $sp, $sp, 4
ifCount1:
	blt $t0, 5, endIfCount1
	li $v0, 1
	
	jr $ra

endIfCount1:
	#if it reached here then the count was < 5
	li $v0, 0
	jr $ra
	
#--------------------------------------------------------
checkHorizontal:
#basicalliy the same as vertical but with columns instead
	#store a1&a2 they are changed and will be reused
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	
	#a0 has the char H or C
	#i will start as row which will still be in a1
	#s2 will always be the base add for board
	#
	li $t0, 0	#count to check for 5 in a row
	lw $t1, rows	#t1 = rows
	lw $t2, cols	#t2 = cols
	addi $t2, $t2, -1 #cols - 1
	li $t6, 9
	

whilepos1:		#while j < cols - 1 and at index row, j == a0
	bge $a2, $t2, endWhilepos1
	mul $t3, $a1, $t6	#t3 = row * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhilepos1
	
	li $t3, 0		#reset shift
	addi $a2, $a2, 1	#increment j
	j whilepos1
	
endWhilepos1:
	addi $a2, $a2, -1	#fix index j
whileneg1:		#while j < 0 and index row, j is a0
	ble $a2, $zero, endWhileneg1
	mul $t3, $a1, $t6	#t3 = i * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhileneg1
	li $t3, 0		#reset shift
	addi $t0, $t0, 1	#increment count
	addi $a2, $a2, -1	#decerement i
	j whileneg1

endWhileneg1:
	lw $a2, 0($sp)
	addi $sp, $sp, 4
	lw $a1, 0($sp)
	addi $sp, $sp, 4
ifCount2:
	blt $t0, 5, endIfCount2
	li $v0, 1
	jr $ra

endIfCount2:
	#if it reached here then the count was < 5
	li $v0, 0
	jr $ra
#--------------------------------------------------------
checkDiagonalLR:
		#store a1&a2 they are changed and will be reused
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	
	#a0 has the char H or C
	#i will start as row which will still be in a1
	#s2 will always be the base add for board
	#
	li $t0, 0	#count to check for 5 in a row
	lw $t1, rows	#t1 = rows
	lw $t2, cols	#t2 = cols
	addi $t2, $t2, -1 #cols - 1
	li $t6, 9

whilepos2:		#while i > 0 and j < 1 and board[i][j] = char
	bge $a2, 1, endWhilepos2
	ble $a1, 0, endWhilepos2
	mul $t3, $a1, $t6	#t3 = row * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhilepos2
	
	li $t3, 0		#reset shift
	addi $a1, $a1, -1
	addi $a2, $a2, -1	#decrement j
	j whilepos2
	
endWhilepos2:
	addi $a1, $a1, 1	#fix index i
	addi $a2, $a2, 1
whileneg2:		#while j < cols - 1 and i < rows, board[i][j]
	bge $a1, $t1, endWhileneg2
	ble $a2, $t2, endWhileneg2
	mul $t3, $a1, $t6	#t3 = i * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhileneg2
	li $t3, 0		#reset shift
	addi $t0, $t0, 1	#increment count
	addi $a2, $a2, 1	#increment j
	addi $a1, $a1, 1	#inc i
	j whileneg2

endWhileneg2:
	lw $a2, 0($sp)
	addi $sp, $sp, 4
	lw $a1, 0($sp)
	addi $sp, $sp, 4
ifCount3:
	blt $t0, 5, endIfCount3
	li $v0, 1
	
	jr $ra

endIfCount3:
	#if it reached here then the count was < 5
	li $v0, 0
	jr $ra
#--------------------------------------------------------
checkDiagonalRL:
	#store a1&a2 they are changed and will be reused
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	
	#a0 has the char H or C
	#i will start as row which will still be in a1
	#s2 will always be the base add for board
	#
	li $t0, 0	#count to check for 5 in a row
	lw $t1, rows	#t1 = rows
	lw $t2, cols	#t2 = cols
	addi $t2, $t2, -1 #cols - 1
	li $t6, 9
	

whilepos3:		#while i < rows and j < col - 1 and board[i][j] = char
	bge $a1, $t1, endWhilepos3
	ble $a2, $zero, endWhilepos3
	mul $t3, $a1, $t6	#t3 = row * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhilepos3
	
	li $t3, 0		#reset shift
	addi $a1, $a1, 1	#inc i
	addi $a2, $a2, -1	#decrement j
	j whilepos3
	
endWhilepos3:
	addi $a1, $a1, -1	#fix index i
	addi $a2, $a2, 1
whileneg3:		#while j < cols - 1 and i > 0, board[i][j]
	ble $a1, $zero, endWhileneg3
	bge $a2, $t2, endWhileneg3
	mul $t3, $a1, $t6	#t3 = i * 9 for future refernce to address
	add $t3, $t3, $a2	#t3 = t3 + j #for future reference to address
	add $t4, $s2, $t3	#t4(address of [i][col]) = base address + shift
	lb $t5, 0($t4)		#char at adress t3
	bne $t5, $a0, endWhileneg3
	li $t3, 0		#reset shift
	addi $t0, $t0, 1	#increment count
	addi $a2, $a2, 1	#increment j
	addi $a1, $a1, -1	#dec i
	j whileneg3

endWhileneg3:
	lw $a2, 0($sp)
	addi $sp, $sp, 4
	lw $a1, 0($sp)
	addi $sp, $sp, 4
ifCount4:
	blt $t0, 5, endIfCount4
	li $v0, 1
	
	jr $ra

endIfCount4:
	#if it reached here then the count was < 5
	li $v0, 0
	jr $ra
#--------------------------------------------------------
printBoard:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	
	move $t0, $a0		#load address of board in t0
	lw $s0, rows		#load rows in s0
	lw $s1, cols		#load cols in s1
	
	li $v0, 4
	la $a0, newLine	#print the new line with ----
	syscall
	
	li $v0, 4		#print a small space
	la $a0, smallSpaces1
	syscall
	
	li $t1, 1
for1:	bgt $t1, 7, endFor1

	li $v0, 4		#print a small space
	la $a0, smallSpaces
	syscall
	
	li $v0, 1
	move $a0, $t1		#print numbers 1 - 7
	syscall
	
	addi $t1, $t1, 1	#inc i++
	j for1
	
endFor1:
	li $v0, 4
	la $a0, hehe
	syscall
	la $a0, newLine	#print another new line with ---
	syscall
	
	li $t1, 0
#This is where is starts printing the rows/cols

for2:	bge $t1, $s0, endFor2	#for i = 0 to rows - 1
	li $t2, 0		#j = 0
for3:	bge $t2, $s1, endFor3	#for j = 0 to cols - 1

	add $s2, $t0, $zero	#keep s2 as base address
	mul $t3, $t1, $s1 	#t3 = i * 9 for future refernce to address
	add $t3, $t3, $t2	#t3 = t3 + j #for future reference to address
	add $s2, $s2, $t3	#t3(address of [i][j]) = base address + shift
	lb $t4, 0($s2)
	
	li $v0, 4
	la $a0, space		#print a space
	syscall
	
	li $v0, 11
	move $a0, $t4		#print the char 
	syscall
	
	addi $t2, $t2, 1	#inc j
	j for3
	
endFor3:
	li $v0, 4
	la $a0, sideSpace	#print sideSpace
	syscall
	addi $t1, $t1, 1
	j for2
endFor2:
	li $v0, 4
	la $a0, newLine
	syscall
	
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#------------------------------------------------
fillBoard:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	 
	move $t0, $a0 #address of board[0][0] in t0
	
	li $t1, 0 #i = 0
	lw $s0, rows
	lw $s1, cols

fori:	bge $t1, $s0, endFori
	li $t2, 0 		#j = 0
forj:  bge $t2, $s1, endForj

	add $t4, $t0, $zero	#Reset t4
	mul $t4, $t1, 9 	#t4 = i * 9 for future refernce to address
	add $t4, $t4, $t2	#t4 = t4 + j #for future reference to address
	add $t4, $t0, $t4	#t4(address of [i][j]) = base address + shift 
	
	beq $t2, 0, if1	#if j = 0 or j = 8
	beq $t2, 8, if1
	j else1		#else jump
if1:
	li $t6, 2		#t6 = 2
	divu $t1, $t6		#i / 2
	mfhi $t3		#remainder stored in t3
	bne $t3, 0, else2 	#if i % 2 == 0
	
	lb $t5, computerChar	#load char into t5
	sb $t5, 0($t4)		#store t5('C') into address t0
	j endif1
	
else2: 
	lb $t5, humanChar	#load char into t5
	sb $t5, 0($t4)		#store t5('H') into addresso t0
	j endif1

else1:	
	lb $t5, dashChar	#load char into t5
	sb $t5, 0($t4)		#store t5('-') into address t0

endif1:	
	addi $t2, $t2, 1	#increment j
	j forj
endForj:
	addi $t1, $t1, 1	#increment i
	j fori
endFori:
	#adjusting stack pointers
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#------------------------------------
randomInRange:
	addi $sp, $sp, -4	#Store values in registers which will be changed
	sw $ra, 0($sp)		#In order to prevent overrides
	addi $sp, $sp, -4	#Store return address, s0, s1, and t0
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	
	sub $t0, $a1, $a0	#high - low = $a1 - $a0
	addi $s0, $t0, 1	#s0 = range = t0 + 1
	
	jal getRandom		#jump to function get random
	move $s1, $v0		#s1 will store the random
	
	divu $v0, $s0		#randnum % range
	mfhi $t2		#which is in t2 now
	add $t2, $t2, $a0	#t2 + low
	move $v0, $t2		#return t2
	
	#Unpopping all values that were stores
	#- t0, s0, s1, return address
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra			#jump to return address
	
	
getRandom:
	#Store all future changed register
	#Adust stack pointer
	addi $sp, $sp, -4	#Stores values from
	sw $s0, 0($sp)		#	- t0, s0, s1
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	
	#result will be in v0
	lw $s0, mz		#m_z will be s0
	lw $s1, mw		#m_w will be s1
	
	li $t0, 36969		#t0 = 36969
	and $t1, $s0, 65535	#t1 = m_z & 65535
	srl $t2, $s0, 16	#t2 = m_z >> 16
	mul $t3, $t0, $t1	#t3 = 36969 * (m_z & 65535)
	addu $t3, $t3, $t2	#t3 += (m_z >> 16)
	sw $t3, mz		#m_z = t3
	
	li $t0, 18000		#t0 = 18000
	and $t1, $s1, 65535	#t1 = m_w & 65535
	srl $t2, $s1, 16	#t2 = m_w >> 16
	mul $t3, $t0, $t1	#t3 = 18000 * (m_z & 65535)
	addu $t3, $t3, $t2	#t3 += (m_z >> 16)
	sw $t3, mw		#m_w = t3
	
	lw $s0, mz		#update $s0
	lw $s1, mw		#update $s1
	
	sll $t3, $s0, 16	#t3 = m_z << 16
	addu $t3, $t3, $s1	#t3 += s1, t3 += m_w & 65536
	move $v0, $t3		#v0 = t3, v0 returns the value in the function
	
	lw $s1, 0($sp)		#Unpop all stored values in this function
	addi $sp, $sp, 4	#	- s1, s0, t0
	lw $s0, 0($sp)
	addi $sp, $sp, 4

	
	
	jr $ra			#jump to return address in main
end:

	# Exit the program by means of a syscall.
	# There are many syscalls - pick the desired one
	# by placing its code in $v0. The code for exit is "10"

	li $v0, 10 # Sets $v0 to "10" to select exit syscall
	syscall # Exit

	# All memory structures are placed after the
	# .data assembler directive
	.data
	#Storing all variables
	board: .space 54 #stored like 00 01 02 03 04 so on and 10 11 12
	mw: .word 0
	mz: .word 0
	full: .word 0
	fullColumns: .space 28
	row: .word 0
	col: .word 0
	rows: .word 6
	cols: .word 9
	gameOver: .word 0
	turn: .word 0

	# Storing all print statements
	welcome: .asciiz "Welcome to Connect Four, Five-in-a-Row variant!\n"
	enter2: .asciiz "Enter two positive numbers to initialize the random number generator\n"
	number1: .asciiz "Number 1: "
	number2: .asciiz "Number 2: "
	enterCol: .asciiz "Enter a column: "
	invalidCol: .asciiz "Invalid Entry! Enter a column: "
	fullCol: .asciiz "Column Full! Enter a different column: "
	noWinner: .asciiz "No one won!?!\n"
	humanWinner: .asciiz "Human Wins\n"
	humanPlayer: .asciiz "Human Player (H)\n"
	computerWinner: .asciiz "Computer Wins\n"
	computerPlayer: .asciiz "Computer Player (C)\n"
	coinToss1: .asciiz "Coin toss... HUMAN goes first.\n"
	coinToss2: .asciiz "Coint toss... COMPUTER goes first.\n"
	compPlace: .asciiz "Computer chose column: "
	newLine1: .asciiz "\n"
	newLine: .asciiz "\n--------------------------------------\n"
	smallSpaces: .asciiz " | "
	hehe: .asciiz " |"
	smallSpaces1: .asciiz "    "
	space: .asciiz " | "
	sideSpace: .asciiz " |\n"
	#Characters for the board
	dashChar: .asciiz "-"
	humanChar: .asciiz "H"
	computerChar: .asciiz "C"

	# The .word assembler directive reserves space
	# in memory for a single 4-byte word (or multiple 4-byte words)
	# and assigns that memory location an initial value
	# (or a comma separated list of initial values)
	#For example:
	#value: .word 12
