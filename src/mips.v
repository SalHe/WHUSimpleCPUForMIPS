
module mips( );
reg clk, reset;

initial begin
    $readmemh( "Test_Instr_4.txt", IM.IMem ) ;
    $monitor("PC = 0x%8X, IR = 0x%8X", PC.oldpc, IM.Out );

    clk = 1 ;
    reset = 0 ;
    #5 reset = 1 ;
    #20 reset = 0 ;

end

always #50 clk = ~clk;

wire [31: 0] old_PC;
wire [31: 0] new_PC;

wire beq_zero;
wire [1: 0] PC_sel;
wire [31: 0] Instrl;

wire ExtOp;
wire [31: 0] ext_out;

wire [1: 0] Data_to_Reg_sel;
wire [31: 0] Data_to_Reg;
wire [1: 0] RegDst;
wire [4: 0] Reg_rd;
wire RegWrite;
wire [31: 0] grf_out_A;
wire [31: 0] grf_out_B;

wire ALUSrc;
wire [31: 0] ALUSrc_out;
wire [4: 0] ALUCtr;
wire [31: 0] ALU_out;

wire [31: 0] dm_data_out;
wire MemWrite;
wire MemRead;

im IM(old_PC[11: 2], Instrl);
npc NPC(old_PC, Instrl[15: 0], beq_zero, PC_sel, new_PC);
pc PC(new_PC, clk, reset, old_PC);


RegDst_mux REGDST(RegDst, Instrl[20: 16], Instrl[15: 11], Reg_rd);
DatatoReg_mux DATATOREG(ALU_out, dm_data_out, Data_to_Reg_sel, Data_to_Reg);
gpr GRF(clk, reset, Instrl[25: 21], Instrl[20: 16], Reg_rd, Data_to_Reg, RegWrite, grf_out_A, grf_out_B);

extend EXTEND(Instrl[15: 0], ExtOp, ext_out);

ALUSrc_mux ALUSRC(grf_out_B, ext_out, ALUSrc, ALUSrc_out);
alu ALU(grf_out_A, ALUSrc_out, ALUCtr, ALU_out, beq_zero);

ctrl CTRL(Instrl[31: 26], Instrl[5: 0], RegDst, ALUSrc, MemRead, RegWrite, MemWrite, Data_to_Reg_sel, PC_sel, ExtOp, ALUCtr);

dm DM(ALU_out, grf_out_B, MemWrite, MemRead, clk, reset, dm_data_out);

endmodule
