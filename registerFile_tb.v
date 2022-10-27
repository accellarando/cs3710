`timescale 1ns / 1ps

module registerFile_tb();
	/* Inputs */
	reg 			clk, reset;
	reg			writeEn;
	reg[15:0] 	writeData;
	reg[3:0] 	srcAddr, dstAddr;
	integer 		counter;
	
	/* Outputs */
	wire[15:0] 	readData1, readData2;
	
	/* Outputs */
	/* Instantiate the Unit Under Test (UUT) */
	registerFile uut (
		.clk(clk),
		.reset(reset),
		.writeEn(writeEn),
		.writeData(writeData),
		.srcAddr(srcAddr),
		.dstAddr(dstAddr),
		.readData1(readData1),
		.readData2(readData2)
	);
	
	/* Initializing inputs */
	initial begin
		clk		<= 1'b0;
		reset		<= 1'b1;		// active-low reset
		#100;
		reset		<= 1'b0;
		#100;
		reset		<= 1'b1;
		writeEn	<= 1'b0;
		#100;						// toggle 100 ns for global reset to finish
		counter 	= 0;			// for switch-case block in testing different write-read values

	end
	
	/* Generate clock */
	always #50 begin		// clock changes edge every 50 ns
		clk = !clk;
	end
	
	/* Adding stimulus testing */
	// reference:	readData1 uses dstAddr
	// cases increment by 10's (for test bench simulation errors)
	always @(posedge clk) begin
		case(counter)
			// @ Writing to a register
			10: begin
				writeEn 		<= 1;
				dstAddr		<= 4'b0; srcAddr	<= 4'b0;	// write to register 1
				writeData	<= 16'd2;						// write 16-bit decimal 2 to register 1
			end
			
			20: begin
				$display("INITIALIZE -> Data-in = %b, Enable = %d, Register to write = %d\n", writeData, writeEn, dstAddr);
				$display("TRY -> write 2 to Register 0");
				
				if(readData1 == 16'd2)
					$display("SUCCESS: write/read to Register 0\n");
				else
					$display("FAILURE: write/read to Register 0 -> EXPECTED = %b, ACTUAL %b\n", 16'd2, readData1);
			end
			
			//---------------------------FIX CASES
			
			// @ Re-write to Register 1 
//			30: begin
//				$display("INITIALIZE -> Data-in = %b, Enable = %d, Register to write = %d\n", writeData, writeEn, dstAddr);
//				$display("TRY -> rewrite 2 to Register 0");
//				
//				if(readData1 == 16'd2)
//					$display("SUCCESS: write/read to Register 0\n");
//				else
//					$display("FAILURE: write/read to Register 0 -> EXPECTED = %b, ACTUAL %b\n", 16'd2, readData1);
//			end
//			
//			// @ Reset registers 
//			40: begin
//				$display("INITIALIZE -> Data-in = %b, Enable = %d, Register to write = %d\n", writeData, writeEn, dstAddr);
//				$display("TRY -> rewrite 2 to Register 0");
//				
//				if(readData1 == 16'd2)
//					$display("SUCCESS: write/read to Register 0\n");
//				else
//					$display("FAILURE: write/read to Register 0 -> EXPECTED = %b, ACTUAL %b\n", 16'd2, readData1);
//			end
			
			default : ;
		endcase
	
		counter <= counter + 1; // increment counter value each pos-edge of the clock to test cases subseqently
	end

endmodule
