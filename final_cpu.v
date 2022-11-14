module final_cpu(
	input clk, reset,
	input [9:0] switches,
	output [9:0] leds);
	
	wire[15:0] instr;
	reg RFen, PSRen, PCen, PCm, MemW1en, MemW2en, Movm;
	reg[3:0] AluOp;
	reg[1:0] A2m, RWm;
	
	controller cont(.clk(clk), .reset(reset),
		.instr(instr),
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