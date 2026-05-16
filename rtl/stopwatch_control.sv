`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst = 1'b0,
    output logic counter_enable,
    output logic lap_hold
);

  localparam logic Live = 1'b1;
  localparam logic Frozen = 1'b0;

  logic run = 1'b0;
  logic display = Live;

  logic only_lap;
  logic only_start_stop;

  assign only_lap = rise_lap && !rise_start_stop;
  assign only_start_stop = rise_start_stop && !rise_lap;

  assign counter_enable = run;
  assign lap_hold = (display == Frozen);

  always_ff @(posedge clk) begin
    counter_rst <= 1'b0;

    if (only_lap) begin
      if (!run && display == Live) counter_rst <= 1'b1;
      else if (run || display == Frozen) display <= !display;
    end else if (only_start_stop) begin
      run <= !run;
    end
  end

endmodule
