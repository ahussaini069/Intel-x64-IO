.data
inbuf:    .space  64

.text
.global main
main:
    pushq   $0  
    movq 	$inbuf, %rdi 
    movq 	$64,%rsi 
    movq 	stdin, %rdx 
    call	fgets

    movq    $inbuf,  %rdi
    call puts

    call exit
