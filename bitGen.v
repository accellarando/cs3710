module bitGen(
	input clk, bright,
	input [9:0] hCount,
	input [9:0] vCount,
	input [15:0] count_addr,
	input [15:0] memData,
	output[15:0] memAddr,
	output reg[23:0] rgb);
	
	parameter BG_COLOR = 24'h111111;
	parameter GLYPHS_ADDR = 16'hFFFF; //change this based on memory map!
	
	parameter FETCH_ONE = 3'b000;
	parameter FETCH_TEN = 3'b001;
	parameter FETCH_HUN = 3'b010;
	parameter WRITE_ONE = 3'b011;
	parameter WRITE_TEN = 3'b100;
	parameter WRITE_HUN = 3'b101;
	parameter FETCH_PIX = 3'b110;
	parameter WRITE_PIX = 3'b111;
	
	parameter TOP = 160;
	parameter BOTTOM = 320;
	parameter HUN_START = 20;
	parameter HUN_END = 180;
	parameter TEN_START = 200;
	parameter TEN_END = 360;
	parameter ONE_START = 380;
	parameter ONE_END = 540;
	
	always@(posedge clk) begin
		if(!reset) 
			nextState = FETCH_ONE;
		thisState <= nextState;
	end
	
	always@(*)
		case(thisState)
			FETCH_ONE: nextState <= FETCH_TEN;
			FETCH_TEN: nextState <= FETCH_HUN;
			FETCH_HUN: nextState <= FETCH_PIX;
			FETCH_PIX: nextState <= WRITE_PIX;
			WRITE_PIX: nextState <= READ_PIX;
			READ_PIX:
				if(pixelCounter == 3'd4)
					nextState <= FETCH_TEN;
				else
					nextState <= READ_PIX;
		endcase
	end
	
	always@(*) begin
		case(thisState)
			FETCH_ONE: memAddr <= count_addr;
			WRITE_ONE: digitOne <= memData;
			FETCH_TEN: memAddr <= count_addr + 1'b1;
			WRITE_TEN: digitTen <= memData;
			FETCH_HUN: memAddr <= count_addr + 2'b10;
			WRITE_HUN: digitHun <= memData;
			FETCH_PIX: memAddr <= pix_addr;
			WRITE_PIX: begin 
				pixelCounter <= 3'b111; //-1
				pixels <= memData;
			end
			READ_PIX: begin
				pixelCounter <= pixelCounter + 1'b1;
			end
		endcase
	end
	
	always@(posedge clk) begin
		if(bright) begin
			if(vCount >= TOP && vCount <= BOTTOM) begin
				if(hCount >= HUN_START && hCount <= HUN_END) begin
					//each time, we get 16 bytes back - that's 5 pixels worth, 
						//if each pixel is 3 bits
					pix_addr <= (GLYPHS_ADDR + digitHun<<10) //each sprite is 1024 words
						+ (vCount-TOP)<<5 //get row
						+ (hCount-HUN_START); //get col
						//this is probably broken. will need to test.
					//figure out which pixel we're fetching, extend it to 8 bits, assign.
					rgb <= {3'd8{pixels[pixelCounter+2'd2]},
						{{3'd8{pixels[pixelCounter+2'd1]},
							{3'd8{pixels[pixelCounter]}}}}};
				end
				if(hCount >= TEN_START && hCount <= TEN_END) begin
					//each time, we get 16 bytes back - that's 5 pixels worth, 
						//if each pixel is 3 bits
					pix_addr <= (GLYPHS_ADDR + digitTen<<10) //each sprite is 1024 words
						+ (vCount-TOP)<<5 //get row
						+ (hCount-TEN_START); //get col
						//this is probably broken. will need to test.
					//figure out which pixel we're fetching, extend it to 8 bits, assign.
					rgb <= {3'd8{pixels[pixelCounter+2'd2]},
						{{3'd8{pixels[pixelCounter+2'd1]},
							{3'd8{pixels[pixelCounter]}}}}};
				end
				if(hCount >= ONE_START && hCount <= ONE_END) begin
					//each time, we get 16 bytes back - that's 5 pixels worth, 
						//if each pixel is 3 bits
					pix_addr <= (GLYPHS_ADDR + digitOne<<10) //each sprite is 1024 words
						+ (vCount-TOP)<<5 //get row
						+ (hCount-ONE_START); //get col
						//this is probably broken. will need to test.
					//figure out which pixel we're fetching, extend it to 8 bits, assign.
					rgb <= {3'd8{pixels[pixelCounter+2'd2]},
						{{3'd8{pixels[pixelCounter+2'd1]},
							{3'd8{pixels[pixelCounter]}}}}};
				end
			end
			else
				rgb <= BG;
		end
	end
endmodule 