module CPSR(negative_flag_and, overflow_and, zero_flag_and, svz, clk);

input negative_flag_and, overflow_and, zero_flag_and, clk;

output reg [2:0] svz;

always @(posedge clk)
begin
	svz[0] = zero_flag_and;
	svz[1] = overflow_and;
	svz[2] = negative_flag_and;

	// case(add_sub_bit)
	// 	2'b00: begin
	// 			if(~(a_most_significant) & ~(b_most_significant) & alu_out_most_significant) svz[1] = 1; // two pos add results in neg
	// 			else if ((a_most_significant) & (b_most_significant) & ~(alu_out_most_significant)) svz[1] = 1; // two neg add results in pos
	// 		end
	// 	2'b01: begin
	// 			if((a_most_significant) & ~(b_most_significant) & ~alu_out_most_significant) svz[1] = 1; // a - b results in pos (a=neg b=pos)
	// 			else if (~(a_most_significant) & (b_most_significant) & (alu_out_most_significant)) svz[1] = 1; // a - b results in neg (a=pos b=neg)
	// 		end
	// 	2'b11: svz[1] = 0 // no overflow
	// endcase
end
initial
begin
	svz[0]=0;
	svz[1]=0;
	svz[2]=0;
end
endmodule