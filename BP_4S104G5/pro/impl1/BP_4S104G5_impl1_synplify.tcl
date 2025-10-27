#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology MACHXO3LF
set_option -part LCMXO3LF_6900C
set_option -package BG400C
set_option -speed_grade -5

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency 100
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -seqshift_no_replicate 0

#-- add_file options
set_option -include_path {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/include}
set_option -include_path {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/pro}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/BP_4S104G5_TOP.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/PLL/pll_i25M_o50M_o25M.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/I2C_UPDATE/I2C_UPDATE.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/bmc_i2c/bmc_cpld_i2c_ram.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/bmc_i2c/i2c_slave_basic0.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/bmc_i2c/i2c_slave_bmc.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/SGPIO_SLAVE/p2s_slave.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/SGPIO_SLAVE/s2p_slave.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/common/edge_delay.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/common/lowpass_filter.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/common/pon_reset.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/common/synclib.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/common/timer_gen_50mhz.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/74LV165/pvt_gpi.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/FAN/fan_pwm_tach.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/FAN/fan_counter.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/common/Edge_Detect.v}
add_file -verilog -vlog_std v2001 {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/rtl/source/breath_led/breath_led.v}

#-- top module name
set_option -top_module BP_4S104G5

#-- set result format/file last
project -result_file {D:/Project/CNIT-K/8U SW/code/V10/4port/BP_4S104G5/pro/impl1/BP_4S104G5_impl1.edi}

#-- error message log file
project -log_file {BP_4S104G5_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
