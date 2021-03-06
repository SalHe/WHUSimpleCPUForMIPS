`ifndef _PC_V_
`define _PC_V_

module pc(
           input [31: 0] newpc,
           input clk,
           input reset,
           output [31: 0] oldpc
       );

reg [31: 0] _pc;

always@(posedge clk or posedge reset)
    //always@(posedge clk)
begin
    if (reset)
        // 老师给的源代码里是这样的
        // 不知道为什么要写成h00003000
        // _pc <= 32'h00003000;

        // _pc <= 32'h00000000;
        
        // 配合Mars软件问题
        // 代码段从 3000H 开始
        _pc <= 32'h00003000;

    else begin
        _pc <= newpc;
    end
end

assign oldpc = _pc;

endmodule

`endif