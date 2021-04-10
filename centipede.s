.data
	displayAddress:	.word 0x10008000
	bugLocation: .word 1008
	centipedLocation: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	centipedDirection: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	centipedLives: .word 3
	background_colour: .word 0x000000
	centipede_colour: .word 0xff0000
	mushroom_colour: .word 0xFF8C00
	bug_colour: .word 0xffffff
	mushroom_number: .word 20
	mushroomLocation: .word 0:20
	dartLocation: .word 0:5
	dartNumber: .word 0
	mushroomLives: .word 0:20
	fleaLocation: .word 0
	fleaColour: .word 0x008000

.text 

############################################################################################

initialize:
	jal board_reset

centipede_initializer:
	la $s0, centipedLives
	addi $s1, $zero, 3
	sw $s1, 0($s0)
	
	addi $t1, $zero, 0
	addi $t0, $zero, 10
	la $t2, centipedLocation
	la $t3, centipedDirection
	addi $t4, $zero, 1
	
centipede_initializer_loop:
	sw $t1, 0($t2)
	sw $t4, 0($t3)
	
	addi $t1, $t1, 1
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	
	bne $t1, $t0, centipede_initializer_loop
	
bug_initializer:
	addi $t1, $zero, 1008
	la $t2, bugLocation
	sw $t1, 0($t2)
	
	
mush_life_initializer:
	la $t0, mushroom_number
	lw $t1, 0($t0)
	addi $t3, $zero, 1
	addi $t2, $zero, 0
	la $t4, mushroomLives
	
life_loop:
	sw $t3, 0($t4)
	
	addi $t4, $t4, 4
	addi $t2, $t2, 1
	
	
	bne $t2, $t1, life_loop


dart_initializer:
	addi $t0, $zero, 0
	la $t1, dartNumber
	sw $t0, 0($t1)
	


mushroom_initializer:
	lw $a3, mushroom_number	# load mush number into $a3
	la $a2, mushroomLocation	# load mushroom location array into $a2
	addi $t0, $zero, 0		# store 0 into $t0 (current mushroom generated index)
	lw $t9, displayAddress  # $t2 stores the base address for display
	addi $s3, $zero, 4	# store 4 into $s3
	
mush_generator:
	li $v0, 42	
	li $a0, 0
	li $a1, 959
	syscall		# randomly generating number from 0 to 959
	
	blt $a0, 10, mush_generator	# redo if it is in the first 10 spots (default centipede)
	
	la $s0, mushroomLocation	# load address of mushroom location array
	addi $t1, $zero, 0		# store 0 into $t1 (compare index)
	
mush_compare:
	beq $t0, $t1, mush_add		# branch to add mushroom (checked all shrooms that have been generated so far)
	mult $t1, $s3			# multiply by $t1 (mush index) by 4
	mflo $t4			# store product in $t4
	add $t5, $s0, $t4		# store mushroom at index $t1 in mushroom location array
	lw $t6, 0($t5)			# load mushroom (location) at current index		
	beq $t6, $a0, mush_generator	# branch to mushroom generator if generated shroom = current index shroom
	addi $t1, $t1, 1		# add 1 to $t1 (shroom compare index)
	j mush_compare
	
	
	

mush_add:
	sw $a0, 0($a2)		# store mushroom location at appropriate mushroom location array
	
	lw $s2, mushroom_colour
	sll $t8, $a0, 2		# $t4 the bias of the old buglocation
	add $t7, $t9, $t8	# $t4 is the address of the old bug location
	sw $s2, 0($t7)		# paint the mushroom mushroom colour
	
	
	addi $a2, $a2, 4	 # increment $a2 by one, to point to the next element in the array
	addi $t0, $t0, 1	 # increment $t0 by 1 (mushroom add index)
	
	bne $t0, $a3, mush_generator
	

initializer:
	jal disp_centiped
	jal display_bug
	jal disp_mush
	jal generate_flea
	jal disp_flea
	
	
	
	li $v0, 32
	li $a0, 50 # 50 default
	syscall
	
	

# GAME LOOP
game_loop_main:
	
	la $t1, fleaLocation
	lw $a0, 0($t1)
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	jal recolour
	
	jal move_flea
	
	jal disp_flea
	
	jal display_bug
	
	jal disp_mush
	
	
	la $t1, centipedLocation
	lw $a0, 0($t1)
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	jal recolour
	
	jal move_centipede
	
	
	jal disp_centiped
	jal check_keystroke
	
	jal remove_darts
	jal darts
	
	la $t2, centipedLives
	lw $t3, 0($t2)
	
	ble $t3, 0, game_over
	
	j game_loop_main	

