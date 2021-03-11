`ifndef _CTRL_V_
`define _CTRL_V_

`include "ctrl_encode_def.v"
`include "instruction_def.v"

        module ctrl(
            input [5: 0] opcode,
            input [5: 0] func,
            output reg [1: 0] RegDst,
            output reg ALUSrc,
            output reg ALUSrc2,
            output reg MemRead,
            output reg RegWrite,
            output reg MemWrite,
            output reg [1: 0] DatatoReg,
            output reg [1: 0] PC_sel,
            output reg ExtOp,
            output reg [4: 0] ALUCtrl,
            output reg [1: 0] IsJump
        );

always @(opcode or func ) begin

    // 原有设计无法满足某些指令的需求
    // 故对模块进行了扩展
    // 也可能是我没找到解决方案。。。
    IsJump = 0;
    ALUSrc2 = `ALU_SRC_MUX_SEL_REGA;

    case (opcode)
        //addu,subu
        `INSTR_RTYPE_OP:          // R type
        case (func)
            // add
            `INSTR_ADD_FUNCT: begin
                RegDst = `REG_MUX_SEL_RD;
                RegWrite = 1;

                ALUSrc = `ALU_SRC_MUX_SEL_REG; // 立即数
                ALUCtrl = `ALUOp_ADD;

                MemRead = 0;
                MemWrite = 0;

                DatatoReg = `DR_MUX_SEL_ALU;

                PC_sel = `PC_MUX_SEL_NEWPC;

                ExtOp = `EXT_SIGNED;
            end

            // sub
            `INSTR_SUB_FUNCT: begin
                RegDst = `REG_MUX_SEL_RD;  // 写入 rt。ins[20:16]
                RegWrite = 1;
                DatatoReg = `DR_MUX_SEL_ALU;

                ALUSrc = `ALU_SRC_MUX_SEL_REG; // 立即数
                ALUCtrl = `ALUOp_SUB;

                MemRead = 0;
                MemWrite = 0;

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

            // slt
            // if (rs < rt) rd=1 else rd=0
            `INSTR_SLT_FUNCT: begin
                RegDst = `REG_MUX_SEL_RD;
                RegWrite = 1;
                DatatoReg = `DR_MUX_SEL_ALU;

                ALUSrc = `ALU_SRC_MUX_SEL_REG;
                ALUCtrl = `ALUOp_SLT;

                MemRead = 0;
                MemWrite = 0;

                PC_sel = `PC_MUX_SEL_NEWPC;

                ExtOp = `EXT_SIGNED;
            end

            // sll
            // 	rd <- rt << shamt; （shamt为 imm[10..6]）
            `INSTR_SLL_FUNCT: begin

                /*
                // Read Addr1, Read Addr2

                // 总为0？？？
                Instrl[25: 21], // rs -> Data1

                Instrl[20: 16], // rt -> Data2
                */

                RegDst = `REG_MUX_SEL_RD;
                RegWrite = 1;
                DatatoReg = `DR_MUX_SEL_ALU;

                // 将立即数无符号扩展传给ALU
                // ALU选取立即数中[10..6]即可拿到shamt
                ALUSrc = `ALU_SRC_MUX_SEL_EXT;
                ALUSrc2 = `ALU_SRC_MUX_SEL_REGB;
                ALUCtrl = `ALUOp_SLL;

                MemRead = 0;
                MemWrite = 0;

                PC_sel = `PC_MUX_SEL_NEWPC;

                ExtOp = `EXT_ZERO;
            end

            // srl
            // 	 rd <- rt >> shamt （shamt为 imm[10..6]）
            `INSTR_SRL_FUNCT: begin
                RegDst = `REG_MUX_SEL_RD;
                RegWrite = 1;
                DatatoReg = `DR_MUX_SEL_ALU;

                // 将立即数无符号扩展传给ALU
                // ALU选取立即数中[10..6]即可拿到shamt
                ALUSrc = `ALU_SRC_MUX_SEL_EXT;
                ALUSrc2 = `ALU_SRC_MUX_SEL_REGB;
                ALUCtrl = `ALUOp_SRL;

                MemRead = 0;
                MemWrite = 0;

                PC_sel = `PC_MUX_SEL_NEWPC;

                ExtOp = `EXT_ZERO;
            end

            // sra
            // 	rd <- rt >> shamt  ；(arithmetic) 注意符号位保留（shamt为 imm[10..6]）
            `INSTR_SRA_FUNCT: begin
                RegDst = `REG_MUX_SEL_RD;
                RegWrite = 1;
                DatatoReg = `DR_MUX_SEL_ALU;

                // 将立即数无符号扩展传给ALU
                // ALU选取立即数中[10..6]即可拿到shamt
                ALUSrc = `ALU_SRC_MUX_SEL_EXT;
                ALUSrc2 = `ALU_SRC_MUX_SEL_REGB;
                ALUCtrl = `ALUOp_SRA;

                MemRead = 0;
                MemWrite = 0;

                PC_sel = `PC_MUX_SEL_NEWPC;

                ExtOp = `EXT_ZERO;
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

        // lw
        `INSTR_LW_OP: begin
            RegDst = `REG_MUX_SEL_RT;
            RegWrite = 1;
            DatatoReg = `DR_MUX_SEL_MEM;

            ALUSrc = `ALU_SRC_MUX_SEL_EXT; // offset
            ALUCtrl = `ALUOp_ADD; // 完成 offset + base

            MemRead = 1;
            MemWrite = 0;

            PC_sel = `PC_MUX_SEL_NEWPC;
            ExtOp = `EXT_SIGNED;
        end

        // sw
        `INSTR_SW_OP: begin
            RegDst = 0;
            RegWrite = 0;
            DatatoReg = 0;

            ALUSrc = `ALU_SRC_MUX_SEL_EXT; // offset
            ALUCtrl = `ALUOp_ADD; // 完成 offset + base

            MemRead = 0;
            MemWrite = 1;

            PC_sel = `PC_MUX_SEL_NEWPC;
            ExtOp = `EXT_SIGNED;
        end

        // TODO: or
        // TODO: and
        // TODO: addi

        // lui 设置高位
        `INSTR_LUI_OP: begin
            RegDst = `REG_MUX_SEL_RT;  // 写入 rt。ins[20:16]
            RegWrite = 1;
            DatatoReg = `DR_MUX_SEL_ALU;

            ALUSrc = `ALU_SRC_MUX_SEL_EXT; // 立即数
            ALUCtrl = `ALUOp_LUI;

            MemRead = 0;
            MemWrite = 0;

            PC_sel = `PC_MUX_SEL_NEWPC;

            ExtOp = `EXT_ZERO;
        end

        // TODO: sra


        // bne
        // if (rs != rt) PC <- PC+4 + (sign-extend)immediate<<2
        `INSTR_BNE_OP: begin
            RegDst = 0;
            RegWrite = 0;
            DatatoReg = 0;

            ALUSrc = `ALU_SRC_MUX_SEL_REG; // 立即数
            ALUCtrl = `ALUOp_BNE;

            MemRead = 0;
            MemWrite = 0;

            PC_sel = `PC_MUX_SEL_BRANCH;

            ExtOp = `EXT_SIGNED;
        end


        // j
        // PC <- (PC+4)[31..28],address[26..0],0,0
        `INSTR_J_OP: begin
            RegDst = 0;
            RegWrite = 0;
            DatatoReg = 0;

            ALUSrc = 0;
            ALUCtrl = 0;

            MemRead = 0;
            MemWrite = 0;

            PC_sel = `PC_MUX_SEL_NEWPC;

            ExtOp = `EXT_SIGNED;

            IsJump = 1;
        end

        // TODO: jal
        // TODO: jr

        // slti 小于则置位(立即数)
        // if (rs <(sign-extend)immediate) rt=1 else rt=0 ；
        `INSTR_SLTI_OP: begin
            RegDst = `REG_MUX_SEL_RT;
            RegWrite = 1;
            DatatoReg = `DR_MUX_SEL_ALU;

            ALUSrc = `ALU_SRC_MUX_SEL_EXT; // 立即数
            ALUCtrl = `ALUOp_SLT;

            MemRead = 0;
            MemWrite = 0;

            PC_sel = `PC_MUX_SEL_NEWPC;

            ExtOp = `EXT_SIGNED;
        end

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

`endif
