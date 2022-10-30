// Increments before heading into PC mux, then PC counter
module pc_increment (PC, offset, PC_next);
	input [15:0] pC,
	output [15:0] PC_next;
	
	// if offset high ==> PC subtraction/decrement
	//	otherwise ==> PC addition/increment
	assign PC_next = (offset == 1'b1) ? (PC - 16'b1) : (PC + 16'1);
	
endmodule
