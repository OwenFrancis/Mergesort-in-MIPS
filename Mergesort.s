	.data
	.align 2
k:      .word   4
s:      .asciiz "bca"

	
    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    
    #jal to jump to a function
    #jr to return
    #these are your friends
    #work out how to do recursive right by maintaining state of caller/subroutine
    lw $t0, k
    lw $s0, k
    la $s6, s
    li $t2, 2
    li $s3, 0
    
    
    
    li $v0,9
    move $a0, $s0
    syscall
    move $s5,$v0 #create an address with k space allocated
    
    subi $s0, $s0, 2 #last byte in s is word end, and index starts at zero
    subi $t0, $t0, 2
    
    jal mergesort
    j end
    
    
    mergesort:
    addi $sp, $sp, -16
    sw $s0, 12($sp) #right
    sw $s3, 8($sp)  #left
    sw $s4, 4($sp)  #mid
    sw $ra, 0($sp)  #return address
    
    sub $t0, $s0, $s3
    blez $t0, skip #skip mergesort if left < right
    add $s4, $s0, $s3
    div $s4, $s4, $t2 # mid = (left+right)/2
    
    move $s0,$s4
    jal mergesort #mergesort left side
    
    lw $s0, 12($sp)
    addi $s3, $s4, 1
    jal mergesort #mergesort right side
    
    lw $s3, 8($sp)
    jal merge #merging both sides
    
    skip:
    lw $ra, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s0, 12($sp)
    addi $sp, $sp, 16
    
    jr $ra
    
    
    merge: 
    #the mergesort traverses the array correctly, 
    #now need to make changes in merge that will persist
    
    #$s5 will be used to assemble the sorted string
    
    #$s0 = right
    #$s6 = string
    #$s3 = left
    #$s4 = mid
    #$t6 = mid + 1
    
    #there will always be at least 1 left and 1 right value
    #none of the values will be the null value
    li $t8, 0 #counter for reseting the address of $s5 at the end
    addi $t6, $s4, 1 #add 1 to mid
    move $t7, $s3
    
    compare:
    add $s6, $s6, $s3 #set pointer to start of left
    lb $t5, ($s6) #first letter of left
    sub $s6, $s6, $s3 #set pointer to start
    

    add $s6, $s6, $t6 #set pointer to start of right
    lb $t4, ($s6) #first letter of right
    sub $s6, $s6, $t6 #set pointer to start
    
    sub $t3, $t4, $t5
    bgez $t3 forward
    #first left comes after first right.
    j forward2
    
    forward:
    # get next letter from left
    #if no more in left, put right characters in place and exit
    sb $t5, ($s5) #add letter to end of string
    addi $s5, $s5, 1 #increment address of string
    addi $t8, $t8, 1 #increment counter
    addi $s3, $s3, 1 #increment left
    sub $t3, $s4, $s3 #if left > mid, left is complete.
    bltz $t3 resolveRight
    
    add $s6, $s6, $s3 #set pointer to start of left
    lb $t5, ($s6) #first letter of left
    sub $s6, $s6, $s3 #set pointer to start
    
    j compare
    
    forward2:
    #get next letter from right
    #if no more in right, put left characters in place and exit
    sb $t4, ($s5)
    addi $s5, $s5, 1 #increment address of string
    addi $t8, $t8, 1 #increment counter
    addi $t6, $t6, 1 #increment left
    sub $t3, $s0, $t6 #if mid+1 > right, right is complete.
    bltz $t3 resolveLeft
    
    add $s6, $s6, $t6 #set pointer to start of right
    lb $t4, ($s6) #first letter of right
    sub $s6, $s6, $t6 #set pointer to start
    
    j compare
    
    resolveRight: #add all remaining in right to string
    sb $t4, ($s5)
    addi $s5, $s5, 1
    addi $t8, $t8, 1
    addi $t6, $t6, 1
    sub $t3, $s0, $t6
    bltz $t3 resolved #all letters move to s5
    
    add $s6, $s6, $t6 #set pointer to start of right
    lb $t4, ($s6) #first letter of right
    sub $s6, $s6, $t6 #set pointer to start
    
    j resolveRight
    
    resolveLeft: #add all remaining in left to string
    sb $t5, ($s5)
    addi $s5, $s5, 1
    addi $t8, $t8, 1
    addi $s3, $s3, 1
    sub $t3, $s4, $s3
    bltz $t3 resolved #all letters move to s5
    
    add $s6, $s6, $s3 #set pointer to start of left
    lb $t5, ($s6) #first letter of left
    sub $s6, $s6, $s3 #set pointer to start
    
    j resolveLeft
    
    resolved:
    sub $s5, $s5, $t8 #set address of $s5 back to start
    li $t6, 0

    move $s3, $t7 #return left to original value
    add $s6, $s6, $s3
    #move everything from $s5 into $s1 letter by letter
    
    transfer:
    lb $t5, ($s5)
    sb $t5, ($s6)
    addi $s6, $s6, 1
    addi $s5, $s5, 1
    addi $t6, $t6, 1
    bne $t6,$t8, transfer
    
    
    sub $s5, $s5, $t8 #set address of $s5 back to start
    sub $s6, $s6, $t8 #set address of $s1 back to start
    sub $s6, $s6, $s3
    
    
    jr $ra
    
    end:
    
    #following three lines to test output correct
    la $a0, ($s6) 
    li $v0, 4
    syscall
    
    li $v0, 10
    syscall