Exit:
	li $v0, 10		# terminate the program gracefully
	syscall

# game over function (restart option)
game_over:
	lw $t1, displayAddress
	li $t3, 0x1E90FF
	addi $t1, $t1, 424
	
	sw $t3, 0($t1)
	sw $t3, 4($t1)
	sw $t3, 8($t1)
	sw $t3, 136($t1)
	sw $t3, 132($t1)
	sw $t3, 128($t1)
	sw $t3, 124($t1)
	sw $t3, 140($t1)
	sw $t3, 268($t1)
	sw $t3, 252($t1)
	sw $t3, 248($t1)
	sw $t3, 376($t1)
	sw $t3, 380($t1)
	sw $t3, 504($t1)
	sw $t3, 508($t1)
	sw $t3, 636($t1)
	sw $t3, 632($t1)
	sw $t3, 768($t1)
	sw $t3, 772($t1)
	sw $t3, 776($t1)
	sw $t3, 764($t1)
	sw $t3, 896($t1)
	sw $t3, 900($t1)
	sw $t3, 904($t1)
	sw $t3, 780($t1)
	sw $t3, 784($t1)
	sw $t3, 912($t1)
	sw $t3, 656($t1)
	sw $t3, 528($t1)
	sw $t3, 524($t1)
	
	addi $t5, $zero, 8
	sll $t5, $t5, 2
	
	add $t1, $t1, $t5
	
	sw $t3, 0($t1)
	sw $t3, 4($t1)
	sw $t3, 8($t1)
	sw $t3, 136($t1)
	sw $t3, 132($t1)
	sw $t3, 128($t1)
	sw $t3, 124($t1)
	sw $t3, 140($t1)
	sw $t3, 268($t1)
	sw $t3, 252($t1)
	sw $t3, 248($t1)
	sw $t3, 376($t1)
	sw $t3, 380($t1)
	sw $t3, 504($t1)
	sw $t3, 508($t1)
	sw $t3, 636($t1)
	sw $t3, 632($t1)
	sw $t3, 768($t1)
	sw $t3, 772($t1)
	sw $t3, 776($t1)
	sw $t3, 764($t1)
	sw $t3, 896($t1)
	sw $t3, 900($t1)
	sw $t3, 904($t1)
	sw $t3, 780($t1)
	sw $t3, 784($t1)
	sw $t3, 912($t1)
	sw $t3, 656($t1)
	sw $t3, 528($t1)
	sw $t3, 524($t1)
	
	addi $s0, $zero, 0
	
	li $a2, 10000
	
retry_loop:
	
	
	
	
	lw $t2, 0xffff0004
	
	beq $t2, 0x73, new_game
	
	
	addi $a2, $a2, -1
	bgtz $a2, retry_loop
	
	
	j Exit	
	
new_game:
	jal board_reset
	
	j initialize

	
	

# function to generate new flea location
generate_flea:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 42	
	li $a0, 0
	li $a1, 31
	syscall
	
	la $t1, fleaLocation
	sw $a0, 0($t1)
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# function to display flea
disp_flea:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t1, fleaLocation
	lw $t2, 0($t1)
	
	lw $t3, fleaColour
	
	lw $t4, displayAddress
	
	sll $t2, $t2, 2
	
	add $t4, $t4, $t2
	
	sw $t3, 0($t4)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# function to move flea
move_flea:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $s0, $zero, 0
	
	la $t1, fleaLocation
	
flea_loop:
	beq $s0, 2, flea_return
	
	lw $t2, 0($t1)
	addi $t2, $t2, 32 
	
	la $t4, bugLocation
	lw $t5, 0($t4)
	
	beq $t5, $t2, Exit
	
	bge $t2, 992, new_flea
	
	sw $t2, 0($t1)
	addi $s0, $s0, 1
	
	j flea_loop

	
new_flea:
	jal generate_flea

flea_return:
		
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra



# function to display mushrooms
disp_mush:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $a3, mushroom_number
	la $a2, mushroomLocation
	addi $t0, $zero, 0
	lw $t9, displayAddress  # $t2 stores the base address for display
	lw $s2, mushroom_colour
	la $s4, mushroomLives
	
mush_print_loop:
	lw $a0, 0($a2)
	lw $t1, 0($s4)
	beq $t1, 1, mush_disp
	j loop_back_mush

