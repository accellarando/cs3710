module cpu #(parameter SIZE=16) (input clk, reset,
	//Bunch of inputs for control signals until we
	//get to that assignment
	MemW1e, MemW2e, RegWe, psr_en,
	LUIm, Movm, RWm,
	input [1:0] PCm, A2m,
	input[3:0] AluOp,
	input[(SIZE-1):0] switches,
	//have a bunch of outputs for testing purposes.
	//ultimately, only output from mem-mapped IO
	output[(SIZE-1):0] PC, AluOut,
		RegR1, RegR2, RegW,
		MemR1, MemR2, MemW1, MemW2,
	output[1:0] flags1out,
	output[2:0] flags2out,
	leds);
	
	//Instantiate internal nets
	wire[(SIZE-1):0] MemAddr1, MemAddr2, seImm, 
		PcMuxOut, LuiMuxOut, A2MuxOut, movMuxOut,
		instr, nextPc;
	wire[1:0] flags1;
	wire[2:0] flags2;
	
	//Different modules that we need
	register 		PCreg(reset, clk, PcMuxOut, MemAddr1);
	register			instrReg(reset, clk, MemR1, instr);
	bram 				RAM(MemW1, MemW2, 
							MemAddr1, MemAddr2, 
							switches, 
							clk, 
							MemW1e, MemW2e,
							MemR1, MemR2,
							leds);
	registerFile 	rf(clk, reset, 
							RegWe,RegW,
							instr[11:8], instr[3:0],
							RegR1, RegR2);
	signExtender 	se(instr[7:0], seImm);
	alu				myAlu(aluOp, 
							LuiMuxOut, A2MuxOut,
							aluOut,
							flags1, flags2);
	PSR_reg			pr(reset, clk, psr_en, flags1, flags2, flags1out, flags2out);
	incrementer		pci(clk,MemAddr1,nextPc);
	
	//Now for the muxes.
	mux3 PCmux(PCm, nextPc, RegR1, aluOut, PcMuxOut);
	mux3 RWritemux(RWm, MemR2, nextPc, MovMuxOut, RegW);
	mux2 MovMux(Movm, A2MuxOut, aluOut, MovMuxOut);
	mux3 Alu2Mux(A2m, RegR2, {{(SIZE-4){1'b0}},{instr[3:0]}}, seImm); //zero extend that? or sign extend...
	mux2 LuiMux(LUIm, RegR1, 16'd8, LuiMuxOut);
	
endmodule 