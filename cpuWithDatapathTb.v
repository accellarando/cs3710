`timescale 1ns / 1ps
module cpuWithDatapath_tb ();

//input
reg clk, reset, nextStateButton,
reg [4:0] switchesLeft,
reg [4:0] switchesRight,

//output

wire [9:0] leds,
wire[6:0] readData, 
wire[6:0] writeData);


cpuWithDatapath uutCWD(
	.clk(clk),
	.reset(reset),
	.nextStateButton(nextStateButton),
	.switchesLeft(switchesLeft),
	.switchesRight(switchesRight),
	.leds(leds),
	.readData(ReadData),
	.writeData(writeData)
	
);

initial begin
	reset = 1'b1;
	nextStateButton = 1'b1;
	#200;
	reset = 1'b0;
	#200;
	reset = 1'b1;
	#200;
	nextStateButton = 1'b0;
	#200;
	nextStateButton = 1'b1;
	//check that the outputs are correct
	$display("Read data: %b, should be ...",readData);
	$display("Write data: %b, should be ...",writeData);
	#200;
	nextStateButton = 1'b0;
	#200;
	nextStateButton = 1'b1;
	$display(".Read data: %b, should be ...", readData);
	$display(".Write data: %b, should be ...", writeData);
end

endmodule 
