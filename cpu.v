module cpu #(parameter SIZE=16, NUMREGS=16)
	(input clk, reset,
		input[SIZE-1:0] memdata, srcAddr, dstAddr, imm,
		output memwrite,
		output[SIZE-1:0] adr,
		output[SIZE-1:0] wd,
		output[SIZE-1:0] condsOut);
		
	wire[SIZE-1:0] pcIn, pcOut, srcOut, dstOut, immOut, 
		d1, d2, aluIn1, aluIn2, aluOut, shifterOut, aluOutShifted, aluFinal;
	wire ctrlAlu1, ctrlAlu2, carryIn, carryOut;
	wire[4:0] conds;
	
	wire[3:0] aluOp;
	
	register #(SIZE) pcReg(reset, clk, pcIn, pcOut);
	register #(SIZE) srcReg(reset, clk, srcAddr, srcOut);
	register #(SIZE) dstReg(reset, clk, dstAddr, dstOut);
	register #(SIZE) immReg(reset, clk, imm, immOut);
	
	registerFile #(SIZE, NUMREGS) rf(clk, reset, pcIn, aluOut, srcOut, dstOut, d1, d2);
	
	mux2 #(SIZE) alu1(ctrlAlu1, pcOut, d1, aluIn1);
	mux2 #(SIZE) alu2(ctrlAlu2, d2, immOut, aluIn2);
	
	ALU #(SIZE) alu(aluIn1, aluIn2, aluOp, carryIn, aluOut, conds, carryOut);
	
	register #(SIZE) psrReg(clk, reset, conds, condsOut);
	
	register #(SIZE) outReg(reset, clk, aluOut, aluFinal); 
	
	
endmodule 