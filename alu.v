module alu #(parameter WIDTH = 16)
            (input      [WIDTH-9:0] aluIn1, aluIn2, 
             input      [3:0]       aluCont, 
				 input		cin;
             output reg [WIDTH-1:0] aluout)
				 output cOut;

   wire     [WIDTH-9:0] b2, sum, slt, shift;
	reg [15:0] alu_Result

   assign b2 = aluCont[2] ? ~aluInt2:aluInt2; 
   assign sum = a + b2 + aluCont[3];
	//inplement shift left and shift rigth inside ALU
	//assign shift_left=  
	
	assign alu_out = alu_Result;
	
   // slt should be 1 if most significant bit of sum is 1
   assign slt = sum[WIDTH-1];

   always@(*) begin
      case(alucont[2:0])
         3'b000: aluOut <= a & b;  // logical AND
         3'b001: aluOut <= a | b;  // logical OR
         3'b010: aluOut <= sum;    // Add/Sub
         3'b011: aluOut <= slt;    // set-less-than
			3'b100: aluOut <= shift; 	// shift left/shift right
			default aluOut <= a & b
			
      endcase