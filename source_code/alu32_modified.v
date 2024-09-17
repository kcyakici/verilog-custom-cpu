module alu32_modified(alu_out, a, b, zout, alu_control, overflow);
output reg [31:0] alu_out;
input [31:0] a,b;

input [2:0] alu_control;

reg [31:0] less;
output zout, overflow;
reg zout, overflow;

always @(a or b or alu_control) // execute when a or b or alu_control change (like at event)
begin
	/*
	there are 5 type of instructions which are 
	2) sum = a + b
	6) sum = a - b
	7) 
	*/
	case(alu_control)
		3'b010: begin alu_out = a+b; // add
				overflow = ((a[31])&(b[31])&(~alu_out[31]) | (~(a[31])&~(b[31])&alu_out[31]));
			end
		3'b110: begin alu_out = a+1+(~b); // subtract
				overflow = (a[31]&~b[31]&(~alu_out[31]) | (~(a[31])&(b[31])&alu_out[31]));
			end
	3'b111: begin less = a+1+(~b); // set on less than
			if (less[31]) alu_out = 1;
			else alu_out=0;
		end
	/*
	0) a AND b
	1) a OR b
	*/
		3'b000: alu_out = a & b; // bitwise and
		3'b001: alu_out = a | b; // bitwise or
		3'b011: alu_out = a ^ b; //bitwise XOR
		3'b100: alu_out = ~(a|b); // NOR
		default: alu_out = 31'bx;
	endcase
zout = ~(|alu_out);
end
endmodule