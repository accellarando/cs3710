module alu #(parameter WIDTH = 16)
            (	input      [WIDTH-9:0] aluIn1, aluIn2, 
					input      [3:0]       aluCont, 
					input	cin,
					output reg [WIDTH-1:0] aluOut,
					output reg [4:0] cond_codes,	// may not need to output condition code, but helpful
					output cOut;
				
	    );

	// cond_codes --> condition codes
	// 	cond_codes[0] --> carry-bit (1 if carry or borrowed occurred)
	// 	cond_codes[1] --> low flag via comparison operations (1 if Rdest oper less than Rsrc oper when both unsigned integers)
	// 	cond_codes[2] --> flag bit used by arith operations (aka V bit, 1 if signed overflow on signed add or sub)
	// 	cond_codes[3] --> Z bit via comparison operation (1 if two operands equal, cleared otherwise)
	// 	cond_codes[4] --> Negative bit via comparisopn operation (1 if Rdest oper less than Rsrc when both signed integers)
		 
		 
		 
	// Defining opcode via 8bit for processor
	parameter def = 		8'b00000000;
	
	parameter ANDI  = 		8'b0001xxxx;
	parameter ADDI = 		8'b0101xxxx;
	parameter SUBI = 		8'b1001xxxx;
	parameter ORI = 		8'b0010xxxx;
	parameter XORI = 		8'b0011xxxx;
	parameter ADDCI = 		8'b0111xxxx;
	parameter CMPI = 		8'b1011xxxx;
	parameter CMPUI = 		8'b1100xxxx;
	parameter ADDUI = 		8'b0110xxxx;
	parameter ADDCUI = 		8'b1010xxxx;
	
	// shift
	parameter LSHI = 		8'b1000000x;
	parameter LSH = 		8'b10000100;
	parameter RSHI = 		8'b1000001x;
	parameter RSH = 		8'b10000101;
	parameter ALL_LSHI =		8'b1000100x;
	parameter ALL_LSH = 		8'b10000110;
	parameter ALL_RSHI = 		8'b1000101x;
	parameter ALL_RSH = 		8'b10000111;
	
	// Registers
	parameter NOT =		8'b00001111;
	parameter AND= 		8'b00000001;
	parameter ADD = 	8'b00000101;
	parameter SUB = 	8'b00001001;
	parameter OR = 		8'b00000010;
	parameter ADDU = 	8'b00000110;
	parameter XOR = 	8'b00000011;
	parameter ADDC =	8'b00000111;
	parameter CMP = 	8'b00001011;
	parameter ADDCU = 	8'b00000100;
	
	// special
	parameter LOAD = 	8'b00000000;
	parameter STOR =	8'b00000000;
	
	// conditions
	
		 
	// Doesn't include: 	MOVI, SUBCI, MULI, LUI,   
	//								WAIT, MOV, SUBC, MUL, 
	//								JAL, Jcond, LPR, SPR, RETX, Scond, SNXB, ZRXB, TBIT, TBITI, DI, EI, EXCP,
	//								ASHUI, ASHU (split ASHU and ASHUI into all shift left, all shift right)						
		 
   wire     [WIDTH-9:0] b2, sum, slt, shift;
   reg [15:0] aluResult;

	assign b2 = aluCont[2] ? ~aluIn1 : aluIn2; 
   assign sum = aluIn1 + b2 + aluCont[3];
	//implement shifter inside ALU 
	
   assign aluOut = aluResult;
	
   // slt should be 1 if most significant bit of sum is 1
   assign slt = sum[WIDTH-1];

   always@(*) begin // maybe always at ALUIn1, ALUIn2, cin, and maybe aluCont? dependent on opcodes though
      case(aluCont[2:0])
    //     3'b000: aluResult <= a & b;  // logical AND
    //    3'b001: aluResult <= a | b;  // logical OR
    //     3'b010: aluResult <= sum;    // Add/Sub
    //     3'b011: aluResult <= slt;    // set-less-than
	 //3'b100: aluResult <= shift; 	// shift left/shift right

	// default aluResult <= aluIn1 & aluIn2;
		
		def:
			begin
			cond_codes = 5'b00000;
			aluOut = {WIDTH{1'bx}}; // setting all bits to x of the variable pareter WIDTH
			end
			
		ADDI, ADD: 
			begin
			aluOut = AluIn1 + AluIn2;
			if (aluOut == {WIDTH{1'b0})
				begin
				cond_codes[3] = 1'b1;
				else begin
				cond_codes[3] = 1'b0;
				end
			if ((~cin[WIDTH-1] & aluIn1[WIDTH-1] & aluIn1[WIDTH-1]) | (cin[WIDTH-1] & ~aluIn1[WIDTH-1] & ~aluIn1[WIDTH-1]))
				begin
				cond_codes[2] = 1'b0; // flag bit for arith comparisons
				else begin
				cond_codes[3:0] = 4'b0000; // else set all condition codes to 0
				end
			end
		
		SUBI, SUB:
			begin
			aluOut = AluIn1 - AluIn2;
			if ()
				begin
				else begin
				end
			if ()
				begin
				else begin
				end
			end
			
		ANDI, AND:
		begin
		aluOut = AluIn1 & AluIn2;
		
		// Fill in here
		end
		
		ORI, OR:
		begin
		aluOut = AluIn1 | AluIn2;
		
		// Fill in here
		end
		
		XORI, XOR:
		begin
		aluOut = AluIn1 ^ AluIn2;
		
		// Fill in here
		end
		
		CMPI, CMP:
		begin
		
		
		// Fill in here
		end
		
		NOT:
		begin
		aluOut = ~AluIn1;
		
		// Fill in here
		end
		
		ADDUCI, ADDU:
		begin
		{cond_codes[0], cin} = AluIn1 + AluIn2 + cin; // carry-bit
		
		// Fill in here
		end
		
		CMPUI, CMPU:
		begin
		
		
		// Fill in here
		end
		
		ADDCI, ADDC:
		begin
		aluOut = AluIn1 + AluIn2 + cin;
		
		// Fill in here
		end
		
		RSHI, RSH:
		begin
		cond_codes[4:0] = 5'b00000;
		aluOut = AluIn1 >> AluIn2;
		end
		
		LSHI, LSH:
		begin
		cond_codes[4:0] = 5'b00000;
		aluOut = AluIn1 << AluIn2;
		end
		
		ALL_RSHI, ALL_RSH:
		begin
		cond_codes[4:0] = 5'b00000;
		aluOut = $signed(AluIn1) >>> $signed(AluIn2);
		end
		
		ALL_LSHI, ALL,LSH:
		begin
		cond_codes[4:0] = 5'b00000;
		aluOut = $signed(AluIn1) <<< $signed(AluIn2);
		end
		
			
		default: 
			begin
			cond_codes = 5'b00000;
			aluOut = {WIDTH{1'bx}}; // setting all bits to x of the variable pareter WIDTH
			end
		
	 endcase
   end
	
endmodule

