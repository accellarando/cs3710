module cpu #(parameter SIZE=16, NUMREGS=16)
	(input clk, reset,
		input[SIZE-1:0] memdata, srcAddr, dstAddr, imm,
		output memwrite,
		output[SIZE-1:0] adr,
		output[SIZE-1:0] wd,
		output[SIZE-1:0] condsOut);
		
	wire[SIZE-1:0] pcIn, pcOut, srcOut, dstOut, immOut, 
		d1, d2, aluIn1, aluIn2, aluOut, shifterOut, aluOutShifted, aluFinal;
	wire ctrlAlu1, ctrlAlu2, cIn, en; // changed carryIn to cIn, added en, removed "carryOut"
	
	// changed [4:0] conds to 2 groups: [1:0] cond_group1, [2:0] cond_group2
	wire[1:0] cond_group1;
	wire[2:0] cond_group2; 
	
	wire[3:0] aluOp;
	
	register #(SIZE) pcReg(reset, clk, pcIn, pcOut);
	register #(SIZE) srcReg(reset, clk, srcAddr, srcOut);
	register #(SIZE) dstReg(reset, clk, dstAddr, dstOut);
	register #(SIZE) immReg(reset, clk, imm, immOut);
	
	registerFile #(SIZE, NUMREGS) rf(clk, reset, pcIn, aluOut, srcOut, dstOut, d1, d2);
	
	mux2 #(SIZE) alu1(ctrlAlu1, pcOut, d1, aluIn1);
	mux2 #(SIZE) alu2(ctrlAlu2, d2, immOut, aluIn2);
	
	ALU #(SIZE) alu(aluOp, aluIn1, aluIn2, cIn, aluOut, cond_group1, cond_group2); //updated inputs/outputs
	
	PSR_reg PSRreg(reset, clk, en, cond_group1, cond_group2, final_group1, final_group2); // added special reg for PSR (enable signal)
	
	register #(SIZE) outReg(reset, clk, aluOut, aluFinal); 
	
	
endmodule  
