import risc_pkg::*;

module control (
    // Instruction type flags
    input logic r_type,
    input logic i_type,
    input logic s_type,
    input logic b_type,
    input logic u_type,
    input logic j_type,

    // Instruction fields
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [6:0] opcode,

    // Outputs
    output logic      pc_sel,
    output logic      op1_sel,
    output logic      op2_sel,
    output alu_op_t   alu_op,
    output wb_src_t   rf_wr_data_sel,
    output logic      dmem_req,
    output mem_size_t dmem_size,
    output logic      dmem_wr_en,
    output logic      dmem_zero_extend,
    output logic      rf_wr_en
);

  // +-----------------------------------------------------------+
  // |                     Internal Signals                      |
  // +-----------------------------------------------------------+
  logic [3:0] funct_r;
  logic [3:0] opcode_i;
  logic funct7_bit5;

  assign funct7_bit5 = funct7[5];

  control_t ctrl_r, ctrl_i, ctrl_s, ctrl_u, ctrl_b, ctrl_j, ctrl;

  // +-----------------------------------------------------------+
  // |                      R-Type Control                       |
  // +-----------------------------------------------------------+
  assign funct_r = {funct7_bit5, funct3};

  always_comb begin
    ctrl_r = '0;
    ctrl_r.rf_write_enable = 1'b1;  //R type instructions always write a result

    case (funct_r)
      R_ADD:  ctrl_r.alu_op = ADD;
      R_SUB:  ctrl_r.alu_op = SUB;
      R_SLL:  ctrl_r.alu_op = SLL;
      R_SLT:  ctrl_r.alu_op = SLT;
      R_SLTU: ctrl_r.alu_op = SLTU;
      R_XOR:  ctrl_r.alu_op = XOR;
      R_SRA:  ctrl_r.alu_op = SRA;
      R_OR:   ctrl_r.alu_op = OR;
      R_AND:  ctrl_r.alu_op = AND;
    endcase

  end

  // +-----------------------------------------------------------+
  // |                      I-Type Control                       |
  // +-----------------------------------------------------------+

  assign opcode_i = {opcode[4], funct3};

  always_comb begin
    ctrl_i = '0;
    ctrl_i.rf_write_enable = 1'b1;
    ctrl_i.alu_src_b_select = 1'b1;

    case (opcode_i)
      // verilog_format: off
      I_LB : {ctrl_i.mem_valid, ctrl_i.mem_size, ctrl_i.wb_src, ctrl_i.load_zero_extend} = {1'b1, BYTE,      WB_SRC_MEM, 1'b0};
      I_LH : {ctrl_i.mem_valid, ctrl_i.mem_size, ctrl_i.wb_src, ctrl_i.load_zero_extend} = {1'b1, HALF_WORD, WB_SRC_MEM, 1'b0};
      I_LW : {ctrl_i.mem_valid, ctrl_i.mem_size, ctrl_i.wb_src, ctrl_i.load_zero_extend} = {1'b1, WORD,      WB_SRC_MEM, 1'b0};
      I_LBU: {ctrl_i.mem_valid, ctrl_i.mem_size, ctrl_i.wb_src, ctrl_i.load_zero_extend} = {1'b1, BYTE,      WB_SRC_MEM, 1'b1};
      I_LHU: {ctrl_i.mem_valid, ctrl_i.mem_size, ctrl_i.wb_src, ctrl_i.load_zero_extend} = {1'b1, HALF_WORD, WB_SRC_MEM, 1'b1};
      // verilog_format: on

      I_ADDI:      ctrl_i.alu_op = ADD;
      I_SLTI:      ctrl_i.alu_op = SLT;
      I_SLTIU:     ctrl_i.alu_op = SLTU;
      I_XORI:      ctrl_i.alu_op = XOR;
      I_ORI:       ctrl_i.alu_op = OR;
      I_ANDI:      ctrl_i.alu_op = AND;
      I_SLLI:      ctrl_i.alu_op = SLL;
      I_SRLI_SRAI: ctrl_i.alu_op = alu_op_t'(funct7_bit5 ? SRA : SRL);
    endcase

    //JALR
    if (opcode == OPCODE_I_JALR) begin
      ctrl_i.pc_src_select = 1'b1;
      ctrl_i.wb_src = WB_SRC_PC;
      ctrl_i.alu_op = ADD;
      //src_b is already set to 1
    end

  end

  // +-----------------------------------------------------------+
  // |                      S-Type Control                       |
  // +-----------------------------------------------------------+
  always_comb begin
    ctrl_s = '0;
    ctrl_s.mem_valid = 1'b1;
    ctrl_s.mem_write = 1'b1;
    ctrl_s.alu_src_b_select = 1'b1;

    case (funct3)
      S_SB: ctrl_s.mem_size = BYTE;
      S_SH: ctrl_s.mem_size = HALF_WORD;
      S_SW: ctrl_s.mem_size = WORD;
    endcase
  end

  // +-----------------------------------------------------------+
  // |                      B-Type Control                       |
  // +-----------------------------------------------------------+
  always_comb begin
    ctrl_b = '0;
    ctrl_b.alu_src_a_select = 1'b1;
    ctrl_b.alu_src_b_select = 1'b1;
    ctrl_b.alu_op = ADD;
  end

  // +-----------------------------------------------------------+
  // |                      U-Type Control                       |
  // +-----------------------------------------------------------+
  always_comb begin
    ctrl_u = '0;
    ctrl_u.rf_write_enable = 1'b1;

    case (opcode)
      OPCODE_AUIPC: begin
        ctrl_u.alu_src_a_select = 1'b1;
        ctrl_u.alu_src_b_select = 1'b1;
      end
      OPCODE_LUI: begin
        ctrl_u.wb_src = WB_SRC_IMM;
      end
    endcase
  end

  // +-----------------------------------------------------------+
  // |                      J-Type Control                       |
  // +-----------------------------------------------------------+

  always_comb begin
    ctrl_j = '0;
    ctrl_j.pc_src_select = 1'b1;
    ctrl_j.rf_write_enable = 1'b1;

    ctrl_j.alu_src_a_select = 1'b1;
    ctrl_j.alu_src_b_select = 1'b1;

    ctrl_j.alu_op = ADD;
    ctrl_j.wb_src = WB_SRC_PC;
  end

  // +-----------------------------------------------------------+
  // |                   Final Control Section                   |
  // +-----------------------------------------------------------+
  always_comb begin
    // ctrl = '0;
    ctrl = r_type ? ctrl_r :
           i_type ? ctrl_i :
           s_type ? ctrl_s :
           b_type ? ctrl_b :
           u_type ? ctrl_u :
           j_type ? ctrl_j : '0;
  end

  // +-----------------------------------------------------------+
  // |                     Output Assignment                     |
  // +-----------------------------------------------------------+

  assign pc_sel           = ctrl.pc_src_select;
  assign op1_sel          = ctrl.alu_src_a_select;
  assign op2_sel          = ctrl.alu_src_b_select;
  assign alu_op           = ctrl.alu_op;
  assign rf_wr_data_sel   = ctrl.wb_src;
  assign dmem_req         = ctrl.mem_valid;
  assign dmem_size        = ctrl.mem_size;
  assign dmem_wr_en       = ctrl.mem_write;
  assign dmem_zero_extend = ctrl.load_zero_extend;
  assign rf_wr_en         = ctrl.rf_write_enable;

endmodule
