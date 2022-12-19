module mux2 #(parameter WIDTH=16)(
	input s, 
	input [WIDTH-1:0] in1, in2,
	output [WIDTH-1:0] out);
	
	assign out = s ? in2 : in1;
endmodule