// register for flags going into ALU with enable signal
module PSR_reg
	(input reset, clk, en,
	input [4:0] flags, // 5 flags, C, F, L, Z, N
	output reg [4:0] flags_out
	);

	always @(posedge clk) begin
		if(reset) begin
			flags <= 5'b00000;
		end
		else
			begin
				if(en) begin
					flags_out <= flags;
				end
				else begin
					flags_out <= flags_out;
				end
			end
	end
	
endmodule 