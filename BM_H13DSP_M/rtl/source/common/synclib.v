//==============================================================================================================
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : liuqi
// Date       : 2020-09-24
// Email      : liuqic@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: 
//==============================================================================================================

/* ------------------------------------------------------------------------------------------------------------
模块功能
该模块的主要功能是将异步复位信号同步到时钟域中，以避免由于异步信号直接驱动时钟域逻辑而导致的亚稳态问题.

工作原理
异步复位检测: 当 aaad_rst_n 为低电平时，模块立即将 aasd_rst_n 和中间寄存器 ff_s1 置为低电平, 确保了复位信号能够快速响应.
同步解复位: 通过两个寄存器级联（ff_s1 和 aasd_rst_n），确保输出信号 aasd_rst_n 的同步性和稳定性.

下述模块一个是低电平有效复位，一个是高电平有效复位.
---------------------------------------------------------------------------------------------------------------*/
module SYNC_RESET_N_AASD(
    input   wire                   clk                 , 
    input   wire                   aaad_rst_n          , 
    output  reg                    aasd_rst_n    
); 
reg                                ff_s1               ;  // lint_checking FFCSTD off
always @(posedge clk or negedge aaad_rst_n) begin
  if (!aaad_rst_n) begin
    ff_s1      <= 1'b   ;
    aasd_rst_n <= 1'b   ;
  end
  else begin
    ff_s1      <= 1'b1  ;
    aasd_rst_n <= ff_s1 ;
  end
end
endmodule

module SYNC_RESET_AASD(
    input   wire                    clk                  , 
    input   wire                    aaad_rst             , 
    output  reg                     aasd_rst
);
reg                                 ff_s1               ;  // lint_checking FFCSTD off
always @(posedge clk or posedge aaad_rst) begin
  if (aaad_rst) begin
    ff_s1     <= 1'b1   ;
    aasd_rst  <= 1'b1   ;
  end
  else begin
    ff_s1     <= 1'b0   ;
    aasd_rst  <= ff_s1  ;
  end
end
endmodule

/* ------------------------------------------------------------------------------------------------------------
模块功能
保证解复位的同步性, 不保证异步复位 
---------------------------------------------------------------------------------------------------------------*/
module SYNC_RESET_SASD(
    input   wire                    clk                  , 
    input   wire                    aaad_rst             , 
    output  reg                     sasd_rst
);
reg                                 ff_s1               ;  // lint_checking FFWNSR RSTDAT off
always @(posedge clk) begin
    ff_s1     <= aaad_rst ;
    sasd_rst  <= ff_s1    ;
end
endmodule

