`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic rst,
    input logic up,
    output logic [WIDTH-1:0] count = '0
);

  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  logic [WIDTH-1:0] next_count;

  always_ff @(posedge clk) begin
    if (rst || enable) count <= next_count;
  end

  always_comb begin
    if (rst) begin
      next_count = 0;
    end else if (up) begin
      next_count = (count == Max) ? 0 : count + 1;
    end else begin
      next_count = (count == 0) ? Max : count - 1;
    end
  end


endmodule
