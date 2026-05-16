`timescale 1ns / 1ps
module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  logic tick;
  logic run_time;
  logic enable_time;

  assign run_time    = enable && !rst;
  assign enable_time = run_time && tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_rate_generator (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      // Output port widths
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_time_counter (
      .clk(clk),
      .enable(enable_time),
      .rst(rst),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

endmodule
