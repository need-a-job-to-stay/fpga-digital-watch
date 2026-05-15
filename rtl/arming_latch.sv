`timescale 1ns / 1ps
module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);
  logic next_armed;

  always_ff @(posedge clk) armed <= next_armed;
  initial armed = 1'b0;
  always_comb begin
    if (disarm) begin
      next_armed = 1'b0;
    end else if (arm) begin
      next_armed = 1'b1;
    end else begin
      next_armed = armed;
    end
  end

endmodule
