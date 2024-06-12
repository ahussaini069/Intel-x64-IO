.data
headMsg:	.asciz	"Start av testprogram. Skriv in 5 tal!"
endMsg:	.asciz	"Slut pa testprogram"
buf:	.space	64
sum:	.quad	0
count:	.quad	0
temp:	.quad	0
MAXPOS:	.quad	64
inbuf:	.space	64
outbuf:	.space	64
buf_empty:	.quad	1
outpos:	.quad	0
inpos:	.quad	0


.text
.global	main
main:
	pushq	$0
	movq	$headMsg,%rdi
	call	putText
	call	outImage
	// movq	$buf,%rdi    #  this tre line for testing getText
	// call	getText
	// call	outImage
	call	inImage
	movq	$5,count
l1:
	call	getInt
	movq	%rax,temp
	cmpq	$0,%rax
	jge		l2
	call	getOutPos
	decq	%rax
	movq	%rax,%rdi
	call	setOutPos
	jmp l2
l2:
	movq	temp,%rdx
	add		%rdx,sum
	movq	%rdx,%rdi
	call	putInt
	movq	$'+',%rdi
	call	putChar
	decq	count
	cmpq	$0,count
	jne		l1
	call	getOutPos
	decq	%rax
	movq	%rax,%rdi
	call	setOutPos
	movq	$'=',%rdi
	call	putChar
	movq	sum, %rdi
	call	putInt
	call	outImage
	movq	$12,%rsi
	movq	$buf,%rdi
	call	getText
	movq	$buf,%rdi
	call	putText
	movq	$125,%rdi
	call	putInt
	call	outImage
	movq	$endMsg,%rdi
	call	putText
	call	outImage
	popq	%rax
	ret
.global inImage
inImage:
	movq 	$inbuf, %rdi 
	addq	inpos, %rdi
    movq 	MAXPOS,%rsi 
    movq 	stdin, %rdx 
    call	fgets
	ret

.global outImage
outImage:
	pushq	%rdi
	movq	$outbuf, %rdi
	call	puts
	movq	$0,outpos
	popq	%rdi

	ret

.global putText
putText:
	movq	%rdi, %r15
	iter:
		cmpb	$0, (%r15)
		je		end_iter
		movq	(%r15),%rdi
		call	putChar
		incq	%r15
		jmp		iter
	end_iter:
	ret

.global getInt
getInt:
	movq	$0, %r12
	movq	$1, %r11
	movq	$10,%r15
	movq	$inbuf, %rdi
	iter_input:
	addq	inpos, %rdi
	incq	inpos 
	movb	(%rdi), %dil    # get element 
	cmpb    $'\n', %dil          
	je		get_new_number
	cmpb    $'-', %dil       
	je		neg
	cmpb    $'+', %dil        
	jne		iter_input

	cmpb	$'0', %dil
	jl		return_string
	cmpb	$'9', %dil
	jg		return_string

	cmpb    $' ', %dil        
	je		iter_input


	subq	%48, %rdi
	movq	%rdi, %rdx
	pushq	%rdx
	incq	%r12



	neg:
		movq	$-1, %r11
		jmp		iter_input
	get_new_number:
		incq	inpos
		call inImage
		jmp getInt
	return_number:
		movq	%r14, %rax
		ret
	return_string:
		ret

.global getOutPos
getOutPos:
	movq outpos,%rax
	ret

.global setOutPos
setOutPos:
	cmpq	$MAXPOS, %rdi
	jle		no_gret
	movq MAXPOS,%rdi
	no_gret:
	cmpq	$0, %rdi
	jge		no_neg
	movq $0, %rdi
	no_neg:
		movq %rdi,outpos
	ret

.global putInt
putInt:
	movq	%rdi,%rax
	cmpq	$0, %rax
	jge		not_neg
	movq 	$45, %rdi
	call 	putChar
	imulq	$-1, %rax
	not_neg:
	movq	$10,%r15
	movq	$0,%r14
	iter_gratter10:
		movq	$0, %rdx
		idivq	%r15			
		addq	$48,%rdx 	
		movq	%rdx,%rdi
		pushq	%rdx		
		incq	%r14		
		cmpq	$0,%rax
		jne		iter_gratter10
	put_each_number:
		popq	%rdi
		call	putChar
		decq	%r14
		cmpq	$0,%r14
		jne	put_each_number
	ret

.global putChar
putChar:
	call	ckeck_outpos
	movq	$outbuf,%r8 	
	addq	outpos,%r8 		
	movq	%rdi,(%r8)
	incq	outpos
	ret

.global ckeck_outpos
ckeck_outpos:
	cmpq	$outpos,MAXPOS  
	jl	less
	call outImage
	less:
	ret

.global getChar
getChar:
	movq	$inbuf,%rax		
	addq	inpos,%rax
	movb	(%rax), %al
	incq	inpos 			
	ret

.global getText
getText:
	movq	%rsi, %r15
	movq	%rdi, %r14
	call	getChar
	cmpb	$0, %al
	jg		continue
	call	inImage				# 1. 
	iter_put_t:
		call	getChar
		continue:
		cmpb	$0, %al
		je		last_str
		cmpq	$0, %r15
		je		last_str
		movb	%al,(%r14)		# från 1 hoppar hit 
		incq	%r14
		decq	%r15
		jmp 	iter_put_t
	last_str:
	subq	$12, %r15
	movq	%r15, %rax	
    ret

.global getInPos
getInPos:
	movq inpos,%rax
	ret

.global setInPos
setInPos:
	cmpq	$MAXPOS, %rdi
	jle		no_grett
	movq MAXPOS,%rdi
	no_grett:
	cmpq	$0, %rdi
	jge		no_negative
	movq $0, %rdi
	no_negative:
		movq %rdi,inpos
	ret


#		how test our program
#		

