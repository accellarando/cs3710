module cpu #(parameter SIZE=16, NUMREGS=16)
	(input clk, reset,
		input[9:0] ctrl, //for testing purposes only
		input[SIZE-1:0] memdata, srcAddr, dstAddr, imm,
		output memwrite,
		output[SIZE-1:0] adr,
		output[SIZE-1:0] wd,
		output[4:0] condsOut);
	
	wire[SIZE-1:0] pcIn, pcOut, srcOut, dstOut, immOut, 
		d1, d2, aluIn1, aluIn2, aluOut, shifterOut, aluOutShifted, aluFinal;
	wire ctrlAlu1, ctrlAlu2, en; // removed cIn (no longer used in ALU)
	
	// changed [4:0] conds to 2 groups: [1:0] cond_group1, [2:0] cond_group2
	wire[1:0] cond_group1;
	wire[2:0] cond_group2; 
	
	wire[7:0] aluOp;
	
	//Code for testing the ALU/RF
	assign memdata = aluFinal;
	assign ctrlAlu1 = ctrl[0];
	assign ctrlAlu2 = ctrl[1];
	assign aluOp = ctrl[9:2];
	
	register #(SIZE) pcReg(reset, clk, pcIn, pcOut);
	register #(SIZE) srcReg(reset, clk, srcAddr, srcOut);
	register #(SIZE) dstReg(reset, clk, dstAddr, dstOut);
	register #(SIZE) immReg(reset, clk, imm, immOut);
	
	registerFile #(SIZE, REGBITS) rf(clk, reset, en, aluOut, srcOut, dstOut, d1, d2);
	
	mux2 #(SIZE) alu1(ctrlAlu1, pcOut, d1, aluIn1);
	mux2 #(SIZE) alu2(ctrlAlu2, d2, immOut, aluIn2);
	
	ALU #(SIZE) alu(aluOp, aluIn1, aluIn2, pcOut, aluOut, cond_group1, cond_group2); //pcOut to output to go to pcReg
	
	PSR_reg PSRreg(reset, clk, en, cond_group1, cond_group2, final_group1, final_group2); // added special reg for PSR (enable signal)
	assign condsOut = {final_group1, final_group2};
	register #(SIZE) outReg(reset, clk, aluOut, aluFinal); 
	
	
endmodule  
