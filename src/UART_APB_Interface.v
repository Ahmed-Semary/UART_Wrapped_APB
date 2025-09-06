module UART_APB_Interface #(
  parameter N = 8
)(
  //Ports from the Controller side
  input  wire        PCLK, PRESETn, PSEL, PENABLE, PWRITE,
  input  wire [31:0] PADDR, PWDATA,
  output reg  [31:0] PRDATA,
  output reg         PREADY,
  
  //Ports from the outside of the chip
  input  wire        rx,
  output wire        tx
);
  //Declaring the required connection wires
  wire         tx_en, rx_en, tx_rst, rx_rst,
               rx_busy, tx_busy, rx_done, tx_done, rx_error;
  wire [N-1:0] Tx_data, Rx_data;
  wire [9:0]   Load_Value;

  //Declaring the register file
  reg [31:0] reg_space [0:4];

  //FSM States
  localparam idle = 2'b00;
  localparam write= 2'b01;
  localparam read = 2'b10;

  //FSM Variable
  reg [1:0] state;

  //FSM Logic
  always @(posedge PCLK, negedge PRESETn) begin
    if (~PRESETn) begin
      state <=idle;
      PRDATA<=0;
      PREADY<=1'b0;
      //Resetting the reg file
		reg_space[0]<=32'b0;
		reg_space[1]<=32'b0;
		reg_space[2]<=32'b0;
		reg_space[3]<=32'b0;
      reg_space[4]<=10'd650;  //defaults to 9600 baud rate
    end
    else begin
      case(state)
        idle:
          begin
            PRDATA<=0;
            //Transition to either write or read state depending on PWRITE
            state <= PSEL ? ( PWRITE ? write : read ) : idle;
          end
        write:
          begin
            if (PWRITE && PENABLE && PSEL) begin
              if((PADDR==3'd0)||(PADDR==3'd2)||(PADDR==3'd4))
                reg_space[PADDR]<=PWDATA;
            end
            //Asserting PREADY and the FSM returns to idle after write transaction
            PREADY<=1;
            state <= idle;
          end
        read:
          begin
            if (~PWRITE && PENABLE && PSEL) begin
              case (PADDR)
                3'd0: PRDATA <= reg_space[0];
                3'd1: PRDATA <= {27'b0,rx_busy,tx_busy,rx_done,tx_done,rx_error};
                3'd2: PRDATA <= reg_space[2];
                3'd3: PRDATA <= {Rx_data};
                3'd4: PRDATA <= reg_space[4];
                default: PRDATA <= 32'b0;
              endcase
            end
            //Asserting PREADY and the FSM returns to idle after read transaction
            PREADY<=1;
            state <= idle;
          end
        default: state<=idle;
      endcase
    end
  end

  //Assigning control signals from the register file
  assign rx_rst    = reg_space[0][0];
  assign tx_rst    = reg_space[0][1];
  assign rx_en     = reg_space[0][2];
  assign tx_en     = reg_space[0][3];
  assign Tx_data   = reg_space[2][N-1:0];
  assign Load_Value= reg_space[4][9:0];

  //Instantaiting and Connecting the UART Transmitter
  UART_Tx #(.N(N)) UART_Tx_inst (
    .clk(PCLK),
    .arst_n(PRESETn),
    .rst(tx_rst),
    .tx_en(tx_en),
    .data(Tx_data),
    .Load_Value(Load_Value),
    .Tx(tx),
    .done(tx_done),
    .busy(tx_busy)
  );

  //Instantaiting and Connecting the UART Receiver
  UART_Rx #(.N(N)) UART_Rx_inst (
    .clk(PCLK),
    .arst_n(PRESETn),
    .rst(rx_rst),
    .rx_en(rx_en),
    .Rx(rx),
    .Load_Value(Load_Value),
    .done(rx_done),
    .busy(rx_busy),
    .err(rx_error),
    .data(Rx_data)
  );
  
endmodule