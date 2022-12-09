`timescale 1ns / 1ps

module laser_tb();
	reg clk, reset;
	wire[23:0] rgb;
	wire hSync, vSync, vgaBlank, vgaClk;
	reg[17:0] gpi;
	wire[17:0] gpo;
	reg[3:0] buttons;
	reg[9:0] switches;
	wire[9:0] leds;
	wire[41:0] sevseg;
	
	final_cpu uut (
		clk,
		reset,
		rgb,
		hSync, vSync, vgaBlank, vgaClk,
		gpi, gpo,
		buttons, switches, leds, sevseg
	);
	
	initial begin
		clk		<= 1'b0;
		reset		<= 1'b1;		// active-low reset
		#100;
		reset		<= 1'b0;
		#100;
		reset		<= 1'b1;
		#100;
		gpi 		<= 18'b0;
		#10000;
		gpi 		<= 18'b100; //trigger A
		#10000;
		gpi		<= 18'b1100; //trigger B, A still triggered
		#10000;
		gpi 		<= 18'b0; //release both
	end
	
	
	/* Generate clock */
	always #20 begin		// clock changes edge every 50 ns
		clk = ~clk;
	end

endmodule
