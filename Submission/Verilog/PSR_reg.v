// register for condition codes going into ALU with enable signal
module PSR_reg
	(input reset, clk, en,
	input [1:0] cond_group1, // 2 flags, C and F
	input [2:0] cond_group2, // 3 flags, L, Z, and N
	//what we see at the output
	output reg [1:0] final_group1, 
	output reg [2:0] final_group2
	);

	always @(posedge clk) begin
		//if active low reset, reset flags to 0
		if(!reset) begin
			final_group1 <= 2'b00;
			final_group2 <= 3'b000;
		end
		else
			begin
				//if enabled, update the output
				if(en) begin
					final_group1 <= cond_group1;
					final_group2 <= cond_group2;
				end
				else begin
					final_group1 <= final_group1;
					final_group2 <= final_group2;
				end
			end
	end
endmodule 
