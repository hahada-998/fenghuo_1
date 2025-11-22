`timescale 1ns / 1ps
module CPLD_Hitless_Control (
    input  wire w_sys_clk,
    input  wire w_rst_n,
    inout  wire [29:0] io_signal_out,
    input  wire [29:0] pre_load_feedback,
    output wire [29:0] user_outputs,
    output reg  update_done,
    output reg  update_error
);

// 内部信号（与I2C、UFM交互）
wire        i2c_cmd_valid;
wire [7:0]  i2c_cmd_opcode;
wire [31:0] i2c_addr;
wire [7:0]  i2c_data;
wire        i2c_trans_done;
wire        ufm_erase_done;
wire        ufm_write_done;
wire        ufm_verify_done;
reg         transfr_enable;
reg         transfr_release;
reg         gpio_latch;
reg [1:0]   update_state;

// 状态定义
localparam S_IDLE        = 2'd0;
localparam S_FLASH_UPDATE = 2'd1;
localparam S_SRAM_REFRESH = 2'd2;
localparam S_FINISH      = 2'd3;

// GPIO 锁存逻辑：控制TransFR功能
always @(posedge w_sys_clk or negedge w_rst_n) begin
    if (~w_rst_n) begin
        gpio_latch <= 1'b0;
        transfr_enable <= 1'b0;
        transfr_release <= 1'b0;
    end else begin
        if (transfr_enable) begin
            gpio_latch <= 1'b1;  // 锁存GPIO状态
            transfr_enable <= 1'b0;
        end
        if (transfr_release) begin
            gpio_latch <= 1'b0;  // 释放GPIO锁存
            transfr_release <= 1'b0;
        end
    end
end

// 升级状态机：串联无感升级三步
always @(posedge w_sys_clk or negedge w_rst_n) begin
    if (~w_rst_n) begin
        update_state <= S_IDLE;
        update_done  <= 1'b0;
        update_error <= 1'b0;
    end else begin
        case (update_state)
            S_IDLE: begin
                if (i2c_cmd_opcode == 8'h02 && ufm_write_done)
                    update_state <= S_FLASH_UPDATE;
            end
            S_FLASH_UPDATE: begin
                if (ufm_verify_done) begin
                    transfr_enable <= 1'b1;  // 触发GPIO锁存
                    update_state <= S_SRAM_REFRESH;
                end else if (ufm_error) begin
                    update_error <= 1'b1;
                    update_state <= S_FINISH;
                end
            end
            S_SRAM_REFRESH: begin
                transfr_release <= 1'b1;  // 释放GPIO锁存
                update_done <= 1'b1;
                update_state <= S_FINISH;
            end
            S_FINISH: begin
                // 保持完成状态
            end
        endcase
    end
end

// UFM 控制器实例化
ufm_controller ufm_inst (
    .clk         (w_sys_clk),
    .rst_n       (w_rst_n),
    .cmd_opcode  (i2c_cmd_opcode),
    .cmd_addr    (i2c_addr),
    .cmd_data    (i2c_data),
    .cmd_valid   (i2c_cmd_valid),
    .erase_done  (ufm_erase_done),
    .write_done  (ufm_write_done),
    .verify_done (ufm_verify_done),
    .ufm_error   (update_error)
);

endmodule