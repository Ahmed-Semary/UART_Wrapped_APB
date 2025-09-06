module FSM_Controller_Rx #(
  parameter N = 8
)(
  input  wire       clk, arst_n, rst, rx_en, Rx,
  input  wire [3:0] count,
  output wire       count_en, count_rst, shift_en, done, busy, err
);
  
  //Declaring States Coding
  localparam idle  =2'b00;
  localparam start =2'b01;
  localparam data  =2'b10;
  localparam stop  =2'b11;

  reg [1:0] present_state, next_state;

  wire half_done, bit_done, bit_done_n_edge, frame_done;
  wire [3:0] bits_count;

  //Setting needed timer ticks
  assign half_done  = (count==4'd8  );
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
    else if (rst|~rx_en)
      present_state<=idle;
    else
      present_state<=next_state;
  end

  //State Transitions Logic
  always @(*) begin
    case(present_state)
      idle  :  next_state<= ~Rx        ? start : idle ;
      start :  next_state<= half_done  ? data  : start;
      data  :  next_state<= frame_done ? stop  : data ;
      stop  :  next_state<= bit_done_n_edge   ? idle  : stop ;
    endcase
  end
  //Outputs assignment
  assign shift_en = (present_state==data) & bit_done_n_edge;
  assign count_en = (present_state!=idle);
  assign count_rst= ((present_state==start)&&half_done || (present_state==idle));
  assign done     = (present_state==stop) && bit_done_n_edge &&  Rx;
  assign err      = (present_state==stop) && bit_done_n_edge && ~Rx;
  assign busy     =  count_en;

endmodule