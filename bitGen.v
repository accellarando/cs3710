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

parameter BG_PIXELS = ~16'hFFFF;

parameter TOP = 176;
parameter BOTTOM = 304;
parameter HUN_START = 64;
parameter HUN_END = 192;
parameter TEN_START = 208;
parameter TEN_END = 336;
parameter ONE_START = 352;
parameter ONE_END = 480;

parameter FETCH_NEXT_LINE = 4'd0;
parameter FETCH_NEXT_LINE_WB = 4'd1;
parameter FETCH_HUN = 4'd2;
parameter FETCH_HUN_WB = 4'd3;
parameter FETCH_TEN = 4'd4;
parameter FETCH_TEN_WB = 4'd5;
parameter FETCH_ONE = 4'd6;
parameter FETCH_ONE_WB = 4'd7;
parameter WRITE_TO_SCREEN = 4'd8;

reg[3:0] thisState, nextState;
reg[2:0] pixelCounter;
reg[3:0] digitOne, digitTen, digitHun;
reg[9:0] start;
reg[15:0] pixelAddr;
reg[15:0] pixels;
reg[14:0] nextPixels;
reg[3:0] i; //keeps track of what pixel in the 4-set we're on (write)
reg[9:0] j;
reg[4:0] k; //keeps track of how many pixels in we are (read)
reg[9:0] oldHc;
reg[9:0] oldVc;
reg[1919:0] thisLine;
reg[1919:0] nextLine;
reg isGlyph;
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
		FETCH_ONE_WB:
			if(!hSync)
				nextState <= FETCH_NEXT_LINE;
			else
				nextState <= WRITE_TO_SCREEN;
		FETCH_NEXT_LINE: nextState <= FETCH_NEXT_LINE_WB;
		FETCH_NEXT_LINE_WB:
			if(i>0)
				nextState <= FETCH_NEXT_LINE;
			else
				nextState <= WRITE_TO_SCREEN;
		WRITE_TO_SCREEN:
			if(!hSync)
				nextState <= FETCH_NEXT_LINE;
			else
				nextState <= WRITE_TO_SCREEN;
	endcase
end

always@(posedge hSync)
	thisLine <= nextLine;

always@(posedge clk) begin
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
			if(!hSync)
				i <= 1919;
		end

		FETCH_NEXT_LINE: begin
			/*
			base glyph address is just 1024*glyph, ie glyph<<10
			row is (row/4)*32, ie, row*8, ie row<<3
			col is col/4, ie row>>2
			*/
			//figure out which region we're in
			if(vCount >= TOP && vCount <= BOTTOM) begin
				if(hCount >= HUN_START && hCount <= HUN_END) begin
					isGlyph <= 1'b1;
					memAddr <= digitHun << 10 
						+ (vCount-TOP) << 3
						+ (hCount - HUN_START) >> 2;
				end
				else if(hCount >= TEN_START && hCount <= TEN_END) begin
					isGlyph <= 1'b1;
					memAddr <= digitTen << 10
						+ (vCount - TOP) << 3
						+ (hCount - HUN_START) >> 2;
				end
				else if(hCount >= ONE_START && hCount <= ONE_END) begin
					isGlyph <= 1'b1;
					memAddr <= digitOne << 10
						+ (vCount - TOP) << 3
						+ (hCount - HUN_START) >> 2;
				end
				else begin
					isGlyph <= 1'b0;
					memAddr <= 16'hFFFF;
				end
			end
			else
				isGlyph <= 1'b0;
		end
		FETCH_NEXT_LINE_WB: begin
			if(!isGlyph)
				pixels <= BG_PIXELS;
			else begin
				pixels <= memData;
			end
			nextLine[i -: 16] = { {{3'd4}{pixels[15:13]}},
				{{3'd4}{pixels[11:9]}},
				{{3'd4}{pixels[7:5]}},
				{{3'd4}{pixels[3:1]}}};
			i <= i-5'd16;
		end
		WRITE_TO_SCREEN: begin
			if(i<3) begin
				i <= 1919;
				rgb <= {BG_PIXELS,BG_PIXELS[7:0]};
			end
			else begin
				rgb <= { {{4'd8}{thisLine[i]}},
					{{4'd8}{thisLine[i-1]}},
					{{4'd8}{thisLine[i-2]}}};
				i <= i-3'd3;
			end
		end
	endcase
end
endmodule 
