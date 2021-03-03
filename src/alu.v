
`include "ctrl_encode_def.v"

module alu(
           input [31: 0] A,
           input [31: 0] B,
           input [4: 0] ALUOp,
           output reg [31: 0] C,
           output reg zero
       );


always @(A or B or ALUOp) begin
    case (ALUOp)
        `ALUOp_ADDU:
            C = A + B;         //addu
        `ALUOp_SUBU:
            C = A - B;         //subu
        `ALUOp_OR:
            C = A | B;
        `ALUOp_EQL:
            zero = (A == B) ? 1'b1 : 1'b0; //beq



    endcase
end



endmodule



