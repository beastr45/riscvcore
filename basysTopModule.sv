`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2020 10:26:56 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top (
    input clk,
    input [15:0] sw,
    output [15:0] led,
    input [7:0] JXADC,

    // Displays (7-Segment)
    output [6:0] seg,
    output dp,
    output [3:0] an,

    // Push Buttons
    input btnC,
    input btnU,
    input btnL,
    input btnR,
    input btnD,

    // Pmod Headers (Digital)
    output [7:0] JA,
    output [7:0] JB,
    output [7:0] JC,

    // VGA Interface
    output [3:0] vgaRed,
    output [3:0] vgaBlue,
    output [3:0] vgaGreen,
    output Hsync,
    output Vsync,

    // USB-RS232 Interface
    input  RsRx,
    output RsTx
);
  // Route leds to their corresponding switches by default
  assign led[15:0] = sw[15:0];

  // Common-Anode 7-Segment Displays: Active-Low signals. 
  // Driving them to logic 1 cuts off the driving transistors and fully disables LEDs.
  assign an        = 4'b1111;
  assign seg       = 7'b1111111;
  assign dp        = 1'b1;

  // Digital Pmod Outputs: Grounded to prevent stray EMI or switching noise on raw headers.
  assign JA        = 8'b00000000;
  assign JB        = 8'b00000000;
  assign JC        = 8'b00000000;

  // VGA DAC Interface: Driven low to blank monitor video lines completely.
  assign vgaRed    = 4'b0000;
  assign vgaBlue   = 4'b0000;
  assign vgaGreen  = 4'b0000;
  assign Hsync     = 1'b0;
  assign Vsync     = 1'b0;

  // UART Communication: Serial TX line idling state is legally driven High (Marking state).
  assign RsTx      = 1'b1;

endmodule
