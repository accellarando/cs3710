`timescale 1ns / 1ps

/* DATAPATH TEST BENCH
****************************************************************************
Assessments evaluating for correctness across a single-cycle datapath, 
supporting data transfers (determinded through the controller/state machine)
required by instructions in handling operations within the processor/CPU.

Datapath Staging: Fetch -> Decode -> Execute
****************************************************************************
Reference Module(s): cpuWithDatapath.v
							statemachine.v ?
							registerfile.v ?
							PSR.v	?
							alu.v ?

------------!FIX!------------
FETCH 				>> get instr, program counter
OPCODE/INSTR		>> 
CONDITION CODES	>>

*/
module datapath_tb();
	/* Inputs */
	reg 			clk, reset;
	
//	POSSIBLE INPUTS TO CONSIDER
//	-immediate or regfile's dataout
//		+(immediate) zeroextend/signextend
//	-select output for whatever alu/shfiting/store or copy to mem
//	-set flags
//		+flag for writing to mem, store instr in reg, left shift immediate, get new instr from mem
//	-alu opcodes
//	-enable register to write
//	-program counter
//		+instr if dataout or pc
//		+pc increment, next pc is output
//	
//	-memory access for ports (outside of datapath)
//		+write data, data addr, i/o input data, enable write(?)
		
	
	
	/* Outputs */
//	POSSIBLE OUTPUTS TO CONSIDER
//	-current instruction from mem
//	-program counter
//	-current flag set
	
	/* Instantiate the Unit Under Test (UUT) */
	cpuWithDatapath uut (
	);
	

endmodule
