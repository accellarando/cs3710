module cpuWithAlu #(parameter SIZE=16, NUMREGS=16)
	(input clk, reset,
		input[4:0] switchesLeft,
		input[4:0] switchesRight,
		input plusButton, minusButton, 
			andButton, orButton, xorButton, 
			shlButton, shrButton,
		output[9:0] leds);
	reg[3:0] aluOp;
	wire[15:0] aluOut;
	
	//always block to figure out aluop
	parameter AND		=	4'b0000;
	parameter OR		=	4'b0001;
	parameter XOR 		= 	4'b0010;
	parameter ADD 		= 	4'b0011;
	parameter SUB		=	4'b0100;
	parameter NOT 		= 	4'b0101;
	parameter SLL 		= 	4'b0110; 	// shift Left logical
	parameter SRL 		= 	4'b0111;
	always@(*) begin
		if(plusButton)
			aluOp = ADD;
		else if(minusButton)
			aluOp = SUB;
		else if(andButton)
			aluOp = AND;
		else if(orButton)
			aluOp = OR;
		else if(xorButton)
			aluOp = XOR;
		else if(shlButton)
			aluOp = SLL;
		else if(shrButton)
			aluOp = SRL;
	end
	alu mainAlu(aluOp, switchesLeft, switchesRight, aluOut, cond_group1, cond_group2);
	
	assign leds = aluOut[9:0];
	
endmodule  
