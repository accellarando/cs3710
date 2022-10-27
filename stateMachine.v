module stateMachine(input nextStateButton, reset,
	output reg [15:0] addr1, addr2,
	output reg we1, we2,
	output reg [15:0] dataOut1, dataOut2, hex); 
	
	/* Hex is like "dataOutFinal", 
	
	
	// *** Need to apply logic to comsider 2 separate addresses's write and data!!! ***
	// Adjust below!
	
	
	 REASON: 	output LEDs can only be represented by 1 variable at a time.
					since two separate addresses/data, either needs to be represented to the LEDs
	THEREFORE:
					always loop needs to consider which dataOut needs to be given to 7seg for
					controlling the LEDs. depending on the state.
					
					States to consider, what should be included in them (among other things of course):
					reset -- hex should be dataOut1 --> hex <= dataOut1
					initialize ram -- values into dram
					use ram -- past state put values into dram, now get em and use them
					return to ram -- past state used ram values, put em back
					change and output -- adjusting addr1 and addr2, assigning: hex <= dataOut2
					
	*/
	
	reg[3:0] thisState;
	reg[3:0] nextState;
	always@(negedge reset) begin
		thisState <= 4'd0;
		nextState <= 4'd0;
	end
	always@(posedge nextStateButton) begin
		//advance to next state
		thisState <= nextState;
		if(nextState == 4'd9)
			nextState <= 4'd0;
		else
			nextState <= nextState + 1;
	end
	always@(*) begin
		case(thisState)
			4'd0: begin
				addr1 <= 16'd0;
				addr2 <= 16'd16;
				we1 <= 1'd0;
				we2 <= 1'd0;
				dataOut1 <= 16'd1;
				dataOut2 <= 16'd2;
			end
			4'd1: begin
				we1 <= 1'd1;
				we2 <= 1'd1;
			end
			4'd2: begin
				addr1 <= 16'd32;
				addr2 <= 16'd48;
				we1 <= 1'd0;
				we2 <= 1'd0;
				dataOut1 <= 16'd3;
				dataOut2 <= 16'd4;
			end
			4'd3: begin
				we1 <= 1'd1;
				we2 <= 1'd1;
			end
			4'd4: begin
				addr1 <= 16'd64;
				addr2 <= 16'd80;
				we1 <= 1'd0;
				we2 <= 1'd0;
				dataOut1 <= 16'd5;
				dataOut2 <= 16'd6;
			end
			4'd5: begin
				we1 <= 1'd1;
				we2 <= 1'd1;
			end
			//Now test that those values are still in memory...
			4'd6: begin
				addr1 <= 16'd0;
				addr2 <= 16'd16;
				we1 <= 1'd0;
				we2 <= 1'd0;
			end
			4'd7: begin
				addr1 <= 16'd32;
				addr2 <= 16'd48;
				we1 <= 1'd0;
				we2 <= 1'd0;
			end
			4'd8: begin
				addr1 <= 16'd64;
				addr2 <= 16'd80;
				we1 <= 1'd0;
				we2 <= 1'd0;
			end
			default: begin
				we1 <= 1'd0;
				we2 <= 1'd0;
			end
			
		endcase
	end
	
	
endmodule 
