.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0            
    li t1, 0
    slli a3, a3, 2 # a0's skip distamce
    slli a4, a4, 2 # a1's skip distance         

loop_start:
    lw t2, 0(a0)
    lw t3, 0(a1)

multiply_loop:
    beq t3, x0, multiply_end    # If t3 == 0, jump to the end of the loop
    andi t5, t3, 1              # Check the least significant bit of t3 and the result stored in t5
    beq t5, x0, skip_add        # If the least significant bit is 0, skip addition
    add t0, t0, t2              # Add t2 to the result stored in t0

skip_add:
    slli t2, t2, 1              # Left shift t2 by one bit (equivalent to multiplying by 2)
    srli t3, t3, 1              # Right shift t3 by one bit (equivalent to dividing by 2)
    j multiply_loop             # Jump back to the beginning of the loop

multiply_end:
    add a0, a0, a3     # a0's strides
    add a1, a1, a4     # a1's strides 
    addi a2, a2, -1    # a2 --
    blt t1, a2, loop_start

    mv a0, t0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit