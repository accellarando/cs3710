`timescale 1ns / 1ps
/*
REGISTER FILE: Provide arguments and hold results by instantiating 16 16-bit registers

(-) Immediate to be sign-extended before ALU (concatenation)
(-) Shifter

(-) Program counter register and immediate register (make sure you can change these later on)

(?) PSR = processor status register
(X) Decoder
*/
//-----------------------------------
/*
@ 2 read ports	[output]:	Reads 2 args from register file to feed ALU
@ 1 write port [input]:		Writes back the result data
									Enables write to reg 
@ 2 addresses  [input]:		From decoded instruction word (mipscpu.v)
									Do not need independent write addr, one of the read addr is also the write addr (dual-port, bram.v)
*/	
module registerFile #(parameter SIZE = 16, REGBITS = 4) (	
	input								clk, reset,
	input 							writeEn,						// enable signal
	input[SIZE-1:0] 				writeData,					//	16-bit Data in
	input[REGBITS-1:0]			srcAddr, dstAddr,			// 4-bit wide read addresses	
	output reg[SIZE-1:0] 		readData1, readData2		// 16-bit Data out
	//	registerFile #(SIZE, REGBITS) rf(clk, reset, pcOut, aluOut, srcOut, dstOut, d1, d2);
	);
	
	// ! Adding Decoder later assignment!
	
	reg [SIZE-1:0] registerFile [REGBITS-1:0]; // Declare registers in register file 
	
	/* Option: reading relative path*/
	initial begin
	$display("Loading register file");
	$readmemb("/home/ella/Documents/School/CS3710/cpu/reg.dat", registerFile); 
	$display("done with RF load"); 
	end
	
	
	/* Option: manually initualized */
	/*
	generate
		for (genvar i = 0; i < SIZE; i++) begin
			registerFile[i] = 0;
		end
	endgenerate
	*/

	/* assigning */
	always @(posedge clk) begin
		if(reset) begin
			readData1 <= 16'b0; //do something here ig?
			readData2 <= 16'b0;
		end
		else begin	
			if (writeEn) begin
				readData1 <= registerFile[srcAddr];
				readData2 <= registerFile[dstAddr];
			end
		end
	end

/*
   always @(posedge clk) begin
      if (reset) begin
            for (i = 0; i < 8; i = i + 1) begin
                regfile[i] <= 0;
            end
      end else begin
            if (write) regfile[wrAddr] <= wrData;
      end // else: !if(reset)
   end
	
	//assign enabledReg = {NUMREGS{writeEn}} & writeData; // -> need to put enableReg into registers? and clk?
	
	always @(posedge clk) begin
		if(reset)
			// registers = 0
		else
	

	
	always @(negedge clk) begin
    rdDataA <= regfile[rdAddrA];
    rdDataB <= regfile[rdAddrB];
end
			
	register #(SIZE) r(reset, clk, x, y);

	// two 16:1 16-bit wide mux (mux for each read port)
	//		read addrs (src/dst) are the mux's selector inputs
	//		mux's output (readData1/2) is input for alu
	mux2 #(
	
	
	
	// OUTSIDE OF REG: mux for immediate extend
	
	/*
	REGISTER
	@ Instantiate all 16-bit registers w/ the correct write-enable and reset inputs
	
	//d1 d2
	assign register #(.SIZE(mine_var)) r
	assign readData1 = */
endmodule 
