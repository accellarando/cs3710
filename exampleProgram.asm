#Load data from memory into regfile
LOAD %1, 0x100
#Set flags - load something into memory address 0x100 s.t. this will overflow!
ADDI %1, 0x1 
#Store result into memory
STORE %1, 0x101
#Reload result into regfile
MOVI %1, 0xFFFF
.loop:
	LOAD %2, 0x101
	#Set flags and do arithmetic
	ADDI %1, 0x1
	CMP %1, %2
	BNE loop
#Write result into memory
STORE %1, 0x102
#Display result at output
STORE %1, 0xF00
