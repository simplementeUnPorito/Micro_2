transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vcom -work xil_defaultlib -93  \
"../../../UART_TP_Micro2.srcs/sources_1/new/utilities.vhd" \
"../../../UART_TP_Micro2.srcs/sources_1/new/FIFO.vhd" \
"../../../UART_TP_Micro2.srcs/sources_1/new/Reciever.vhd" \
"../../../UART_TP_Micro2.srcs/sources_1/new/Reciever_FIFO.vhd" \
"../../../UART_TP_Micro2.srcs/sources_1/new/Transmitter.vhd" \
"../../../UART_TP_Micro2.srcs/sources_1/new/Transmitter_FIFO.vhd" \
"../../../UART_TP_Micro2.srcs/sources_1/imports/new/frecDivisor.vhd" \
"../../../UART_TP_Micro2.srcs/sources_1/new/UART.vhd" \
"../../../UART_TP_Micro2.srcs/sim_1/imports/new/tb_UART.vhd" \


