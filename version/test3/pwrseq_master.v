//=================================================================================================
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module is the power sequencing master. It is responsible for directing the
//   system's power sequencing slaves to enable/disable VRMs. The master is responsible for
//   monitoring each of the power goods coming back from the slaves. These power goods are
//   consolidated to pgd_so_far When a power fault occurs, the master will normally transition to
//   the `SM_CRITICAL_FAIL state to allow the slave to capture the source of the fault. The master
//   will then proceed with power-down sequence to protect the system.
//   This module uses a single WDT counter for all timeout logic so it determines the largest
//   counter needed based on the largest timeout parameter given below. This, together with
//   sequence_tick and psu_on_tick, each platform can vary the granularity of the timeout values.
// Parameter  :
//   LIM_RECOV_MAX_RETRY_ATTEMPT: Number of allowed power-on retry attempt following a limited
//     recoverable fault condition. Once the max number of attempt is reached, the system will only
//     be recoverable by cycling aux efuse.
//     Default: 2
//   WDT_NBITS: Number of counter bits to use to support the timeout values below.
//     Default: 8 (max of 255 for any timeout values)
//     For the parameters below, it is assumed that the sequence_tick rate is 2ms while psu_on_tick
//     rate is 32ms. Platform can use a different tick as needed.
//   DSW_PWROK_TIMEOUT_VAL: Time to wait in SM_EN_PCH_DSW_PWROK for SLPSUS# to de-assert after
//     DSWPWROK is asserted. Max spec time is 100ms. Use 150ms for timeout.
//     Default: 75 (sequence_tick=2ms * 75 = 150ms)
//   PCH_WATCHDOG_TIMEOUT_VAL: Wait time for PCH VRM turn on before considering it faulted.
//     Default: 8 (sequence_tick=2ms * 8 = 16ms)
//   PON_WATCHDOG_TIMEOUT_VAL: Wait time for VRM turn on before considering it faulted.
//     Default: 112 (sequence_tick=2ms * 112 = 224ms)
//   PSU_WATCHDOG_TIMEOUT_VAL: 1st stage wait time for PSU turn on. If PSU is good during this
//     time, power sequencer proceed to next stage. Otherwise, wait for 2nd stage.
//     Default: 10 (psu_on_tick=32ms * 10 = 320ms)
//   EFUSE_WATCHDOG_TIMEOUT_VAL: Wait time for efuse turnon before considering it faulted.
//     Default: 137 (sequence_tick=2ms * 137 = 274ms)
//   VCORE_WATCHDOG_TIMEOUT_VAL: Wait time for CPU vcore turn on before considering it faulted.
//     Default: 112 (sequence_tick=2ms * 112 = 224ms)
//   PDN_WATCHDOG_TIMEOUT_VAL: Wait time for VRM turn off during no-fault condition.
//     Default: 2 (sequence_tick=2ms * 2 = 4ms)
//   PDN_WATCHDOG_TIMEOUT_FAULT_VAL: Wait time for VRM turn off during fault condition.
//     Default: 2 (sequence_tick=2ms * 2 = 4ms)
//   DISABLE_INTEL_VCCIN_TIMEOUT_VAL, DISABLE_INTEL_VCCIN_TIMEOUT_FAULT_VAL: Wait time for VRM turn
//     off during SM_DISABLE_INTEL_VCCIN state for both normal and fault condition.
//     This is a state specific timout value.
//     Default: PDN_WATCHDOG_TIMEOUT_VAL
//   DISABLE_3V3_TIMEOUT_VAL, DISABLE_3V3_TIMEOUT_FAULT_VAL: Wait time for VRM turn off during
//     SM_DISABLE_3V3 state for both normal and fault condition.
//     This is a state specific timout value.
//     Default: PDN_WATCHDOG_TIMEOUT_VAL
//   PON_65MS_WATCHDOG_TIMEOUT_VAL: Wait before transitioning to `SM_STEADY_PWROK after all VRM has turnd on.
//     Default: 34 (sequence_tick=2ms * 34 = 68ms)
//   DC_ON_WAIT_COMPLETE_NOFLT_VAL: Time to wait in `SM_OFF_STANDBY before proceeding to turn on w/o fault.
//     Default: 17 (256ms * 17 = 4.3s)
//   DC_ON_WAIT_COMPLETE_FAULT_VAL: Time to wait in `SM_OFF_STANDBY before proceeding to turn on with fault.
//     Default: 2 (256ms * 2 = 512ms)
//   PF_ON_WAIT_COMPLETE_VAL: Time to wait in `SM_HALT_POWER_CYCLE before allowing recovery, if
//     allowed. This is also the time used to assert PCH PWRBTN# input to force S0->S5 transition.
//     Default: 33 (256ms * 33 = 8.4s)
//   PO_ON_WAIT_COMPLETE_VAL: Time to assert the PCH PWRBTN# input to force an S5->S0 transition.
//     Default: 1 (256ms * 1 = 256ms)
//   S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL, S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL: Time to wait in
//     `SM_OFF_STANDBY before proceeding to enable the S5 devices.
//     Default: 0 (256ms * 0 = 0)
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================
`include "pwrseq_define.v"
module pwrseq_master #(
  parameter LIM_RECOV_MAX_RETRY_ATTEMPT                     = 2,        //有限恢复类故障的最大重试次数（如电源软故障的重试上限）
  parameter WDT_NBITS                                       = 10,       //看门狗计数器的位宽，决定超时时间的范围
  parameter GRP_A_PWROK_TIMEOUT_VAL                             = 75,   //电源组 A 的 PWR_OK 超时阈值（单位：时钟周期，用于检测电源就绪是否超时）
  parameter GRP_B_PWROK_TIMEOUT_VAL                             = 256,  //电源组 B 的 PWR_OK 超时阈值
  parameter PON_WATCHDOG_TIMEOUT_VAL                           = 256,   //上电阶段（Power-On）的看门狗超时阈值
  parameter PSU_WATCHDOG_TIMEOUT_VAL                           = 10,    //电源模块（PSU）的看门狗超时阈值
  parameter EFUSE_WATCHDOG_TIMEOUT_VAL                       = 137,     //eFuse 相关操作的看门狗超时阈值
  parameter VCORE_WATCHDOG_TIMEOUT_VAL                       = PON_WATCHDOG_TIMEOUT_VAL,  //核心电压（VCORE）的看门狗超时阈值
  parameter PDN_WATCHDOG_TIMEOUT_VAL                           = 2,     //下电阶段（Power-Down）的看门狗超时阈值
  parameter PDN_WATCHDOG_TIMEOUT_FAULT_VAL               = PDN_WATCHDOG_TIMEOUT_VAL,      //下电阶段故障时的看门狗超时阈值
  parameter DISABLE_INTEL_VCCIN_TIMEOUT_VAL             = PDN_WATCHDOG_TIMEOUT_VAL,       //禁用 Intel VCCIN 电源的超时阈值
  parameter DISABLE_INTEL_VCCIN_TIMEOUT_FAULT_VAL = PDN_WATCHDOG_TIMEOUT_VAL,             //禁用 Intel VCCIN 电源故障时的超时阈值
  parameter DISABLE_3V3_TIMEOUT_VAL                       = PDN_WATCHDOG_TIMEOUT_VAL,     //禁用 3.3V 电源的超时阈值
  parameter DISABLE_3V3_TIMEOUT_FAULT_VAL                 = PDN_WATCHDOG_TIMEOUT_VAL,     //禁用 3.3V 电源故障时的超时阈值
  parameter PON_65MS_WATCHDOG_TIMEOUT_VAL                 = 34,         //上电阶段 65ms 窗口的看门狗超时阈值
  parameter DC_ON_WAIT_COMPLETE_NOFLT_VAL                 = 17,         //无故障时 “直流上电等待完成” 的超时阈值
  parameter DC_ON_WAIT_COMPLETE_FAULT_VAL                 = 2,          //故障时 “直流上电等待完成” 的超时阈值
  parameter PF_ON_WAIT_COMPLETE_VAL                             = 33,   //电源故障恢复（PF On）的等待完成阈值
  parameter PO_ON_WAIT_COMPLETE_VAL                             = 1,    //上电完成（PO On）的等待完成阈值
  parameter S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL = 4,                  //S5 状态下设备上电（无故障）的等待完成阈值
  parameter S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL = 0,                  //S5 状态下设备上电（故障）的等待完成阈值
  parameter RSMRST_REALSE_TIMEOUT_VAL			        = 75,                 //RSMRST# 信号释放的超时阈值（用于南桥复位控制）
  parameter DISPG_WATCHDOG_TIMEOUT_VAL			= 6                         //显示相关模块的看门狗超时阈值
  ) (
// Clocks and resets
  input     wire    clk     ,                   // clock
  input     wire    reset ,                   // reset
  input     wire    cmu_fault_clear_rst,      //CMU（时钟管理单元）故障清除复位信号，用于清除 CMU 相关故障标志
// Ticks
  input     wire    t1us                   ,    // 10ns pulse every 1us 每 1 微秒的脉冲信号，用于微秒级超时计数（如短时间窗口的电源就绪检测）
  input     wire    t512us               ,    // 10ns pulse every 512us
  input     wire    t256ms               ,    // 10ns pulse every 256ms 每 256 毫秒的脉冲信号，用于长时间窗口的状态检测（如下电超时）
  input     wire    t512ms               ,    // 10ns pulse every 500ms
  input     wire    t1s_tick           ,    // 10ns pulse every 1s 每 1 秒的脉冲信号，用于秒级超时或周期性任务（如电源健康轮询）
  input     wire    sequence_tick ,    // tick used for wdt timeout during power-up/down states 电源时序专用 Tick，用于上电 / 下电阶段的看门狗超时计数
  input     wire    psu_on_tick     ,    // tick used for wdt timeout during PS on state  电源模块（PSU）上电专用 Tick，用于 PSU 状态的超时检测
  input     wire    i_20mSEC        ,
// Physical power button and south bridge status/control
  input     wire    sys_sw_in_n                          ,    // system's power button switch 系统电源按钮（低有效），用户按下时触发上电 / 下电流程
  input     wire    pch_slp4_n                            ,    // SB (south bridge) system sleep state 南桥（PCH）睡眠状态信号（低有效），指示系统是否进入 S4 睡眠状态
  input     wire    p0_pwrbtn_n                          ,    // SB power button input (same signal driven to SB PWRBTN)  南桥电源按钮输入（低有效），与 sys_sw_in_n 联动，驱动南桥电源状态
  input     wire    [1:0]   pch_thermtrip_n     ,    // SB bound thermtrip signal (same signal driven to SB THERMTRIP)  南桥热跳变信号（低有效），检测到过热时触发紧急下电
  output   reg      force_pwrbtn_n                    ,    // forces SB to switch to S5 after power shutdown due to fault 强制驱动南桥电源按钮（低有效），故障时强制系统进入 S5 关机状态
  input     wire    [1:0]   cpu_thermtrip_fault_det  ,      //CPU 热跳变故障检测信号，多通道指示不同 CPU 的过热状态
  input     wire    [5:0]   power_seq_sm_fb     ,           //电源时序状态机反馈信号，用于多模块间状态同步
  input     wire    mux_sel                          ,      // 多路选择器控制信号，用于切换电源时序的配置或路径

  // Misc.
  input     wire    xr_ps_en                        ,// system allowed to power on (Xreg's ps_enable) X 寄存器的电源使能信号，软件层面对电源的使能控制
  input     wire    pwron_override_n        ,// power-on override 上电覆盖信号（低有效），强制触发上电流程
  input     wire    interlock_broken        ,// interlock broken indicator 联锁故障信号，指示硬件联锁（如安全机制）被破坏
  input     wire    allow_recovery            ,// allow power button press to recover from HALT_POWER_CYCLE 允许恢复信号，故障时允许通过电源按钮重试恢复
  input     wire    aux_video_holdoff      ,// allow AUX video to hold turning on of system 辅助视频保持信号，延迟系统上电以等待视频模块就绪
  input     wire    pgood_rst_mask            ,// from ADR module to mask shutdown events PGOOD 复位掩码信号，屏蔽某些 PGOOD 事件的下电触发
  //input            bmc_ready_out_n           ,
  input     wire    bmc_clr_stby_tmout_n ,    //BMC 清除待机超时信号（低有效），用于清除 BMC 触发的待机超时标志

//  input            cpu_mcp_en,              // any CPU is MCP enabled which enables P1V0_CPU and PVMCP_CPU rails
  input     wire    keep_alive_on_fault,     // prevent transition to critical fail on power up  故障时保持运行信号，故障时不立即进入关键故障状态，维持系统运行
//  input            no_vppen,                // set to 1'b1 if platform does not have an explicity EN for VPP rails
//  input            hold_pch_rsmrst,         // set to 1'b1 to stall power sequencer in state before RSMRST# is released
  output   reg      pgd_raw,                 // de-asserts on SM_STEADY_OK on fault condition
// S5 powered device control
  input     wire    s5dev_pwren_request,     // S5 powered device enable request  S5 设备上电请求，触发 S5 状态下设备的电源使能
  input     wire    s5dev_pwrdis_request,    // S5 powered device disable request S5 设备下电请求，触发 S5 状态下设备的电源禁用
// Slave sequencer interface
  input     wire    pgd_so_far                        ,   // current overall power status 当前整体电源就绪状态，从模块反馈的电源就绪汇总
  input     wire    any_pwr_fault_det          ,   // any type of power fault 任何电源故障检测，从模块反馈的故障汇总
  input     wire    any_lim_recov_fault      ,   // any limited recovery fault 任何有限恢复类故障，从模块反馈的可重试故障汇总
  input     wire    any_non_recov_fault      ,   // any non-recoverable fault 任何不可恢复故障，从模块反馈的致命故障汇总
  output   reg      dc_on_wait_complete      ,   // 4s flag - used by slave for stuck on check 	直流上电等待完成标志，主模块通知从模块 “上电等待窗口结束”
  output   reg      rt_critical_fail_store,   // asserts when during runtime when critical failure detected 运行时关键故障存储标志，记录致命故障用于后续诊断
  output   reg      fault_clear                      ,   // clear fault flags 故障清除信号，主模块通知从模块清除故障标志
  output   reg      cmu_fault_clear              ,   // for cmu  CMU 故障清除信号，主模块通知 CMU 清除故障标志
  output   reg      [5:0]   power_seq_sm       ,   // copy of the state variable   电源时序状态机，主模块向从模块同步当前状态机阶段
// Status
  output   reg      fault_power                       ,   // power fault is active  电源故障标志，指示当前存在电源类故障
  output   reg      stby_failure_detected   ,   // standby failure detected (goes to Xreg byte07[4] 待机阶段故障检测，上报系统在待机状态下的故障
  output   reg      po_failure_detected       ,   // poweron failure detected (goes to Xreg byte07[2]) 上电阶段故障检测，上报系统在上电过程中的故障
  output   reg      rt_failure_detected       ,   // runtime failure detected (goes to Xreg byte07[5]) 运行时故障检测，上报系统在正常运行时的故障
  output   reg      cpld_latch_sys_off         ,   // system in non-recovery state (goes to Xreg byte08[6]) CPLD 锁存系统关机标志，指示系统进入不可恢复的关机状态
  output   reg      turn_on_wait                     ,   // system waiting to turn on 等待上电标志，指示系统处于 “就绪但等待触发上电” 的状态
  output   reg      po_failure_detected_set        //上电故障检测置位标志，用于故障的边缘检测或锁存
);
//------------------------------------------------------------------------------
// State definition
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
// Derive number of bits needed for counter
// - This may generate one more than required number of FFs
function integer clogb2 (input [31:0] value);
    reg [31:0] tmp;
    begin
          tmp = (value <= 2) ? 2 : (value - 1);// 处理边界：value≤2时强制tmp=2，避免位宽不足
          for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1)
            tmp = tmp >> 1;// 右移操作：通过循环计算tmp的二进制位数
    end
endfunction
// Limited recovery retry counter
localparam LIM_RECOV_RETRY_NBITS = clogb2(LIM_RECOV_MAX_RETRY_ATTEMPT); //根据 “有限恢复最大重试次数”，自动计算重试计数器的位宽，避免手动定义位宽导致的资源浪费或计数溢出。

//------------------------------------------------------------------------------
// Local sigs
//------------------------------------------------------------------------------
// FSM
reg  [5:0] state;   // 现态：当前电源时序状态机的状态
reg  [5:0] state_ns;// 次态：下一周期要进入的状态

wire st_off_standby;// 状态标志：是否处于SM_OFF_STANDBY（S5待机就绪）
wire st_ps_on;      // 状态标志：是否处于`SM_PS_ON（PSU使能）
wire st_steady_pwrok;// 状态标志：是否处于SM_STEADY_PWROK（S0电源稳定）
wire st_critical_fail;// 状态标志：是否处于SM_CRITICAL_FAIL（关键故障）
wire st_halt_power_cycle;// 状态标志：是否处于SM_HALT_POWER_CYCLE（暂停电源循环）
wire st_disable_main_efuse;// 状态标志：是否处于SM_DISABLE_MAIN_EFUSE（禁用主eFuse）

