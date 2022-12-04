#r1 = 0
#r3 = 11111111 11111111
#r5 = 00000001 01111101
#while r2<r3
#    r2 ++
#if r2 >= r3
#    r4 ++
#    if r4 >= r5
#        r1 ++
#        r2 = 0
#        Display r1
#        GOTO "while r2<r3"

LUI $-1 %r3
ORI $-1 %r3
LUI $1 %r5
ORI $125 %r5

CMP %r2 %r3
BHS $3
ADDI $1 %r2
BUC $-3

ADDI $1 %r4
CMP %r4 %r5
BHS $3
MOVI $4 %r6
JUC %r6

ADDI $1 %r1
LUI $0 %r2
ANDI $0 %r2

#Address calculation and store: address is 00010000 00000000
LUI $16 %r7
STOR %r1 %r7
MOVI $2 %r8
JUC %r8
