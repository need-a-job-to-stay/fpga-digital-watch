`timescale 1ns / 1ps

module user_top_timepiece_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
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

  typedef struct packed {
    logic [3:0] button;
    logic [9:0] sw;
  } ui_in_t;

  typedef struct packed {
    logic [9:0] led;
    logic [6:0] hours_disp;
    logic [6:0] minutes_disp;
    logic [6:0] seconds_disp;
    logic blank_hours;
    logic blank_minutes;
    logic blank_seconds;
  } ui_out_t;

  ui_in_t watch_in, timer_in, sw_in;
  ui_out_t watch_out, timer_out, sw_out;

  // TO DO -- instantiate :
  // user_top_watch_v4
  // user_top_timer_v1
  // user_top_stopwatch_v1
  //
  // Connect the ports up to the appropriate ui_in and ui_out
  // e.g., for the watch, .button(watch_in.button)

  // ------------
  // Multiplexers
  // ------------

  ui_in_t ui_top_in;
  assign ui_top_in.sw = sw;
  assign ui_top_in.button = button;

  ui_in_t ui_top_in_no_buttons;
  assign ui_top_in_no_buttons.sw = sw;
  assign ui_top_in_no_buttons.button = '0;

  ui_out_t ui_top_out;
  assign led = ui_top_out.led;
  assign hours_disp = ui_top_out.hours_disp;
  assign minutes_disp = ui_top_out.minutes_disp;
  assign seconds_disp = ui_top_out.seconds_disp;
  assign blank_hours = ui_top_out.blank_hours;
  assign blank_minutes = ui_top_out.blank_minutes;
  assign blank_seconds = ui_top_out.blank_seconds;

  logic [1:0] mode_sel;
  assign mode_sel = sw[1:0];

  always_comb
    case (mode_sel)
      // Stopwatch
      2'b01: begin
        // TO DO -- fill in appropriately
      end

      // Timer
      2'b11: begin
        // TO DO -- fill in appropriately
      end

      // Watch
      default: begin
        // TO DO -- fill in appropriately
      end
    endcase

endmodule
