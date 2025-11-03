onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pwrseq_tb/clk_50m
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/reset
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state_ns
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/power_seq_sm_fb
add wave -noupdate -divider SM_EN_GRP_A_01
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_a_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_a_pwrok_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_master_inst/any_pwr_fault_det
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_lim_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_non_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/LIM_RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/NON_RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_lim_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_non_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_master_inst/any_pwr_fault_det
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_lim_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_non_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/LIM_RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/NON_RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_lim_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_non_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_master_inst/any_pwr_fault_det
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_lim_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_non_recov_fault_c
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/LIM_RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/NON_RECOV_FAULT_MASK
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_lim_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/any_non_recov_fault_vec
add wave -noupdate -group any_pwr_fault_det /pwrseq_tb/pwrseq_slave_inst/fault_vec
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_RSMRST_DISABLE_02
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate -color Magenta /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -radix unsigned -childformat {{{/pwrseq_tb/pwrseq_master_inst/wdt_counter[9]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[8]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[7]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[6]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[5]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[4]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[3]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[2]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[1]} -radix unsigned} {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[0]} -radix unsigned}} -subitemconfig {{/pwrseq_tb/pwrseq_master_inst/wdt_counter[9]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[8]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[7]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[6]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[5]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[4]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[3]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[2]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[1]} {-radix unsigned} {/pwrseq_tb/pwrseq_master_inst/wdt_counter[0]} {-radix unsigned}} /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_EN_GRP_B_33_S5_03
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_b_critical_fail_en
add wave -noupdate -color Magenta /pwrseq_tb/pwrseq_master_inst/grp_b_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_b_pwrok_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_tick
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_EN_GRP_B_18_S5_04
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_b_critical_fail_en
add wave -noupdate -color Magenta /pwrseq_tb/pwrseq_master_inst/grp_b_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_b_pwrok_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_tick
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_EN_P5V_STBY_05
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_b_critical_fail_en
add wave -noupdate -color Magenta /pwrseq_tb/pwrseq_master_inst/grp_b_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_b_pwrok_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_tick
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_EN_RSMRST_RELEASE_06
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/rsmrst_release_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/rsmrst_release_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/rsmrst_release_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_OFF_STANDBY_08
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/any_pwr_fault_det
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/s5dev_pwrdis_request
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/s5dev_pwren_request
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/s5_devices_on_wait_complete
add wave -noupdate -group next_state_09 /pwrseq_tb/pwrseq_master_inst/turn_system_on
add wave -noupdate -group next_state_09 /pwrseq_tb/pwrseq_master_inst/dc_on_wait_complete
add wave -noupdate -group next_state_09 /pwrseq_tb/pwrseq_master_inst/fault_power
add wave -noupdate -group next_state_09 /pwrseq_tb/pwrseq_master_inst/xr_ps_en
add wave -noupdate -group next_state_09 /pwrseq_tb/pwrseq_master_inst/pch_slp4_n
add wave -noupdate -group next_state_09 /pwrseq_tb/pwrseq_master_inst/interlock_broken
add wave -noupdate -group next_state_09 /pwrseq_tb/pwrseq_master_inst/aux_video_holdoff
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_PS_ON_09
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/psu_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/psu_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_tick
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_EN_TELEM_10
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_EN_MAIN_EFUSE_11
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/efuse_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/efuse_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -divider SM_EN_GRP_ATX_12
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -divider SM_EN_GRP_C_13
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -divider SE_EN_GRP_D_VDDIO_14
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -divider SE_EN_GPR_D_SOC_15
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -divider SM_EN_GRP_D_VDDCORE0_16
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -divider SM_EN_GRP_D_VDDCORE1_17
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_EN_PGOOD_RELEASE_18
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pon_watchdog_timeout
add wave -noupdate -divider SM_WAIT_POWEROK_19
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/wait_steady_pwrok_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgd_so_far
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_STEADY_PWROK_20
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/rt_critical_fail_store
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pgood_rst_mask
add wave -noupdate -color Magenta /pwrseq_tb/pwrseq_master_inst/rt_thermtrip_pwr_down
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_CRITICAL_FAIL_34
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_PWRGD_21
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/dispg_watchdog_timeout
add wave -noupdate -divider SM_DISABLE_GRP_D_VDDCORE1_22
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_GRP_D_VDDCORE0_23
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_GRP_D_SOC_24
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_GRP_D_VDDIO_25
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_GRP_C_26
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_GRP_ATX_27
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_MAIN_EFUSE_28
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_TELEM_29
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate -divider SM_DISABLE_PS_ON_30
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pdn_watchdog_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate -color Cyan /pwrseq_tb/pwrseq_master_inst/wdt_counter_clr
add wave -noupdate -radix hexadecimal /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/any_pwr_fault_det
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/keep_alive_on_fault
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/cpu_thermtrip_fault_det
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {122896624 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 222
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {122874524 ps} {122935998 ps}
