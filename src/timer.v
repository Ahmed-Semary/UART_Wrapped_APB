`default_nettype none

module timer #(
    parameter TIMER_BITS=10
  ) (
    input  wire                   clk, rst_n, rst, enable,
    input  wire  [TIMER_BITS-1:0] Load_Value,
    output wire                   done
  );
  reg [TIMER_BITS-1:0] Q;

  always @(posedge clk, negedge rst_n)
  begin
    if(~rst_n)
      Q <= {TIMER_BITS{1'b0}};
	 else if (rst|done)
		Q <= Load_Value;
	 else
		Q <= Q - enable;
  end

  assign done=~|Q;

endmodule
