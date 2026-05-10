`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count = WIDTH'(0)

);

  logic [WIDTH-1:0] next_count;

  always_ff @(posedge clk) begin
    if (rst) count <= WIDTH'(0);
    else count <= next_count;
  end

  always_comb begin
    if (enable) next_count = (32'(count) == N - 1) ? 0 : count + 1;
    else next_count = count;
  end

endmodule
