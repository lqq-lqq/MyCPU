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

//控制信号的生成
module controller(
    input [31:0] instrD,
    input zeroM,flushE,clk,rst, 
    output alusrcE,memwriteM,memtoregW,regwriteM,regdstE,rd_31E,write_pc_plus8M,write_pc_plus8W,jump_regD,regwriteW,branchD,regwriteE,memtoregM,memtoregE,
    output jumpD,   
    output[2:0] alucontrolE   //E阶段进行计算
    //pcsrcM,
    );

    wire memwriteE,branchE;
    wire regwriteD,memtoregD,memwriteD,alusrcD,regdstD,rd_31D;
    wire [2:0] alucontrolD;
    wire[1:0] aluopD;
    wire write_pc_plus8D,write_pc_plus8E;   //pc_plus8W--写回pc+8
    //wire jumpD;  
    maindec u1(
    .op(instrD[31:26]), //取前六位表示操作，生成控制信号
    .funct(instrD[5:0]),
    .aluop(aluopD),
    .jump(jumpD),
    .branch(branchD),
    .alusrc(alusrcD),
    .memwrite(memwriteD),
    .memtoreg(memtoregD),
    .regwrite(regwriteD),
    .regdst(regdstD),
    .rd_31(rd_31D),
    .write_pc_plus8(write_pc_plus8D),
    .jump_reg(jump_regD)
    );

    aludec t1(
    .funct(instrD[5:0]),
    .aluop(aluopD),
    .alucontrol(alucontrolD)
    );
    //fetchcode----decode--------------------------------
    // wire [31:0] instrD;
    // flopenrc  #(32) rc1(clk,rst,1'b1,1'b0,instr,instrD);
    //decode----execute-----------------------------------
    
//    flopenrc  #(9) rc2 (clk,rst,1'b1,flushE,
//                {regwriteD,memtoregD,memwriteD,branchD,alucontrolD,alusrcD,regdstD,rd_31D,write_pc_plus8D},
//                {regwriteE,memtoregE,memwriteE,branchE,alucontrolE,alusrcE,regdstE,rd_31E,write_pc_plus8E});
//分开来写！！！！一起写会报错，个别量无法赋值
    flopenrc  #(9) rc11 (clk,rst,1'b1,flushE,regwriteD,regwriteE);  
    flopenrc  #(9) rc12 (clk,rst,1'b1,flushE,memtoregD,memtoregE);  
    flopenrc  #(9) rc13 (clk,rst,1'b1,flushE,memwriteD,memwriteE);
    flopenrc  #(9) rc14 (clk,rst,1'b1,flushE,branchD,branchE);
    flopenrc  #(9) rc15 (clk,rst,1'b1,flushE,alucontrolD,alucontrolE);
    flopenrc  #(9) rc16 (clk,rst,1'b1,flushE,alusrcD,alusrcE);
    flopenrc  #(9) rc17 (clk,rst,1'b1,flushE,regdstD,regdstE);
    flopenrc  #(9) rc18 (clk,rst,1'b1,flushE,rd_31D,rd_31E);
    flopenrc  #(9) rc19 (clk,rst,1'b1,flushE,write_pc_plus8D,write_pc_plus8E);        

    //excute----memory
    wire branchM;
    flopenrc  #(5) rc3 (clk,rst,1'b1,1'b0,
                {regwriteE,memtoregE,memwriteE,branchE,write_pc_plus8E},
                {regwriteM,memtoregM,memwriteM,branchM,write_pc_plus8M});
    //assign pcsrcM = zeroM & branchM;

    //memort----writeback
    flopenrc  #(3) rc4 (clk,rst,1'b1,1'b0,
                {regwriteM,memtoregM,write_pc_plus8M},
                {regwriteW,memtoregW,write_pc_plus8W});
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

//判断指令类型，并生成相应的控制信号
module maindec(
    input[5:0] op,funct,
    output reg[1:0] aluop,
    output reg jump,branch,alusrc,memwrite,memtoreg,regwrite,regdst,rd_31,write_pc_plus8,jump_reg
    );
    //rd_31表示选择rd还是31
    //增加
    //regdst,1:rd, 0:rt
    //write_pc_plus8表示写回寄存器的值为pc＋8
    //jump_reg跳转到寄存器的值
    always @(*) begin
        case(op)
            6'b000000: begin
                case(funct)
                    6'b001001: begin  //jalr:无条件寄存器,将pc+8存储至rd寄存器
                        regwrite=1; regdst=1;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=10;jump=1;
                        rd_31=1;write_pc_plus8=1;jump_reg=1;
                    end
                    6'b001000: begin   //jr:无条件寄存器,将pc+8存储至31号寄存器
                        regwrite=1; regdst=1;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=10;jump=1;
                        rd_31=0;write_pc_plus8=1;jump_reg=1;
                    end
                    default:begin  //其他R指令
                        regwrite=1; regdst=1;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=10;jump=0;
                        rd_31=1;write_pc_plus8=0;jump_reg=0;
                    end
                endcase
            end
            6'b000011:begin   //jal
                regwrite=1; regdst=1;alusrc=1;branch=0;memwrite=0;memtoreg=0;aluop=10;jump=1;
                rd_31=0;write_pc_plus8=1;jump_reg=0;
            end 
            6'b100011:begin   //lw
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=1;aluop=00;jump=0;
                rd_31=1;write_pc_plus8=0;jump_reg=0;
            end 
            6'b101011:begin  //sw
                regwrite=0;regdst=0;alusrc=1;branch=0;memwrite=1;memtoreg=0;aluop=00;jump=0;
                rd_31=1;write_pc_plus8=0;jump_reg=0;
            end
            6'b000100:begin  //beq
                regwrite=0;regdst=0;alusrc=0;branch=1;memwrite=0;memtoreg=0;aluop=01;jump=0;
                rd_31=1;write_pc_plus8=0;jump_reg=0;
            end
            6'b001000:begin  //addi
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;
                rd_31=1;write_pc_plus8=0;jump_reg=0;
            end
            6'b000010:begin   //j    无条件直接跳转
                regwrite=0;regdst=0;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=1;
                rd_31=1;write_pc_plus8=0;jump_reg=0;
            end
            //增加
            6'b001001:begin //addiu，直接复用addi
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;
                rd_31=1;write_pc_plus8=0;jump_reg=0;
            end
            default:begin
                regwrite=0; regdst=0;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;
                rd_31=1;write_pc_plus8=0;jump_reg=0;
            end
        endcase
    end

endmodule
