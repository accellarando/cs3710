/***
 * vgaControl module.
 * Generates VGA control signals.
 * Written by Ella Moss for CS/ECE 3710, fall 2022.
 */
module vgaControl(
	input clk, clr,
	output reg hSync, vSync, bright,
	output reg [9:0] hCount,
	output reg [9:0] vCount,
	output vgaClk);

	//Parameters given in the spec
	parameter HMAX = 800; //lines to draw
	parameter VMAX = 521;
	parameter HFP  = 16; //Porch widths
	parameter VFP  = 10;
	parameter HBP  = 48;
	parameter VBP  = 29;
	parameter HPW  = 96; //pulse widths
	parameter VPW  = 2;
	//used to calculate porches etc
	reg [9:0] vCounter;
	reg [9:0] hCounter;
	reg isHorizontalOff;
	reg isVerticalOff;

	//Clock divider
	reg counter;
	reg enable;
	assign vgaClk = ~enable;
	always@(negedge clr, posedge clk) begin
		if(~clr) 
			counter <= 0;
		else begin
			counter <= ~counter;
			if(counter) begin
				enable <= 1;
				counter <= 0;
			end
			else
				enable <= 0;
		end
	end

	/* Could probably put this in the same always
	* block as above but this may be clearer.
	*/
	always@(negedge clr, posedge clk) begin


		if(clr==0) begin
			hCount <= 0;
			vCount <= 0;
			hCounter <= 0;
			vCounter <= 0;
			hSync <= 1;
			vSync <= 1;
		end
		else begin
			//Setting bright
			isHorizontalOff <= (hCounter < HPW + HFP) | (hCounter > HMAX - HBP);
			isVerticalOff <= (vCounter < VPW + VFP) | (vCounter > VMAX - VBP);
			bright <= ~isHorizontalOff & ~isVerticalOff;
			if(enable) begin
				//Horizontal
				hCounter <= hCounter + 1'b1;
				if(bright)
					hCount <= hCount + 1'b1;
				if(hCounter == HMAX) begin
					hCounter <= 0;
					hCount <= 0;
					hSync <= 0;
					vCounter <= vCounter + 1'b1;
					vCount   <= vCount + 1'b1;
				end
				else begin
					if(hCounter>HPW)
						hSync <= 1;
				end

				//Remaining vertical
				if(vCounter == VMAX) begin
					vCounter <= 0;
					vCount <= 0;
					vSync <= 0;
				end
				else begin
					if(vCounter > VPW) 
						if(!vSync)
							vSync <= 1;
				end
			end
		end
	end
endmodule
