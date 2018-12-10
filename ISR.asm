; ISR.asm
; Name: Vikram Pandian and Amitesh Yeleswarapu
; UTEid: vip248 and avy89
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x4600
               

.ORIG x2600
		
	ST R0, ISRR0
	ST R1, ISRR1
	ST R2, ISRR2
	ST R7, ISRR7
	

	LDI R0, KBDR
	AND R1, R1, #0
	ADD R1, R0, #0
	
	LD R2, A
	ADD R2, R1, R2
	BRz storeInput
	
	LD R2, C
	ADD R2, R1, R2
	BRz storeInput

	LD R2, G
	ADD R2, R1, R2
	BRz storeInput

	LD R2, U
	ADD R2, R1, R2
	BRz storeInput	

	BRnzp done
storeInput
	
	STI R0, Dest

done	LD R0, ISRR0
	LD R1, ISRR1
	LD R2, ISRR2
	LD R7, ISRR7
	
	RTI
KBDR	.FILL xFE02
KBSR	.FILL xFE00
Dest	.FILL x4600

ISRR0	.BLKW	1
ISRR1	.BLKW	1
ISRR2	.BLKW	1
ISRR7	.BLKW	1

A	.FILL	x-41
C	.FILL	x-43
G	.FILL	x-47
U	.FILL	x-55
.END
		