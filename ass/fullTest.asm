# ADD and ADDI - PASS
ADDI $1 %r1
ADDI $2 %r2
ADD %r1 %r2
# Expected register contents:
# %r1 = 1
# %r2 = 3

# SUB and SUBI - PASS
SUBI $1 %r2 
SUB %r2 %r1
# Expected register contents:
# %r1 = -1
# %r2 = 2

# CMP - pass?
CMP %r1 %r2
# Expected PSR flags to be set:
# L

# CMPI - pass?
CMPI $0 %r3
# Expected PSR flags to be set:
# Z

# Would be good to do more CMP/CMPI testing here.

# AND and ANDI - PASS
ADD %r2 %r3
ADD %r1 %r3
AND %r2 %r3
ANDI $3 %r2
# Expected register contents:
# %r2 = 2
# %r3 = 0

# OR and ORI - PASS
ADD %r1 %r2
OR %r2 %r3
ORI $7 %r2
# Expected register contents:
# %r2 = 7
# %r3 = 1

# XOR and XORI - PASS
ORI $11 %r4
XOR %r3 %r4
XORI $6 %r3
# Expected register contents:
# %r3 = 7
# %r4 = 10

# MOV and MOVI - PASS
MOV %r4 %r5
MOVI $1 %r4
# Expected register contents:
# %r4 = 1
# %r5 = 10

# LSH and LSHI - PASS
LSH %r4 %r5 
LSHI $1 %r4
# Expected register contents:
# $r5 = 20
# $r4 = 2 

# LUI - PASS
LUI $4 %r6
# Expected register contents:
# %r6 = 1024

# LOAD - PASS
# Memory cell 1024 is init'd with value -1 - address is in %r6
LOAD %r7 %r6
# Expected register contents:
# %r7 = -1

# STORE - PASS
ADDI $10 %r6
STOR %r5 %r6
# Expected MEMORY contents:
# M[1034] = 20


# todo: Bcond, Jcond, JAL in separate test file.
