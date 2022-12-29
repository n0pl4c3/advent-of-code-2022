

	section .text
	global _start

_start:
	call get_stat				 ; Get Info about Inputfile
	
	call open_fd				 ; Open input.txt

	call read_inputfile			 ; Read Contents of input.txt

	call close_fd           		 ; Close input.txt

	call remove_newline			 ; Replace newline in input with nullbyte

	mov rax, [stat + STAT.st_size]
	dec rax
	push rax                                 ; We will need this more often

	;; Print message
	mov rdi, welcome
	mov rsi, welcome_len
	call write_stdout
	
	;; Print input
	mov rdi, input
	mov rsi, [rsp]
	call write_stdout
	call print_newline

	;; Part 1
	
	mov rdi, 4
	call find_start_marker
	push rax
	
	cmp rax, 0
	je .failed

	mov rdi, solution1
	mov rsi, solution1_len
	call write_stdout

	mov rdi, [rsp]
	call print_number
        call print_newline

        ;; Part 2
	
	mov rdi, 14
	call find_start_marker
	push rax
	
	cmp rax, 0
	je .failed

	mov rdi, solution2
	mov rsi, solution2_len
	call write_stdout

	mov rdi, [rsp]
	call print_number
        call print_newline
	
	jmp .exit

	.failed:
	mov rdi, error
	mov rsi, error_len
	call write_stdout
	call print_newline	

	.exit:	
	mov rdi, [rsp]                           ; Set exit value
	mov rax, 60				 ; Syscall sys_exit
	syscall
	
	;; Writes text to stdout
	;; rdi ... Address of String
	;; rsi ... Length of string
write_stdout:
	mov rax, 1				 ; Syscall sys_write
	mov rdx, rsi                             ; Length to print
	mov rsi, rdi				 ; Address of string to print
	mov rdi, 1				 ; Use stdout
	syscall
	ret

print_number:
	push rbp
	mov rbp, rsp

	mov rax, rdi
	mov rcx, 0

	.loop:
	mov rdx, 0
	mov r9, 10
	div r9
	
	add rdx, 48
	push rdx
	
	inc rcx

	cmp rax, 0
	jne .loop

	mov rdi, rsp
	mov rax, rcx
	mov r8, 8
	mul r8
	mov rsi, rax
	call write_stdout
	
	mov rsp, rbp
	pop rbp
	ret
	
print_newline:
	mov rax, 1				 ; Syscall sys_write
	mov rdx, 1                               ; Length to print

	push 0xA				 ; 0xA - newline
	
	mov rsi, rsp				 ; Address of string to print
	mov rdi, 1				 ; Use stdout
	syscall
	pop rax
	ret
	
open_fd:
	mov rax, 2		; Syscall sys_open
	mov rdi, filename       ; Load address of filename
	mov rsi, 0		; No flags needed, O_RDONLY
	mov rdx, 0		; Mode not necessary when only reading
	syscall
	mov [fd], eax           ; Save file descriptor
	ret

close_fd:	
        mov edi, [fd]
        mov rax, 3              ; Syscall sys_close
        syscall
	ret

read_inputfile:
	mov rax, 0				 ; Syscall sys_read
	mov rdi, [fd]				 ; Read from File Descriptor
	mov rsi, input				 ; Read into 1KB buffer
	mov rdx, [stat + STAT.st_size]           ; Read as many bytes as input is long
	syscall
	ret

remove_newline:
	mov r8, input
	add r8, [stat + STAT.st_size]
	dec r8
	mov byte [r8], 0
	ret

;; rdi - number of equal characters needed
find_start_marker:
	;; Preamble
	push rbp
	mov rbp, rsp

        mov r10, rdi 	                         ; Number of non-equal chars needed
	
	xor rax, rax				 ; Clear RAX
	mov rdi, input                           ; Use RDI as input pointer

	mov r11, r10                             ; Create Copy for preliminary loop
	dec r11                                  ; Preliminary adds n-1 items to stack (no solution possible yet)
	
	mov r8, 0      				 ; r8 saves location of rightmost known byte in the quartet that causes a duplicate
	mov rcx, 0                               ; Counter of characters written to stack

        push 0x0
	
	.preliminary_loop:
        mov al, byte[rdi]	                 ; Fetch next character

	mov rsi, 0		                 ; Counter for inner loop 
	.preliminary_loop_inner:
	mov r9, rsp		                 ; Grab Stack Pointer
	add r9, rsi                              ; Add rsi twice due to stack alignment
	add r9, rsi
	
	cmp ax, [r9]		                 ; Check if equal
	jne .no_match
	mov rdx, rcx		                 ; Compute r8 = number of bytes pushed - number of byte checked (from right to left)
	sub rdx, rsi
	cmp rdx, r8
	jle .not_relevant
        mov r8, rdx
	.not_relevant:
	.no_match:
 
	inc rsi
	cmp rsi, rcx
	jle .preliminary_loop_inner

	inc rcx
	inc rdi
	push ax
	cmp rcx, r11
	jne .preliminary_loop

	;; ---------------------------------------------------------------------
	
	.loop_compare:

	mov al, byte[rdi]

	mov r11, r10                             ; Create Copy of max count
	dec r11                                  ; Check n-1 elements
	mov rsi, 0
	.inner_loop:
	mov r9, rsp
	add r9, rsi
	add r9, rsi

	cmp ax, [r9]
	jne .not_matching

        mov rdx, r11
	sub rdx, rsi
	
	cmp rdx, r8
	jle .not_matching
	mov r8, rdx
	.not_matching:
        inc rsi
	cmp rsi, r11
        jl .inner_loop
	
	cmp r8, 0
	je .solved_one
	
	.equal:
	push ax
	inc rdi
	inc rcx
	dec r8
        cmp rcx, [stat + STAT.st_size]
	je  .not_found
	jmp .loop_compare

        .not_found:	
	mov rax, 0
	mov rsp, rbp
	pop rbp
	ret

	.solved_one:
	inc rcx
	mov rax, rcx
	mov rsp, rbp
	pop rbp
	ret


	
get_stat:
	mov rax, 4				 ; Syscall sys_stat
	mov rdi, filename
	mov rsi, stat
	syscall
	ret


	
	section .bss

	input	 resb 8192     	                 ; Assuming 8KB should be more than enough
	
	fd	 resd 1

	stat     resb 144

	struc STAT
		.st_dev         resq 1
		.st_ino         resq 1
		.st_nlink       resq 1
		.st_mode        resd 1
		.st_uid         resd 1
		.st_gid         resd 1
		.pad0           resb 4
		.st_rdev        resq 1
		.st_size        resq 1
		.st_blksize     resq 1
		.st_blocks      resq 1
		.st_atime       resq 1
		.st_atime_nsec  resq 1
		.st_mtime       resq 1
		.st_mtime_nsec  resq 1
		.st_ctime       resq 1
		.st_ctime_nsec  resq 1
	endstruc
	
	
	section .data
	
	filename db "input.txt", 0
	welcome  db "Input to the program is: ", 0x0
	welcome_len equ $ - welcome
	solution1 db "Solution found for Part 1 is: ", 0x0
	solution1_len equ $ - solution1
	solution2 db "Solution found for Part 2 is: ", 0x0
	solution2_len equ $ - solution2
	error  db "No solution was found: ", 0x0
	error_len equ $ - error
	
	
	
