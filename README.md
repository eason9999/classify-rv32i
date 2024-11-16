# Assignment 2: Classify
## Part A: Mathematical Functions
### Task 1: ReLU
The ReLU operation modifies each array element in place. Below is how each instruction works to implement the functionality.
```
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
```
1. Input Validation
```assembly
li t0, 1             
blt a1, t0, error
```
- li t0, 1: Load the value 1 into t0.
- blt a1, t0, error: If the array length (a1) is less than 1, jump to the error label. This ensures the array is not empty.

2. Loop Setup
```assembly
li t1, 0
loop_start:
    bge t1, a1, done
```
- li t1, 0: Initialize the index counter (t1) to 0.
- bge t1, a1, done: Compare the current index (t1) with the array length (a1). If all elements are processed, exit the loop.
3. Accessing Array Elements
```assembly
slli t2, t1, 2
add t3, a0, t2
lw t4, 0(t3)
```
- slli t2, t1, 2: Compute the byte offset for the current element by multiplying the index (t1) by 4 (each element is 4 bytes).
- add t3, a0, t2: Add the base address (a0) and the offset (t2) to calculate the element's memory address.
- lw t4, 0(t3): Load the value at the calculated address into register t4.
4. Applying the ReLU Operation
```assembly
bge t4, zero, skip_relu
li t4, 0
sw t4, 0(t3)
```
- bge t4, zero, skip_relu: If the value in t4 is greater than or equal to 0, skip to the next iteration.
- li t4, 0: Set t4 to 0 if the value is negative.
- sw t4, 0(t3): Write the modified value (0) back to the memory address of the current element.
5. Incrementing the Index
```assembly
addi t1, t1, 1
j loop_start
```
- addi t1, t1, 1: Increment the index (t1) to process the next element.
- j loop_start: Jump back to the start of the loop to continue processing.
6. Loop Termination
```assembly
done:
    jr ra
```
- jr ra: Return to the caller after processing all elements.
7. Error Handling
```assembly
error:
    li a0, 36          
    j exit
```
- li a0, 36: Load error code 36 into a0 to indicate invalid input.
- j exit: Jump to the exit routine for termination.
### Task 2: ArgMax
This RISC-V code scans an integer array to find the maximum value and returns the position (index) of its first occurrence. If multiple elements have the same maximum value, it returns the smallest index.

1. Input Validation
``` assembly
li t6, 1
blt a1, t6, handle_error
```
- li t6, 1: Load 1 into register t6 as the minimum valid array length.
- blt a1, t6, handle_error: If the array length (a1) is less than 1, jump to the handle_error label, setting an error code (36).
2. Initialization
```assembly
lw t0, 0(a0)  #max value
li t1, 0      #max_index
li t2, 0      #now position
```
- lw t0, 0(a0): Load the first element of the array into t0 as the initial maximum value.
- li t1, 0: Initialize t1 to 0, representing the index of the maximum value.
- li t2, 0: Initialize t2 to 0, representing the current index.
3. Main Loop
```assembly
addi a1, a1, -1          #i--
blt a1, t6, loop_end     #if i < 1 (a1),exit loop
addi a0, a0, 4           #a[i+1] = a[i] + offset
lw   t3, 0(a0)           #load the number of a[i+1]
addi t2, t2, 1            
bgt  t0, t3, loop_start  #if max>a[i], keep loop
mv   t0, t3              #Else max=a[i]
mv   t1, t2              #max_index = now_index 
j   loop_start
```
- addi a1, a1, -1: Decrement the counter a1 to track remaining elements.
blt a1, t6, loop_end: Exit the loop when all elements are processed.
addi a0, a0, 4: Move the pointer a0 to the next element by adding 4 bytes (size of an integer).
- lw t3, 0(a0): Load the next element into t3.
addi t2, t2, 1: Increment the current position index (t2).
bgt t0, t3, loop_start: If the current maximum (t0) is greater than the new element (t3), continue the loop without updates.
- mv t0, t3: If the new element is greater, update t0 as the new maximum value.
- mv t1, t2: Update t1 to the current index (t2) of the new maximum value.
- j loop_start: Repeat the process for the next element.
4. Finalization
```
assembly
loop_end:
   mv a0, t1
   jr ra
```
- mv a0, t1: Move the index of the maximum value (t1) into a0 for returning.
- jr ra: Return to the caller.
5. Error Handling
```assembly
handle_error:
    li a0, 36
    j exit
```
- li a0, 36: Set error code 36 to indicate invalid input (array length < 1).
- j exit: Jump to the program's exit sequence.
### Task 3.1: Dot Product
This RISC-V code calculates the dot product of two arrays with strides.
Key Steps and Instructions
1. Input Validation
```assembly
li t0, 1
blt a2, t0, error_terminate  
blt a3, t0, error_terminate   
blt a4, t0, error_terminate
```
- li t0, 1: Load the minimum valid value (1) into t0.
- blt a2, t0, error_terminate: Check if element_count (a2) is at least 1.
- blt a3, t0, error_terminate: Check if stride0 is valid.
- blt a4, t0, error_terminate: Check if stride1 is valid.
- Invalid values trigger error handling.
2. Initialization
``` assembly
li t0, 0            # Initialize result to 0
li t1, 0            # Initialize loop counter
slli a3, a3, 2      # Convert stride0 to byte offset
slli a4, a4, 2      # Convert stride1 to byte offset
```
- Initialize registers for result (t0) and loop counter (t1).
- Convert strides from element units to byte offsets.
3. Main Loop
```assembly
loop_start:
    lw t2, 0(a0)      # Load element from arr0
    lw t3, 0(a1)      # Load element from arr1
lw t2, 0(a0): Load the current value from array 0.
lw t3, 0(a1): Load the current value from array 1.
```
4. Binary Multiplication
```assembly
multiply_loop:
    beq t3, x0, multiply_end # Exit if arr1 element is 0
    andi t5, t3, 1           # Check least significant bit of t3
    beq t5, x0, skip_add     # Skip addition if LSB is 0
    add t0, t0, t2           # Add t2 to result

skip_add:
    slli t2, t2, 1           # Left shift t2 (multiply by 2)
    srli t3, t3, 1           # Right shift t3 (divide by 2)
    j multiply_loop          # Repeat multiplication loop
```
- This performs bitwise multiplication of t2 (arr0 element) and t3 (arr1 element) using shift-and-add logic.
- andi t5, t3, 1: Extracts the least significant bit of t3.
- slli and srli: Shift operations simulate binary multiplication.

