; Main.asm
; Name:
; UTEid: 
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

	
loop	LDI R3, BUFFER
	BRzp loop
	
	
; start of actual program
startprogram	
	AND R5, R5, #0
	AND R2, R2, #0
	LEA R2, ACHAR	;loads location of ACHAR
inloop	LDI R0, BUFFER
	BRz inloop	; check if valid letter
	TRAP x21	
	AND R1, R1, #0
	STI R1, BUFFER
	; PROCESS R0



BRnzp loop


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

		.END
