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
            (	input 		[3:0] aluOp,
					input     	[WIDTH-1:0] aluIn1, aluIn2,	// regarding pcOut as 16-bit	
					output reg 	[WIDTH-1:0] aluOut, 
					output reg	[1:0]cond_group1,	// FC bits
					output reg	[2:0] cond_group2
				
				);
					
	parameter AND		=	4'b0000;
	parameter OR		=	4'b0001;
	parameter XOR 		= 	4'b0010;
	parameter ADD 		= 	4'b0011;
	parameter SUB		=	4'b0100;
	parameter NOT 		= 	4'b0101;
	parameter SLL 		= 	4'b0110; 	// shift Left logical
	parameter SRL 		= 	4'b0111; 	// shift right logical
	
	wire [WIDTH:0] tmp;
	assign tmp =({1'b0,aluIn1} + {1'b0, aluIn2});
	reg cOut;
		
					
	always@(*) begin // maybe always at ALUIn1, ALUIn2, carryIn, and maybe aluOp? dependent on opcodes though
      cond_group1[0] <= tmp[WIDTH];
		aluOut <= {WIDTH{1'b0}};
		//cond_group1 <= 1'b0;
		cond_group2 <= 3'b000;
		 
		
	casex(aluOp)
	
	AND:begin 
			aluOut <= aluIn1 & aluIn2;
				if (aluOut == {WIDTH{1'b0}})
					begin
						cond_group2[1] <= 1'b1; // Z bit set to 1
					end
				else 
					begin
						cond_group2[1] <= 1'b0; // Else, Z bit set to 0
						//cond_group1[1:0] = 2'b0; // C and F bit to 0
						cond_group2[0] <= 1'b0; // L bit to 0
						cond_group2[2] <= 1'b0; // N bit to 0	
					end
		 end
	OR: begin
			aluOut <= aluIn1 | aluIn2;
				if (aluOut == {WIDTH{1'b0}})
					begin
						cond_group2[1] <= 1'b1; // Z bit set to 1
					
					end
		 end
	XOR: begin
			aluOut <= aluIn1 ^ aluIn2;
			if (aluOut == {WIDTH{1'b0}})
					cond_group2[1] <= 1'b1; // Z bit set to 1
			
	     end
		
	ADD: begin
			 {cOut, aluOut} <= $signed(aluIn1) + $signed(aluIn2);
				if ((~aluOut[WIDTH-1] & aluIn1[WIDTH-1] & aluIn2[WIDTH-1]) | (aluOut[WIDTH-1] & ~aluIn1[WIDTH-1] & ~aluIn2[WIDTH-1]))
					cond_group1[1] <= 1'b1; // F bit set to 1 in signed arithmetic
				else
				begin
				 {cOut, aluOut} <= aluIn1 + aluIn2;
					 if(cOut == 1'b1)
						cond_group1[0] <= 1'b1;  // C bit set to 1 in unsigned arrithmetic
				end
			end
	SUB:
			begin
					aluOut <= aluIn1 - aluIn2;
					
				if(aluIn1 < aluIn2)
				begin
					cond_group1[0] <= 1'b1; 		// C flag is to 1
					cond_group2[0] <= 1'b1;
				end	// L flag is set to 1
					
				if($signed(aluIn1) < $signed(aluIn2))
				begin
					cond_group1[1] <= 1'b1;
					cond_group2[2] <= 1'b1; // N bit set to 1
				end
				if(aluIn1 == aluIn2)
					cond_group2[1] <= 1'b1; // Z bit set to 1
				begin
				{cOut, aluOut} <= $signed(aluIn1) - $signed(aluIn2);
					if ((~aluOut[WIDTH-1] & aluIn1[WIDTH-1] & aluIn2[WIDTH-1]) | (aluOut[WIDTH-1] & ~aluIn1[WIDTH-1] & ~aluIn2[WIDTH-1]))
						cond_group1[1] <= 1'b1; // F bit set to 1 in signed arithmetic
				end
			end
	NOT:
			begin
				aluOut <= ~aluIn1;
				if (aluOut == {WIDTH{1'b0}})
					begin
						cond_group2[1] <= 1'b1; // Z bit set to 1 Not veriry sure about this 
					end
				else 
					begin
						cond_group2[1] <= 1'b0; // Else, Z bit set to 0
					end
				//cond_group1[1:0] = 2'b0; // C and F bit to 0
				cond_group2[0] <= 1'b0; // L bit to 0
				cond_group2[2] <= 1'b0; // N bit to 0
				
			end
	SLL: 
		begin
			aluOut <= aluIn1 << 1;
		
		end
	SRL:
		begin
			aluOut <= aluIn1 >> 1;
		end
		
 endcase
end
endmodule
