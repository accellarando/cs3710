module stateMachine(input nextStateButton, reset,
	output reg [15:0] addr,
	output reg we,
	output reg [15:0] dataOut);
	
	reg[3:0] thisState;
	reg[3:0] nextState;
	always@(negedge reset) begin
		thisState <= 4'd0;
		nextState <= 4'd0;
	end
	always@(posedge nextStateButton) begin
		//advance to next state
		thisState <= nextState;
		if(nextState == 4'd15)
			nextState <= 4'd0;
		else
			nextState <= nextState + 1;
	end
	always@(*) begin
		case(thisState)
			4'd0: begin
				addr <= 16'd0;
				we <= 1'd0;
				dataOut <= 16'd1;
			end
			4'd1: we <= 1'd1;
			4'd2: begin
				addr <= 16'd16;
				we <= 1'd0;
				dataOut <= 16'd2;
			end
			4'd3: we <= 1'd1;
			4'd4: begin
				addr <= 16'd32;
				we <= 1'd0;
				dataOut <= 16'd3;
			end
			4'd5: we <= 1'd1;
			//am I on the right track here?
		endcase
	end
	
	
endmodule 