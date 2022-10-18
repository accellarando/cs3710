`timescale 1ns / 1ps
/*
REGISTER FILE: Provide arguments and hold results by instantiating 16 16-bit registers

(-) Immediate to be sign-extended before ALU (concatenation)
(-) Shifter

(-) Program counter register and immediate register (make sure you can change these later on)

(?) PSR = processor status register
(X) Decoder
*/
//-----------------------------------
/*
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
	
	//	registerFile #(SIZE, REGBITS) rf(clk, reset, pcOut, aluOut, srcOut, dstOut, d1, d2);
	);
		
	
	reg [SIZE-1:0] regFile [(1<<REGBITS)-1:0]; // Declare sixteen 16-bit registers in register file 

	/* Reading relative path*/
	initial begin
	$display("Loading register file");
	$readmemb("E:/3710/GroupProject/cs3710/reg.dat", regFile); // ! CHANGE TO YOUR LOCAL PATH !
	$display("Done with loading register file"); 
	end
	

	/* Assigning */
	always @(posedge clk) begin
		if(reset) begin
			// ?? all 16 registers are set to 16'b0
			for(integer i = 0; i < SIZE; i = i + 1) begin 
				regFile[i] <= 0;							
			end
		end
		else begin	
			if(writeEn) begin
				readData1 <= regFile[dstAddr];
				readData2 <= regFile[srcAddr];
			end
		end
	end

endmodule 
