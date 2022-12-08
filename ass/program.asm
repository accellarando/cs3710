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
#
#    what to do if only one beam is triggered?? will that happen?
#    trigger reset button?
#r6: value of gpio pins
#r7: current ones place
#r8: current tens place
#r9: current hundreds place
#r15: address of 7seg display
#r10-r14: temporary registers

#Address calculation
LUI $-1 %r1
ORI $-1 %r1

LUI $16 %r2

MOV %r2 %r3
ADDI $1 %r3

MOV %r3 %r4
ADDI $1 %r4

LUI $-1 %r15
ORI $-5 %r15

#Main loop:
.main
#Put current values on the hex to 7 seg displays
LOAD %r7 %r2
LOAD %r8 %r3
LOAD %r9 %r4

MOV %r15 %r14
SUBI $1 %r14

LSHI $8 %r7
LSHI $12 %r8

MOVI $0 %r13
OR %r7 %r13
OR %r8 %r13
STOR %r13 %r14
STOR %r9 %r15

#Get gpio
LOAD %r6 %r1

#Check state, jump to different instruction depending on state
MOVI .zero %r10
CMPI $0 %r5
JEQ %r10

MOVI .one %r10
CMPI $1 %r5
JEQ %r10

MOVI .two %r10
CMPI $2 %r5
JEQ %r10

MOVI .three %r10
CMPI $3 %r5
JEQ %r10

MOVI .four %r10
CMPI $4 %r5
JEQ %r10

MOVI .five %r10
CMPI $5 %r5
JEQ %r10

MOVI .six %r10
CMPI $6 %r5
JEQ %r10

.zero
#if A triggered, change state to 1
MOV %r1 %r11
ANDI $1 %r11
CMPI $1 %r1
#check this branch value...
BNE $3
MOVI $1 %r5
MOVI .main %r10
JUC %r10

#get B - could move this to a function call but idk if it's worth it tbh
#if B triggered, change state to 4
ANDI $2 %r1
CMPI $2 %r1
#check this branch amt
BNE $3
MOVI $4 %r5

#loop
MOVI .main %r10
JUC %r10

.one
#if B triggered, change state to 2
ANDI $2 %r1
CMPI $2 %r1
BNE $3
MOVI $2 %r5

#loop
MOVI .main %r10
JUC %r10

.two
#if a and b reset, ie ab==00, change state to 3
ANDI $3 %r1
CMPI $0 %r1
MOVI .main %r10
JNE %r10
MOVI $3 %r5

#loop
JUC %r10

.three
#load from memory
LOAD %r7 %r2
LOAD %r8 %r3
LOAD %r9 %r4

#increment
ADDI $1 %r7

#check ones place carry
CMPI $10 %r7
MOVI .threeUpdate %r10
JNE %r10
MOVI $0 %r7
ADDI $1 %r8

#check tens place carry
CMPI $10 %r8
JNE %r10
MOVI $0 %r8
ADDI $1 %r9

#check hundreds place carry
CMPI $10 %r9
JNE %r10
MOVI $0 %r9

.threeUpdate
STOR %r7 %r2
STOR %r8 %r3
STOR %r9 %r4

#loop
MOVI .main %r10
JUC %r10

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
