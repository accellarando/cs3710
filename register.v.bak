module register #(parameter SIZE=16)
	(input reset, clk,
	input [SIZE-1:0] d, 
	output reg [SIZE-1:0] q);

	always @posedge(clk) begin
		if(reset)
			q = 0;
		else
			q = d;
	end
endmodule 