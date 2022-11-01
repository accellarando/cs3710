module mux4 #(parameter WIDTH=16)(
<<<<<<< HEAD
	input[1:0] s, 
	input[WIDTH-1:0] a, b, c, d,
=======
	input[1:0] s,
	input[WIDTH-1:0] a, b, c,d,
>>>>>>> 60c9d5cc39c5e032e0aca7aa64dfa7c82db1eb05
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