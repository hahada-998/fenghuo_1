`timescale 1ns/1ps

module tb_bmc_cpld_i2c_ram;

    // Parameters
    parameter DLY_LEN = 3;

    // Testbench signals
    logic i_rst_n;
    logic i_clk;
    logic i_1ms_clk;
    logic i_rst_i2c_n;
    logic i_scl;
    wire  io_sda;
    logic io_sda_driver;
    
    // CPLD Common Register inputs
    logic [7:0] i_product_id;
    logic [7:0] i_vender_id;
    logic [7:0] i_board_id;
    logic [7:0] i_pcb_version;
    logic [7:0] i_bom_id;
    logic [7:0] i_cpld_version;
    logic [7:0] i_year;
    logic [7:0] i_month;
    logic [7:0] i_day;
    logic [7:0] i_nc_pin;
    logic [7:0] i_cpld_compa_version;
    logic [7:0] i_cpld_debug_version;
    logic i_PS1_PRSNT;
    logic i_PS2_PRSNT;
    logic i_PS3_PRSNT;
    logic i_PS4_PRSNT;
    logic i_PS1_ACFAIL;
    logic i_PS2_ACFAIL;
    logic i_PS1_DCOK;
    logic i_PS2_DCOK;
    logic i_PS1_ALERT;
    logic i_PS2_ALERT;
    logic i_PS1_P12V_ON;
    logic i_PS2_P12V_ON;
    logic i_PS_OFF;
    logic i_DUAL_EN;
    logic i_P12V_DROOP;
    logic i_P12V_STBY_DROOP;
    logic i_P12V_DISCHARGE;
    
    // Outputs
    logic [7:0] o_test_reg;
    logic o_BMC_JTAG_MUX_S;
    logic o_bmc_clr_tmout_n;
    logic o_pal_cpu0_forcepr_r;
    logic o_pal_cpu1_forcepr_r;
    logic o_clear_register;
    logic o_bmc_clr_sbtn_n;
    logic o_bmc_clr_lbtn_n;
    logic o_bmc_clr_sbtn_sys_n;
    logic o_pwr_btn_lock;
    logic o_bmc_power_soft_ctl;
    logic o_bmc_lbtn_pwrdown_ctl;
    logic o_bmc_sbtn_pwron_ctl;
    logic o_bmc_sbtn_sysrst_ctl;
    logic o_aux_pcycle;
    logic o_usb_sw_s;
    logic o_p0_vpp_9545_4_rst_n;
    logic o_p0_vpp_9545_5_rst_n;
    logic o_p0_vpp_9545_6_rst_n;
    logic o_bmc_i2c5_9548_rst_n;
    logic o_bmc_i2c4_9548_1_rst_n;
    logic o_bmc_i2c4_9548_2_rst_n;
    logic o_bmc_i2c4_9548_3_rst_n;

    assign io_sda = (io_sda_driver === 1'bz) ? 1'bz : io_sda_driver;

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
        .o_usb_sw_s(o_usb_sw_s)
        // .o_p0_vpp_9545_4_rst_n(o_p0_vpp_9545_4_rst_n),
        // .o_p0_vpp_9545_5_rst_n(o_p0_vpp_9545_5_rst_n),
        // .o_p0_vpp_9545_6_rst_n(o_p0_vpp_9545_6_rst_n),
        // .o_bmc_i2c5_9548_rst_n(o_bmc_i2c5_9548_rst_n),
        // .o_bmc_i2c4_9548_1_rst_n(o_bmc_i2c4_9548_1_rst_n),
        // .o_bmc_i2c4_9548_2_rst_n(o_bmc_i2c4_9548_2_rst_n),
        // .o_bmc_i2c4_9548_3_rst_n(o_bmc_i2c4_9548_3_rst_n)
    );

    // 系统时钟25Mhz
    initial begin
        i_clk = 0;
        forever #2 i_clk = ~i_clk; // 250MHz clock
    end

    initial begin
        // 初始化控制信号
        i_rst_n = 0;
        i_rst_i2c_n = 0;
        // 等待一段时间，释放复位
        #20;
        i_rst_n = 1;
        i_rst_i2c_n = 1;
    end 

    // I2C_slave 超时复位使用, 模拟35ms超时后对输入的数据进行复位
    logic   [9:0]           i_1ms_cnt    ; // 2周期, 8ns

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) 
            i_1ms_cnt <= 10'd0;
        else if (i_1ms_cnt == 10'd999) 
            i_1ms_cnt <= 10'd0;
        else 
            i_1ms_cnt <= i_1ms_cnt + 1'b1;
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) 
            i_1ms_clk <= 1'd0;
        else if (i_1ms_cnt == 10'd999) 
            i_1ms_clk <= 1'd1;
        else 
            i_1ms_clk <= 1'd0;
    end

    // 初始化I2C寄存器信息, 后续可以根据外界模块使能信息
    initial begin
        // 等待复位释放
        #20;
        /*CPLD Common Register*/
        // 0x0000 - 0x000C
        i_product_id         = 8'h01;
        i_vender_id          = 8'h02;
        i_board_id           = 8'h03;
        i_pcb_version        = 8'h04;
        i_bom_id             = 8'h05;
        i_cpld_version       = 8'h06;
        i_year               = 8'h21;
        i_month              = 8'h09;
        i_day                = 8'h30;
        i_nc_pin             = 8'h00;
        i_cpld_compa_version = 8'h01;
        i_cpld_debug_version = 8'h01;

        //PSU--0x000D
        i_PS1_PRSNT = 1;
        i_PS2_PRSNT = 1;
        i_PS3_PRSNT = 0;
        i_PS4_PRSNT = 0;
        i_PS1_ACFAIL = 0;
        i_PS2_ACFAIL = 0;
        i_PS1_DCOK = 1;
        i_PS2_DCOK = 1;

        //PSU--0x000E
        i_PS1_ALERT = 0;
        i_PS2_ALERT = 0;
        i_PS1_P12V_ON = 1;
        i_PS2_P12V_ON = 1;
        i_PS_OFF = 0;
        i_DUAL_EN = 1;
        i_P12V_DROOP = 0;
        i_P12V_STBY_DROOP = 0;

        //P12V --0x000F
        i_P12V_DISCHARGE = 0;

        /*
        ...添加后续寄存器信息
        */
    end

    // 模拟输入的i2c读写操作, 模拟连续读取0x0000~0x0002寄存器的值
    initial begin
        i_scl         = 1;
        io_sda_driver = 1; // SDA 空闲状态为高电平
        #400;

        // 开始对I2C从设备进行写操作
        i_scl  = 1; 
        io_sda_driver = 1; 
        #200;
        io_sda_driver = 0; 
        #200;
        i_scl  = 0;
        send_byte(8'h20);

        // 2. 主机发送寄存器写地址(假设要读取的寄存器地址为0x00)
        send_byte(8'h10);
        send_byte(8'h51);
        send_byte(8'h52);

        // 3. 读取从设备寄存器数据
        // read_byte(); // 读取第一个字节
        # 1600; // 等待一段时间以确保数据被正确读取
        // 4. 发送停止信号
        i_scl = 0;
        io_sda_driver = 0;
        #200;
        i_scl = 1;
        #200;
        io_sda_driver = 1; // SDA 拉高表示停止信号
        #1000;


        /*
        // 等待一段时间后，进行下一次读操作
        #1000;
        i_scl         = 1;
        io_sda_driver = 1; // SDA 空闲状态为高电平
        #400;

        // 开始对I2C从设备进行读操作
        i_scl  = 1; 
        io_sda_driver = 1; 
        #200;
        io_sda_driver = 0; 
        #200;
        i_scl  = 0;
        send_byte(8'h21);

        // 2. 主机发送寄存器读地址(假设要读取的寄存器地址为0x00)
        send_byte(8'h02);

        // 3. 读取从设备寄存器数据
        read_byte(); // 读取第一个字节

        // 4. 发送停止信号
        i_scl = 0;
        io_sda_driver = 0;
        #200;
        i_scl = 1;
        #200;
        io_sda_driver = 1; // SDA 拉高表示停止信号
        #1000;
        */

        /*
        send_byte(8'h02);

        read_byte(); // 读取第二个字节

        send_byte(8'h03);

        read_byte(); // 读取第三个字节

        // 4. 发送停止信号
        i_scl = 0;
        io_sda_driver = 0;
        #20;
        i_scl = 1;
        #20;
        io_sda_driver = 1; // SDA 拉高表示停止信号
        #20;
        */

        // 结束仿真
        $finish;
    end

    // 任务：发送一个字节数据
    task send_byte(input [7:0] data);
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                i_scl  = 0       ; // SCL 拉低
                io_sda_driver = data[i]; // 发送数据位
                #200              ;
                i_scl  = 1       ; // SCL 拉高
                #200;
            end
            // 接收 ACK
            i_scl = 0 ;
            io_sda_driver = 1'bz; // 释放 SDA
            #200;
            i_scl = 1 ; // SCL 拉高
            #200;
            i_scl = 0 ; // SCL 拉低
        end
    endtask

    // 任务：读取一个字节数据
    task read_byte();
        integer i;
        reg [7:0] data;
        begin
            data = 8'h00;
            for (i = 7; i >= 0; i = i - 1) begin
                i_scl = 0; // SCL 拉低
                io_sda_driver = 1'bz; // 释放 SDA
                #200;
                i_scl = 1; // SCL 拉高
                data[i] = io_sda; // 读取数据位
                #200;
            end
            // 发送 ACK
            i_scl = 0;
            io_sda_driver = 0; // 发送 ACK
            #200;
            i_scl = 1; // SCL 拉高
            #200;
            i_scl = 0; // SCL 拉低
        end
    endtask
endmodule