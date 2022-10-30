module instruction_reg
	(
		input inst_en, reset,
		input [15:0] ram1_out,
		output [15:0] instr_out
	);

	always @(posedge reset, posedge inst_en) begin
		if(~reset)
			ram2_out <= 0;
		else if (inst_en)
			ram2_out <= ram1_out;
		else
			ram2_out <= ram2_out;
			
	end

endmodule

// instruction_reg inst_reg(inst_en, ram1_out, reset, instr_out);

