
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [3:0]   ALUControl,
    input         Jalr,
    output        Zero,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCJalr, PCPlus4, PCTarget, AuiPC, lAuiPC;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;
reg [31:0] LoadData;
reg [31:0] StoreData;
always @(*) begin

    LoadData = ReadData;

    // Load instructions
    if (Instr[6:0] == 7'b0000011) begin

        case (Instr[14:12])

            // LB
            3'b000: begin
                case (ALUResult[1:0])
                    2'b00: LoadData = {{24{ReadData[7]}},  ReadData[7:0]};
                    2'b01: LoadData = {{24{ReadData[15]}}, ReadData[15:8]};
                    2'b10: LoadData = {{24{ReadData[23]}}, ReadData[23:16]};
                    2'b11: LoadData = {{24{ReadData[31]}}, ReadData[31:24]};
                endcase
            end

            // LH
            3'b001: begin
                if (ALUResult[1:0] == 2'b00)
                    LoadData = {{16{ReadData[15]}}, ReadData[15:0]};
                else if (ALUResult[1:0] == 2'b10)
                    LoadData = {{16{ReadData[31]}}, ReadData[31:16]};
            end

            // LW
            3'b010:
                LoadData = ReadData;

            // LBU
            3'b100: begin
                case (ALUResult[1:0])
                    2'b00: LoadData = {24'b0, ReadData[7:0]};
                    2'b01: LoadData = {24'b0, ReadData[15:8]};
                    2'b10: LoadData = {24'b0, ReadData[23:16]};
                    2'b11: LoadData = {24'b0, ReadData[31:24]};
                endcase
            end

            // LHU
            3'b101: begin
                if (ALUResult[1:0] == 2'b00)
                    LoadData = {16'b0, ReadData[15:0]};
                else if (ALUResult[1:0] == 2'b10)
                    LoadData = {16'b0, ReadData[31:16]};
            end

            default:
                LoadData = ReadData;

        endcase
    end
end

// next PC logic
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
mux2 #(32)     jalrmux(PCNext, ALUResult, Jalr, PCJalr);
reset_ff #(32) pcreg(clk, reset, PCJalr, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero);
adder #(32)    auipcadder({Instr[31:12], 12'b0}, PC, AuiPC);
// auipc: PC + (imm << 12), lui: (imm << 12)
// Instr[5] distinguishes the two opcodes (auipc: 0, lui: 1)
mux2 #(32)     lauipcmux(AuiPC, {Instr[31:12], 12'b0}, Instr[5], lAuiPC);

// Result Source
mux4 #(32)     resultmux(ALUResult, LoadData, PCPlus4, lAuiPC, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule

