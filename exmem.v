module exmem #(parameter DATA_WIDTH=16, parameter ADDR_WIDTH= 16)
        (
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] addr,
	input                    we, clk,
	output [(DATA_WIDTH-1):0] q
        );
	// wire Switch;	//me
	// wire LED;		//me

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Variable to hold the read address
	reg [ADDR_WIDTH-1:0] addr_reg;

        // The $readmemb function allows you to load the
        // RAM with data on initialization to the FPGA
        // you'll need to update the path to this file
        // for your own location. 
	initial begin
	$display("Loading memory");
	$readmemb("C:/Users/bledy/OneDrive/Documents/ECE 3710/Mini MIPS/fib-b.dat", ram);
	$display("done loading");
	end

	always @ (posedge clk)
	begin
		// Write
		if (we) ram[addr] <= data;
			 
       // register to hold the read address
		addr_reg <= addr;
	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign q = ram[addr_reg]; 
	

endmodule