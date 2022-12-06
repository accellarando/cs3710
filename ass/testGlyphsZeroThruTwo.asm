#calculate people count address - ones
LUI $16 %r1
#calculate tens and hundreds places
MOV %r1 %r2
ADDI $1 %r2
MOV %r2 %r3
ADDI $1 %r3

#put in some numbers
MOVI $3 %r4
MOVI $4 %r5
MOVI $5 %r6

#store
STOR %r4 %r1
STOR %r5 %r2
STOR %r6 %r3
