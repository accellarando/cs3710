//
// Module to take a single (4-bit) hex value and 
// display it on a 7-segment display as a number
// 
module hexTo7Seg(
		input [3:0]bcd,
		output reg [6:0] seven_seg
		);

  // always @* guarantees that the circuit that is 
  // synthesized is combinational 
  // (no clocks, registers, or latches)
  always @*
    // Note that the 7-segment displays on the DE1-SoC board are
    // "active low" - a 0 turns on the segment, and 1 turns it off
    case(bcd)
      4'b0000 : seven_seg = ~7'b0111111; // 0
      4'b0001 : seven_seg = ~7'b0000110; // 1
      4'b0010 : seven_seg = ~7'b1011011; // 2
      4'b0011 : seven_seg = ~7'b1001111; // 3
      4'b0100 : seven_seg = ~7'b1100110; // 4
      4'b0101 : seven_seg = ~7'b1101101; // 5
      4'b0110 : seven_seg = ~7'b1111101; // 6
      4'b0111 : seven_seg = ~7'b0000111; // 7
      4'b1000 : seven_seg = ~7'b1111111; // 8
      4'b1001 : seven_seg = ~7'b1100111; // 9 
      4'b1010 : seven_seg = ~7'b1110111; // A
      4'b1011 : seven_seg = ~7'b1111100; // b
      4'b1100 : seven_seg = ~7'b1011000; // c
      4'b1101 : seven_seg = ~7'b1011110; // d
      4'b1110 : seven_seg = ~7'b1111001; // E
      4'b1111 : seven_seg = ~7'b1110001; // F
      default : seven_seg = ~7'b0000000; // Always good to have a default! 
    endcase
endmodule 