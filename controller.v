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
	input[1:0] flag1, 
	input[2:0] flag2,
	
	/* Outputs !! RENAME */
	output reg RFen, PSRen,			// Register File controller
	output reg[3:0] AluOp,			// ALU controller
	output reg PCm, PCen, 			// PC controller
	output reg MemW1en, MemW2en,	// Memory (BRAM) controller
	output reg Movm, 					// other muxes
	output reg[1:0] A2m, RWm 		// other muxes
	); 
	
	// split instruction into opcode and opcode extend for state encodings
	reg[3:0] op, opExt; 
	assign op		= instr[15:12];
	assign opExt	= instr[7:4];
	
	
	/* State Name Parameters */
	// allows for changing of state encodings
	parameter FETCH		= 4'd0;
	parameter DECODE	= 4'd1;
	parameter REX		= 4'd2;
	parameter IEX		= 4'd3;
	parameter LEX		= 4'd4;
	parameter JEX		= 4'd5;
	parameter SEX		= 4'd6;
	parameter BEX		= 4'd7;
	parameter RWB		= 4'd8;
	parameter IWB		= 4'd9;
	parameter LWB		= 4'd10;
	parameter JWB		= 4'd12;
	parameter SWB		= 4'd12;
	parameter BWB		= 4'd13;

	/* Instruction opcode parameters */
	parameter EXT0		= 4'b0000;
	parameter ADD		= 4'b0101;
	parameter SUB		= 4'b1001;
	parameter CMP		= 4'b1011;
	parameter AND		= 4'b0001;
	parameter OR 		= 4'b0010;
	parameter XOR		= 4'b0011;
	parameter MOV		= 4'b1101;
	
	parameter LSH		= 4'b1000;
	parameter E_LSHI	= 4'b000x;
	
	parameter LUI		= 4'b1111;
	
	parameter L_S		= 4'b0100;
	parameter E_LOAD	= 4'b0000;
	parameter E_STORE	= 4'b0100;
	
	parameter B			= 4'b1100;
	
	parameter J			= 4'b0100;
	parameter E_J		= 4'b1100;
	parameter E_JAL		= 4'b1000;
	
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
					EXT0:	nextState <= REX;
					ADD:	nextState <= IEX;
					SUB:	nextState <= IEX;
					CMP:	nextState <= IEX;
					AND:	nextState <= IEX;
					OR:		nextState <= IEX;
					XOR:	nextState <= IEX;
					MOV:	nextState <= IEX;

					LSH:	nextState <= opExt[2] ? REX : IEX;

					LUI:	nextState <= IEX;
					L_S:	nextState <= opExt[2] ? SEX : LEX;
					B:		nextState <= BEX;
					J:		nextState <= JEX;
					default: nextState <= FETCH; //should never reach
				endcase
			REX:	nextState <= RWB;
			IEX:	nextState <= IWB;
			LEX:	nextState <= LWB;
			JEX:	nextState <= JWB;
			SEX:	nextState <= SWB;
			BEX:	nextState <= BWB;

			RWB:	nextState <= FETCH;
			IWB:	nextState <= FETCH;
			LWB:	nextState <= FETCH;
			JWB:	nextState <= FETCH;
			SWB:	nextState <= FETCH;
			BWB:	nextState <= FETCH;
			default: nextState <= FETCH;
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
			/*
			LUI: begin
			// (?) current state = immd val read from instr 
			// next state = register file write port	.writeData(RFwrite)
				PCm	<= 2'b00;
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
			*/
		   FETCH: 
			
		   JUMP: begin
		   end

		   BRANCH: begin
		   end

			   //MOV: datapath muxes allow src reg to be written back w/o mod to dst reg (func code bits to set alu func to pass a val thru unmodded)

			default: ;

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