// Watchdog logic
reg  [WDT_NBITS-1:0] wdt_counter;// 看门狗计数器：用于超时检测
wire wdt_tick;// 看门狗时钟 tick：决定计数速率
reg  [5:0] power_seq_sm_last;// 上一周期的状态机状态：用于检测状态切换
wire wdt_counter_clr; // 看门狗计数器清零信号：状态切换时触发
// 各阶段超时标志：电源组A/B就绪超时、上电超时、PSU超时等
reg  grp_a_pwrok_timeout;
reg  grp_b_pwrok_timeout;
reg  pon_watchdog_timeout;
reg  psu_watchdog_timeout;
reg  efuse_watchdog_timeout;
//reg  vcore_watchdog_timeout;
reg  pdn_watchdog_timeout;
reg  dispg_watchdog_timeout;
//reg  disable_intel_vccin_timeout;
reg  disable_3v3_timeout;
reg  pon_65ms_watchdog_timeout;
// 等待完成标志：用于延迟执行动作（如等待S5设备上电完成）
reg  pf_on_wait_complete;
reg  po_on_wait_complete;
reg  s5_devices_on_wait_complete;
reg  rsmrst_release_timeout;
reg  rsmrst_release_fail_en;

// Button logic
wire p0_pwrbtn_n_ne;// 南桥电源按钮信号边沿检测
wire sys_sw_in_n_ne;// 物理电源按钮信号边沿检测
// wire sys_sw_in_n_delay;
reg  assert_power_button;// 强制触发电源按钮信号
reg  assert_physical_button;// 物理按钮触发标志
reg  assert_button_clr;// 按钮触发标志清零
reg  rt_normal_pwr_down_flag;// 运行时正常下电标志

// Fault flags
// 故障标志及清零/置位信号：待机故障、上电故障、运行时故障
reg  stby_failure_detected_clr;
reg  stby_failure_detected_set;
reg  po_failure_detected_clr;
// reg  po_failure_detected_set;
reg  rt_failure_detected_clr;
reg  rt_failure_detected_set;

// Limited recovery logic
// 有限恢复逻辑：恢复就绪标志、重试计数器、重试计数使能/清零
reg  ready_for_recov;
reg  ready_for_recov_clr;
reg  ready_for_recov_set;
reg  [LIM_RECOV_RETRY_NBITS-1:0] lim_recov_retry_count;
reg  lim_recov_retry_incr;
reg  lim_recov_retry_clr;
wire lim_recov_retry_max; // 重试达到最大次数标志

// Misc
reg  off_state;            // 关机状态标志：是否处于S5及以下关机状态
reg  turn_system_on;       // 系统上电使能标志：触发上电流程
wire pch_slp4_n_delay;     // 南桥S4睡眠信号延迟：防抖处理
reg  fault_clear_ns;       // 故障清零次态：下一周期的故障清零信号
// wire pch_thermtrip_n_delay;

// State transition
// 状态切换使能：各电源组、故障场景的状态切换允许信号
reg  grp_a_state_trans_en;
reg  grp_a_critical_fail_en;
reg  grp_b_state_trans_en;
reg  grp_b_critical_fail_en;
reg  pwrup_state_trans_en;
reg  pwron_critical_fail_en;
reg  psu_critical_fail_en;
reg  efuse_critical_fail_en;
//reg  vcore_critical_fail_en;
reg  wait_steady_pwrok_fail_en;
wire rt_critical_fail_check;  // 运行时关键故障检测
wire rt_normal_pwr_down;      // 运行时正常下电
wire rt_thermtrip_pwr_down;   // 运行时热跳变下电
reg  rsmrst_release_trans_en; // RSMRST释放状态切换使能

//------------------------------------------------------------------------------
// SM states
//------------------------------------------------------------------------------
//  SM states：将状态机值转换为单bit标志，简化逻辑判断
assign  st_off_standby        = (power_seq_sm == `SM_OFF_STANDBY        ) ? 1'b1 : 1'b0;
assign  st_ps_on              = (power_seq_sm == `SM_PS_ON              ) ? 1'b1 : 1'b0;
assign  st_steady_pwrok       = (power_seq_sm == `SM_STEADY_PWROK       ) ? 1'b1 : 1'b0;
assign  st_critical_fail      = (power_seq_sm == `SM_CRITICAL_FAIL      ) ? 1'b1 : 1'b0;
assign  st_halt_power_cycle   = (power_seq_sm == `SM_HALT_POWER_CYCLE   ) ? 1'b1 : 1'b0;
assign  st_disable_main_efuse = (power_seq_sm == `SM_DISABLE_MAIN_EFUSE ) ? 1'b1 : 1'b0;
//将 6bit 的状态机信号 power_seq_sm 与具体状态（如 SM_OFF_STANDBY）比较，输出 1bit wire 标志（高电平表示当前处于该状态）。
//例：当 power_seq_sm 为 6'h08（SM_OFF_STANDBY）时，st_off_standby=1'b1，否则为 0。
//后续逻辑中，判断 “是否处于 S0 稳定状态” 只需写 if (st_steady_pwrok)，无需重复写 if (power_seq_sm == 6'h20)，减少代码量与出错概率

//------------------------------------------------------------------------------
// Watchdog logic
//------------------------------------------------------------------------------
// Tick rate depends on which state we're in.
assign wdt_tick = (off_state) ? t256ms            :
                                 (st_ps_on  ) ? psu_on_tick  :
                                  sequence_tick;