mush_disp:
	sll $t8, $a0, 2		# $t4 the bias of the old buglocation
	add $t7, $t9, $t8	# $t4 is the address of the old bug location
	sw $s2, 0($t7)		# paint the first (top-left) unit white.
	
loop_back_mush:
	addi $a2, $a2, 4	 # increment $a2 by one, to point to the next element in the array
	addi $t0, $t0, 1	 # increment $t0 by 1
	addi $s4, $s4, 4
	
	bne $t0, $a3, mush_print_loop
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


# function to see if it an offset is a mushroom
check_mush:
	lw $a0, 0($sp) 		# load the location to be checked
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $v1, mushroom_number	# load the number of mushrooms into $s2
	addi $v0, $zero, 0		# the mushroom array current index (0)
	
	la $t4, mushroomLocation	# load the address of the mushroom location array into $s4
	
	la $t7, mushroomLives
	
	
check_mush_loop:
	beq $v0, $v1, push_original	# branch to push_neg_one if the current index is the same as number of mushrooms
	
	lw $s5, 0($t7)
	beq $s5, 0, check_mush_loop_back
	
	lw $t8, 0($t4)			#
	beq $t8, $a0, push_neg_one
	
check_mush_loop_back:
	addi $t4, $t4, 4
	addi $v0, $v0, 1
	addi $t7, $t7, 4
	j check_mush_loop
	

	
	
push_original: # returns original location on success (if no shrooms match)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	j return

push_neg_one: #returns -1 on failure
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $t3, $zero, -1
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	j return
	

return:	
	jr $ra




# function to display a static centiped	
disp_centiped: 
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a3, $zero, 10	 # load a3 with the loop count (10)
	la $a1, centipedLocation # load the address of the array into $a1

arr_loop:	#iterate over the loops elements to draw each body in the centiped
	lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1

	lw $t2, displayAddress  # $t2 stores the base address for display
	
	lw $t3, centipede_colour
	
	beq $a3, 1, head_colour	# branches if $a1 currently represents the head of the centipede
	j colour
	
head_colour:
	li $t3, 0x800000	#t3 stores the maroon colour code
	j colour
	
colour:
	sll $t4, $t1, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the body w/ith the designated colour
	
	
		
	addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
	addi $a3, $a3, -1	 # decrement $a3 by 1
	bne $a3, $zero, arr_loop
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# function to move the centipede locations
move_centipede:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a3, $zero, 10	 # load a3 with the loop count (10)
	la $a1, centipedLocation # load the address of the array into $a1
	la $a2, centipedDirection # load the address of the array into $a2

move_loop:
	lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1
	lw $t5, 0($a2)		 # load a word from the centipedDirection  array into $t5
	addi $s0, $zero, 1
	
	bne $t5, $s0, left_	# branch to move left if $t5 does not hold the direction value 1

right:
	beq $t1, $zero, move_right
	
	j right_

switch_left:
	addi $t5, $t5, -2
	sw $t5, 0($a2)
	j move_left
	
right_:
	addi $s1, $t1, 1
	addi $t7, $zero, 32	# store 32 into $t7
	div $s1, $t7		# divide $t1 representing the current centipede location by 31
	mfhi $t7		# load register HI into $t7
	bne $t7, $zero, move_right	# branch if $t7 is not equal to 0, aka if current centipede location + 1 is not divisible by 32
	
	
	

move_down_from_right:
	addi $t1, $t1, 32	# add 32 to register $t1 (the current centipede location)
	addi $t5, $t5, -2	# add -2 to register $t5 (the current centipede direction)
	sw $t1, 0($a1)		# store value at $t1 at memory address of $a1 (the current centipede location inex)
	sw $t5, 0($a2)		# store value at $t2 at memory address of $a2 (the current centipede direction index)
	
	bge $t1, 992, game_over 
	
	j move_done


switch_right:
	addi $t5, $t5, 2
	sw $t5, 0($a2)
	j move_right

left_:
	addi $t7, $zero, 32	# add 32 to register 
	div $t1, $t7
	mfhi $t7
	bne $t7, $zero, move_left

move_down_from_left:
	addi $t1, $t1, 32
	addi $t5, $t5, 2
	sw $t1, 0($a1)
	sw $t5, 0($a2)
	
	bge $t1, 992, game_over 
	
	j move_done

