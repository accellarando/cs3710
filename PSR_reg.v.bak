// register for condition codes going into ALU with enable signal
module PSR_reg
	(
	input reset, clk, en
	input [1:0] cond_group1, // 2 flags, C and F
	input [2:0] cond_group2, // 3 flags, L, Z, and N
	output reg [1:0] final_group1, 
	output reg [2:0] final_group2,
	);

	always @(posedge clk) begin
		if(reset)
			final_group1 <= 2'b00;
			final_group2 <= 3'b000;
		else
			begin
				if(en)
					final_group1 <= cond_group1;
					final_group2 <= cond_group2;
				else
					final_group1 <= final_group1;
					final_group2 <= final_group2;
			end
	end
endmodule 