`timescale 1ns / 1ps
module wave_restartable_rate_generator_idk;
  reg clk = 0;
  reg run = 0;
  wire tick;
  wire rst_count;
  wire [$clog2(5)-1:0] count;

  restartable_rate_generator #(
      .CYCLE_COUNT(5)
  ) dut (
      .clk(clk),
      .run(run),
      .tick(tick),
      .rst_count(rst_count),
      .count(count)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_restartable_rate_generator_idk.vcd");
    $dumpvars(0, wave_restartable_rate_generator_idk);

    // Run: tick fires every CYCLE_COUNT clocks
    #30;
    run = 1;
    #130;

    // Disable mid-cycle: counter resets, no stray tick on re-enable
    run = 0;
    #30;
    run = 1;
    #90;

    run = 0;
    #20 $finish;
  end
endmodule
