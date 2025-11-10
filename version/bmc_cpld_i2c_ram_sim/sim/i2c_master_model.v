`timescale 1ns/1ps

module tb_bmc_cpld_i2c_ram;

    // Parameters
    parameter DLY_LEN = 3;

    // Testbench signals
    reg i_rst_n;
    reg i_clk;
    reg i_1ms_clk;
    reg i_rst_i2c_n;
    reg i_scl;
    reg io_sda;
    
    // CPLD Common Register inputs
    reg [7:0] i_product_id;
    reg [7:0] i_vender_id;
    reg [7:0] i_board_id;
    reg [7:0] i_pcb_version;
    reg [7:0] i_bom_id;
    reg [7:0] i_cpld_version;
    reg [7:0] i_year;
    reg [7:0] i_month;
    reg [7:0] i_day;
    reg [7:0] i_nc_pin;
    reg [7:0] i_cpld_compa_version;
    reg [7:0] i_cpld_debug_version;
    reg i_PS1_PRSNT;
    reg i_PS2_PRSNT;
    reg i_PS3_PRSNT;
    reg i_PS4_PRSNT;
    reg i_PS1_ACFAIL;
    reg i_PS2_ACFAIL;
    reg i_PS1_DCOK;
    reg i_PS2_DCOK;
    reg i_PS1_ALERT;
    reg i_PS2_ALERT;
    reg i_PS1_P12V_ON;
    reg i_PS2_P12V_ON;
    reg i_PS_OFF;
    reg i_DUAL_EN;
    reg i_P12V_DROOP;
    reg i_P12V_STBY_DROOP;
    reg i_P12V_DISCHARGE;
    
    // Outputs
    wire [7:0] o_test_reg;
    wire o_BMC_JTAG_MUX_S;
    wire o_bmc_clr_tmout_n;
    wire o_pal_cpu0_forcepr_r;
    wire o_pal_cpu1_forcepr_r;
    wire o_clear_register;
    wire o_bmc_clr_sbtn_n;
    wire o_bmc_clr_lbtn_n;
    wire o_bmc_clr_sbtn_sys_n;
    wire o_pwr_btn_lock;
    wire o_bmc_power_soft_ctl;
    wire o_bmc_lbtn_pwrdown_ctl;
    wire o_bmc_sbtn_pwron_ctl;
    wire o_bmc_sbtn_sysrst_ctl;
    wire o_aux_pcycle;
    wire o_usb_sw_s;
    wire o_p0_vpp_9545_4_rst_n;
    wire o_p0_vpp_9545_5_rst_n;
    wire o_p0_vpp_9545_6_rst_n;
    wire o_bmc_i2c5_9548_rst_n;
    wire o_bmc_i2c4_9548_1_rst_n;
    wire o_bmc_i2c4_9548_2_rst_n;
    wire o_bmc_i2c4_9548_3_rst_n;

    // Instantiate the DUT
    bmc_cpld_i2c_ram #(
        .DLY_LEN(DLY_LEN)
    ) dut (
        .i_rst_n(i_rst_n),
        .i_clk(i_clk),
        .i_1ms_clk(i_1ms_clk),
        .i_rst_i2c_n(i_rst_i2c_n),
        .i_scl(i_scl),
        .io_sda(io_sda),
        .i_product_id(i_product_id),
        .i_vender_id(i_vender_id),
        .i_board_id(i_board_id),
        .i_pcb_version(i_pcb_version),
        .i_bom_id(i_bom_id),
        .i_cpld_version(i_cpld_version),
        .o_test_reg(o_test_reg),
        .i_year(i_year),
        .i_month(i_month),
        .i_day(i_day),
        .i_nc_pin(i_nc_pin),
        .i_cpld_compa_version(i_cpld_compa_version),
        .i_cpld_debug_version(i_cpld_debug_version),
        .i_PS1_PRSNT(i_PS1_PRSNT),
        .i_PS2_PRSNT(i_PS2_PRSNT),
        .i_PS3_PRSNT(i_PS3_PRSNT),
        .i_PS4_PRSNT(i_PS4_PRSNT),
        .i_PS1_ACFAIL(i_PS1_ACFAIL),
        .i_PS2_ACFAIL(i_PS2_ACFAIL),
        .i_PS1_DCOK(i_PS1_DCOK),
        .i_PS2_DCOK(i_PS2_DCOK),
        .i_PS1_ALERT(i_PS1_ALERT),
        .i_PS2_ALERT(i_PS2_ALERT),
        .i_PS1_P12V_ON(i_PS1_P12V_ON),
        .i_PS2_P12V_ON(i_PS2_P12V_ON),
        .i_PS_OFF(i_PS_OFF),
        .i_DUAL_EN(i_DUAL_EN),
        .i_P12V_DROOP(i_P12V_DROOP),
        .i_P12V_STBY_DROOP(i_P12V_STBY_DROOP),
        .i_P12V_DISCHARGE(i_P12V_DISCHARGE),
        .o_BMC_JTAG_MUX_S(o_BMC_JTAG_MUX_S),
        .o_bmc_clr_tmout_n(o_bmc_clr_tmout_n),
        .o_pal_cpu0_forcepr_r(o_pal_cpu0_forcepr_r),
        .o_pal_cpu1_forcepr_r(o_pal_cpu1_forcepr_r),
        .o_clear_register(o_clear_register),
        .o_bmc_clr_sbtn_n(o_bmc_clr_sbtn_n),
        .o_bmc_clr_lbtn_n(o_bmc_clr_lbtn_n),
        .o_bmc_clr_sbtn_sys_n(o_bmc_clr_sbtn_sys_n),
        .o_pwr_btn_lock(o_pwr_btn_lock),
        .o_bmc_power_soft_ctl(o_bmc_power_soft_ctl),
        .o_bmc_lbtn_pwrdown_ctl(o_bmc_lbtn_pwrdown_ctl),
        .o_bmc_sbtn_pwron_ctl(o_bmc_sbtn_pwron_ctl),
        .o_bmc_sbtn_sysrst_ctl(o_bmc_sbtn_sysrst_ctl),
        .o_aux_pcycle(o_aux_pcycle),
        .o_usb_sw_s(o_usb_sw_s),
        .o_p0_vpp_9545_4_rst_n(o_p0_vpp_9545_4_rst_n),
        .o_p0_vpp_9545_5_rst_n(o_p0_vpp_9545_5_rst_n),
        .o_p0_vpp_9545_6_rst_n(o_p0_vpp_9545_6_rst_n),
        .o_bmc_i2c5_9548_rst_n(o_bmc_i2c5_9548_rst_n),
        .o_bmc_i2c4_9548_1_rst_n(o_bmc_i2c4_9548_1_rst_n),
        .o_bmc_i2c4_9548_2_rst_n(o_bmc_i2c4_9548_2_rst_n),
        .o_bmc_i2c4_9548_3_rst_n(o_bmc_i2c4_9548_3_rst_n)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 100MHz clock
    end

    // 1ms clock generation
    initial begin
        i_1ms_clk = 0;
        forever #1000 i_1ms_clk = ~i_1ms_clk; // 1ms clock
    end

    // I2C signals
    initial begin
        i_rst_n = 0;
        i_scl = 1;
        io_sda = 1; // SDA is high when idle
        #20;
        i_rst_n = 1; // Release reset
        #20;

        // Initialize inputs
        i_product_id = 8'h01;
        i_vender_id = 8'h02;
        i_board_id = 8'h03;
        i_pcb_version = 8'h04;
        i_bom_id = 8'h05;
        i_cpld_version = 8'h06;
        i_year = 8'h21;
        i_month = 8'h09;
        i_day = 8'h30;
        i_nc_pin = 8'h00;
        i_cpld_compa_version = 8'h01;
        i_cpld_debug_version = 8'h01;
        i_PS1_PRSNT = 1;
        i_PS2_PRSNT = 1;
        i_PS3_PRSNT = 0;
        i_PS4_PRSNT = 0;
        i_PS1_ACFAIL = 0;
        i_PS2_ACFAIL = 0;
        i_PS1_DCOK = 1;
        i_PS2_DCOK = 1;
        i_PS1_ALERT = 0;
        i_PS2_ALERT = 0;
        i_PS1_P12V_ON = 1;
        i_PS2_P12V_ON = 1;
        i_PS_OFF = 0;
        i_DUAL_EN = 1;
        i_P12V_DROOP = 0;
        i_P12V_STBY_DROOP = 0;
        i_P12V_DISCHARGE = 0;

        // Simulate I2C read operation
        #20;
        i_scl = 0; // Start condition
        #20;
        io_sda = 0; // SDA goes low
        #20;
        i_scl = 1; // SCL goes high
        #20;
        io_sda = 1; // SDA goes high (ACK)
        #20;
        i_scl = 0; // SCL goes low
        #20;

        // Read the test register
        i_scl = 1; // SCL goes high
        #20;
        // Here you would read the data from the register
        // For example, you can check the output o_test_reg
        #20;
        i_scl = 0; // SCL goes low
        #20;

        // End simulation
        $finish;
    end

endmodule