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
	registerFile #(.SIZE(X), .REGBITS(X)) uut (
		.clk(clk)
		.reset(reset)
		.writeEn(writeEn)
		.writeData(writeData)
		.srcAddr(srcAddr)
		.dstAddr(dstAddr)
	);
	
	/* Initializing inputs */
	initial begin
		clk		<= 1'b0;
		reset		<= 1'b1;	// active-low reset
		writeEn	<= 1'b0;
		counter 	= 0;		// for switch-case block in testing different write-read values
		#100					// wait 100 ns for global reset to finish
	end
	
	/* Generate clock */
	always #50 begin
		clk = !clk;
	end
	
	/* Adding stimulus testing */
	always @(posedge clk) begin
		case(counter)
			1: begin
			end
			// last case: set coutner back to zero
			default : ;
		endcase
		
		counter <= counter++; // increment counter value each pos-edge of the clock to test cases subseqently
	
endmodule
	
	
	
	