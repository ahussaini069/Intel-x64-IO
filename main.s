	.data
headMsg:	.asciz	"Start av testprogram. Skriv in 5 tal!"
endMsg:	.asciz	"Slut pa testprogram"
testmsg: .asciz	"debug value %d\n"
buf:	.space	64
inbuf:	.space	64
outbuf:	.space	64
MAXPOS:	.quad	63
buf_empty:	.quad	1
inpos:	.quad	0
outpos:	.quad	0
sum:	.quad	0
count:	.quad	0
temp:	.quad	0


movq	%rdi, %r15
	iter:
		cmpb	$0, (%r15)
		je		end_iter
		movq	(%r15),%rdi
		call	putChar
		incq	%r15
		jmp		iter
	end_iter:


	.text
	.global	main
main:
	pushq	$0
	movq	$headMsg,%rdi
	call	putText
	call	outImage
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

checkInPos:
	pushq	%r11
	cmpq	$0,buf_empty
	je	jump_check_in1
	call inImage
	jump_check_in1:
	cmpq	$inpos,MAXPOS  # Check if outpos is larger than maxpos
	jl	jump_check_in2
	call inImage
	jump_check_in2:
	popq	%r11
	ret
	
checkOutPos:
	pushq	%rax
	cmpq	$outpos,MAXPOS  # Check if outpos is larger than maxpos
	jl	jump_check_out
	call outImage
	jump_check_out:
	popq	%rax
	ret

inImage:
	pushq	%rax
	movq	$0,%rdi
	call	setInPos
	movq 	$inbuf, %rdi # lägg i buf, adr. arg1
    movq 	MAXPOS,%rsi # högst 63 tecken, arg2
    movq 	stdin, %rdx # från standard input, arg3
    call	fgets
	movq	$0,buf_empty
	popq	%rax
	ret

getChar:
	pushq	%r8
	getchar_start:
	call	checkInPos
	movq	$inbuf,%r8		# base address to the buf
	addq	inpos,%r8		# offset with in position
	movb	(%r8),%al 		# get char of this position, %al return, 1 byte = 1 char
	jmp_char:
	incq	inpos 			# move the inpos pointer one step forward
	popq	%r8
	ret
# Parameter %rdi, character if is a number, return 0 if not otherwise 1
isANumber:
	movq	$0,%rax 	# the return value, default 0
	cmpq	$'0',%rdi
	jl	not_number 		# if less than char '0', not a number
	cmpq	$'9',%rdi
	jg	not_number 		# if greater than char '9' return directly
	incq %rax 			# return 1 if is a number
	not_number:
	ret

# Parameter %rdi, character if is a number, return 0 if not otherwise 1
isABlank:
	movq	$0,%rax 	# the return value, default 0
	cmpq	$' ',%rdi
	jne	not_blank
	incq	%rax
	not_blank:
	cmpq	$'\n',%rdi
	jne	not_rawbreak
	incq	%rax
	not_rawbreak:
	ret

getInt:
	pushq	%r8 	# the return value, the number
	pushq	%r9 	# for the character
	pushq	%r10 	# for the pos/neg
	movq	$0,%r10
	movq	$0,%r8
	jmp_isABlank:
	call	getChar
	cmpb	$0,%al
	jne		get_int_notempty
	call 	inImage
	call	getChar
	get_int_notempty:
	movzbq	%al,%r9
	movq	%r9,%rdi
	call	isABlank
	cmpq	$1, %rax	# inledande space, ignore and get next char
	je jmp_isABlank
	cmpq	$'-',%r9
	je	int_neg
	cmpq	$'+',%r9
	je	int_pos
	jmp itr_getint_firstchar_jump
	itr_getint:
		movq	$0,%r9
		call	getChar
		movzbq	%al,%r9
		itr_getint_firstchar_jump:
		movq	%r9,%rdi
		call	isANumber
		cmpq	$0, %rax
		je	int_not_number
		pushq	%r9
		movq	$10,%r9
		movq	%r8,%rax
		mulq	%r9 		# the previous number have to multiply with 10, then add the new number
		popq	%r9
		subq	$48,%r9		# convert from ascii to number
		addq	%r9,%rax	# S * %rax = %rdx,%rax
		movq	%rax,%r8
		call	getInPos
		cmpq	MAXPOS,%rax	# finish when reach the maxpos
		je	int_final
	jmp	itr_getint
	int_neg:
		movq $1,%r10 #negative
		jmp	itr_getint
	int_pos:
		movq $0,%r10
		jmp	itr_getint
	int_not_number: 		# if the char is not a number
		call getInPos
		movq	%rax,%rdi
		decq 	%rdi 		# , we have to set the inpos one step back.
		call	setInPos
	int_final:
		cmpq	$1,%r10
		jne	int_final_notneg
		negq	%r8			# take negation if r10 is 1.
		int_final_notneg:
		movq	%r8, %rax
		popq	%r10
		popq	%r9
		popq	%r8
	ret

