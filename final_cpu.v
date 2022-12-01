module final_cpu(
	input clk, reset,

	//VGA outputs.
	output[23:0] rgb,
	output hSync, vSync, vgaBlank, vgaClk,
	
	//Memory mapped IO devices.
	input[17:0] GPI, output[17:0] GPO,
	input[3:0] buttons,
	input[9:0] switches,
	output[9:0] leds
	);
	
	wire[15:0] instr;
	wire RFen, PSRen, PCen, MemW1en, MemW2en, Movm, INSTRen, A1m, setZNL;
	wire[3:0] AluOp;
	wire[1:0] A2m, RWm, PCm;

	wire[1:0] flags1out;
	wire[2:0] flags2out;
	
	//Memory mapping parameters
	parameter GLYPHS_START_ADDR = 16'h37FB;
	parameter PEOPLE_COUNT_ADDR = 16'h1000;
	
	//assign leds = 10'b0;
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
    wire[15:0] memAddr, memData;
	datapath dp(.clk(clk), .reset(reset),
		.MemW1en(MemW1en), .MemW2en(MemW2en), .RFen(RFen), 
		.PSRen(PSRen), .PCen(PCen), .INSTRen(INSTRen),
		.Movm(Movm), .A1m(A1m), .setZNL(setZNL),
		.PCm(PCm), .A2m(A2m), .RWm(RWm),
		.aluOp(AluOp),
		.instr(instr),
		.flags1out(flags1out), .flags2out(flags2out),
		
		.memAddrB(memAddr), .memDataB(memData),
		
		.gpi(GPI), .gpo(GPO),
		.buttons(buttons), .switches(switches),
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
	

	wire bright;
	wire[9:0] hCount, vCount;
	assign vgaBlank = 1'b1;
	vgaControl vc(.clk(clk), .clr(reset),
		.hSync(hSync), .vSync(vSync), .bright(bright),
		.hCount(hCount), .vCount(vCount),
		.vgaClk(vgaClk)
	);

	/*
	input clk, bright,
	input [9:0] hCount,
	input [9:0] vCount,
	input [7:0] count,
	output reg[23:0] rgb
	*/
	bitGen bg(.clk(clk), .bright(bright), .reset(reset),
		.hCount(hCount), .vCount(vCount),
		.rgb(rgb), .memData(memData), .memAddr(memAddr),
		.glyphs(GLYPHS_START_ADDR),
		.count_addr(PEOPLE_COUNT_ADDR)
	);
	

	
endmodule 
