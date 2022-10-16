module alu #(parameter WIDTH = 16)
            (input      [WIDTH-9:0] aluIn1, aluIn2, 
             input      [3:0]       aluCont, 
	     input	cin,
             output reg [WIDTH-1:0] aluout
	     output cOut;
	    );

   wire     [WIDTH-9:0] b2, sum, slt, shift;
   reg [15:0] aluResult;

	assign b2 = aluCont[2] ? ~aluIn1 : aluIn2; 
   assign sum = aluIn1 + b2 + aluCont[3];
	//implement shifter inside ALU 
	
   assign aluOut = aluResult;
	
   // slt should be 1 if most significant bit of sum is 1
   assign slt = sum[WIDTH-1];

   always@(*) begin
      case(alucont[2:0])
         3'b000: aluResult <= a & b;  // logical AND
         3'b001: aluResult <= a | b;  // logical OR
         3'b010: aluResult <= sum;    // Add/Sub
         3'b011: aluResult <= slt;    // set-less-than
	 3'b100: aluResult <= shift; 	// shift left/shift right
	 default aluResult <= aluIn1 & aluIn2;		
	 endcase
   end
endmodule
