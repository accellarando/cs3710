#Initialize some counting variables
MOVI $10 %r2
MOVI $2 %r3
ADDI $1 %r1
CMP %r1 %r2
#Jump if not hit yet
JGT %r3
#Count back down to 0
SUBI $1 %r1
CMPI $0 %r1
BUC $-2
