module final_cpu(
	input clk, reset,
	input [9:0] switches,
	output [9:0] leds);
	
	wire[15:0] instr;
	reg RFen, PSRen, PCen, PCm, MemW1en, MemW2en, Movm;
	reg[3:0] AluOp;
	reg[1:0] A2m, RWm;
	
	wire[1:0] flags1out;
	wire[2:0] flags2out;
	
	/*
	input clk, reset,
	input[SIZE-1:0] instr,	// instruction bits
	input zero,					// program counter enable -> check minimips
	input flag1, flag2,
	
	output reg RFen, PSRen,			// Register File controller
	output reg[3:0] AluOp,			// ALU controller
	output reg PCm, PCen 			// PC controller
	output reg MemW1en, MemW2en,	// Memory (BRAM) controller
	output reg Movm, 					// other muxes
	output reg[1:0] A2m, RWm 		// other muxes
	*/
	controller cont(.clk(clk), .reset(reset),
		.instr(instr),
		.zero(1'b0), //????
		.flag1(flags1out), .flag2(flags2out),
		.RFen(RFen), .PSRen(PSRen), .PCen(PCen),
		.AluOp(AluOp),
		.PCm(PCm),
		.MemW1en(MemW1en), .MemW2en(MemW2en),
		.Movm(Movm), .A2m(A2m), .RWm(RWm)
	);
	
	datapath dp(clk, reset,
		MemW1en, MemW2en, RFen, PSRen, PCen,
		Movm,
		PCm, A2m, RWm,
		AluOp,
		switches,
		leds,
		flags1out, flags2out
	);
	
endmodule 