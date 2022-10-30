module regfile 
	(
		input clk, reset, mux1_en, mux2_en,
		input [4:0] regfile_en,
		input [15:0] alu_bus, inputs_received,
		output [15:0] demo_reg1, mux1_out, mux2_out
		//output [15:0] registers [0:15];
	);
	
	wire [15:0] registers [0:15];
	// some always clk on doing these below, do later

reg_mux_1 mux_1(registers, mux1_en, mux2_out)

reg_mux_2 mux_2(registers, mux2_en, mux2_out);

	
	
	
endmodule
	