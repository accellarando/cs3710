`timescale 1ns / 1ps

module final_cpu_tb();
	/* Inputs */
	/*
	cpu uut (
		clk,
		reset,
		switches,
		leds
	);
	
	initial begin
		clk		<= 1'b0;
		reset		<= 1'b1;		// active-low reset
		#100;
		reset		<= 1'b0;
		#100;
		reset		<= 1'b1;
		#100;		
		

	end
	*/
	
	/* Generate clock */
	always #20 begin		// clock changes edge every 50 ns
		//clk = !clk;
	end

endmodule
