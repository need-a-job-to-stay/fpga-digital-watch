`timescale 1ns / 1ps
module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int WCounter = $clog2(PERIOD_CYCLES);
  logic [WCounter-1:0] count;

  always_comb begin
    if (32'(count) < DUTY_CYCLES) pwm_out = 1'b1;
    else pwm_out = 1'b0;
  end

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(WCounter)
  ) counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

endmodule
