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
@ 1 write port [input]:		Writes back the result
									Enables write to reg 
@ 2 addresses  [input]:		From decoded instruction word (mipscpu.v)
									Do not need independent write addr, one of the read addr is also the write addr (dual-port, bram.v)
*/	
module registerFile #(parameter SIZE = 16, NUMREGS = 16) (
	// rf(clk, reset, pcIn, aluOut, srcOut, dstOut, d1, d2);
	
	input	clk, reset,
	input writeEn,
	input	[$clog2(NUMREGS)-1:0] srcAddr, dstAddr,
	input	[SIZE-1:0] writeData,	
	output [SIZE-1:0] readData1, readData2 
	
	// writeEn INPUT 					"regWrite" enable write = 1/0 -> program counter in pcIn
	// srcAddr, dstAddr INPUTS 	read addrs -> log2(16) = 4, REGBITS == 4 [3:0]
	);
 
	

	
	
	/*
	REGISTER
	@ Instantiate all 16-bit registers w/ the correct write-enable and reset inputs
	*/
	register #(.SIZE(mine_var)) r
	
	// (A) MUX2: 16-bit wide 2 to 1 selector mux for selecting either the value from
	//				the RegFile or an Immediate
 
 	// (B) MUX2: 16-bit wide 2 to 1 selector mux for selecting either the value from
	//				the RegFile ?

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
