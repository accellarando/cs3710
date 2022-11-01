`timescale 1ns / 1ps

/* DATAPATH TEST BENCH
****************************************************************************
Assessments evaluating for correctness across a single-cycle datapath, 
supporting data transfers (determinded through the controller/state machine)
required by instructions in handling operations within the processor/CPU.

Datapath Staging: Fetch -> Decode -> Execute
****************************************************************************
Reference Module(s):	cpuWithDatapath.v
							statemachine.v (?)
							registerfile.v (?)
							PSR.v	(?)
							alu.v (?)

---------ALU OP-----------
parameter AND		=	4'b0000;
parameter OR		=	4'b0001;
parameter XOR 		= 	4'b0010;
parameter ADD 		= 	4'b0011;
parameter SUB		=	4'b0100;
parameter NOT 		= 	4'b0101;
parameter SLL 		= 	4'b0110;
parameter SRL 		= 	4'b0111;

*/
module datapath_tb();
	reg 			clk, reset;
	
	/* Temporary controller FSM: control signals*/
	reg MemW1en, MemW2en, RFen, PSRen,		// enable signals (modules: bram, registerFile)
	input Movm, RWm,									// mux select signals (MoveMux, RWriteMux)
	input[1:0] PCm, A2m, LUIm,						// mux select signals (PCMux, ALU2Mux, LUIMux)
	input[3:0] AluOp,
	input[SIZE-1:0] switches,						// simulate on board
	
	output[SIZE-1:0] AluOut,
	output[SIZE-1:0] RFwrite, RFread1, RFread2,						// register file data input and outputs
	output[SIZE-1:0] MemWrite1, MemWrite2, MemRead1, MemRead2,	// bram memory access data input and output  
	output[1:0] flags1out,
	output[2:0] flags2out,
	output[9:0] leds,															// simulate on board
	

		
	
	
	/* Outputs */
//	POSSIBLE OUTPUTS TO CONSIDER
//	-current instruction from mem
//	-program counter
//	-current flag set
	
	/* Instantiate the Unit Under Test (UUT) */
	cpuWithDatapath uut (
	);
	

endmodule
