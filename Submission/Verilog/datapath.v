/*
----------------------------------------------------------------------------
[SUMMARY]
- Datapath consists of the functional units of the processor/CPU:
	+ Elements that hold data (Program Counter, Register File, Instruction
	Register, Data Memory/BAM).
	+ Elements that operate on data (ALU, adder, wire manipulation).
	+ Control-signal muxes that determine the correct data transfer between
	these elements.
	
- In conjunction with the datapath, the controller FSM will command when/how
to route and operate on data.
----------------------------------------------------------------------------
*/
module datapath #(parameter SIZE = 16) (
	input clk, reset,
	
	/* Temporary controller FSM: control signals*/
	input MemW1en, MemW2en, RFen, PSRen, PCen, INSTRen,	// enable signals (BRAM, reg)
	input Movm, A1m, setZNL,										// mux select signals (MoveMux, Alu1mux)
	input[1:0] PCm, MAm, A2m, RWm,								// mux select signals (PCMux, MemAddrMux, Alu2mux, RWritemux)
	input[3:0] aluOp,
	input[(SIZE-1):0] memAddrB,										// BRAM MemAddr2 input
	
	output[(SIZE-1):0] memDataB,										// BRAM MemRead2 output
	output[(SIZE-1):0] instr,										// instruction bits at an address
	output[1:0] flags1out,
	output[2:0] flags2out,

	//Memory mapped IO.
	input[17:0] gpi,
	output[17:0] gpo,

	input[2:0] buttons,
	input[9:0] switches,

	output[9:0] leds,
	output[41:0] segs
	);

	/* Instantiate internal nets */
	wire[(SIZE-1):0] PC, nextPC;											// Program Counter elements
	wire[(SIZE-1):0] RFwrite, RFread1, RFread2;						// Register File
	wire[(SIZE-1):0] MemWrite1, MemWrite2, MemRead1, MemRead2,
						  MemAddr1, MemAddr2;								// BRAM
	wire[(SIZE-1):0] A1MuxOut, A2MuxOut, aluOut, 					
						  LuiMuxOut, MovMuxOut, PcMuxOut, AddrOut;	// control-signal mux
	wire[1:0] flags1;	
	wire[2:0] flags2;
	
	// sign-extension wire manipulation
	wire[(SIZE-1):0] immd;
	assign immd = instr[7:0]; // immediate bits (8-bits) isolated from the instruction 
		
	wire[SIZE-1:0] luiImmd;
	assign luiImmd = immd << 8; // (for LUI) immediate bits and left-shifts by 8-bits     
	
	wire[(SIZE-1):0] seImmd; 
	// check if the MSB of the immediate bits from the instruction is 0/1
	// concatenate 8-bits with 0's/1's and appends immediate bits back to 16-bits
	assign seImmd = instr[7] ? {{8{1'b1}},instr[7:0]} : {{8{1'b0}},instr[7:0]}; // sign-extend immediate

	
	/* Instantiate modules and elements */
	assign nextPC = MemAddr1 + 1'b1; // (for JAL) adder 1-bit/increment address from PC 
	
	// Program Counter register
	en_register		PC_Reg(.clk(clk), .reset(reset), .d(PcMuxOut), .q(MemAddr1), .en(PCen));

	// Instruction register
	en_register		Instr_Reg(.clk(clk), .reset(reset), .d(MemRead1), .q(instr), .en(INSTRen)); 
	
	
	// Data Memory
	bram	RAM(
		.clk(clk),
		.we_a(MemW1en), .we_b(MemW2en),
		.data_a(RFread1), .data_b(MemWrite2), //.data_a(MemWrite1)
		.addr_a(AddrOut), .addr_b(memAddrB), //.addr_b(MemAddr2)
		.q_a(MemRead1), .q_b(memDataB), //.q_a(MemRead1), .q_b(MemRead2) ->VGAout q_b 

		//Memory mapped IO:
		.gpi(gpi), .gpo(gpo),
		.buttons(buttons), .switches(switches),
		.leds(leds), .sevSegs(segs)
	);
	
	// Register File
	registerFile	regFile(
		.clk(clk), .reset(reset),
		.writeEn(RFen), .writeData(RFwrite),
		.srcAddr(instr[3:0]), .dstAddr(instr[11:8]),
		
		.readData1(RFread1), .readData2(RFread2)
	
	);
			
	// ALU
	alu	myAlu(
		.clk(clk),
		.setZNL(setZNL),
		.aluOp(aluOp),
		.aluIn1(A1MuxOut), .aluIn2(A2MuxOut), //rfread1
		
		.aluOut(aluOut),
		.cond_group1(flags1), .cond_group2(flags2)
	);
	
	// PSR
	PSR_reg	psr(
		.clk(clk), .reset(reset), 
		.en(PSRen),
		.cond_group1(flags1), .cond_group2(flags2),
		
		.final_group1(flags1out), .final_group2(flags2out)
	);
	

	/* Control-signal muxes */
	// Program Counter mux
	mux3	PCmux(
		.s(PCm),
		.a(nextPC), .b(RFread2), .c(aluOut),
		.out(PcMuxOut)
	);
	
	// Memory Address mux
	mux2	MemAddrMux(
		.s(MAm),
		.in1(MemAddr1),
		.in2(RFread2),
		.out(AddrOut)
	);
	
	// Read-Write Data mux
	mux4	RWritemux(
		.s(RWm),
		.a(MemRead1), .b(nextPC), .c(MovMuxOut), .d(luiImmd),
		.out(RFwrite)
	);

	// Move Data mux
	mux2	MovMux(
		.s(Movm),
		.in1(A2MuxOut), .in2(aluOut),
		.out(MovMuxOut)
	);
	
	// ALU 1 mux
	mux2	Alu1Mux(
		.s(A1m),
		.in1(RFread1),
		.in2(MemAddr1),
		.out(A1MuxOut)	// input to ALU
	);
	
	// ALU 2 mux
	mux3 	Alu2Mux(
		.s(A2m),
		.a(RFread2), .b( {instr[3:0]} ), .c( seImmd ),
		.out(A2MuxOut)	// input to either ALU or Move Data mux
	);

endmodule 
