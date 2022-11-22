.text
#Load data from memory into regfile
#$1025 = 0b 100 00000001
LUI $8 %r2 #r2: 00000100 00000000
ORI $1 %r2 #r2: 00000100 00000001
LOAD %r1 %r2 #r1: whatever's in memory in r2
#I've put something in memory at $1025 so that this is 11111111 11111111 (in the ram.dat file)
#Set flags - load something into memory address $1025 s.t. this will overflow!
ADDI $1 %r1 #add something to r1 to make it overflow
#Store result into memory at 1026
LUI $8 %r2 #more address calculation for $1026
ORI $2 %r2
STOR %r1 %r2 #put the result from our overflow (should just be 0) into M[1026]
#Reload result into regfile


LUI $127 %r1 #load all 1s into R1
ORI $127 %r1
.loop:
	#Calculate mem addr 1025
	LUI $8 %r3
	ORI $1 %r3
	LOAD %r2 %r3 //load M[1025] into %r2
	#Set flags and do arithmetic
	ADDI $1 %r1 //Add 1 to r1, so this should overflow (we loaded all 1s into it)
	CMP %r1 %r2 //compare r1 to r2, set flags
	BNE $-5 //if r1 != r2, go back to loop. might be -6 idk
#Write result into memory
LUI $8 %r2
ORI $3 %r3
STOR %r2 %r1
#Display result at output
LUI $127 %r2
ORI $127 %r2
STOR %r1 %r2
