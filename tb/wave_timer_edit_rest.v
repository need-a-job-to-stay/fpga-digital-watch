`timescale 1ns / 1ps

module wave_timer_edit_reset;
  reg        clk = 0;
  reg  [3:0] button = 4'b0;
  reg  [9:0] sw = 10'b0;

  wire [9:0] led;
  wire [6:0] hours_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire       blank_hours;
  wire       blank_minutes;
  wire       blank_seconds;

  user_top_timer_add_preset #(
      .CYCLES_PER_SECOND(50)
  ) dut (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(blank_hours),
      .blank_minutes(blank_minutes),
      .blank_seconds(blank_seconds)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_timer_edit_reset.vcd");
    $dumpvars(0, wave_timer_edit_reset);

    // -------------------------
    // Enter edit mode
    // Hold button[3] > 50 cycles
    // -------------------------
    button[3] = 1;
    #550;
    button[3] = 0;

    #200;

    // -------------------------
    // Increase seconds
    // -------------------------
    button[0] = 1;
    #50;
    button[0] = 0;

    #300;

    // -------------------------
    // Press button[2]
    // Time should reset to zero
    // -------------------------
    button[2] = 1;
    #50;
    button[2] = 0;

    #500;

    $finish;
  end

endmodule