//off_state=1（关机状态）：使用 t256ms（256ms 脉冲），关机阶段无需快速响应，降低计数频率节省资源；
//st_ps_on=1（PSU 使能状态）：使用 psu_on_tick（PSU 专用脉冲），PSU 上电需精准计时，用专用速率；
//其他状态（如上电、下电）：使用 sequence_tick（时序专用脉冲），适配通用计时需求

// Clear counter - generates a 1us pulse on entry to new state
always @(posedge clk or posedge reset) begin
  if (reset)
    power_seq_sm_last <= power_seq_sm_fb;//`SM_RESET_STATE; 
  else if (t1us)
    power_seq_sm_last <= power_seq_sm; //存储上一周期的状态机状态（由 t1us 脉冲同步更新，确保周期稳定）
end

assign wdt_counter_clr = (power_seq_sm_last != power_seq_sm);//当 “当前状态（power_seq_sm）≠ 上一状态（power_seq_sm_last）” 时，产生清零信号，复位看门狗计数器
//每次进入新状态时，看门狗计数器重新开始计时，确保每个状态的超时检测独立（如从 “PSU 使能” 进入 “电源组 C 使能”，计数器清零，重新计时电源组 C 的超时）

// Counter
always @(posedge clk or posedge reset) begin
  if (reset)
    wdt_counter <= {WDT_NBITS{1'b0}};// 复位时清零（用位宽拼接，适配任意WDT_NBITS）
  else if (wdt_counter_clr)
    wdt_counter <= {WDT_NBITS{1'b0}};// 状态切换时清零
  else if (wdt_tick)
    wdt_counter <= wdt_counter + 1'b1;// 收到tick脉冲时计数+1
end
//带复位和清零的时序计数器：复位或状态切换时清零，收到 wdt_tick 时累加计数，计数范围由 WDT_NBITS 决定（如 WDT_NBITS=10 时，计数范围 0~1023）

// Timeout flags  超时标志生成
// - Used for waiting on power-up/down sequence states
always @(posedge clk or posedge reset) begin
  if (reset) begin
        grp_a_pwrok_timeout               <= 1'b0;
        grp_b_pwrok_timeout               <= 1'b0;
        pon_watchdog_timeout             <= 1'b0;
        psu_watchdog_timeout             <= 1'b0;
        efuse_watchdog_timeout         <= 1'b0;
    //    vcore_watchdog_timeout      <= 1'b0;
        pon_65ms_watchdog_timeout   <= 1'b0;
        pdn_watchdog_timeout             <= 1'b0;
    //    disable_intel_vccin_timeout <= 1'b0;
        disable_3v3_timeout               <= 1'b0;
        rsmrst_release_timeout         <= 1'b0;
        dispg_watchdog_timeout         <= 1'b0;
  end
  else if (wdt_counter_clr) begin         // 状态切换时，清零所有超时标志（新状态重新计时）
        grp_a_pwrok_timeout               <= 1'b0;
        grp_b_pwrok_timeout               <= 1'b0;
        pon_watchdog_timeout             <= 1'b0;
        psu_watchdog_timeout             <= 1'b0;
        efuse_watchdog_timeout         <= 1'b0;
    //    vcore_watchdog_timeout      <= 1'b0;
        pon_65ms_watchdog_timeout   <= 1'b0;
        pdn_watchdog_timeout             <= 1'b0;
    //    disable_intel_vccin_timeout <= 1'b0;
        disable_3v3_timeout               <= 1'b0;
        rsmrst_release_timeout         <= 1'b0;
        dispg_watchdog_timeout         <= 1'b0;
  end
  else if (wdt_tick) begin
    if (wdt_counter == GRP_A_PWROK_TIMEOUT_VAL) // 电源组A就绪超时：计数器达到GRP_A_PWROK_TIMEOUT_VAL时置1
      grp_a_pwrok_timeout <= 1'b1;

    if (wdt_counter == GRP_B_PWROK_TIMEOUT_VAL) // 电源组B就绪超时：计数器达到GRP_B_PWROK_TIMEOUT_VAL时置1
      grp_b_pwrok_timeout <= 1'b1;

    if (wdt_counter == PON_WATCHDOG_TIMEOUT_VAL) 
      pon_watchdog_timeout <= 1'b1;

    if (wdt_counter == PSU_WATCHDOG_TIMEOUT_VAL)// PSU超时：计数器达到PSU_WATCHDOG_TIMEOUT_VAL时置1
      psu_watchdog_timeout <= 1'b1;

    if (wdt_counter == EFUSE_WATCHDOG_TIMEOUT_VAL)
      efuse_watchdog_timeout <= 1'b1;

//    if (wdt_counter == VCORE_WATCHDOG_TIMEOUT_VAL)
//      vcore_watchdog_timeout <= 1'b1;

    if (wdt_counter == PON_65MS_WATCHDOG_TIMEOUT_VAL)
      pon_65ms_watchdog_timeout <= 1'b1;
	  
    if ( wdt_counter == RSMRST_REALSE_TIMEOUT_VAL)
      rsmrst_release_timeout <= 1'b1;

    if (((wdt_counter == PDN_WATCHDOG_TIMEOUT_VAL)       && !fault_power) ||
        ((wdt_counter == PDN_WATCHDOG_TIMEOUT_FAULT_VAL) &&  fault_power))// 下电超时标志：区分“正常下电”和“故障下电”，使用不同超时阈值
      pdn_watchdog_timeout <= 1'b1;
    if (wdt_counter == DISPG_WATCHDOG_TIMEOUT_VAL) // 显示模块超时标志：计数器达到显示模块超时阈值时置1
      dispg_watchdog_timeout <= 1'b1;

//    if (((wdt_counter == DISABLE_INTEL_VCCIN_TIMEOUT_VAL)       && !fault_power) ||
//        ((wdt_counter == DISABLE_INTEL_VCCIN_TIMEOUT_FAULT_VAL) &&  fault_power))
//      disable_intel_vccin_timeout <= 1'b1;

    if (((wdt_counter == DISABLE_3V3_TIMEOUT_VAL)       && !fault_power) ||
        ((wdt_counter == DISABLE_3V3_TIMEOUT_FAULT_VAL) &&  fault_power))// 3.3V电源禁用超时：正常下电用默认阈值，故障下电用更短阈值（快速断电）
      disable_3v3_timeout <= 1'b1;
  end
end

//&&（逻辑与）优先级高于 ||（逻辑或），因此先判断 “计数器值 + 故障状态” 的组合条件，再进行场景间的或运算

// Complete flags等待完成标志逻辑
// - Used for holding off actions form occurring until enough time has passed
//等待完成标志与超时标志的区别：超时标志用于 “检测异常”（超时则触发故障），等待完成标志用于 “确认正常”（达到阈值则允许下一步动作）
always @(posedge clk or posedge reset) begin
  if (reset) begin
    dc_on_wait_complete         <= 1'b0;    // 直流上电等待完成
    po_on_wait_complete         <= 1'b0;    // 上电完成等待
    s5_devices_on_wait_complete <= 1'b0;    // S5设备上电等待完成
  end
  else if (t1us) begin// 每1us同步更新，避免高频抖动
    if (!off_state || interlock_broken) begin   // 非关机状态或联锁故障时，清零所有等待标志（流程中断）
      dc_on_wait_complete                 <= 1'b0;
      po_on_wait_complete                 <= 1'b0;
      s5_devices_on_wait_complete <= 1'b0;
    end
    else begin
      if (((wdt_counter == DC_ON_WAIT_COMPLETE_NOFLT_VAL) && !fault_power) ||
          ((wdt_counter == DC_ON_WAIT_COMPLETE_FAULT_VAL) &&  fault_power))   // 直流上电等待完成：正常/故障场景用不同阈值
        dc_on_wait_complete <= 1'b1;    //直流电源（如 12V 主电）上电后，等待足够时间确保电压稳定，再允许后续电源组（如 3.3V）使能

      if (wdt_counter == PO_ON_WAIT_COMPLETE_VAL)   // 上电完成等待：仅用固定阈值（上电流程时序固定）
        po_on_wait_complete <= 1'b1;    //整体上电流程完成后，等待固定时间（如 1 个计数周期），确认无瞬时故障后进入稳定状态

      if (((wdt_counter == S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL) && !fault_power) ||
          ((wdt_counter == S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL) &&  fault_power)) // S5设备上电等待完成：正常/故障场景用不同阈值
        s5_devices_on_wait_complete <= 1'b1;  //S5 状态（软关机）下的设备（如 BMC、传感器）上电后，等待其初始化完成
    end
  end
end

// pf_on_wait_complete is separated from above since it needs to also assert
// during interlock_broken case. 电源故障恢复等待标志
always @(posedge clk or posedge reset) begin
  if (reset)
    pf_on_wait_complete <= 1'b0;// 电源故障恢复等待完成
  else if (t1us && !off_state)
    pf_on_wait_complete <= 1'b0;// 非关机状态时清零（流程不相关）
  else if (t1us && (wdt_counter == PF_ON_WAIT_COMPLETE_VAL))
    pf_on_wait_complete <= 1'b1;// 达到故障恢复等待阈值时置1
end
//pf_on_wait_complete：电源故障恢复（如 PSU 重启）后，等待足够时间（如 33 个计数周期）确认电源稳定，再允许重试上电

//------------------------------------------------------------------------------
// turn_system_on  系统上电使能逻辑
// - Asserts when system is requested to turn on and have satisfied all
//   required conditions for turn on.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    turn_system_on <= 1'b0;// 系统上电使能标志（初始禁用）
  else if (t1us)
    turn_system_on <= (xr_ps_en | ~pwron_override_n | turn_system_on)   &  //default 1 allowed to turn on // 上电请求条件
                                      pch_slp4_n                                        &  // SB in S0 state // 南桥状态条件
                                      ~interlock_broken                          &  //default 1 nothing is broken  // 硬件安全条件
                                      ~aux_video_holdoff;                          //default 1 // 外设就绪条件
end
//turn_system_on 是系统上电的 “总使能开关”，仅当所有条件满足时才置 1，触发上电流程。各条件含义如下
//xr_ps_en	X 寄存器使能（软件允许上电，如 BMC 下发的上电指令）
//~pwron_override_n	上电强制覆盖（硬件强制上电，如测试模式下的强制触发，低有效信号取反后为高）
//turn_system_on	自保持条件（一旦置 1，即使单次请求信号消失，仍保持使能，确保上电流程不中断）
//pch_slp4_n	南桥非 S4 睡眠状态（pch_slp4_n=1 表示南桥处于 S0/S5 状态，支持上电）
//~interlock_broken	无联锁故障（interlock_broken=0 表示硬件联锁正常，如柜门关闭、安全开关闭合）
//~aux_video_holdoff	无辅助视频延迟（aux_video_holdoff=0 表示显示模块就绪，无需延迟上电）





// 1. 按钮防抖逻辑（lowpass_filter模块）
// 物理按钮按下 / 松开时会有机械抖动（通常 10~20ms），直接采样会导致误判，模块通过 3 级低通滤波（lowpass_filter）消除抖动：

// 滤波后按钮信号：存储3路按钮（物理/ BMC/ DBP）经防抖滤波后的稳定信号
wire w_PWR_BTN_Filter;    // 物理按钮（ i_FP_PWR_BTN_MUX_N ）滤波后信号

lowpass_filter #
(
    .TOTAL_STAGES           ( 3 ),// 3级滤波（需连续3次采样一致才确认状态）
    .INIT_VALUE             (1'b1)// 初始值为1（按钮未按下时为高电平）
)PwrBtn_Filter
(
    .i_clk                  ( clk                 ),
    .i_rst_n                ( reset               ),
    .i_filter_en            ( i_20mSEC            ),// 20ms使能（每20ms采样一次）
    .i_data_in              ( ~p0_pwrbtn_n        ),// 原始按钮信号
    .o_data_out             ( w_PWR_BTN_Filter    )
);


// 物理按钮信号两级延时：用于边沿检测（消除毛刺，稳定捕捉边沿）
reg r_pwr_btn_dly1, r_pwr_btn_dly2; // 两级延时寄存器
wire w_pwr_btn_neg, w_pwr_btn_pos;   // 物理按钮的下降沿（按下）/上升沿（松开）检测信号

always@(posedge clk or negedge reset) 
begin
	if(!reset)  // 复位状态：两级延时寄存器均置1（对应按钮未按下时的高电平）
	begin
		r_pwr_btn_dly1  <= 1'b1;  // 1级延时（当前周期的滤波后信号）
		r_pwr_btn_dly2  <= 1'b1;  // 2级延时（上一周期的滤波后信号）
	end
	else  // 正常工作：每时钟周期更新延时寄存器（移位操作）
    begin
        r_pwr_btn_dly1 <= w_PWR_BTN_Filter;    // 1级延时 = 当前滤波后信号
        r_pwr_btn_dly2 <= r_pwr_btn_dly1 ;     // 2级延时 = 上一周期的1级延时信号
    end
end

// 下降沿检测（按钮按下）：上一周期为高（r_pwr_btn_dly2=1），当前周期为低（r_pwr_btn_dly1=0）
assign w_pwr_btn_neg = (!r_pwr_btn_dly1) && (r_pwr_btn_dly2) ;
// 上升沿检测（按钮松开）：上一周期为低（r_pwr_btn_dly2=0），当前周期为高（r_pwr_btn_dly1=1）
assign w_pwr_btn_pos = r_pwr_btn_dly1 && (!r_pwr_btn_dly2) ;


//=long/short press====================================================================================================
reg r_Pwrbtn_short ;
reg r_Pwrbtn_long  ;

reg [7:0] r_cnt_pwr_btn;

reg [7:0] r_cnt_100ms;
reg       r_clk_100ms;

//2. 长 / 短按判断逻辑（基于PWRBTN_LONG）

// 1. 100ms时钟生成（5个20ms周期=100ms）
always@(posedge clk or negedge reset) 
begin
    if(!reset) 
    begin
        r_cnt_100ms <= 8'd0;
	      r_clk_100ms <= 1'b0;
    end
	else 
	begin
        if(r_cnt_100ms==8'd5)
            r_cnt_100ms <= 8'd0;
		else if(i_20mSEC)
			r_cnt_100ms <= r_cnt_100ms+8'd1;
		else
			r_cnt_100ms <= r_cnt_100ms;
		
		if(r_cnt_100ms==8'd5)// 每100ms输出一个脉冲
			r_clk_100ms <= 1'b1;
		else
			r_clk_100ms <= 1'b0;
	end
end

// 时钟周期	w_PWR_BTN_Filter（当前信号）	r_pwr_btn_dly1（1 级延时）	r_pwr_btn_dly2（2 级延时）	w_pwr_btn_neg（下降沿）	 动作解读
// 1	             1（未按下）	                    1	                         1	                   0	              无动作
// 2	             0（按下）	                        0	                         1	                   1（高脉冲）	       按钮按下
// 3	             0（保持按下）	                    0	                         0	                   0	               无动作

// 2. 按键计数与长/短按判断
always@(posedge clk or negedge reset) 
begin
	if(!reset) 
	begin
		r_cnt_pwr_btn  <= 8'h00;    // 按键计数寄存器
		r_Pwrbtn_short <= 1'b0;     // 短按标志
		r_Pwrbtn_long  <= 1'b0;     // 长按标志
	end
	else begin
		// 按键松开时（下降沿），计数清零
		if(w_pwr_btn_neg) 					          r_cnt_pwr_btn	<= 8'h00;
		// 计数达到阈值（PWRBTN_LONG×10+1），停止计数
		else if ( r_cnt_pwr_btn == (PWRBTN_LONG*10 +1))  r_cnt_pwr_btn	<= r_cnt_pwr_btn ;
		// 按键按下且100ms脉冲到来，计数+1
		else if ( (~w_PWR_BTN_Filter) & r_clk_100ms   )    r_cnt_pwr_btn	<= r_cnt_pwr_btn + 1'b1 ;
        else                                          r_cnt_pwr_btn	<= r_cnt_pwr_btn ;

		// 按键按下（上升沿）且BMC激活，判断长/短按
		if(w_pwr_btn_pos & (~i_BMC_active1_n  ) ) 
		begin
			// 计数≤PWRBTN_LONG×10（4×10=40 → 40×100ms=4s？此处需注意：原代码可能存在笔误，应为PWRBTN_LONG×1 → 4×100ms=400ms）
			if(r_cnt_pwr_btn<=(PWRBTN_LONG*10) )   r_Pwrbtn_short  <=1'b1;
			// 计数达到PWRBTN_LONG×10+1，判定为长按
			if(r_cnt_pwr_btn==(PWRBTN_LONG*10 +1)) r_Pwrbtn_long   <=1'b1;
		end
		else         
		begin
		    r_Pwrbtn_short <= r_Pwrbtn_short;
		    r_Pwrbtn_long  <= r_Pwrbtn_long ;		
		end
	end
end





//------------------------------------------------------------------------------
// assert_power_button, phys_power_button 电源按钮控制逻辑
// - Asserts when power button is pressed while in 'off' states unless the
//   assertion is due to force_pwrbtn_n. Mask out in this case. We don't want
//   that asserted due to pwrseq forcing power button assertion.
// - Remains asserted until we hit `SM_CRITICAL_FAIL or the start of power-on.
// - phys_power_button only asserts on sys_sw_in_n assertion alone.
//------------------------------------------------------------------------------
// edge_detect #(.SIGCNT(2), .DEF_INIT(2'b11)) edge_detect_button_ne_inst (
  // .reset       (reset),
  // .clk         (clk),
  // .tick        (1'b1),
  // .signal_in   ({p0_pwrbtn_n,    sys_sw_in_n}),
  // .detect_pe   (),
  // .detect_ne   ({p0_pwrbtn_n_ne, sys_sw_in_n_ne}),
  // .detect_any  ()
// );
//电源按钮是 “用户操作” 与 “系统控制” 的交互核心，分为物理按钮检测和强制按钮驱动两部分

// 南桥电源按钮（p0_pwrbtn_n）的下降沿检测（按钮按下时信号从1变0）
Edge_Detect Edge_Detect_U1(    
    .i_clk               (clk),        
    .i_rst_n             (reset),       
    .i_signal            (p0_pwrbtn_n),// 输入：南桥电源按钮信号
    
    .o_signal_pos        (),// 输出：上升沿（未使用）
    .o_signal_neg        (p0_pwrbtn_n_ne),// 输出：下降沿（按钮按下）
    .o_signal_invert     () // 输出：信号反相（未使用）
);
// 物理电源按钮（sys_sw_in_n）的下降沿检测
Edge_Detect Edge_Detect_U2(    
    .i_clk               (clk),        
    .i_rst_n             (reset),       
    .i_signal            (sys_sw_in_n),// 输入：物理电源按钮信号
    
    .o_signal_pos        (),
    .o_signal_neg        (sys_sw_in_n_ne),// 输出：下降沿（按钮按下）
    .o_signal_invert     ()
);
//Edge_Detect 模块：通用边沿检测模块，检测输入信号的上升沿 / 下降沿，输出单周期脉冲（如 p0_pwrbtn_n_ne=1 表示南桥电源按钮被按下


//按钮触发标志（assert_power_button/assert_physical_button）
// 南桥电源按钮触发标志：标记“南桥按钮被按下”事件
always @(posedge clk or posedge reset) begin
  if (reset)
    assert_power_button <= 1'b0;
  else if (assert_button_clr || ~force_pwrbtn_n)
    assert_power_button <= 1'b0;  // 清零条件：手动清零或强制按钮禁用
  else if (p0_pwrbtn_n_ne && off_state)
    assert_power_button <= 1'b1;  // 置位条件：南桥按钮下降沿 + 关机状态
end
//assert_power_button：仅在 off_state（关机状态）下，检测到南桥按钮按下（p0_pwrbtn_n_ne）时置 1，标记 “请求上电” 事件

// 物理电源按钮触发标志：标记“用户手动按下物理按钮”事件
always @(posedge clk or posedge reset) begin
  if (reset)
    assert_physical_button <= 1'b0;
  else if (assert_button_clr)
    assert_physical_button <= 1'b0;// 手动清零
  else if (sys_sw_in_n_ne && st_halt_power_cycle)// 置位条件：物理按钮下降沿 + 暂停电源循环状态
    assert_physical_button <= 1'b1;
end
//仅在 st_halt_power_cycle（暂停电源循环，如故障重试前）下，检测到物理按钮按下（sys_sw_in_n_ne）时置 1，标记 “用户请求恢复” 事件

//------------------------------------------------------------------------------
// force_pwrbtn_n  强制按钮驱动
// - Asserts low when power sequencer needs to toggle SB power button input.
// - Note the differet behavior between BL and non-BL platform
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    force_pwrbtn_n <= 1'b1; // 强制南桥按钮信号（初始高电平，未强制）
  else if (t1us) begin
    // Forces SB power button assertion when any of the following:
    // 1. (Any)   Power fault and waiting for pf_on_wait_complete. Asserts for 8s.
    // 2. (BL/BT) Software request to turn E-fuse back on.
    //            CHECKME: Is this a request to turn-on? Shouldn't this be
    //            po_on_wait_complete as using pf_on_wait_complete will assert the
    //            signal for 8s.
    // 3. (BL)    Power fault and waiting for pf_on_wait_complete. Asserts for 8s.
    // 4. (Any)   Power fault and SB in S5 and power button is asserted. This is a
    //            request to turn on. po_on_wait_complete is masked in BL/BT.
    // 5. (BL/BT) This is a hold term. Keep asserted for 250ms and while SB is in S5.
    // 6. (BL)    In SM_MISS_TURNON state and either pf_on_wait_complete is not
    //            done or SB is still in S0 state. This term is forcing SB to S5.
    // 7. (BL)    In SM_MISS_TURNON and now allowed to turn on (xr_ps_en asserts)
    //            causing f_btn_sr to start shifting. Asserts for 250ms as f_btn_sr
    //            is shifted only every 250ms.

    // 1. 暂停电源循环状态 + 故障 + 未完成故障恢复等待：强制按钮低（触发下电）
    // 2. 待机状态 + 故障 + 上电完成等待 + 按钮触发 + 南桥非S4：强制按钮低（重试上电）
    force_pwrbtn_n <=~((st_halt_power_cycle   &  fault_power& ~pf_on_wait_complete)|  // /
                                         (st_off_standby & fault_power & (po_on_wait_complete) & assert_power_button  & ~pch_slp4_n));                        // /
  end
end
//force_pwrbtn_n：直接驱动南桥的 PWRBTN# 信号（低有效），用于 “软件强制触发按钮动作”（无需用户手动按下）：
//场景 1（故障下电）：st_halt_power_cycle（暂停循环）+ fault_power（故障）+ ~pf_on_wait_complete（未完成恢复等待）→ 强制按钮低，触发南桥下电；
//场景 2（故障重试上电）：st_off_standby（待机）+ fault_power（故障）+ po_on_wait_complete（上电等待完成）+ assert_power_button（按钮触发）+ ~pch_slp4_n（南桥非 S4）→ 强制按钮低，触发重试上电

//------------------------------------------------------------------------------
// turn_on_wait 上电等待标志 是上电流程的 “进行中” 标志，用于标记系统已触发上电但尚未完成
// - Asserts when system has been triggered to turn on and keep asserted until
//   `SM_STEADY_PWROK or `SM_CRITICAL_FAIL is reached.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    turn_on_wait <= 1'b0;
  else if (t1us)
    turn_on_wait <= (st_off_standby & turn_system_on)               |                 // 触发条件1：待机状态+上电使能
                                  (assert_power_button)             |                 // 触发条件2：按钮触发上电请求
                                  (turn_on_wait & ~(st_steady_pwrok | st_critical_fail));// 保持条件
end
//触发条件：
//1.st_off_standby & turn_system_on：系统处于 S5 待机状态（st_off_standby=1）且上电总使能（turn_system_on=1），触发上电；
//2.assert_power_button：南桥电源按钮被触发（assert_power_button=1），触发上电；
//保持条件：一旦置 1，将持续保持，直到进入 st_steady_pwrok（S0 电源稳定）或 st_critical_fail（关键故障），此时通过 ~(st_steady_pwrok | st_critical_fail) 清零。

//------------------------------------------------------------------------------
// cpld_latch_sys_off 系统关机锁存标志
// - Asserts when in `SM_HALT_POWER_CYCLE and we've reached the max number of
//   retry attempt. Aux power cycle is required.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    cpld_latch_sys_off <= 1'b0;// 系统关机锁存标志（初始未锁存）
  else
    cpld_latch_sys_off <= st_halt_power_cycle & lim_recov_retry_max;// 锁存条件
end
//cpld_latch_sys_off 是不可恢复故障的 “关机锁存” 标志，用于标记系统需人工干预才能恢复，锁存条件：
//st_halt_power_cycle=1：系统处于 “暂停电源循环” 状态（故障后暂停上电流程）；
//lim_recov_retry_max=1：有限恢复重试次数达到最大值（如 LIM_RECOV_MAX_RETRY_ATTEMPT=2，重试 2 次后仍失败）。

//------------------------------------------------------------------------------
// stby, poweron and runtime fault flags  待机故障标志（ stby_failure_detected ）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    stby_failure_detected <= 1'b0;// 待机故障标志（初始无故障）
  else if (t1us && stby_failure_detected_clr)
    stby_failure_detected <= 1'b0;// 清零：收到待机故障清零信号
  else if (t1us && stby_failure_detected_set)
    stby_failure_detected <= 1'b1;// 置位：收到待机故障置位信号
end

//------------------------------------------------------------------------------
// 上电故障标志（po_failure_detected）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    po_failure_detected <= 1'b0;
  else if (t1us && po_failure_detected_clr)
    po_failure_detected <= 1'b0;// 清零：收到上电故障清零信号
  else if (t1us && po_failure_detected_set)
    po_failure_detected <= 1'b1;// 置位：收到上电故障置位信号
end

//------------------------------------------------------------------------------
// 运行时故障标志（rt_failure_detected）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    rt_failure_detected <= 1'b0;
  else if (t1us && rt_failure_detected_clr)
    rt_failure_detected <= 1'b0;// 清零：收到运行时故障清零信号
  else if (t1us && rt_failure_detected_set)
    rt_failure_detected <= 1'b1;// 置位：收到运行时故障置位信号
end
//标记 “运行阶段”（S0 状态）的故障（如 CPU 热跳变、PSU 掉电）；
//运行时故障通常需紧急下电，因此该标志会触发 rt_critical_fail_check（运行时关键故障检测）

//------------------------------------------------------------------------------
// 总电源故障标志（fault_power）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    fault_power <= 1'b0;
  else if (t1us)
    fault_power <= stby_failure_detected | po_failure_detected | rt_failure_detected;// 总故障逻辑
end
//汇总三类故障标志，fault_power=1 表示系统存在任何电源相关故障；
//作为全局故障信号，用于触发下电流程、调整超时阈值（如故障下电用更短阈值）

//------------------------------------------------------------------------------
// Limited-recovery logic 有限恢复逻辑 针对 “可重试故障”（如瞬时电源波动），实现自动重试恢复
//------------------------------------------------------------------------------

//恢复就绪标志（ready_for_recov）
always @(posedge clk or posedge reset) begin
  if (reset)
    ready_for_recov <= 1'b0;
  else if (t1us && ready_for_recov_clr)
    ready_for_recov <= 1'b0;
  else if (t1us && ready_for_recov_set)
    ready_for_recov <= 1'b1;//由外部检测逻辑生成 ready_for_recov_set（故障解除）和 ready_for_recov_clr（开始恢复）信号
end

//重试计数器（lim_recov_retry_count）
always @(posedge clk or posedge reset) begin
  if (reset)
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}};// 重试计数器（初始0）
  else if (t1us && lim_recov_retry_clr)
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}};// 清零：恢复成功或重启后清零
  else if (t1us && lim_recov_retry_incr)
    lim_recov_retry_count <= lim_recov_retry_count + 1'b1;// 计数：每次重试失败后加1
end

assign lim_recov_retry_max = (lim_recov_retry_count == LIM_RECOV_MAX_RETRY_ATTEMPT);// 重试达最大值标志
//lim_recov_retry_count：记录故障后的重试次数（位宽由 LIM_RECOV_RETRY_NBITS 自动计算）；
//lim_recov_retry_max：当重试次数达到 LIM_RECOV_MAX_RETRY_ATTEMPT（如 2 次）时置 1，触发 cpld_latch_sys_off 锁存关机

//------------------------------------------------------------------------------
// Generate a 1ms delayed version of pch_thermtrip_n when in `SM_STEADY_PWROK.
// This is used to trigger a power-down.
//------------------------------------------------------------------------------
/*
edge_delay #(
  .CNTR_NBITS    (2)
) sb_thermtrip_delay_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b11),
  .cnt_step      (t512us),
  .signal_in     (~pch_thermtrip_n & st_steady_pwrok),
  .delay_output  (pch_thermtrip_n_delay)
);
*/

// pch S4睡眠信号延迟：用于运行时下电防抖
edge_delay #(
  .CNTR_NBITS    (2)  // 计数器位宽：2位
) sb_pch_slp4_delay_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),  // 延迟计数阈值：2个512us（总延迟1.024ms）
  .cnt_step      (t512us),  // 计数步长：512us
  .signal_in     (~pch_slp4_n & st_steady_pwrok),  // 输入：南桥S4信号（低有效）+运行状态
  .delay_output  (pch_slp4_n_delay)  // 输出：延迟后的S4信号
);
//edge_delay 模块：通用信号延迟模块，通过 “计数器 + 阈值比较” 实现信号防抖（避免瞬时噪声导致误触发）；
//南桥 S4 信号延迟（pch_slp4_n_delay）：
//输入 ~pch_slp4_n：南桥 S4 睡眠信号（低有效）取反，转为高有效逻辑；
//延迟计算：cnt_step=t512us（每 512us 计数一次），cnt_size=2'b10（计数 2 次），总延迟约 1ms；
//作用：确保南桥确实进入 S4 状态（非瞬时噪声），再触发运行时下电流程

