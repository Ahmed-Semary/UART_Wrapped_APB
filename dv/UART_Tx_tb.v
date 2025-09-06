`timescale 1ns/1ps

module UART_Tx_tb;

  // Parameters

  //Ports
  reg  clk;
  reg  arst_n;
  reg  rst;
  reg  tx_en;
  reg  [7:0] data;
  reg  [9:0] Load_Value;
  wire Tx;
  wire done;
  wire busy;

  UART_Tx  UART_Tx_inst (
    .clk(clk),
    .arst_n(arst_n),
    .rst(rst),
    .tx_en(tx_en),
    .data(data),
    .Load_Value(Load_Value),
    .Tx(Tx),
    .done(done),
    .busy(busy)
  );

  always #5  clk = ! clk ;

  initial begin
    clk=0;
    arst_n=1;
    rst=0;
    tx_en=0;
    data=$random;
    Load_Value=10'd650;
    @(negedge clk)
    arst_n=0;
    @(negedge clk)
    arst_n=1;
    #500
    data=8'b0011_0101;
    tx_en=1;
    wait(done==1'b1);
    tx_en=0;
  #500
    $stop;
  end

endmodule