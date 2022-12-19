/***
 * VGA state machine and RGB output code.
 * Author: Ella Moss
 */
module bitGen(
	input clk, bright, reset,
	input unsigned [9:0] hCount,
	input unsigned [9:0] vCount,
	input [15:0] memData,
	input [15:0] glyphs,
	input [15:0] count_addr,
	input hSync, vSync,
	output reg[15:0] memAddr,
	output reg[23:0] rgb);

parameter BG_COLOR = 16'b1111111111111111; //what to set RGB to if in background region

//Parameters dictating where the rectangles go
parameter TOP = 176;
parameter BOTTOM = 304;
parameter HUN_START = 112;
parameter HUN_END = 240;
parameter TEN_START = 256;
parameter TEN_END = 384;
parameter ONE_START = 400;
parameter ONE_END = 528;

reg[3:0] thisState, nextState;
reg[2:0] pixelCounter;
reg[3:0] digitOne, digitTen, digitHun;
reg[3:0] digit;
reg[9:0] start;
reg[15:0] pixelAddr;
reg[15:0] pixels;
reg[14:0] nextPixels;
reg[4:0] i; //keeps track of what pixel in the 5-set we're on (write)
reg[9:0] j;
reg[3:0] k; //keeps track of how many pixels in we are (read)
//Helps keep track if Hcount or Vcount have changed
reg[9:0] oldHc;
reg[9:0] oldVc;
reg isGlyph;

reg[7:0] red, green, blue;

//State parameters.
parameter FETCH_PIX = 4'd0;
parameter WRITE_PIX = 4'd1;
parameter FETCH_HUN = 4'd2;
parameter FETCH_HUN_WB = 4'd3;
parameter FETCH_TEN = 4'd4;
parameter FETCH_TEN_WB = 4'd5;
parameter FETCH_ONE = 4'd6;
parameter FETCH_ONE_WB = 4'd7;

//Move to next state on rising clock edge.
always@(posedge clk) begin
	thisState <= nextState;
end

//Combinational next-state logic.
always@(*) begin
	if(!reset) begin
		nextState <= FETCH_HUN;
		//i <= 4'b0;
	end
	case(thisState)
		FETCH_HUN: nextState <= FETCH_HUN_WB;
		FETCH_HUN_WB: nextState <= FETCH_TEN;
		FETCH_TEN: nextState <= FETCH_TEN_WB;
		FETCH_TEN_WB: nextState <= FETCH_ONE;
		FETCH_ONE: nextState <= FETCH_ONE_WB;
		FETCH_ONE_WB: nextState <= FETCH_PIX;
		FETCH_PIX: nextState <= WRITE_PIX;
		WRITE_PIX:
			if(!vSync)
				nextState <= FETCH_HUN;
			else if(i >= 5'd16)
				nextState <= FETCH_PIX;
			else
				nextState <= WRITE_PIX;
	endcase
end

//What to do in each state.
always@(posedge clk) begin
	if(!reset) begin
		i <= 4'b0;
		j <= 10'b0;
	end
	case(thisState)
		//Set up hundreds place memory fetch...
		FETCH_HUN: memAddr <= count_addr + 2'd2;
		//...and get memData for that place.
		FETCH_HUN_WB: begin
			memAddr <= count_addr + 2'd2;
			digitHun <= memData[3:0];
		end
	
		//Similarly fetch tens place data.
		FETCH_TEN: memAddr <= count_addr + 2'd1;
		FETCH_TEN_WB: begin
			memAddr <= count_addr + 2'd1;
			digitTen <= memData[3:0];
		end

		//And ones place.
		FETCH_ONE: memAddr <= count_addr + 2'd0;
		FETCH_ONE_WB: begin
			memAddr <= count_addr + 2'd0;
			digitOne <= memData[3:0];
		end

		//Now, translate these numbers into pixel values
		//    based on glyph information, hCount and vCount
		FETCH_PIX: begin
			i <= 5'd31; //-1. idk
			//Check which region we're in.
			if(vCount >= TOP && vCount <= BOTTOM) begin
				if(hCount >= HUN_START && hCount <= HUN_END) begin
					isGlyph <= 1'b1;
					if(hCount == HUN_START) begin
						j <= 10'b0;
					end
					else begin
						//Every 4 places, increment j
						if(k==4'd4)
							j <= j+1'b1;
						else
							k <= k + 1'b1;
					end
					//in the hundreds region
					memAddr <= glyphs + (digitHun << 4'd10) //base glyph addr
						+ ((vCount - TOP) << 3) //row
						+ (j>>2);
					pixels <= memData;
				end
				else if(hCount >= TEN_START && hCount <= TEN_END) begin
					isGlyph <= 1'b1;
					if(hCount == TEN_START) begin
						j <= 10'b0;
						k <= 4'b0;
					end
					else begin
						if(k==4'd4)
							j <= j+1'b1;
						else
							k <= k + 1'b1;
					end
					memAddr <= glyphs + (digitTen << 4'd10) //base glyph addr
						+ ((vCount - TOP) <<3)//row
						+ (j>>2);
					pixels <= memData;
				end
				else if(hCount >= ONE_START && hCount <= ONE_END) begin
					isGlyph <= 1'b1;
					if(hCount == ONE_START) begin
						j <= 10'b0;
						k <= 4'b0;
					end
					else begin
						if(k==4'd4)
							j <= j+1'b1;
						else
							k <= k + 1'b1;
					end
					memAddr <= glyphs + (digitOne << 10) //base glyph addr
						+ ((vCount - TOP) <<3) //row
						+ (j>>2);
					pixels <= memData;
				end
				else begin
					isGlyph <= 1'b0;
					pixels <= BG_COLOR;
				end
			end
			else begin
				isGlyph <= 1'b0;
				pixels <= BG_COLOR;
			end
		end

		//Finally, convert these pixels to rgb values
		//    that make sense to the VGA DAC.
		WRITE_PIX: begin
			if(isGlyph)
				pixels <= memData;
			if(oldHc != hCount) begin
				//update...
				i <= i+1'b1;
				oldHc <= hCount;
			end
			red <= {4'd8{pixels[3'd4 * (i>>2) + 3'd2]}};
			green <= {4'd8{pixels[3'd4 * (i>>2) + 3'd1]}};
			blue <= {4'd8{pixels[3'd4 * (i>>2) + 3'd0]}};
			rgb <= {red,green,blue};
		end
		default: ; //I think this will prevent a latch but idk
	endcase
end
endmodule 
