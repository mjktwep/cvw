# The main clocks are all autogenerated by the Xilinx IP
# mmcm_clkout1 is the 22Mhz clock from the DDR4 IP used to drive wally and the AHBLite Bus.
# mmcm_clkout0 is the clock output of the DDR4 memory interface / 4.
# This clock is not used by wally or the AHBLite Bus. However it is used by the AXI BUS on the DD4 IP.

create_generated_clock -name CLKDiv64_Gen -source [get_pins wallypipelinedsoc/uncore.uncore/sdc.SDC/sd_top/slow_clk_divider/clkMux/I0] -multiply_by 1 -divide_by 2 [get_pins wallypipelinedsoc/uncore.uncore/sdc.SDC/sd_top/slow_clk_divider/clkMux/O]

##### GPI ####
set_property PACKAGE_PIN BB24 [get_ports {GPI[0]}]
set_property PACKAGE_PIN BF22 [get_ports {GPI[1]}]
set_property PACKAGE_PIN BD23 [get_ports {GPI[2]}]
set_property PACKAGE_PIN BE23 [get_ports {GPI[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {GPI[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {GPI[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {GPI[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {GPI[0]}]
set_input_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 2.000 [get_ports {GPI[*]}]
set_input_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 2.000 [get_ports {GPI[*]}]
set_max_delay -from [get_ports {GPI[*]}] 10.000

##### GPO ####
set_property PACKAGE_PIN AT32 [get_ports {GPO[0]}]
set_property PACKAGE_PIN AV34 [get_ports {GPO[1]}]
set_property PACKAGE_PIN AY30 [get_ports {GPO[2]}]
set_property PACKAGE_PIN BF32 [get_ports {GPO[4]}]
set_property PACKAGE_PIN BB32 [get_ports {GPO[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {GPO[4]}]
set_property IOSTANDARD LVCMOS12 [get_ports {GPO[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {GPO[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports {GPO[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {GPO[0]}]
set_max_delay -to [get_ports {GPO[*]}] 10.000
set_output_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 0.000 [get_ports {GPO[*]}]
set_output_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 0.000 [get_ports {GPO[*]}]


##### UART #####
set_property PACKAGE_PIN AW25 [get_ports UARTSin]
set_property PACKAGE_PIN BB21 [get_ports UARTSout]
set_max_delay -from [get_ports UARTSin] 10.000
set_max_delay -to [get_ports UARTSout] 10.000
set_property IOSTANDARD LVCMOS18 [get_ports UARTSin]
set_property IOSTANDARD LVCMOS18 [get_ports UARTSout]
set_property DRIVE 6 [get_ports UARTSout]
set_input_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 2.000 [get_ports UARTSin]
set_input_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 2.000 [get_ports UARTSin]
set_output_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 0.000 [get_ports UARTSout]
set_output_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 0.000 [get_ports UARTSout]


##### reset #####
set_input_delay -clock [get_clocks default_250mhz_clk1_0_p] -min -add_delay 2.000 [get_ports reset]
set_input_delay -clock [get_clocks default_250mhz_clk1_0_p] -max -add_delay 2.000 [get_ports reset]
set_input_delay -clock [get_clocks mmcm_clkout0] -min -add_delay 0.000 [get_ports reset]
set_input_delay -clock [get_clocks mmcm_clkout0] -max -add_delay 0.000 [get_ports reset]
set_input_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 0.000 [get_ports reset]
set_input_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 0.000 [get_ports reset]
set_max_delay -from [get_ports reset] 15.000
set_false_path -from [get_ports reset]
set_property PACKAGE_PIN L19 [get_ports {reset}]
set_property IOSTANDARD LVCMOS12 [get_ports {reset}]



##### cpu_reset #####
set_property PACKAGE_PIN AV36 [get_ports {cpu_reset}]
set_property IOSTANDARD LVCMOS12 [get_ports {cpu_reset}]
set_output_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 0.000 [get_ports {cpu_reset}]
set_output_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 0.000 [get_ports {cpu_reset}]


##### calib #####
set_property PACKAGE_PIN BA37 [get_ports calib]
set_property IOSTANDARD LVCMOS12 [get_ports calib]
set_output_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 0.000 [get_ports calib]
set_output_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 20.000 [get_ports calib]
set_max_delay -from [get_pins xlnx_ddr4_c0/inst/u_ddr4_mem_intfc/u_ddr_cal_top/calDone_gated_reg/C] -to [get_ports calib] 50.000


##### ahblite_resetn #####
set_property PACKAGE_PIN AU37 [get_ports {ahblite_resetn}]
set_property IOSTANDARD LVCMOS12 [get_ports {ahblite_resetn}]
set_output_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 0.000 [get_ports {ahblite_resetn}]
set_output_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 0.000 [get_ports {ahblite_resetn}]


##### south_rst #####
set_property PACKAGE_PIN BE22 [get_ports south_rst]
set_property IOSTANDARD LVCMOS18 [get_ports south_rst]
set_input_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 2.000 [get_ports south_rst]
set_input_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 2.000 [get_ports south_rst]


##### SD Card I/O #####
set_property PACKAGE_PIN AY14 [get_ports {SDCDat[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {SDCDat[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {SDCDat[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {SDCDat[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {SDCDat[0]}]
set_property PACKAGE_PIN AU16 [get_ports {SDCDat[2]}]
set_property PACKAGE_PIN AV16 [get_ports {SDCDat[1]}]
set_property PACKAGE_PIN AW15 [get_ports {SDCDat[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports SDCCLK]
set_property IOSTANDARD LVCMOS18 [get_ports {SDCCmd}]
set_property PACKAGE_PIN AV15 [get_ports SDCCLK]
set_property PACKAGE_PIN AY15 [get_ports {SDCCmd}]
set_property PULLUP true [get_ports {SDCDat[3]}]
set_property PULLUP true [get_ports {SDCDat[2]}]
set_property PULLUP true [get_ports {SDCDat[1]}]
set_property PULLUP true [get_ports {SDCDat[0]}]
set_property PULLUP true [get_ports {SDCCmd}]


set_input_delay -clock [get_clocks CLKDiv64_Gen] -min -add_delay 2.500 [get_ports {SDCDat[*]}]
set_input_delay -clock [get_clocks CLKDiv64_Gen] -max -add_delay 21.000 [get_ports {SDCDat[*]}]

set_input_delay -clock [get_clocks CLKDiv64_Gen] -min -add_delay 2.500 [get_ports {SDCCmd}]
set_input_delay -clock [get_clocks CLKDiv64_Gen] -max -add_delay 14.000 [get_ports {SDCCmd}]


set_output_delay -clock [get_clocks CLKDiv64_Gen] -min -add_delay 2.000 [get_ports {SDCCmd}]
set_output_delay -clock [get_clocks CLKDiv64_Gen] -max -add_delay 6.000 [get_ports {SDCCmd}]

set_output_delay -clock [get_clocks CLKDiv64_Gen] 0.000 [get_ports SDCCLK]



set_property DCI_CASCADE {64} [get_iobanks 65]
set_property INTERNAL_VREF 0.9 [get_iobanks 65]


set_property PACKAGE_PIN E13 [get_ports c0_ddr4_act_n]
set_property PACKAGE_PIN D14 [get_ports {c0_ddr4_adr[0]}]
set_property PACKAGE_PIN C12 [get_ports {c0_ddr4_adr[10]}]
set_property PACKAGE_PIN B13 [get_ports {c0_ddr4_adr[11]}]
set_property PACKAGE_PIN C13 [get_ports {c0_ddr4_adr[12]}]
set_property PACKAGE_PIN D15 [get_ports {c0_ddr4_adr[13]}]
set_property PACKAGE_PIN H14 [get_ports {c0_ddr4_adr[14]}]
set_property PACKAGE_PIN H15 [get_ports {c0_ddr4_adr[15]}]
set_property PACKAGE_PIN F15 [get_ports {c0_ddr4_adr[16]}]
set_property PACKAGE_PIN B15 [get_ports {c0_ddr4_adr[1]}]
set_property PACKAGE_PIN B16 [get_ports {c0_ddr4_adr[2]}]
set_property PACKAGE_PIN C14 [get_ports {c0_ddr4_adr[3]}]
set_property PACKAGE_PIN C15 [get_ports {c0_ddr4_adr[4]}]
set_property PACKAGE_PIN A13 [get_ports {c0_ddr4_adr[5]}]
set_property PACKAGE_PIN A14 [get_ports {c0_ddr4_adr[6]}]
set_property PACKAGE_PIN A15 [get_ports {c0_ddr4_adr[7]}]
set_property PACKAGE_PIN A16 [get_ports {c0_ddr4_adr[8]}]
set_property PACKAGE_PIN B12 [get_ports {c0_ddr4_adr[9]}]
set_property PACKAGE_PIN G15 [get_ports {c0_ddr4_ba[0]}]
set_property PACKAGE_PIN G13 [get_ports {c0_ddr4_ba[1]}]
set_property PACKAGE_PIN H13 [get_ports {c0_ddr4_bg[0]}]
set_property PACKAGE_PIN F14 [get_ports {c0_ddr4_ck_t[0]}]
set_property PACKAGE_PIN E14 [get_ports {c0_ddr4_ck_c[0]}]
set_property PACKAGE_PIN A10 [get_ports {c0_ddr4_cke[0]}]
set_property PACKAGE_PIN F13 [get_ports {c0_ddr4_cs_n[0]}]
set_property PACKAGE_PIN F11 [get_ports {c0_ddr4_dq[0]}]
set_property PACKAGE_PIN M18 [get_ports {c0_ddr4_dq[10]}]
set_property PACKAGE_PIN M17 [get_ports {c0_ddr4_dq[11]}]
set_property PACKAGE_PIN N19 [get_ports {c0_ddr4_dq[12]}]
set_property PACKAGE_PIN N18 [get_ports {c0_ddr4_dq[13]}]
set_property PACKAGE_PIN N17 [get_ports {c0_ddr4_dq[14]}]
set_property PACKAGE_PIN M16 [get_ports {c0_ddr4_dq[15]}]
set_property PACKAGE_PIN L16 [get_ports {c0_ddr4_dq[16]}]
set_property PACKAGE_PIN K16 [get_ports {c0_ddr4_dq[17]}]
set_property PACKAGE_PIN L18 [get_ports {c0_ddr4_dq[18]}]
set_property PACKAGE_PIN K18 [get_ports {c0_ddr4_dq[19]}]
set_property PACKAGE_PIN E11 [get_ports {c0_ddr4_dq[1]}]
set_property PACKAGE_PIN J17 [get_ports {c0_ddr4_dq[20]}]
set_property PACKAGE_PIN H17 [get_ports {c0_ddr4_dq[21]}]
set_property PACKAGE_PIN H19 [get_ports {c0_ddr4_dq[22]}]
set_property PACKAGE_PIN H18 [get_ports {c0_ddr4_dq[23]}]
set_property PACKAGE_PIN F19 [get_ports {c0_ddr4_dq[24]}]
set_property PACKAGE_PIN F18 [get_ports {c0_ddr4_dq[25]}]
set_property PACKAGE_PIN E19 [get_ports {c0_ddr4_dq[26]}]
set_property PACKAGE_PIN E18 [get_ports {c0_ddr4_dq[27]}]
set_property PACKAGE_PIN G20 [get_ports {c0_ddr4_dq[28]}]
set_property PACKAGE_PIN F20 [get_ports {c0_ddr4_dq[29]}]
set_property PACKAGE_PIN F10 [get_ports {c0_ddr4_dq[2]}]
set_property PACKAGE_PIN E17 [get_ports {c0_ddr4_dq[30]}]
set_property PACKAGE_PIN D16 [get_ports {c0_ddr4_dq[31]}]
set_property PACKAGE_PIN D17 [get_ports {c0_ddr4_dq[32]}]
set_property PACKAGE_PIN C17 [get_ports {c0_ddr4_dq[33]}]
set_property PACKAGE_PIN C19 [get_ports {c0_ddr4_dq[34]}]
set_property PACKAGE_PIN C18 [get_ports {c0_ddr4_dq[35]}]
set_property PACKAGE_PIN D20 [get_ports {c0_ddr4_dq[36]}]
set_property PACKAGE_PIN D19 [get_ports {c0_ddr4_dq[37]}]
set_property PACKAGE_PIN C20 [get_ports {c0_ddr4_dq[38]}]
set_property PACKAGE_PIN B20 [get_ports {c0_ddr4_dq[39]}]
set_property PACKAGE_PIN F9 [get_ports {c0_ddr4_dq[3]}]
set_property PACKAGE_PIN N23 [get_ports {c0_ddr4_dq[40]}]
set_property PACKAGE_PIN M23 [get_ports {c0_ddr4_dq[41]}]
set_property PACKAGE_PIN R21 [get_ports {c0_ddr4_dq[42]}]
set_property PACKAGE_PIN P21 [get_ports {c0_ddr4_dq[43]}]
set_property PACKAGE_PIN R22 [get_ports {c0_ddr4_dq[44]}]
set_property PACKAGE_PIN P22 [get_ports {c0_ddr4_dq[45]}]
set_property PACKAGE_PIN T23 [get_ports {c0_ddr4_dq[46]}]
set_property PACKAGE_PIN R23 [get_ports {c0_ddr4_dq[47]}]
set_property PACKAGE_PIN K24 [get_ports {c0_ddr4_dq[48]}]
set_property PACKAGE_PIN J24 [get_ports {c0_ddr4_dq[49]}]
set_property PACKAGE_PIN H12 [get_ports {c0_ddr4_dq[4]}]
set_property PACKAGE_PIN M21 [get_ports {c0_ddr4_dq[50]}]
set_property PACKAGE_PIN L21 [get_ports {c0_ddr4_dq[51]}]
set_property PACKAGE_PIN K21 [get_ports {c0_ddr4_dq[52]}]
set_property PACKAGE_PIN J21 [get_ports {c0_ddr4_dq[53]}]
set_property PACKAGE_PIN K22 [get_ports {c0_ddr4_dq[54]}]
set_property PACKAGE_PIN J22 [get_ports {c0_ddr4_dq[55]}]
set_property PACKAGE_PIN H23 [get_ports {c0_ddr4_dq[56]}]
set_property PACKAGE_PIN H22 [get_ports {c0_ddr4_dq[57]}]
set_property PACKAGE_PIN E23 [get_ports {c0_ddr4_dq[58]}]
set_property PACKAGE_PIN E22 [get_ports {c0_ddr4_dq[59]}]
set_property PACKAGE_PIN G12 [get_ports {c0_ddr4_dq[5]}]
set_property PACKAGE_PIN F21 [get_ports {c0_ddr4_dq[60]}]
set_property PACKAGE_PIN E21 [get_ports {c0_ddr4_dq[61]}]
set_property PACKAGE_PIN F24 [get_ports {c0_ddr4_dq[62]}]
set_property PACKAGE_PIN F23 [get_ports {c0_ddr4_dq[63]}]
set_property PACKAGE_PIN E9 [get_ports {c0_ddr4_dq[6]}]
set_property PACKAGE_PIN D9 [get_ports {c0_ddr4_dq[7]}]
set_property PACKAGE_PIN R19 [get_ports {c0_ddr4_dq[8]}]
set_property PACKAGE_PIN P19 [get_ports {c0_ddr4_dq[9]}]
set_property PACKAGE_PIN D11 [get_ports {c0_ddr4_dqs_t[0]}]
set_property PACKAGE_PIN D10 [get_ports {c0_ddr4_dqs_c[0]}]
set_property PACKAGE_PIN P17 [get_ports {c0_ddr4_dqs_t[1]}]
set_property PACKAGE_PIN P16 [get_ports {c0_ddr4_dqs_c[1]}]
set_property PACKAGE_PIN K19 [get_ports {c0_ddr4_dqs_t[2]}]
set_property PACKAGE_PIN J19 [get_ports {c0_ddr4_dqs_c[2]}]
set_property PACKAGE_PIN F16 [get_ports {c0_ddr4_dqs_t[3]}]
set_property PACKAGE_PIN E16 [get_ports {c0_ddr4_dqs_c[3]}]
set_property PACKAGE_PIN A19 [get_ports {c0_ddr4_dqs_t[4]}]
set_property PACKAGE_PIN A18 [get_ports {c0_ddr4_dqs_c[4]}]
set_property PACKAGE_PIN N22 [get_ports {c0_ddr4_dqs_t[5]}]
set_property PACKAGE_PIN M22 [get_ports {c0_ddr4_dqs_c[5]}]
set_property PACKAGE_PIN M20 [get_ports {c0_ddr4_dqs_t[6]}]
set_property PACKAGE_PIN L20 [get_ports {c0_ddr4_dqs_c[6]}]
set_property PACKAGE_PIN H24 [get_ports {c0_ddr4_dqs_t[7]}]
set_property PACKAGE_PIN G23 [get_ports {c0_ddr4_dqs_c[7]}]
set_property PACKAGE_PIN C8 [get_ports {c0_ddr4_odt[0]}]
set_property PACKAGE_PIN N20 [get_ports c0_ddr4_reset_n]


set_property PACKAGE_PIN G11 [get_ports {c0_ddr4_dm_dbi_n[0]}]
set_property PACKAGE_PIN R18 [get_ports {c0_ddr4_dm_dbi_n[1]}]
set_property PACKAGE_PIN K17 [get_ports {c0_ddr4_dm_dbi_n[2]}]
set_property PACKAGE_PIN G18 [get_ports {c0_ddr4_dm_dbi_n[3]}]
set_property PACKAGE_PIN B18 [get_ports {c0_ddr4_dm_dbi_n[4]}]
set_property PACKAGE_PIN P20 [get_ports {c0_ddr4_dm_dbi_n[5]}]
set_property PACKAGE_PIN L23 [get_ports {c0_ddr4_dm_dbi_n[6]}]
set_property PACKAGE_PIN G22 [get_ports {c0_ddr4_dm_dbi_n[7]}]





set_max_delay -datapath_only -from [get_pins xlnx_ddr4_c0/inst/u_ddr4_mem_intfc/u_ddr_cal_top/calDone_gated_reg/C] -to [get_pins xlnx_proc_sys_reset_0/U0/EXT_LPF/lpf_int_reg/D] 10.000


set_output_delay -clock [get_clocks mmcm_clkout1] -min -add_delay 0.000 [get_ports c0_ddr4_reset_n]
set_output_delay -clock [get_clocks mmcm_clkout1] -max -add_delay 20.000 [get_ports c0_ddr4_reset_n]



set_max_delay -from [get_pins {xlnx_ddr4_c0/inst/u_ddr4_mem_intfc/u_ddr_cal_top/cal_RESET_n_reg[0]/C}] -to [get_ports c0_ddr4_reset_n] 50.000


