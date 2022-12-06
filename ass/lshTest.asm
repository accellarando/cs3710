MOVI $1 %r1
MOV %r1 %r2
LSH %r1 %r2
#r2 should be 2'b10 
LSHI $1 %r1
#r1 should be 2'b10

MOVI $-1 %r3
LSH %r3 %r1
#r1 should be 1'b1
