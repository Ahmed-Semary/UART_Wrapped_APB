module UART_Rx #(
  parameter N = 8
)(
  input  wire       clk , arst_n, rst, rx_en, Rx,
  input  wire [9:0] Load_Value,
  output wire       done, busy, err,
  output wire [7:0] data
);

  //Declaring Connection Wires needed
  wire       count_en, count_rst, shift_en;
  wire [3:0] count;

  //Instatiating the FSM_Controller
  FSM_Controller_Rx #(.N(N)) FSM_Controller_Rx_inst (
    .clk(clk),
    .arst_n(arst_n),
    .rst(rst),
    .rx_en(rx_en),
    .Rx(Rx),
    .count(count),
    .count_en(count_en),
    .count_rst(count_rst),
    .shift_en(shift_en),
    .done(done),
    .busy(busy),
    .err(err)
  );

  //Instatiating the Baud_counter
  Baud_Counter  Baud_Counter_inst (
    .clk(clk),
    .arst_n(arst_n),
    .count_rst(count_rst),
    .count_en(count_en),
    .Load_Value(Load_Value),
    .count(count)
  );

  //Instatiating the Shift_Register
  Shift_Reg #(.N(N)) Shift_Reg_inst (
    .serial_in(Rx),
    .clk(clk),
    .rst_n(arst_n),
    .enable(shift_en),
    .load(1'b0),
    .parallel_in(8'b0),
    .serial_out(),
    .parallel_out(data)
  );
  
endmodule