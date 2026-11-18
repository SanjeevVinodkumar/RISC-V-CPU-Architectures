# Five-Stage Pipelined RISC-V CPU

A five-stage pipelined RISC-V processor implementation in Verilog HDL.

## Pipeline stages
1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

## Contents
- `rtl/`: processor top-level, datapath, pipeline registers, control, ALU, hazard/branch logic, memories, and supporting modules.
- `testbench/`: supplied Verilog testbench.
- `programs/`: assembly test program and instruction-memory image.

## Source context
This implementation was developed as part of eYantra Logic Quest coursework. The original source files are retained in this repository as provided, apart from removal of backup/build artifacts. No separate license is added; check the original course terms before redistributing or making the repository public.

## Tools
Verilog HDL; Intel Quartus project files and generated build outputs are not included.
