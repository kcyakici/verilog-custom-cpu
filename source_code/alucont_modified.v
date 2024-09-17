module alucont_modified(aluop1,aluop0,f3,f2,f1,f0,gout);

input aluop1,aluop0,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;

always @(aluop1 or aluop0 or f3 or f2 or f1 or f0) // funct fields
begin
	if(~(aluop1|aluop0)) // lw or sw, both do addition
		gout=3'b010;
	if(aluop0) // beq, subtraction
		gout=3'b110;
	if(aluop1) // r type
	begin
		if (~(f3|f2|f1|f0))
			gout=3'b010; // addition
		if (f1 & ~f2 & f3 & ~f0) 
			gout=3'b111; // set less than
		if (f1 &~(f3) & ~f0 & ~f2) 
			gout=3'b110; // subtract 001000
		if (f2 & f0 & ~f1 & ~f3) 
			gout=3'b001; // or
		if (f2 &~(f0) & ~f1 & ~f3) 
			gout=3'b000; // and
		if (f2 & f1 & f3 & f0) // XOR
			gout = 3'b011;
		if (~f3 & f2 & f1 & f0) // it was not taken, so I will use it for nor 000111
			gout = 3'b100;
	end
end
endmodule
