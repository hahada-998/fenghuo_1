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
set_option -include_path {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/include}
set_option -include_path {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/pro}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/BM_H13DSP_S_TOP.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/ClkDiv.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/ClkDivTree.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/delay.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/edge_delay.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/edge_detect.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/lowpass_filter.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/pon_reset.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/synclib.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/UID_Function.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/common/timer_gen_50mhz.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/74LV165/pvt_gpi.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/bmc_i2c/bmc_cpld_i2c_ram.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/bmc_i2c/i2c_slave_basic0.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/bmc_i2c/i2c_slave_bmc.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/uart/aux_uart_master.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/uart/mcio_uart_master.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/IIC_Update/I2C_UPDATE.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/PLL/pll_i25M_o50M_o25M.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/SGPIO_SLAVE/s2p_slave.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/SGPIO_SLAVE/p2s_slave.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/rtl/source/74HC164/s2p_164.v}

#-- top module name
set_option -top_module BM_H13DSP_S

#-- set result format/file last
project -result_file {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_S/pro/impl1/BM_H13DSP_S_impl1.edi}

#-- error message log file
project -log_file {BM_H13DSP_S_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run -clean
