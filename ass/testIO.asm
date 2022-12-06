#Enter a while loop to read from switches and write that value to LEDs

#calculate led/switch address: 0xFFFC
#0b 1111 1111	1111 1100
#0d -1			-3 ? (to make the assembler happy)
LUI $-1 %r1
ORI $-4 %r1

#load switch data into register
LOAD %r2 %r1
LOAD %r2 %r1
LOAD %r2 %r1

#store address into LEDs
STOR %r2 %r1

#loop
BUC $-3
