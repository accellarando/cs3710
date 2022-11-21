module final_cpu(
	input clk, reset,
	input [9:0] switches,
	output [9:0] leds);
	
	wire[15:0] instr;
	wire RFen, PSRen, PCen, MemW1en, MemW2en, Movm, INSTRen, A1m;
	wire[3:0] AluOp;
	wire[1:0] A2m, RWm, PCm;

	wire[1:0] flags1out;
	wire[2:0] flags2out;
	
	/*
	input clk, reset,
	input[SIZE-1:0] instr,	// instruction bits
	//input zero,					// program counter enable -> check minimips
	input[1:0] flag1, 
	input[2:0] flag2,
	output reg RFen, PSRen,	INSTRen,		// Register File controller
	output reg[3:0] AluOp,			// ALU controller
	output reg PCm, PCen, 			// PC controller
	output reg MemW1en, MemW2en,	// Memory (BRAM) controller
	output reg Movm, A1m,			// other muxes
	output reg[1:0] A2m, RWm 		// other muxes
	); 
	*/
	controller cont(.clk(clk), .reset(reset),
		.instr(instr),
		.flag1(flags1out), .flag2(flags2out),
		.RFen(RFen), .PSRen(PSRen), .INSTRen(INSTRen), 
		.PCen(PCen),
		.AluOp(AluOp),
		.PCm(PCm),
		.MemW1en(MemW1en), .MemW2en(MemW2en),
		.Movm(Movm), .A1m(A1m), .A2m(A2m), .RWm(RWm)
	);
	
	datapath dp(clk, reset,
		MemW1en, MemW2en, RFen, 
		PSRen, PCen, INSTRen,
		Movm, A1m,
		PCm, A2m, RWm,
		AluOp,
		switches,
		flags1out, flags2out,
		leds
	);
	
endmodule 