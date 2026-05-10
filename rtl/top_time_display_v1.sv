`timescale 1ns / 1ps
module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);


  // Tick Rate Switch Values
  localparam logic [1:0] Hz1 = 2'b00;
  localparam logic [1:0] Hz25 = 2'b01;
  localparam logic [1:0] Hz1k = 2'b10;
  localparam logic [1:0] Hz50M = 2'b11;

  //Internal port widths
  localparam int WHours = 5;
  localparam int WMinutes = 6;
  localparam int WSeconds = 6;
  localparam int Wdigits = 4;


  // Internal states (Flip-flop outputs)
  logic [  WHours-1:0] hours;
  logic [WMinutes-1:0] minutes;
  logic [WSeconds-1:0] seconds;

  // Internal signals (From binary_to_bcd to seven_segment)
  logic [Wdigits-1:0]
      digit_hrs_tens,
      digit_hrs_ones,
      digit_min_tens,
      digit_min_ones,
      digit_sec_tens,
      digit_sec_ones;

  logic tick_1hz, tick_25hz, tick_1khz;
  logic tick;


  // Flip-flop and Next State Logic
  hms_counter #(
      .W_HOURS  (WHours),
      .W_MINUTES(WMinutes),
      .W_SECONDS(WSeconds)
  ) u_hms_counter (
      .clk(CLOCK_50),
      .enable(tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // Rate control logic

  always_comb begin
    case (SW)
      Hz1:    tick = tick_1hz;
      Hz25:   tick = tick_25hz;
      Hz1k:   tick = tick_1khz;
      Hz50M:  tick = 1'b1;
      default: tick = 1'b1;
    endcase
  end
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_1hz_rate_gen (
      .clk (CLOCK_50),
      .run (SW == Hz1),
      .tick(tick_1hz)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_25hz_rate_gen (
      .clk (CLOCK_50),
      .run (SW == Hz25),
      .tick(tick_25hz)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_1khz_rate_gen (
      .clk (CLOCK_50),
      .run (SW == Hz1k),
      .tick(tick_1khz)
  );

  // Output Logic
  // Convert binary counter outputs to BCD digits
  binary_to_bcd #() u_hours (
      .bin ({2'b0, hours}),
      .tens(digit_hrs_tens),
      .ones(digit_hrs_ones)
  );

  binary_to_bcd #() u_minutes (
      .bin ({1'b0, minutes}),
      .tens(digit_min_tens),
      .ones(digit_min_ones)
  );

  binary_to_bcd #() u_seconds (
      .bin ({1'b0, seconds}),
      .tens(digit_sec_tens),
      .ones(digit_sec_ones)
  );

  //Convert BCD digits to 7-segment display outputs
  seven_segment #() hex5_display (
      .digit(digit_hrs_tens),
      .blank(1'b0),
      .segments(HEX5)
  );
  seven_segment #() hex4_display (
      .digit(digit_hrs_ones),
      .blank(1'b0),
      .segments(HEX4)
  );
  seven_segment #() hex3_display (
      .digit(digit_min_tens),
      .blank(1'b0),
      .segments(HEX3)
  );
  seven_segment #() hex2_display (
      .digit(digit_min_ones),
      .blank(1'b0),
      .segments(HEX2)
  );
  seven_segment #() hex1_display (
      .digit(digit_sec_tens),
      .blank(1'b0),
      .segments(HEX1)
  );
  seven_segment #() hex0_display (
      .digit(digit_sec_ones),
      .blank(1'b0),
      .segments(HEX0)
  );

endmodule
