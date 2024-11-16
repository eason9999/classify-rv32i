.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0             

loop_start:
    # Check if we have reached the end of the array
    bge t1, a1, done        # If t1 >= a1, jump to done (end of loop)

    # Load current array element
    slli t2, t1, 2          # Calculate offset (t1 * 4)
    add t3, a0, t2          # Calculate the address of the current element (a0 + offset)
    lw t4, 0(t3)            # Load the value at the calculated address into t4

    # Apply ReLU (if the value is less than 0, set it to 0)
    bge t4, zero, skip_relu # If t4 >= 0, skip to the next iteration
    li t4, 0                # Set t4 to 0 if it is less than 0
    sw t4, 0(t3)            # Store the modified value back to the array

skip_relu:
    # Increment the index and continue the loop
    addi t1, t1, 1          # Increment t1 by 1
    j loop_start            # Jump back to the start of the loop

done:
    # Return to the caller
    jr ra

error:
    li a0, 36          
    j exit          
