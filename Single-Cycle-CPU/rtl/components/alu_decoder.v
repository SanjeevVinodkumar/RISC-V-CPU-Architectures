// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin

    case (ALUOp)

        // Loads, stores, AUIPC, etc.
        2'b00:
            ALUControl = 4'b0000;       // ADD

        // Branches
        2'b01: begin
            case (funct3)

                3'b000: ALUControl = 4'b0001; // BEQ -> SUB
                3'b001: ALUControl = 4'b0001; // BNE -> SUB

                3'b100: ALUControl = 4'b0101; // BLT  -> SLT
                3'b101: ALUControl = 4'b0101; // BGE  -> SLT

                3'b110: ALUControl = 4'b0110; // BLTU -> SLTU
                3'b111: ALUControl = 4'b0110; // BGEU -> SLTU

                default: ALUControl = 4'b0001;

            endcase
        end

        // R-type and I-type ALU instructions
        default: begin

            case (funct3)

                // ADD / SUB / ADDI
                3'b000: begin
                    if (funct7b5 && opb5)
                        ALUControl = 4'b0001; // SUB
                    else
                        ALUControl = 4'b0000; // ADD
                end

                // SLL / SLLI
                3'b001:
                    ALUControl = 4'b0111;

                // SLT / SLTI
                3'b010:
                    ALUControl = 4'b0101;

                // SLTU / SLTIU
                3'b011:
                    ALUControl = 4'b0110;

                // XOR / XORI
                3'b100:
                    ALUControl = 4'b0100;

                // SRL / SRA / SRLI / SRAI
                3'b101: begin
                    if (funct7b5)
                        ALUControl = 4'b1001; // SRA
                    else
                        ALUControl = 4'b1000; // SRL
                end

                // OR / ORI
                3'b110:
                    ALUControl = 4'b0011;

                // AND / ANDI
                3'b111:
                    ALUControl = 4'b0010;

                default:
                    ALUControl = 4'bxxxx;

            endcase
        end

    endcase
end

endmodule