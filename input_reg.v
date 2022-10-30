module input_reg
	(
		input clk, reset,
		input [7:0] d,
		output [15:0] q
	)
	
	always @(posedge clk, posedge reset) begin
		if(~reset)
			q <= 0;
		else
			q <= d;
	end
	
	
endmodule

// input_reg input_reg(clk, reset, switches, inputs_received);

