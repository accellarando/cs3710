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

		
	
	
	/* Outputs */
//	POSSIBLE OUTPUTS TO CONSIDER
//	-current instruction from mem
//	-program counter
//	-current flag set
	
	/* Instantiate the Unit Under Test (UUT) */
	cpuWithDatapath uut (
	);
	

endmodule
