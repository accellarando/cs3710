module stateMachine(input nextStateButton, reset,
	output[15:0] addr,
	output we,
	output[15:0] dataOut)
	
	wire[3:0] thisState;
	wire[3:0] nextState;
	always@(negedge reset) begin
		thisState <= 4'b0;
		nextState <= 4'b0;
	end
	always@(posedge nextStateButton) begin
		//advance to next state
		thisState <= nextState;
		if(nextState == 4'b15)
			nextState <= 4'b0;
		else
			nextState += 4'b1;
	end
	always@(*) begin
		case(thisState)
			4'b0: begin
				addr <= 16'b0;
				we <= 1'b0;
				dataOut <= 16'b1;
			end
			4'b1: we <= 1'b1;
			4'b2: begin
				addr <= 16'b16;
				we <= 1'b0;
				dataOut <= 16'b2;
			end
			4'b3: we <= 1'b1;
			4'b4: begin
				addr <= 16'b32;
				we <= 1'b0;
				dataOut <= 16'b3;
			end
			4'b5: we <= 1'b1;
			//am I on the right track here?
		endcase
	end
	
	
endmodule 