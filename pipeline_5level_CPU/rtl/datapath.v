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

//濂藉儚娌℃湁jump鐨勫疄鐜帮紵锛燂紵-----澧炲姞浜唈ump鐨勫疄鐜?
//濂藉儚鍦╮egfile鍓嶅皯浜嗕竴浜涘閫夊櫒锛燂紵锛?---宸茶В鍐?
//鍏ㄧ▼rsD,rtD閮芥槸鐢ㄧ殑instrD[25:21],instrD[20:16]
//pc锛宨nstr閮芥槸F闃舵鐨?
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
wire [31:0] srcB3E; //涓夐?夊嚭鏉ョ殑srcBE

//增加的变量
wire jumpE;


// Fetch - Decode------------------------------------
//mux for pc_branch or pc_plus4

//分支跳转还是+4
mux2 #(32) mux4
(
    .A(pc_branchD),  //1鐨勮瘽灏眂hoose鍓嶉潰涓?涓?  pcbranchD锛屼笉鏄師鏉ョ殑pcbranchM浜嗭紝鍥犱负鍒嗘敮鍒ゆ柇鎻愬墠浜嗭紒锛侊紒锛侊紒锛侊紒锛侊紒锛?
    .B(pc_plus4F), //????????????????????????
    .choose(pcsrcD), //1: branch
    .C(pc_branch_plus4FD)
    );
//还是直接跳转
mux2 #(32) mux5
(
    .A({pc_plus4D[31:28],instrD[25:0],2'b00}),  //无条件跳转指令的pc
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
//regfile 寄存器文件，
wire [31:0] srcAE;
wire [31:0] srcBE;
wire equalD;
wire[31:0] x,y;
assign pcsrcD = equalD & branchD;//??????????????????????
//数据前推,M阶段取出的前推到第一个操作数
mux2 #(32) mm1
(
    .A(aluoutM),  //1
    .B(readdata1D),//0
    .choose(forwardAD), 
    .C(x)
);
//M阶段取出的前推到第二个操作数
mux2 #(32) mm2
(
    .A(aluoutM),  //1
    .B(readdata2D),//0
    .choose(forwardBD), 
    .C(y)
);
assign equalD = (x==y)?1:0;  //beq 相等 跳转

regfile rf(
	.clk(clk),
	.we3(regwriteW), //1:can write  0:can't
	.ra1(instrD[25:21]),
    .ra2(instrD[20:16]),
    .wa3(writeregW),  //被写的寄存器的编号
	.wd3(resultW),  //写进寄存器的数据
	.rd1(readdata1D),  
    .rd2(readdata2D)
    );
//sign-extend 立即数拓展，后面补00
wire [31:0] signimmD;
signext sign_1(
    .a(instrD[15:0]),
    .y(signimmD)
    );
sl2 sl2_1(
    .a(signimmD),
    .y(target_offsetD)
    );
 //跳转指令跳转的地址   
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

//增加 
flopenrc  #(32) r9(clk,rst,1'b1,flushE,jumpD,jumpE);


//Execute - Memory-----------------------------------
//pc_branch

//mux for the reg rt and rd  
wire[4:0] writereg1E;
//增加
//如果是jal指令，rd为31
mux2 #(5) mux11(
    .A(rdE),  //1:表示这个为jalr指令或其他的正常的指令，需要取rd
    .B(5'b11111),   //jal指令rd默认为31
    .choose(rd_31E),
    .C(writereg1E)
);
mux2 #(5) mux1
(
    .A(writereg1E),  //E阶段的rd，，instrD[15:11]->rdE
    .B(rtE),
    .choose(regdstE), //1:rd   哪个reg是需要写回的寄存器
    .C(writeregE)
    );

    
//alu_assign
//选择alu的第二个操作数
mux2 #(32) mux2
(
    .A(signimmE),  //立即数
    .B(srcB3E),
    .choose(alusrcE), //1：选择立即数的控制信号
    .C(srcBE) 
    );
//选择alu的第一个操作数
mux3 #(32) m31
(   .d0(readdata1E),//00:寄存器里面读完出的第一个值instr[25:21]
    .d1(resultW),//01  ：写进寄存器里的值
    .d2(aluoutM),//10  //alu算出来的数的下一个周期的数
    .s(forwardAE),
    .y(srcAE)
);

mux3 #(32) m32
(   .d0(readdata2E),//00:readdata2
    .d1(resultW),//01
    .d2(aluoutM),//10
    .s(forwardBE),
    .y(srcB3E)   //涓夐?夊嚭鏉ョ殑srcBE
);
//计算
alu alu1(
    .A(srcAE),
    .B(srcBE),
    .result(aluoutE),
    .op(alucontrolE),
    .zero(zeroE) //是否为0
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
    .A(readdataW),  //1:M阶段从memory读出来的值
    .B(aluoutW),   //0 ；alu算出来的值
    .choose(memtoregW), //1: from memory
    .C(resultW)  //得到真正写回寄存器的值
    );

//鍐掗櫓

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
