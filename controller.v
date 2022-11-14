/*
-------------------------------------------------------------------------
[SUMMARY]
- The control unit is responsible for setting all the control signals
so that each instruction is executed properly for the datapath.

- With using a Moore FSM (outputs depend only on present state) for
control, each state also specifies a set of outputs that are asserted when
the machine is in that state. 

- Instruction decoder unit within the FSM will look at the opcode
information and uses that to decide how to set the other control bits of 
the data path.
-------------------------------------------------------------------------
[DOCUMENT REQUIREMENTS]
- Register-to-Register (including immediate versions) operations 
- Load and Store operations
- Conditional and Unconditional Branches/Jumps
- Jump and Link
- Instruction Decode: mux settings, register file addressing, immediate
fields (including sign extension or zero extension), and register enables
-------------------------------------------------------------------------
FETCH = retrieve instr from mem
DECODE = split retrieved instr into 2 parts: OP Code and Operand
[R-TYPE INSTRUCTIONS]
ADD
SUB
AND
OR
XOR
MOV

CMP?

[I-TYPE INSTRUCTIONS]
ADDI
SUBI
ANDI
ORI
XORI
MOVI

CMPI?

LUI
BRANCH -> cond codes

mem access instr:
LOAD
STOR

other:
CLR

[J-TYPE]
JAL
JUMP -> cond codes


SHFT
SHFTI
make macros for:
LSH
LSHI
RSH
RSHI
(alu.v SLL SLR)


cond codes
'EQ' : EQ,
'NE' : NE,
'GE' : GE,
'CS' : CS,
'CC' : CC,
'HI' : HI,
'LS' : LS,
'LO' : LO,
'HS' : HS,
'GT' : GT,
'LE' : LE,
'FS' : FS,
'FC' : FC,
'LT' : LT,
'UC' : UC
*/
module controller #(parameter SIZE = 16) (
	/* Inputs */
	input clk, reset,
	input[SIZE-1:0] instr,	// instruction bits
	//input zero,					// program counter enable -> check minimips
	input flag1, flag2,
	
	/* Outputs !! RENAME */
	output reg RFen, PSRen,			// Register File controller
	output reg[3:0] AluOp,			// ALU controller
	output reg PCm, PCen 			// PC controller
	output reg MemW1en, MemW2en,	// Memory (BRAM) controller
	output reg Movm, 					// other muxes
	output reg[1:0] A2m, RWm 		// other muxes
	); 
	
	// split instruction into opcode and opcode extend  for state encodings
	reg[3:0] op, opExt; 
	op 	= instr[15:12];
	opExt	= instr[7:4];
	
	
	/* State Name Parameters */
	// allows for changing of state encodings
	parameter FETCH	= 5'b00000;
	parameter DECODE	= 5'b00001;

	parameter ADD		= 5'b00010;
	parameter SUB		= 5'b00011;
	parameter AND		= 5'b00100;
	parameter OR		= 5'b00101;
	parameter XOR     = 5'b00110;
	parameter MOV     = 5'b00111;
	
	parameter ADDI		= 5'b01000;
	parameter SUBI    = 5'b01001;
	parameter ANDI    = 5'b01011;
	parameter ORI		= 5'b01100;
	parameter XORI    = 5'b01101;
	parameter MOVI    = 5'b01110;
	parameter LUI		= 5'b01111;

	parameter LOAD    = 5'b10000;
	parameter STOR		= 5'b10001;

	parameter BRANCH  = 5'b10010;
	parameter JUMP		= 5'b10011;
	parameter JAL     = 5'b10100;

	parameter SHFT		= 5'b10101;
	parameter SHFTI   = 5'b10110;
	parameter CLR     = 5'b10111;
	
	/* Condition Codes */
	parameter EQ		= 4'b0000;
	parameter NE		= 4'b0001;
	parameter CS		= 4'b0010;
	parameter CC		= 4'b0011;
	parameter HI		= 4'b0100;
	parameter LS		= 4'b0101;
	parameter GT		= 4'b0110;
	parameter LE		= 4'b0111;
	parameter FS		= 4'b1000;
	parameter FC		= 4'b1001;
	parameter LO		= 4'b1010;
	parameter HS		= 4'b1011;
	parameter LT		= 4'b1100;
	parameter GE		= 4'b1101;
	parameter UC		= 4'b1110;
	parameter NJ		= 4'b1111; 
	
	/* Flags */
	// for checking within the condition codes
	wire carry, flag, low, zero, neg;
	assign carry		= flag1[0];
	assign flag			= flag1[1];
	assign low			= flag2[0];
	assign zero			= flag2[1];
	assign neg			= flag2[2];
	
	/* State Register */
	reg[3:0] state, nextState;
	
	always @(posedge clk)
		if (~reset)	state <= FETCH;
		else			state <= nextState;
	
	/* Next State Combinational Logic */
	// maps the current state and the inputs to a new state
	always @(*) begin
		case(state)
			FETCH: nextState <= DECODE;
			/* Instruction Decoder (Op code) */
			DECODE:	case(op) // first decode with Op Code
							4'b0000: nextState <= ; 		// Op code: R-Type Instructions -> decode Op code extend
																	// ADD, ADDU, ADDC, MUL, SUB, SUBC, CMP, AND, OR, XOR, MO
							4'b0001: nextState <= ANDI;
							4'b0010: nextState <= ORI;
							4'b0011: nextState <= XORI;
							4'b0100: nextState <= ;			// OP Code: Memory Access, Jump and Link Instructions -> decode Op code extend
																	// STOR, LOAD, JAL
							4'b0101: nextState <= ADDI;
							//4'b0110: nextState <= ADDUI;
							//4'b0111: nextState <= ADDCI;
							4'b1000:	begin						// OP Code: Shift Instructions -> decode Op code extend
								/* PSEDUO CODE
								if (cond) nextState <= SHFT;  -> LSH, RSH, ALSH, ARSH
								else		 nextState <= SHFTI; -> LSHI, RSHI, ALSHI, ARSHI
								*/
								end
							4'b1001: nextState <= SUBI;
							//4'b1010: nextState <= SUBCI;
							//4'b1011: nextState <= CMPI;
							//4'b1100: nextState <= Bcond;
							4'b1101: nextState <= MOVI;
							//4'b1110: nextState <= MULI;
							4'b1111: nextState <= LUI;
							// !!! make CLR instr
							default: nextstate <= FETCH;	// never reaches
						endcase
			ADD:
			SUB:
			AND:
			OR:
			XOR:
			MOV:
			
			ADDI:
			SUBI: 
			ANDI:
			ORI:	
			XORI: 
			MOVI: 
			LUI:	
			
			LOAD: 
			STOR:	
			
			BRANCH:
			JUMP:	
			JAL:  
			
			SHFT:	
			SHFTI:
			CLR:  
			default: nextState <= FETCH; // never reaches
		endcase
	end

	/* Combinational Output Logic*/
	// generates the outputs from each state as datapath control signals
	always @(*) begin
		// set all outputs to zero
		RFen <= 0; PSRen <= 0;
		AluOp <= 4'b0000;
		PCm <= 0;
		MemW1en <= 0; MemW2en <= 0;
		Movm <= 0;
		A2m <= 2'b00; RWm <= 2'b00;
		// conditionally assert the outputs
		// for each state, every output/control signal needs to be explicitly assigned
		case(state)
			FETCH: begin
				//PCm 	<= 2'bxx; // increment pc (?)
				// (?) get instruction from mem/BRAM
			end
			
			DECODE: begin
				// (?)
			end
			
			LUI: begin
			// (?) current state = immd val read from instr 
			// next state = register file write port	.writeData(RFwrite)
				PCm	<= 2'00;
				RWm 	<= 2'b11;	// RWritemux: .d(luiImmd)
				RFen 	<= 1; 		// enable registerFile write
			end
			
			JAL: begin
			// next pc -> reg file
			// immd -> next pc
			// (?) set write register to r15
				PCm	<= 2'b01;	// PCmux: memAddr+1 = .a(nextPC) 
				RWm	<= 2'b01;	// RWritemux: .b(nextPC)
				RFen 	<= 1;			// enable registerFile write
			end
			
			JUMP: begin
			end
			
			BRANCH: begin
			end
			
			//MOV: datapath muxes allow src reg to be written back w/o mod to dst reg (func code bits to set alu func to pass a val thru unmodded)

			
			default: nextstate <= FETCH; // (!) CHANGE

	end
	
	// !! assign PCen = PCwrite | (PCWriteCond & zero);