move_right:
	addi $t6, $t1, 1 # add 1 offset
	
	addi $sp, $sp, -4 # send the potential next location to function check_mush
	sw $t6, 0($sp)
	jal check_mush # call check_mush
	
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	
	beq $s2, -1, move_down_from_right
	
	sw $t6, 0($a1)
	
	
	j move_done

move_left:
	addi $t6, $t1, -1	# t6 is the potential next address of bug location
	
	addi $sp, $sp, -4
	sw $t6, 0($sp)
	jal check_mush
	
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	
	beq $s2, -1, move_down_from_left
	
	sw $t6, 0($a1)
	
	j move_done

move_done:
	addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
	addi $a2, $a2, 4
	addi $a3, $a3, -1	 # decrement $a3 by 1
	
	
	bne $a3, $zero, move_loop
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


# function to detect any keystroke
check_keystroke:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t8, 0xffff0000
	beq $t8, 1, get_keyboard_input # if key is pressed, jump to get this key
	addi $t8, $zero, 0
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# function to get the input key
get_keyboard_input:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x6A, respond_to_j
	beq $t2, 0x6B, respond_to_k
	beq $t2, 0x78, respond_to_x
	beq $t2, 0x73, respond_to_s
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# Call back function of j key
respond_to_j:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	beq $t1, 992, skip_movement # prevent the bug from getting out of the canvas
	addi $t1, $t1, -1	# move the bug one location to the right
skip_movement:
	sw $t1, 0($t0)		# save the bug location

	li $t3, 0xffffff	# $t3 stores the white colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# Call back function of k key
respond_to_k:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the block with black
	
	beq $t1, 1023, skip_movement2 #prevent the bug from getting out of the canvas
	addi $t1, $t1, 1	# move the bug one location to the right
skip_movement2:
	sw $t1, 0($t0)		# save the bug location

	li $t3, 0xffffff	# $t3 stores the white colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the block with white
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
respond_to_x:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	lw $s5, dartNumber
	
	
	
	la $t7, bugLocation
	lw $s2, 0($t7)
	
	
	
	la $s6, dartNumber
	lw $s5, 0($s6)
	
	
	addi $s7, $zero, 0	# TEMPORARY initialize counter for dart index
	
	
	
	
	addi $t5, $zero, 4
	mul $t1, $t5, $s5
	
	la $s1, dartLocation
	add $s3, $s1, $t1
	
	sw $s2, 0($s3)		# store bug location as the last dart location (new dart)
	
	
	addi $s5, $s5, 1
	sw $s5, 0($s6)		# increment dart number (adding a new dart starting from shooter)
	
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

respond_to_s:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	jal board_reset
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	j initialize
	
	# pop a word off the stack and move the stack pointer
	
	jr $ra	# won't ever reach here

# function to move darts
darts:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	la $s1, dartLocation
	la $s6, dartNumber
	lw $s5, 0($s6)
	
	
	addi $s7, $zero, 0	# initialize counter for dart index
	
dart_loops:
	
	
	
	addi $s0, $zero, 0	# initialize dart move number
	lw $s2, 0($s1)		# load current dart location
	

	
	la $s6, dartNumber
	lw $s5, 0($s6)
	
	
	beq $s7, $s5, dart_return	# end if finished last dart
	
single_dart_loop:
	
	beq $s0, 6, display_dart
	
	
	

	addi $sp, $sp, -4
	sw $s2, 0($sp)		# store the current dart location into the stack
	
	
	jal move_dart		# have to make sure if it moves off the screen too it goes to dead
	
	
	lw $s2, 0($sp) # next dart location
	addi $sp, $sp, 4
	
	
	beq $s2, -1, dead_dart
	
	addi $s0, $s0, 1
	sw $s2, 0($s1)
	
	j single_dart_loop 
	
display_dart:
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	
	jal disp_dart
	
	lw $s2, 0($sp) 
	addi $sp, $sp, 4 
	
	j single_dart_return
	
dead_dart:
	la $s6, dartNumber
	lw $s5, 0($s6)
	
	
	addi $s5, $s5, -1
	sw $s5, 0($s6)		# store decremented dart number
	
	
	
	
	bne $s5, $s7, dart_shift		# shift darts if not on last index
	j single_dart_return
	
dart_shift:
	lw $s5, 0($s6)
	
	add $t9, $zero, $s7
	addi $t6, $s1, 4	# next dart location address
	add $t7, $s1, $zero	# current dart location address
	
