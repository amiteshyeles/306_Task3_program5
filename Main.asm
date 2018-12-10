; Main.asm
; Name: Amitesh Yeleswarapu and Vikram Pandian
; UTEid: AVY89 and VIP248
; Continuously reads from x4600 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.
               .ORIG x4000
; initialize the stack pointer

	LD R6, SP


; set up the keyboard interrupt vector table entry

	LD R0, ISRSTART
	STI R0, IVT

; enable keyboard interrupts
	LD R0, BUFFER
	STI R0, KBSR

	AND R5, R5, #0	
loop	LDI R3, BUFFER
	BRnz loop
	
	
; start of actual program
startprogram	
	AND R2, R2, #0
	LEA R2, ACHAR	;loads location of ACHAR
	LDI R0, BUFFER
	;BRz inloop	; check if valid letter
	TRAP x21	
	AND R1, R1, #0
	STI R1, BUFFER
	; PROCESS R0
			;check R5, depending on where it is, jump: 0=startcA, 1=startcU, 2=startcG, 3=stopcU, 4=stopcAG1, 5=stopcAG2, 6=stopcA2
	AND R4, R4, #0
	ADD R4, R5, #0
	Brz startcA
	AND R4, R4, #0
	ADD R4, R5, #-1
	Brz startcU
	AND R4, R4, #0
	ADD R4, R5, #-2
	Brz startcG
	AND R4, R4, #0
	ADD R4, R5, #-3
	Brz stopcU	;if R5 is 3 then it is in the looking for stop codon phase, so jump all the way down
	AND R4, R4, #0
	ADD R4, R5, #-4
	Brz stopcAG1
	AND R4, R4, #0
	ADD R4, R5, #-5
	Brz stopcAG2
	AND R4, R4, #0
	ADD R4, R5, #-6
	Brz stopcA2
	
	
startcA	

	LD R2, ACHAR
	ADD R2, R0, R2
	BRnp loop	;if not A, go back up to get new letter
	AND R5, R5, #0	;if A, change R5 counter to 1
	ADD R5, R5, #1
	Brnzp loop	;loop back to get new letter 


startcU

	LD R2, UCHAR
	ADD R2, R0, R2
	BRnp #3		;if not U, jump down to see if it is A
	AND R5, R5, #0	;if U, change R5 counter to 2
	ADD R5, R5, #2
	Brnzp loop	;loop back to get new letter

	LD R2, ACHAR
	ADD R2, R0, R2
	BRnp #3		;if not A, jump a little below and make R5 0
	AND R5, R5, #0
	ADD R5, R5, #1	;if A, change R5 counter to 1
	Brnzp loop	;loop back to get new letter
	AND R5, R5, #0	;if the letter is not A or U, it will reset R5 to 0 and go back to startcA state
	Brnzp loop


startcG
	LD R2, GCHAR
	ADD R2, R0, R2
	BRnp #3		;if not G, jump down to see if it is A
	AND R5, R5, #0	;if G, change R5 counter to 3
	ADD R5, R5, #3
	Brnzp NEXTSTEP	;jump to next step of processing

	LD R2, ACHAR
	ADD R2, R0, R2
	BRnp #3		;if not A, jump a little below and make R5 0
	AND R5, R5, #0
	ADD R5, R5, #1	;if A, change R5 counter to 1
	Brnzp loop	;loop back to get new letter
	AND R5, R5, #0	;if the letter is not A or U, it will reset R5 to 0 and go back to startcA state
	Brnzp loop



NEXTSTEP
	;will be checking for stop codon
	LD R0, pipesymbol
	TRAP x21
	Brnzp loop

stopcU	
	LD R2, UCHAR
	ADD R2, R0, R2
	BRnp loop	;if not U, go back up to get new letter
	AND R5, R5, #0	;if U, change R5 counter to 4
	ADD R5, R5, #4
	Brnzp loop	;loop back to get new letter 

stopcAG1
	LD R2, ACHAR
	ADD R2, R0, R2
	BRnp #3		;if not A, jump to see if G
	AND R5, R5, #0	;if A, change R5 counter to 5
	ADD R5, R5, #5
	Brnzp loop	;loop back to get new letter 

	LD R2, GCHAR
	ADD R2, R0, R2
	BRnp #3		;if not G, jump down to see if U again
	AND R5, R5, #0	;if G, change R5 counter to 6
	ADD R5, R5, #6
	Brnzp loop	;loop back to get new letter 
	
	LD R2, UCHAR
	ADD R2, R0, R2
	BRnp #3		;if not U, jump a little below and make R5 3
	AND R5, R5, #0
	ADD R5, R5, #4	;if U, change R5 counter to 4
	Brnzp loop	;loop back to get new letter
	AND R5, R5, #0	;if the letter is not A, U, or G, it will reset R5 to 3 and go back to stopcU state
	ADD R5, R5, #3
	Brnzp loop

stopcAG2	;checking for last G or A

	LD R2, ACHAR
	ADD R2, R0, R2
	BRnp #3		;if not A, jump to see if G
	AND R5, R5, #0	;if A, change R5 counter to 7
	ADD R5, R5, #7
	Brnzp DONE	;end code, stop codon is reached

	LD R2, GCHAR
	ADD R2, R0, R2
	BRnp #3		;if not G, jump down to see if U again
	AND R5, R5, #0	;if G, change R5 counter to 7
	ADD R5, R5, #7
	Brnzp DONE	;end code, stop codon is reached

 	LD R2, UCHAR
	ADD R2, R0, R2
	BRnp #3		;if not U, jump a little below and make R5 3
	AND R5, R5, #0
	ADD R5, R5, #4	;if U, change R5 counter to 4
	Brnzp loop	;loop back to get new letter
	AND R5, R5, #0	;if the letter is not A, U, or G, it will reset R5 to 3 and go back to stopcU state
	ADD R5, R5, #3
	Brnzp loop

stopcA2

	LD R2, ACHAR
	ADD R2, R0, R2
	BRnp #3		;if not A, jump to see if U
	AND R5, R5, #0	;if A, change R5 counter to 7
	ADD R5, R5, #7
	Brnzp DONE	;end code, stop codon is reached

	LD R2, UCHAR
	ADD R2, R0, R2
	BRnp #3		;if not U, jump a little below and make R5 3
	AND R5, R5, #0
	ADD R5, R5, #4	;if U, change R5 counter to 4
	Brnzp loop	;loop back to get new letter
	AND R5, R5, #0	;if the letter is not A, U, or G, it will reset R5 to 3 and go back to stopcU state
	ADD R5, R5, #3
	Brnzp loop

DONE
	TRAP x25


SP		.FILL	x4000
IVT		.FILL	x180
ISRSTART	.FILL	x2600
MASK		.FILL	x4000
BUFFER		.FILL 	x4600
KBSR		.FILL	xFE00

ACHAR		.FILL 	x-41
UCHAR		.FILL	x-55
GCHAR		.FILL	x-47
CCHAR		.FILL	x-43
pipesymbol 	.FILL #124
		.END
