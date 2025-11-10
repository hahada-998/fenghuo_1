onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/i_clk
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/i_scl
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/io_sda
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_sda_en
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_glitchlessSignal_scl_q
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_glitchlessSignal_sda_q
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_scl_in
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_sda_in
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_scl_0
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_sda_0
add wave -noupdate -color Magenta /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_sda_neg
add wave -noupdate -color Magenta /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_start
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_stop
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_scl_pos
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_scl_neg
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_I2C_state
add wave -noupdate -expand /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_r1_sda_dly
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_r1_sda_dly
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_I2c_address
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/o_I2C_ADDR_OUT
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/i_addr_hit
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_sda_data
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/o_data_vld
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/o_data_out
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_I2C_RW
add wave -noupdate /tb_bmc_cpld_i2c_ram/io_sda
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/i_data_in
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/o_i2c_command
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/r_i2c_command
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/w_R_W
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/r_read_byte_cnt
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i_rst_n
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/r_write_byte_cnt
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/w_i2c_command
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3537007 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 177
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {13650 ns}
