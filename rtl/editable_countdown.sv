`timescale 1ns / 1ps
module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH -1:0] count,
    output logic borrow_out
);

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  wire enable;
  wire up;

  assign borrow_out = (edit_mode || clr) ? 1'b0 : (tick_event && (count == 0));
  assign up = inc_event;
  assign enable = inc_event || tick_event || dec_event;

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .rst(clr),
      .up(up),
      .count(count)
  );

endmodule