//------------------------------------------------------------------------------
// fault_clear 故障清零逻辑
// - Clears any outstanding faults on AUX_FAIL_RECOVERY state or during the
//   start of power on sequence.
// - Registered fault_clear to ease out timing since that drives all fault_detectB
//   instances in this module. The extra clock is here is acceptable since SM
//   changes state only every 1us.
//------------------------------------------------------------------------------

// 故障清零信号（寄存器输出，时序优化）
always @(posedge clk or posedge reset) begin
  if (reset)
    fault_clear <= 1'b0;
  else
    fault_clear <= fault_clear_ns;// 次态赋值：由组合逻辑生成fault_clear_ns
end

// CMU故障清零信号（异步复位）
always @(posedge cmu_fault_clear_rst or posedge fault_clear_ns) begin
  if (cmu_fault_clear_rst)
    cmu_fault_clear <= 1'b0;// CMU故障清零（初始未清零）
  else
    cmu_fault_clear <= 1'b1;// 故障清零次态置位时，CMU故障清零
end
//fault_clear ：全局故障清零信号，用于清除所有故障标志（stby/po/rt_failure_detected），触发条件由组合逻辑 fault_clear_ns 决定（如进入 “辅助故障恢复” 状态 `SM_AUX_FAIL_RECOVERY 或上电流程开始）；
//cmu_fault_clear ：针对 CMU（时钟管理单元）的专用故障清零信号，由 cmu_fault_clear_rst（CMU 复位）和 fault_clear_ns（全局故障清零）控制

