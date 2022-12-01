/*
----------------------------------------------------------------------------
[SUMMARY]
- The control unit is responsible for setting all the control signals
so that each instruction is executed properly for the datapath.

- With using a Moore FSM (outputs depend only on present state) for
control, each state also specifies a set of outputs that are asserted when
the machine is in that state. 

- Instruction decoder unit within the FSM will look at the opcode
information and uses that to decide how to set the other control bits of 
the data path.
----------------------------------------------------------------------------
[DOCUMENT REQUIREMENTS]
- Register-to-Register (including immediate versions) operations 
- Load and Store operations
- Conditional and Unconditional Branches/Jumps
- Jump and Link
- Instruction Decode: mux settings, register file addressing, immediate
fields (including sign extension or zero extension), and register enables
---------------------------------------------------------------------------
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
module controller (
	/* Inputs */
	input clk, reset,
	input[15:0] instr,	// instruction bits
	//input zero,					// program counter enable -> check minimips
	input[1:0] flag1, 
	input[2:0] flag2,
	
	/* Outputs !! RENAME */
	output reg RFen, PSRen,	INSTRen,		// Register File controller
	output reg[3:0] AluOp,					// ALU controller
	output reg PCen, setZNL,				// PC controller
	output reg[1:0] PCm, 					// PC controller
	output reg MemW1en, MemW2en,			// Memory (BRAM) controller
	output reg Movm, A1m, MAm,					// other muxes
	output reg[1:0] A2m, RWm 				// other muxes
	); 
	
	// split instruction into opcode and opcode extend for state encodings
	wire[3:0] op, opExt; 
	assign op		= instr[15:12];
	assign opExt	= instr[7:4];
	
	
	/* State Name Parameters */
	// allows for changing of state encodings
	parameter SIZE = 16;
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
	parameter JWB		= 4'd11;
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
	parameter NOT		= 4'b0100;
	
	parameter LSH		= 4'b1000;
	parameter E_LSHI	= 4'b000x;
	
	parameter LUI		= 4'b1111;
	
	parameter LJS		= 4'b0100;
	parameter E_LOAD	= 4'b0000;
	parameter E_STORE	= 4'b0100;
	
	parameter B			= 4'b1100;
	
	//parameter J			= 4'b0100;
	parameter E_J		= 4'b1100;
	parameter E_JAL		= 4'b1000;
	
	/* AluOp parameters */
	parameter ALU_AND			=	4'b0000;
	parameter ALU_OR			=	4'b0001;
	parameter ALU_XOR 		= 	4'b0010;
	parameter ALU_ADD 		= 	4'b0011;
	parameter ALU_SUB			=	4'b0100;
	parameter ALU_NOT 		= 	4'b0101;
	parameter ALU_SLL 		= 	4'b0110; 	// shift Left logical
	parameter ALU_SRL 		= 	4'b0111; 	// shift right logical
	
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
	wire carry, overFlow, low, zero, neg;
	assign carry		= flag1[0];
	assign overFlow		= flag1[1];
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
					//L_S:	nextState <= opExt[2] ? SEX : LEX;
					LJS: case(opExt)
						E_LOAD: nextState <= LEX;
						E_STORE: nextState <= SEX;
						default: nextState <= JEX;
					endcase
						
					B:		nextState <= BEX;
					//J:		nextState <= JEX;
					default: nextState <= FETCH; //should never reach
				endcase
			REX:	nextState <= RWB;
			IEX:	nextState <= IWB;
			LEX:	nextState <= LWB;
			JEX:	nextState <= JWB;
			SEX:	nextState <= SWB;
			BEX:	nextState <= BWB;

			/* not necessary
			RWB:	nextState <= FETCH;
			IWB:	nextState <= FETCH;
			LWB:	nextState <= FETCH;
			JWB:	nextState <= FETCH;
			SWB:	nextState <= FETCH;
			BWB:	nextState <= FETCH;
			*/
			default: nextState <= FETCH;
		endcase
	end

	/* Combinational Output Logic*/
	// generates the outputs from each state as datapath control signals
	always @(*) begin
		// set all outputs to zero
		INSTRen <= 1'b0;
		MAm <= 1'b1;
		RFen <= 1'b0; PSRen <= 1'b0;
		AluOp <= 4'b0000; 
		setZNL <= 1'b0;
		PCm <= 2'b0; //1'b0;
		PCen <= 1'b0;
		MemW1en <= 1'b0; MemW2en <= 1'b0;
		Movm <= 1'b0;
		A1m <= 1'b0;
		A2m <= 2'b00; RWm <= 2'b00;
		// conditionally assert the outputs
		// for each state, every output/control signal needs to be explicitly assigned
		case(state)
			FETCH: begin
				INSTRen <= 1'b1;
				MAm <= 1'b0;
			end
			DECODE: begin
				MAm <= 1'b0;
				//? 
			end
			REX: begin
				RFen <= 1'b1;
				//PCen <= 1'b1;
				PSRen <= 1'b1;
				//figure out aluop
				//it lives in the extended opcode
				case(opExt)
					AND:  AluOp <= ALU_AND;
					OR:   AluOp <= ALU_OR;
					XOR:  AluOp <= ALU_XOR;
					ADD:  AluOp <= ALU_ADD;
					SUB:  AluOp <= ALU_SUB;
					NOT:  AluOp <= ALU_NOT;
					//shifting...
					LSH: AluOp <= ALU_SLL; //?
					CMP: begin
						AluOp <= ALU_SUB;
						setZNL <= 1'b1;
					end
					default: AluOp <= ALU_AND;
				endcase

				//set rwrite mux to movm
				RWm <= 2'd2;

				//set alu2mux to read2
				A2m <= 2'b0;
				
				//set alu1mux to read1
				A1m <= 1'b0;
				
				//get PC ready
				PCm <= 2'b0;


				//set mov mux
				Movm <= (opExt == MOV) ? 1'b0 : 1'b1;
			end
			IEX: begin
				RFen <= 1'b1;
				//PCen <= 1'b1;
				case(op)
					AND:  AluOp <= ALU_AND;
					OR:   AluOp <= ALU_OR;
					XOR:  AluOp <= ALU_XOR;
					ADD:  AluOp <= ALU_ADD;
					SUB:  AluOp <= ALU_SUB;
					NOT:  AluOp <= ALU_NOT;
					LSH:  AluOp <= ALU_SLL;
					CMP: begin
						AluOp <= ALU_SUB;
						setZNL <= 1'b1;
					end
					default: AluOp <= ALU_AND;
				endcase

				//set rwrite mux to movm out or luiImmd
				RWm <= (op == LUI) ? 2'd3 : 2'd2;

				//set alu2mux to immediate
				A2m <= 2'd2;

				//set alu1mux to read1
				A1m <= 1'b0;

				//prepare the pc
				PCm <= 2'b0;

				//set mov mux
				Movm <= (op == MOV) ? 1'b0: 1'b1;
			end
			LEX: begin
				RWm <= 2'b0;
				PCm <= 2'b0;
			end
			SEX: begin
				MemW2en <= 1'b1;
			end
			JEX: begin
				//check flags, decide to do jump or not
				case(instr[11:8])
					EQ: PCm <= zero ? 2'b1 : 2'b0;
					NE: PCm <= ~zero ? 2'b1 : 2'b0;
					GE: PCm <= (neg | zero) ? 2'b1 : 2'b0;
					CS: PCm <= carry ? 2'b1 : 2'b0;
					CC: PCm <= ~carry ? 2'b1 : 2'b0;
					HI: PCm <= low ? 2'b1 : 2'b0;
					LS: PCm <= ~low ? 2'b1 : 2'b0;
					LO: PCm <= (~low & ~zero) ? 2'b1 : 2'b0;
					HS: PCm <= (low & zero) ? 2'b1 : 2'b0;
					GT: PCm <= neg ? 2'b1 : 2'b0;
					LE: PCm <= ~neg ? 2'b1 : 2'b0;
					FS: PCm <= overFlow ? 2'b1 : 2'b0;
					FC: PCm <= ~overFlow ? 2'b1 : 2'b0;
					LT: PCm <= (~neg & ~zero) ? 2'b1 : 2'b0;
					UC: PCm <= 2'b1;
					default: PCm <= 2'b0; //corresponds to NJ
				endcase
				if(opExt == E_JAL) begin
					RWm <= 2'b1;
					RFen <= 1'b1;
				end
				//PCen <= 1'b1;
			end
			BEX: begin
				//PCen <= 1'b1;
				case(instr[11:8])
					EQ: PCm <= zero ? 2'd2 : 2'b0;
					NE: PCm <= ~zero ? 2'd2 : 2'b0;
					GE: PCm <= (neg | zero) ? 2'd2 : 2'b0;
					CS: PCm <= carry ? 2'd2 : 2'b0;
					CC: PCm <= ~carry ? 2'd2 : 2'b0;
					HI: PCm <= low ? 2'd2 : 2'b0;
					LS: PCm <= ~low ? 2'd2 : 2'b0;
					LO: PCm <= (~low & ~zero) ? 2'd2 : 2'b0;
					HS: PCm <= (low & zero) ? 2'd2 : 2'b0;
					GT: PCm <= neg ? 2'd2 : 2'b0;
					LE: PCm <= ~neg ? 2'd2 : 2'b0;
					FS: PCm <= overFlow ? 2'd2 : 2'b0;
					FC: PCm <= ~overFlow ? 2'd2 : 2'b0;
					LT: PCm <= (~neg & ~zero) ? 2'd2 : 2'b0;
					UC: PCm <= 2'd2;
					default: PCm <= 2'd0; //corresponds to NJ
				endcase
				//set a1 to pc
				A1m <= 1'b1;
				//set a2 to imm
				A2m <= 2'd2;
				//set aluop to add
				AluOp <= ALU_ADD;
			end
			RWB: begin
				RFen <= 1'b1;
				PCen <= 1'b1;
				PSRen <= 1'b1;
				MAm <= 1'b0;
				case(opExt)
					AND:  AluOp <= ALU_AND;
					OR:   AluOp <= ALU_OR;
					XOR:  AluOp <= ALU_XOR;
					ADD:  AluOp <= ALU_ADD;
					SUB:  AluOp <= ALU_SUB;
					NOT:  AluOp <= ALU_NOT;
					CMP: begin
						AluOp <= ALU_SUB;
						setZNL <= 1'b1;
					end
					//shifting...
					LSH: AluOp <= ALU_SLL; //?
					default: AluOp <= ALU_AND;
				endcase

				//set rwrite mux to movm
				RWm <= 2'd2;

				//set alu2mux to read2
				A2m <= 2'b0;
				
				//set alu1mux to read1
				A1m <= 1'b0;
				
				//get PC ready
				PCm <= 2'b0;
				//PCen <= 1'b1;

				//set mov mux
				Movm <= (opExt == MOV) ? 1'b0 : 1'b1;
			end
			IWB: begin
