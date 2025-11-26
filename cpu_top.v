`timescale 1ns/1ps
// cpu_top.v
// Top-level 5-stage pipelined CPU

module cpu_top (
    input  wire clk,
    input  wire reset
);

    // =====================
    // IF stage wires
    // =====================
    wire [31:0] pc_if;
    wire [31:0] pc_plus4_if;
    wire [31:0] instr_if;

    // Hazard + branch signals
    wire        pc_write;
    wire        if_id_write;
    wire        if_id_flush;
    wire        branch_taken;
    wire [31:0] branch_target_exmem;

    // IF stage
    if_stage IF_STAGE (
        .clk          (clk),
        .reset        (reset),
        .pc_write     (pc_write),
        .branch_taken (branch_taken),
        .branch_target(branch_target_exmem),
        .pc           (pc_if),
        .pc_plus4     (pc_plus4_if),
        .instr        (instr_if)
    );

    // =====================
    // IF/ID pipeline
    // =====================
    wire [31:0] pc_plus4_id;
    wire [31:0] instr_id;

    if_id_reg IF_ID (
        .clk          (clk),
        .reset        (reset),
        .write_en     (if_id_write),
        .flush        (if_id_flush),
        .pc_plus4_in  (pc_plus4_if),
        .instr_in     (instr_if),
        .pc_plus4_out (pc_plus4_id),
        .instr_out    (instr_id)
    );

    // =====================
    // ID stage
    // =====================
    wire [31:0] rd1_id;
    wire [31:0] rd2_id;
    wire [31:0] sign_ext_imm_id;
    wire [4:0]  rs_id;
    wire [4:0]  rt_id;
    wire [4:0]  rd_id;

    // WB stage output to regfile
    wire        wb_reg_write;
    wire [4:0]  wb_write_reg;
    wire [31:0] wb_write_data;

    id_stage ID_STAGE (
        .clk           (clk),
        .instr         (instr_id),
        .pc_plus4_in   (pc_plus4_id),
        .wb_reg_write  (wb_reg_write),
        .wb_write_reg  (wb_write_reg),
        .wb_write_data (wb_write_data),
        .rd1           (rd1_id),
        .rd2           (rd2_id),
        .sign_ext_imm  (sign_ext_imm_id),
        .rs            (rs_id),
        .rt            (rt_id),
        .rd            (rd_id),
        .pc_plus4_out  (/* unused */)
    );

    // =====================
    // Control unit (in ID)
    // =====================
    wire [5:0] opcode_id = instr_id[31:26];
    wire [5:0] funct_id  = instr_id[5:0];

    wire reg_dst_id;
    wire alu_src_id;
    wire mem_to_reg_id;
    wire reg_write_id;
    wire mem_read_id;
    wire mem_write_id;
    wire branch_id;
    wire [2:0] alu_ctrl_id;

    control_unit CTRL (
        .opcode    (opcode_id),
        .funct     (funct_id),
        .reg_dst   (reg_dst_id),
        .alu_src   (alu_src_id),
        .mem_to_reg(mem_to_reg_id),
        .reg_write (reg_write_id),
        .mem_read  (mem_read_id),
        .mem_write (mem_write_id),
        .branch    (branch_id),
        .alu_ctrl  (alu_ctrl_id)
    );

    // Hazard unit: load-use
    wire        id_ex_mem_read;
    wire [4:0]  id_ex_rt;
    wire        control_stall;

    hazard_unit HAZ (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rt      (id_ex_rt),
        .if_id_rs      (rs_id),
        .if_id_rt      (rt_id),
        .pc_write      (pc_write),
        .if_id_write   (if_id_write),
        .control_stall (control_stall)
    );

    // Stall = insert bubble by zeroing control signals to ID/EX
    wire        reg_dst_id_eff    = control_stall ? 1'b0      : reg_dst_id;
    wire        alu_src_id_eff    = control_stall ? 1'b0      : alu_src_id;
    wire        mem_to_reg_id_eff = control_stall ? 1'b0      : mem_to_reg_id;
    wire        reg_write_id_eff  = control_stall ? 1'b0      : reg_write_id;
    wire        mem_read_id_eff   = control_stall ? 1'b0      : mem_read_id;
    wire        mem_write_id_eff  = control_stall ? 1'b0      : mem_write_id;
    wire        branch_id_eff     = control_stall ? 1'b0      : branch_id;
    wire [2:0]  alu_ctrl_id_eff   = control_stall ? 3'b000    : alu_ctrl_id;

    // =====================
    // ID/EX pipeline
    // =====================
    wire        reg_dst_ex;
    wire        alu_src_ex;
    wire        mem_to_reg_ex;
    wire        reg_write_ex;
    wire        mem_read_ex;
    wire        mem_write_ex;
    wire        branch_ex;
    wire [2:0]  alu_ctrl_ex;
    wire [31:0] pc_plus4_ex;
    wire [31:0] rd1_ex;
    wire [31:0] rd2_ex;
    wire [31:0] sign_ext_imm_ex;
    wire [4:0]  rs_ex;
    wire [4:0]  rt_ex;
    wire [4:0]  rd_ex;

    id_ex_reg ID_EX (
        .clk              (clk),
        .reset            (reset),
        .flush            (control_stall),  // bubble control
        .reg_dst_in       (reg_dst_id_eff),
        .alu_src_in       (alu_src_id_eff),
        .mem_to_reg_in    (mem_to_reg_id_eff),
        .reg_write_in     (reg_write_id_eff),
        .mem_read_in      (mem_read_id_eff),
        .mem_write_in     (mem_write_id_eff),
        .branch_in        (branch_id_eff),
        .alu_ctrl_in      (alu_ctrl_id_eff),
        .pc_plus4_in      (pc_plus4_id),
        .rd1_in           (rd1_id),
        .rd2_in           (rd2_id),
        .sign_ext_imm_in  (sign_ext_imm_id),
        .rs_in            (rs_id),
        .rt_in            (rt_id),
        .rd_in            (rd_id),
        .reg_dst_out      (reg_dst_ex),
        .alu_src_out      (alu_src_ex),
        .mem_to_reg_out   (mem_to_reg_ex),
        .reg_write_out    (reg_write_ex),
        .mem_read_out     (id_ex_mem_read),
        .mem_write_out    (mem_write_ex),
        .branch_out       (branch_ex),
        .alu_ctrl_out     (alu_ctrl_ex),
        .pc_plus4_out     (pc_plus4_ex),
        .rd1_out          (rd1_ex),
        .rd2_out          (rd2_ex),
        .sign_ext_imm_out (sign_ext_imm_ex),
        .rs_out           (rs_ex),
        .rt_out           (id_ex_rt),
        .rd_out           (rd_ex)
    );

    // =====================
    // Forwarding unit inputs (EX stage hazards)
    // =====================
    wire        ex_mem_reg_write;
    wire [4:0]  ex_mem_write_reg;
    wire        mem_wb_reg_write;
    wire [4:0]  mem_wb_write_reg;

    wire [1:0]  forward_a_ex;
    wire [1:0]  forward_b_ex;

    forwarding_unit FWD (
        .ex_mem_reg_write (ex_mem_reg_write),
        .ex_mem_rd        (ex_mem_write_reg),
        .mem_wb_reg_write (mem_wb_reg_write),
        .mem_wb_rd        (mem_wb_write_reg),
        .id_ex_rs         (rs_ex),
        .id_ex_rt         (id_ex_rt),
        .forward_a        (forward_a_ex),
        .forward_b        (forward_b_ex)
    );

    // =====================
    // EX stage
    // =====================
    wire [31:0] branch_target_ex;
    wire [31:0] alu_result_ex;
    wire [31:0] write_data_ex;
    wire        zero_ex;
    wire [4:0]  write_reg_ex;
    wire [4:0]  rs_ex_dummy;
    wire [4:0]  rt_ex_dummy;

    ex_stage EX_STAGE (
        .pc_plus4          (pc_plus4_ex),
        .rd1_in            (rd1_ex),
        .rd2_in            (rd2_ex),
        .sign_ext_imm      (sign_ext_imm_ex),
        .rs                (rs_ex),
        .rt                (id_ex_rt),
        .rd                (rd_ex),
        .reg_dst           (reg_dst_ex),
        .alu_src           (alu_src_ex),
        .alu_ctrl          (alu_ctrl_ex),
        .forward_a         (forward_a_ex),
        .forward_b         (forward_b_ex),
        .ex_mem_alu_result (alu_result_exmem),
        .mem_wb_write_data (wb_write_data),
        .branch_target     (branch_target_ex),
        .alu_result        (alu_result_ex),
        .write_data        (write_data_ex),
        .zero              (zero_ex),
        .write_reg_out     (write_reg_ex),
        .rs_out            (rs_ex_dummy),
        .rt_out            (rt_ex_dummy)
    );

    // =====================
    // EX/MEM pipeline
    // =====================
    wire        mem_to_reg_exmem;
    wire        mem_read_exmem;
    wire        mem_write_exmem;
    wire        branch_exmem;
    wire [31:0] alu_result_exmem;
    wire [31:0] write_data_exmem;
    wire        zero_exmem;

    ex_mem_reg EX_MEM (
        .clk              (clk),
        .reset            (reset),
        .mem_to_reg_in    (mem_to_reg_ex),
        .reg_write_in     (reg_write_ex),
        .mem_read_in      (mem_read_ex),
        .mem_write_in     (mem_write_ex),
        .branch_in        (branch_ex),
        .branch_target_in (branch_target_ex),
        .zero_in          (zero_ex),
        .alu_result_in    (alu_result_ex),
        .write_data_in    (write_data_ex),
        .write_reg_in     (write_reg_ex),
        .mem_to_reg_out   (mem_to_reg_exmem),
        .reg_write_out    (ex_mem_reg_write),
        .mem_read_out     (mem_read_exmem),
        .mem_write_out    (mem_write_exmem),
        .branch_out       (branch_exmem),
        .branch_target_out(branch_target_exmem),
        .zero_out         (zero_exmem),
        .alu_result_out   (alu_result_exmem),
        .write_data_out   (write_data_exmem),
        .write_reg_out    (ex_mem_write_reg)
    );

    assign branch_taken = branch_exmem & zero_exmem;
    assign if_id_flush  = branch_taken;

    // =====================
    // MEM stage
    // =====================
    wire [31:0] read_data_mem;
    wire [31:0] alu_result_mem;

    mem_stage MEM_STAGE (
        .clk            (clk),
        .mem_read       (mem_read_exmem),
        .mem_write      (mem_write_exmem),
        .alu_result_in  (alu_result_exmem),
        .write_data_in  (write_data_exmem),
        .read_data_out  (read_data_mem),
        .alu_result_out (alu_result_mem)
    );

    // =====================
    // MEM/WB pipeline
    // =====================
    wire        mem_to_reg_memwb;
    wire [31:0] read_data_memwb;
    wire [31:0] alu_result_memwb;

    mem_wb_reg MEM_WB (
        .clk             (clk),
        .reset           (reset),
        .mem_to_reg_in   (mem_to_reg_exmem),
        .reg_write_in    (ex_mem_reg_write),
        .read_data_in    (read_data_mem),
        .alu_result_in   (alu_result_mem),
        .write_reg_in    (ex_mem_write_reg),
        .mem_to_reg_out  (mem_to_reg_memwb),
        .reg_write_out   (mem_wb_reg_write),
        .read_data_out   (read_data_memwb),
        .alu_result_out  (alu_result_memwb),
        .write_reg_out   (mem_wb_write_reg)
    );

    // =====================
    // WB stage
    // =====================
    wb_stage WB_STAGE (
        .mem_to_reg (mem_to_reg_memwb),
        .read_data  (read_data_memwb),
        .alu_result (alu_result_memwb),
        .write_data (wb_write_data)
    );

    assign wb_reg_write  = mem_wb_reg_write;
    assign wb_write_reg  = mem_wb_write_reg;

endmodule
