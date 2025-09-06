`timescale 1ns/1ps
module UART_tb;

  localparam N = 8;
  //Ports
  reg         PCLK;
  reg         PRESETn;
    //Main IP Ports
    reg         PSEL;
    reg         PENABLE;
    reg         PWRITE;
    reg  [31:0] PADDR;
    reg  [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire        PREADY;
    wire        rx;
    wire        tx;
    //Testing Device Ports
    reg        tx_en, rx_en, tx_rst, rx_rst;
    wire       rx_busy, tx_busy, rx_done, tx_done, rx_error;
    wire [7:0] Rx_data;
    reg  [7:0] Tx_data;
    reg  [9:0] Load_Value;

  //Main IP with the default data width of 8 bits
  UART_APB_Interface #(.N(N)) UART_APB_Interface_inst (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .rx(rx),
    .tx(tx)
  );

  //Another UART device Receiver
  UART_Rx #(.N(N)) UART_Rx_inst (
    .clk(PCLK),
    .arst_n(PRESETn),
    .rst(rx_rst),
    .rx_en(rx_en),
    .Rx(tx),
    .Load_Value(Load_Value),
    .done(rx_done),
    .busy(rx_busy),
    .err(rx_error),
    .data(Rx_data)
  );

  //Another UART device Transmitter
  UART_Tx #(.N(N)) UART_Tx_inst (
    .clk(PCLK),
    .arst_n(PRESETn),
    .rst(tx_rst),
    .tx_en(tx_en),
    .data(Tx_data),
    .Load_Value(Load_Value),
    .Tx(rx),
    .done(tx_done),
    .busy(tx_busy)
  );

  //Generating 100MHz Clock
  always #5  PCLK = ! PCLK ;

  //Testbench Stimulus generation 
  initial begin
    //Initialization
    PCLK=0;
    PRESETn=1;
    PSEL=0;
    PENABLE=0;
    Load_Value=10'd650;
    PWRITE=$random;
    PADDR=$random;
    PWDATA=$random;
    //Resetting
    @(negedge PCLK)
    PRESETn=0;
    @(negedge PCLK)
    PRESETn=1;
    @(negedge PCLK)
    //Writing to location 2 (tx_data)
    PSEL=1;
    PWRITE=1;
    PADDR=32'd2;
    PWDATA={24'b0,8'b0100_0101};
    //Write Operation done in two clock cycles
    @(negedge PCLK)
    PENABLE=1;
    //Driving the test UART transmitter Tx_data to be sent to our IP 
    @(posedge PCLK)
    Tx_data=8'b0101_0100;
    tx_en=0;
    rx_en=0;
    tx_rst=1;
    rx_rst=1;
    //Writing to location 0 (tx_en,rx_en,tx_rst,rx_rst) respectively
    @(negedge PCLK)
    PENABLE=0;
    PSEL=1;
    PWRITE=1;
    PADDR=32'd0;
    PWDATA={28'b0,4'b1100};
    //Write Operation done in two clock cycles
    @(negedge PCLK)
    PENABLE=1;
    //Enabling the test UART rx and tx to start the communication process with our IP
    @(posedge PCLK)
    tx_en=1;
    rx_en=1;
    tx_rst=0;
    rx_rst=0;
    @(negedge PCLK)
    PSEL=0;
    PENABLE=0;
    
    //Wait till frame transmission and reception is done
    wait(rx_done);
    #104160

    //read the received data
    @(negedge PCLK)
    PENABLE=0;
    PSEL=1;
    PWRITE=0;
    PADDR=32'd3;
    @(negedge PCLK)
    PENABLE=1;
    @(negedge PCLK)

    // Self Checking Conditions
    if(PRDATA[7:0]==Tx_data)
      $display("IP Reception Test Passed");
    else
      $display("IP Reception Test Failed");

    if(Rx_data==8'b0100_0101)
      $display("IP Transmission Test Passed");
    else
      $display("IP Transmission Test Failed");

    $display("Rx_data: %b",PRDATA[7:0]);
    $display("Tx_data: %b",Rx_data);
    $stop;
  end
endmodule