/* ------------------------------------------------------------------------------------------------------------
模块功能
数据同步器，用于将异步数据信号同步到时钟域中，避免亚稳态问题。使用两级D触发器级联实现同步，并带有低电平复位控制.

工作原理
异步复位有效：输出dout都被重置为全0。
复位无效：输出dout两级同步确保了数据信号的亚稳态被充分抑制，输出相对于时钟域是稳定且安全的。


下述模块一个是低电平有效复位，一个是高电平有效复位.
---------------------------------------------------------------------------------------------------------------*/
module SYNC_DATA_N #(parameter SIGCNT = 1) (
    input   wire                    clk                 ,
    input   wire                    rst_n               ,
    input   wire    [SIGCNT-1:0]    din                 ,
    output  reg     [SIGCNT-1:0]    dout
);
reg     [SIGCNT-1:0]                ff_s1               ;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout     <= {SIGCNT{1'b0}};
        ff_s1    <= {SIGCNT{1'b0}};
    end
    else begin
        ff_s1    <= din           ;
        dout     <= ff_s1         ;
    end
end
endmodule

module SYNC_DATA #(parameter SIGCNT = 1) (
    input   wire                    clk                 ,
    input   wire                    rst                 ,
    input   wire    [SIGCNT-1:0]    din                 ,
    output  reg     [SIGCNT-1:0]    dout
);
reg     [SIGCNT-1:0]                ff_s1               ;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        dout     <= {SIGCNT{1'b1}};
        ff_s1    <= {SIGCNT{1'b1}};
    end
    else begin
        ff_s1    <= din           ;
        dout     <= ff_s1         ;
    end
end
endmodule


/* ------------------------------------------------------------------------------------------------------------
模块功能
用于过滤异步信号毛刺

工作原理
输入信号打2拍, 短时毛刺（<3 周期）不会影响输出，稳定的信号变化 (>=3 周期) 才传播。
---------------------------------------------------------------------------------------------------------------*/
module STABLE (
    input   wire                    clk                 ,
    input   wire                    aaad_sig            , 
    output  reg                     sasd_sig
);
reg     [SIGCNT-1:0]                ff_s1               ;  // lint_checking FFWASR FFWNSR MRSTDT off
reg     [SIGCNT-1:0]                ff_s2               ;  // lint_checking FFWASR FFWNSR MRSTDT off

always @(posedge clk)begin // Synchronize incoming signal
    ff_s1 <= aaad_sig   ;
    ff_s2 <= ff_s1      ;
end

always @(posedge clk)begin // Circuit to filter both signal assert and de-assert glitches
  if(aaad_sig && ff_s1 && ff_s2)
    sasd_sig <= 1;
  else if(!aaad_sig && !ff_s1 && !ff_s2)
    sasd_sig <= 0;
  else
    sasd_sig <= sasd_sig;
end
endmodule

/* ------------------------------------------------------------------------------------------------------------
模块功能
组合逻辑打拍输出

下述模块一个是低电平有效复位，一个是高电平有效复位.
---------------------------------------------------------------------------------------------------------------*/

module BREAK_COMBI_N (
    input   wire                    clk                 ,
    input   wire                    rst_n               ,
    input   wire                    din                 , 
    output  reg                     dout
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        dout <= 1'b0 ;
    else 
        dout <= din  ;
end
endmodule

module BREAK_COMBI (
    input   wire                    clk                 ,
    input   wire                    rst_n               ,
    input   wire                    din                 , 
    output  reg                     dout
);

always @(posedge clk or posedge rst) begin
    if (rst) 
        dout <= 1'b1 ;
    else 
        dout <= din  ;
end
endmodule

module ISOLATE_COMBI (
    input   wire                    clk                 , 
    input   wire                    din                 , 
    output  reg                     dout
);
reg                                 ff_s1               ;  // lint_checking FFWNSR off

always @(posedge clk) begin
    ff_s1 <= din    ;
    dout  <= ff_s1  ;
end
endmodule

/* ------------------------------------------------------------------------------------------------------------
模块功能
去抖动模块，用于对输入信号进行去抖动处理，确保输出信号稳定. 它通过计数器和延迟机制过滤掉输入信号中的毛刺或短时抖动

下述模块一个是低电平有效复位，一个是高电平有效复位.
---------------------------------------------------------------------------------------------------------------*/
module PGM_DEBOUNCE_N #(
    parameter SIGCNT = 5                      , // 信号数量
    parameter NBITS  = 3                      , // 计数器位宽
    parameter NDELAY = (2**NBITS)             , // 去抖动延迟周期
    parameter ENABLE = 1                        // 去抖动使能
)(
    input  wire                   clk         ,  // 时钟信号
    input  wire                   rst_n       ,  // 低电平有效复位
    input  wire                   timer_tick  ,  // 计数器使能信号
    input  wire  [SIGCNT-1:0]     din         ,  // 输入信号
    output wire  [SIGCNT-1:0]     dout           // 输出信号
);

// 内部寄存器和信号
reg  [SIGCNT-1:0]                  nxt_s1, nxt, out_i    ; // 同步寄存器和输出寄存器
reg  [SIGCNT-1:0][(NBITS-1):0]     cnt                   ; // 计数器
reg  [SIGCNT-1:0]                  equal                 ; // 状态比较信号

// 去抖动逻辑
generate
    genvar i;
    for (i = 0; i < SIGCNT; i = i + 1) begin: DEBOUNCE_LOGIC
        // 输入信号打2拍使用
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                nxt_s1[i] <= 1'b0       ;
                nxt[i]    <= 1'b0       ;
            end 
            else begin
                nxt_s1[i] <= din[i]     ;
                nxt[i]    <= nxt_s1[i]  ;
            end
        end

        // 比较当前信号状态是否一致
        assign equal[i] = (din[i] & nxt_s1[i] & nxt[i]) || (~din[i] & ~nxt_s1[i] & ~nxt[i]);

        // 计数器, 控制状态变化
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                cnt[i] <= {(NBITS?NBITS:1){1'b0}};
            else if(!equal[i]) // 状态变化时清零计数器
                cnt[i] <= {(NBITS?NBITS:1){1'b0}}; 
            else if(timer_tick && (cnt[i] < (NDELAY - 1'b1))) // 状态稳定时计数器递增（受计数器使能控制 ）
                cnt[i] <= cnt[i] + 1'b1;
        end

        // 输出寄存器更新
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                out_i[i] <= 1'b0;
            else if(timer_tick && (cnt[i] == (NDELAY - 1'b1))) // 状态稳定达到延迟要求时更新输出 
                out_i[i] <= nxt[i];
        end 
    end
endgenerate

// 输出信号赋值
assign dout = ENABLE ? out_i : din;
endmodule

module PGM_DEBOUNCE #(
    parameter SIGCNT = 5,                      // 信号数量
    parameter NBITS  = 3,                      // 计数器位宽
    parameter NDELAY = (2**NBITS),             // 去抖动延迟周期
    parameter ENABLE = 1                       // 去抖动使能
)(
    input  wire                   clk,         // 时钟信号
    input  wire                   rst,         // 高电平有效复位
    input  wire                   timer_tick,  // 计数器使能信号
    input  wire  [SIGCNT-1:0]     din,         // 输入信号
    output wire  [SIGCNT-1:0]     dout         // 输出信号
);

reg   [SIGCNT-1:0]                  nxt_s1, nxt, out_i;   // 同步寄存器和输出寄存器
reg   [SIGCNT-1:0][(NBITS-1):0]     cnt;                 // 计数器
reg   [SIGCNT-1:0]                  equal;               // 状态比较信号

generate
    genvar i;
    for (i = 0; i < SIGCNT; i = i + 1) begin: DEBOUNCE_LOGIC
        // 输入信号打2拍
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                nxt_s1[i] <= 1'b0;
                nxt[i]    <= 1'b0;
            end else begin
                nxt_s1[i] <= din[i];
                nxt[i]    <= nxt_s1[i];
            end
        end

        // 比较当前信号状态是否一致
        assign equal[i] = (din[i] & nxt_s1[i] & nxt[i]) || (~din[i] & ~nxt_s1[i] & ~nxt[i]);

        // 计数器逻辑
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                cnt[i] <= {(NBITS){1'b0}};
            end else if (!equal[i]) begin
                cnt[i] <= {(NBITS){1'b0}}; // 状态变化时清零计数器
            end else if (timer_tick && (cnt[i] < (NDELAY - 1'b1))) begin
                cnt[i] <= cnt[i] + 1'b1; // 状态稳定时计数器递增
            end
        end

        // 输出寄存器更新
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                out_i[i] <= 1'b0;
            end else if (timer_tick && (cnt[i] == (NDELAY - 1'b1))) begin
                out_i[i] <= nxt[i]; // 状态稳定达到延迟要求时更新输出
            end
        end
    end
endgenerate

// 输出信号赋值
assign dout = ENABLE ? out_i : din;
endmodule

/* ------------------------------------------------------------------------------------------------------------
模块功能
（1）去抖动模块，用于对输入信号进行去抖动处理，确保输出信号稳定. 它通过计数器和延迟机制过滤掉输入信号中的毛刺或短时抖动
（2）支持1-4个周期延迟时间选择，用户动态调整去抖动的时间参数；支持去抖动功能的启用和禁用，方便在不同应用场景下使用。
---------------------------------------------------------------------------------------------------------------*/
module PGM_DEBOUNCE_GPO_N #(
    parameter SIGCNT = 5,                      // 信号数量
    parameter NBITS = 3,                       // 计数器位宽
    parameter DEFAULT_OUT = 5'b00000           // 默认输出值
)(
    input  wire                   clk,         // 时钟信号
    input  wire                   rst_n,       // 低电平有效复位
    input  wire  [SIGCNT-1:0]     din,         // 输入信号
    input  wire  [1:0]            select_delay,// 延迟选择信号
    input  wire  [(NBITS-1):0]    ndelay0,     // 延迟值选项 0
    input  wire  [(NBITS-1):0]    ndelay1,     // 延迟值选项 1
    input  wire  [(NBITS-1):0]    ndelay2,     // 延迟值选项 2
    input  wire  [(NBITS-1):0]    ndelay3,     // 延迟值选项 3
    input  wire                   timer_tick,  // 计数器使能信号
    input  wire                   disable_db,  // 禁用去抖动信号
    output wire  [SIGCNT-1:0]     dout         // 输出信号
);

localparam NDELAY_DEFAULT = (2**NBITS) - 1;    // 默认延迟值

// 内部寄存器和信号
reg   [(NBITS-1):0]                 ndelay              ; // 当前选定的延迟值
reg   [SIGCNT-1:0][(NBITS-1):0]     cnt                 ; // 计数器
reg   [SIGCNT-1:0]                  nxt_s1, nxt, out_i  ; // 同步寄存器和输出寄存器
wre   [SIGCNT-1:0]                  equal               ; // 状态比较信号

// 延迟值选择逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        ndelay <= (!ndelay0) ? NDELAY_DEFAULT : ndelay0;
    else 
        case (select_delay)
            2'b00: ndelay <= ndelay0;
            2'b01: ndelay <= ndelay1;
            2'b10: ndelay <= ndelay2;
            2'b11: ndelay <= ndelay3;
            default: ndelay <= NDELAY_DEFAULT;
        endcase
end

// 去抖动逻辑
generate
    genvar i;
    for (i = 0; i < SIGCNT; i = i + 1) begin: DEBOUNCE_LOGIC
        // 输入信号同步
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                nxt_s1[i] <= DEFAULT_OUT[i];
                nxt[i]    <= DEFAULT_OUT[i];
            end else begin
                nxt_s1[i] <= din[i];
                nxt[i]    <= nxt_s1[i];
            end
        end

        // 状态比较逻辑
        assign equal[i] = (din[i] & nxt_s1[i] & nxt[i]) || (~din[i] & ~nxt_s1[i] & ~nxt[i]);

        // 计数器逻辑
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                cnt[i] <= {NBITS{1'b0}};
            end else if (!equal[i]) begin
                cnt[i] <= {NBITS{1'b0}}; // 状态变化时清零计数器
            end else if (timer_tick && (cnt[i] < ndelay)) begin
                cnt[i] <= cnt[i] + 1'b1; // 状态稳定时计数器递增
            end
        end

        // 输出寄存器更新
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                out_i[i] <= DEFAULT_OUT[i];
            end else if (timer_tick && (cnt[i] == ndelay)) begin
                out_i[i] <= nxt[i]; // 状态稳定达到延迟要求时更新输出
            end
        end
    end
endgenerate

// 输出信号赋值
assign dout = disable_db ? din : out_i;
endmodule
