`timescale 1ns / 1ps
module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic held_d;
  logic first_held;
  logic pulse_train;

  rising_edge_detector u_rise (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold (
      .clk(clk),
      .button(button),
      .held(held)
  );

  always_ff @(posedge clk) begin
    held_d <= held;
  end

  assign first_held = held & ~held_d;

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_count (
      .clk (clk),
      .run (held_d),
      .tick(pulse_train)
  );

  assign pulse = rise | first_held | (button & pulse_train);

endmodule
