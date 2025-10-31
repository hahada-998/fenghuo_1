onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pwrseq_tb/clk_50m
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/reset
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/state_ns
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/power_seq_sm_fb
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwrup_state_trans_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/grp_a_pwrok_timeout
add wave -noupdate -radix unsigned /pwrseq_tb/pwrseq_master_inst/wdt_counter
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/off_state
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/st_ps_on
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/psu_on_tick
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/sequence_tick
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/pwron_critical_fail_en
add wave -noupdate /pwrseq_tb/pwrseq_master_inst/keep_alive_on_fault
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5992641 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 334
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {20686595 ps}
