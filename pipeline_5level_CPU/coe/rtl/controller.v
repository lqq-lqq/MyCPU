`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 19:14:38
// Design Name: 
// Module Name: controller
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


module controller(
    input [31:0] instr,
    input zeroM,
    output alusrcE,memwriteW,memtoregW,regwriteM,regdstE,pcsrcM,regwriteW,branchD,
    output[2:0] alucontrolE
    );
    wire regwriteE,memtoregE,memwriteE,branchE,regdstE;
    wire regwriteD,memtoregD,memwriteD,alusrcD,regdstD;
    wire [2:0] alucontrolD,alucontrolE;
    wire[1:0] aluopD;
    wire jumpD;   //没用到？？？？？？？？？？？？？
    maindec u1(
    .op(instrD[31:26]),
    .aluop(aluopD),
    .jump(jumpD),
    .branch(branchD),
    .alusrc(alusrcD),
    .memwrite(memwriteD),
    .memtoreg(memtoregD),
    .regwrite(regwriteD),
    .regdst(regdstD)
    );

    aludec t1(
    .funct(instrD[5:0]),
    .aluop(aluopD),
    .alucontrol(alucontrolD)
    );
    //fetchcode----decode--------------------------------
    wire [31:0] instrD;
    flopenrc  #(32) rc1(clk,rst,1'b1,1'b0,instr,instrD);
    //decode----execute-----------------------------------
    
    flopenrc  #(9) rc2 (clk,rst,1'b1,flushE,
                {regwriteD,memtoregD,memwriteD,branchD,alucontrolD,alusrcD,regdstD},
                {regwriteE,memtoregE,memwriteE,branchE,alucontrolE,alusrcE,regdstE});

    //excute----memory
    wire memtoregM,memwriteM,branchM,pcsrcM;
    flopenrc  #(4) rc3 (clk,rst,1'b1,1'b0,
                {regwriteE,memtoregE,memwriteE,branchE},
                {regwriteM,memtoregM,memwriteM,branchM});
    assign pcsrcM = zeroM & branchM;

    //memort----writeback
    wire memtoregW;
    flopenrc  #(2) rc4 (clk,rst,1'b1,1'b0,
                {regwriteM,memtoregM},
                {regwriteW,memtoregW});
endmodule




module aludec(
    input[5:0] funct,
    input[1:0] aluop,
    output[2:0] alucontrol
    );
    assign alucontrol = (aluop==2'b00)? 010: //add
                (aluop==2'b01)? 110:  //sub
                (aluop==2'b10 && funct==6'b100000)?010: //add
                (aluop==2'b10 && funct==6'b100010)?110: //sub
                (aluop==2'b10 && funct==6'b100100)?000: //and
                (aluop==2'b10 && funct==6'b100101)?001: //or
                (aluop==2'b10 && funct==6'b100110)?000: //xor  !!!!!!!!!!!!!!!!!!!!!!!!!!!!
                (aluop==2'b10 && funct==6'b101010)?111: //slt
                                                   000;
                            
endmodule

module maindec(
    input[5:0] op,
    output reg[1:0] aluop,
    output reg jump,branch,alusrc,memwrite,memtoreg,regwrite,regdst
    );
    //像学长那样用先拼接为六位，就可以直接写六个值了，更简单方便。
    always @(*) begin
        case(op)
            6'b000000: begin
                regwrite=1; regdst=1;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=10;jump=0;
            end
            6'b100011:begin
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=1;aluop=00;jump=0;
            end
            6'b101011:begin
                regwrite=0;regdst=0;alusrc=1;branch=0;memwrite=1;memtoreg=0;aluop=00;jump=0;
            end
            6'b000100:begin
                regwrite=0;regdst=0;alusrc=0;branch=1;memwrite=0;memtoreg=0;aluop=01;jump=0;
            end
            6'b001000:begin
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;
            end
            6'b000010:begin
                regwrite=0;regdst=0;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=1;
            end
            default:begin
                regwrite=0; regdst=0;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;
            end
        endcase
    end

endmodule
