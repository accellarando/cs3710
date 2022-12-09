#I have A on GPI[0], mapped to PIN_AC18
#I have B on GPI[1], mapped to PIN_AD17
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
#r1: 0xFFFF (GPIO)
LUI $-1 %r1
ORI $-1 %r1

#r2: 0x1000 - people counter address (ones place)
LUI $16 %r2

#r3: 0x1001 - people counter address (tens place)
MOV %r2 %r3
ADDI $1 %r3

#r3: 0x1010 - people counter address (hundreds place)
MOV %r3 %r4
ADDI $1 %r4

#r15: 7-segment displays
LUI $-1 %r15
ORI $-5 %r15

#Main loop:
.main
#Put current values on the hex to 7 seg displays
LOAD %r7 %r2
LOAD %r8 %r3
LOAD %r9 %r4

#Move r15 to r14, subtract 1 to get memory address of lower 2 7seg displays
MOV %r15 %r14
SUBI $1 %r14

#Left shifts to pack tens and hundreds place into one memory word, with the ones place
#i think these numbers are right, but we might wanna check
LSHI $8 %r7
LSHI $12 %r8

#Clearing out r13, or-ing in r7 and r8 (already bitshifted to the right places)
MOVI $0 %r13
OR %r7 %r13
OR %r8 %r13

#Displaying hundreds and tens place on 7seg
STOR %r13 %r14
#Displaying ones place on 7seg
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


#if A triggered, change state to 1. If B triggered, change state to 4
.zero
MOV %r6 %r11

#Get LSB (corresponds to A)
ANDI $1 %r11 

#if A==1, move to next state (1)
CMPI $1 %r11
#check this branch value...
BNE $4
#move to the next state
MOVI $1 %r5
#loops back to main
MOVI .main %r10
JUC %r10

#get B - could move this to a function call but idk if it's worth it tbh
#if B triggered, change state to 4
ANDI $2 %r6
CMPI $2 %r6


BNE $2
#if b is triggered, move to state 4
MOVI $4 %r5

#loop
MOVI .main %r10
JUC %r10


#A has already been triggered
.one
#if B triggered, change state to 2
ANDI $2 %r6
CMPI $2 %r6
BNE $2
MOVI $2 %r5

#loop
MOVI .main %r10
JUC %r10


#A and B have both been triggered, in that order
.two
#if a and b reset, ie ab==00, change state to 3
#Get 2 LSB
ANDI $3 %r6
#See if it's 0
MOVI .main %r10
CMPI $0 %r6
JNE %r10
#else: (ie, ab==00)
MOVI $3 %r5

#loop
JUC %r10

.three
#load people counts from memory
LOAD %r7 %r2
LOAD %r8 %r3
LOAD %r9 %r4

#increment ones place
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
#return to state 0
MOVI $0 %r5

#loop
MOVI .main %r10
JUC %r10


#Comes here from .zero - B was triggered, but A hasn't been yet.
.four
#if A triggered, change state to 5
ANDI $1 %r6
CMPI $1 %r6
BNE $2
MOVI $5 %r5

#loop
MOVI .main %r10
JUC %r10

.five
#if a and b reset, change state to 6
ANDI $3 %r6
CMPI $0 %r6
MOVI .main %r10
JNE %r10
MOVI $6 %r5

#loop
JUC %r10

.six
#decrement counter
LOAD %r7 %r2
LOAD %r8 %r3
LOAD %r9 %r4
MOVI .threeUpdate %r10

MOVI .sixDecrementOne %r11
CMPI $0 %r7
JNE %r11
MOVI $9 %r7

MOVI .sixDecrementTen %r12
CMPI $0 %r8
JNE %r12
MOVI $9 %r8

MOVI .sixDecrementHun %r13
CMPI $0 %r9
JNE %r13
MOVI $9 %r9

JUC %r10

.sixDecrementOne
SUBI $1 %r7
JUC %r10

.sixDecrementTen
SUBI $1 %r8
JUC %r10

.sixDecrementHun
SUBI $1 %r9
JUC %r10
