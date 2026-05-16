// `timescale 1ns / 1ps

// module restartable_rate_generator #(
//     parameter int CYCLE_COUNT = 2
// ) (
//     input  logic clk,
//     input  logic run,
//     output logic tick = 1'b0
// );

//   generate
//     if (CYCLE_COUNT == 1) begin : g_special

//       always_ff @(posedge clk) begin
//         tick <= run;
//       end

//     end else begin : g_general

//       localparam int CountWidth = $clog2(CYCLE_COUNT);

//       logic rst_count;
//       logic enable_count;
//       logic [CountWidth-1:0] count;

//       assign rst_count    = !run || (32'(count) == CYCLE_COUNT - 2);
//       assign enable_count = run;

//       mod_n_counter #(
//           .N(CYCLE_COUNT - 1),
//           .WIDTH(CountWidth)
//       ) u_count (
//           .clk(clk),
//           .rst(rst_count),
//           .enable(enable_count),
//           .count(count)
//       );

//       always_ff @(posedge clk) begin
//         if (!run) tick <= 1'b0;
//         else tick <= (32'(count) == CYCLE_COUNT - 2);
//       end

//     end
//   endgenerate

// endmodule
`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick = 1'b0
);

  generate
    if (CYCLE_COUNT == 1) begin : g_special

      always_ff @(posedge clk) begin
        tick <= run;
      end

    end else begin : g_general

      localparam int CountWidth = $clog2(CYCLE_COUNT);

      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;

      assign enable_count = run;
      assign rst_count    = !run;

      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      always_ff @(posedge clk) begin
        if (!run) tick <= 1'b0;
        else tick <= (32'(count) == CYCLE_COUNT - 2);
      end

    end
  endgenerate

endmodule
