
module extend(
    input [15:0] in,
    input ExtOp,
    output reg[31:0] out
    );
	
	always@(in or ExtOp)begin
		if(ExtOp == 1) out = {{16{in[15]}},in[15:0]};
		else out = {{16{1'b0}},in[15:0]};
	end

endmodule
