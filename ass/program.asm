#Register usage:
#r1: address of gpio pins
#r2: address of ones place
#r3: address of tens place
#r4: address of hundreds place
#r5: current state:
#    0000: wait for interrupt -> go to states 1 (on A) or 4 (on B)
#    0001: beam A interrupted - wait for beam B -> go to state 2 on B
#    0002: beam B interrupted - wait for beams to reset -> go to state 3 once both are active
#    0003: increment counter -> proceed immediately to state 0
#    0004: beam B interrupted - wait for beam A -> go to state 5 on A
#    0005: beam A interrupted - wait for beams to reset -> go to state 6 once both are active
#    0006: decrement counter -> proceed immediately to state 0
#    what to do if only one beam is triggered?? will that happen?
#r6: value of gpio pins
#r7: current ones place
#r8: current tens place
#r9: current hundreds place
#r10-r15: temporary registers

#Address calculation


#Main loop:
.main
#Get gpio
LOAD %r6 %r1

#Check state, jump to different instruction depending on state
CMPI $0 %r5
BEQ .zero
CMPI $1 %r5
BEQ .one
CMPI $2 %r5
BEQ .two
CMPI $3 %r5
BEQ .three
CMPI $4 %r5
BEQ .four
CMPI $5 %r5
BEQ .five
CMPI $6 %r5
BEQ .six

.zero
#if A triggered, change state to 1
MOV %r1 %r11
ANDI $1 %r11
CMPI $1 %r1
#check this branch value...
BNE $3
MOVI $1 %r5
BUC .main

#get B - could move this to a function call but idk if it's worth it tbh
LUI $-1 %r10
ORI $-1 %r10
LSH %r10 %r1
#if B triggered, change state to 4
CMPI $1 %r1
#check this branch amt
BNE $2
MOVI $4 %r5

#loop
BUC .main

.one
#if B triggered, change state to 2
LUI $-1 %r10
ORI $-1 %r10
LSH %r10 %r1
ANDI $1 %r1
CMPI $1 %r1
BNE $2
MOVI $2 %r5

#loop
BUC .main

.two
#if a and b reset, ie ab==00, change state to 3
ANDI $3 %r1
CMPI $0 %r1
BNE .main
MOVI $3 %r5

#loop
BUC .main

.three
#load from memory
LOAD %r7 %r2
LOAD %r8 %r3
LOAD %r9 %r4

#increment
ADDI $1 %r7

#check ones place carry
CMPI $10 %r7
BNE .threeUpdate
MOVI $0 %r7
ADDI $1 %r8

#check tens place carry
CMPI $10 %r8
BNE .threeUpdate
MOVI $0 %r8
ADDI $1 %r9

#check hundreds place carry
CMPI $10 %r9
BNE .threeUpdate
MOVI $0 %r9

.threeUpdate
STOR %r7 %r2
STOR %r8 %r3
STOR %r9 %r4

#loop
BUC .main

.four
#if A triggered, change state to 5

#loop
BUC .main

.five
#if a and b reset, change state to 6

#loop
BUC .main

.six
#decrement counter

#loop
BUC .main
