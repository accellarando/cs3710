`timescale 1ns / 1ps

module registerFile_tb();
	/* Inputs */
	reg 			clk, reset;
	reg			writeEn;
	reg[15:0] 	writeData;
	reg[3:0] 	srcAddr, dstAddr;
	
	/* Outputs */
	wire[15:0] 	ReadData1, ReadData2;
	
	/* Instantiate the Unit Under Test (UUT) */
	registerFile #(.SIZE(), .REGBITS()) uut (
		.clk(clk)
		.reset(reset)
		.writeEn(writeEn)
		.writeData(writeData)
		.srcAddr(srcAddr)
		.dstAddr(dstAddr)
	);
	
	