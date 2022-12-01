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

# Issues with compare: still setting AluOut
# but not setting flags...
# CMP - FAIL
CMP %r1 %r2
# Expected PSR flags to be set:
# L

# CMPI - FAIL
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
# %r4 = 6
# %r5 = 12

# LSH and LSHI - tbd
LSH %r3 %r5
LSHI $1 %r4
# Expected register contents:
# $r5 = 24
# $r4 = 12 

# LUI - tbd
LUI $4 %r6
# Expected register contents:
# %r6 = 1024

# LOAD - tbd
# Memory cell 1024 is init'd with value -1 - address is in %r6
LOAD %r7 %r6
# Expected register contents:
# %r7 = -1

# STORE - tbd
ADDI $1 %r6
STOR %r7 %r6
# Expected MEMORY contents:
# M[1025] = -1


# Bcond, Jcond, JAL in separate test file.
