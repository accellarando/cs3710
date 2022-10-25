module cpuWithDatapath #(parameter SIZE=16, NUMREGS=16)
	(input clk,
		reset, nextStateButton,
		output[9:0] leds,
		output[6:0] readData,
		output[6:0] writeData);
		
	wire we;
	reg[SIZE-1:0] addr, dataIn, dataOut;
	stateMachine fsm(nextStateButton,reset,addr,we,dataIn);
	
	memory mem(we, clk, addr, dataIn, dataOut);
	hexTo7Seg readDataDecode(dataOut[3:0], readData);
	hexTo7Seg writeDataDecode(dataIn[3:0], writeData);
	
	assign leds = addr[9:0];
endmodule 