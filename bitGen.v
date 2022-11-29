module bitGen(
	input clk, bright,
	input [9:0] hCount,
	input [9:0] vCount,
	input [7:0] count,
	output reg[23:0] rgb);
	
	parameter BG = 24'h111111;

	always@(posedge clk) begin
		if(bright)
			rgb <= BG;
	end
endmodule 