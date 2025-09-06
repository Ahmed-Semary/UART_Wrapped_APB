// module Edge_Detector_Moore (
//     input  wire clk,level,rst_n,
//     output wire p_edge,n_edge
//   );
//   localparam s0=0,s1=1,s2=2,s3=3;
//   reg [1:0]  present_state,next_state;


//   always @(posedge clk,negedge rst_n)
//   begin
//     if(~rst_n)
//       present_state<=0;
//     else
//       present_state<=next_state;
//   end

//   always @(*)
//   begin
//     case (present_state)
//       s0:
//         next_state<=level ? s1 : s0;
//       s1:
//         next_state<=level ? s2 : s3;
//       s2:
//         next_state<=level ? s2 : s3;
//       s3:
//         next_state<=level ? s1 : s0;
//       default:
//         next_state<=s0;
//     endcase
//   end

//   assign {p_edge,n_edge}={(present_state==s1),(present_state==s3)};
// endmodule

module Edge_Detector_Mealy (
    input clk,level,rst_n,
    output p_edge,n_edge
);
    localparam s0=0,s1=1;
    reg [1:0]  present_state,next_state;
 
    always @(posedge clk,negedge rst_n)
    begin
        if(~rst_n)
        present_state<=0;
        else
        present_state<=next_state;
    end

    always @(*) begin
        case (present_state)
            s0:      next_state<= level ? s1 : s0;
            s1:      next_state<= level ? s1 : s0;
            default: next_state<= s0; 
        endcase
    end
 
    assign {p_edge,n_edge}={(present_state==s0)&level&rst_n,(present_state==s1)&(~level)&rst_n};
endmodule

// module Edge_Detector (
//     input clk,level,rst_n,
//     output reg p_edge,n_edge
// );
//     reg present_state;

//     always @(posedge clk,negedge rst_n)
//     begin
//         if(~rst_n) begin
//           present_state<=0;
//           p_edge <= 1'b0;
//           n_edge <= 1'b0;
//         end  
//         else begin
//           p_edge <= ({present_state,level}==2'b01);
//           n_edge <= ({present_state,level}==2'b10);
//           present_state<=level;
//         end
//     end
// endmodule