// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module bram
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
(
	input [(DATA_WIDTH-1):0] data_a, data_b, addr_a, addr_b,
	input clk, we_a, we_b,
	
	output [15:0] q_a,
	output reg [(DATA_WIDTH-1):0] q_b,

	input [17:0] gpi, 
	output reg[17:0] gpo,
	input[3:0] buttons,
	input[9:0] switches,
	output reg[9:0] leds
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0]; // possibly switch to 0:2**ADDR_WIDTH - 1
	initial begin
		$display("Loading memory...");
		//$readmemb("D:/3710/Project/cs3710/ram.dat", ram); //change to correct path to .dat file
		//$readmemb("/home/ella/Documents/cpu/ram.dat",ram);
		//$readmemb("/home/ella/Documents/School/CS3710/cpu/ram.dat",ram);
		$readmemb("/home/emoss/Documents/cs3710/ram.dat",ram);
		$display("Done.");
	end
	reg[15:0] io, mem;
	
	always @ (negedge clk) begin
		case(addr_a)
			16'hFFFF: begin
				if(we_a)
					gpo[17:2] <= data_a;
				io <= gpi[17:2];
			end
			16'hFFFE: begin
				if(we_a)
					gpo[1:0] <= data_a;
				io[1:0] <= gpi[15:14];
				io[15:2] <= 14'b0;
			end
			16'hFFFD: io[15:12] <= buttons;
			16'hFFFC: begin
				if(we_a)
					leds <= data_a[15:6];
				io[15:6] <= switches;
				io[5:0] <= 6'b0;
			end
		endcase
	end
				
	assign q_a = (addr_a >= 16'hFFFC) ? io : mem;

	// Port A - for the cpu itself.
	// All memory mapped IO happens here.
	always @ (negedge clk) begin
		if(we_a)
			ram[addr_a] <= data_a;
		mem <= ram[addr_a];
	end 

	// Port B 
	always @ (negedge clk) begin
		if (we_b) begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
			q_b <= ram[addr_b];
	end 

endmodule
