`timescale 1ns/1ps
// BP_4S104G5_S - I2C slave register file (aligned to BP_4S104G5_S_TOP instance)
// 替换/对齐了端口名与寄存器地址（参考 top 实例化处的注释与信号）

module bmc_cpld_i2c_ram #(
    parameter DLY_LEN = 16
)(
    input  wire        i_rst_n,
    input  wire        i_clk,            // clk_25m from top
    input  wire        i_1ms_clk,
    input  wire        i_rst_i2c_n,
    input  wire        i_scl,
    inout  wire        io_sda,

    // identification (mapped from top)
    input  wire [7:0]  i_product_id,           // addr 0x0000
    input  wire [7:0]  i_vender_id,            // addr 0x0001
    input  wire [7:0]  i_board_id,             // addr 0x0002
    input  wire [7:0]  i_pcb_version,          // addr 0x0003
    input  wire [7:0]  i_bom_id,               // addr 0x0004
    input  wire [7:0]  i_cpld_version,         // addr 0x0005
    output wire [7:0]  o_test_reg,             // addr 0x0006 (RW)
    input  wire [7:0]  i_year,                 // addr 0x0007
    input  wire [7:0]  i_month,                // addr 0x0008
    input  wire [7:0]  i_day,                  // addr 0x0009
    input  wire [7:0]  i_nc_pin,               // addr 0x000a
    input  wire [7:0]  i_cpld_compa_version,   // addr 0x000b
    input  wire [7:0]  i_cpld_debug_version,   // addr 0x000c

    // NIC / board specific fields (top passes constants)
    input  wire [7:0]  i_nic_board_id,         // addr 0x0010 (top used 8'b0)
    input  wire [7:0]  i_nic_pcb_version,      // addr 0x0011 (top used 8'b0)

    // SW alerts (mapped to 0x000d / 0x0012 area in top)
    input  wire        i_P0V8_SW1_ALERT_N,     // used in status bytes
    input  wire        i_P0V8_SW1_FAULT_N,

    output wire [7:0]  o_uid_led_ctl,          // addr 0x0013 (driven by I2C write)

    // NVMe / present groups (mapped to 0x0014..0x0018 in top)
    input  wire        i_MCIO01A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO01C_NVME0_PRSNT_R_N,
    input  wire        i_MCIO02A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO02C_NVME0_PRSNT_R_N,
    input  wire        i_MCIO11A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO11C_NVME0_PRSNT_R_N,
    input  wire        i_MCIO12A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO12C_NVME0_PRSNT_R_N,

    input  wire        i_MCIO21A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO21C_NVME0_PRSNT_R_N,
    input  wire        i_MCIO22A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO22C_NVME0_PRSNT_R_N,
    input  wire        i_MCIO31A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO31C_NVME0_PRSNT_R_N,
    input  wire        i_MCIO32A_NVME0_PRSNT_R_N,
    input  wire        i_MCIO32C_NVME0_PRSNT_R_N,

    input  wire        i_MCIO01A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO01C_NVME1_PRSNT_R_N,
    input  wire        i_MCIO02A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO02C_NVME1_PRSNT_R_N,
    input  wire        i_MCIO11A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO11C_NVME1_PRSNT_R_N,
    input  wire        i_MCIO12A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO12C_NVME1_PRSNT_R_N,

    input  wire        i_MCIO21A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO21C_NVME1_PRSNT_R_N,
    input  wire        i_MCIO22A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO22C_NVME1_PRSNT_R_N,
    input  wire        i_MCIO31A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO31C_NVME1_PRSNT_R_N,
    input  wire        i_MCIO32A_NVME1_PRSNT_R_N,
    input  wire        i_MCIO32C_NVME1_PRSNT_R_N,

    input  wire        i_NVME3_PRSNT0_R_N,
    input  wire        i_NVME3_PRSNT1_R_N,
    input  wire        i_NVME4_PRSNT0_R_N,
    input  wire        i_NVME4_PRSNT1_R_N,

    // GPU throttle controls (these are outputs controlled by I2C registers)
    output wire        o_mcio01_11_gpu_throttle_r_n, // mapped to reg @ 0x0019 bits
    output wire        o_mcio02_12_gpu_throttle_r_n,
    output wire        o_mcio21_31_gpu_throttle_r_n,
    output wire        o_mcio22_32_gpu_throttle_r_n,
    output wire        o_npu1_4_gpu_throttle_r_n,
    output wire        o_npu5_8_gpu_throttle_r_n,
    output wire        o_nic1_4_gpu_throttle_r_n,
    output wire        o_nic5_8_gpu_throttle_r_n,

    // MCIO pcie wake inputs (mapped to 0x0020..0x0021 area)
    input  wire        i_MCIO01A_PE_WAKE_R_N,
    input  wire        i_MCIO01C_PE_WAKE_R_N,
    input  wire        i_MCIO02A_PE_WAKE_R_N,
    input  wire        i_MCIO02C_PE_WAKE_R_N,
    input  wire        i_MCIO11A_PE_WAKE_R_N,
    input  wire        i_MCIO11C_PE_WAKE_R_N,
    input  wire        i_MCIO12A_PE_WAKE_R_N,
    input  wire        i_MCIO12C_PE_WAKE_R_N,
    input  wire        i_MCIO21A_PE_WAKE_R_N,
    input  wire        i_MCIO21C_PE_WAKE_R_N,
    input  wire        i_MCIO22A_PE_WAKE_R_N,
    input  wire        i_MCIO22C_PE_WAKE_R_N,
    input  wire        i_MCIO31A_PE_WAKE_R_N,
    input  wire        i_MCIO31C_PE_WAKE_R_N,
    input  wire        i_MCIO32A_PE_WAKE_R_N,
    input  wire        i_MCIO32C_PE_WAKE_R_N
);

// ----------------------------- internal i2c bus signals -----------------------
wire        w_i2c_start;
wire        w_WR;
wire        w_data_vld_pos;
wire [15:0] w_i2c_command;
wire [7:0]  w_i2c_data_out;
reg  [7:0]  r_i2c_data_in;

// ----------------------------- RO wires (compose multi-bit status) -----------
wire [7:0] w_ram_0000 = i_product_id;
wire [7:0] w_ram_0001 = i_vender_id;
wire [7:0] w_ram_0002 = i_board_id;
wire [7:0] w_ram_0003 = i_pcb_version;
wire [7:0] w_ram_0004 = i_bom_id;
wire [7:0] w_ram_0005 = i_cpld_version;
wire [7:0] w_ram_0007 = i_year;
wire [7:0] w_ram_0008 = i_month;
wire [7:0] w_ram_0009 = i_day;
wire [7:0] w_ram_000a = i_nc_pin;
wire [7:0] w_ram_000b = i_cpld_compa_version;
wire [7:0] w_ram_000c = i_cpld_debug_version;

// 0x000d: pack SW and fault bits (align with top usage)
wire [7:0] w_ram_000d = {
    i_P0V8_SW1_ALERT_N,   // bit7
    1'b0,                 //6
    1'b0,                 //5
    1'b0,                 //4
    i_P0V8_SW1_FAULT_N,   //3
    1'b0,                 //2
    1'b0,                 //1
    1'b0                  //0
};

// 0x0013 uid led control is RW (driven by I2C write)
wire [7:0] w_ram_0013 = r_reg_0013;

// 0x0014..0x0018 NVMe present packing (each address is assigned from inputs)
wire [7:0] w_ram_0014 = {
    i_MCIO01A_NVME0_PRSNT_R_N,
    i_MCIO01C_NVME0_PRSNT_R_N,
    i_MCIO02A_NVME0_PRSNT_R_N,
    i_MCIO02C_NVME0_PRSNT_R_N,
    i_MCIO11A_NVME0_PRSNT_R_N,
    i_MCIO11C_NVME0_PRSNT_R_N,
    i_MCIO12A_NVME0_PRSNT_R_N,
    i_MCIO12C_NVME0_PRSNT_R_N
};

wire [7:0] w_ram_0015 = {
    i_MCIO21A_NVME0_PRSNT_R_N,
    i_MCIO21C_NVME0_PRSNT_R_N,
    i_MCIO22A_NVME0_PRSNT_R_N,
    i_MCIO22C_NVME0_PRSNT_R_N,
    i_MCIO31A_NVME0_PRSNT_R_N,
    i_MCIO31C_NVME0_PRSNT_R_N,
    i_MCIO32A_NVME0_PRSNT_R_N,
    i_MCIO32C_NVME0_PRSNT_R_N
};

wire [7:0] w_ram_0016 = {
    i_MCIO01A_NVME1_PRSNT_R_N,
    i_MCIO01C_NVME1_PRSNT_R_N,
    i_MCIO02A_NVME1_PRSNT_R_N,
    i_MCIO02C_NVME1_PRSNT_R_N,
    i_MCIO11A_NVME1_PRSNT_R_N,
    i_MCIO11C_NVME1_PRSNT_R_N,
    i_MCIO12A_NVME1_PRSNT_R_N,
    i_MCIO12C_NVME1_PRSNT_R_N
};

wire [7:0] w_ram_0017 = {
    i_MCIO21A_NVME1_PRSNT_R_N,
    i_MCIO21C_NVME1_PRSNT_R_N,
    i_MCIO22A_NVME1_PRSNT_R_N,
    i_MCIO22C_NVME1_PRSNT_R_N,
    i_MCIO31A_NVME1_PRSNT_R_N,
    i_MCIO31C_NVME1_PRSNT_R_N,
    i_MCIO32A_NVME1_PRSNT_R_N,
    i_MCIO32C_NVME1_PRSNT_R_N
};

wire [7:0] w_ram_0018 = {
    i_NVME3_PRSNT0_R_N,
    i_NVME3_PRSNT1_R_N,
    i_NVME4_PRSNT0_R_N,
    i_NVME4_PRSNT1_R_N,
    4'b0
};

wire [7:0] w_ram_0020 = {
    i_MCIO01A_PE_WAKE_R_N,
    i_MCIO01C_PE_WAKE_R_N,
    i_MCIO02A_PE_WAKE_R_N,
    i_MCIO02C_PE_WAKE_R_N,
    i_MCIO11A_PE_WAKE_R_N,
    i_MCIO11C_PE_WAKE_R_N,
    i_MCIO12A_PE_WAKE_R_N,
    i_MCIO12C_PE_WAKE_R_N
};

wire [7:0] w_ram_0021 = {
    i_MCIO21A_PE_WAKE_R_N,
    i_MCIO21C_PE_WAKE_R_N,
    i_MCIO22A_PE_WAKE_R_N,
    i_MCIO22C_PE_WAKE_R_N,
    i_MCIO31A_PE_WAKE_R_N,
    i_MCIO31C_PE_WAKE_R_N,
    i_MCIO32A_PE_WAKE_R_N,
    i_MCIO32C_PE_WAKE_R_N
};
wire [7:0] w_ram_0024 = 8'h00; 
// ----------------------------- RW registers (aligned with top comments) ------
reg [7:0] r_reg_0006;   // test reg
reg [7:0] r_reg_0013;   // uid led ctl (0x0013)
reg [7:0] r_reg_0019;   // gpu throttle pack (0x0019)  bits map to o_mcio01_11.. etc
reg [7:0] r_reg_001A;   // 0x001A
reg [7:0] r_reg_001B;   // 0x001B
reg [7:0] r_reg_0023;   // reserved / dimm etc
reg [7:0] r_reg_0024;   // thermal alerts read-only composed below (kept as RO)
reg [7:0] r_reg_0072;   // BIOS/QSPI controls if used

// ----------------------------- Assign outputs from regs -----------------------
assign o_test_reg = r_reg_0006;
assign o_uid_led_ctl = r_reg_0013;

// GPU throttle outputs mapped from r_reg_0019..0x001B bits (active low signals in top use _r_n)
assign o_mcio01_11_gpu_throttle_r_n = r_reg_0019[7];
assign o_mcio02_12_gpu_throttle_r_n = r_reg_0019[6];
assign o_mcio21_31_gpu_throttle_r_n = r_reg_0019[5];
assign o_mcio22_32_gpu_throttle_r_n = r_reg_0019[4];

assign o_npu1_4_gpu_throttle_r_n = r_reg_001A[7];
assign o_npu5_8_gpu_throttle_r_n = r_reg_001A[6];

assign o_nic1_4_gpu_throttle_r_n = r_reg_001B[7];
assign o_nic5_8_gpu_throttle_r_n = r_reg_001B[6];

// BIOS/QSPI / other outputs (kept for compatibility)
assign o_sw_bios_flash_spi_s_r = r_reg_0072[7];
assign o_sw_bios_qspi_s_r      = r_reg_0072[6];
assign o_sw_bios_spi_oe        = r_reg_0072[5];
assign o_sw_qspi_oe_r          = r_reg_0072[4];
assign o_bios_flash_reset_r_n  = r_reg_0072[3];

// ----------------------------- Read logic ------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) r_i2c_data_in <= 8'h00;
    else begin
        case (w_i2c_command)
            16'h0000: r_i2c_data_in <= w_ram_0000;
            16'h0001: r_i2c_data_in <= w_ram_0001;
            16'h0002: r_i2c_data_in <= w_ram_0002;
            16'h0003: r_i2c_data_in <= w_ram_0003;
            16'h0004: r_i2c_data_in <= w_ram_0004;
            16'h0005: r_i2c_data_in <= w_ram_0005;
            16'h0006: r_i2c_data_in <= r_reg_0006;
            16'h0007: r_i2c_data_in <= w_ram_0007;
            16'h0008: r_i2c_data_in <= w_ram_0008;
            16'h0009: r_i2c_data_in <= w_ram_0009;
            16'h000a: r_i2c_data_in <= w_ram_000a;
            16'h000b: r_i2c_data_in <= w_ram_000b;
            16'h000c: r_i2c_data_in <= w_ram_000c;
            16'h000d: r_i2c_data_in <= w_ram_000d;
            16'h0010: r_i2c_data_in <= i_nic_board_id;
            16'h0011: r_i2c_data_in <= i_nic_pcb_version;
            16'h0012: r_i2c_data_in <= 8'h00; // reserved
            16'h0013: r_i2c_data_in <= r_reg_0013;
            16'h0014: r_i2c_data_in <= w_ram_0014;
            16'h0015: r_i2c_data_in <= w_ram_0015;
            16'h0016: r_i2c_data_in <= w_ram_0016;
            16'h0017: r_i2c_data_in <= w_ram_0017;
            16'h0018: r_i2c_data_in <= w_ram_0018;
            16'h0019: r_i2c_data_in <= r_reg_0019;
            16'h001A: r_i2c_data_in <= r_reg_001A;
            16'h001B: r_i2c_data_in <= r_reg_001B;
            16'h0020: r_i2c_data_in <= w_ram_0020;
            16'h0021: r_i2c_data_in <= w_ram_0021;
            16'h0023: r_i2c_data_in <= r_reg_0023;
            16'h0024: r_i2c_data_in <= w_ram_0024;
            16'h0072: r_i2c_data_in <= r_reg_0072;
            default: r_i2c_data_in <= 8'h00;
        endcase
    end
end

// ----------------------------- Write logic -----------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_reg_0006 <= 8'h55;
        r_reg_0013 <= 8'h00;
        r_reg_0019 <= 8'hFF; // default throttles = inactive (high)
        r_reg_001A <= 8'hFF;
        r_reg_001B <= 8'hFF;
        r_reg_0023 <= 8'h00;
        r_reg_0072 <= 8'h00;
    end else begin
        if ((w_WR == 1'b0) && w_data_vld_pos) begin
            case (w_i2c_command)
                16'h0006: r_reg_0006 <= ~w_i2c_data_out; // preserve existing test reg style
                16'h0013: r_reg_0013 <= w_i2c_data_out;  // uid led ctl
                16'h0019: r_reg_0019 <= w_i2c_data_out;  // gpu throttle pack
                16'h001A: r_reg_001A <= w_i2c_data_out;
                16'h001B: r_reg_001B <= w_i2c_data_out;
                16'h0023: r_reg_0023 <= w_i2c_data_out;
                16'h0072: r_reg_0072 <= w_i2c_data_out;
                default: ; // ignore writes to RO/defaults
            endcase
        end
    end
end

// ----------------------------- i2c slave inst ---------------------------------
// i2c_slave_bmc should exist in project and provide:
//  .o_i2c_start, .o_WR, .o_data_vld_pos, .o_i2c_command, .o_i2c_data_out, .i_i2c_data_in
i2c_slave_bmc #(
    .DLY_LEN (DLY_LEN)
) i2c_slave_bmc_u0 (
    .i_rst_n        (i_rst_n),
    .i_clk          (i_clk),
    .i_1ms_clk      (i_1ms_clk),
    .i_rst_i2c_n    (i_rst_i2c_n),
    .i_scl          (i_scl),
    .io_sda         (io_sda),
    .i_i2c_address  (7'h20),
    .o_i2c_start    (w_i2c_start),
    .o_WR           (w_WR),
    .o_data_vld_pos (w_data_vld_pos),
    .o_i2c_command  (w_i2c_command),
    .i_i2c_data_in  (r_i2c_data_in),
    .o_i2c_data_out (w_i2c_data_out)
);

endmodule