shift_loop:
	lw $t5, 0($t6)
	sw $t5, 0($t7)		# shift next dart location to current dart location index
	
	addi $t6, $t6, 4
	addi $t7, $t7, 4
	addi $t9, $t9, 1
	
	
	bne $t9, $s5, shift_loop	# shift loop again unless we are done shifting all darts (index = # darts)
	
single_dart_return:
	
	
	addi $s1, $s1, 4
	addi $s7, $s7, 1		# increment the current dart index
	la $s6, dartNumber		
	lw $s5, 0($s6)			# load in dart number just in case
	
	ble $s7, $s5, dart_loops	# branch to next dart unless finished all darts (next dart index = # darts)
	
	
dart_return:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

delay:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a2, 10000
	addi $a2, $a2, -1
	bgtz $a2, delay
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# Initial Bug Display
display_bug:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	lw $t2, displayAddress  # $t2 stores the base address for display
	lw $t3, bug_colour
	
	sll $t4, $t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# function to display dart
disp_dart:
	lw $t2, 0($sp)		# load the dart location to $t2
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, displayAddress	#load display address
	
	sll $t4, $t2, 2		# shift the offset
	lw $t3, bug_colour	# load bug colour
	
	
	add $t0, $t0, $t4
	sw $t3, 0($t0)
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	
	jr $ra
	
# function to move the dart
move_dart:
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $t2, $t2, -32
	
	bge $t2, 0, dart_check_centipede
	
	addi $t2, $zero, -1
	j move_dart_return
	
dart_check_centipede:
	
	addi $t5, $zero, 0
	la $t6, centipedLocation
	addi $t7, $zero, 10
	
check_centipede_loop:
	beq $t5, $t7, dart_check_mush
	
	lw $t8, 0($t6)
	
	beq $t8, $t2, hit_centipede
	
	addi $t6, $t6, 4
	addi $t5, $t5, 1
	j check_centipede_loop
	

hit_centipede:
	la $t1, centipedLives
	lw $t0, 0($t1)
	
	addi $t0, $t0, -1
	sw $t0, 0($t1)
	
	addi $t2, $zero, -1
	j move_dart_return
	
dart_check_mush:
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	
	jal check_mush_collision
	
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
move_dart_return:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	
	jr $ra

# function to remove darts
remove_darts:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $s4, dartLocation
	la $s0, dartNumber
	lw $s1, 0($s0)
	addi $s2, $zero, 0 	# initialize counter
	
	
remove_dart_loop:
	beq $s2, $s1, remove_dart_return
	
	lw $s3, 0($s4)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal recolour
	
	addi $s4, $s4, 4
	addi $s2, $s2, 1
	
	j remove_dart_loop


remove_dart_return:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

recolour:
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t2, displayAddress
	lw $t3, background_colour
	sll $t4, $t1, 2		# shift the offset
	
	add $t2, $t2, $t4
	
	sw $t3, 0($t2)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	

# function to see if it an offset is a mushroom
check_mush_collision:
	lw $a0, 0($sp) 		# load the location to be checked
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $v1, mushroom_number	# load the number of mushrooms into $s2
	addi $v0, $zero, 0		# the mushroom array current index (0)
	
	la $t4, mushroomLocation	# load the address of the mushroom location array into $s4
	
	la $t6, mushroomLives
	
	
check_mush_loop_collision:
	beq $v0, $v1, push_original_collision	# branch to push_neg_one if the current index is the same as number of mushrooms
	
	lw $t5, 0($t6)
	beq $t5, 0, check_mush_loop_collision_back
	
	lw $t8, 0($t4)			#
	beq $t8, $a0, push_neg_one_collision
	
check_mush_loop_collision_back:
	addi $t4, $t4, 4
	addi $v0, $v0, 1
	addi $t6, $t6, 4
	j check_mush_loop_collision
	
	
	
	
	
push_original_collision: # returns original location on success (if no shrooms match)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	j return_collision

push_neg_one_collision: #returns -1 on failure
	mul $t5, $v0, 4
	la $t6, mushroomLives
	add $t6, $t6, $t5
	addi $t7, $zero, 0
	sw $t7, 0($t6)
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal recolour
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $t3, $zero, -1
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	j return_collision
	

return_collision:	
	jr $ra


# function to reset board
board_reset:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $t0, $zero, 1024
	lw $t2, displayAddress
	addi $t1, $zero, 0
	lw $t3, background_colour
	
board_loop:
	sw $t3, 0($t2)
	
	addi $t1, $t1, 1
	addi $t2, $t2, 4
	
	bne $t0, $t1, board_loop
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

	