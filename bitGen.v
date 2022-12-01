module bitGen(
	input clk, bright, reset,
	input [9:0] hCount,
	input [9:0] vCount,
	input [15:0] memData,
	input [15:0] glyphs,
	input [15:0] count_addr,
	output reg[15:0] memAddr,
	output reg[23:0] rgb);
	
	parameter BG_COLOR = 24'h111111;
	
	parameter FETCH_ONE = 4'b000;
	parameter FETCH_TEN = 4'b001;
	parameter FETCH_HUN = 4'b010;
	parameter WRITE_ONE = 4'b011;
	parameter WRITE_TEN = 4'b100;
	parameter WRITE_HUN = 4'b101;
	parameter FETCH_PIX = 4'b110;
	parameter WRITE_PIX = 4'b111;
	parameter READ_PIX = 4'b1000;
	
	parameter TOP = 160;
	parameter BOTTOM = 320;
	parameter HUN_START = 20;
	parameter HUN_END = 180;
	parameter TEN_START = 200;
	parameter TEN_END = 360;
	parameter ONE_START = 380;
	parameter ONE_END = 540;
	
	reg[3:0] thisState, nextState;
	reg[2:0] pixelCounter;
	reg[3:0] digitOne, digitTen, digitHun;
	reg[15:0] pix_addr;
	reg[15:0] pixels;
	
	always@(posedge clk) begin
//		if(!reset) 
//			nextState = FETCH_ONE;
		thisState <= nextState;
	end
	
	always@(*) begin
	   if(!reset) nextState <= FETCH_ONE;
		else 
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
			default: nextState <= FETCH_ONE;
		endcase
	end
	
	always@(*) begin //maybe posedge clk here
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
					pix_addr <= (glyphs + digitHun<<4'd10) //each sprite is 1024 words
						+ (vCount-TOP)<<4'd5 //get row
						+ (hCount-HUN_START); //get col
						//this is probably broken. will need to test.
					//figure out which pixel we're fetching, extend it to 8 bits, assign.
					rgb <= {{4'd8{pixels[pixelCounter+2'd2]}},
						 {{4'd8{pixels[pixelCounter+2'd1]}},
							{4'd8{pixels[pixelCounter]}}}};
				end
				if(hCount >= TEN_START && hCount <= TEN_END) begin
					//each time, we get 16 bytes back - that's 5 pixels worth, 
						//if each pixel is 3 bits
					pix_addr <= (glyphs + digitTen<<4'd10) //each sprite is 1024 words
						+ (vCount-TOP)<<4'd5 //get row
						+ (hCount-TEN_START); //get col
						//this is probably broken. will need to test.
					//figure out which pixel we're fetching, extend it to 8 bits, assign.
					rgb <= {{4'd8{pixels[pixelCounter+2'd2]}},
						{{{{4'd8{pixels[pixelCounter+2'd1]}},
							{4'd8{pixels[pixelCounter]}}}}}};
				end
				if(hCount >= ONE_START && hCount <= ONE_END) begin
					//each time, we get 16 bytes back - that's 5 pixels worth, 
						//if each pixel is 3 bits
					pix_addr <= (glyphs + digitOne<<4'd10) //each sprite is 1024 words
						+ (vCount-TOP)<<4'd5 //get row
						+ (hCount-ONE_START); //get col
						//this is probably broken. will need to test.
					//figure out which pixel we're fetching, extend it to 8 bits, assign.
					rgb <= {{4'd8{pixels[pixelCounter+2'd2]}},
						{{{4'd8{pixels[pixelCounter+2'd1]}},
							{4'd8{pixels[pixelCounter]}}}}};
				end
			end
			else
				rgb <= BG_COLOR;
		end
	end
endmodule 
