
module mips( );
reg clk, reset;

initial begin
    $readmemh( "../../asm/Test_Instr_4.txt", IM.IMem ) ;
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

// ------------------------------------------------------
// 指令相关

// 指令寄存器
// 取指令
im IM(
       /* PC地址 */         old_PC[11:2],
       /* 取出的指令 */     Instrl
   );

// 指令地址决定单元（根据控制信号选择分支PC还是正常PC+4）
npc NPC(
        /* 原PC(未+4) */            old_PC,
        /* 偏移(暂时只考虑beq) */    Instrl[15:0],
        /* 信号 */                  beq_zero,
        /* 多路选择信号 */           PC_sel,
        /* 输出的新PC */             new_PC
    );

// PC模块
pc PC(
       new_PC,
       clk,
       reset,
       old_PC
   );


// ------------------------------------------------------
// 多路选择器

// rd编号选择器，对应Write Addr
// 这里实参和形参定义貌似不一致？
RegDst_mux REGDST(RegDst,
                  /* rt??? */ Instrl[20:16],
                  /* rd??? */ Instrl[15:11],
                  /*       */ Reg_rd
                 );

// (从内存读出orALU运算结果)写回数据选择器
DatatoReg_mux DATATOREG(
                  /* ALU计算结果    */  ALU_out,
                  /* 内存读出的数据 */   dm_data_out,
                  /* 选择信号 */        Data_to_Reg_sel,
                  /* wire */            Data_to_Reg
              );

// gpr Geeral-PuroeRegiter 通用寄存器
gpr GRF(
        clk,
        reset,

        // Read Addr1, Read Addr2
        Instrl[25: 21],
        Instrl[20: 16],

        // Write Addr
        Reg_rd,

        // 写入数据以及写使能信号
        Data_to_Reg,
        RegWrite,

        // Read Data1, Read Data2
        grf_out_A,
        grf_out_B
    );

// -----------------------------------------------------------
// 运算

// 符号扩展
extend EXTEND(Instrl[15: 0], ExtOp, ext_out);

// ALU操作数选择器
ALUSrc_mux ALUSRC(
               /* 寄存器Data2 */    grf_out_B,
               /* 符号扩展结果 */   ext_out,
               /* ALU选择信号 */    ALUSrc,
               /* 选择结果 */       ALUSrc_out
           );

// ALU
alu ALU(
        /* 操作数1：寄存器Data2 */          grf_out_A,
        /* 操作数2：ALU操作数选择结果 */     ALUSrc_out,
        /* ALU控制信号 */                   ALUCtr,
        /* 运算结果 */                      ALU_out,
        /* 操作数是否相等？ */              beq_zero
    );

// 控制信号单元
// 根据指令内容生成对应的控制信号
// 比如是否选择offset作为PC的偏移等等
ctrl CTRL(
         // 输入指令
         Instrl[31: 26],
         Instrl[5: 0],

         // 生成信号
         RegDst,
         ALUSrc,
         MemRead,
         RegWrite,
         MemWrite,
         Data_to_Reg_sel,
         PC_sel,
         ExtOp,
         ALUCtr
     );

// 内存访问模块
dm DM(
       /* 内存地址 */       ALU_out,
       /* 寄存器Data2 */    grf_out_B,
       /* 写使能信号 */     MemWrite,
       /* 读使能信号 */     MemRead,

       clk,
       reset,

       /* 读出结果 */       dm_data_out
   );

endmodule
