`timescale 1ns / 1ps

module user_top_brightness_wrapper #(
    parameter int CYCLES_PER_SECOND = 50_000_000
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
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  localparam int PwmCycles = CYCLES_PER_SECOND / 1000;
  localparam int WCounter = $clog2(PwmCycles);

  localparam int DimDuty = PwmCycles / 8;  // 12.5%
  localparam int LowDuty = PwmCycles / 4;  // 25%
  localparam int MediumDuty = PwmCycles / 2;  // 50%
  localparam int FullDuty = PwmCycles;  // 100%

  logic top_blank_hours;
  logic top_blank_minutes;
  logic top_blank_seconds;

  logic [WCounter-1:0] count;
  logic [31:0] duty_cycles;
  logic pwm_on;

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(top_blank_hours),
      .blank_minutes(top_blank_minutes),
      .blank_seconds(top_blank_seconds)
  );

  logic [1:0] brightness_sel;
  assign brightness_sel = sw[9:8];

  always @(*) begin
    case (brightness_sel)
      2'b00:   duty_cycles = DimDuty;
      2'b01:   duty_cycles = LowDuty;
      2'b11:   duty_cycles = MediumDuty;
      2'b10:   duty_cycles = FullDuty;
      default: duty_cycles = FullDuty;
    endcase
  end

  mod_n_counter #(
      .N(PwmCycles),
      .WIDTH(WCounter)
  ) counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(count)
  );

  assign pwm_on = (duty_cycles == FullDuty) || (32'(count) < duty_cycles);

  assign blank_hours = top_blank_hours || !pwm_on;
  assign blank_minutes = top_blank_minutes || !pwm_on;
  assign blank_seconds = top_blank_seconds || !pwm_on;

endmodule
