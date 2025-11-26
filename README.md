

# 5-Stage Pipelined MIPS-Like Processor (Verilog HDL)

This repository contains the implementation of a 32-bit, 5-stage pipelined MIPS-like processor written entirely in Verilog.
The project follows the classical pipeline architecture taught in Computer Architecture courses and is designed for simulation in Vivado.

The processor implements a clean and modular design with pipeline registers, forwarding, hazard detection, branch handling, and memory interfaces.

---

## 1. Introduction

The goal of this project is to design and simulate a simple pipelined CPU that demonstrates the core ideas behind RISC architecture and pipelined execution.

The processor supports a basic subset of MIPS instructions (R-type ALU operations, memory instructions, and BEQ). It includes all essential pipeline mechanisms such as:

* Instruction Fetch (IF)
* Instruction Decode (ID)
* Execute (EX)
* Memory Access (MEM)
* Write Back (WB)
* Forwarding (EX and MEM hazards)
* Load-use hazard detection
* Branch handling with pipeline flushing

The design is intended for learning, academic demonstration, and FPGA-ready simulation.

---

## 2. Architecture Overview

The CPU follows the standard 5-stage MIPS pipeline:

```
IF → ID → EX → MEM → WB
```

Each stage is separated by a pipeline register:

```
IF/ID → ID/EX → EX/MEM → MEM/WB
```

The processor follows a Harvard architecture model with separate instruction and data memories.

---

## 3. Pipeline Flow (ASCII Diagram)

```
               IF ───► ID ───► EX ───► MEM ───► WB
                │       │       │       │       │
PC Update ──────┘       │   Forwarding  │    Register Write
                        │               │
                   Hazard Detection     Branch Resolution
```

---

## 4. Hazard Handling

### Forwarding Unit

The forwarding unit resolves data hazards by selecting the most recent value for ALU operands from:

* EX/MEM stage
* MEM/WB stage
* ID/EX register (default)

This prevents unnecessary pipeline stalls.

### Load-Use Hazard Detection

When a load instruction is followed immediately by an instruction that depends on its result, a one-cycle stall (bubble) is inserted.

During the stall:

* PC is frozen
* IF/ID register is frozen
* Control signals entering ID/EX are forced to zero

### Branch Handling

Branches are resolved in the EX stage.
If BEQ is taken:

* IF/ID register is flushed
* PC is updated to the branch target

---

## 5. Module-Level Explanation

Below is a brief description of each Verilog module included in `src/`.

### alu.v

Implements the ALU supporting:
ADD, SUB, AND, OR.
Generates the `zero` flag used for branch decisions.

### regfile.v

A 32×32 register file with:

* Two asynchronous read ports
* One synchronous write port
  Register 0 is fixed at zero.

### imem.v

Instruction memory (read-only during execution).
Supports loading instructions using `$readmemh`.
Indexed based on `PC[9:2]`.

### dmem.v

Data memory used for load/store operations.
Implements synchronous writes and asynchronous reads.

### control_unit.v

Generates all control signals based on the instruction opcode and function field.

### hazard_unit.v

Detects load-use hazards and generates stall signals:

* `pc_write`
* `if_id_write`
* `control_stall`

### forwarding_unit.v

Selects forwarded operands for the ALU to avoid unnecessary stalls.

### if_stage.v

Handles PC update, instruction fetch, and integration with instruction memory.

### id_stage.v

Performs instruction decoding, register file access, and sign extension.

### ex_stage.v

Implements ALU operations, forwarding muxing, RegDst muxing, and branch target calculation.

### mem_stage.v

Handles memory reads and writes using the data memory.

### wb_stage.v

Selects the source of data to write back to the register file.

### Pipeline Registers

Each stage is separated by:

* if_id_reg.v
* id_ex_reg.v
* ex_mem_reg.v
* mem_wb_reg.v

These modules store stage outputs and allow pipelined operation.

### cpu_top.v

Integrates all modules.
Contains the entire datapath, control path, forwarding logic, hazard control, and memory connections.

### tb_cpu.v

A simple testbench used to simulate the CPU.
Provides a clock, applies reset, and runs the processor.

---

## 6. Supported Instruction Set

### R-Type

* ADD
* SUB
* AND
* OR

### I-Type

* LW
* SW
* BEQ

This is a minimal but complete subset for demonstrating pipelined execution.

---

## 7. How to Simulate in Vivado

1. Create a new Vivado project
2. Add all `.v` files from the `src/` directory as design sources
3. Add `tb/tb_cpu.v` as a simulation source
4. Set `tb_cpu` as the simulation top module
5. Run Behavioral Simulation
6. View pipeline behavior using waveforms

---

## 8. Loading Programs Into Instruction Memory

The instruction memory can be initialized in two ways:

### Option A — Hardcoded inside `imem.v`

```verilog
initial begin
    mem[0] = 32'hXXXXXXXX;
    mem[1] = 32'hYYYYYYYY;
end
```

### Option B — Using a hex file (recommended)

1. Create `program.hex`
2. Add machine code instructions line-by-line
3. Modify `imem.v`:

```verilog
initial begin
    $readmemh("program.hex", mem);
end
```

---

## 9. Limitations (What This CPU Cannot Do)

This design intentionally keeps the CPU simple and suitable for academic understanding.
It does not support:

1. Jump instructions (J, JAL, JR, JALR)
2. Immediate ALU instructions (ADDI, ORI, ANDI, SLTI)
3. Multiply or divide instructions
4. Exceptions, interrupts, or system calls
5. Cache memory
6. Branch prediction
7. Sub-word memory access (byte or halfword loads/stores)
8. Out-of-order execution
9. Multi-cycle memory interfaces
10. Full MIPS ISA compliance

These features can be added in extended versions.

---

## 10. Why This Project Matters

This project demonstrates practical knowledge of:

* Digital logic design
* Pipelined processor architecture
* RTL design and modular coding
* Hazard detection and forwarding logic
* Designing hardware datapaths and control paths
* Simulation and verification in Vivado
* Memory-mapped CPU design

Such a project is commonly used in Computer Architecture and VLSI courses and is excellent for showcasing Verilog skills in technical interviews or engineering portfolios.

