`timescale 1ns / 1ps
module wave_user_top_timer_v1_d;
  reg        clk = 0;
  reg  [3:0] button = 4'b0;
  reg  [9:0] sw = 10'b0;
  wire [9:0] led;
  wire [6:0] centiseconds_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire       blank_centiseconds;
  wire       blank_minutes;
  wire       blank_seconds;

  // CYCLES_PER_SECOND=1000 keeps the simulation concise:
  //   1 simulated second  = 1000 cycles
  //   PWM period (0.5 s)  = 500 cycles  = 250 ns
  //   PWM high (0.1 s)    =  100 cycles
  //   Hold threshold (1s) = 1000 cycles
  user_top_timer_v1_d #(
      .CYCLES_PER_SECOND(1000)
  ) dut (
      .clk               (clk),
      .button            (button),
      .sw                (sw),
      .led               (led),
      .minutes_disp      (minutes_disp),
      .seconds_disp      (seconds_disp),
      .centiseconds_disp (centiseconds_disp),
      .blank_minutes     (blank_minutes),
      .blank_seconds     (blank_seconds),
      .blank_centiseconds(blank_centiseconds)
  );


  always #0.5 clk = ~clk;  // 100 MHz: 10 ns period

  initial begin
    $dumpfile("wave_user_top_timer_v1_d.vcd");
    $dumpvars(0, wave_user_top_timer_v1_d);

    // --- Normal operation: watch counts for ~1.5 seconds ---
    // seconds_disp advances once per 50 cycles; blank_* remain 0.
    #1500;  // 75 cycles = 1.5 simulated seconds

    // --- Long press: hold KEY[3] for 55 cycles (> HOLD_CYCLES=50) ---
    // button_hold_pulse fires at cycle 50 of the press, arming the latch.
    // mode_enable becomes 3'b001 (seconds selected); blank_seconds begins
    // pulsing at 2 Hz.  The rising edge at press start is ignored because
    // the latch is not yet armed.
    button[3] = 1;
    #1100;  // 55 cycles held high

    button[3] = 0;
    #2000;  // 100 cycles released; observe seconds flashing (4 PWM cycles visible)

    // --- Short press 1: advance seconds -> minutes ---
    // Rising edge detected while armed; mod-3 counter advances to 1.
    // mode_enable becomes 3'b010; blank_minutes flashes, blank_seconds stops.
    button[3] = 1;
    #200;  // 10 cycles
    button[3] = 0;
    #2000;  // 100 cycles released; observe minutes flashing (4 PWM cycles visible)

    // --- Short press 2: advance minutes -> hours ---
    // Counter advances to 2; mode_enable becomes 3'b100.
    button[3] = 1;
    #200;
    button[3] = 0;
    #2000;  // 100 cycles released; observe hours flashing (4 PWM cycles visible)

    // --- Short press 3: exit edit mode ---
    // disarm condition fires (count==2 && enable_counter); latch clears.
    // mode_enable returns to 3'b000; all blank_* return to 0.
    button[3] = 1;
    #200;
    button[3] = 0;

    // --- Normal operation resumes ---
    // blank_* are all 0; seconds_disp continues incrementing.
    #1000;  // 50 cycles

    $finish;
  end
endmodule
