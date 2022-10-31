module cpuWithDatapath #(parameter SIZE=16, NUMREGS=16)
	(input clk,
		reset, nextStateButton, 
		output [9:0] leds,
		//output[6:0] led0, led1, led2, led3); //?
		output[6:0] readData, //data we're reading/writing
		output[6:0] writeData);
		
	wire we1, we2;
	reg[SIZE-1:0] addr1, addr2, dataIn1, dataIn2, dataOut1, dataOut2, hex;
	/* hex is an output from fsm -- a sort of [15:0] "dataFinal" 
		to tell hexTo7Seg which out of the 2 sets of addresses/write/data's considered, 
		should be ouputted to the leds on the board.
		
		** Unsure how readData and writeData fit into this, commented them out for now **
		
		** led0, led1, led2, led3 are I/O, compile and use pin planner to finish this **
		
		** Finished bram (basically memory, but considers 2 addresses/data/write on single clock **
		** Finished hexTo7Seg**
		
		** fsm needs to be finished, outline of how it should work is in that module **
		
	*/
	// Need to consider 2 separate addresses, their own we, and their own data.
	stateMachine fsm(nextStateButton,reset,addr1, addr2, we1, we2, dataIn1, dataIn2);
	
	// D Ram interface (1 clock, considers 2 addresses, each with their own we and data out.
	bram bram_interface(dataIn1, dataIn2, addr1, addr2, we1, we2, clk, dataOut1, dataOut2);
	
	
	/*
	hexTo7Seg hexDecode0(hex[3:0], led0);
	hexTo7Seg hexDecode1(hex[7:4], led1);
	hexTo7Seg hexDecode2(hex[11:8], led2);
	hexTo7Seg hexDecode3(hex[15:12], led3);
	*/
	
	hexTo7Seg hexerRead(dataOut1[3:0],readData);
	hexTo7Seg hexerWrite(dataIn1[3:0],writeData);
	
	assign leds = addr[9:0];
endmodule 