//Parameter %rdi, address store the data
//Parameter %rsi, max number of char to be read
//Return %rax, number of char have been read
getText:
	pushq	%r8
	pushq	%r9
	movq	$0,%r8
	movq	%rsi,%r9
	call	getChar
	cmpb	$0,%al
	jne		get_txt_notempty
	call 	inImage
	itr_gettext:
		cmpq	$0,%r9
		je	getText_final
		call	getChar
		get_txt_notempty:
		cmpb	$0,%al		# reach the final character
		je	getText_final
		movzbq	%al,%rax
		movq	%rax,(%r8,%rdi)
		decq	%r9
		incq	%r8
		jmp	itr_gettext
		getText_final:
		movq	%r8,%rax
		popq	%r9
		popq	%r8
	ret


getInPos:
	movq inpos,%rax
	ret

setInPos:
	pushq	%rax
	cmpq MAXPOS,%rdi
	jle inpos_not_ge
	movq MAXPOS,%rdi
	inpos_not_ge:
	cmpq $0,%rdi
	jge inpos_not_neg
	movq $0,%rdi
	inpos_not_neg:
	movq %rdi,inpos
	popq	%rax
	ret

outImage:
	pushq	%rdi
	movq	$outbuf,%rdi
	call	puts
	movq	$0,outpos
	popq	%rdi
	ret

putInt:
	pushq	%rax
	pushq	%rdx
	pushq	%r9
	pushq	%r10
	movq	%rdi,%rax
	movq	$10,%r9
	movq	$0,%r10
	cmpq	$0,%rax
	jge	itr_number		# if negative, we have to put an - char
	movq	$'-',%rdi
	call	putChar
	negq	%rax  		# example: -1 stores ffff, -2 fffe, take invers will be 0002
	itr_number:
		movq	$0, %rdx
		idivq	%r9			# %rax / s = %rax ... %rdx
		addq	$48,%rdx 	# numbers starts from 48 in ascii
		movq	%rdx,%rdi
		pushq	%rdx		# the number after convert is in reverse order, we have to reverse again.
		incq	%r10		# the counter how much numbers in the stack
		cmpq	$0,%rax
		jne	itr_number
	itr_pop_number:
		popq	%rdi
		call	putChar
		decq	%r10
		cmpq	$0,%r10
		jne	itr_pop_number
	popq	%r10
	popq	%r9
	popq	%rdx
	popq	%rax
	ret
		
putText:
	pushq	%r9
	movq	%rdi, %r9
	itr_putChar:
		cmpb	$0, (%r9)
		je	end_itr_putChar
		movq	(%r9),%rdi
		call	putChar
		incq	%r9
		jmp	itr_putChar
	
	end_itr_putChar:
	popq	%r9

//Parameter %rdi, character which should be put into outbuffer
putChar:
	pushq	%r8
	call	checkOutPos
	movq	$outbuf,%r8 	# the base address of outbuf
	addq	outpos,%r8 		# the address with offset/position
	movq	%rdi,(%r8)
	incq	outpos
	popq	%r8
	ret

getOutPos:
	movq outpos,%rax
	ret

setOutPos:
	pushq	%rax
	cmpq MAXPOS,%rdi
	jle outpos_not_ge
	movq MAXPOS,%rdi
	outpos_not_ge:
	cmpq $0,%rdi
	jge outpos_not_neg
	movq $0,%rdi
	outpos_not_neg:
	movq %rdi,outpos
	popq	%rax
	ret
	