//------------------------------------------------------------------------------
// state transition logic 状态切换使能逻辑
// - These signals are used by SM to steer state transition. The logic are
//   too big to put in the SM block so an intermediate variable is used.
//------------------------------------------------------------------------------
// Asserts when SM is ready to move to the next VRD enablement
//状态切换使能是电源时序状态机的 “准入控制”，分为 “正常切换使能” 和 “故障切换使能”，确保只有满足条件时才允许状态机跳转，避免异常流程
always @(posedge clk or posedge reset) begin
  if (reset) begin
    grp_a_state_trans_en  <= 1'b0;  // 电源组A切换使能（初始禁用）
    grp_b_state_trans_en  <= 1'b0;  // 电源组B切换使能（初始禁用）
    pwrup_state_trans_en  <= 1'b0;  // 上电流程切换使能（初始禁用）
    rsmrst_release_trans_en  <= 1'b0;  // RSMRST释放切换使能（初始禁用）
  end
  else begin
    grp_a_state_trans_en    <= grp_a_pwrok_timeout    & pgd_so_far;// 电源组A切换使能：A组就绪超时 + 累计电源就绪（pgd_so_far=1）
    grp_b_state_trans_en    <= grp_b_pwrok_timeout    & pgd_so_far;// 电源组B切换使能：B组就绪超时 + 累计电源就绪
    pwrup_state_trans_en    <= pon_watchdog_timeout   & pgd_so_far;// 上电流程切换使能：上电超时 + 累计电源就绪
	  rsmrst_release_trans_en <= rsmrst_release_timeout   & pgd_so_far;// RSMRST释放切换使能：RSMRST释放超时 + 累计电源就绪
  end
end
//“超时 + 就绪” 双重校验：仅当 “当前电源组达到稳定等待时间”（超时标志）且 “历史电源组均正常”（pgd_so_far）时，才允许进入下一状态，避免带故障跳转

