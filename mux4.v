module mux4 #(parameter WIDTH=16)(
	input[1:0] s,
	input[WIDTH-1:0] a, b, c,d,
	output reg[WIDTH-1:0] out);
	
	always@(*) begin
		case(s)
			2'b0:  out <= a;
			2'b1:  out <= b;
			2'b10: out <= c;
			2'b11: out <= d;
			default: out <= a;
		endcase
	end
endmodule 