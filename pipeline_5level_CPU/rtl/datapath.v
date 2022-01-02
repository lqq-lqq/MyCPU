`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/03 21:48:30
// Design Name: 
// Module Name: datapath
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

//好像没有jump的实现？？？-----增加了jump的实�?
//好像在regfile前少了一些多选器？？�?---已解�?
//全程rsD,rtD都是用的instrD[25:21],instrD[20:16]
//pc，instr都是F阶段�?
module datapath(
    input clk,rst,
    output[31:0] writedataM,
    output[31:0] aluoutM,
    output[31:0] pc,
    output zeroM,
    input alusrcE,memtoregW,regdstE,rd_31E,regwriteM,regwriteW,branchD,memtoregE,regwriteE,memtoregM,jumpD,
    input [2:0] alucontrolE,
    input[31:0] instr,
    output[31:0] instrD,
    input [31:0] readdataM, 
    output wire flushE
    );
//input pcsrcD,branchD,jumpD
//output eqaulD
//output [5:0] opD,functD


wire pcsrcD;
wire [4:0] rtE,rdE,rsE;
wire [31:0] signimmE,pc_plus4E,readdata1D,readdata2D,writedataE,readdata1E,readdata2E;
// wire [31:0] instrD; //instr in decode stage
wire [31:0] pc_plus4D;
wire [31:0] pc_plus4F;
wire [31:0] pc_branch_plus4FD,pcnextFD;
wire[31:0] aluoutW;
wire[4:0] writeregW;
wire [31:0] aluoutE;
wire [4:0] writeregM;
wire zeroE;
wire [31:0] pc_branchD;
wire[31:0] target_offsetD;
wire [4:0] writeregE;
wire[1:0] forwardAE,forwardBE;
wire lwstall,stallD,stallF;
wire forwardAD,forwardBD;
wire [31:0] resultW;
wire [31:0] readdataW;
wire [31:0] srcB3E; //三�?�出来的srcBE

//���ӵı���
wire jumpE;


// Fetch - Decode------------------------------------
//mux for pc_branch or pc_plus4

//��֧��ת����+4
mux2 #(32) mux4
(
    .A(pc_branchD),  //1的话就choose前面�?�?  pcbranchD，不是原来的pcbranchM了，因为分支判断提前了！！！！！！！！！�?
    .B(pc_plus4F), //????????????????????????
    .choose(pcsrcD), //1: branch
    .C(pc_branch_plus4FD)
    );
//����ֱ����ת
mux2 #(32) mux5
(
    .A({pc_plus4D[31:28],instrD[25:0],2'b00}),  //��������תָ���pc
    .B(pc_branch_plus4FD),
    .choose(jumpD), //1: pc_jump
    .C(pcnextFD)
    );
//pc change
pc pc1(
    .clk(clk),
    .rst(rst),
    .en(~stallF),
    .pc_new(pcnextFD),
    .pc(pc)
    );
//pc_plus4
adder adder_1(
	.a(pc),
    .b(32'b100),
	.y(pc_plus4F)
    );

//pc
//wire[31:0] pc_next;


//floprs
//instr: instr in fetch stage

flopenrc  #(32) rF1(clk,rst,~stallD,1'b0,instr,instrD); //flushD???????????????
flopenrc  #(32) rF(clk,rst,~stallD,1'b0,pc_plus4F,pc_plus4D);





//Decode - Execute------------------------------------
//regfile �Ĵ����ļ���
wire [31:0] srcAE;
wire [31:0] srcBE;
wire equalD;
wire[31:0] x,y;
assign pcsrcD = equalD & branchD;//??????????????????????
//����ǰ��,M�׶�ȡ����ǰ�Ƶ���һ��������
mux2 #(32) mm1
(
    .A(aluoutM),  //1
    .B(readdata1D),//0
    .choose(forwardAD), 
    .C(x)
);
//M�׶�ȡ����ǰ�Ƶ��ڶ���������
mux2 #(32) mm2
(
    .A(aluoutM),  //1
    .B(readdata2D),//0
    .choose(forwardBD), 
    .C(y)
);
assign equalD = (x==y)?1:0;  //beq ��� ��ת

regfile rf(
	.clk(clk),
	.we3(regwriteW), //1:can write  0:can't
	.ra1(instrD[25:21]),
    .ra2(instrD[20:16]),
    .wa3(writeregW),  //��д�ļĴ����ı��
	.wd3(resultW),  //д���Ĵ���������
	.rd1(readdata1D),  
    .rd2(readdata2D)
    );
//sign-extend ��������չ�����油00
wire [31:0] signimmD;
signext sign_1(
    .a(instrD[15:0]),
    .y(signimmD)
    );
sl2 sl2_1(
    .a(signimmD),
    .y(target_offsetD)
    );
 //��תָ����ת�ĵ�ַ   
adder adder_2(
	.a(target_offsetD),
    .b(pc_plus4D),
	.y(pc_branchD)
);



flopenrc  #(5) r3(clk,rst,1'b1,flushE,instrD[15:11],rdE);
flopenrc  #(5) r4(clk,rst,1'b1,flushE,instrD[20:16],rtE);
flopenrc  #(5) r10(clk,rst,1'b1,flushE,instrD[25:21],rsE);
flopenrc  #(32) r5(clk,rst,1'b1,flushE,signimmD,signimmE);
flopenrc  #(32) r6(clk,rst,1'b1,flushE,pc_plus4D,pc_plus4E);
flopenrc  #(32) r7(clk,rst,1'b1,flushE,readdata1D,readdata1E);
flopenrc  #(32) r8(clk,rst,1'b1,flushE,readdata2D,readdata2E);

//���� 
flopenrc  #(32) r9(clk,rst,1'b1,flushE,jumpD,jumpE);


//Execute - Memory-----------------------------------
//pc_branch

//mux for the reg rt and rd  
wire[4:0] writereg1E;
//����
//�����jalָ�rdΪ31
mux2 #(5) mux11(
    .A(rdE),  //1:��ʾ���Ϊjalrָ���������������ָ���Ҫȡrd
    .B(5'b11111),   //jalָ��rdĬ��Ϊ31
    .choose(rd_31E),
    .C(writereg1E)
);
mux2 #(5) mux1
(
    .A(writereg1E),  //E�׶ε�rd����instrD[15:11]->rdE
    .B(rtE),
    .choose(regdstE), //1:rd   �ĸ�reg����Ҫд�صļĴ���
    .C(writeregE)
    );

    
//alu_assign
//ѡ��alu�ĵڶ���������
mux2 #(32) mux2
(
    .A(signimmE),  //������
    .B(srcB3E),
    .choose(alusrcE), //1��ѡ���������Ŀ����ź�
    .C(srcBE) 
    );
//ѡ��alu�ĵ�һ��������
mux3 #(32) m31
(   .d0(readdata1E),//00:�Ĵ������������ĵ�һ��ֵinstr[25:21]
    .d1(resultW),//01  ��д���Ĵ������ֵ
    .d2(aluoutM),//10  //alu�������������һ�����ڵ���
    .s(forwardAE),
    .y(srcAE)
);

mux3 #(32) m32
(   .d0(readdata2E),//00:readdata2
    .d1(resultW),//01
    .d2(aluoutM),//10
    .s(forwardBE),
    .y(srcB3E)   //三�?�出来的srcBE
);
//����
alu alu1(
    .A(srcAE),
    .B(srcBE),
    .result(aluoutE),
    .op(alucontrolE),
    .zero(zeroE) //�Ƿ�Ϊ0
    );
assign writedataE = srcB3E;
flopenrc  #(32) r29(clk,rst,1'b1,1'b0,writedataE,writedataM);
flopenrc  #(32) r100(clk,rst,1'b1,1'b0,aluoutE,aluoutM);
flopenrc  #(5) r14(clk,rst,1'b1,1'b0,writeregE,writeregM);
flopenrc  #(1) r12(clk,rst,1'b1,1'b0,zeroE,zeroM);

//Memory - Writeback----------------------------------

flopenrc  #(32) r13(clk,rst,1'b1,1'b0,aluoutM,aluoutW);
flopenrc  #(5) r15(clk,rst,1'b1,1'b0,writeregM,writeregW);
flopenrc  #(32) r20(clk,rst,1'b1,1'b0,readdataM,readdataW);
//Writeback ------------------------------------------

//mux for alu or the readata from the data memory
mux2 #(32) mux3
(
    .A(readdataW),  //1:M�׶δ�memory��������ֵ
    .B(aluoutW),   //0 ��alu�������ֵ
    .choose(memtoregW), //1: from memory
    .C(resultW)  //�õ�����д�ؼĴ�����ֵ
    );

//冒险

hazard h( 
    .regwriteM(regwriteM),
    .regwriteW(regwriteW),
    .memtoregE(memtoregE),
    .branchD(branchD),
    .regwriteE(regwriteE),
    .memtoregM(memtoregM),
    .rsD(instrD[25:21]),
    .rtD(instrD[20:16]),
    .rsE(rsE),
    .rtE(rtE),
    .writeregM(writeregM),
    .writeregW(writeregW),
    .forwardAE(forwardAE),
    .forwardBE(forwardBE),
    .stallF(stallF),
    .stallD(stallD),
    .flushE(flushE),
    .forwardAD(forwardAD),
    .forwardBD(forwardBD),
    .writeregE(writeregE)
);
endmodule
