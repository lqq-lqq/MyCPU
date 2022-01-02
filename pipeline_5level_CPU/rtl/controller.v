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

//�����źŵ�����
module controller(
    input [31:0] instrD,
    input zeroM,flushE,clk,rst, 
    output alusrcE,memwriteM,memtoregW,regwriteM,regdstE,rd_31E,regwriteW,branchD,regwriteE,memtoregM,memtoregE,
    output jumpD,
    output[2:0] alucontrolE   //E�׶ν��м���
    //pcsrcM,
    );

    wire memwriteE,branchE;
    wire regwriteD,memtoregD,memwriteD,alusrcD,regdstD,rd_31D;
    wire [2:0] alucontrolD;
    wire[1:0] aluopD;
    //wire jumpD;  
    maindec u1(
    .op(instrD[31:26]), //ȡǰ��λ��ʾ���������ɿ����ź�
    .aluop(aluopD),
    .jump(jumpD),
    .branch(branchD),
    .alusrc(alusrcD),
    .memwrite(memwriteD),
    .memtoreg(memtoregD),
    .regwrite(regwriteD),
    .regdst(regdstD),
    .rd_31(rd_31D)
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
    
    flopenrc  #(9) rc2 (clk,rst,1'b1,flushE,
                {regwriteD,memtoregD,memwriteD,branchD,alucontrolD,alusrcD,regdstD,rd_31D},
                {regwriteE,memtoregE,memwriteE,branchE,alucontrolE,alusrcE,regdstE,rd_31E});

    //excute----memory
    wire branchM;
    flopenrc  #(4) rc3 (clk,rst,1'b1,1'b0,
                {regwriteE,memtoregE,memwriteE,branchE},
                {regwriteM,memtoregM,memwriteM,branchM});
    //assign pcsrcM = zeroM & branchM;

    //memort----writeback
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

//�ж�ָ�����ͣ���������Ӧ�Ŀ����ź�
module maindec(
    input[5:0] op,
    output reg[1:0] aluop,
    output reg jump,branch,alusrc,memwrite,memtoreg,regwrite,regdst,rd_31
    );
    //rd_31��ʾѡ��rd����31
    //����
    //regdst,jalָ����31����jalrָ��Ϊrd��������Ҫѡ������jump�ź��������ж�
    always @(*) begin
        case(op)
            6'b000000: begin   //���ӣ���jalr:�������Ĵ�����ת���ӳ��򲢱��淵�ص�ַ��, or:λ�� ��jr�������Ĵ�����ת
                regwrite=1; regdst=1;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=10;jump=0;rd_31=1;
            end
            6'b100011:begin   //lw
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=1;aluop=00;jump=0;rd_31=1;
            end 
            6'b101011:begin  //sw
                regwrite=0;regdst=0;alusrc=1;branch=0;memwrite=1;memtoreg=0;aluop=00;jump=0;rd_31=1;
            end
            6'b000100:begin  //beq
                regwrite=0;regdst=0;alusrc=0;branch=1;memwrite=0;memtoreg=0;aluop=01;jump=0;rd_31=1;
            end
            6'b001000:begin  //addi
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;rd_31=1;
            end
            6'b000010:begin   //j    ������ֱ����ת
                regwrite=0;regdst=0;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=1;rd_31=1;
            end
            //����
            6'b001001:begin //addiu��ֱ�Ӹ���addi
                regwrite=1; regdst=0;alusrc=1;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;rd_31=1;
            end
            6'b000011:begin  //jal  ������ֱ����ת���ӳ��򲢱��淵�ص�ַ������pc+8��ͨ�üĴ���GPR[31]
                regwrite=1;regdst=0;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=1;rd_31=0;
            end
            default:begin
                regwrite=0; regdst=0;alusrc=0;branch=0;memwrite=0;memtoreg=0;aluop=00;jump=0;rd_31=1;
            end
        endcase
    end

endmodule
