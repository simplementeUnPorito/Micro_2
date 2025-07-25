set_property SRC_FILE_INFO {cfile:c:/Users/Elias/OneDrive/UCA/9_Semestre/Micro_2/Vivado/Mips_con_UART/Mips_con_UART.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../../../Mips_con_UART.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:inst_divisor/inst} [current_design]
set_property SRC_FILE_INFO {cfile:C:/Users/Elias/OneDrive/UCA/9_Semestre/Micro_2/Vivado/Mips_con_UART/Mips_con_UART.srcs/constrs_1/imports/MIPS-2023/ZYBO_Master.xdc rfile:../../../Mips_con_UART.srcs/constrs_1/imports/MIPS-2023/ZYBO_Master.xdc id:2} [current_design]
current_instance inst_divisor/inst
set_property src_info {type:SCOPED_XDC file:1 line:54 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk]] 0.080
current_instance
set_property src_info {type:XDC file:2 line:7 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 } [get_ports { rx1 }];
set_property src_info {type:XDC file:2 line:9 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports { tx1 }];
set_property src_info {type:XDC file:2 line:11 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports {clk}]; #IO_L11P_T1_SRCC_35 Sch=sysclk
set_property src_info {type:XDC file:2 line:17 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { llaves[0] }]; #IO_L19N_T3_VREF_35 Sch=SW0
set_property src_info {type:XDC file:2 line:18 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { llaves[1] }]; #IO_L24P_T3_34 Sch=SW1
set_property src_info {type:XDC file:2 line:19 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { llaves[2] }]; #IO_L4N_T0_34 Sch=SW2
set_property src_info {type:XDC file:2 line:20 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { llaves[3] }]; #IO_L9P_T1_DQS_34 Sch=SW3
set_property src_info {type:XDC file:2 line:24 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { botones[0] }]; #IO_L20N_T3_34 Sch=BTN0
set_property src_info {type:XDC file:2 line:25 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { botones[1] }]; #IO_L24N_T3_34 Sch=BTN1
set_property src_info {type:XDC file:2 line:26 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { botones[2] }]; #IO_L18P_T2_34 Sch=BTN2
set_property src_info {type:XDC file:2 line:27 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { botones[3] }]; #IO_L7P_T1_34 Sch=BTN3
set_property src_info {type:XDC file:2 line:31 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { salida[0] }]; #IO_L23P_T3_35 Sch=LED0
set_property src_info {type:XDC file:2 line:32 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { salida[1] }]; #IO_L23N_T3_35 Sch=LED1
set_property src_info {type:XDC file:2 line:33 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { salida[2] }]; #IO_0_35=Sch=LED2
set_property src_info {type:XDC file:2 line:34 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { salida[3] }]; #IO_L3N_T0_DQS_AD1N_35 Sch=LED3
set_property src_info {type:XDC file:2 line:118 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { reset_boton }]; #IO_L4P_T0_34 Sch=JE1
set_property src_info {type:XDC file:2 line:121 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { atn }]; #IO_L19P_T3_35 Sch=JE4
