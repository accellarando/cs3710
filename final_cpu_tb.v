`timescale 1ns / 1ps

module final_cpu_tb();
	reg clk, reset;
	wire[23:0] rgb;
	wire hSync, vSync, vgaBlank, vgaClk;
	reg[17:0] gpi;
	wire[17:0] gpo;
	reg[3:0] buttons;
	reg[9:0] switches;
	wire[9:0] leds;
	integer counter;
	
	final_cpu uut (
		clk,
		reset,
		rgb,
		hSync, vSync, vgaBlank, vgaClk,
		gpi, gpo,
		buttons, switches, leds
	);
	
	initial begin
		clk		<= 1'b0;
		reset		<= 1'b1;		// active-low reset
		#100;
		reset		<= 1'b0;
		#100;
		reset		<= 1'b1;
		#100;
		switches <= 10'b101010101;
		#200;
		switches <= 10'b101010101;
	end
	
	
	/* Generate clock */
	always #20 begin		// clock changes edge every 50 ns
		clk = ~clk;
		if(!hSync) 
			counter <= counter + 1'b1;
		else
			counter <= 0;
	end
	
	always@(posedge hSync)
		$display(counter);

endmodule