endmodule 

/* For Reference (IGNORE)
--------
PYTHON ASSEMBLER:
RType = ['ADD', 'ADDU', 'ADDC', 'ADDCU', 'SUB', 'CMP', 'CMPU', 'AND', 'OR', 'XOR']
Immediates = ['ADDI', 'ADDUI', 'ADDCI', 'ADDCUI', 'SUBI', 'CMPI', 'CMPUI', 'ANDI', 'ORI', 'XORI']
Shift = ['LSH', 'RSH', 'ALSH', 'ARSH']
ImmdShift = ['LSHI', 'RSHI', 'ALSHI', 'ARSHI']
Branch = ['BEQ', 'BNE', 'BGE', 'BCS', 'BCC', 'BHI', 'BLS', 'BLO', 'BHS', 'BGT', 'BLE', 'BFS', 'BFC', 'BLT', 'BUC']
Jump = ['JEQ', 'JNE', 'JGE', 'JCS', 'JCC', 'JHI', 'JLS', 'JLO', 'JHS', 'JGT', 'JLE', 'JFS', 'JFC', 'JLT', 'JUC']
--------
MINIMIPS: 
input            clk, reset, 
input      [5:0] op,												// instr[31:26]					  
input            zero, 					  
output reg       memwrite, alusrca, memtoreg, iord,					  
output           pcen, 
output reg       regwrite, regdst, 
output reg [1:0] pcsource, alusrcb, aluop,
output reg [3:0] irwrite);					  
--------					  
DATAPATH:
input MemW1en, MemW2en, RFen, PSRen,		// enable signal (modules: bram, registerFile)
input Movm, 										// mux select (MoveMux, RWriteMux)
input[1:0] PCm, A2m, RWm, //LUIm,			// mux select (PCMux, ALU2Mux, LUIMux)
input[3:0] AluOp,									//
input[SIZE-1:0] switches,						// simulate

output[SIZE-1:0] PC, AluOut,
output[SIZE-1:0] RFwrite, RFread1, RFread2,						// register file data input and outputs				
output[SIZE-1:0] MemWrite1, MemWrite2, MemRead1, MemRead2,	// bram memory access data input and output
output[1:0] flags1out,
output[2:0] flags2out,
output[9:0] leds,															// simulate				  
*/