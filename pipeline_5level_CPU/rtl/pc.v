`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 20:07:28
// Design Name: 
// Module Name: pc
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

//??????
//？？？？？？？？？？？？？？？？？？？？？？、、就因为这个negedge天呐！！！！！！！！！！！！！！！！！！！！！！！！！！！！
module pc(
    input clk,rst,en,
    input[31:0] pc_new,
    output reg[31:0] pc

    );
    always @(posedge clk or posedge rst) begin //异步的rst很重要    这里是posedge！！！！！！！！！！！！！！！！！！！！！！！！！！
        if (rst) begin pc <= 0; end   //!!!!!!!!非常巧妙最先将pc置为了0，从而后面的可以运转。
        else if(en) 
            begin pc <= pc_new; end
        // else begin
        //     pc <= 32'b0;
        // end  没有这个，否则1c过后pc就变为0了！！！????????????????????????????????????????？？？？？？？？？？？？？？？？？？
        
    end

endmodule
