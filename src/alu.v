
`ifndef _ALU_V_
`define _ALU_V_

`include "ctrl_encode_def.v"

        module alu(
            input [31: 0] A,  /* Read Data1 */
            input [31: 0] B,  /* ALUSrc */
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
        `ALUOp_LUI:
            C = B << 16;
        `ALUOp_ADD:
            C = A + B;
        `ALUOp_SUB:
            C = A - B;
        `ALUOp_SLT:
            C = ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;
        `ALUOp_BNE:
            zero = (A != B) ? 1'b1 : 1'b0; //bne
        `ALUOp_SLL:
            C = A << B[10:6];
        `ALUOp_SRL:
            C = A >> B[10:6];
        `ALUOp_SRA:
            C = $signed(A) >>> B[10:6];
        `ALUOp_AND:
            C = A & B;

    endcase
end



endmodule




`endif
