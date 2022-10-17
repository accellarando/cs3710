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
module registerFile #(parameter SIZE = 16, NUMREGS = 16) (	
	input								clk, reset,
	input 							writeEn,						// enable signal
	input[SIZE-1:0] 				writeData,					//	16-bit Data in
	input[$clog2(NUMREGS)-1:0] srcAddr, dstAddr,			// 4-bit wide read addresses	
	output[SIZE-1:0] 				readData1, readData2		// 16-bit Data out
	);
 
	// sixteen 16-bit registers
	
	// two 16:1 16-bit wide mux
	//		read addrs (src/dst) are the mux's selector inputs
	//		mux's output (readData1/2) is input for alu
	
	// clock signal is ANDed w/ the enable signal
	
	// OUTSIDE OF REG: 2 mux for immediate
	
	/*
	REGISTER
	@ Instantiate all 16-bit registers w/ the correct write-enable and reset inputs
	*/
	register #(.SIZE(mine_var)) r
	
endmodule 


//REFERENCE
//----------------------------------------------------------------
module register #(parameter SIZE=16)
	(input reset, clk,
	input [SIZE-1:0] d, //data in
	output reg [SIZE-1:0] q); //data out

	//data only written on posedge of clock
	always @posedge(clk) begin //? @(posedge clk)
		if(reset)
			q = 0;	//active low?
		else
			q = d;	// data out = data in
	end
endmodule 

//----------------------------------------------------------------
module mux2 #(parameter WIDTH=16)(
	input s, 
	input [WIDTH-1:0] in1, in2,
	output [WIDTH-1:0] out);
	
	assign out = s ? in2 : in1;
endmodule
