// TEMP FILE FOR HOW TO POSSIBLY ORGANIZE DATAPATH

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
		
//	POSSIBLE OUTPUTS TO CONSIDER
//	-current instruction from mem
//	-program counter
//	-current flag set

module datapath #(parameter SIZE = 16) (
	/* INPUTS* */
	input
	
	/* OUTPUTS */
	output reg[SIZE-1:0] PC
	);
	
	/* INSTANTIATE MODULES */
	registerFile regfile (
		.clk(clk),
		.reset(reset),
		.writeEn(writeEn),
		.writeData(writeData),
		.srcAddr(srcAddr),
		.dstAddr(dstAddr),
		.readData1(readData1),
		.readData2(readData2)
	);
	
	/* PROGRAM COUNTER */
//	PC as a loadable counter: 
//	-Load the counter for the update and displacement functions (muxes) and count the counter for the increment-the-pc function
//	-[advantage] May not have to use the complete datapath for each PC increment

//	Datapath PC operations:
//	-PC needs to be incremented by one word of 16-bits (the normal case)
//	-Added to a sign-extended displacement (for branches)
//	-Loaded from a register (for jumps)
//	-JAL instr -> PC needs a path to regfile so that PC+1 (addr of the next instr following the JAL) can be stored in the link register, no reads

// Consider possible PC issues:
//	-[un/signed arithmetic] Unsigned PC that is operated on by a two's complement ALU
//		+unsigned PC can directly addr 0 - 64k locations (each location is a 16-bit word) == 64k words in the addr space w/ each word being 16-bits
//		+(subtraction) unsigned # w/ MSB of 1 binary added to a signed # w/ MSB of 1 -> overflow
	
//	[mini mips] flopenr    #(WIDTH)  pcreg(clk, reset, pcen, nextpc, pc);


	// Immediate zero-extend or sign-extend
	

endmodule