// Registered to ease timing 故障状态切换使能（触发故障跳转）
always @(posedge clk or posedge reset) begin
  if (reset) begin
    grp_a_critical_fail_en       <= 1'b0;  // 电源组A关键故障使能
    grp_b_critical_fail_en       <= 1'b0;  // 电源组B关键故障使能
    pwron_critical_fail_en       <= 1'b0;  // 上电关键故障使能
    psu_critical_fail_en         <= 1'b0;  // PSU关键故障使能
    efuse_critical_fail_en       <= 1'b0;  // eFuse关键故障使能
    // vcore_critical_fail_en    <= 1'b0;  // （预留）核心电压关键故障使能
    wait_steady_pwrok_fail_en <= 1'b0;  // 等待电源稳定故障使能
    rsmrst_release_fail_en       <= 1'b0;  // RSMRST释放故障使能
  end
  else if (keep_alive_on_fault) begin       // 故障保活模式：故障时仍需保持电源，禁用所有故障使能
        grp_a_critical_fail_en       <= 1'b0;
        grp_b_critical_fail_en       <= 1'b0;
        pwron_critical_fail_en       <= 1'b0;
        psu_critical_fail_en           <= 1'b0;
        efuse_critical_fail_en       <= 1'b0;
    //    vcore_critical_fail_en    <= 1'b0;
        wait_steady_pwrok_fail_en <= 1'b0;
        rsmrst_release_fail_en	   <= 1'b0;
  end
  // 正常故障检测模式：满足故障条件时置能，触发状态机跳转到故障状态
  else begin
        grp_a_critical_fail_en       <= (grp_a_pwrok_timeout          & ~pgd_so_far) | any_pwr_fault_det;// 电源组A故障：A组超时但累计电源未就绪（超时异常） OR 任何电源故障
        grp_b_critical_fail_en       <= (grp_b_pwrok_timeout          & ~pgd_so_far) | any_pwr_fault_det;// 电源组B故障：B组超时但累计电源未就绪 OR 任何电源故障
        pwron_critical_fail_en       <= (pon_watchdog_timeout         & ~pgd_so_far) | any_pwr_fault_det;// 上电故障：上电超时但累计电源未就绪 OR 任何电源故障
        psu_critical_fail_en         <= (psu_watchdog_timeout         & ~pgd_so_far) | any_pwr_fault_det;// PSU故障：PSU超时但累计电源未就绪 OR 任何电源故障
        efuse_critical_fail_en       <= (efuse_watchdog_timeout       & ~pgd_so_far) | any_pwr_fault_det;// eFuse故障：eFuse超时但累计电源未就绪 OR 任何电源故障
    //  vcore_critical_fail_en    <= (vcore_watchdog_timeout     & ~pgd_so_far) | any_pwr_fault_det;
        wait_steady_pwrok_fail_en    <= (pon_65ms_watchdog_timeout    & ~pgd_so_far) | any_pwr_fault_det;// 等待电源稳定故障：65ms超时但累计电源未就绪 OR 任何电源故障
        rsmrst_release_fail_en	     <= (rsmrst_release_timeout	      & ~pgd_so_far) | any_pwr_fault_det;// RSMRST释放故障：RSMRST释放超时但累计电源未就绪 OR 任何电源故障
  end
end

// On fault during runtime, assert flag for the duration of SM_STEADY_OK until
// FSM transitions to `SM_CRITICAL_FAIL. Flag deasserts on entry to `SM_CRITICAL_FAIL.
//运行时故障处理（Runtime Fault Handling） 运行时（S0 状态）故障需快速响应，避免硬件损坏，此处通过 “故障检测 - 锁存 - 触发下电” 实现闭环控制
// 运行时关键故障检测：故障且非保活模式 OR 联锁故障
assign rt_critical_fail_check = (any_pwr_fault_det & ~keep_alive_on_fault) | interlock_broken;

// 运行时故障锁存：锁存故障直到进入关键故障状态
always @(posedge clk or posedge reset) begin
  if (reset)
    rt_critical_fail_store <= 1'b0;
  else
    rt_critical_fail_store <= ( st_steady_pwrok  & rt_critical_fail_check) |  // 触发：运行状态+故障检测
                              (~st_critical_fail & rt_critical_fail_store);   // 保持：未进入关键故障则锁存
end
//rt_critical_fail_check： 实时检测运行时故障，包含两类场景：
//1.电源故障且非保活模式（ any_pwr_fault_det & ~ keep_alive_on_fault ）；
//2.硬件联锁故障（ interlock_broken ，如柜门打开、安全开关断开）；
//rt_critical_fail_store：锁存故障状态，一旦在运行时（st_steady_pwrok=1）检测到故障，将持续锁存，直到状态机进入 SM_CRITICAL_FAIL（关键故障）才释放

// Shutdown events 下电事件触发
//下电事件按 “触发原因” 分类，分为 “正常下电” 和 “热跳变紧急下电”，确保不同场景下的下电流程有序执行
//assign rt_normal_pwr_down    = ~pgood_rst_mask &(~turn_system_on | ( pch_thermtrip_n_delay & pch_slp4_n));

// 当前正常下电逻辑：电源就绪复位掩码解除 + 南桥S4延迟信号（确认进入S4状态）
assign rt_normal_pwr_down    = ~pgood_rst_mask &  pch_slp4_n_delay	 ;
// 热跳变紧急下电逻辑：电源就绪复位掩码解除 + 南桥热跳变信号 + 运行状态
assign rt_thermtrip_pwr_down = ~pgood_rst_mask &  pch_thermtrip_n & st_steady_pwrok	 ;
//pgood_rst_mask ：电源就绪复位掩码（ pgood_rst_mask=1 时屏蔽下电，用于上电初期电源未稳定阶段）；
//pch_slp4_n_delay ：南桥 S4 睡眠信号延迟（防抖后的值，确保南桥确实进入 S4 状态，避免误触发下电）；
//pch_thermtrip_n ：南桥热跳变信号（低有效，表示 CPU / 南桥过温，需紧急下电

//assign rt_thermtrip_pwr_down = ~pgood_rst_mask &(~turn_system_on | (pch_thermtrip_n & pch_slp4_n_delay)); 


//addr t_thermtrip_pwr_down
//assign rt_normal_pwr_down = ~pgood_rst_mask &( ~pch_slp4_n | ~turn_system_on); 

// pgd_raw asserts on `SM_STEADY_PWROK while pgd_so_far is high and
// rt_critical_fail_check is low. If any of these two terms switches states,
// pgd_raw will immediately de-asserts.
//电源就绪原始信号（pgd_raw） pgd_raw 是系统电源就绪的核心标志，直接决定是否允许 CPU / PSU 进入工作状态，需严格确保无故障时才置位
always @(posedge clk or posedge reset) begin
  if (reset)
    pgd_raw <= 1'b0;
  else if (t1us)
    pgd_raw <= pgd_so_far & st_steady_pwrok & ~rt_critical_fail_check;// 1us同步更新：累计电源就绪 + 运行稳定状态 + 无运行时故障
  else
    pgd_raw <= pgd_so_far & pgd_raw & ~rt_critical_fail_check;// 非同步阶段：保持就绪状态，但需实时检测故障（故障立即失能）
end
//置位条件：需同时满足三个条件：
//1.pgd_so_far=1：所有已使能电源组均正常就绪；
//2.st_steady_pwrok=1：状态机进入 “电源稳定” 状态（S0）；
//3.~rt_critical_fail_check=1：无运行时故障；
//失能条件：任一条件不满足时立即失能（如突发运行时故障，pgd_raw 实时清零，触发下电）

//------------------------------------------------------------------------------
// Synchronous portion of FSM （状态机同步部分）状态机同步逻辑 状态机采用 “现态 - 次态” 同步设计，确保时序稳定，避免组合逻辑毛刺导致的状态跳变异常。
//------------------------------------------------------------------------------
// 现态寄存器：存储当前状态机状态
always @(posedge clk or posedge reset) begin
  if (reset)
    state <= `SM_RESET_STATE;//power_seq_sm_fb;//`SM_RESET_STATE;  // 复位时进入初始复位状态
  else if (t1us)
    state <= state_ns;// 每1us同步更新为次态（避免高频跳变）
end

