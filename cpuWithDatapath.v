module cpuWithDatapath #(parameter SIZE=16, NUMREGS=16)
	(input clk,
		reset, nextStateButton, 
		output [9:0] leds,
		//output[6:0] led0, led1, led2, led3); //?
		output[6:0] readData, //data we're reading/writing, to 7seg display
		output[6:0] writeData);
		
	wire we1, we2;
	reg[SIZE-1:0] addr1, addr2, dataIn1, dataIn2, dataOut1, dataOut2, hex;

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
	
	assign leds = addr1[9:0];

endmodule 
