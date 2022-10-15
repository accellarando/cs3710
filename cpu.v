module cpu #(parameter SIZE=16, NUMREGS=16)
	(input clk, reset,
		input[SIZE-1:0] memdata, srcAddr, dstAddr, imm,
		output memwrite,
		output[SIZE-1:0] adr,
		output[SIZE-1:0] wd);
		
	wire[SIZE-1:0] pcIn, pcOut, srcOut, dstOut, immOut, 
		d1, d2, aluIn1, aluIn2, aluOut, shifterOut, aluOutShifted, aluFinal;
	wire ctrlAlu1, ctrlAlu2;
	wire[3:0] aluOp;
	
	register #(SIZE) pcReg(reset, clk, pcIn, pcOut);
	register #(SIZE) srcReg(reset, clk, srcAddr, srcOut);
	register #(SIZE) dstReg(reset, clk, dstAddr, dstOut);
	register #(SIZE) immReg(reset, clk, imm, immOut);
	
	registerFile #(SIZE, NUMREGS) rf(clk, reset, pcIn, srcOut, dstOut, d1, d2);
	
	mux2 #(SIZE) alu1(ctrlAlu1, pcOut, d1, aluIn1);
	mux2 #(SIZE) alu2(ctrlAlu2, d2, immOut, aluIn2);
	
	ALU #(SIZE) alu(clk, reset, aluIn1, aluIn2, aluOp, aluOut);
	shifter #(SIZE) shift(clk, reset, aluIn1, shifterOut, shiftBits);
	mux2 #(SIZE) shiftMux(ctrlShifter, shiftBits, aluOut, aluOutShifted);
	
	register #(SIZE) outReg(reset, clk, aluOutShifted, aluFinal); 
	
	
endmodule 