// 'power_seq_sm' is an alias for state（power_seq_sm是state的别名，便于外部引用）
//assign power_seq_sm = state;
// 寄存器输出别名：避免组合逻辑毛刺，提升可靠性
always @(posedge clk or posedge reset) begin 
  if (reset)
      power_seq_sm <= `SM_RESET_STATE;// 复位时保持初始值
  else 
	    power_seq_sm <=state; // 同步输出当前状态，作为外部接口信号 
end
//同步更新：state（现态）仅在 t1us 脉冲时更新为 state_ns（次态），确保状态机每 1us 仅跳变一次，避免高频噪声导致的异常跳变；
//毛刺消除：power_seq_sm 采用寄存器输出（而非组合逻辑 assign），避免组合逻辑延迟导致的毛刺，确保外部模块（如电源驱动）接收的状态信号稳定；
//接口兼容性：power_seq_sm 作为状态机对外的统一接口，隐藏内部 state 寄存器细节，便于后续代码维护。

//------------------------------------------------------------------------------
// Combinatorial portion of FSM
//------------------------------------------------------------------------------
always @(*) begin
      // 1. 信号默认值：避免组合逻辑 latch（必须初始化所有输出）
      state_ns                          = state;
      assert_button_clr                 = 1'b0;
      stby_failure_detected_clr = 1'b0;
      stby_failure_detected_set = 1'b0;
      po_failure_detected_clr     = 1'b0;
      po_failure_detected_set     = 1'b0;
      rt_failure_detected_clr     = 1'b0;
      rt_failure_detected_set     = 1'b0;
      ready_for_recov_clr             = 1'b0;
      ready_for_recov_set             = 1'b0;
      lim_recov_retry_clr             = 1'b0;
      lim_recov_retry_incr           = 1'b0;
      off_state                                 = 1'b0;
      fault_clear_ns                       = 1'b0;
      rt_normal_pwr_down_flag     = 1'b0;
  case (state)
    `SM_RESET_STATE : begin       //00 复位状态
          if (power_seq_sm_fb==`SM_OFF_STANDBY && (mux_sel == 1'b0))//08    场景1：反馈状态为待机且选择默认路径，跳转到待机状态 
               state_ns = `SM_OFF_STANDBY;
          else if(power_seq_sm_fb==`SM_STEADY_PWROK && (mux_sel == 1'b0))//20   场景2：反馈状态为电源稳定且选择默认路径，直接跳转到运行稳定状态
               state_ns = `SM_STEADY_PWROK;
          else begin  // 场景3：默认路径，跳转到电源组A使能，同时清零所有故障标志
               state_ns = `SM_EN_GRP_A;
               stby_failure_detected_clr = 1'b1;// 清零待机故障
               po_failure_detected_clr   = 1'b1;// 清零上电故障
               rt_failure_detected_clr   = 1'b1;// 清零运行时故障
          end
    end

    `SM_EN_GRP_A : begin          //01 电源组A使能
          // 故障优先：电源组A故障，跳故障状态
          if (grp_a_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;               //01 电源组A使能
          end 
          // 故障优先：电源组A故障，跳故障状态
          if (grp_a_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;  // 跳转到关键故障状态，终止上电
            po_failure_detected_set = 1'b1;
          end
          // 正常跳转：电源组A就绪，跳转到RSMRST禁用（下一步）
          else if (grp_a_state_trans_en) begin
            state_ns = `SM_RSMRST_DISABLE; // 跳转到RSMRST禁用状态，进入下一步
          end		  
    end
	
    `SM_RSMRST_DISABLE : begin       //0X02
          // 场景1：故障优先——检测到上电关键故障
          if (pwron_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;// 置位上电故障
          end
          // 场景2：正常流程——上电流程满足切换条件
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_GRP_B_33_S5;// 跳转到B组3.3V S5电源使能
          end 
    end

    `SM_EN_GRP_B_33_S5 : begin   //0X03
          if (grp_b_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end	
          // 场景2：正常流程——B组满足切换条件
          else if (grp_b_state_trans_en) begin
            state_ns = `SM_EN_GRP_B_18_S5;// 跳转到B组1.8V S5电源使能
          end
    end
	
    `SM_EN_GRP_B_18_S5 : begin   //0X04
          if (grp_b_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end	
          // 场景2：正常流程——B组满足切换条件
          else if (grp_b_state_trans_en) begin
            state_ns = `SM_EN_P5V_STBY;// 跳转到5V待机电源使能
          end
    end
	
    `SM_EN_P5V_STBY : begin          //0X05
          if (grp_b_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
           // 场景2：正常流程——B组满足切换条件（5V待机就绪）
          else if (grp_b_state_trans_en) begin
            state_ns = `SM_EN_RSMRST_RELEASE;// 跳转到RSMRST释放状态
          end
    end
	
    `SM_EN_RSMRST_RELEASE : begin   //0X06 RSMRST 释放
          // 场景1：故障优先——检测到RSMRST释放故障
          if (rsmrst_release_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end	
          // 场景2：正常流程——RSMRST释放满足切换条件
          else if (rsmrst_release_trans_en) begin
            state_ns = `SM_OFF_STANDBY;// 跳转到待机状态，完成上电准备
          end
    end	
	
    `SM_OFF_STANDBY : begin         //0X08 待机状态
          // 场景1：检测到电源故障且非保活模式，跳故障状态并置位待机故障
          if (any_pwr_fault_det & ~keep_alive_on_fault) begin  
            // Fault detected. Using new STBY flag for standby failure.
            state_ns = `SM_CRITICAL_FAIL;
            stby_failure_detected_set = 1'b1;
          end
           // 场景2：收到S5设备下电请求（如BMC请求关闭S5状态设备），跳转到S5设备下电
          else if (s5dev_pwrdis_request) begin
            // S5 device disable request or request to shutdown e-fuse (BL only)
            state_ns = `SM_DISABLE_S5_DEVICES;
          end
          // 场景3：收到S5设备上电请求且等待完成，跳转到S5设备上电
          else if (s5dev_pwren_request && s5_devices_on_wait_complete) begin
            // S5 device enable request
            state_ns = `SM_ENABLE_S5_DEVICES;
          end
          // 场景4：满足上电条件（上电使能+直流上电等待完成），跳转到PSU使能
          else if (turn_system_on && dc_on_wait_complete ) begin
            //add bmc_ready_out_n
            // Let's power on. Note that if miss_turn_on_window is asserted, there's
            // no need to wait for dc_on_wait_complete since we just went through
            // SM_MISS_TURNON which is long enough wait time for the next power up.
            state_ns = `SM_PS_ON;
            // Clear assert_*_button flags and set fault_clear
            assert_button_clr = 1'b1;// 清零按钮触发标志（避免重复触发）
            fault_clear_ns = 1'b1;// 清零故障（确保上电前无故障）
          end
          // This is an offstate  标记当前为“关机状态”（用于其他逻辑判断）
          off_state = 1'b1;
    end
    //SM_EN_GRP_A（A 组使能）→ SM_RSMRST_DISABLE（禁用 RSMRST）→ SM_EN_GRP_B_33_S5（B 组 3.3V S5）→ SM_EN_GRP_B_18_S5（B 组 1.8V S5）
    //→ SM_EN_P5V_STBY（5V 待机）→ SM_EN_RSMRST_RELEASE（释放 RSMRST）→ `SM_OFF_STANDBY （待机）

    `SM_ENABLE_S5_DEVICES : begin   //0X07 S5 设备使能
          // 场景1：故障处理——S5设备使能时检测到上电故障
          if (pwron_critical_fail_en) begin
            // - Fault detected while trying to turn on S5 device.
            // - Non-BL/BT, go to Disable S5 device.
             // 非BL/BT平台：跳转到S5设备禁用状态（关闭故障设备）
            state_ns = `SM_DISABLE_S5_DEVICES;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：正常流程——上电切换条件满足（S5设备使能完成）
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_OFF_STANDBY;// 跳回待机状态，等待后续主上电流程
          end
    end

    `SM_PS_ON : begin                 //09  PSU 使能
          // 场景1：PSU故障（如PSU超时未就绪），跳故障状态并置位上电故障
          if (psu_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：PSU超时（已就绪）且累计电源就绪，跳转到遥测电源使能
          else if (psu_watchdog_timeout && pgd_so_far) begin
            state_ns = `SM_EN_TELEM;
          end
    end

    `SM_EN_TELEM : begin              //10 遥测电源使能
          // - Enable telemetry rails (P3V3_PWM_CTRL and PVCC_HPMOS).
          // - BL, skipped since telemetry rails are enabled during ??
         // if (pwron_critical_fail_en) begin
          //  state_ns = `SM_CRITICAL_FAIL;
          //  po_failure_detected_set = 1'b1;
         // end
          //else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_MAIN_EFUSE; // 无条件跳转到主eFuse使能
         // end
    end

    `SM_EN_MAIN_EFUSE : begin         //11 主 eFuse 使能
          // - BL, called after SM_EN_P3V3_VCC state. Go to enabling PCH rails next.
          // - Non-BL, part of power-on sequence.

          // 场景1：故障处理——eFuse使能故障（如过流保护触发）
          if (efuse_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：正常流程——eFuse超时就绪且累计电源正常
          else if (efuse_watchdog_timeout && pgd_so_far) begin
            state_ns = `SM_EN_GRP_ATX;// 跳转到ATX电源组使能
          end
    end

    `SM_EN_GRP_ATX : begin            //12 ATX 电源组使能
          // 场景1：故障处理——ATX电源组故障
          if (pwron_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：正常流程——ATX电源组就绪
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_GRP_C;// 跳转到C组电源使能
          end
    end

    `SM_EN_GRP_C : begin              //13 C 组电源使能
          if (pwron_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：正常流程——C组电源就绪
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_GRP_D_VDDIO;// 跳转到D组VDDIO电源使能
          end
    end
	
    `SM_EN_GRP_D_VDDIO : begin              //14 D 组 VDDIO 电源使能
          if (pwron_critical_fail_en) begin
          // Skipped if no_vppen is set
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：正常流程——VDDIO电源就绪
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_GRP_D_SOC; // 跳转到D组SOC电源使能
          end
    end

    `SM_EN_GRP_D_SOC : begin             //15 D 组 SOC 电源使能
          if (pwron_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：正常流程——SOC电源就绪
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_GRP_D_VDDCORE0; // 跳转到核心电压0使能
          end
    end
	
    `SM_EN_GRP_D_VDDCORE0 : begin          //16 核心电压0使能
          // 故障优先：核心电压故障，跳故障状态
          if (pwron_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 正常跳转：核心电压0就绪，跳转到核心电压1使能
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_GRP_D_VDDCORE1;
          end
    end	

    `SM_EN_GRP_D_VDDCORE1 : begin          //17 核心电压1使能
          // 故障优先：核心电压故障，跳故障状态
          if (pwron_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 正常跳转：核心电压0就绪，跳转到电源good信号
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_EN_PGOOD_RELEASE;
          end
    end		

    `SM_EN_PGOOD_RELEASE : begin     //18 电源就绪信号释放
          if (pwron_critical_fail_en) begin
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：正常流程——电源就绪信号释放完成
          else if (pwrup_state_trans_en) begin
            state_ns = `SM_WAIT_POWEROK; // 跳转到等待电源稳定
          end
    end
    //SM_ENABLE_S5_DEVICES→`SM_PS_ON→SM_EN_TELEM→SM_EN_MAIN_EFUSE→SM_EN_GRP_ATX→SM_EN_GRP_C→SM_EN_GRP_D_VDDIO→
    //SM_EN_GRP_D_SOC→SM_EN_GRP_D_VDDCORE0→SM_EN_GRP_D_VDDCORE1→SM_EN_PGOOD_RELEASE

    `SM_WAIT_POWEROK : begin         //6'h19 等待电源稳定
          // 场景1：等待电源稳定故障（如65ms超时未稳定），跳故障状态
          if (wait_steady_pwrok_fail_en) begin //wait_steady_pwrok_fail_en：等待电源稳定故障使能（如 65ms 超时仍未稳定，判定为故障）
            state_ns = `SM_CRITICAL_FAIL;
            po_failure_detected_set = 1'b1;
          end
          // 场景2：等待超时（已稳定）且累计电源就绪，跳转到运行稳定状态
          else if (pwrup_state_trans_en && pgd_so_far) begin //pwrup_state_trans_en：上电流程切换使能（此处表示等待稳定超时，即电源已稳定）
            state_ns = `SM_STEADY_PWROK;
          end
    end

    `SM_STEADY_PWROK : begin         //6'h20
          // 场景1：运行时故障锁存且电源就绪掩码解除，跳故障状态并置位运行时故障
          if (rt_critical_fail_store && !pgood_rst_mask ) begin //rt_critical_fail_store：运行时故障锁存标志确保瞬时故障不被忽略  pgood_rst_mask：电源就绪复位掩码（1'b0 表示电源已稳定，允许下电 / 故障响应）
            state_ns = `SM_CRITICAL_FAIL;
            rt_failure_detected_set = 1'b1;   
          end
          // 场景2：热跳变下电请求（如CPU过温），跳故障状态
	        else if (rt_thermtrip_pwr_down) begin           //rt_thermtrip_pwr_down：热跳变下电请求（紧急下电，优先级最高）
            state_ns = `SM_CRITICAL_FAIL;           
          //		rt_failure_detected_set = 1'b1;
          end
          // 场景3：正常下电请求（如用户关机），跳转到电源就绪禁用
          else if (rt_normal_pwr_down || r_Pwrbtn_long) begin //rt_normal_pwr_down：正常下电请求（如南桥 S4 状态触发，优先级次高）
             state_ns = `SM_DISABLE_PWRGD;
          end
          // Clear retry counter on clean powerup 正常运行时，清零重试计数器（避免历史重试次数影响后续故障恢复）
          lim_recov_retry_clr = 1'b1;
    end

    `SM_CRITICAL_FAIL : begin        //34 关键故障状态
          state_ns = `SM_DISABLE_PWRGD;  // 故障时直接跳转到电源就绪禁用，开始下电流程
          assert_button_clr = 1'b1;// 清零按钮触发标志，避免故障时重复触发
    end  //所有故障场景的 “统一入口”，无论哪个阶段故障，均先跳到此状态，再启动下电流程；清零按钮触发标志，避免故障时按钮误操作导致流程混乱
	
    `SM_DISABLE_PWRGD: begin       //21 电源就绪信号禁用
          // 场景：电源就绪信号禁用超时（表示PGOOD已拉低，通知CPU停止工作）
          if (dispg_watchdog_timeout) begin //dispg_watchdog_timeout：电源就绪（PGOOD）禁用超时标志（PGOOD 信号从高电平拉低后，需等待固定时间确认信号稳定，避免 CPU 误判）
            state_ns = `SM_DISABLE_GRP_D_VDDCORE1;// 跳转到核心电压1禁用（下电第一步：先关核心）
          end
    end	

    `SM_DISABLE_GRP_D_VDDCORE1 : begin  //22 核心电压 1 禁用
          // 下电超时（表示当前电源组已禁用完成），跳转到下一个电源组禁用
          if (pdn_watchdog_timeout) begin // pdn_watchdog_timeout：下电超时标志（禁用指令发出后，等待固定时间确保电压降至 0，判定为禁用完成）
            state_ns = `SM_DISABLE_GRP_D_VDDCORE0;// 跳转到核心电压0禁用
          end
    end
    //逆序下电：先禁用核心电压（对时序最敏感），再禁用主电、辅助电，最后禁用 PSU，符合硬件下电时序要求，避免低压设备承受高压冲击；
    //超时确认：每个电源组禁用后等待超时，确保完全关闭后再禁用下一个，避免残留电压导致的短路风险

    `SM_DISABLE_GRP_D_VDDCORE0 : begin  //23 核心电压 0 禁用
          if (pdn_watchdog_timeout) begin
            state_ns = `SM_DISABLE_GRP_D_SOC;   // 跳转到SOC电压禁用
          end
    end

    `SM_DISABLE_GRP_D_SOC : begin        //24  SOC 电压禁用
          if (pdn_watchdog_timeout) begin
            state_ns = `SM_DISABLE_GRP_D_VDDIO; // 跳转到VDDIO电压禁用
          end 
    end

    `SM_DISABLE_GRP_D_VDDIO : begin        //25 VDDIO 电压禁用
          if (pdn_watchdog_timeout) begin
            state_ns = `SM_DISABLE_GRP_C; // 跳转到C组电源禁用
          end
    end
    //逆序逻辑：上电时先使能 VDDIO→SOC→核心电压，下电时先禁用核心电压→SOC→VDDIO，避免核心电路在低电压环境下承受高电压（如 SOC 未断电时 VDDIO 仍有电压，可能导致信号异常）。

    `SM_DISABLE_GRP_C : begin        //26 C 组电源禁用
          if (pdn_watchdog_timeout) begin
            state_ns = `SM_DISABLE_GRP_ATX; // 跳转到ATX电源组禁用
          end
    end

   `SM_DISABLE_GRP_ATX : begin       //27 ATX 电源组禁用
          if (pdn_watchdog_timeout) begin
            state_ns = `SM_DISABLE_MAIN_EFUSE; // 跳转到主eFuse禁用
          end
    end

    `SM_DISABLE_MAIN_EFUSE : begin   //28 主 eFuse 禁用
          // - BL, last one to turn off due to power fault or was forced off.
          // - Non-BL, part of pwrdn flow so go to turning off of telemetry rails.
          if (pdn_watchdog_timeout) begin
            state_ns = `SM_DISABLE_TELEM;  // 跳转到遥测电源禁用
          end
          off_state = 1'b0;  // 标记当前非关机状态（下电流程未完全结束
    end

    `SM_DISABLE_TELEM : begin        //29 遥测电源禁用
          // - BT, last pwrdn stage. Go to DISABLE_S5_DEVICES if there's any power fault.
          // - Non-BT, not last group yet.
          if (pdn_watchdog_timeout) begin
            state_ns = `SM_DISABLE_PS_ON; // 跳转到PSU禁用（主电源关闭）
          end
    end

    `SM_DISABLE_PS_ON : begin        //30 PSU 禁用
      // - BL/BT, not used
      // - Non-BL/BT, disable PSU. This is the last stage. Proceed to disable S5
      //   devices if there are any power fault
          // PSU禁用超时后，按故障状态决定跳转目标
          if (pdn_watchdog_timeout)
            // 条件判断：有电源故障（非保活模式）或CPU热跳变故障
            state_ns = ((any_pwr_fault_det & ~keep_alive_on_fault ) || (cpu_thermtrip_fault_det )) ? 
                        `SM_DISABLE_S5_DEVICES : // 有故障：跳S5设备禁用（彻底下电）
                        `SM_OFF_STANDBY;         // 无故障：跳回待机状态（等待下次上电）
    end
      //changed '(!pch_thermtrip_n)' to '(cpu_thermtrip_fault_det)' 
    `SM_DISABLE_S5_DEVICES : begin    //31 S5 设备禁用
          // - If no fault, go back to `SM_OFF_STANDBY. Otherwise,
          // - BL, proceed to disable main efuse if e-fuse is forced off or we have
          //   limited/non-recoverable fault.
          // - For anything else, go to `SM_HALT_POWER_CYCLE
          if (pdn_watchdog_timeout) begin
                if (any_pwr_fault_det  )
                  state_ns = `SM_HALT_POWER_CYCLE; // 跳故障暂停状态（等待人工干预）
                else if(|cpu_thermtrip_fault_det) //changed '(!pch_thermtrip_n)' to '(cpu_thermtrip_fault_det)'   // CPU热跳变故障（原!pch_thermtrip_n修改）
                  state_ns = `SM_RESET_STATE;  // 跳复位状态（热跳变后需重启初始化）           
                else // 无故障
                  state_ns = `SM_OFF_STANDBY;  // 跳回待机状态
          end
    end
    //逆序下电，安全优先：完全遵循 “上电顺序相反” 的逻辑，先关核心、再关辅助、最后关主电源，避免低压设备承受高压冲击；
    //超时确认，无残留：每个电源组禁用后均等待pdn_watchdog_timeout，确保电压降至 0V，杜绝短路或漏电风险；
    //故障差异化处理：根据故障类型（电源故障 / CPU 热跳变 / 无故障）决定下电终点，兼顾安全性和可恢复性

  
    `SM_HALT_POWER_CYCLE : begin      //6'h32    暂停电源循环
      //该状态是故障后的 “人工干预等待阶段”，用于处理可重试故障（如瞬时电源波动），等待用户通过物理按钮或软件指令触发恢复，同时限制最大重试次数避免无效循环
      // - We have a power fault waiting for user interaction. Recovery is based
      //   on what the user does. We'll force PCH to transition to S5 here in
      //   this state before before honoring any recovery.
      // - For non-BT, the following are the recovery mechanism.
      //   - Virtual or physical button recovery on any of the following:
      //     - allow_recovery = 1 (any fault is recoverable)
      //     - recoverable fault
      //   - Physical button only recovery on any of the following:
      //     - allow_recovery = 0 AND any_lim_recov_fault
      //   - For either recovery mechanism, a max of LIM_RECOV_RETRY_ATTEMP
      //     recovery attemp is allowed. Counter is incremented for every visit
      //     to this state and cleared on successful power-on. No further
      //     recovery possible if max count is reached.
      // - For BT, getting to this state means a recovery was forced from
      //   SM_SYSTEM_LOCKOUT state. A virtual or physical button press will exit
      //   this state.
      //   - No recovery possible with any_non_recov_fault set.
          // 恢复条件：恢复就绪且无不可恢复故障
          if (ready_for_recov && !any_non_recov_fault) begin
              // 未达到最大重试次数
              if (!lim_recov_retry_max)
                    // 触发恢复的三种场景：
                    // 1. 虚拟按钮触发 +（允许恢复 或 非有限恢复故障）
                    // 2. 物理按钮触发 + 禁止恢复 + 有限恢复故障
                    // 3. BMC清除待机超时信号（bmc_clr_stby_tmout_n）
                   if ((assert_power_button && (allow_recovery || ~any_lim_recov_fault)) ||
                       (assert_physical_button && !allow_recovery && any_lim_recov_fault)||
                       bmc_clr_stby_tmout_n) 	
                      begin
                        state_ns = `SM_AUX_FAIL_RECOVERY;  // 跳转到辅助故障恢复状态
                        lim_recov_retry_incr = 1'b1;      // 重试计数器+1
                      end
          end
          // Set a flag that indicates we're ready for recovery. This flag is
          // to allow system recovery when user first do a virtual power button
          // (no recovery yet) followed by physical button press (recovery expected).
          // In this case, the virtual power button press will cause PCH to switch to
          // S0 which de-asserts pch_slp4_n. Without this latched flag, subsequent
          // physical power button press won't recover since pch_slp4_n is not
          // asserted anymore.
          //ready_for_recov_set = pf_on_wait_complete & ~pch_slp4_n;
          ready_for_recov_set = pf_on_wait_complete ;	  // 设置恢复就绪标志：需故障恢复等待完成
          // This is an offstate
          off_state = 1'b1;// 标记当前为关机状态（用于其他逻辑判断）
    end

    `SM_AUX_FAIL_RECOVERY : begin      //33 辅助故障恢复
      // Clear faults
          // 清除所有故障标志
          stby_failure_detected_clr = 1'b1;  // 清除待机故障
          po_failure_detected_clr     = 1'b1;  // 清除上电故障
          rt_failure_detected_clr     = 1'b1;  // 清除运行时故障
          ready_for_recov_clr             = 1'b1;  // 清除恢复就绪标志（避免重复触发）
          fault_clear_ns                       = 1'b1;  // 全局故障清零
          off_state                                 = 1'b1;        // 标记当前为关机状态
          // 若CMU故障已清除，跳转到RSMRST禁用状态（重新开始上电流程）
          if(~cmu_fault_clear)begin       
            state_ns = `SM_RSMRST_DISABLE;
          end
    end
    //总结：故障恢复流程闭环
    //故障触发：任何阶段检测到可重试故障时，最终进入 SM_HALT_POWER_CYCLE；
    //等待恢复：在 `SM_HALT_POWER_CYCLE 中等待用户操作（按钮 / BMC 指令），同时限制重试次数；
    //恢复初始化：触发恢复后进入 `SM_AUX_FAIL_RECOVERY ，清除所有故障标志；
    //重新上电：从 `SM_RSMRST_DISABLE 开始重新执行上电流程，完成故障恢复

    default : begin
      state_ns = `SM_RESET_STATE;//power_seq_sm_fb;//`SM_RESET_STATE;   异常状态默认跳回复位状态
    end
  endcase
end
	
endmodule



//SM_DISABLE_PWRGD→SM_DISABLE_GRP_D_VDDCORE1→SM_DISABLE_GRP_D_VDDCORE0→SM_DISABLE_GRP_D_SOC→SM_DISABLE_GRP_D_VDDIO
//→SM_DISABLE_GRP_C→SM_DISABLE_GRP_ATX→SM_DISABLE_MAIN_EFUSE→SM_DISABLE_TELEM→SM_DISABLE_PS_ON→
//（分支）SM_DISABLE_S5_DEVICES→（分支）SM_HALT_POWER_CYCLE/`SM_RESET_STATE/`SM_OFF_STANDBY