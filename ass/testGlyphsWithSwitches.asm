#r1 = switches address
#r2 = hundreds place address
#r3 = tens place address
#r4 = ones place address
#while true:
#    r5 = switch values
#    r6 = lower three bits of r5
#    r7 = next
#    r8 = next
#    load r6 r4
#    load r7 r3
#    load r8 r2

#Calculate switches address: 11111111 11111100
LUI $-1 %r1
ORI $-4 %r1

#Calculate ones place address:
LUI $16 %r4
#Calculate tens place:
MOV %r4 %r3
ADDI $1 %r3
#Calculate hundreds place:
MOV %r3 %r2
ADDI $1 %r2


LOAD %r5 %r1
MOVI $-6 %r12
LSH %r12 %r5

MOV %r5 %r6
ANDI $7 %r6

MOV %r5 %r7
ANDI $56 %r7
MOVI $-3 %r11
LSH %r11 %r7 

MOV %r5 %r8
#AND 1 11000000
LUI $1 %r9
ORI $-64 %r9
AND %r9 %r8
#RSH 6
MOVI $-6 %r13
LSH %r13 %r8

STOR %r6 %r4
STOR %r7 %r3
STOR %r8 %r2

MOVI $7 %r10
JUC %r10
