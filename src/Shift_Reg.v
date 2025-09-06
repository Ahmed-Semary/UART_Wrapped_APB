module Shift_Reg #(
    parameter N=8
  ) (
    input serial_in , clk , rst_n , enable , load,
    input [N-1:0] parallel_in,
    output serial_out,
    output [N-1:0] parallel_out
  );
  reg [N-1:0] shift_reg;

  always @(posedge clk, negedge rst_n)
  begin
    if(~rst_n)
      shift_reg<='b0;
    else if(load)
      shift_reg<=parallel_in;
    else if(enable)
      shift_reg<={serial_in,shift_reg[N-1:1]};
    else
      shift_reg<=shift_reg;
  end

  assign serial_out=shift_reg[0];
  assign parallel_out=shift_reg;

endmodule
