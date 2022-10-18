/* ECE 3710: ALU and RF Design
* 	Group: Jack Marshall, Ella Moss, Dana Escandor, and Blandine Tchetche
*	
*	The ALU receives inputs for the 8-bit opcode, 2 16-bit integers to conduct ALU operations on, 
*	and pcOut from the pc register to add to aluOut for Bcond/Jcond conditions.
*
*	The ALU returns outputs a 16-but integer after conducting ALU operations and 2 separate groups of
*	condition codes.
*
*	LOAD/STORE opcodes were implemented using the "pass-though" method recommended by ISA instructions.
*
*
*/	

module alu #(parameter WIDTH = 16)
            (	input 		[WIDTH-9:0] aluOp,
					input     	[WIDTH-1:0] aluIn1, aluIn2,
					//output reg  [WIDTH-1:0] pcOut, // regarding pcOut as 16-bit
					output reg [WIDTH-1:0] aluOut,
					output reg [1:0] cond_group1,	
					output reg [2:0] cond_group2
					// output reg PCen, PCjump, PCbranch, WRen //program counter enable, jump, branch, write enable
	    );

	/* cond_codes --> condition codes
	*
	* 	cond_group1[0] --> C carry-bit (1 if carry or borrowed occurred)
	* 	cond_group1[1] --> F flag bit used by arith operations (aka V bit, 1 if signed overflow on signed add or sub)
	*
	* 	cond_group2[0] --> L low flag via comparison operations (1 if Rdest oper less than Rsrc oper when both unsigned integers)
	* 	cond_group2[1] --> Z bit via comparison operation (1 if two operands equal, cleared otherwise)
	* 	cond_group2[2] --> N Negative bit via comparisopn operation (1 if Rdest oper less than Rsrc when both signed integers) 
	* 	Defining opcode via 8bit for processor
	*/ 
	
	parameter ANDI			=	8'b0001xxxx;
	parameter ORI			=	8'b0010xxxx;
	parameter XORI 		= 	8'b0011xxxx;
	parameter ADDI 		= 	8'b0101xxxx;
	parameter ADDUI		=	8'b0110xxxx;
	parameter SUBI 		= 	8'b1001xxxx;
	parameter CMPI 		= 	8'b1011xxxx;
	parameter MOVI 		= 	8'b1101xxxx;
	parameter LUI			=	8'b1111xxxx;
	
	// shift
	parameter LSHI			=	8'b1000000x; // used for shifting 1
	parameter LSH 			= 	8'b10000100; // used for shifting 1
	parameter ASHUI 		=	8'b1000001x; 
	parameter ASHU			=	8'b10000110;
	
	// Registers
	parameter NOT 			=	8'b00001111;
	parameter AND 			= 	8'b00000001;
	parameter ADD 			= 	8'b00000101;
	parameter SUB 			= 	8'b00001001;
	parameter MOV 			= 	8'b00001101;
	parameter OR 			= 	8'b00000010;
	parameter ADDU			=	8'b00000110;
	parameter XOR 			= 	8'b00000011;
	parameter CMP 			= 	8'b00001011;
	parameter ADDCU 		= 	8'b00000100;
	
	// special
	parameter LOAD 			= 	8'b01000000;
	parameter STOR 			=	8'b01000100;
	
	parameter JAL 			=	8'b01001000;
	parameter Bcond 		= 	8'b1100xxxx;
	parameter Jcond 		= 	8'b01001100;
	
	// Cond values for Bcond and Jcond
	parameter EQ			=	4'h0;	// Equal
	parameter NE			=	4'h1;	// Not Equal
	parameter GE			=	4'hD;	// Greater Than Or Equal
	parameter CS			=	4'h2;	// Carry Set
	parameter CC			=	4'h3;	// Carry Clear
	parameter HI			=	4'h4;	// Higher Than
	parameter LS			=	4'h5;	// Lower Than or Same as
	parameter LO			=	4'hA;	// Lower Than
	parameter HS			=	4'hB;	// Higher than or Same as
	parameter GT			=	4'h6;	// Greater Than
	parameter LE			=	4'h7;	// Less Than or Equal
	parameter FS			=	4'h8;	// Flag Set
	parameter FC			=	4'h9;	// Flag Clear
	parameter LT			=	4'hC;	// Less Than
	parameter UC			=	4'hE;	// unconditional
	parameter NJ			=	4'hF;	// never jump
	
	reg carryIn; // assigned from past carry bit in the conditional codes/flags				

   always@(*) begin // maybe always at ALUIn1, ALUIn2, carryIn, and maybe aluOp? dependent on opcodes though
      
		aluOut = {WIDTH{1'b0}};
		carryIn = cond_group1[0];
		cond_group1 = 2'b00;
		cond_group2 = 3'b000;
			
		casex(aluOp) // case expression to allow for don't care values in case comparison
		
		/* Load & STORE: needs to use values in registers as memory addresses (possibly w/ immediate values (imm) added)
		*		Put values through ALU (in some sore of "pass through" mode -- what we did)
		*		Passed through, no alteration occurred.
		*		These register values were made to "somehow" be usable as memory addresses
		* 		Assuming "pass-through" means pass aluIn2 into aluOut, could mean aluOut = aluOut
		*/
		
		LOAD:
			begin
				aluOut = aluIn2;
				//WRen = 1'b1;   //need some way eventually to let CPU know to writeback
			end
			
		STOR:
			begin
				aluOut = aluIn2;
				//PCen = 1'b1; // need to some way to let CPU enable program counter
			end			
			
		/* Jump and Link:
		*		Like Jcond (jump), but the PC + 1 value also written to a register (aka, the link register)
		*		Function: jump to a subroutine, and return back to this point in code (where the subroutine was called)
		*		Will use  a JUC (jump unconditional) Rlink instruction
		*			--> Jump undonitional to the value that I will store in the Rlink register
		*/
		JAL:
			begin	
				// Will be uncommented once PC implemented, this is here to show work. 
				// PCen = 1'b1; PCjump = 1'b1; PCbranch = 1'b0;
				
				// Could be incorrect due to jumping to link register.
				// Jumps to aluIn2, where PC + 1 is written
				aluOut = aluIn2 + pcOut + 1'b1; 
			end
		
		// Implementing Branch and Jump Conditions:
		//		Option 1: Using ALU to compute target address
		
		

		/* Branch conditions: 
		*		Chose option 1: Using ALU to compute target address
		*		"sign-extended offset" in the immediate field (imm) of instruction is added to current PC and written
		*		back to PC "if branch condition is true"	
		*		immediate field (imm) only 8 bits of instruction coding
		*			therefore: only can branch to -128 or 127 instructions past the current instruction (using baseline instruction set)
		*/
		
		Bcond, Jcond: 
			begin
				// PCen = 1'b1; PCjump = 1'b0; PCbranch = 1'b1;
				case(aluIn1[3:0])
			
				//bcond and Jcond values	
				EQ:
					begin
						if(cond_group2[1]) // If Z bit is 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1; 
					end
				
				NE:
					begin
						if(!cond_group2[1]) // If Z bit is 0
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end 
						else
							aluOut = pcOut + 1'b1; 
					end
				
				GE:
					begin
						if(cond_group2[2] || cond_group2[1]) // If N or Z bit is 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]}; 
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
				
				CS:
					begin
						if(cond_group1[0]) // If C bit is 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluOut - aluIn2; // maybe aluOut = aluIn2
							endcase
						end 
						else
							aluOut = pcOut + 1'b1; 
					end
				
				CC:
					begin
						if(!cond_group1[0]) // If C bit is 0
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end 
						else
							aluOut = pcOut + 1'b1; 
					end
				
				HI:
					begin
						if(cond_group2[0]) // If L bit is 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
				
				LS:
					begin
						if(!cond_group2[0]) // If L bit is 0
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
					
				LO:
					begin
						if(!cond_group2[0] && !cond_group2[1]) // If L and Z bit are 0
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
					
				HS:
					begin
						if(cond_group2[0] && cond_group2[1]) // If L and Z bit are 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
					
				GT:
					begin
						if(cond_group2[2]) // If N bit is 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
				
				LE:
					begin
						if(!cond_group2[2]) // If N bit is 0
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
				
				FS:
					begin
						if(cond_group1[1]) // If F bit is 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
				
				FC:
					begin
						if(!cond_group1[1]) // If F bit is 0
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2;
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
				
				LT:
					begin
						if(cond_group2[2] && cond_group2[1]) // If N and Z bit are 1
						begin
							casex(aluOp)
							Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
							Jcond: aluOut = aluIn2; // possibly same as Bcond
							endcase
						end
						else
							aluOut = pcOut + 1'b1;
					end
				
				UC:	
					begin
						casex(aluOp)
						Bcond: aluOut = pcOut - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
						Jcond: aluOut = aluIn2;
						endcase
					end
					
				NJ:	
					begin
						aluOut = pcOut;
					end

				endcase
			end
		
		ADDI: 
			begin
				{carryIn, aluOut} = aluIn1 + {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
				if ((~carryIn & aluIn1[WIDTH-1] & aluIn2[WIDTH-1]) | (carryIn & ~aluIn1[WIDTH-1] & ~aluIn2[WIDTH-1]))
					cond_group1[1] = 1'b1; // F bit set to 1	
			end
			
		ADD: 
			begin
				{carryIn, aluOut} = aluIn1 + aluIn2;
				if ((~carryIn & aluIn1[WIDTH-1] & aluIn2[WIDTH-1]) | (carryIn & ~aluIn1[WIDTH-1] & ~aluIn2[WIDTH-1]))
					cond_group1[1] = 1'b1; // F bit set to 1	
			end
		
		SUBI:
			begin
				{carryIn, aluOut} = aluIn1 - {{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]};
				
				if($signed(aluIn1) < $signed(aluIn2))
					cond_group2[2] = 1'b1; // N bit set to 1
				
				if(aluIn1 == aluIn2)
					cond_group2[1] = 1'b1; // Z bit set to 1
					
				if(aluIn1 < aluIn2)
					cond_group2[0] = 1'b1; // L bit set to 1
				
				if ((carryIn & ~aluIn1[WIDTH-1] & ~aluIn1[WIDTH-1]) | (~carryIn & aluIn1[WIDTH-1] & aluIn1[WIDTH-1]))
					cond_group1[1] = 1'b1; // F bit set to 1	
			end
			
		SUB:
			begin
				{carryIn, aluOut} = aluIn1 - aluIn2;
					
				if($signed(aluIn1) < $signed(aluIn2))
					cond_group2[2] = 1'b1; // N bit set to 1
				
				if(aluIn1 == aluIn2)
					cond_group2[1] = 1'b1; // Z bit set to 1
					
				if(aluIn1 < aluIn2)
					cond_group2[0] = 1'b1; // L bit set to 1				
					
				if ((carryIn & ~aluIn1[WIDTH-1] & ~aluIn1[WIDTH-1]) | (~carryIn & aluIn1[WIDTH-1] & aluIn1[WIDTH-1]))
					cond_group1[1] = 1'b1; // F bit set to 1	
			end
			
		ANDI:
			begin
				aluOut = aluIn1 & {{WIDTH-8{1'b0}}, aluIn2[WIDTH-9:0]};
				if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] = 1'b1; // Z bit set to 1			
			end
			
		AND:
			begin
				aluOut = aluIn1 & aluIn2;
				if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] = 1'b1; // Z bit set to 1			
			end
		
		ORI:
			begin
				aluOut = aluIn1 | {{WIDTH-8{1'b0}}, aluIn2[WIDTH-9:0]};
				if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] = 1'b1; // Z bit set to 1
			end
			
		OR:
			begin
				aluOut = aluIn1 | aluIn2;
				if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] = 1'b1; // Z bit set to 1
			end
		
		
		XORI:
			begin
				aluOut = aluIn1 ^ {{WIDTH-8{1'b0}}, aluIn2[WIDTH-9:0]};
				if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] = 1'b1; // Z bit set to 1
			end
		
		XOR:
			begin
				aluOut = aluIn1 ^ aluIn2;
				if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] = 1'b1; // Z bit set to 1
			end
		
		// Move imm
		MOVI: aluOut = {{WIDTH-8{1'b0}}, aluIn2[WIDTH-9:0]};	
			
		// Move
		MOV: aluOut = aluIn1;
	
		// Load upper imm
		LUI: aluOut = {{aluIn2[WIDTH-9:0]}, {(WIDTH-8){1'b0}}};

		// Comparison imm
		CMPI:
			begin
				if ($signed(aluIn1) < $signed({{WIDTH-8{aluIn2[WIDTH-9]}} , aluIn2[WIDTH-9:0]}))
					begin
						cond_group2[2] = 1'b1; // N bit set to 1
					end
				else if (aluIn1 < {{WIDTH-8{1'b0}} , aluIn2[WIDTH-9:0]})
					begin
						cond_group2[0] = 1'b1; // L bit set to 1
					end
				else // if equal
					begin
						cond_group2[1] = 1'b1;  // Z bit set to 1
					end			
			end
			
		// Comparison
		CMP:
			begin
				if ($signed(aluIn1) < $signed(aluIn2))
					begin
						cond_group2[2] = 1'b1; // N bit set to 1
					end
				else if (aluIn1 < aluIn2)
					begin
						cond_group2[0] = 1'b1; // L bit set to 1
					end
				else // if equal
					begin
						cond_group2[1] = 1'b1;  // Z bit set to 1
					end			
			end
		
		NOT:
			begin
				aluOut = ~aluIn1;
				if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] = 1'b1; // Z bit set to 1	
			end
		
		// Logical shift imm
		LSHI: 
			begin
				if(aluOp[0] == 1'b1) // if doesn't equals, shift right
					aluOut = aluIn1 >> {1'b0, aluIn2[3:0]};  // shift right
				else // if equals, shift left
					aluOut = aluIn1 << {1'b0, aluIn2[3:0]};  // shift left
			end
		LSH: 
			begin
				if(aluIn2[WIDTH-1] == 1'b1) 
					aluOut = aluIn1 >> (-aluIn2);  // shift right
				else
					aluOut = aluIn1 << aluIn2;  // shift left
			end
		// Arthmetic shift up imm
		ASHUI: 
			begin
				if(aluOp[0] == 1'b1)
					aluOut = $signed(aluIn1) >>> {1'b0, aluIn2[3:0]}; // shift right
				else
					aluOut = $signed(aluIn1) <<< {1'b0, aluIn2[3:0]};  // shift left
			end
		ASHU: 
			begin
				if(aluIn2[WIDTH-1] == 1'b1)
					aluOut = $signed(aluIn1) >>> (-aluIn2);  // shift right
				else
					aluOut = $signed(aluIn1) <<< aluIn2;  // shift left
			end
			
		default:
			begin
				cond_group1[1:0] = 2'b00; // condition codes to 0
				cond_group2[2:0] = 3'b000; // condition codes to 0
				aluOut = aluIn1; // setting all bits to x of the variable pareter WIDTH
				aluOut =  {WIDTH{1'b1}}; // depending on how register handles, may have to be all 0's.
				// PCen = 1'b0; PCjump = 1'b0; PCbranch = 1'b0; WRen = 1'b0;
			end
	 endcase	
   end
	
endmodule
