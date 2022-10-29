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

module datapath_TEMP #(parameter SIZE = 16) (
	);