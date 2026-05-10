`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,  // Number of hours
    parameter int N_MINUTES = 60,  // number of minutes
    parameter int N_SECONDS = 60,  //number of seconds

    //Output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);

  localparam int MaxHours = N_HOURS - 1;
  localparam int MaxMinutes = N_MINUTES - 1;
  localparam int MaxSeconds = N_SECONDS - 1;

  up_down_counter #(
      .MAX  (MaxSeconds),
      .WIDTH(W_SECONDS)
  ) seconds_counter (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );

  up_down_counter #(
      .MAX  (MaxMinutes),
      .WIDTH(W_MINUTES)
  ) minutes_counter (
      .clk(clk),
      .enable(enable && (seconds == W_SECONDS'(MaxSeconds))),
      .up(1'b1),
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (MaxHours),
      .WIDTH(W_HOURS)
  ) hours_counter (
      .clk(clk),
      .enable(enable && (seconds == W_SECONDS'(MaxSeconds)) && (minutes == W_MINUTES'(MaxMinutes))),
      .up(1'b1),
      .count(hours)
  );

endmodule
