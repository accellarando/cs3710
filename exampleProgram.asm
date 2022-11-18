.text
#Load data from memory into regfile
#0x100
MOVI $30 %r2
LOAD %r1 %r2
#Set flags - load something into memory address $30 s.t. this will overflow!
ADDI $1 %r1
#Store result into memory
MOVI $31 %r2
STOR %r1 %r2
#Reload result into regfile
LUI $127 %r1
ORI $127 %r1
.loop:
	#Calculate mem addr
	MOVI $31 %r3
	LOAD %r2 %r3
	#Set flags and do arithmetic
	ADDI $1 %r1
	CMP %r1 %r2
	BNE $-4
#Write result into memory
MOVI $32 %r2
STOR %r2 %r1
#Display result at output
MOVI $62 %r2
STOR %r1 %r2
