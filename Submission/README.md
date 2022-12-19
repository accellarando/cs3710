#ECE 3710: Computer Design Lab Final Project - Associated Verilog and supporting files

This archive contains all associated files with the ECE 3710 final project by Dana Escandor, Blandine Tchetche, Ella Moss, and Jack Marshall.

All files are described below; they have also been commented.

## Assembler.py
This is the Python file used to convert assembly programs into binary, which can then be loaded into the ram.dat file.

## AssemblyFiles
These files contain assembly tests, as well as the final program.

### exampleProgram.asm
Demonstrates basic CPU behavior, including loading data, addition, storing data back into memory, and conditional branches.

### finalProgram.asm
The final program used for the bidirectional visitor counter. Note that this contains code for the reset button at the beginning of the main loop, which was not demonstrated due to a bug in how we were loading and storing values.

Refer to the final report for more details on how this program works.

### fullTest.asm
Tests for each type of instruction in the ISA, with the exception of branch and jump instructions (see testJB).

### testGlyphsWithSwitches.asm
Reads data from switches, then displays that data on the VGA monitor.

### testJB.asm
Simple test of branch and jump instructions.

## Verilog
This contains all (commented) Verilog and supporting files for the project.

### PSR\_reg.v
This contains code for the Program State Register, which holds five flags: (C)arry, over(F)low, (Z)ero, (N)egative, (L)ess-than.

### alu.v
This contains code for the ALU. Note that to support the CMP instruction, you must set aluOp to SUB (4'b0100) and assert the setZNL signal, then ignore the output. Also, our CPU does not use the SRL instruction, instead using the SLL instruction with a negative shift value. 

#### aluOp parameters
| Name       | Value      |
|------------|------------|
| AND        | 4'b0000    |
| OR         | 4'b0001    |
| XOR        | 4'b0010    |
| ADD        | 4'b0011    |
| SUB        | 4'b0100    |
| NOT        | 4'b0101    |
| SLL        | 4'b0110    |
| SRL        | 4'b0111    |

### bitGen.v
This file contains the VGA state machine and RGB output code.

### controller.v
The control unit is responsible for setting all the control signals so that each instruction is executed properly for the datapath.

#### Opcodes
| Name       | Value      |
|------------|------------|
| EXT0       | 4'b0000    |
| ADD        | 4'b0101    |
| SUB        | 4'b1001    |
| CMP        | 4'b1011    |
| AND        | 4'b0001    |
| OR         | 4'b0010    |
| XOR        | 4'b0011    |
| MOV        | 4'b1101    |
| LSH        | 4'b1000    |
| E\_LSH      | 4'b0100    |
| E\_LSHI     | 4'b000x    |
| LUI        | 4'b1111    |
| LJS        | 4'b0100    |
| E\_LOAD     | 4'b0000    |
| E\_STORE    | 4'b0100    |
| B          | 4'b1100    |
| E\_J        | 4'b1100    |
| E\_JAL      | 4'b1000    |

#### Condition Codes
| Name       | Value      |
|------------|------------|
| EQ         | 4'b0000    |
| NE         | 4'b0001    |
| CS         | 4'b0010    |
| CC         | 4'b0011    |
| HI         | 4'b0100    |
| LS         | 4'b0101    |
| GT         | 4'b0110    |
| LE         | 4'b0111    |
| FS         | 4'b1000    |
| FC         | 4'b1001    |
| LO         | 4'b1010    |
| HS         | 4'b1011    |
| LT         | 4'b1100    |
| GE         | 4'b1101    |
| UC         | 4'b1110    |
| NJ         | 4'b1111    |

### cpu.qpf
This is the Quartus Prime Project file that contains our project.

### cpu.qsf
Associated settings file for Quartus that contains pin assignments, et cetera.

### datapath.v
This contains code for the main processor datapath.

### en\_register.v
Register with an enable signal.

### final\_cpu.v
Top-level module for the project - ties it all together.

### hexTo7Seg.v
Provided file to convert hexadecimal values into 7-segment output.

### laser\_tb.v
A rudimentary testbench to simulate different laser states by inspecting waveform outputs.

### mux\*.v
Muxes with different numbers of inputs.

### ram.dat
Binary file to initialize the RAM. Note that the program and glyphs have been loaded already.

### reg.dat
Binary file to initialize the register file (all registers are initialized to 0).

### register.v
Simple register with a reset signal.

### registerFile.v
Register file for the CPU. Note it has two read ports but only one write port - writes happen to dstAddr.

### vgaController.v
Manages timing and signal generation for VGA output. See bitGen.v for the actual RGB values.
