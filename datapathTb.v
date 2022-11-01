module datapathTb();
	wire clk, reset,
		MemW1en, MemW2en, RFen, PSRen,
		Movm;
	wire[1:0] PCm, A2m, RWm,
		flags1out;
	wire[3:0] AluOp;
	wire[9:0] switches;
	wire[15:0] PC, AluOut, 
		RFwrite, RFread1, RFread2,
		MemWrite1, MemWrite2, MemRead1, MemRead2;
	wire[2:0] flags2out;
	wire[9:0] leds;
	
	
	datapath uut(clk, reset,
		MemW1en, MemW2en, RFen, PSRen,
		Movm,
		PCm, A2m, RWm,
		AluOp,
		switches,
		PC, AluOut,
		RFwrite, RFread1, RFread2,
		MemWrite1, MemWrite2, MemRead1, MemRead2,
		flags1out, flags2out,
		leds);
	
	always #20
		clk = !clk;
		
	initial begin
		clk = 1'b0;
		reset = 1'b1;
		MemW1en = 1'b0;
		MemW2en = 1'b0;
		RFen = 1'b0;
		PSRen = 1'b0;
		Movm = 1'b0;
		PCm = 2'b0;
		A2m = 2'b0;
		RWm = 2'b0;
		AluOp = 4'b0;
		#200;
		reset = 1'b0;
		#200;
		reset = 1'b1;
		#200
		//Test datapath for ADD
		RWm = 2'b10; //aluout
		Movm = 1'b1;
		$display("AluOut for add: %b",AluOut);
		#200;
		//Test datapath for ADDI
		
	end
endmodule 