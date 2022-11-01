// Documentation:
// CURRENT ASSIGNMENT -> 
// NEXT ASSIGNMENT -> instruction decoding, control state machine (FSM), I/O support configurations for our project

// datapath module same as cpu module
module datapath #(parameter SIZE = 16) (
	input clk, reset,
	
	/* Temporary controller FSM: control signals*/
	input MemW1en, MemW2en, RFen, PSRen,		// enable signals (modules: bram, registerFile)
	input Movm, RWm,									// mux select signals (MoveMux, RWriteMux)
	input[1:0] PCm, A2m, LUIm,						// mux select signals (PCMux, ALU2Mux, LUIMux)
	input[3:0] AluOp,
	input[SIZE-1:0] switches,						// simulate on board
	
	output[SIZE-1:0] AluOut,
	output[SIZE-1:0] RFwrite, RFread1, RFread2,						// register file data input and outputs
	output[SIZE-1:0] MemWrite1, MemWrite2, MemRead1, MemRead2,	// bram memory access data input and output  
	output[1:0] flags1out,
	output[2:0] flags2out,
	output[9:0] leds															// simulate on board
	
	// Program counter register (?) -> working without controller FSM -> MUXES
	input pcIncrement;			// (condition if single-cycle should continue) to move to the next PC
	input pcNextOut;				// (condtion for Branches and Jumps) next PC should be the output 
	input pcInstr;					// (condition for Branches and Jumps) either modify the PC or the alu input
	output reg [SIZE-1:0] PC;
	
	);
	
	// declare vars (?)
	reg [SIZE-1 : 0] nextPC;	// register that overwrites PC 
	
	// EXAMPLE PC mux (?) to change
	always @(*) begin
		if (~reset) nextPC <= PC;
		else if (pcContinue) nextPC <= PC + 1;
		else if (pcOverwrite) nextPC <= outputReg;
		else nextPC <= PC;
    end
	
	/* Instantiate internal nets */
	wire[(SIZE-1):0] MemAddr1, MemAddr2;
	wire[(SIZE-1):0] seImm;
	wire[(SIZE-1):0] PcMuxOut, LuiMuxOut, A2MuxOut, movMuxOut;	// temporary controller FSM: mux output
	wire[(SIZE-1):0] instr, nextPc;
	wire[1:0] flags1;
	wire[2:0] flags2;
	
	/* Instantiate modules */
	register		PC_Reg(.clk(clk), .reset(reset), .d(PcMuxOut), .q(MemAddr1));
	
	register		Instr_Reg(.clk(clk), .reset(reset), .d(MemR1), .q(instr));
	
	
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
		
		.readData1(RegR1), .readData2(RegR2)
	
	);
	
	// signExtender 	se(instr[7:0], seImm);
	
	alu	myAlu(
		.aluOp(aluOp),
		.aluIn1(LuiMuxOut), .aluIn2A2MuxOut
		
		.aluOut(aluOut),
		.cond_group1(flags1), .cond_group2(flags2)
	);
	
	PSR_reg	psr(
		.clk(clk), .reset(reset), 
		.en(PSRen),
		.cond_group1(flags1), .cond_group2(flags2),
		
		.final_group1(flags1out), .final_group2(flags2out)
	);
	
	//incrementer		pci(clk,MemAddr1,nextPc);

	/* Temporary controller FSM: muxes */
	mux3 	PCmux(
		.s(PCm),
		.a(nextPc), .b(RegR1), .c(aluOut),
		.out(PcMuxOut)
	);
	
	mux3 	RWritemux(
		.s(RWm),
		.a(MemR2), .b(nextPc), .c(MovMuxOut),
		.out(RFwrite)
	);
	

	mux2 	MovMux(
		.s(Movm),
		.in1(A2MuxOut), .in2(aluOut),
		.out(MovMuxOut)
	);
	
	mux3 	Alu2Mux(
		.s(A2m),
		.a(RegR2), .b({{(SIZE-4){1'b0}}), .c({instr[3:0]}}), //zero extend that? or sign extend...
		.out(seImm)
	);
	
	mux3 	LuiMux(
		.s(LUIm),
		.a(RegR1), .b(MemAddr1), .c(16'd8),
		.out(LuiMuxOut)
	);
	
endmodule 