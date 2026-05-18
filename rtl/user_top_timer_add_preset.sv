`timescale 1ns / 1ps

module user_top_timer_add_preset #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (

    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_off UNUSED */
    output logic [9:0] led,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic [6:0] hours_disp,
    output logic blank_minutes,
    output logic blank_seconds,
    output logic blank_hours
);
  // ------------------
  // Core Functionality
  // ------------------

  logic auto_repeat_dec;
  logic auto_repeat_inc;
  logic start_stop;
  logic time_not0;
  logic running = 1'b0;
  logic clr;
  logic preset_load;
  logic preset_load_d;
  logic [5:0] preset_seconds;
  logic [5:0] preset_minutes;
  logic [4:0] preset_hours;
  logic not_editting;

  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_borrow_out;
  logic [5:0] seconds;
  editable_countdown_preset #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(clr),
      .load(preset_load_d),
      .load_value(preset_seconds),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(auto_repeat_dec),
      .dec(auto_repeat_inc),
      .count(seconds),
      .borrow_out(seconds_borrow_out)
  );


  // minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_borrow_out;
  logic [5:0] minutes;
  editable_countdown_preset #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(clr),
      .load(preset_load_d),
      .load_value(preset_minutes),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(auto_repeat_dec),
      .dec(auto_repeat_inc),
      .count(minutes),
      .borrow_out(minutes_borrow_out)
  );

  // hours
  logic hours_tick;
  logic hours_edit;
  logic hours_borrow_out;
  logic [4:0] hours;
  editable_countdown_preset #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(clr),
      .load(preset_load_d),
      .load_value(preset_hours),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(auto_repeat_dec),
      .dec(auto_repeat_inc),
      .count(hours),
      .borrow_out(hours_borrow_out)
  );

  logic one_hz_tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (running),
      .tick(one_hz_tick)
  );

  assign seconds_tick = one_hz_tick && running && time_not0 && not_editting;

  // Zero -extend counter values to display outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign minutes_tick = seconds_borrow_out;
  assign hours_tick = minutes_borrow_out;

  assign time_not0 = ({hours, minutes, seconds} != '0);

  always_ff @(posedge clk) begin
    if (not_editting && ((time_not0 & start_stop)  // paulse or staet when time > 0
        || (!time_not0 && running)))  //stop when reach 0
      running <= !running;
    if (!not_editting) running <= 1'b0;
  end

  // ------------------
  // Preset time interval
  // ------------------

  logic button2;
  logic [2:0] default_selection;
  logic [2:0] mode_enable;
  logic preset_mode;
  logic preset_advance;


  always_ff @(posedge clk) preset_load_d <= preset_load;

  always_comb begin
    preset_hours   = 5'd0;
    preset_minutes = 6'd0;
    preset_seconds = 6'd0;

    case (default_selection)
      3'd1: preset_seconds = 6'd30;  //30s
      3'd2: preset_minutes = 6'd1;  // 1 min
      3'd3: preset_minutes = 6'd5;  // 5 min
      3'd4: preset_minutes = 6'd25;  // 25 min
      default: begin
        preset_hours   = 5'd0;
        preset_minutes = 6'd0;
        preset_seconds = 6'd0;
      end
    endcase
  end

  // button2 is signal for clr if in edit mode of if stopped but time is not 0
  assign clr = button2 && !not_editting;
  assign preset_load = button2 && preset_mode;
  assign preset_mode = not_editting && !running && (default_selection != 3'd0 || !time_not0);

  rising_edge_detector u_button2 (
      .clk(clk),
      .sig_in(button[2]),
      .rise(button2)
  );

  mod_n_counter #(
      .N(5),
      .WIDTH(3)
  ) u_default_selector (
      .clk(clk),
      .rst(running || !not_editting),
      .enable(preset_load),
      .count(default_selection)
  );
  // ------------------
  // Mode_select
  // ------------------

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
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 2 / 5)
  ) u_pwm_generator (
      .clk(clk),
      .rst(not_editting),
      .pwm_out(pwm_out)
  );

  assign not_editting = (mode_enable == '0);
  assign hours_edit   = mode_enable[2];
  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];

`ifdef FORMAL
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;
  assign blank_hours   = 1'b0;
`else
  assign blank_minutes = (mode_enable[1]) ? pwm_out : 1'b0;
  assign blank_seconds = (mode_enable[0]) ? pwm_out : 1'b0;
  assign blank_hours   = (mode_enable[2]) ? pwm_out : 1'b0;
`endif
  // --------------
  // Edit Logic
  // --------------

  button_auto_repeat #(
      //hold longer than 0.5s
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      //10Hz
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_auto_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(auto_repeat_dec)
  );

  button_auto_repeat #(
      //hold longer than 0.5s
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      //10Hz
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_auto_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(auto_repeat_inc)
  );

  logic button0;

  rising_edge_detector u_button0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(button0)
  );

  assign start_stop = button0 || (button2 && running);

  // Unused
  assign led = 10'b0;


`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif


endmodule
