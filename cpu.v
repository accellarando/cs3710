module cpu (#parameter SIZE=16) (input clk, reset,
	//Bunch of inputs for control signals until we
	//get to that assignment
	MemW1e, MemW2e, RegW1e, RegW2e, psr_en,
	PCm, LUIm, A2m, Movm, 
	input[3:0] AluOp,
	input[(SIZE-1):0] switches,
	//have a bunch of outputs for testing purposes.
	//ultimately, only output from mem-mapped IO
	output[(SIZE-1):0] PC, AluOut,
	RegR1, RegR2, RegW1, RegW2,
	MemR1, MemR2, MemW1, MemW1,
	leds);
	
	//Instantiate internal nets
	wire[(SIZE-1):0] MemAddr1, MemAddr2, seImm, 
		PcMuxOut, LuiMuxOut, A2MuxOut;
	
	//Different modules that we need, and their connections
	register 		PCreg(reset, clk, PcMuxOut, MemAddr1);
	bram 				RAM(MemW1, MemW2, 
							MemAddr1, MemAddr2, 
							switches, 
							clk, 
							MemW1e, MemW2e,
							MemR1, MemR2,
							leds);
	registerFile 	rf(clk, reset, 
							RegW1e, RegW2e,
							RegW1, RegW2,
							instr[11:8], instr[3:0],
							RegR1, RegR2);
	signExtender 	se(instr[7:0], seImm);
	alu				myAlu(aluOp, 
							LuiMuxOut, A2MuxOut,
							aluOut,
							flags1, flags2);
	PSR_reg			pr(reset, clk, psr_en
		(input reset, clk, en,
	input [1:0] cond_group1, // 2 flags, C and F
	input [2:0] cond_group2, // 3 flags, L, Z, and N
	output reg [1:0] final_group1, 
	output reg [2:0] final_group2
	
	
	
endmodule 