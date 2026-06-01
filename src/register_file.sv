module register_file (
    //Read adresses
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    //Write port
    input logic [4:0] rd_addr,
    input logic rf_wr_en,
    input logic [31:0] wr_data,

    //Read data outputs
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    input logic clk,
    input logic reset_n

);

  logic [31:0] regs[0:31];

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      //Reset all of the registers
      for (integer i = 0; i < 32; i++) regs[i] <= 32'b0;

    end else if (rf_wr_en && (rd_addr != 5'd0)) begin
      // in risc-v register w0 always is zero, so we block writes when rd_addr is zero
      regs[rd_addr] <= wr_data;
    end
  end

  assign rs1_data = regs[rs1_addr];
  assign rs2_data = regs[rs2_addr];

endmodule
