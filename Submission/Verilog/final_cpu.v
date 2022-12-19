/*** final_cpu - The top level module for the project.
 * Instantiates datapath, controller, and VGA 
 * controller/bitgen modules.
 * Author: Ella Moss
 */
module final_cpu(
	input clk, reset,

	//VGA outputs.
	output[23:0] rgb,
	output hSync, vSync, vgaBlank, vgaClk,
	
	//Memory mapped IO devices.
	input[17:0] GPI, output[17:0] GPO,
	input[2:0] buttons,
	input[9:0] switches,
	output[9:0] leds,
	output[41:0] segs
	);
	
	//Instantiate internal nets to communicate between 
	//controller, datapath, and vga peripherals
	wire[15:0] instr;
	wire RFen, PSRen, PCen, MemW1en, MemW2en, Movm, INSTRen, A1m, setZNL;
	wire[3:0] AluOp;
	wire[1:0] A2m, RWm, PCm;

	wire[1:0] flags1out;
	wire[2:0] flags2out;
	
	//Memory mapping parameters
	parameter GLYPHS_START_ADDR = 16'hD7F0;
	parameter PEOPLE_COUNT_ADDR = 16'h1000;
	
    wire[15:0] memAddr, memData;
	wire MAm;

	//Instantiate the datapath.
	datapath dp(.clk(clk), .reset(reset),
		.MemW1en(MemW1en), .MemW2en(MemW2en), .RFen(RFen), 
		.PSRen(PSRen), .PCen(PCen), .INSTRen(INSTRen),
		.Movm(Movm), .A1m(A1m), .setZNL(setZNL),
		.PCm(PCm), .A2m(A2m), .RWm(RWm), .MAm(MAm),
		.aluOp(AluOp),
		.instr(instr),
		.flags1out(flags1out), .flags2out(flags2out),
		
		.memAddrB(memAddr), .memDataB(memData),
		
		.gpi(GPI), .gpo(GPO),
		.buttons(buttons), .switches(switches),
		.leds(leds), .segs(segs)
	);

	//Instantiate the controller.
	controller cont(.clk(clk), .reset(reset),
		.instr(instr),
		.flag1(flags1out), .flag2(flags2out),
		.RFen(RFen), .PSRen(PSRen), .INSTRen(INSTRen), 
		.PCen(PCen),
		.AluOp(AluOp),
		.PCm(PCm), .setZNL(setZNL),
		.MemW1en(MemW1en), .MemW2en(MemW2en),
		.Movm(Movm), .A1m(A1m), .A2m(A2m), .RWm(RWm), .MAm(MAm)
	);

	//VGA support.
	wire bright;
	wire[9:0] hCount, vCount;
	assign vgaBlank = 1'b1;
	vgaControl vc(.clk(clk), .clr(reset),
		.hSync(hSync), .vSync(vSync), .bright(bright),
		.hCount(hCount), .vCount(vCount),
		.vgaClk(vgaClk)
	);
	bitGen bg(.clk(clk), .bright(bright), .reset(reset),
		.hCount(hCount), .vCount(vCount), .memData(memData),
		.glyphs(GLYPHS_START_ADDR),
		.count_addr(PEOPLE_COUNT_ADDR),
		.hSync(hSync), .vSync(vSync),
		.memAddr(memAddr),
		.rgb(rgb));
	
endmodule 
