// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module bram
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
(
	input [(DATA_WIDTH-1):0] data_a, data_b, addr_a, addr_b,
	input clk, we_a, we_b,

	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

// Declare the RAM variable
reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0]; // possibly switch to 0:2**ADDR_WIDTH - 1
initial begin
	$display("Loading memory...");
	//$readmemb("D:/3710/Project/ram_old.dat", ram); //change to correct path to .dat file
	$readmemb("/home/ella/Documents/School/CS3710/cpu/ram.dat",ram);
	$display("Done.");
end


// Port A - for the cpu itself.
// All memory mapped IO happens here.
always @ (posedge clk) begin
	if (we_a)
		ram[addr_a] <= data_a; 
	q_a <= ram[addr_a];
end 

// Port B 
always @ (posedge clk) begin
	if (we_b)
		ram[addr_b] <= data_b;
	q_b <= ram[addr_b];
end 

endmodule
