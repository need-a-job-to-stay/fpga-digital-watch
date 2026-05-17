
`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    /* verilator lint_on UNUSED */
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    /* verilator lint_off UNUSED */
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
    /* verilator lint_on UNUSED */
);
  logic rise_start_stop;
  logic rise_lap;
  logic counter_rst;
  logic counter_enable;
  logic lap_hold;

  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  logic [6:0] minutes_count;
  logic [5:0] seconds_count;
  logic [6:0] centiseconds_count;

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(minutes_count),
      .seconds(seconds_count),
      .centiseconds(centiseconds_count)
  );

  logic [20:0] count_pack;
  logic [20:0] dispaly_pack;

  snapshot_mux #(
      .WIDTH(21)
  ) u_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(count_pack),
      .q(dispaly_pack)
  );

  rising_edge_detector u_starts_stop (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  rising_edge_detector u_lap (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  assign count_pack = {minutes_count, 1'b0, seconds_count, centiseconds_count};
  assign {hours_disp, minutes_disp, seconds_disp} = dispaly_pack;


  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;
  assign led = 10'b0;

endmodule
