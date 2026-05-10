module pwm_generator #(
 // Number of clock cycles in one PWM period
3 parameter int PERIOD_CYCLES = 50 _000_000 ,
4
5 // Number of clock cycles output is high
6 parameter int DUTY_CYCLES = 25 _000_000
7 ) (
8 input logic clk ,
9 input logic rst ,
10 output logic pwm_out
11 ) ;