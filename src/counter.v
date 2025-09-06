module counter #(
    parameter WIDTH=4
) (
    input  wire             clk, enab, rst_n, rst,
    output reg  [WIDTH-1:0] cnt_out
);

    always @(posedge clk , negedge rst_n) begin
        if(~rst_n)
            cnt_out<=0;
        else if (rst)
            cnt_out<=0;
        else if (enab)
            cnt_out<=cnt_out+1'b1;
        else
            cnt_out<=cnt_out;
    end

endmodule
