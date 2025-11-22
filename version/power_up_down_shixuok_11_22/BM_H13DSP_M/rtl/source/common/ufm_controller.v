`timescale 1ns / 1ps
module ufm_controller (
    input  wire        clk,            // 输入：工作时钟（顶层wb_clk，4.29MHz）
    input  wire        rst_n,          // 输入：系统复位（顶层w_rst_n，低电平有效）
    input  wire        pwr_ok,         // 输入：电源就绪信号（顶层i_P0_PWROK，高电平有效）
    input  wire [7:0]  cmd_opcode,     // 输入：I2C指令 opcode（擦除=0x01/写入=0x02/校验=0x03）
    input  wire [31:0] cmd_addr,       // 输入：UFM操作地址（擦除/写入的目标地址）
    input  wire [7:0]  cmd_data,       // 输入：UFM写入数据（仅写入指令有效）
    input  wire        cmd_valid,      // 输入：指令有效信号（高电平=指令可执行）
    output reg         erase_done,     // 输出：擦除完成信号（高电平=擦除成功）
    output reg         write_done,     // 输出：写入完成信号（高电平=写入成功）
    output reg         verify_done,    // 输出：校验完成信号（高电平=校验成功）
    output reg         ufm_error       // 输出：UFM错误信号（高电平=操作失败）
);

// 内部信号：UFM存储阵列（模拟1KB存储，实际为CPLD硬件UFM）
reg [7:0] ufm_mem [0:1023];           // UFM存储单元（地址0~1023，8位数据）
reg [3:0] op_state;                   // 操作状态机（0=空闲，1=擦除，2=写入，3=校验）
reg [31:0] op_cnt;                    // 操作计数器（模拟擦除/写入的硬件延时）

// 状态机定义
localparam S_IDLE    = 4'd0;          // 空闲状态
localparam S_ERASE   = 4'd1;          // 擦除状态
localparam S_WRITE   = 4'd2;          // 写入状态
localparam S_VERIFY  = 4'd3;          // 校验状态
localparam S_DONE    = 4'd4;          // 操作完成状态
localparam S_ERR     = 4'd5;          // 错误状态

// 1. UFM初始化：复位时清空存储（模拟硬件UFM复位）
initial begin
    integer i;
    for (i = 0; i < 1024; i = i + 1) begin
        ufm_mem[i] = 8'hFF; // 擦除后默认值为0xFF
    end
end

// 2. 操作状态机：仅在电源就绪（pwr_ok=1）时执行操作
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        op_state <= S_IDLE;
        op_cnt <= 32'd0;
        erase_done <= 1'b0;
        write_done <= 1'b0;
        verify_done <= 1'b0;
        ufm_error <= 1'b0;
    end else if (~pwr_ok) begin
        // 电源未就绪：强制回到空闲状态，清空所有标志
        op_state <= S_IDLE;
        op_cnt <= 32'd0;
        erase_done <= 1'b0;
        write_done <= 1'b0;
        verify_done <= 1'b0;
        ufm_error <= 1'b0;
    end else begin
        case (op_state)
            S_IDLE: begin
                // 指令有效时，根据opcode进入对应操作状态
                if (cmd_valid) begin
                    case (cmd_opcode)
                        8'h01: begin // 擦除指令
                            if (cmd_addr < 32'd1024) begin // 地址合法（0~1023）
                                op_state <= S_ERASE;
                                op_cnt <= 32'd100; // 模拟擦除延时（100个时钟周期）
                            end else begin
                                op_state <= S_ERR; // 地址非法，进入错误状态
                            end
                        end
                        8'h02: begin // 写入指令
                            if (cmd_addr < 32'd1024) begin // 地址合法
                                op_state <= S_WRITE;
                                op_cnt <= 32'd50; // 模拟写入延时（50个时钟周期）
                            end else begin
                                op_state <= S_ERR;
                            end
                        end
                        8'h03: begin // 校验指令
                            if (cmd_addr < 32'd1024) begin // 地址合法
                                op_state <= S_VERIFY;
                                op_cnt <= 32'd30; // 模拟校验延时（30个时钟周期）
                            end else begin
                                op_state <= S_ERR;
                            end
                        end
                        default: begin // 非法指令
                            op_state <= S_ERR;
                        end
                    endcase
                end
                // 清空完成/错误标志
                erase_done <= 1'b0;
                write_done <= 1'b0;
                verify_done <= 1'b0;
                ufm_error <= 1'b0;
            end

            S_ERASE: begin
                // 延时计数完成后，执行擦除操作
                if (op_cnt == 32'd0) begin
                    ufm_mem[cmd_addr] <= 8'hFF; // 擦除：将目标地址设为0xFF
                    op_state <= S_DONE;
                    erase_done <= 1'b1; // 置位擦除完成标志
                end else begin
                    op_cnt <= op_cnt - 1'b1; // 延时计数递减
                end
            end

            S_WRITE: begin
                // 延时计数完成后，执行写入操作
                if (op_cnt == 32'd0) begin
                    ufm_mem[cmd_addr] <= cmd_data; // 写入：将数据写入目标地址
                    op_state <= S_DONE;
                    write_done <= 1'b1; // 置位写入完成标志
                end else begin
                    op_cnt <= op_cnt - 1'b1;
                end
            end

            S_VERIFY: begin
                // 延时计数完成后，执行校验操作
                if (op_cnt == 32'd0) begin
                    if (ufm_mem[cmd_addr] == cmd_data) begin // 存储值 == 期望数据：校验成功
                        op_state <= S_DONE;
                        verify_done <= 1'b1;
                    end else begin // 校验失败
                        op_state <= S_ERR;
                    end
                end else begin
                    op_cnt <= op_cnt - 1'b1;
                end
            end

            S_DONE: begin
                // 完成状态保持1个时钟周期，回到空闲
                op_state <= S_IDLE;
            end

            S_ERR: begin
                // 错误状态保持1个时钟周期，置位错误标志
                ufm_error <= 1'b1;
                op_state <= S_IDLE;
            end
        endcase
    end
end

endmodule