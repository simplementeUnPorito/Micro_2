transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+tb_uart  -L xil_defaultlib -L secureip -O5 xil_defaultlib.tb_uart

do {tb_uart.udo}

run 1000ns

endsim

quit -force
