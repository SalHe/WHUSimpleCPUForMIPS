`include "ctrl_encode_def.v"
`include "instruction_def.v"

module ctrl(
           input [5: 0] opcode,
           input [5: 0] func,
           output reg [1: 0] RegDst,
           output reg ALUSrc,
           output reg MemRead,
           output reg RegWrite,
           output reg MemWrite,
           output reg [1: 0] DatatoReg,
           output reg [1: 0] PC_sel,
           output reg ExtOp,
           output reg [4: 0] ALUCtrl
       );

always @(opcode or func ) begin
    case (opcode)
        //addu,subu
        `INSTR_RTYPE_OP:          // R type
        case (func)
            // add
            `INSTR_ADD_FUNCT: begin
                RegDst = `REG_MUX_SEL_RD;  // 写入 rt。ins[20:16]
                RegWrite = 1;

                ALUSrc = `ALU_SRC_MUX_SEL_REG; // 立即数
                ALUCtrl = `ALUOp_ADD;

                MemRead = 0;
                MemWrite = 0;

                DatatoReg = `DR_MUX_SEL_ALU;

                PC_sel = `PC_MUX_SEL_NEWPC;

                ExtOp = `EXT_SIGNED;
            end


            //addu
            `INSTR_ADDU_FUNCT: begin
                RegDst = 2'b01;
                ALUSrc = 0;
                MemRead = 0;
                RegWrite = 1;
                MemWrite = 0;
                DatatoReg = 2'b00;
                PC_sel = 2'b00;
                ExtOp = 0;
                ALUCtrl = `ALUOp_ADDU;

            end

            //subu
            `INSTR_SUBU_FUNCT: begin
                RegDst = 2'b01;
                ALUSrc = 0;
                MemRead = 0;
                RegWrite = 1;
                MemWrite = 0;
                DatatoReg = 2'b00;
                PC_sel = 2'b00;
                ExtOp = 0;
                ALUCtrl = `ALUOp_SUBU;

            end

        endcase //the end of the func

        //ori
        `INSTR_ORI_OP:         //6'b001101:
        begin
            RegDst = 2'b00;
            ALUSrc = 1;
            MemRead = 0;
            RegWrite = 1;
            MemWrite = 0;
            DatatoReg = 2'b00;
            PC_sel = 2'b00;
            ExtOp = 0;
            ALUCtrl = `ALUOp_OR;
        end

        //beq
        `INSTR_BEQ_OP: begin
            RegDst = 2'b00;
            ALUSrc = 0;
            MemRead = 0;
            RegWrite = 0;
            MemWrite = 0;
            DatatoReg = 2'b00;
            PC_sel = 2'b01;
            ExtOp = 0;
            ALUCtrl = `ALUOp_EQL;
        end

        // 作业部分

        // TODO: lw
        // TODO: sw
        // TODO: sub
        // TODO: or
        // TODO: and
        // TODO: addi

        // lui 设置高位
        `INSTR_LUI_OP: begin
            RegDst = `REG_MUX_SEL_RT;  // 写入 rt。ins[20:16]
            RegWrite = 1;

            ALUSrc = `ALU_SRC_MUX_SEL_EXT; // 立即数
            ALUCtrl = `ALUOp_LUI;

            MemRead = 0;
            MemWrite = 0;

            DatatoReg = `DR_MUX_SEL_ALU;

            PC_sel = `PC_MUX_SEL_NEWPC;

            ExtOp = `EXT_ZERO;
        end

        // TODO: sll
        // TODO: srl
        // TODO: sra
        // TODO: bne
        // TODO: j
        // TODO: jal
        // TODO: jr
        // TODO: slt
        // TODO: slti


        default: begin
            RegDst = 2'b00;
            ALUSrc = 0;
            MemRead = 0;
            RegWrite = 0;
            MemWrite = 0;
            DatatoReg = 2'b00;
            PC_sel = 2'b00;
            ExtOp = 0;
            ALUCtrl = 3'b000;

        end

    endcase
end


endmodule
