`timescale 1ns / 1ps

module wave_user_top_timer_add_preset;
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
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (blank_hours),
      .blank_minutes(blank_minutes),
      .blank_seconds(blank_seconds)
  );

  always #5 clk = ~clk;  // 10 ns period

  initial begin
    $dumpfile("wave_user_top_timer_add_preset.vcd");
    $dumpvars(0, wave_user_top_timer_add_preset);

    // Initial state: timer stopped at 0.
    #100;

    // --- Preset interval selection while stopped at zero ---
    // button[2] should cycle presets:
    // 1st press: 30 seconds
    // 2nd press: 1 minute
    // 3rd press: 5 minutes
    // 4th press: 25 minutes
    // 5th press: back to 0
    button[2] = 1;
    #50;
    button[2] = 0;
    #200;

    button[2] = 1;
    #50;
    button[2] = 0;
    #200;

    button[2] = 1;
    #50;
    button[2] = 0;
    #200;

    button[2] = 1;
    #50;
    button[2] = 0;
    #200;

    button[2] = 1;
    #50;
    button[2] = 0;
    #200;

    // Select 30-second preset again so timer can be started.
    button[2] = 1;
    #50;
    button[2] = 0;
    #300;

    // --- Start countdown with button[0] ---
    button[0] = 1;
    #50;
    button[0] = 0;

    // Let it run for a few simulated seconds.
    #3000;

    // --- button[2] while running should stop timer ---
    button[2] = 1;
    #50;
    button[2] = 0;
    #1000;

    // --- button[2] while stopped with remaining time should clear timer ---
    button[2] = 1;
    #50;
    button[2] = 0;
    #500;

    // --- Enter edit mode ---
    // Hold button[3] for more than HOLD_CYCLES = 50 cycles.
    button[3] = 1;
    #550;
    button[3] = 0;
    #500;

    // --- button[2] in edit mode should reset time to zero ---
    // First increment seconds so reset effect is visible.
    button[1] = 1;
    #50;
    button[1] = 0;
    #200;

    button[2] = 1;
    #50;
    button[2] = 0;
    #500;

    // --- Move through edit modes and exit ---
    button[3] = 1;
    #100;
    button[3] = 0;
    #300;

    button[3] = 1;
    #100;
    button[3] = 0;
    #300;

    button[3] = 1;
    #100;
    button[3] = 0;
    #500;

    // --- Simultaneous button[0] and button[2] while running should stop ---
    // Load 30s preset again.
    button[2] = 1;
    #50;
    button[2] = 0;
    #300;

    // Start.
    button[0] = 1;
    #50;
    button[0] = 0;
    #1000;

    // Press both button[0] and button[2].
    button[0] = 1;
    button[2] = 1;
    #50;
    button[0] = 0;
    button[2] = 0;
    #1000;

    $finish;
  end

endmodule