MAm <= 1'b0;
				RFen <= 1'b1;
				PCen <= 1'b1;

				case(op)
					AND:  AluOp <= ALU_AND;
					OR:   AluOp <= ALU_OR;
					XOR:  AluOp <= ALU_XOR;
					ADD:  AluOp <= ALU_ADD;
					SUB:  AluOp <= ALU_SUB;
					NOT:  AluOp <= ALU_NOT;
					LSH:  AluOp <= ALU_SLL;
					CMP: begin
						AluOp <= ALU_SUB;
						setZNL <= 1'b1;
					end
					default: AluOp <= ALU_AND;
				endcase

				//set rwrite mux to movm out or luiImmd
				RWm <= (op == LUI) ? 2'd3 : 2'd2;

				//set alu2mux to immediate
				A2m <= 2'd2;

				//set alu1mux to read1
				A1m <= 1'b0;

				//prepare the pc
				PCm <= 2'b0;
				PCen <= 1'b1;

				//set mov mux
				Movm <= (op == MOV) ? 1'b0: 1'b1;
			end
			LWB: begin
				RFen <= 1'b1;
				PCen <= 1'b1;
				RWm <= 2'b1;
				PCm <= 2'b0;
				MAm <= 1'b0;
			end
			SWB: begin
				MemW2en <= 1'b1;
				PCen <= 1'b1;
				MAm <= 1'b0;
			end

			JWB: begin
				//check flags, decide to do jump or not
				case(instr[11:8])
					EQ: PCm <= zero ? 2'b1 : 2'b0;
					NE: PCm <= ~zero ? 2'b1 : 2'b0;
					GE: PCm <= (neg | zero) ? 2'b1 : 2'b0;
					CS: PCm <= carry ? 2'b1 : 2'b0;
					CC: PCm <= ~carry ? 2'b1 : 2'b0;
					HI: PCm <= low ? 2'b1 : 2'b0;
					LS: PCm <= ~low ? 2'b1 : 2'b0;
					LO: PCm <= (~low & ~zero) ? 2'b1 : 2'b0;
					HS: PCm <= (low & zero) ? 2'b1 : 2'b0;
					GT: PCm <= neg ? 2'b1 : 2'b0;
					LE: PCm <= ~neg ? 2'b1 : 2'b0;
					FS: PCm <= overFlow ? 2'b1 : 2'b0;
					FC: PCm <= ~overFlow ? 2'b1 : 2'b0;
					LT: PCm <= (~neg & ~zero) ? 2'b1 : 2'b0;
					UC: PCm <= 2'b1;
					default: PCm <= 2'b0; //corresponds to NJ
				endcase
				if(opExt == E_JAL) begin
					RWm <= 2'b1;
				end
				PCen <= 1'b1;
				MAm <= 1'b0;
				if(opExt == E_JAL)
					RFen <= 1'b1;
			end
			BWB: begin
				PCen <= 1'b1;
				MAm <= 1'b0;
				case(instr[11:8])
					EQ: PCm <= zero ? 2'd2 : 2'b0;
					NE: PCm <= ~zero ? 2'd2 : 2'b0;
					GE: PCm <= (neg | zero) ? 2'd2 : 2'b0;
					CS: PCm <= carry ? 2'd2 : 2'b0;
					CC: PCm <= ~carry ? 2'd2 : 2'b0;
					HI: PCm <= low ? 2'd2 : 2'b0;
					LS: PCm <= ~low ? 2'd2 : 2'b0;
					LO: PCm <= (~low & ~zero) ? 2'd2 : 2'b0;
					HS: PCm <= (low & zero) ? 2'd2 : 2'b0;
					GT: PCm <= neg ? 2'd2 : 2'b0;
					LE: PCm <= ~neg ? 2'd2 : 2'b0;
					FS: PCm <= overFlow ? 2'd2 : 2'b0;
					FC: PCm <= ~overFlow ? 2'd2 : 2'b0;
					LT: PCm <= (~neg & ~zero) ? 2'd2 : 2'b0;
					UC: PCm <= 2'd2;
					default: PCm <= 2'd0; //corresponds to NJ
				endcase
				//set a1 to pc
				A1m <= 1'b1;
				//set a2 to imm
				A2m <= 2'd2;
				//set aluop to add
				AluOp <= ALU_ADD;

			end
			default: PCen <= 1'b0; //idk lol
		endcase
	end
	
endmodule 

