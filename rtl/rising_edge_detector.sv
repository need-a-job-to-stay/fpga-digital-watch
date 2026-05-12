`timescale 1ns / 1ps
module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  logic sig_in_delay;

  always_ff @(posedge clk) sig_in_delay <= sig_in;

  always_comb rise = sig_in & ~sig_in_delay;

endmodule
