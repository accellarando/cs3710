#Calculate gpio mem address
#Calculate led mem address
#Load gpi
#Store to led
#Loop

#gpi mem address: 0xFFFF
LUI $-1 %r1
ORI $-1 %r1

#led mem address: 0xFFFC
LUI $-1 %r2
ORI $-4 %r2

LOAD %r3 %r1
STOR %r3 %r2
BUC $-3
