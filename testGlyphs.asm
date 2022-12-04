#r1 = 0
#r3 = 11111111 11111111
#while r2<r3
#    r2 ++
#if r2 >= r3
#    r1 ++
#    r2 = 0
#    Display r1
#    GOTO "while r2<r3"

LUI $-127 %r3
ORI $-127 %r3

CMP %r2 %r3
BGE $3
ADDI $1 %r2
BUC $-3
ADDI $1 %r1
LUI $0 %r2
ANDI $0 %r2

#Address calculation and store: address is 00010000 00000000
LUI $16 %r4
STOR %r1 %r4
BUC $-9
