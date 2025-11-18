`timescale 1ns/1ps

module tb_Pwr_But_Ctrl;

    // Parameters
    parameter PWRBTN_LONG = 4; // 长按键判断阈值（4个20ms时钟周期）

    // Inputs
    reg i_clk;
    reg i_rst_n;
    reg i_20mSEC;
    reg i_PWRBTN_OUT_disable;
    reg i_disable_button;
    reg i_BMC_active0_n;
    reg i_FP_PWR_BTN_MUX_N;
    reg i_FM_BMC_PWRBTN_OUT_CPLD_N;
    reg i_DBP_POWER_BTN_N;
    reg i_state_s0;
    reg i_state_s5;
    reg i_bmc_clear_data;
    reg i_BMC_active1_n;

    // Outputs
    wire o_pwrbtn_short;
    wire o_pwrbtn_long;
    wire o_PWRBTN_state;
    wire [1:0] o_pwr_btn_state;
    wire o_pwr_btn_dly;
    wire o_FM_BMC_PWRBTN_OUT_B_N;

    // Instantiate the Unit Under Test (UUT)
    Pwr_But_Ctrl #(
        .PWRBTN_LONG(PWRBTN_LONG)
    ) uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_20mSEC(i_20mSEC),
        .i_PWRBTN_OUT_disable(i_PWRBTN_OUT_disable),
        .i_disable_button(i_disable_button),
        .i_BMC_active0_n(i_BMC_active0_n),
        .i_FP_PWR_BTN_MUX_N(i_FP_PWR_BTN_MUX_N),
        .i_FM_BMC_PWRBTN_OUT_CPLD_N(i_FM_BMC_PWRBTN_OUT_CPLD_N),
        .i_DBP_POWER_BTN_N(i_DBP_POWER_BTN_N),
        .i_state_s0(i_state_s0),
        .i_state_s5(i_state_s5),
        .i_bmc_clear_data(i_bmc_clear_data),
        .i_BMC_active1_n(i_BMC_active1_n),
        .o_pwrbtn_short(o_pwrbtn_short),
        .o_pwrbtn_long(o_pwrbtn_long),
        .o_PWRBTN_state(o_PWRBTN_state),
        .o_pwr_btn_state(o_pwr_btn_state),
        .o_pwr_btn_dly(o_pwr_btn_dly),
        .o_FM_BMC_PWRBTN_OUT_B_N(o_FM_BMC_PWRBTN_OUT_B_N)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #10 i_clk = ~i_clk; // 50MHz clock
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_20mSEC = 0;
        i_PWRBTN_OUT_disable = 0;
        i_disable_button = 0;
        i_BMC_active0_n = 1;
        i_FP_PWR_BTN_MUX_N = 1;
        i_FM_BMC_PWRBTN_OUT_CPLD_N = 1;
        i_DBP_POWER_BTN_N = 1;
        i_state_s0 = 0;
        i_state_s5 = 1;
        i_bmc_clear_data = 1;
        i_BMC_active1_n = 1;

        // Reset the module
        #50;
        i_rst_n = 1;

        // Simulate a short press
        #50;
        i_FP_PWR_BTN_MUX_N = 0; // Press the button
        #1000; // Hold for 40ms
        i_FP_PWR_BTN_MUX_N = 1; // Release the button

        /*
        // Simulate a long press
        #200;
        i_FP_PWR_BTN_MUX_N = 0; // Press the button
        #160; // Hold for 160ms
        i_FP_PWR_BTN_MUX_N = 1; // Release the button

        // Simulate button disable
        #200;
        i_disable_button = 1;
        i_FP_PWR_BTN_MUX_N = 0; // Press the button
        #40;
        i_FP_PWR_BTN_MUX_N = 1; // Release the button
        i_disable_button = 0;

        // Simulate BMC active scenario
        #200;
        i_BMC_active0_n = 0; // BMC active
        i_FP_PWR_BTN_MUX_N = 0; // Press the button
        #40;
        i_FP_PWR_BTN_MUX_N = 1; // Release the button
     */
        // End simulation
        #500;
        $finish;
    end
   

    // Generate 20ms clock enable
    initial begin
        i_20mSEC = 0;
        forever begin
          #60; // 20ms period
            i_20mSEC = ~i_20mSEC;
        end
    end

endmodule