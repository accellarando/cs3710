module memoryTb();

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
	$display("...");
end

endmodule 