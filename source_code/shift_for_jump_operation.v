module shift_for_jump_operation(shout, shin);
output [27:0] shout;
input [25:0] shin;
assign shout=shin<<2;
endmodule
