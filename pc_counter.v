// register/ counter for PC
module pc_counter
	(input clk, reset, en,
	input [15:0] q
	output reg [15:0] q_out
	);

	always @(posedge clk) begin
		if(reset) begin
			q_out <= 16'd0;
		end
		else
			begin
				if(en) begin
					q_out <= q;
				end
				else begin
					q_out <= q_out;
				end
			end
	end
endmodule 