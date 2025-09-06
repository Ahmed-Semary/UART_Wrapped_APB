`timescale 1ns/1ps

module UART_Rx_tb;

  //Ports
  reg  clk;
  reg  arst_n;
  reg  rst;
  reg  rx_en;
  reg  Rx;
  reg  count_en;
  reg  [9:0] Load_Value;
  wire done;
  wire busy;
  wire err;
  wire [3:0] count;
  wire [7:0] data;

 UART_Rx  UART_Rx_inst (
    .clk(clk),
    .arst_n(arst_n),
    .rst(rst),
    .rx_en(rx_en),
    .Rx(Rx),
    .Load_Value(Load_Value),
    .done(done),
    .busy(busy),
    .err(err),
    .data(data)
  );

  Baud_Counter  Baud_Counter_inst (
    .clk(clk),
    .arst_n(arst_n),
    .count_rst(1'b0),
    .count_en(count_en),
    .Load_Value(Load_Value),
    .count(count)
  );

  always #5  clk = !clk ;

  initial begin
    clk=1;
    arst_n=1;
    rst=0;
    Rx=1;
    Load_Value=10'd650;
    count_en=0;
    rx_en=1;
    @(negedge clk)
    arst_n=0;
    @(negedge clk)
    arst_n=1;
    @(posedge clk)
    count_en=1;
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=0;   //start bit ,want to send 11010011
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=1;   //bit 0
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=1;   //bit 1
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=0;   //bit 2
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=0;   //bit 3
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=1;   //bit 4
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=0;   //bit 5
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=1;   //bit 6
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=1;   //bit 7
    wait(count==4'd15);
    wait(count==4'b0 );
    Rx=1;   //stop bit
    wait(count==4'd15);
    wait(count==4'b0 );


    $stop;
  end
endmodule