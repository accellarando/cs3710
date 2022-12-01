# ADD and ADDI - PASS
ADDI $1 %r1
ADDI $2 %r2
ADD %r1 %r2
# Expected register contents:
# %r1 = 1
# %r2 = 3

# SUB and SUBI - tbd
SUBI $1 %r2
SUB %r2 %r1
# Expected register contents:
# %r1 = -1
# %r2 = 2

# CMP - tbd
CMP %r1 %r2
# Expected PSR flags to be set:
# L

# CMPI - tbd
CMPI $0 %r3
# Expected PSR flags to be set:
# Z

# Would be good to do more CMP/CMPI testing here.

# AND and ANDI - tbd
ADD %r2 %r3
ADD %r1 %r3
AND %r2 %r3
ANDI $3 %r2
# Expected register contents:
# %r2 = 2
# %r3 = 0

# OR and ORI - tbd
ADD %r1 %r2
OR %r2 %r3
ORI $7 %r2
# Expected register contents:
# %r2 = 7
# %r3 = 1

# XOR and XORI - tbd
ORI $11 %r4
XOR %r3 %r4
XORI $6 %r3
# Expected register contents:
# %r3 = 1
# %r4 = 12

# MOV and MOVI - tbd
MOV %r5 %r4
MOVI $6 %r4
# Expected register contents:
# %r5 = 6
# %r5 = 12

# LSH and LSHI - tbd
LSH 
# Expected register contents:
# $r4 = 24
