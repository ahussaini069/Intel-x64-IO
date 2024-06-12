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
.global inImage
inImage:
	movq 	$inbuf, %rdi 
    movq 	MAXPOS,%rsi 
    movq 	stdin, %rdx 
    call	fgets
	movq	$0, inpos
	ret
.global outImage
outImage:
	pushq 	$0
	movq	$outbuf, %rdi
	call	puts
	movq	$0,outpos
	popq	%rax
	ret

.global putText
putText:
	movq	%rdi, %r15
	clean_blank:
		cmpb	$' ', (%r15)
		jne		iter
		incq	%r15
		jmp		clean_blank
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
movq	$0, %r13
iter_inbuf:
	movq	$inbuf, %rdi
	addq	inpos, %rdi
	call    atoi
	movq	$inbuf,%rdi		# get the list
	addq	inpos, %rdi		# index of interest 
	movb	(%rdi), %dil    # get element 
	cmpb    $'\n', %dil          
	je		get_new_number
	cmpb    $' ', %dil        
	je		pos_neg_blank
	cmpb    $'+', %dil        
	je		pos_neg_blank
	cmpb    $'0', %dil        
	je		number
	cmpb    $'-', %dil       
	je		pos_neg_blank
	cmpb	$0, %al
	je		return_string
	number:
		movq	$10,%r15
		movq	%rsi,%rax
		iter_bigger10:
			movq	$0, %rdx	# skip divitions with zero error
			idivq	%r15
			incq	inpos
			cmpq	$0,%rax
			jne		iter_bigger10
		
		cmpq	$0, %r14
		jl		neg
		movq	%rsi,%r14
		neg:
		jmp	return_number

	pos_neg_blank:
		movq	%rax,%r14
		incq	inpos
		jmp		iter_inbuf
		
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
		movq	$0, %rdx	# skippa noll divitions felmeddelande	
		idivq	%r15		# ex:  innan rax = 453	efter  rax=45,   rdx=3
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
	movq	%rsi, %r13
	iter_put_t:
		call	getChar
		cmpb	$0, %al
		je		last_str
		cmpq	$0, %r15
		je		last_str
		movb	%al,(%r14)
		incq	%r14
		decq	%r15
		jmp 	iter_put_t
	last_str:
	subq	%r13, %r15
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



