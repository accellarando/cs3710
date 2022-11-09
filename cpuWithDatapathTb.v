//OLD NAME: memoryTb.v
module cpuWithDatapathTb();
wire clk, reset, nextStateButton;
wire[9:0] leds;
wire [6:0] readData, writeData;


cpuWithDatapath uut(clk, reset, nextStateButton,
	leds,
	readData, writeData);

always #20
	clk = !clk;

initial begin
	clk = 1'b0;

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
	$display("Read data: %b",readData);
	$display("Write data: %b",writeData);
	#200;
	nextStateButton = 1'b0;
	#200;
	nextStateButton = 1'b1;
	$display("Read data: %b",readData);
	$display("Write data: %b",writeData);
	#200;
	nextStateButton = 1'b0;
	#200;
	nextStateButton = 1'b1;
	$display("Read data: %b",readData);
	$display("Write data: %b",writeData);
	#200;
	nextStateButton = 1'b0;
	#200;
	nextStateButton = 1'b1;
	$display("Read data: %b",readData);
	$display("Write data: %b",writeData);
end

endmodule 
