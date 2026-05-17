`timescale 1ns / 1ps

module user_top_timer_v1_d #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_off UNUSED */
    output logic [9:0] led,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic [6:0] centiseconds_disp,
    output logic blank_minutes,
    output logic blank_seconds,
    output logic blank_centiseconds
);
  // ------------------
  // Core Functionality
  // ------------------

  logic clr;
  logic inc;
  logic dec;

  // centiseconds
  logic centiseconds_tick;
  logic centiseconds_edit;
  logic centiseconds_borrow_out;
  logic [6:0] centiseconds;
  editable_countdown #(
      .MAX  (100),
      .WIDTH(7)
  ) u_centiseconds (
      .clk(clk),
      .clr(clr),
      .tick(centiseconds_tick),
      .edit_mode(centiseconds_edit),
      .inc(inc),
      .dec(dec),
      .count(centiseconds),
      .borrow_out(centiseconds_borrow_out)
  );

  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_borrow_out;

  logic [5:0] seconds;
  editable_countdown #(
      .MAX  (60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(clr),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(inc),
      .dec(dec),
      .count(seconds),
      .borrow_out(seconds_borrow_out)
  );

  // minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_borrow_out;

  logic [6:0] minutes;
  editable_countdown #(
      .MAX  (100),
      .WIDTH(7)
  ) u_minutes (
      .clk(clk),
      .clr(clr),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(inc),
      .dec(dec),
      .count(minutes),
      .borrow_out(minutes_borrow_out)
  );

  // Derive 100 Hz tick from system clock
  logic run;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_divider_100_Hz (
      .clk (clk),
      .run (run),
      .tick(centiseconds_tick)
  );

  // ------------------
  // Mode_select
  // ------------------

  logic [2:0] mode_enable;
  logic running;

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3] && !running),
      .mode_enable(mode_enable)
  );

  logic pwm_out;
  pwm_generator #(
      // 2Hz
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      // 80% duty cycle
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 2 * 0.2)
  ) u_pwm_generator (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  assign centiseconds_edit = mode_enable[0];
  assign seconds_edit = mode_enable[1];
  assign minutes_edit = mode_enable[2];

  // Zero -extend counter values to display outputs
  assign minutes_disp = '0;
  assign seconds_disp = '0;
  assign centiseconds_disp = '0;

  assign blank_minutes = (mode_enable[2]) ? pwm_out : button[3];
  assign blank_seconds = (mode_enable[1]) ? pwm_out : button[3];
  assign blank_centiseconds = (mode_enable[0]) ? pwm_out : button[3];
  // Unused
  assign led = 10'b0;
  assign running = 1'b0;

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif


endmodule
