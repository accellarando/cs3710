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
	input Movm, A1m,													// mux select signals (MoveMux, RWriteMux)
	input[1:0] PCm, A2m, RWm,										// mux select signals (PCMux, ALU2Mux, LUIMux)
	input[3:0] aluOp,
	input[9:0] switches,												// simulate on board
	
	output[(SIZE-1):0] instr,										// instruction bits at an address
	output[1:0] flags1out,
	output[2:0] flags2out,
	output[9:0] leds													// simulate on board
	
	// (Assignment #2) outputs to test with temporary test FSM  
	//output[SIZE-1:0] PC, AluOut,
	//output[SIZE-1:0] RFwrite, RFread1, RFread2,						// register file data input and outputs
	//output[SIZE-1:0] MemWrite1, MemWrite2, MemRead1, MemRead2,	// bram memory access data input and output  
	);

	/* Instantiate internal nets */
	wire[(SIZE-1):0] PC, nextPC;											// Program Counter elements
	wire[(SIZE-1):0] RFwrite, RFread1, RFread2;						// Register File
	wire[(SIZE-1):0] MemWrite1, MemWrite2, MemRead1, MemRead2,
						  MemAddr1, MemAddr2;								// BRAM
	wire[(SIZE-1):0] A1MuxOut, A2MuxOut, aluOut, 					
						  LuiMuxOut, MovMuxOut, PcMuxOut;				// control-signal mux
	wire[1:0] flags1;	
	wire[2:0] flags2;
	
	// sign-extension wire manipulation
	wire[(SIZE-1):0] immd;
	assign immd = instr[7:0];// immediate bits (8-bits) isolated from the instruction 
	
	wire[SIZE-1:0] luiImmd;
	assign luiImmd = immd << 8; // LUI instruction takes immediate bits and left-shifts by 8-bits     
	
	wire[(SIZE-1):0] seImmd;	// sign-extension immediate 
	assign seImmd = instr[7] ? {{8{1'b1}},instr[7:0]} : {{8{1'b0}},instr[7:0]};

	/* Instantiate modules */
	//reg[(SIZE-1):0] nextPC;	// register that overwrite PC for incrementation

	en_register		PC_Reg(.clk(clk), .reset(reset), .d(PcMuxOut), .q(MemAddr1), .en(PCen));
	
	//incrementer		pci(clk,MemAddr1,nextPc);
	assign nextPC = MemAddr1 + 1'b1;

	
	en_register		Instr_Reg(.clk(clk), .reset(reset), .d(MemRead1), .q(instr), .en(INSTRen)); // input comes from bram  
	
	
	
	bram	RAM(
		.clk(clk),
		.we_a(MemW1en), .we_b(MemW2en),
		.data_a(MemWrite1), .data_b(MemWrite2), 
		.addr_a(MemAddr1), .addr_b(MemAddr2), 
		.ex_inputs(switches),
		
		.q_a(MemRead1), .q_b(MemRead2), 
		.ex_outputs(leds)
	);
	
	registerFile	regFile(
		.clk(clk), .reset(reset),
		.writeEn(RFen), .writeData(RFwrite),
		.srcAddr(instr[11:8]), .dstAddr(instr[3:0]),
		
		.readData1(RFread1), .readData2(RFread2)
	
	);
			
	mux2  A1Mux(.s(A1m),.in1(RFread1),.in2(MemAddr1),.out(A1MuxOut));

	
	alu	myAlu(
		.aluOp(aluOp),
		.aluIn1(A1MuxOut), .aluIn2(A2MuxOut), //rfread1
		
		.aluOut(aluOut),
		.cond_group1(flags1), .cond_group2(flags2)
	);
	
	PSR_reg	psr(
		.clk(clk), .reset(reset), 
		.en(PSRen),
		.cond_group1(flags1), .cond_group2(flags2),
		
		.final_group1(flags1out), .final_group2(flags2out)
	);
	

	/* Temporary controller FSM: muxes/ */
	mux3 	PCmux(
		.s(PCm),
		.a(nextPC), .b(RFread2), .c(aluOut),
		.out(PcMuxOut)
	);
	
	mux4 RWritemux(
		.s(RWm),
		.a(MemRead2), .b(nextPC), .c(MovMuxOut), .d(luiImmd),
		.out(RFwrite)
	);

	mux2 	MovMux(
		.s(Movm),
		.in1(A2MuxOut), .in2(aluOut),
		.out(MovMuxOut)
	);
	
	//wire[SIZE-1:0] seImm;
	mux3 	Alu2Mux(
		.s(A2m),
		.a(RFread2), .b( {instr[3:0]} ), .c( seImmd ),	// c-input sign-extend the immediate back to 16-bits (!) change to immd concate
		//.a(RFread2), .b( {instr[3:0]}} ), .c( {{(SIZE-4){1'b0}} ), //zero extend that? or sign extend...
		.out(A2MuxOut)
	);
	
	


	/*
	mux2 	LuiMux(
		.s(LUIm),
		.in1(instr), .in2(luiImmd),
		.out(RFWrite)
	);
	*/
	
//	mux3 	LuiMux(
//		.s(LUIm),
//		.a(RFread1), .b(MemAddr1), .c(16'd8),
//		.out(LuiMuxOut)
	//);
	
endmodule 