module bitGen(
	input clk, bright, reset,
	input [9:0] hCount,
	input [9:0] vCount,
	input [15:0] memData,
	input [15:0] glyphs,
	input [15:0] count_addr,
	input hSync, vSync,
	output reg[15:0] memAddr,
	output reg[23:0] rgb);

parameter BG_COLOR = ~16'b1111111111111111;

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
reg[3:0] digit;
reg[9:0] start;
reg[15:0] pixelAddr;
reg[15:0] pixels;
reg[14:0] nextPixels;
reg[3:0] i; //keeps track of what pixel in the 5-set we're on (write)
reg[9:0] j;
reg[3:0] k; //keeps track of how many pixels in we are (read)
reg[9:0] oldHc;
reg[9:0] oldVc;
reg isGlyph;

parameter FETCH_PIX = 4'd0;
parameter WRITE_PIX = 4'd1;
parameter FETCH_HUN = 4'd2;
parameter FETCH_HUN_WB = 4'd3;
parameter FETCH_TEN = 4'd4;
parameter FETCH_TEN_WB = 4'd5;
parameter FETCH_ONE = 4'd6;
parameter FETCH_ONE_WB = 4'd7;

always@(posedge clk) begin
	thisState <= nextState;
end

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
			else if(i >= 3'd4)
				nextState <= FETCH_PIX;
			else
				nextState <= WRITE_PIX;
	endcase
end

always@(posedge clk) begin
	if(!reset) begin
		i <= 4'b0;
		j <= 10'b0;
	end
	case(thisState)
		FETCH_HUN: memAddr <= count_addr + 2'd2;
		FETCH_HUN_WB: begin
			memAddr <= count_addr + 2'd2;
			digitHun <= memData[3:0];
		end
		
		FETCH_TEN: memAddr <= count_addr + 2'd1;
		FETCH_TEN_WB: begin
			memAddr <= count_addr + 2'd1;
			digitTen <= memData[3:0];
		end

		FETCH_ONE: memAddr <= count_addr + 2'd0;
		FETCH_ONE_WB: begin
			memAddr <= count_addr + 2'd0;
			digitOne <= memData[3:0];
		end

		FETCH_PIX: begin
			i <= 4'd15; //-1
			if(vCount >= TOP && vCount <= BOTTOM) begin
				if(hCount >= HUN_START && hCount <= HUN_END) begin
					isGlyph <= 1'b1;
					if(hCount == HUN_START) begin
						j <= 10'b0;
						k <= 4'b0;
					end
					else begin
						if(k==4'd4)
							j <= j+1'b1;
						else
							k <= k + 1'b1;
					end
					//in the hundreds region
					memAddr <= glyphs + (digitHun << 4'd12) + (digitHun << 4'd10) //base glyph addr
						+ (vCount - TOP) * (2'd2 << 5) //row
						+ j;
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
					memAddr <= glyphs + (digitTen << 4'd12) + (digitTen << 4'd10) //base glyph addr
						+ (vCount - TOP) * (2'd2 << 5) //row
						+ j;
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
					memAddr <= glyphs + (digitOne << 4'd12) + (digitOne << 4'd10) //base glyph addr
						+ (vCount - TOP) * (2'd2 << 5) //row
						+ j;
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

		WRITE_PIX: begin
			if(isGlyph)
				pixels <= memData;
			if(oldHc != hCount) begin
				//update...
				i <= i+1'b1;
				oldHc <= hCount;
			end
			rgb <= { {4'd8{pixels[3'd3 * i + 3'd3]}},
				{4'd8{pixels[3'd3 * i + 3'd2]}},
				{4'd8{pixels[3'd3 * i + 3'd1]}}};
			// j <= j+1'b1;
		end
		default: ;
	endcase
end
endmodule 
