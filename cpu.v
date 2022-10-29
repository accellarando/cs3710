module cpu (#parameter SIZE=16) (input clk, reset,
	//Bunch of inputs for control signals until we
	//get to that assignment
	MemW1e, MemW2e, RegW1e, RegW2e, 
	PCm, LUIm, A2m, Movm, 
	AluOp,
	input[(SIZE-1):0] switches,
	//have a bunch of outputs for testing purposes.
	//ultimately, only output from mem-mapped IO
	output[(SIZE-1):0] PC, AluOut,
	RegR1, RegR2, RegW1, RegW2,
	MemR1, MemR2, MemW1, MemW1,
	leds);
	
	//Instantiate internal nets
	wire[(SIZE-1):0] MemAddr1, MemAddr2;
	
	//Different modules that we need, and their connections
	register 		PCreg(reset, clk, PcMuxOut, MemAddr1);
	bram 				RAM(MemW1, MemW2, 
							MemAddr1, MemAddr2, 
							switches, 
							clk, 
							MemW1e, MemW2e,
							MemR1, MemR2,
							leds);
	registerFile 	rf(clk, reset,
	
	input								clk, reset,
	input 							writeEn1, writeEn2,		// enable signals
	input[SIZE-1:0] 				writeData1, writeData2, //	16-bit Data ins
	input[REGBITS-1:0]			srcAddr, dstAddr,			// 4-bit wide read addresses	
	output reg[SIZE-1:0] 		readData1, readData2		// 16-bit Data out
	
	
	
endmodule 