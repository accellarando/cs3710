module cpuWithDatapath #(parameter size=16, NUMREGS=16)
	(input clk,
		reset, nextStateButton,
		output[9:0] leds,
		output[6:0] readData,
		output[6:0] writeData)
		
	stateMachine fsm();
	hexTo7Seg readDataDecode(readDataBytes, readData);
	hexTo7Seg writeDataDecode(writeDataBytes, writeData);
	assign leds = addr[9:0];
endmodule 