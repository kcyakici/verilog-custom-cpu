module control_modified(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, ben, bvf, jump);
input [5:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, ben, bvf, jump; // added 3 more instructions, nor is already r type

wire rformat,lw,sw,beq;

assign rformat =~| in;

assign lw = in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0]; // 100011

assign sw = in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0]; // 101011

assign beq = ~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]); // 000100

assign ben = (~in[5])& (~in[4])&(~in[3])&in[2]&(in[1])&(~in[0]); // 000110

assign bvf = (~in[5])& (~in[4])&(~in[3])&(in[2])&(~in[1])&(in[0]); // 000101

assign j = ~in[5]& (~in[4])& ~in[3] & (~in[2])&in[1]& ~in[0]; // 000010

assign addi = ~in[5]& (~in[4])& in[3] & (~in[2])& ~in[1]& ~in[0]; // 001000, alusrc = 1, regwrite = 1, aluop should be addition, regdest

// these are all one bit
assign regdest = rformat;
assign alusrc = lw|sw|addi; 
assign memtoreg = lw;
assign regwrite = rformat|lw|addi;
assign memread = lw;
assign memwrite = sw;
assign branch = beq;
assign aluop1 = rformat|(~addi); // two bits but shown seperately
assign aluop2 = beq|(~addi); // since when aluop1 and aluop2 are zero we do addition (lw and sw) I want to pair this behaviour for addi as well
assign jump = j;

endmodule
