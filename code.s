%rdi
%rsi
%rdi
%rdx
%rcx
%r8
%r9

// print user input
main:
    pushq   $0
    movq    $buff, %rdi    # Load the address of the buffer into %rdi
    movq    $64, %rsi      # Load the size of the buffer into %rsi
    movq    stdin, %rdx     # Load stdin into %rdx
    call    fgets           # Call fgets
    movq $buff, %rdi      # Load the address of the buffer into %rdi
    call puts
    call    exit            # Exit the program


// print a variable
main:
    pushq $0
    movq $string, %rdi   # Load the address of the string into %rdi
    call printf               # Call printf to print the string
    call exit                 # Exit the program
main:
    pushq $0
    movq $string, %rdi   # Load the address of the string into %rdi
    call puts            # Call puts to print the string
    call exit            # Call exit to terminate the program

// print a number
main:
    pushq $0
    movq $5, %rsi   # Load the address of the string into %rdi
    movq $format, %rdi
    call printf               # Call printf to print the string
    call exit                 # Exit the program

putText:
    movq $5, %rax
    iter:
        movq    $buf, %rdi    # Load the address of the buffer into %rdi
        movq    $64, %rsi      # Load the size of the buffer into %rsi
        movq    stdin, %rdx     # Load stdin into %rdx
        movq $buf, %rdi      # Load the address of the buffer into %rdi
        pushq %rax
        call fgets
        popq %rax
        dec %rax
        jne iter
    ret

putText:
    movq $5, %rax
    iter:
        movq    $buf, %rdi    # Load the address of the buffer into %rdi
        movq    $64, %rsi      # Load the size of the buffer into %rsi
        movq    stdin, %rdx     # Load stdin into %rdx
        movq $buf, %rdi      # Load the address of the buffer into %rdi
        add %rdi, sum
        pushq %rax
        call fgets
        popq %rax
        dec %rax
        jne iter
    movq $sum, %rdi
    //movq $format, %rdi
    call puts       
    ret


movq	$sum,%r8 	# the base address of outbuf
movq $buf, (%r8)
movq $0, %rdi
movq (%r8), %rdi



pushq   $0                  # Null terminator for fgets

movq    $buf, %rdi    # Load the address of the buffer into %rdi
movq    $64, %rsi      # Load the size of the buffer into %rsi
movq    stdin, %rdx     # Load stdin into %rdx
call    fgets           # Call fgets

movq    $buf, %rdi      # Load the address of the buffer into %rdi
call    atoi            # Convert ASCII string to integer

movq    %rax, %rsi      # Move the result to %rsi for printf

movq    $format, %rdi   # Load the address of the format string into %rdi
call    printf          # Call printf to print the number
