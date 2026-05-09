`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   // binary input , 0 -99
    output logic [3:0] tens,  // decimal tens digit ( BCD )
    output logic [3:0] ones   // decimal ones digit ( BCD )
);
  localparam int WIDTH = 7;
  localparam logic [WIDTH-1:0] MAX = WIDTH'(99);
  localparam logic [WIDTH-1:0] DIVIDER = WIDTH'(10);


  always_comb begin
    if (bin > MAX) begin
      tens = 'b0;
      ones = 'b0;
    end else begin
      //convert RHS to 4 bits.
      tens = 4'(bin / DIVIDER);
      ones = 4'(bin % DIVIDER);
    end
  end

endmodule
