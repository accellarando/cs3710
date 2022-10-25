module cpuWithAlu #(parameter SIZE=16, NUMREGS=16)
	(input clk, reset,
		input[4:0] switchesLeft,
		input[4:0] switchesRight,
		input plusButton, minusButton, 
			andButton, orButton, xorButton, 
			shlButton, shrButton,
		output[9:0] leds);
	wire[7:0] aluOp;
	reg[15:0] aluOut;
	
	//always block to figure out aluop
	always@(*) begin
		if(plusButton)
			aluOp = 8'b00000101;
		else if(minusButton)
			aluOp = 8'b00001001;
		else if(andButton)
			aluOp = 8'b00000001;
		else if(orButton)
			aluOp = 8'b00000010;
		else if(xorButton)
			aluOp = 8'b00000011;
		else if(shlButton)
			aluOp = 8'b10000101;
		else if(shrButton)
			aluOp = 8'b10000100;
	end
	alu mainAlu(aluOp, switchesLeft, switchesRight, aluOut, cond_group1, cond_group2);
	
	assign leds = aluOut[9:0];
	
endmodule  
