/*** Register with an enable signal.
 * Used throughout the datapath and processor.
 * Author: Ella Moss
 */
module en_register #(parameter SIZE=16)
	(input reset, clk, en,
	input [SIZE-1:0] d, 
	output reg [SIZE-1:0] q);

	always @(posedge clk) begin
		if(~reset)
			q <= 16'b0;
		else if(en)
			q <= d;
		else
			q <= q; //prevent latches
	end
endmodule 
