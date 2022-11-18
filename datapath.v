// Documentation:
// CURRENT ASSIGNMENT -> 
// NEXT ASSIGNMENT -> instruction decoding, control state machine (FSM), I/O support configurations for our project

// datapath module same as cpu module
module datapath #(parameter SIZE = 16) (
	input clk, reset,
	
	/* Temporary controller FSM: control signals*/
	input MemW1en, MemW2en, RFen, PSRen, PCen, INSTRen,		// enable signals (modules: bram, registerFile)
	input Movm, A1m,									// mux select signals (MoveMux, RWriteMux)
	input[1:0] PCm, A2m, RWm,//LUIm,						// mux select signals (PCMux, ALU2Mux, LUIMux)
	input[3:0] AluOp,
	input[SIZE-1:0] switches,						// simulate on board
	
	//output[SIZE-1:0] PC, AluOut,
	//output[SIZE-1:0] RFwrite, RFread1, RFread2,						// register file data input and outputs
	//output[SIZE-1:0] MemWrite1, MemWrite2, MemRead1, MemRead2,	// bram memory access data input and output  
	output[1:0] flags1out,
	output[2:0] flags2out,
	output[9:0] leds												// simulate on board
	);
	
	// declare vars (?)
	reg [SIZE-1 : 0] nextPC;	// register that overwrites PC 
	

	
	/* Instantiate internal nets */
	wire[(SIZE-1):0] MemAddr1, MemAddr2;
	wire[(SIZE-1):0] seImm;
	wire[(SIZE-1):0] PcMuxOut, LuiMuxOut, A2MuxOut, movMuxOut;	// temporary controller FSM: mux output
	wire[(SIZE-1):0] instr, nextPc;
	wire[1:0] flags1;
	wire[2:0] flags2;
	
	wire [SIZE-1:0] immd; 		// immediate from instruction (will be instr[7:0])
	assign immd = instr[7:0];
	wire[SIZE-1:0] luiImmd;
	assign luiImmd = immd << 8;
	
	/* Instantiate modules */
	en_register		PC_Reg(.clk(clk), .reset(reset), .d(PcMuxOut), .q(MemAddr1), .en(PCen));
	
	//incrementer		pci(clk,MemAddr1,nextPc);
	assign nextPc = MemAddr1 + 1'b1;

	
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
	
	wire[SIZE-1:0] A1MuxOut;
		
	mux2  A1Mux(.s(A1m),.in1(RFread1),.in2(MemAddr1),.out(A1MuxOut));

	
	alu	myAlu(
		.aluOp(aluOp),
		.aluIn1(RFread1), .aluIn2(A2MuxOut), //rfread1
		
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
		.a(nextPc), .b(RFread2), .c(aluOut),
		.out(PcMuxOut)
	);
	
	mux4 RWritemux(
		.s(RWm),
		.a(MemRead2), .b(nextPc), .c(MovMuxOut), .d(luiImmd),
		.out(RFwrite)
	);

	mux2 	MovMux(
		.s(Movm),
		.in1(A2MuxOut), .in2(aluOut),
		.out(MovMuxOut)
	);
	
	//wire[SIZE-1:0] seImm;
	assign seImm = instr[7] ? {{8{1'b1}},instr[7:0]} : {{8{1'b0}},instr[7:0]};
	mux3 	Alu2Mux(
		.s(A2m),
		.a(RFread2), .b( {instr[3:0]} ), .c( seImm ),	// c-input sign-extend the immediate back to 16-bits (!) change to immd concate
		//.a(RFread2), .b( {instr[3:0]}} ), .c( {{(SIZE-4){1'b0}} ), //zero extend that? or sign extend...
		.out(seImm)
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
