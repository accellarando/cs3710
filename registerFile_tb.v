`timescale 1ns / 1ps

module registerFile_tb();
	/* Inputs */
	reg 			clk, reset;
	reg			writeEn;
	reg[15:0] 	writeData;
	reg[3:0] 	srcAddr, dstAddr;
	
	/* Outputs */
	wire[15:0] 	ReadData1, ReadData2;
	integer counter;
	
	/* Instantiate the Unit Under Test (UUT) */
	registerFile #(.SIZE(16), .REGBITS(4)) uut (
		.clk(clk),
		.reset(reset),
		.writeEn(writeEn),
		.writeData(writeData),
		.srcAddr(srcAddr),
		.dstAddr(dstAddr)
	);
	
	/* Initializing inputs */
	initial begin
		clk		<= 1'b0;
		reset		<= 1'b1;	// active-low reset
		writeEn	<= 1'b0;
		counter 	= 0;		// for switch-case block in testing different write-read values
		#100;					// wait 100 ns for global reset to finish
	end
	
	/* Generate clock */
	always #50 begin		// clock changes edge every 50 ns
		clk = !clk;
	end
	
	/* Adding stimulus testing */
	// reference:	readData1 uses dstAddr
	//					readData2 uses srcAddr
	always @(posedge clk) begin
				$display("\n");
		case(counter)
			// ??? put #time each case -> longer time than generate clock

			
			// @ Writing to a register
			1: begin
				writeEn 		<= 1;
				dstAddr		<= 4'b1; srcAddr	<= 4'b1;	// write to register 1
				writeData	<= 16'd2;						// write 16-bit decimal 2 to register 1
			end
			2: begin
				if(readData1 == 16'd2)
					$display("SUCCESS: write/read to register 1");
				else
					$display("FAILURE: write/read to register 1 -> EXPECTED = %b, ACTUAL %d", 16'd2, readData1);
			end
			
			// last case: set coutner back to zero
			
			default : ;
		endcase;
	
		counter <= counter + 1; // increment counter value each pos-edge of the clock to test cases subseqently
	end
	
endmodule
	
	
	
	