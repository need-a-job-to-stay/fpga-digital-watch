`timescale 1ns / 1ps

module button_auto_repeat_no_initial #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  localparam int CountWidth = $clog2(HOLD_CYCLES + REPEAT_CYCLES + 1);

  logic [CountWidth-1:0] count;
  logic button_d;

  always_ff @(posedge clk) begin
    button_d <= button;

    if (!button) begin
      count <= '0;
      pulse <= 1'b0;
    end else begin
      count <= count + 1'b1;

      if (!button_d) begin
        // initial press
        pulse <= 1'b1;
      end else if (
          32'(count) >= HOLD_CYCLES &&
          ((32'(count) - HOLD_CYCLES) % REPEAT_CYCLES == REPEAT_CYCLES - 1)
      ) begin
        // repeat only after hold threshold
        pulse <= 1'b1;
      end else begin
        pulse <= 1'b0;
      end
    end
  end

endmodule
