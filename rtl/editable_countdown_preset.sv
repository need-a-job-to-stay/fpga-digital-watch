`timescale 1ns / 1ps

module editable_countdown_preset #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic load,
    input logic [WIDTH-1:0] load_value,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count = '0,
    output logic borrow_out
);

  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);

  always_ff @(posedge clk) begin
    if (clr) count <= '0;
    else if (load) count <= load_value;
    else if (edit_mode) begin
      if (inc && !dec) count <= (count == Max) ? '0 : count + WIDTH'(1);
      else if (dec && !inc) count <= (count == '0) ? Max : count - WIDTH'(1);
    end else if (tick) begin
      count <= (count == '0) ? Max : count - WIDTH'(1);
    end
  end

  assign borrow_out = (!edit_mode && !clr && tick && (count == '0));

endmodule
