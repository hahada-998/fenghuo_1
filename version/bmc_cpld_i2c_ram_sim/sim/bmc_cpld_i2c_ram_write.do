onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/i_clk
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/i_scl
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/io_sda
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_sda_en
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_scl_0
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_I2C_state
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_sda_0
add wave -noupdate -color Orange /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i_i2c_address
add wave -noupdate -color Orange /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/o_I2C_ADDR_OUT
add wave -noupdate -color Orange /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/i_addr_hit
add wave -noupdate -color Magenta /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_start
add wave -noupdate -color Cyan /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_stop
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_scl_pos
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_scl_neg
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_I2C_state
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/r_r1_sda_dly
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/i2c_slave_basic0_u0/w_r1_sda_dly
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/r_i2c_command_temp
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/r_write_byte_cnt
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/w_data_vld_pos
add wave -noupdate -color Magenta /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/w_i2c_command
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/r_reg_1051
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/w_WR
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/w_data_vld_pos
add wave -noupdate /tb_bmc_cpld_i2c_ram/dut/i2c_slave_bmc_u0/o_i2c_data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 6} {3622000 ps} 1} {{Cursor 7} {11620745 ps} 1}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ps} {15330 ns}
