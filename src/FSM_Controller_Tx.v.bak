module FSM_Controller_Tx #(
  parameter N = 8
)(
  input  wire       clk, arst_n, rst, tx_en, serial,
  input  wire [3:0] count,
  output wire       count_en, count_rst, shift_en, load_en, done, busy,
  output reg        Tx
);
  
  //Declaring States Coding
  localparam idle  =2'b00;
  localparam start =2'b01;
  localparam data  =2'b10;
  localparam stop  =2'b11;

  reg [1:0] present_state, next_state;

  wire bit_done, bit_done_n_edge, frame_done, frame_rst;
  wire [3:0] bits_count;

  //Setting needed timer ticks
  assign bit_done   = (count==4'd15 );
  assign frame_done = (bits_count==N);

  //This edge detector is used to detect when signal bit_count gows low again (indicated counter going from 15 to 0)
  //This is used instead of bit_count as it stays asserted for a bit time period not a singe clock cycle
  Edge_Detector_Mealy  Edge_Detector_Mealy_inst (
    .clk(clk),
    .level(bit_done),
    .rst_n(arst_n),
    .p_edge(),
    .n_edge(bit_done_n_edge)
  );

  //Another counter instance to count the number of bits sampled
  counter counter_inst (
    .clk(clk),
    .enab(bit_done_n_edge && (present_state==data)),
    .rst_n(arst_n),
    .rst(present_state==idle),
    .cnt_out(bits_count)
  );

  always @(posedge clk, negedge arst_n) begin
    if(~arst_n)
      present_state<=idle;
    else if(rst|~tx_en)
      present_state<=idle;
    else
      present_state<=next_state;
  end

  //State Transitions Logic
  always @(*) begin
    case(present_state)
      idle  : begin 
                next_state<= tx_en            ? start : idle ;
                Tx <= 1'b1;
              end
      start : begin 
                next_state<= bit_done_n_edge  ? data  : start;
                Tx <= 1'b0;
              end
      data  : begin 
                next_state<= frame_done       ? stop  : data ;
                Tx <= serial;
              end
      stop  : begin
                next_state<= bit_done_n_edge  ? idle  : stop ;
                Tx <= 1'b1;
              end
    endcase
  end

  //Outputs assignment
  assign shift_en = (present_state==data) && bit_done_n_edge;
  assign load_en  = (present_state==idle) && tx_en;
  assign count_en = (present_state!=idle);
  assign count_rst= (present_state==idle);
  assign done     = (present_state==stop) && bit_done_n_edge;
  assign busy     =  count_en;

endmodule