5. Stride Update
```assembly
multiply_end:
    add a0, a0, a3     # Move to the next element in arr0
    add a1, a1, a4     # Move to the next element in arr1
    addi a2, a2, -1    # Decrement element count
    blt t1, a2, loop_start
```
- Update pointers a0 and a1 to the next elements using strides (a3, a4).
- Decrement the remaining element count (a2).
6. Finalization
```assembly
mv a0, t0      # Move the result to a0 for return
jr ra          # Return to the caller
```
- Store the result in a0 and return.
7. Error Handling
```assembly
error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
```
- Error Codes:
36: Invalid element_count.
37: Invalid strides.
#### How It Works
1. Binary Multiplication:
- Each bit of the multiplier represents whether to add the multiplicand to the result.
The multiplicand is shifted left for each successive bit position (equivalent to multiplying by 2).
The multiplier is shifted right to process the next bit.
2. Example : Multiply t2 = 6 (110 in binary) and t3 = 5 (101 in binary):
- Step 1: LSB of t3 is 1 → Add 6 to the result.
- Step 2: Left shift 6 → 12. Right shift 5 → 2 (10 in binary).
- Step 3: LSB of t3 is 0 → Skip addition.
- Step 4: Left shift 12 → 24. Right shift 2 → 1 (1 in binary).
- Step 5: LSB of t3 is 1 → Add 24 to the result.
- Final result: 30.

### Task 3.2: Matrix Multiplication
- This RISC-V program implements matrix multiplication 
Each element 
- D[i][j] is the dot product of the i-th row of 𝑀0 and the j-th column of 𝑀1.
1. Input Validation
```assembly
li t0 1
blt a1, t0, error
blt a2, t0, error
blt a4, t0, error
blt a5, t0, error
bne a2, a4, error
```
blt: Checks if matrix dimensions are positive.
bne: Ensures cols~0~ = rows~1~ for valid multiplication.
- Error handling: Invalid inputs terminate with exit code 38.
2. Outer Loop: Iterates Rows of 𝑀0
```assembly
outer_loop_start:
    li s1, 0          # Reset inner loop counter
    mv s4, a3         # Reset M1 pointer to start
    blt s0, a1, inner_loop_start
    j outer_loop_end
```
- li: Initializes the inner loop counter s1.
- mv: Resets the 𝑀1 pointer to the start for each new row of 𝑀0.
blt: Compares the current row index (s0) with rows0.
3. Inner Loop: Iterates Columns of 𝑀1
```assembly
inner_loop_start:
    beq s1, a5, inner_loop_end
    ...
    sw t0, 0(s2)         # Store result in the output matrix
    addi s2, s2, 4       # Move to next element in the result matrix
    li t1, 4
    add s4, s4, t1       # Move to the next column in M1
    addi s1, s1, 1
    j inner_loop_start
```
- beq: Ends the inner loop when all columns of 𝑀1 are processed.
- sw: Stores the computed dot product in the result matrix.
- addi/add: Increment pointers for the result matrix and 𝑀1.
4. Dot Product Calculation
```assembly=
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    jal dot
    mv t0, a0 # storing result of the dot product into t0
```
- jal: Calls the dot subroutine, which calculates the dot product of a row of 𝑀0 and a column of 𝑀1.
- mv: Sets up arguments for dot, including pointers and strides.
- Return: Stores the dot product result in t0.
5. Advance to the Next Row of 𝑀0
```assembly
slli t0, a2, 2      # Total length of M0 row in bytes
add s3, s3, t0      # Move to the next row in M0
addi s0, s0, 1      # Increment the row counter
```
- slli: Computes the total byte offset for one row of 𝑀0.
add: Updates the pointer to 𝑀0 for the next row.
6. Function Prologue and Epilogue
```assembly
addi sp, sp, -28     # Allocate stack space
sw ra, 0(sp)         # Save return address
...
lw ra, 0(sp)         # Restore return address
addi sp, sp, 28      # Deallocate stack space
ret
```
- sw/lw: Save and restore caller-saved registers and stack pointers.
- ret: Return to the caller after completing matrix multiplication.

