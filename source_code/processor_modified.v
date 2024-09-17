module processor;

reg [31:0] pc;

reg clk;
reg [7:0] datmem[0:63], mem[0:63]; // total number of memory place = 32

wire [31:0] dataa,datab;
wire [31:0] out2,out3,out4; 
wire [31:0] sum, extad, adder1out, adder2out;
wire [31:0] sextad,readdata;

wire [5:0] inst31_26;
wire [4:0] inst25_21, inst20_16, inst15_11, out1;
wire [15:0] inst15_0;
wire [17:0] sign_extended_inst15_0; // for bvf and ben
wire [31:0] instruc,dpack;
wire [2:0] gout;
wire [25:0] inst25_0; // for jump
wire [27:0] sign_extended_jump; // after jump goes through sll2

wire [31:0] pc_and_sign_extended_jump_concatenated; // the jump instruction with last four bits of pc concatenated
// I later removed this after realizing I can just concatenate things while using as an argument (see the jump implementation section below for the commented out code, about 106th line)

wire [31:0] from_branch_to_jump_multiplexer;
wire [31:0] from_jump_to_bvf_multiplexer;
wire [31:0] from_bvf_to_ben_multiplexer;
wire [31:0] sign_extended_bvf_ben;

wire [2:0] svz;

wire cout,zout,nout,pcsrc,regdest,alusrc,memtoreg,regwrite,memread,
memwrite,branch,aluop1,aluop0,ben_signal_coming_from_controller,bvf_signal_coming_from_controller,
jump_signal_coming_from_controller,overflow_out_alu,
and_1_out, and_2_out, and_3_out, and_4_out, and_5_out, and_6_out, or_1_out;

reg [31:0] registerfile [0:31]; // total number of registers = 32
integer i;

// datamemory connections
always @(posedge clk)
begin
	if(memwrite)
	begin 
		datmem[sum[4:0]+3]=datab[7:0];
		datmem[sum[4:0]+2]=datab[15:8];
		datmem[sum[4:0]+1]=datab[23:16];
		datmem[sum[4:0]]=datab[31:24];
	end
end

//instruction memory
assign instruc = {mem[pc[4:0]],
					mem[pc[4:0]+1],
					mem[pc[4:0]+2],
					mem[pc[4:0]+3]};
assign inst31_26 = instruc[31:26];
assign inst25_21 = instruc[25:21];
assign inst20_16 = instruc[20:16];
assign inst15_11 = instruc[15:11];
assign inst15_0 = instruc[15:0];
assign inst25_0 = instruc[25:0]; // for jump

// registers
assign dataa = registerfile[inst25_21];
assign datab = registerfile[inst20_16];

//multiplexers
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest); // left of registers
mult2_to_1_32 mult2(out2, datab, extad, alusrc); // right of registers
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg); // right of data memory
mult2_to_1_32 mult4(from_branch_to_jump_multiplexer, adder1out,adder2out,pcsrc); // choose whether branch

always @(posedge clk)
begin
	registerfile[out1]= regwrite ? out3 : registerfile[out1];
end


// load pc
always @(posedge clk)
pc = out4;

// alu, adder and control logic connections

alu32_modified alu1(sum, dataa, out2, zout, gout, overflow_out_alu);
adder add1(pc,32'h4,adder1out);
adder add2(adder1out,sextad,adder2out);
/*
control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2);
*/
control_modified cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0, ben_signal_coming_from_controller, bvf_signal_coming_from_controller, jump_signal_coming_from_controller);

signext sext(instruc[15:0],extad);

alucont_modified acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0],gout);

shift shift2(sextad,extad);

// Added for jump (ref page 19 09 processor slide)

shift_for_jump_operation shift_for_jump_operation1(sign_extended_jump, inst25_0);
// assign pc_and_sign_extended_jump_concatenated = {adder1out[31:28], sign_extended_jump}; // adder1 out is PC + 4
mult2_to_1_32 multiplexer_to_choose_whether_jump(from_jump_to_bvf_multiplexer, from_branch_to_jump_multiplexer, 
{adder1out[31:28], sign_extended_jump}, jump_signal_coming_from_controller);

// Added for jump

// added multiplexers for ben and bvf jump

signext signext_bvf_ben(inst15_0, sign_extended_bvf_ben);
mult2_to_1_32 multiplexer_to_choose_whether_bvf(from_bvf_to_ben_multiplexer, from_jump_to_bvf_multiplexer, sign_extended_bvf_ben, and_1_out);
mult2_to_1_32 multiplexer_to_choose_whether_ben(out4, from_bvf_to_ben_multiplexer, sign_extended_bvf_ben, and_2_out);

// added for ben and bvf jump

// added for cpsr
AND cpsr_and1(bvf_signal_coming_from_controller, svz[1], and_1_out, clk);
AND cpsr_and2(ben_signal_coming_from_controller, or_1_out, and_2_out, clk);
AND cpsr_and3(~and_1_out, ~and_2_out, and_3_out, clk);
AND cpsr_and4(zout, and_3_out, and_4_out, clk);
AND cpsr_and5(overflow_out_alu, and_3_out, and_5_out, clk);
AND cpsr_and6(sum[31], and_3_out, and_6_out, clk);
OR cpsr_or1(svz[2], svz[0], or_1_out, clk);
CPSR cpsr1(and_6_out, and_5_out, and_4_out, svz, clk);
// added for cpsr

assign pcsrc = branch && zout;

//initialize datamemory,instruction memory and registers
initial
begin
	$readmemh("G:/deneme/example_test_code_initdata.dat",datmem);
	$readmemh("G:/deneme/example_test_code_init.dat",mem);
	$readmemh("G:/deneme/example_test_code_initreg.dat",registerfile);

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
	pc=0;
	#400 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial 
begin
	$monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
	"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end

endmodule

