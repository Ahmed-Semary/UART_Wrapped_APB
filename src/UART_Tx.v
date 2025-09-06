module UART_Tx #(
  parameter N = 8
)(
  input  wire       clk, arst_n, rst, tx_en,
  input  wire [7:0] data,
  input  wire [9:0] Load_Value,
  output wire       Tx, done, busy
);
  
  //Declaring Connection Wires needed
  wire       count_en, count_rst, shift_en, load_en, serial;
  wire [3:0] count;

  //Instatiating the FSM_Controller
  FSM_Controller_Tx #(.N(N)) FSM_Controller_Tx_inst (
    .clk(clk),
    .arst_n(arst_n),
    .rst(rst),
    .tx_en(tx_en),
    .serial(serial),
    .count(count),
    .count_en(count_en),
    .count_rst(count_rst),
    .shift_en(shift_en),
    .load_en(load_en),
    .done(done),
    .busy(busy),
    .Tx(Tx)
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
    .serial_in(1'b0),
    .clk(clk),
    .rst_n(arst_n),
    .enable(shift_en),
    .load(load_en),
    .parallel_in(data),
    .serial_out(serial),
    .parallel_out()
  );
endmodule