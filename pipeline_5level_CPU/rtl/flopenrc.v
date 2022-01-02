`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/12 23:39:03
// Design Name: 
// Module Name: flopenrc
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


module flopenrc 
#(parameter WIDTH = 32)
    (
    input clk,rst,en,clear,
    input[WIDTH-1:0] d,
    output reg[WIDTH-1:0] q  //WTDTH.......................
    );

    always @(posedge clk) begin
        if(rst) begin
            q <= 0;
        end
        else if(clear) begin
            q <= 0;
        end
        else if(en) begin
            q <= d;
        end
    end
endmodule
