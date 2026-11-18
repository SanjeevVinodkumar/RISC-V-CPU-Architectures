
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump, Jalr,
    output [1:0] ImmSrc,
    output [3:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch;

main_decoder    md (op, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, Jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// for jump and branch
wire BranchTaken;

assign BranchTaken =
       (funct3 == 3'b000) ?  Zero  :   // BEQ
       (funct3 == 3'b001) ? ~Zero  :   // BNE
       (funct3 == 3'b100) ? ~Zero  :   // BLT
       (funct3 == 3'b101) ?  Zero  :   // BGE
       (funct3 == 3'b110) ? ~Zero  :   // BLTU
       (funct3 == 3'b111) ?  Zero  :   // BGEU
                            1'b0;

assign PCSrc = (Branch & BranchTaken) | Jump;

endmodule

