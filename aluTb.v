`timescale 1ns / 1ps

module aluTb();
reg clk, reset;
integer counter;

reg cIn;
reg[7:0] aluOp, aluIn1, aluIn2;
wire[15:0] aluOut;
//wire[1:0] cond_group1;
wire cond_group1;
wire[2:0] cond_group2;
wire[4:0] conds;

reg writeEn;
reg[15:0] writeData;
reg[3:0] srcAddr, dstAddr;
wire[15:0] readData1, readData2;

/*
module alu #(parameter WIDTH = 16)
            (	input 		[WIDTH-9:0] aluOp,
					input     	[WIDTH-9:0] aluIn1, aluIn2, 
					input	cIn,
					output reg [WIDTH-1:0] aluOut,
					output reg [1:0] cond_group1,	
					output reg [2:0] cond_group2,			
	    );
*/

alu uutAlu(aluOp, aluIn1, aluIn2,
	aluOut,
	cond_group1,
	cond_group2);

assign conds = {cond_group2,cond_group1};
/*
module registerFile #(parameter SIZE = 16, NUMREGS = 16) (	
	input								clk, reset,
	input 							writeEn,						// enable signal
	input[SIZE-1:0] 				writeData,					//	16-bit Data in
	input[$clog2(NUMREGS)-1:0] srcAddr, dstAddr,			// 4-bit wide read addresses	
	output[SIZE-1:0] 				readData1, readData2		// 16-bit Data out
	);
*/

registerFile uutRf(clk, reset, writeEn,
	writeData, srcAddr, dstAddr,
	readData1, readData2);

initial begin
	reset = 1'b1; //remember it's active-low reset
	#200;
	reset = 1'b0;
	#200;
	reset = 1'b1;
	counter = 0;
	clk = 1'b0;
	aluOp = 8'b0;
	aluIn1 = 8'b0;
	aluIn2 = 8'b0;
	writeEn = 1'b0;
	writeData = 16'b0;
	srcAddr = 4'b0;
	dstAddr = 4'b0;
end

always #200 begin
	clk = !clk;
end

always@(posedge clk) begin
	$display("aluOp: %b, aluIn1: %b, aluIn2: %b, aluOut: %b, conds: %b",
		aluOp, aluIn1, aluIn2, aluOut, conds);
<<<<<<< Updated upstream
//	$display("writeEn: %b, writeData: %b, srcAddr: %b, dstAddr: %b, readData1: %b, readData2: %b",
	//	writeEn, writeData, srcAddr, dstAddr, readData1, readData2);
=======
	$display("writeEn: %b, writeData: %b, srcAddr: %b, dstAddr: %b, readData1: %b, readData2: %b",
		writeEn, writeData, srcAddr, dstAddr, readData1, readData2);
>>>>>>> Stashed changes
	//$display("%b %d",counter,counter);
	case(counter)
		1: begin
			//and
			aluOp <= 8'b00010000;
			aluIn1 <= 8'b10101010;
			aluIn2 <= 8'b11011101;
			//cin <= 8'b0;
			$display("Testing AND...\n");
		end
		2: begin
			if(aluOut != 8'b10001000 || conds != 5'b0)
				$display("ERROR IN AND: Expected aluOut = 10001000, conds = 00000, got %d, %d \n",
					aluOut, conds);
		end
		3: begin
			aluIn1 <= 8'b11111111;
			aluIn2 <= 8'b00000000;
		end
		4: begin
			if(aluOut != 8'b0 || conds != 5'b01000)
				$display("ERROR IN AND: Expected aluOut = 0000000, conds = 01000, got %d, %d\n",
					aluOut, conds);
		end
		5: begin
			aluOp <= 8'b00100000;
			aluIn1 <= 8'b10101010;
			aluIn2 <= 8'b01010101;
			$display("Testing OR...\n");
		end
		6: begin
			if(aluOut != 8'b11111111 || conds != 5'b00000)
				$display("ERROR IN OR: Expected aluOut = 11111111, conds = 00000, got %d, %d\n",
					aluOut, conds);
		end
		7: begin
			aluIn1 <= 8'b00000000;
			aluIn2 <= 8'b00000000;
		end
		8: if(aluOut != 8'b00000000 || conds != 5'b01000)
				$display("ERROR IN OR: Expected aluOut = 00000000, conds = 01000, got %d, %d\n",
					aluOut, conds);
		9: begin
			aluOp <= 8'b00110000;
			aluIn1 <= 8'b10001000;
			aluIn2 <= 8'b10001000;
			$display("Testing XOR...\n");
		end
		10: if(aluOut != 8'b0 || conds != 5'b01000)
				$display("ERROR IN XOR: Expected aluOut = 00000000, conds = 01000, got %d, %d\n",
					aluOut, conds);
		11: begin
			aluIn1 <= 8'b10110101;
			aluIn2 <= 8'b01100010;
		end
		12: if(aluOut != 8'b11010111 || conds != 5'b00000)
				$display("ERROR IN XOR: Expected aluOut = 11010111, conds = 00000, got %d, %d\n",
					aluOut, conds);
		13: begin
			aluOp <= 8'b01010000;
			$display("Testing ADD...\n");
		end
		14: if(aluOut != 8'b00010111 || conds != 5'b00010)
				$display("ERROR IN ADD: Expected aluOut = 00010111, conds = 00010, got %d, %d\n",
					aluOut, conds);
		15: begin
			aluIn1 <= 8'b00000011;
			aluIn2 <= 8'b00000011;
		end
		16: if(aluOut != 8'b00000110 || conds != 5'b00000)
				$display("ERROR IN ADD: Expected aluOut = 00000110, conds = 00000, got %d, %d\n",
					aluOut, conds);
		17: begin
			aluOp = 8'b10010000;
			$display("Testing SUB...\n");
		end
		18: if(aluOut != 8'b00000000 || conds != 5'b01000)
				$display("ERROR IN SUB: Expected aluOut = 00000000, conds = 01000, got %d, %d\n",
					aluOut, conds);
		19: begin
			aluIn1 <= 8'b00000000;
			aluIn2 <= 8'b00000001;
		end
		20: if(aluOut != 8'b11111111 || conds != 5'b00010)
				$display("ERROR IN SUB: Expected aluOut = 11111111, conds = 00010, got %d, %d\n",
					aluOut, conds);
		21: begin
			aluOp <= 8'b01100000;
			$display("Testing ADDU...\n");
		end
		22: if(aluOut != 8'b00000001 || conds != 5'b00000)
				$display("ERROR IN ADDU: Expected aluOut = 00000001, conds = 00000, got %d, %d\n",
					aluOut, conds);
		23: begin
			 aluIn1 <= 8'b01111111;
			 aluIn2 <= 8'b00000001;
		end
		24: if(aluOut != 8'b10000000 || conds != 5'b00000)
				$display("ERROR IN ADDU: Expected aluOut = 10000000, conds = 00000, got %d, %d\n",
					aluOut, conds);
		25: begin
			aluOp <= 8'b10110000;
			$display("Testing CMP...\n");
		end
		/*26: if(conds != 5'b00000)
				$display("ERROR IN CMP: Expected conds = 00000, got %d\n",
					conds);
		27: begin
			aluIn1 <= 8'b00000001;
			aluIn2 <= 8'b01111111;
		end
		28: if(conds != 5'b01010)
				$display("ERROR IN CMP: Expected conds = 01010, got %d\n",
					conds);
		29: begin
			aluIn1 <= 8'b00000001;
			aluIn2 <= 8'b00000001;
		end
		30: if(conds != 5'b00100)
				$display("ERROR IN CMP: Expected conds = 00100, got %d\n",
					conds);
		31: begin
			aluOp <= 8'b10000000;
			$display("Testing LSH...\n");
		end
		32: if(aluOut != 8'b00000010 || conds != 5'b00000)
				$display("ERROR IN LSH: Expected aluOut = 00000010, conds = 00000, got %d, %d\n",
					aluOut, conds);
		33: begin
			aluOp <= 8'b10000010;
			$display("Testing RSH...\n");
		end
		34: if(aluOut != 8'b00000000 || conds != 5'b00000)
				$display("ERROR IN RSH: Expected aluOut = 00000000, conds = 00000, got %d, %d\n",
					aluOut, conds);
		35: begin
			aluOp <= 8'b10001000;
			aluIn1 <= 8'b10000001;
			aluIn2 <= 8'b00000001;
			$display("Testing arithmetic LSH...\n");
		end
		36: if(aluOut != 8'b10000010 || conds != 5'b00000)
				$display("ERROR IN ARITH LSH: Expected aluOut = 10000010, conds = 00000, got %d, %d\n",
					aluOut, conds);
		37: begin
			aluOp <= 8'b10000111;
			$display("Testing arithmetic RSH...\n");
		end
		38: if(aluOut != 8'b10000000 || conds != 5'b00000)
				$display("ERROR IN ARITH RSH: Expected aluOut = 10000000, conds = 00000, got %d, %d\n",
					aluOut, conds);
		39: begin
			aluOp <= 8'b00001111;
			$display("Testing NOT...\n");
		end
		40: if(aluOut != 8'b01111110 || conds != 5'b00000)
				$display("ERROR IN NOT: Expected aluOut = 01111110, conds = 00000, got %d, %d\n",
					aluOut, conds);
		41: aluIn1 <= 8'b11111111;
		42: if(aluOut != 8'b0 || conds != 5'b01000)
				$display("ERROR IN RSH: Expected aluOut = 00000000, conds = 01000, got %d, %d\n",
					aluOut, conds);
		43: begin
			writeEn <= 1;
			writeData <= 8'b10101010;
			srcAddr <= 8'b1;
			dstAddr <= 8'b1;
		end
		44: if(readData1 != 8'b10101010)
<<<<<<< Updated upstream
			$display("ERROR IN RF: Expected readData1 = 10101010, got %d\n",readData1); */
=======
			$display("ERROR IN RF: Expected readData1 = 10101010, got %d\n",readData1);
>>>>>>> Stashed changes
		45: counter <= 0;
		default: ;
	endcase
	

	counter <= counter + 1;
end


endmodule
