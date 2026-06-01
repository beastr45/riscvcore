module fetch (
    input  logic [31:0] imem_data,
    output logic [31:0] imem_addr,

    output logic imem_req,
    output logic [31:0] instruction,
    input logic [31:0] pc,
    input logic reset_n,
    input logic clk
);

  logic req_reg;

  always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
      req_reg <= 1'b0;
    end else begin
      req_reg <= 1'b1;
    end
  end

  assign instruction = imem_data;
  assign imem_addr = pc;
  assign imem_req = req_reg;

endmodule
