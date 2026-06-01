import risc_pkg::*;

module alu (
    //Operands
    input logic [31:0] alu_a,
    input logic [31:0] alu_b,

    //Opcode
    input alu_op_t alu_op,

    //Result
    output logic [31:0] alu_res
);

  logic signed [31:0] signed_a;
  logic signed [31:0] signed_b;

  assign signed_a = alu_a;
  assign signed_b = alu_b;

  always_comb begin

    //Avoid unintended latch inference and make sure result is always valid
    alu_res = 32'd0;

    unique case (alu_op)
      ADD:  alu_res = alu_a + alu_b;  //Add
      SUB:  alu_res = alu_a - alu_b;  //Subtract

      SLL:  alu_res = alu_a << alu_b;  //Shift Left Logical
      SRL:  alu_res = alu_a >> alu_b;  //Shift Right Logical
      SRA:  alu_res = alu_a >>> alu_b;  //Shift Right Arithmetic

      SLT:  alu_res = (alu_a < alu_b) ? 32'd1 : 32'b0;  //Set Less Than (Signed)
      SLTU: alu_res = (signed_a < signed_b) ? 32'd1 : 32'b0;  //Set Less Than Unsigned

      OR:   alu_res = alu_a | alu_b;  // Or
      AND:  alu_res = alu_a & alu_b;  // And
      XOR:  alu_res = alu_a ^ alu_b;  // eXclusive Or
    endcase

  end

endmodule
