`timescale 1ns / 1ps
module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2 -1:0] count2,
    output logic [W1 -1:0] count1,
    output logic [W0 -1:0] count0
);

  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_counter_n2 (
      .clk(clk),
      .enable(enable && (count1 == W1'(N1 - 1)) && (count0 == W0'(N0 - 1))),
      .rst(rst),
      .count(count2)
  );

  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_counter_n1 (
      .clk(clk),
      .enable(enable && (count0 == W0'(N0 - 1))),
      .rst(rst),
      .count(count1)
  );

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) u_counter_n0 (
      .clk(clk),
      .enable(enable),
      .rst(rst),
      .count(count0)
  );

endmodule
