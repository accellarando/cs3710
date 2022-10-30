// Writing inputs/outputs for calling modules:   ORDER MATTERS! 
//	If calling FSM: (clk, reset, etc.), FSM module must instantiate in that order: input clk, reset, etc.

module part2top() 
	(
		input clk, reset,
		input [7:0] switches,
		output led0, led1, led2, led3
	);

wire [15:0] PC, PC_next, PC_mux, PC_addr1, PC_addr2, PC_data1, PC_data2, ram1_out, ram2_out, alu_bus_data, 
				instr_out, regfile_en, alu_bus, mux1_out, mux2_out, alu_b, alu_immed, alu_mux_out, inputs_received,
				demo_reg1; // testbench will demo reg1 of the 2-D register array (16, 16-bit registers, reg0-reg15)
				
wire 			PC_count_en, PC_en, ram1_en, ram2_en, mem_en, addr_en, flag_en, inst_en, rDest_en, bux_mux_en, 
				alu_mux_en, writeback_en, cin;
				
wire [1:0] inst_type;
wire [4:0] flags, flags_out, mux1_en, mux2_en, rDest_in, mux_1_en, mux_2_en;
wire [7:0] opcodes;
reg [15:0] registers [0:15];

/* FSM
	Update as datapath develops:
	Inputs: clk, reset, writeback_en, inst_type
	Outputs: addr_en, alu_mux_en, bus_mux_en, rDest_en, PC_en, mem_en, inst_en, flag_en, ram1_en, PC_count_en
*/
FSM fsm(clk, reset, writeback_en, inst_type, addr_en, alu_mux_en, bus_mux_en, rDest_en, PC_en, mem_en, inst_en, flag_en, ram1_en, PC_count_en);

/* Reg file
	Will contain:
	a regfile formatter (takes the ALU bus and input to ALU, then 
	outputs ro-15 to be used for rest of module
	
	4 muxes (one for inputs, one for BUS, one for r0-r15 from mux1_en, one for r0-r15 from mux2_en),
	
	flag register
	
	ALU

	Update as datapath develops:
	Inputs:
	Outputs: alu_out, flags
*/
alu alu1(opcodes, mux1_out, alu_mux_out, alu_out, flags_out,  flags);

/* Decoder

	Update as datapath develops:
	Inputs: flags, inst_type
	Outputs: opcodes, mux_1_en, mux_2_en, writeback_en, inst_type
*/
decoder decode (flags_out, instr_out, rDest_in, alu_immed, opcodes, mux1_en, mux2_en, writeback_en, inst_type);


PC_data2 = 16'h0;
ram2_en = 1'h0;
bram ram(PC_addr1, PC_addr2, PC_data1, PC_data2, ram1_en, ram2_en, clk, ram1_out, ram2_out);



// increment --> mux --> pc counter --> loops, with output also going to: PC memory mux and address mux
pc_increment pc_inc(PC, 1'b0, PC_next);

// PC count enable will be output from FSM to decide PC_next or immd to output, then go to PC reg
mux2 pc_count_mux(PC_count_en, PC_next, mux2_out, PC_mux);

pc_counter pc_count(clk, reset, PC_en, PC_mux, PC);


PSR_reg flags_reg(reset, clk, flag_en, flags, flags_out);

// 4-bit to 16-bit decoder
decoder_reg decode_reg(rDest_en, rDest_in, input_out, regfile_en);

// *** needs inputs from switches [7:0], then output the result in 16-bit form! (input_out) ***
// input_out goes into regfile
// similar to our register.v, but [7:0] input instead of [15:0] input
input_reg input_reg(clk, reset, switches, inputs_received);

// similar to our register.v, but without clock --> posedge of inst_en, posedge of reset
instruction_reg inst_reg(inst_en, reset, ram1_out, instr_out);


mux2 address_mux(addr_en, mux2_out, PC, PC_addr1);

mux2 memory_mux(mem_en, ram1_out, PC, alu_bus_data);

mux2 bus_mux(bus_mux_en, alu_out, alu_bus_data, alu_bus);

mux2 alu_mux(alu_mux_en, alu_b, alu_immed, alu_mux_out);


regfile registering(	clk, reset, mux1_en, mux2_en, regfile_en, alu_bus, inputs_received, demo_reg1
							mux1_out, mux2_out); // dont think we need to output registers, but can do so with "registers" wire
						
hexTo7Seg hexseg0(demo_reg1[3:0], reset, led0);
hexTo7Seg hexseg0(demo_reg1[7:4], reset, led1);
hexTo7Seg hexseg0(demo_reg1[11:8], reset, led2);
hexTo7Seg hexseg0(demo_reg1[15:12], reset, led3);

endmodule
