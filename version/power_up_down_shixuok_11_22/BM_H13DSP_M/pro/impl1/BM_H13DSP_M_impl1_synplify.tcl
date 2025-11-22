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
set_option -include_path {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/include}
set_option -include_path {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/pro}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/BM_H13DSP_M_TOP.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/PLL/pll_i25M_o50M_o25M.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/IIC_Update/I2C_UPDATE.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/74LV165/pvt_gpi.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/bmc_i2c/bmc_cpld_i2c_ram.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/bmc_i2c/i2c_slave_basic0.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/bmc_i2c/i2c_slave_bmc.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/ESPI_LINK/espi_link.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/ESPI_LINK/pch_cpld_espi_ram.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/ESPI_LINK/pcie_dync_alloc.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/SGPIO_MASTER/s2p_master.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/SGPIO_MASTER/p2s_slave.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/ClkDiv.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/delay.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/ClkDivTree.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/edge_delay.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/edge_detect.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/lowpass_filter.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/pon_reset.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/synclib.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/timer_gen_50mhz.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/system_rst.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Signal_Latch/Edge_Detect_SL.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Signal_Latch/Signal_Latch.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/uart/mcio_uart_master.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Pwr_But_Ctrl/bmc_ctl_pwrbtn.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Pwr_But_Ctrl/Pwr_But_Ctrl.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/bios_i2c/bios_cpld_i2c_ram.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/nmi_clear.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/cpu_module.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/cpu_thermtrip.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Pwr_seq/pwrseq_master.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Pwr_seq/pwrseq_slave.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/cmos_clear.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/extrst_evt_count.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/genCntr.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/MESSAGE_CONTROL.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Power_Fault/dimm_fail_event.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Power_Fault/ERROR_CODE.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Power_Fault/fault_detectA_chklive.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Power_Fault/fault_detectB_chklive.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Power_Fault/Power_Fault.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/Power_Fault/Pwr_Error_Latch.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/74HC164/s2p_164.v}
add_file -verilog -vlog_std v2001 {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/rtl/source/common/power_button.v}

#-- top module name
set_option -top_module BM_H13DSP_M

#-- set result format/file last
project -result_file {D:/FH_MB_powerup_1106_shixu_ok_exit_fault_change_right_addcpuprsnt_ok_add_pull_down_add_pwrbmc_ctrl/MB/09/BM_H13DSP_M/pro/impl1/BM_H13DSP_M_impl1.edi}

#-- error message log file
project -log_file {BM_H13DSP_M_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run -clean
