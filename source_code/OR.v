module OR(a,b,out,clk);
input a,b,clk;
output reg out;
always @(a or b)
begin
out = a | b;
end
initial
begin
	out=0;
end
endmodule
