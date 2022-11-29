module final_cpu(
	input clk, reset,
	input [9:0] switches,
	output [9:0] leds);
	
	//wire[15:0] instr;
	wire RFen, PSRen, PCen, MemW1en, MemW2en, Movm, INSTRen, A1m, setZNL;
	wire[3:0] AluOp;
	wire[1:0] A2m, RWm, PCm;

	wire[1:0] flags1out;
	wire[2:0] flags2out;
	
	/*
input clk, reset,
	input MemW1en, MemW2en, RFen, PSRen, PCen, INSTRen,	// enable signals (BRAM, reg)
	input Movm, A1m, setZNL,										// mux select signals (MoveMux, Alu1mux)
	input[1:0] PCm, A2m, RWm,										// mux select signals (PCMux, Alu2mux, RWritemux)
	input[3:0] aluOp,
	input[9:0] switches,												// simulate on board
	
	output[(SIZE-1):0] instr,										// instruction bits at an address
	output[1:0] flags1out,
	output[2:0] flags2out,
	output[9:0] leds				
	*/
	datapath dp(.clk(clk), .reset(reset),
		.MemW1en(MemW1en), .MemW2en(MemW2en), .RFen(RFen), 
		.PSRen(PSRen), .PCen(PCen), .INSTRen(INSTRen),
		.Movm(Movm), .A1m(A1m), .setZNL(setZNL),
		.PCm(PCm), .A2m(A2m), .RWm(RWm),
		.aluOp(AluOp),
		.switches(switches),
		.instr(instr),
		.flags1out(flags1out), .flags2out(flags2out),
		.leds(leds)
	);
	
	controller cont(.clk(clk), .reset(reset),
		.instr(instr),
		.flag1(flags1out), .flag2(flags2out),
		.RFen(RFen), .PSRen(PSRen), .INSTRen(INSTRen), 
		.PCen(PCen),
		.AluOp(AluOp),
		.PCm(PCm), .setZNL(setZNL),
		.MemW1en(MemW1en), .MemW2en(MemW2en),
		.Movm(Movm), .A1m(A1m), .A2m(A2m), .RWm(RWm)
	);
	

	
endmodule 