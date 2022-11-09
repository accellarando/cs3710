`timescale 1ns / 1ns

/*
REGISTER FILE: Provide arguments and hold results by instantiating 16 16-bit registers(-) Immediate to be sign-extended before ALU (concatenation)
(-) Shifter
(-) Program counter register and immediate register (make sure you can change these later on)
(?) PSR = processor status register
(X) Decoder


@ 2 read ports	[output]:	Reads 2 args from register file to feed ALU
@ 1 write port [input]:		Writes back the result data
									Enables write to reg 
@ 2 addresses  [input]:		From decoded instruction word (mipscpu.v)
									Do not need independent write addr, one of the read addr is also the write addr (dual-port, bram.v)
*/	
module registerFile #(parameter SIZE = 16, REGBITS = 4) (	
	input								clk, reset,
	input 							writeEn,						// enable signal
	input[SIZE-1:0] 				writeData,					//	16-bit Data in
	input[REGBITS-1:0]			srcAddr, dstAddr,			// 4-bit wide read addresses	
	output reg[SIZE-1:0] 		readData1, readData2		// 16-bit Data out
	);
		
	
	reg [SIZE-1:0] regFile [(1<<REGBITS)-1:0]; // Declare sixteen 16-bit registers in register file 

	/* Reading relative path*/
	initial begin
	$display("Loading Register File...");
	
	/* ! CHANGE TO YOUR LOCAL PATH ! */
	//$readmemb("E:/3710/Group/cs3710/reg.dat", regFile);
	//$readmemb("C:/Users/bledy/OneDrive/Documents/GitHub/cs3710/reg.dat", regFile);
	$readmemb("/home/ella/Documents/School/CS3710/cpu/reg.dat", regFile);
	
	$display("Done with loading Register File\n"); 
	end
	

	/* Assigning */ 
	integer i;
	
	always @(posedge clk) begin
		if(!reset) begin
			// ?? all 16 registers are set to 16'b0
			for(i = 0; i < SIZE; i = i + 1) begin 
				regFile[i] <= 0;							
			end
		end
		else begin	
			if(writeEn) begin
				regFile[dstAddr] <= writeData;	// dstAddr is both read and write address (dual-port)
			end
		end
		readData1 <= regFile[dstAddr];			// read ports have data inputs
		readData2 <= regFile[srcAddr];
	end

endmodule 
