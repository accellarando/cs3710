// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module bram
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16)
(
	input [(DATA_WIDTH-1):0] data_a, data_b, addr_a, addr_b,
	input clk, we_a, we_b,
	
	output reg [(DATA_WIDTH-1):0] q_a, q_b
	//output reg[15:0] ex_outputs
	// removed ex_outputs and ex_inputs
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0]; // possibly switch to 0:2**ADDR_WIDTH - 1
	initial begin
		$display("Loading memory...");
		//$readmemb("D:/3710/Project/ram_old.dat", ram); //change to correct path to .dat file
		$readmemb("/home/ella/Documents/School/CS3710/cpu/ram.dat",ram);
		$display("Done.");
	end

	
	
	
	// ** UPDATE: If not working, only thing would be an initial begin block to initialize
	//		BRAM to all zeros or with initial values. ***
	
	
	
	
	
	
	// *** BRAM problem: in always block below: a if, else, else statement. Logic never seen.
	
	
	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) begin
		// removed if statement:  if(addr_a[(ADDR_WIDTH-1):(ADDR_WIDTH-4)] == 4'hF) begin

			//writing to external
			ram[addr_a] <= data_a; //this was yelling at us, idk dude
			q_a <= data_a;
		end
		else begin
				q_a <= ram[addr_a];
		end
//		else begin
//			//// removed if statement:  if(addr_a[(ADDR_WIDTH-1):(ADDR_WIDTH-4)] == 4'hF) begin
//			if(addr_a[(ADDR_WIDTH-1):(ADDR_WIDTH-4)] == 4'hF)
//				q_a <= ex_inputs;
//			else
//				q_a <= ram[addr_a];
//		end 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) begin
//			if(addr_b[(ADDR_WIDTH-1):(ADDR_WIDTH-4)] == 4'hF) begin
				//writing to external
				//ex_outputs <= data_b;
//				q_b <= ex_inputs;
//			end
//			else begin
				ram[addr_b] <= data_b;
				q_b <= data_b;
//			end
		end
		else begin
//			if(addr_b[(ADDR_WIDTH-1):(ADDR_WIDTH-4)] == 4'hF)
//				q_b <= ex_inputs;
//			else
				q_b <= ram[addr_b];
		end 
	end 
	
	
	
	/*
	always @ (posedge clk)
	begin
		if (we_b) begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else begin
			q_b <= ram[addr_b];
		end 
	end
	*/

endmodule
