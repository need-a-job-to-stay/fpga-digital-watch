
`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  assign led = clk ? sw : ~sw;

  assign blank_hours = button[0];
  assign blank_minutes = button[1];
  assign blank_seconds = button[2];

  assign hours_disp = button[3] ? 7'd16 : 7'd7;
  assign minutes_disp = button[3] ? 7'd38 : 7'd23;
  assign seconds_disp = button[3] ? 7'd59 : 7'd45;

endmodule
