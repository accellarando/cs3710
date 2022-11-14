/* For Reference (IGNORE)

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



/*
--------------------------------------------------------------------
[SUMMARY]
- The control unit is responsible for setting all the control signals
so that each instruction is executed properly for the datapath.

- With using a FSM for control, each state also
specifies a set of outputs that are asserted when the machine is in 
that state. 

- A FSM can be implemented with a temporary register that holds
the current state and a block of combinational logic that determines both the
data-path signals to be asserted and the next state.
--------------------------------------------------------------------
[DOCUMENT REQUIREMENTS]
- Register-to-Register (including immediate versions) operations
- Load and Store operations
- Conditional and Unconditional Branches/Jumps
- Jump and Link

FETCH = retrieve instruction
DECODE = looks at op code once instruction from fetch is updated
JAL		-> store next instr, write to reg, jump, write to pc
JUMP		-> cond, write to pc = go to target addr
BRANCH	-> cond, write to pc
--------------------------------------------------------------------

[R-TYPE INSTRUCTIONS]
[I-TYPE INSTRUCTIONS]
[SHIFT]
labels = {}
jpoint_instrs = {}
RType = ['ADD', 'ADDU', 'ADDC', 'ADDCU', 'SUB', 'CMP', 'CMPU', 'AND', 'OR', 'XOR']
Immediates = ['ADDI', 'ADDUI', 'ADDCI', 'ADDCUI', 'SUBI', 'CMPI', 'CMPUI', 'ANDI', 'ORI', 'XORI']
Shift = ['LSH', 'RSH', 'ALSH', 'ARSH']
ImmdShift = ['LSHI', 'RSHI', 'ALSHI', 'ARSHI']
Branch = ['BEQ', 'BNE', 'BGE', 'BCS', 'BCC', 'BHI', 'BLS', 'BLO', 'BHS', 'BGT', 'BLE', 'BFS', 'BFC', 'BLT', 'BUC']
Jump = ['JEQ', 'JNE', 'JGE', 'JCS', 'JCC', 'JHI', 'JLS', 'JLO', 'JHS', 'JGT', 'JLE', 'JFS', 'JFC', 'JLT', 'JUC']
REGISTERS = ['%r0', '%r1', '%r2', '%r3', '%r4', '%r5', '%r6', '%r7', '%r8', '%r9', '%r10', '%r11', '%r12', '%r13', '%r14', '%r15']

*/
module controller #(parameter SIZE = 16) (
	/* Inputs */
	input clk, reset,
	input[SIZE-1:0] instr, // instruction bits
	//input[3:0] op,	 	(?) operation bits -> instr[31:26]
	//input zero, 			(?) program counter enable (MINIMIPS)
	
	/* Outputs (from datapath) */
	output reg RFen, PSRen,			// Register File controller
	output reg[3:0] AluOp,			// ALU controller
	output reg PCm, 					// PC controller
	output reg MemW1en, MemW2en,	// Memory (BRAM) controller
	output reg Movm, 					// other muxes
	output reg[1:0] A2m, RWm 		// other muxes
	
//	input nextStateButton, reset,
//	output reg [15:0] addr1, addr2,
//	output reg we1, we2,
//	output reg [15:0] dataOut1, dataOut2
	); 
	
	reg[3:0] op;
	op = instr[15:12];
	
	/* State Name Parameters */
	// allows for changing of state encodings
	parameter FETCH	= 4'b0000;
	parameter DECODE	= 4'b0001;
	
	// from ALU.v
	parameter AND		=	4'b0000;
	parameter OR		=	4'b0001;
	parameter XOR 		= 	4'b0010;
	parameter ADD 		= 	4'b0011;
	parameter SUB		=	4'b0100;
	parameter NOT 		= 	4'b0101;
	parameter SLL 		= 	4'b0110;
	parameter SRL 		= 	4'b0111;
	
	// to implement
	parameter LUI		= 4'b;
	parameter JAL		= 4'b;  
	parameter JUMP		= 4'b;
	parameter BRANCH	= 4'b; // conditional branch
	parameter CLR		= 4'b;
	
	/* Instruction Types & Condition Checks */
	parameter 
	
	/* (?) Flags */
	// C = carry 
	// L = low
	// F = flag
	// Z = comparison (equal)
	// N = negative 
	
	/* State Register */
	reg[3:0] state, nextState;
	
	always @(posedge clk)
		if(~reset)	state <= FETCH;
		else			state <= nextState;
	
	/* Next State Generation Combinational Logic */
	// maps the current state and the inputs to a new state
	always @(*) begin
		case(state)
			FETCH: nextState <= DECODE;
			
			/* Instruction Decoder */
			// mux settings, register file addressing,
			// immediate fields (including sign extension or zero extension),
			// and register enables.
			DECODE:	case(op)
							TEST: nextState <= OPERATION;
							
							default: nextstate <= FETCH; // never reaches
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
				RWm 	<= 2'b11;	// RWritemux: .d(luiImmd)
				RFen 	<= 1; 		// enable registerFile write
			end
			
			JAL: begin
			// next pc -> reg file
			// immd -> next pc
			// (?) set write register to r15
				PCm	<= 2'b00;	// PCmux: memAddr+1 = .a(nextPC) 
				RWm	<= 2'b01;	// RWritemux: .b(nextPC)
				RFen 	<= 1;			// enable registerFile write
			end
			
			JUMP: begin
			end
			
			BRANCH: begin
			end
			
			default: nextstate <= FETCH; // (!) CHANGE

	end
endmodule 
