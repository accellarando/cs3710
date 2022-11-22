.text
#Load data from memory into regfile
#$1025 = 0b 100 00000001
LUI $8 %r2
ORI $1 %r2
LOAD %r1 %r2
#Set flags - load something into memory address $1025 s.t. this will overflow!
ADDI $1 %r1
#Store result into memory at 1026
LUI $8 %r2
ORI $2 %r2
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
LUI $8 %r2
ORI $3 %r3
STOR %r2 %r1
#Display result at output
LUI $127 %r2
ORI $127 %r2
STOR %r1 %r2
