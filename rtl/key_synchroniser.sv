`timescale 1ns / 1ps
module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active -low , asynchronous
    output logic [3:0] key_sync = 4'b0  //active -high , synchronised
);
  logic [3:0] inverted_key;
  logic [3:0] first_key_sync = 4'b0;

  always_ff @(posedge clk) begin
    first_key_sync <= inverted_key;
    key_sync <= first_key_sync;
  end

  assign inverted_key = ~key_n;
endmodule
