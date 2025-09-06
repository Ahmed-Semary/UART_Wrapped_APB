vlib work
vlog Baud_Counter.v
vlog counter.v
vlog timer.v
vlog Edge_Detector.v
vlog Shift_Reg.v
vlog FSM_Controller_Rx.v
vlog FSM_Controller_Tx.v
vlog UART_APB_Interface.v
vlog UART_Rx_tb.v
vlog UART_Rx.v
vlog UART_tb.v
vlog UART_Tx_tb.v
vlog UART_Tx.v
vsim -voptargs=+acc work.UART_Rx_tb
add wave *
run -all