7. Error Handling
```assembly
error:
    li a0, 38
    j exit
```
- li: Loads error code 38 into a0.
- j: Jumps to the program’s exit routine for invalid inputs.
## Part B: File Operations and Main
### Matrix File Format
- Plaintext: Begins with two integers (rows, columns), followed by matrix rows.
- Binary: Stores matrix dimensions in the first 8 bytes (two 4-byte integers), followed by matrix elements in row-major order.
### Task 1: Read Matrix
- The read_matrix function reads a binary matrix file into dynamically allocated memory. It extracts matrix dimensions (rows and columns) from the file header and loads matrix data into memory in row-major order.
1. File Operations:
- Opens the file using fopen. If the file cannot be opened, it terminates with error code 27.
Reads the first 8 bytes (header) to extract the row and column count, storing these values at specified addresses.
Reads the matrix data into dynamically allocated memory.
2. Dynamic Memory Allocation:
- Computes the total memory required (rows × columns × 4 bytes) and allocates memory using malloc. If allocation fails, it terminates with error code 26.
3. Matrix Data Loading:
- Reads the matrix data into the allocated memory using fread. If the data cannot be read fully, it terminates with error code 29.
4. Error Handling:
- Ensures proper error codes for:
File opening issues (27).
Memory allocation issues (26).
File reading errors (29).
File closure errors (28).
5. Final Steps:
- Closes the file using fclose. If this fails, it terminates with error code 28.
Returns the base address of the allocated matrix.
### Task 2: Write Matrix
- The write_matrix function writes a matrix of integers to a binary file in row-major order. The file format begins with an 8-byte header containing the number of rows and columns, followed by the matrix elements as 4-byte integers.

1. File Handling:

- The filename is passed as an argument, and the file is opened using fopen. If the file cannot be opened, the function terminates with error code 27.
Header Writing:

- The number of rows and columns is stored in a temporary buffer and written to the file. This ensures the file's header contains the correct matrix dimensions.
Matrix Data Writing:

- The matrix is written to the file one element at a time in row-major order. Each element occupies 4 bytes.
The function uses fwrite to write both the header and the matrix data. If fwrite fails, it terminates with error code 30.
2. Error Handling:

- If any file operation (fopen, fwrite, or fclose) fails, the function uses specific error codes (27, 30, 28) to indicate the type of failure.
4. Cleanup:

- Before returning, the function closes the file using fclose. If the closure fails, it terminates with error code 28.
- The stack and saved registers are restored to ensure the program's state remains consistent.

### Task 3: Classification
Classify.s is a matrix-based neural network classifier that implements the following main functionalities:

1. Argument Check and Initialization: 
- The program first checks if the correct number of command-line arguments (at least 5) is provided and allocates stack space to save the return address and registers. It then initializes all matrix pointers and related dimension variables.

2. Loading Pretrained Matrices m0 and m1 and Input Matrix: 
- The program uses the read_matrix function to load matrices from the specified files. For each matrix, it dynamically allocates memory and stores its dimensions (rows and columns).

3. Matrix Multiplication:

- Computes h = m0 × input and stores the result in h.
- Simulates the matrix multiplication process using a simple multiplication loop.
- Dynamically allocates memory for h to store the result.
4. Applying ReLU Activation Function: Applies the ReLU activation function to each element of matrix h (setting negative values to 0).

5. Computing Output Matrix o = m1 × h: Multiplies m1 and h to compute the final output matrix o.

6. Writing Output Matrix: 
- Writes the result matrix o to the specified file using the write_matrix function.

7. Classification Result (argmax Calculation): 
- Performs an argmax operation on the matrix o to find the index of the maximum value and prints the result in non-silent mode.

8. Memory Cleanup and Exit: 
- Frees all dynamically allocated memory, including matrices and intermediate variables, and then returns to the main program.
## Result
![image](https://hackmd.io/_uploads/B1eRqKUIGke.png)

## Reference
1. [cs61c Lab 3: RISC-V, Venus](https://cs61c.org/fa24/labs/lab03/#venus-m)
2. [sysprog21/classify-rv32i](https://github.com/sysprog21/classify-rv32i)
3. [Computer Architecture](https://wiki.csie.ncku.edu.tw/arch/schedule)