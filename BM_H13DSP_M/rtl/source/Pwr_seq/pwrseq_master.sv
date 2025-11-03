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
//   the SM_CRITICAL_FAIL state to allow the slave to capture the source of the fault. The master
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
//   PON_65MS_WATCHDOG_TIMEOUT_VAL: Wait before transitioning to SM_STEADY_PWROK after all VRM has turnd on.
//     Default: 34 (sequence_tick=2ms * 34 = 68ms)
//   DC_ON_WAIT_COMPLETE_NOFLT_VAL: Time to wait in SM_OFF_STANDBY before proceeding to turn on w/o fault.
//     Default: 17 (256ms * 17 = 4.3s)
//   DC_ON_WAIT_COMPLETE_FAULT_VAL: Time to wait in SM_OFF_STANDBY before proceeding to turn on with fault.
//     Default: 2 (256ms * 2 = 512ms)
//   PF_ON_WAIT_COMPLETE_VAL: Time to wait in SM_HALT_POWER_CYCLE before allowing recovery, if
//     allowed. This is also the time used to assert PCH PWRBTN# input to force S0->S5 transition.
//     Default: 33 (256ms * 33 = 8.4s)
//   PO_ON_WAIT_COMPLETE_VAL: Time to assert the PCH PWRBTN# input to force an S5->S0 transition.
//     Default: 1 (256ms * 1 = 256ms)
//   S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL, S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL: Time to wait in
//     SM_OFF_STANDBY before proceeding to enable the S5 devices.
//     Default: 0 (256ms * 0 = 0)
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================
`include "pwrseq_define.v"
module pwrseq_master #(
    // 参数定义
    parameter LIM_RECOV_MAX_RETRY_ATTEMPT           = 2                         , // 最大恢复重试次数
    parameter WDT_NBITS                             = 10                        , // 看门狗计数器位宽
    parameter GRP_A_PWROK_TIMEOUT_VAL               = 75                        , // A组电源OK超时时间
    parameter GRP_B_PWROK_TIMEOUT_VAL               = 256                       , // B组电源OK超时时间
    parameter PON_WATCHDOG_TIMEOUT_VAL              = 256                       , // 上电看门狗超时时间
    parameter PSU_WATCHDOG_TIMEOUT_VAL              = 10                        , // 电源单元看门狗超时时间
    parameter EFUSE_WATCHDOG_TIMEOUT_VAL            = 137                       , // EFUSE看门狗超时时间
    parameter VCORE_WATCHDOG_TIMEOUT_VAL            = PON_WATCHDOG_TIMEOUT_VAL  , // VCORE看门狗超时时间
    parameter PDN_WATCHDOG_TIMEOUT_VAL              = 2                         , // 电源关闭看门狗超时时间
    parameter PDN_WATCHDOG_TIMEOUT_FAULT_VAL        = PDN_WATCHDOG_TIMEOUT_VAL  , // 故障时电源关闭超时时间
    parameter DISABLE_INTEL_VCCIN_TIMEOUT_VAL       = PDN_WATCHDOG_TIMEOUT_VAL  , // 禁用VCCIN超时时间
    parameter DISABLE_3V3_TIMEOUT_VAL               = PDN_WATCHDOG_TIMEOUT_VAL  , // 禁用3.3V超时时间
    parameter PON_65MS_WATCHDOG_TIMEOUT_VAL         = 34                        , // 上电65ms看门狗超时时间
    parameter DC_ON_WAIT_COMPLETE_NOFLT_VAL         = 17                        , // 无故障时DC ON等待完成时间
    parameter DC_ON_WAIT_COMPLETE_FAULT_VAL         = 2                         , // 有故障时DC ON等待完成时间
    parameter PF_ON_WAIT_COMPLETE_VAL               = 33                        , // 电源故障等待完成时间
    parameter PO_ON_WAIT_COMPLETE_VAL               = 1                         , // 电源开启等待完成时间
    parameter S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL = 4                         , // 无故障时S5设备开启等待时间
    parameter S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL = 0                         , // 有故障时S5设备开启等待时间
    parameter RSMRST_REALSE_TIMEOUT_VAL             = 75                        , // RSMRST释放超时时间
    parameter DISPG_WATCHDOG_TIMEOUT_VAL            = 6                           // 显示看门狗超时时间 
)(
    // 时钟和复位信号
    input   wire                                          clk                                      , // 时钟信号
    input   wire                                          reset                                    , // 复位信号
    input   wire                                          cmu_fault_clear_rst                      , // CMU故障清除复位信号   

    // 定时脉冲信号
    input   wire                                          t1us                                     , // 每1微秒的脉冲信号
    input   wire                                          t512us                                   , // 每512微秒的脉冲信号
    input   wire                                          t256ms                                   , // 每256毫秒的脉冲信号
    input   wire                                          t512ms                                   , // 每512毫秒的脉冲信号
    input   wire                                          t1s_tick                                 , // 每1秒的脉冲信号
    input   wire                                          sequence_tick                            , // 用于上电/下电状态的看门狗超时计时
    input   wire                                          psu_on_tick                              , // 用于PSU开启状态的看门狗超时计时 

    // 电源按钮和南桥状态/控制信号
    input   wire                                          sys_sw_in_n                              , // 系统电源按钮开关
    input   wire                                          pch_slp4_n                               , // 南桥系统睡眠状态
    input   wire                                          p0_pwrbtn_n                              , // 南桥电源按钮输入
    input   wire  [1:0]                                   pch_thermtrip_n                          , // 南桥热保护信号
    output  reg                                           force_pwrbtn_n                           , // 强制南桥切换到S5状态
    input   wire  [1:0]                                   cpu_thermtrip_fault_det                  , // CPU热保护故障检测信号
    input   wire  [5:0]                                   power_seq_sm_fb                          , // 电源序列状态机反馈信号
    input   wire                                          mux_sel                                  , // 多路复用选择信号               

    // 控制和状态信号
    input   wire                                          xr_ps_en                                 , // 系统允许上电信号
    input   wire                                          pwron_override_n                         , // 上电覆盖信号
    input   wire                                          interlock_broken                         , // 联锁断开指示信号
    input   wire                                          allow_recovery                           , // 允许电源按键从HALT_POWER_CYCLE恢复
    input   wire                                          aux_video_holdoff                        , // 允许AUX视频延迟上电
    input   wire                                          pgood_rst_mask                           , // 用于屏蔽关机事件的复位掩码
    // input   logic                                         bmc_ready_out_n                          , // BMC就绪信号
    input   wire                                          bmc_clr_stby_tmout_n                     , // BMC清除待机超时信号

    // input   logic                                         cpu_mcp_en                               , // 任何CPU启用MCP以启用P1V0_CPU和PVMCP_CPU电源轨
    input   wire                                          keep_alive_on_fault                      , // 在上电过程中防止进入关键故障状态
    // input   wire                                          no_vppen                                 , // 禁用VPPEN信号以防止上电       
    // input   wire                                          hold_pch_rsmrst                          , // 禁用VPPEN信号以防止上电

    // S5设备控制信号
    input   wire                                          s5dev_pwren_request                      , // S5设备上电请求信号
    input   wire                                          s5dev_pwrdis_request                     , // S5设备断电请求信号

    // 从序列器接口信号
    input   wire                                          pgd_so_far                               , // 当前整体电源状态（Power Good）
    input   wire                                          any_pwr_fault_det                        , // 任意类型的电源故障检测信号
    input   wire                                          any_lim_recov_fault                      , // 任意有限恢复故障信号
    input   wire                                          any_non_recov_fault                      , // 任意不可恢复故障信号

    //-------------------------------------------------------------------------------------------------------------------------------------------------------
    // 输出信号
    //-------------------------------------------------------------------------------------------------------------------------------------------------------
    // 电源状态信号
    output  reg                                           pgd_raw                                   , // 电源良好信号（在SM_STEADY_OK状态下无故障时有效）

    // 状态信号
    output  reg                                           dc_on_wait_complete                       , // DC上电等待完成标志（4秒标志，用于从序列器检测卡住状态）
    output  reg                                           rt_critical_fail_store                    , // 运行时关键故障存储标志
    output  reg                                           fault_clear                               , // 故障清除信号
    output  reg                                           cmu_fault_clear                           , // CMU故障清除信号
    output  reg   [5:0]                                   power_seq_sm                              , // 电源序列状态机的当前状态

    // 故障状态信号
    output  reg                                           fault_power                               , // 电源故障激活标志
    output  reg                                           stby_failure_detected                     , // 待机故障检测标志（映射到Xreg byte07[4]）
    output  reg                                           po_failure_detected                       , // 上电故障检测标志（映射到Xreg byte07[2]）
    output  reg                                           rt_failure_detected                       , // 运行时故障检测标志（映射到Xreg byte07[5]）
    output  reg                                           cpld_latch_sys_off                        , // 系统处于不可恢复状态标志（映射到Xreg byte08[6]）

    // 系统状态信号
    output  reg                                           turn_on_wait                              , // 系统等待上电标志
    output  reg                                           po_failure_detected_set                     // 上电故障检测设置标志
);

// 根据 “有限恢复最大重试次数”，自动计算重试计数器的位宽，避免手动定义位宽导致的资源浪费或计数溢出。
function integer clogb2 (input [31:0] value);
    reg [31:0] tmp;
    begin
        tmp = (value <= 2) ? 2 : (value - 1); // 处理边界：value≤2时强制tmp=2，避免位宽不足
        for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1)
            tmp = tmp >> 1;
    end
endfunction
localparam LIM_RECOV_RETRY_NBITS = clogb2(LIM_RECOV_MAX_RETRY_ATTEMPT);

// FSM
reg    [5:0]                                  state                             ; // 当前状态
reg    [5:0]                                  state_ns                          ; // 下一状态

wire                                          st_off_standby                    ; //状态机 SM_OFF_STANDBY 状态
wire                                          st_ps_on                          ; //状态机 SM_PS_ON 状态
wire                                          st_steady_pwrok                   ; //状态机 SM_STEADY_PWROK 状态
wire                                          st_critical_fail                  ; //状态机 SM_CRITICAL_FAIL 状态
wire                                          st_halt_power_cycle               ; //状态机 SM_HALT_POWER_CYCLE 状态
wire                                          st_disable_main_efuse             ; //状态机 SM_DISABLE_MAIN_EFUSE 状态

// Watchdog logic
reg     [WDT_NBITS-1:0]                       wdt_counter                       ; // 看门狗计数器
wire                                          wdt_tick                          ; // 看门狗计数器的时钟信号
reg     [5:0]                                 power_seq_sm_last                 ; // 上一个状态
wire                                          wdt_counter_clr                   ; // 看门狗计数器清零信号

// 各阶段超时标志：电源组A/B就绪超时、上电超时、PSU超时、eFuse超时、Vcore超时、断电超时等
reg                                           grp_a_pwrok_timeout                ;
reg                                           grp_b_pwrok_timeout                ;
reg                                           pon_watchdog_timeout               ;
reg                                           psu_watchdog_timeout               ;
reg                                           efuse_watchdog_timeout             ;
//reg  vcore_watchdog_timeout;
reg                                           pdn_watchdog_timeout               ;
reg                                           dispg_watchdog_timeout             ;
//reg  disable_intel_vccin_timeout;
reg                                           disable_3v3_timeout                ;
reg                                           pon_65ms_watchdog_timeout          ;

// 等待完成标志：DC上电等待完成、按键等待完成、S5设备上电等待完成等; 用于延迟执行动作
reg                                           pf_on_wait_complete                ;
reg                                           po_on_wait_complete                ; // PCH 按键（或 PO）等待完成（用于触发强制按键时序）
reg                                           s5_devices_on_wait_complete        ;
reg                                           rsmrst_release_timeout             ;
reg                                           rsmrst_release_fail_en             ;

// 按钮逻辑
wire                                          p0_pwrbtn_n_ne                     ; // 电源按钮的下降沿检测信号 
wire                                          sys_sw_in_n_ne                     ; // 系统开关的下降沿检测信号 
reg                                           assert_power_button                ; // 强制触发电源按钮信号
reg                                           assert_physical_button             ; // 物理按钮触发标志
reg                                           assert_button_clr                  ; // 按钮触发标志清零
reg                                           rt_normal_pwr_down_flag            ; // 运行时正常下电标志

// 故障标志及清零/置位信号：待机故障、上电故障、运行时故障
reg                                           stby_failure_detected_clr          ; // 待机故障标志清除
reg                                           stby_failure_detected_set          ; // 待机故障标志置位
reg                                           po_failure_detected_clr            ; // 上电故障标志清除
// reg                                           po_failure_detected_set            ; // 上电故障标志置位
reg                                           rt_failure_detected_clr            ; // 运行故障标志清除
reg                                           rt_failure_detected_set            ; // 运行故障标志置位

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// 有限恢复逻辑
// 实现有限恢复逻辑，允许系统在故障后尝试恢复一定次数
//-------------------------------------------------------------------------------------------------------------------------------------------------------
reg                                          ready_for_recov                    ; // 表示系统是否准备好进行恢复
reg                                          ready_for_recov_clr                ; // 恢复标志清除
reg                                          ready_for_recov_set                ; // 恢复标志置位
reg     [LIM_RECOV_RETRY_NBITS-1:0]          lim_recov_retry_count              ; // 恢复重试计数器
reg                                          lim_recov_retry_incr               ; // 恢复重试计数器
reg                                          lim_recov_retry_clr                ; // 恢复重试计数器清除
wire                                         lim_recov_retry_max                ; // 表示恢复重试次数是否达到最大值

reg                                          off_state                          ; // 关机状态标志：是否处于S5及以下关机状态
reg                                          turn_system_on                     ; // 系统上电使能标志：触发上电流程

wire                                         pch_slp4_n_delay                   ; // 南桥S4睡眠信号延迟：防抖处理
reg                                          fault_clear_ns                     ; // 故障清除的下一个状态信号

// 状态切换使能：各电源组、故障场景的状态切换允许信号
reg                                          grp_a_state_trans_en               ;
reg                                          grp_a_critical_fail_en             ;
reg                                          grp_b_state_trans_en               ;
reg                                          grp_b_critical_fail_en             ;
reg                                          pwrup_state_trans_en               ;
reg                                          pwron_critical_fail_en             ;
reg                                          psu_critical_fail_en               ;
reg                                          efuse_critical_fail_en             ;
//reg  vcore_critical_fail_en;
reg                                          wait_steady_pwrok_fail_en          ;
reg                                          rt_critical_fail_check             ; // 运行时关键故障检测使能
reg                                          rt_normal_pwr_down		            ; // 运行时正常下电使能
reg                                          rt_thermtrip_pwr_down	            ; // 运行时热跳变下电使能
reg                                          rsmrst_release_trans_en            ; // RSMRST释放状态切换使能使能


/* ------------------------------------------------------------------------------------------------------------
状态监控, 计数器用于控制各个上电状态延时, 状态跳转
---------------------------------------------------------------------------------------------------------------*/
// 上下电状态打拍输出, 供外部模块判断使用
always @(posedge clk or posedge reset)begin 
  if(reset)
        power_seq_sm <= power_seq_sm;
  else 
        power_seq_sm <= state       ;    
end

// 当前状态信号枚举分类
assign st_off_standby        = (power_seq_sm == SM_OFF_STANDBY            );
assign st_ps_on              = (power_seq_sm == SM_PS_ON                  );
assign st_steady_pwrok       = (power_seq_sm == SM_STEADY_PWROK           );
assign st_critical_fail      = (power_seq_sm == SM_CRITICAL_FAIL          );
assign st_halt_power_cycle   = (power_seq_sm == SM_HALT_POWER_CYCLE       );
assign st_disable_main_efuse = (power_seq_sm == SM_DISABLE_MAIN_EFUSE     );

// wdt_tick信号可选不同触发时间间隔
assign wdt_tick = (off_state) ? t256ms : (st_ps_on ? psu_on_tick : sequence_tick);

// 监测状态机状态变化, 清零看门狗计数器, 时间间隔1us
always @(posedge clk or posedge reset)begin
  if(reset)
      power_seq_sm_last <= power_seq_sm_fb;
  else if(t1us)
      power_seq_sm_last <= power_seq_sm   ;
end

assign wdt_counter_clr = (power_seq_sm_last != power_seq_sm);

// 看门狗计时
always @(posedge clk or posedge reset)begin
  if(reset)
      wdt_counter <= {WDT_NBITS{1'b0}};
  else if(wdt_counter_clr)
      wdt_counter <= {WDT_NBITS{1'b0}};
  else if (wdt_tick)
      wdt_counter <= wdt_counter + 1'b1;
end

/* ------------------------------------------------------------------------------------------------------------
状态监控, “状态超时标志信号” 信号, 供状态机跳转使用
各类挂死的超时标志, 达到阈值时置位，直到下次清零 
---------------------------------------------------------------------------------------------------------------*/
always @(posedge clk or posedge reset) begin
    if (reset)begin
        grp_a_pwrok_timeout       <= 1'b0;
        grp_b_pwrok_timeout       <= 1'b0;
        pon_watchdog_timeout      <= 1'b0;
        psu_watchdog_timeout      <= 1'b0;
        efuse_watchdog_timeout    <= 1'b0;
        // vcore_watchdog_timeout   <= 1'b0;
        pon_65ms_watchdog_timeout <= 1'b0;
        pdn_watchdog_timeout      <= 1'b0;
        // disable_intel_vccin_timeout <= 1'b0;
        disable_3v3_timeout       <= 1'b0;
        rsmrst_release_timeout    <= 1'b0;
        dispg_watchdog_timeout    <= 1'b0;
    end
    else if(wdt_counter_clr)begin
        grp_a_pwrok_timeout       <= 1'b0;
        grp_b_pwrok_timeout       <= 1'b0;
        pon_watchdog_timeout      <= 1'b0;
        psu_watchdog_timeout      <= 1'b0;
        efuse_watchdog_timeout    <= 1'b0;
        //vcore_watchdog_timeout   <= 1'b0;
        pon_65ms_watchdog_timeout <= 1'b0;
        pdn_watchdog_timeout      <= 1'b0;
        //disable_intel_vccin_timeout <= 1'b0;
        disable_3v3_timeout       <= 1'b0;
        rsmrst_release_timeout    <= 1'b0;
        dispg_watchdog_timeout    <= 1'b0;
    end
    else if(wdt_tick)begin
        // A组电源OK超
        if(wdt_counter == GRP_A_PWROK_TIMEOUT_VAL)
            grp_a_pwrok_timeout <= 1'b1;
        // B组电源OK超时
        if(wdt_counter == GRP_B_PWROK_TIMEOUT_VAL)
            grp_b_pwrok_timeout <= 1'b1;
        // 上电看门狗超时
        if(wdt_counter == PON_WATCHDOG_TIMEOUT_VAL)
            pon_watchdog_timeout <= 1'b1;
        // 电源单元看门狗超时
        if(wdt_counter == PSU_WATCHDOG_TIMEOUT_VAL)
            psu_watchdog_timeout <= 1'b1;
        // EFUSE看门狗超时
        if(wdt_counter == EFUSE_WATCHDOG_TIMEOUT_VAL)
            efuse_watchdog_timeout <= 1'b1;
        // VCORE看门狗超时
        if(wdt_counter == VCORE_WATCHDOG_TIMEOUT_VAL)
            vcore_watchdog_timeout <= 1'b1;
        // 上电65ms看门狗超时
        if(wdt_counter == PON_65MS_WATCHDOG_TIMEOUT_VAL)
            pon_65ms_watchdog_timeout <= 1'b1;
        // RSMRST释放超时
        if(wdt_counter == RSMRST_REALSE_TIMEOUT_VAL)
            rsmrst_release_timeout <= 1'b1;
        // 电源关闭看门狗超时/故障时电源关闭超时
        if(((wdt_counter == PDN_WATCHDOG_TIMEOUT_VAL) && !fault_power) ||
          ((wdt_counter == PDN_WATCHDOG_TIMEOUT_FAULT_VAL) && fault_power))
            pdn_watchdog_timeout <= 1'b1;
        // 显示看门狗超时
        if(wdt_counter == DISPG_WATCHDOG_TIMEOUT_VAL) 
            dispg_watchdog_timeout <= 1'b1;
        // 禁用Intel VCCIN超时/故障时禁用Intel VCCIN超时
        //if(((wdt_counter == DISABLE_INTEL_VCCIN_TIMEOUT_VAL) && !fault_power) ||
        //  ((wdt_counter == DISABLE_INTEL_VCCIN_TIMEOUT_FAULT_VAL) &&  fault_power))
        //    disable_intel_vccin_timeout <= 1'b1;
        // 禁用3.3V超时/故障时禁用3.3V超时
        if(((wdt_counter == DISABLE_3V3_TIMEOUT_VAL)       && !fault_power) ||
          ((wdt_counter == DISABLE_3V3_TIMEOUT_FAULT_VAL) &&  fault_power))
            disable_3v3_timeout <= 1'b1;
      end
end

/* ------------------------------------------------------------------------------------------------------------
状态切换使能逻辑, 供状态机使用
状态切换使能是电源时序状态机的 “准入控制”，分为 “正常切换使能” 和 “故障切换使能”
确保只有满足条件时才允许状态机跳转，避免异常流程
---------------------------------------------------------------------------------------------------------------*/
// Asserts when SM is ready to move to the next VRD enablement
always @(posedge clk or posedge reset) begin
  if (reset) begin
    grp_a_state_trans_en     <= 1'b0;  // 电源组A切换使能（初始禁用）
    grp_b_state_trans_en     <= 1'b0;  // 电源组B切换使能（初始禁用）
    pwrup_state_trans_en     <= 1'b0;  // 上电流程切换使能（初始禁用）
	rsmrst_release_trans_en  <= 1'b0;  // RSMRST释放切换使能（初始禁用）
  end
  else begin
    grp_a_state_trans_en    <= grp_a_pwrok_timeout    & pgd_so_far; // 电源组A切换使能：A组就绪超时 + 累计电源就绪（pgd_so_far=1）
    grp_b_state_trans_en    <= grp_b_pwrok_timeout    & pgd_so_far; // 电源组B切换使能：B组就绪超时 + 累计电源就绪
    pwrup_state_trans_en    <= pon_watchdog_timeout   & pgd_so_far; // 上电流程切换使能：上电超时 + 累计电源就绪
	rsmrst_release_trans_en <= rsmrst_release_timeout & pgd_so_far; // RSMRST释放切换使能：RSMRST释放超时 + 累计电源就绪
  end
end


//“超时 + 就绪” 双重校验：仅当 “当前电源组达到稳定等待时间”（超时标志）且 “历史电源组均正常”（pgd_so_far）时，才允许进入下一状态，避免带故障跳转
always @(posedge clk or posedge reset) begin
  if (reset) begin
        grp_a_critical_fail_en       <= 1'b0; // 电源组A关键故障使能
        grp_b_critical_fail_en       <= 1'b0; // 电源组B关键故障使能
        pwron_critical_fail_en       <= 1'b0; // 上电关键故障使能
        psu_critical_fail_en         <= 1'b0; // PSU关键故障使能
        efuse_critical_fail_en       <= 1'b0; // eFuse关键故障使能
    //    vcore_critical_fail_en     <= 1'b0; // （预留）核心电压关键故障使能
        wait_steady_pwrok_fail_en    <= 1'b0; // 等待电源稳定故障使能
        rsmrst_release_fail_en	     <= 1'b0; // RSMRST释放故障使能
  end
  else if (keep_alive_on_fault) begin // 故障保活模式：故障时仍需保持电源，禁用所有故障使能
        grp_a_critical_fail_en       <= 1'b0;
        grp_b_critical_fail_en       <= 1'b0;
        pwron_critical_fail_en       <= 1'b0;
        psu_critical_fail_en         <= 1'b0;
        efuse_critical_fail_en       <= 1'b0;
    //    vcore_critical_fail_en    <= 1'b0;
        wait_steady_pwrok_fail_en    <= 1'b0;
        rsmrst_release_fail_en	     <= 1'b0;
  end
  else begin
        grp_a_critical_fail_en    <= (grp_a_pwrok_timeout        & ~pgd_so_far) | any_pwr_fault_det; // 电源组A故障：A组超时但累计电源未就绪（超时异常） OR 任何电源故障
        grp_b_critical_fail_en    <= (grp_b_pwrok_timeout        & ~pgd_so_far) | any_pwr_fault_det; // 电源组B故障：B组超时但累计电源未就绪 OR 任何电源故障
        pwron_critical_fail_en    <= (pon_watchdog_timeout       & ~pgd_so_far) | any_pwr_fault_det; // 上电故障：上电超时但累计电源未就绪 OR 任何电源故障
        psu_critical_fail_en      <= (psu_watchdog_timeout       & ~pgd_so_far) | any_pwr_fault_det; // PSU故障：PSU超时但累计电源未就绪 OR 任何电源故障
        efuse_critical_fail_en    <= (efuse_watchdog_timeout     & ~pgd_so_far) | any_pwr_fault_det; // eFuse故障：eFuse超时但累计电源未就绪 OR 任何电源故障
    //  vcore_critical_fail_en    <= (vcore_watchdog_timeout     & ~pgd_so_far) | any_pwr_fault_det;
        wait_steady_pwrok_fail_en <= (pon_65ms_watchdog_timeout  & ~pgd_so_far) | any_pwr_fault_det; // 等待电源稳定故障：65ms超时但累计电源未就绪 OR 任何电源故障
        rsmrst_release_fail_en	  <= (rsmrst_release_timeout	 & ~pgd_so_far) | any_pwr_fault_det; // RSMRST释放故障：RSMRST释放超时但累计电源未就绪 OR 任何电源故障
  end
end

/* ------------------------------------------------------------------------------------------------------------
主板上下电状态机
---------------------------------------------------------------------------------------------------------------*/
always @(posedge clk) begin
    if (reset)
        state <= SM_RESET_STATE ; // 初始复位状态
    else if(t1us)
        state <= state_ns       ; // 状态切换, 每1us更新一次
end

always @(*) begin
    if (reset)
        state_ns = SM_RESET_STATE ;
    else begin
        case(state)
            // 0x00: 复位状态
            SM_RESET_STATE:begin 
                if(power_seq_sm_fb == SM_OFF_STANDBY && (mux_sel == 1'b0))
                    state_ns = SM_OFF_STANDBY     ; 
                else if(power_seq_sm_fb == SM_STEADY_PWROK && (mux_sel == 1'b0))
                    state_ns = SM_STEADY_PWROK    ; 
                else
                    state_ns = SM_EN_GRP_A    ; 
            end

            // 0x01: 电源组A使能, o_PAL_P5V_STBY_EN_R=1'b1
            SM_EN_GRP_A:begin
                if(grp_a_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;
                else if(grp_a_state_trans_en)
                    state_ns = SM_RSMRST_DISABLE  ;
            end

            // 0x02: 禁用 RSMRST 信号, 将南桥复位信号 o_P0_RSMRST_N 置 0，保持南桥复位状态
            SM_RSMRST_DISABLE:begin 
                if(pwron_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;
                else if(pwrup_state_trans_en)
                    state_ns = SM_EN_GRP_B_33_S5  ;
            end

            // 0x03: 使能 S5 状态下的电源组 B（3.3V 域）, 开启 CPU 相关的 3.3V 待机电源（如 o_P0_VDDC_EN_R 置 1)
            SM_EN_GRP_B_33_S5: begin   
                if(grp_b_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;
                else if(grp_b_state_trans_en)
                    state_ns = SM_EN_GRP_B_18_S5  ;
            end

            // 0x04: 使能 S5 状态下的电源组 B（1.8V 域）。开启 CPU 相关的 1.8V 待机电源（如 o_PAL_P0_VDD_18_STBY_EN_R 置 1） o_PAL_P0_VDD_18_STBY_EN_R=1'b1; o_P1_VDD_18_STBY_EN=1'b1; 
            SM_EN_GRP_B_18_S5:begin   
                if(grp_b_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;	
                else if(grp_b_state_trans_en)
                    state_ns = SM_EN_P5V_STBY     ;
            end
	
            // 0x05: 使能 5V 待机电源, 开启 USB 总线等外设的 5V 待机电源（如 o_PAL_USB_VBUS1_EN_R 置 1）o_PAL_USB_VBUS1_EN_R=1'b1; o_PAL_USB_VBUS2_EN_R=1'b1; 
            SM_EN_P5V_STBY:begin          
                if(grp_b_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if(grp_b_state_trans_en)
                    state_ns = SM_EN_RSMRST_RELEASE ;
            end
	
            // 0x06: 释放 RSMRST 信号。将南桥复位信号 o_P0_RSMRST_N 置 1，解除南桥复位，允许南桥初始化; o_P0_RSMRST_N=1'b1;o_P1_RSMRST_N=1'b1
            SM_EN_RSMRST_RELEASE:begin   
                if (rsmrst_release_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if(rsmrst_release_trans_en) 
                    state_ns = SM_OFF_STANDBY       ;
            end	

            // 0x07: 使能 S5 状态下的设备电源。开启 S5 状态下需保持供电的外设（如管理芯片、部分传感器）
            SM_ENABLE_S5_DEVICES: begin
                if (pwron_critical_fail_en)
                    // - Fault detected while trying to turn on S5 device.
                    // - Non-BL/BT, go to Disable S5 device.
                    state_ns = SM_DISABLE_S5_DEVICES;
                else if (pwrup_state_trans_en)
                    state_ns = SM_OFF_STANDBY       ;
            end

            // 0x08: S5 Power OK 待机下电状态; S5 状态下电源就绪确认，标志待机阶段电源时序完成状态解释
            // 1、上电故障 2、S5设备断电请求 3、S5设备上电请求 4、系统上电请求
            SM_OFF_STANDBY: begin
                if (any_pwr_fault_det & ~keep_alive_on_fault) 
                    // Fault detected. Using new STBY flag for standby failure.
                    state_ns = SM_CRITICAL_FAIL     ;
                else if (s5dev_pwrdis_request) 
                    // S5 device disable request or request to shutdown e-fuse (BL only)
                    state_ns = SM_DISABLE_S5_DEVICES;
                else if (s5dev_pwren_request && s5_devices_on_wait_complete)
                    // S5 device enable request
                    state_ns = SM_ENABLE_S5_DEVICES ;
                else if (turn_system_on && dc_on_wait_complete) 
                    //add bmc_ready_out_n
                    // Let's power on. Note that if miss_turn_on_window is asserted, there's
                    // no need to wait for dc_on_wait_complete since we just went through
                    // SM_MISS_TURNON which is long enough wait time for the next power up.
                    state_ns = SM_PS_ON             ;
            end

            // 0x09: 电源模块使能; 触发电源供应单元（PSU）的主电源使能，进入上电流程
            SM_PS_ON: begin
                if (psu_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if (psu_watchdog_timeout && pgd_so_far)
                    state_ns = SM_EN_TELEM          ;
            end

            // 0x10: 使能遥测功能; 开启电源、温度等遥测模块，用于系统健康监控
            SM_EN_TELEM: begin
                // - Enable telemetry rails (P3V3_PWM_CTRL and PVCC_HPMOS).
                // - BL, skipped since telemetry rails are enabled during ??
                // if (pwron_critical_fail_en) begin
                //  state_ns = SM_CRITICAL_FAIL;
                //  po_failure_detected_set = 1'b1;
                // end
                //else if (pwrup_state_trans_en) begin
                state_ns = SM_EN_MAIN_EFUSE         ;
            end

            // 0x11: 使能主 eFuse 电源。开启 CPU 内存、SSD 等核心部件的 eFuse 供电（如 o_PAL_P12V_EFUSE_EN_R 置 1）
            SM_EN_MAIN_EFUSE: begin
                if (efuse_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if (efuse_watchdog_timeout && pgd_so_far)
                    state_ns = SM_EN_GRP_ATX        ;
            end

            // 0x12: 使能 ATX 电源组。开启 3.3V 等 ATX 标准电源轨（如 o_PAL_P3V3_EN_R 置 1）
            SM_EN_GRP_ATX: begin
                if (pwron_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL    ;
                else if (pwrup_state_trans_en)
                    state_ns = SM_EN_GRP_C         ;
            end

            // 0x13: 使能电源组 C。开启 CPU 相关的 1.1V 挂起电源（如 o_PAL_P0_VDD_11_SUS_EN 置 1）
            SM_EN_GRP_C: begin
                if (pwron_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if (pwrup_state_trans_en)
                    state_ns = SM_EN_GRP_D_VDDIO    ;
            end


            // 0x14: 使能电源组 D（VDDIO 域）。开启 CPU 输入输出接口的电源（如 o_PAL_P0_VDDIO_EN_R 置 1）
            SM_EN_GRP_D_VDDIO: begin
                if (pwron_critical_fail_en) begin
                    // Skipped if no_vppen is set
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_EN_GRP_D_SOC;
                end
            end

            // 0x15: 使能电源组 D（SOC 域）。开启 CPU 片上系统核心的电源（如 o_PAL_P0_VDD_SOC_EN 置 1）
            SM_EN_GRP_D_SOC: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_EN_GRP_D_VDDCORE0;
                end
            end

            // 0x16: 使能电源组 D（VDDCORE0 域）。开启 CPU 核心电压 0 轨的电源（如 o_PAL_P0_VDD_CORE_0_EN_R 置 1）
            SM_EN_GRP_D_VDDCORE0: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_EN_GRP_D_VDDCORE1;
                end
            end

            // 0x17: 使能电源组 D（VDDCORE1 域）。开启 CPU 核心电压 1 轨的电源（如 o_PAL_P0_VDD_CORE_1_EN_R 置 1）
            SM_EN_GRP_D_VDDCORE1: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_EN_PGOOD_RELEASE;
                end
            end

            // 0x18: 释放 PGOOD 信号。将系统电源就绪信号 o_P0_PWR_GOOD 置 1，通知系统电源全就绪
            SM_EN_PGOOD_RELEASE: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_WAIT_POWEROK;
                end
            end

            // 0x19: 使能电源组 C。开启 CPU 相关的 1.1V 挂起电源（如 o_PAL_P0_VDD_11_SUS_EN 置 1）
            SM_WAIT_POWEROK: begin
                if (wait_steady_pwrok_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en && pgd_so_far) begin
                    state_ns = SM_STEADY_PWROK;
                end
            end

            // 0x20: 稳定电源就绪状态。标志系统进入 S0 工作状态，所有电源轨均稳定就绪
            SM_STEADY_PWROK: begin
                if (rt_critical_fail_store && !pgood_rst_mask)
                    state_ns = SM_CRITICAL_FAIL;
                else if(rt_thermtrip_pwr_down) 
                    state_ns = SM_CRITICAL_FAIL;
                else if(rt_normal_pwr_down)
                    state_ns = SM_DISABLE_PWRGD; 
            end

            // 0x34: 关键故障状态。检测到致命故障（如 CPU 热跳变），触发紧急下电并锁存故障状态
            SM_CRITICAL_FAIL: begin
                state_ns = SM_DISABLE_PWRGD;
            end

            // 0x21 -> 0x2F: 关断序列（按顺序）
            // 0x21: 禁用 PWRGD 信号。将系统电源就绪信号 o_P0_PWR_GOOD 置 0，触发下电流程
            SM_DISABLE_PWRGD: begin
                if (dispg_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_VDDCORE1;
            end

            // 0x22: 禁用电源组 D（VDDCORE1 域）。关闭 CPU 核心电压 1 轨的电源
            SM_DISABLE_GRP_D_VDDCORE1: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_VDDCORE0;
            end

            // 0x23: 禁用电源组 D（VDDCORE0 域）。关闭 CPU 核心电压 0 轨的电源
            SM_DISABLE_GRP_D_VDDCORE0: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_SOC;
            end

            // 0x24: 禁用电源组 D（SOC 域）。关闭 CPU 片上系统核心的电源
            SM_DISABLE_GRP_D_SOC: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_VDDIO;
            end

            // 0x25: 禁用电源组 D（VDDIO 域）。关闭 CPU 输入输出接口的电源
            SM_DISABLE_GRP_D_VDDIO: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_C;
            end

            // 0x26: 禁用电源组 C。关闭 CPU 相关的 1.1V 挂起电源
            SM_DISABLE_GRP_C: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_ATX;
            end

            // 0x27: 禁用 ATX 电源组。关闭 3.3V 等 ATX 标准电源轨？
            SM_DISABLE_GRP_ATX: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_MAIN_EFUSE;
            end

            //  0x28: 禁用主 eFuse 电源。关闭 CPU 内存、SSD 等核心部件的 eFuse 供电
            SM_DISABLE_MAIN_EFUSE: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_TELEM;
                off_state = 1'b0;
            end

            //  0x29: 禁用遥测功能。关闭电源、温度等遥测模块，停止系统健康监控
            SM_DISABLE_TELEM: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_PS_ON;
            end

            //  0x30: 禁用电源模块。关闭电源供应单元（PSU）的主电源使能，进入下电流程
            SM_DISABLE_PS_ON: begin
                if (pdn_watchdog_timeout)
                    state_ns = ((any_pwr_fault_det & ~keep_alive_on_fault) || (cpu_thermtrip_fault_det)) ? SM_DISABLE_S5_DEVICES : SM_OFF_STANDBY;
            end

            // 0x31: 禁用 S5 状态下的设备电源。关闭 S5 状态下的外设电源
            SM_DISABLE_S5_DEVICES: begin
                if (pdn_watchdog_timeout) begin
                    if (any_pwr_fault_det)
                        state_ns = SM_HALT_POWER_CYCLE;
                    else if (|cpu_thermtrip_fault_det)
                        state_ns = SM_RESET_STATE;
                    else
                        state_ns = SM_OFF_STANDBY;
                end
            end

            // 0x32: 暂停电源循环。故障时进入该状态，暂停上电 / 下电流程，等待人工干预或自动恢复
            SM_HALT_POWER_CYCLE: begin
                if (ready_for_recov && !any_non_recov_fault) begin
                    if (!lim_recov_retry_max)
                        if ((assert_power_button && (allow_recovery || ~any_lim_recov_fault)) ||
                            (assert_physical_button && !allow_recovery && any_lim_recov_fault) || bmc_clr_stby_tmout_n) begin
                                state_ns = SM_AUX_FAIL_RECOVERY;
                        end
                end
            end

            // 0x33: 辅助故障恢复。针对可重试的辅助故障（如遥测异常），执行恢复流程
            SM_AUX_FAIL_RECOVERY: begin
                if (~cmu_fault_clear)
                    state_ns = SM_RSMRST_DISABLE;
            end
    
            // 其他状态转换逻辑...
            default: begin
                state_ns = SM_RESET_STATE; // 默认回到初始状态
            end
        endcase
    end 
end 

/* ------------------------------------------------------------------------------------------------------------
状态机控制生成主板上下电 “相关标志” 信号, 供外部模块使用
---------------------------------------------------------------------------------------------------------------*/
// 清除按钮按下标志
assign assert_button_clr = (state == SM_OFF_STANDBY) || (state == SM_CRITICAL_FAIL);

// 清除待机故障标志
assign stby_failure_detected_clr = (state == SM_AUX_FAIL_RECOVERY) ||
                                   (state == SM_RESET_STATE && 
                                   !((power_seq_sm_fb == SM_OFF_STANDBY && (mux_sel == 1'b0)) ||
                                     (power_seq_sm_fb == SM_STEADY_PWROK && (mux_sel == 1'b0)))
                                   );

// 待机故障标志, 上电过程中要保持待机故障标志不变
assign stby_failure_detected_set = (state == SM_OFF_STANDBY) && (any_pwr_fault_det & ~keep_alive_on_fault);

// 清除上电故障标志
assign po_failure_detected_clr   = stby_failure_detected_clr;

// 上电故障标志
assign po_failure_detected_set = (state == SM_EN_GRP_A          && grp_a_critical_fail_en   ) ||
                                 (state == SM_RSMRST_DISABLE    && pwron_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_B_33_S5    && grp_b_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_B_18_S5    && grp_b_critical_fail_en   ) ||
                                 (state == SM_EN_P5V_STBY       && grp_b_critical_fail_en   ) ||
                                 (state == SM_EN_RSMRST_RELEASE && rsmrst_release_fail_en   ) ||
                                 (state == SM_PS_ON             && psu_critical_fail_en     ) ||
                                 (state == SM_EN_MAIN_EFUSE     && efuse_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_ATX        && pwron_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_C          && pwron_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_D_VDDIO    && pwron_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_D_SOC      && pwron_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_D_VDDCORE0 && pwron_critical_fail_en   ) ||
                                 (state == SM_EN_GRP_D_VDDCORE1 && pwron_critical_fail_en   ) ||
                                 (state == SM_EN_PGOOD_RELEASE  && pwron_critical_fail_en   ) ||
                                 (state == SM_WAIT_POWEROK      && wait_steady_pwrok_fail_en);

// 清除运行故障标志
assign rt_failure_detected_clr = stby_failure_detected_clr;

// 运行故障标志
assign rt_failure_detected_set = (state == SM_STEADY_PWROK && rt_critical_fail_store && !pgood_rst_mask);

// 恢复标志
assign ready_for_recov_set = (state == SM_HALT_POWER_CYCLE) && pf_on_wait_complete;

// 清除恢复标志
assign ready_for_recov_clr = (state == SM_AUX_FAIL_RECOVERY);

// 重新清除恢复标志
assign lim_recov_retry_clr = (state == SM_STEADY_PWROK);

// 重新清除恢复标志
assign lim_recov_retry_incr = (state == SM_HALT_POWER_CYCLE) &&
                               ready_for_recov               &&
                               !any_non_recov_fault          &&
                               !lim_recov_retry_max          &&
                               ((assert_power_button && (allow_recovery || ~any_lim_recov_fault)) ||
                                (assert_physical_button && !allow_recovery && any_lim_recov_fault)||
                                bmc_clr_stby_tmout_n);

// 系统处于关闭状态标志
assign off_state =
     (state == SM_OFF_STANDBY) ||
     (state == SM_HALT_POWER_CYCLE) ||
     (state == SM_AUX_FAIL_RECOVERY);

// 故障清除的下一个状态信号
assign fault_clear_ns =
    (state == SM_AUX_FAIL_RECOVERY) ||
    (state == SM_OFF_STANDBY && turn_system_on && dc_on_wait_complete);

// ?? 未使用 ?? 
assign rt_normal_pwr_down_flag = 1'b0;


/* ------------------------------------------------------------------------------------------------------------
状态监控, 状态完成时标志信号
---------------------------------------------------------------------------------------------------------------*/
always @(posedge clk or posedge reset) begin
    if(reset) begin
        dc_on_wait_complete         <= 1'b0; // 直流上电等待完成
        po_on_wait_complete         <= 1'b0; // 上电完成等待
        s5_devices_on_wait_complete <= 1'b0; // S5设备上电等待完成
  end
  else if(t1us)begin
      if(!off_state || interlock_broken)begin
          dc_on_wait_complete                 <= 1'b0;
          po_on_wait_complete                 <= 1'b0;
          s5_devices_on_wait_complete <= 1'b0;
    end
  else begin
      if(((wdt_counter == DC_ON_WAIT_COMPLETE_NOFLT_VAL) && !fault_power) ||
        ((wdt_counter == DC_ON_WAIT_COMPLETE_FAULT_VAL) &&  fault_power))
          dc_on_wait_complete <= 1'b1;

      if(wdt_counter == PO_ON_WAIT_COMPLETE_VAL)
          po_on_wait_complete <= 1'b1;

      if(((wdt_counter == S5_DEVICES_ON_WAIT_COMPLETE_NOFLT_VAL) && !fault_power) ||
        ((wdt_counter == S5_DEVICES_ON_WAIT_COMPLETE_FAULT_VAL) &&  fault_power))
          s5_devices_on_wait_complete <= 1'b1;
    end
  end
end

always @(posedge clk or posedge reset)begin
    if(reset)
        pf_on_wait_complete <= 1'b0;
    else if(t1us && !off_state)
        pf_on_wait_complete <= 1'b0;
    else if(t1us && (wdt_counter == PF_ON_WAIT_COMPLETE_VAL))
        pf_on_wait_complete <= 1'b1;
end

/* ------------------------------------------------------------------------------------------------------------
系统被允许/请求开始上电
---------------------------------------------------------------------------------------------------------------*/
always @(posedge clk or posedge reset)begin
    if(reset)
        turn_system_on <= 1'b0;
    else if(t1us)
        turn_system_on <= (xr_ps_en | ~pwron_override_n | turn_system_on) &  // 外部/寄存器使能位; 强制允许/改变上电
                          pch_slp4_n                                      &  // PCH（南桥)未进入睡眠状态
                          ~interlock_broken                               &  // 联锁故障指示（例如安全盖/急停等）
                          ~aux_video_holdoff;                                // 辅助视频保持未激活
end

/* ------------------------------------------------------------------------------------------------------------
检测pwrbtn/sys_sw_in按钮信号的下降沿, 并生成相应的按钮按下标志信号
---------------------------------------------------------------------------------------------------------------*/
Edge_Detect Edge_Detect_U1(    
    .i_clk               (clk           ),        
    .i_rst_n             (reset         ),       
    .i_signal            (p0_pwrbtn_n   ),
    
    .o_signal_pos        (              ),
    .o_signal_neg        (p0_pwrbtn_n_ne),
    .o_signal_invert     (              )
);
Edge_Detect Edge_Detect_U2(    
    .i_clk               (clk           ),        
    .i_rst_n             (reset         ),       
    .i_signal            (sys_sw_in_n   ),
    
    .o_signal_pos        (              ),
    .o_signal_neg        (sys_sw_in_n_ne),
    .o_signal_invert     (              )
);

// 按钮触发标志（assert_power_button/assert_physical_button）
// 南桥电源按钮触发标志：标记“南桥按钮被按下”事件
always @(posedge clk or posedge reset)begin
  if (reset)
      assert_power_button <= 1'b0;
  else if(assert_button_clr || ~force_pwrbtn_n) // 清零条件：手动清零或强制按钮禁用
      assert_power_button <= 1'b0;
  else if(p0_pwrbtn_n_ne && off_state) // 置位条件：南桥按钮下降沿 + 关机状态
      assert_power_button <= 1'b1;
end

// 物理电源按钮触发标志：标记“用户手动按下物理按钮”事件
always @(posedge clk or posedge reset) begin
  if(reset)
      assert_physical_button <= 1'b0;
  else if(assert_button_clr) // 手动清零
      assert_physical_button <= 1'b0;
  else if(sys_sw_in_n_ne && st_halt_power_cycle) // 置位条件：物理按钮下降沿 + 暂停电源循环状态
      assert_physical_button <= 1'b1;
end

//------------------------------------------------------------------------------
// force_pwrbtn_n 强制按钮驱动
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
        force_pwrbtn_n <= ~((st_halt_power_cycle & fault_power& ~pf_on_wait_complete) ||   
                            (st_off_standby & fault_power & (po_on_wait_complete) & assert_power_button  & ~pch_slp4_n));                    
    end
end

//------------------------------------------------------------------------------
// turn_on_wait
// - Asserts when system has been triggered to turn on and keep asserted until
//   SM_STEADY_PWROK or SM_CRITICAL_FAIL is reached.
//  turn_on_wait 上电等待标志 是上电流程的 “进行中” 标志，用于标记系统已触发上电但尚未完成
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
    if(reset)
        turn_on_wait <= 1'b0;
    else if(t1us)
        turn_on_wait <= (st_off_standby & turn_system_on) |
                        (assert_power_button)             |
                        (turn_on_wait & ~(st_steady_pwrok | st_critical_fail));
end

//------------------------------------------------------------------------------
// cpld_latch_sys_off 统关机锁存标志
// cpld_latch_sys_off 是不可恢复故障的 “关机锁存” 标志，用于标记系统需人工干预才能恢复，锁存条件：
// st_halt_power_cycle=1：系统处于 “暂停电源循环” 状态（故障后暂停上电流程）；
// lim_recov_retry_max=1：有限恢复重试次数达到最大值（如 LIM_RECOV_MAX_RETRY_ATTEMPT=2，重试 2 次后仍失败）。
// - Asserts when in SM_HALT_POWER_CYCLE and we've reached the max number of
//   retry attempt. Aux power cycle is required.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
    if (reset)
        cpld_latch_sys_off <= 1'b0; // 系统关机锁存标志（初始未锁存）
    else
        cpld_latch_sys_off <= st_halt_power_cycle & lim_recov_retry_max; // 锁存条件
end

//------------------------------------------------------------------------------
// 待机故障标志（ stby_failure_detected ）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)begin
    if(reset)
        stby_failure_detected <= 1'b0; // 待机故障标志（初始无故障
    else if(t1us && stby_failure_detected_clr)
        stby_failure_detected <= 1'b0; // 清零：收到待机故障清零信号
    else if(t1us && stby_failure_detected_set)
        stby_failure_detected <= 1'b1; // 置位：收到待机故障置位信号
end

//------------------------------------------------------------------------------
// 上电故障标志（po_failure_detected）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)begin
    if(reset)
        po_failure_detected <= 1'b0;
    else if(t1us && po_failure_detected_clr)
        po_failure_detected <= 1'b0; // 清零：收到上电故障清零信号
    else if(t1us && po_failure_detected_set)
        po_failure_detected <= 1'b1; // 置位：收到上电故障置位信号
end

//------------------------------------------------------------------------------
// 运行时故障标志（rt_failure_detected）
// 标记 “运行阶段”（S0 状态）的故障（如 CPU 热跳变、PSU 掉电）；
// 运行时故障通常需紧急下电，因此该标志会触发 rt_critical_fail_check（运行时关键故障检测）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)begin
    if(reset)
        rt_failure_detected <= 1'b0;
    else if(t1us && rt_failure_detected_clr)
        rt_failure_detected <= 1'b0;
    else if(t1us && rt_failure_detected_set)
        rt_failure_detected <= 1'b1;
end

//------------------------------------------------------------------------------
// 总电源故障标志（fault_power）
// 汇总三类故障标志，fault_power=1 表示系统存在任何电源相关故障；
// 作为全局故障信号，用于触发下电流程、调整超时阈值（如故障下电用更短阈值）
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
    if(reset)
        fault_power <= 1'b0;
    else if(t1us)
        fault_power <= stby_failure_detected | po_failure_detected | rt_failure_detected;
end

//------------------------------------------------------------------------------
// 恢复就绪标志（ready_for_recov）
// 由外部检测逻辑生成 ready_for_recov_set（故障解除）和 ready_for_recov_clr（开始恢复）信号
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    ready_for_recov <= 1'b0;
  else if (t1us && ready_for_recov_clr)
    ready_for_recov <= 1'b0;
  else if (t1us && ready_for_recov_set)
    ready_for_recov <= 1'b1;
end

always @(posedge clk or posedge reset) begin
  if (reset)
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}}; // 重试计数器（初始0
  else if (t1us && lim_recov_retry_clr)
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}}; // 清零：恢复成功或重启后清零
  else if (t1us && lim_recov_retry_incr)
    lim_recov_retry_count <= lim_recov_retry_count + 1'b1;  // 计数：每次重试失败后加1
end

assign lim_recov_retry_max = (lim_recov_retry_count == LIM_RECOV_MAX_RETRY_ATTEMPT); // 重试达最大值标志

//------------------------------------------------------------------------------
// Generate a 1ms delayed version of pch_thermtrip_n when in SM_STEADY_PWROK.
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

/* ------------------------------------------------------------------------------------------------------------
pch S4睡眠信号延迟：用于运行时下电防抖
edge_delay 模块：通用信号延迟模块，通过 “计数器 + 阈值比较” 实现信号防抖（避免瞬时噪声导致误触发）；
南桥 S4 信号延迟（pch_slp4_n_delay）：
输入 ~pch_slp4_n：南桥 S4 睡眠信号（低有效）取反，转为高有效逻辑；
延迟计算：cnt_step=t512us（每 512us 计数一次），cnt_size=2'b10（计数 2 次），总延迟约 1ms；
作用：确保南桥确实进入 S4 状态（非瞬时噪声），再触发运行时下电流程
--------------------------------------------------------------------------------------------------------------*/
edge_delay #(
    .CNTR_NBITS    (2                               )
) sb_pch_slp4_delay_inst (
    .clk           (clk                             ),
    .reset         (reset                           ),
    .cnt_size      (2'b10                           ), // 延迟计数阈值：2个512us（总延迟1.024ms）
    .cnt_step      (t512us                          ), // 计数步长：512us
    .signal_in     (~pch_slp4_n & st_steady_pwrok   ), // 输入：南桥S4信号（低有效）+运行状态
    .delay_output  (pch_slp4_n_delay                )  // 输出：延迟后的S4信号
);

//------------------------------------------------------------------------------
// fault_clear 故障清零逻辑
// - Clears any outstanding faults on AUX_FAIL_RECOVERY state or during the
//   start of power on sequence.
// - Registered fault_clear to ease out timing since that drives all fault_detectB
//   instances in this module. The extra clock is here is acceptable since SM
//   changes state only every 1us.
//fault_clear ：全局故障清零信号，用于清除所有故障标志（stby/po/rt_failure_detected），触发条件由组合逻辑 fault_clear_ns 决定（如进入 “辅助故障恢复” 状态 `SM_AUX_FAIL_RECOVERY 或上电流程开始）；
//cmu_fault_clear ：针对 CMU（时钟管理单元）的专用故障清零信号，由 cmu_fault_clear_rst（CMU 复位）和 fault_clear_ns（全局故障清零）控制
//------------------------------------------------------------------------------
// 故障清零信号（寄存器输出，时序优化）
always @(posedge clk or posedge reset) begin
    if (reset)
        fault_clear <= 1'b0;
    else
        fault_clear <= fault_clear_ns;
end

// CMU故障清零信号（异步复位）
always @(posedge cmu_fault_clear_rst or posedge fault_clear_ns) begin
    if (cmu_fault_clear_rst)
        cmu_fault_clear <= 1'b0; // CMU故障清零（初始未清零）
    else
        cmu_fault_clear <= 1'b1; // 故障清零次态置位时，CMU故障清零
end



/* ------------------------------------------------------------------------------------------------------------
运行时故障处理（Runtime Fault Handling） 运行时（S0 状态）故障需快速响应，避免硬件损坏，
此处通过 “故障检测 - 锁存 - 触发下电” 实现闭环控制，
运行时关键故障检测：故障且非保活模式 OR 联锁故障
//rt_critical_fail_check： 实时检测运行时故障，包含两类场景：
//1.电源故障且非保活模式（ any_pwr_fault_det & ~ keep_alive_on_fault ）；
//2.硬件联锁故障（ interlock_broken ，如柜门打开、安全开关断开）；
//rt_critical_fail_store：锁存故障状态，一旦在运行时（st_steady_pwrok=1）检测到故障，将持续锁存，直到状态机进入 SM_CRITICAL_FAIL（关键故障）才释放
---------------------------------------------------------------------------------------------------------------*/
assign rt_critical_fail_check = (any_pwr_fault_det & ~keep_alive_on_fault) | interlock_broken;

always @(posedge clk or posedge reset) begin
  if (reset)
    rt_critical_fail_store <= 1'b0;
  else
    rt_critical_fail_store <= ( st_steady_pwrok  & rt_critical_fail_check) |
                                                      (~st_critical_fail & rt_critical_fail_store);
end

/* ------------------------------------------------------------------------------------------------------------
Shutdown events 下电事件触发
下电事件按 “触发原因” 分类，分为 “正常下电” 和 “热跳变紧急下电”，确保不同场景下的下电流程有序执行
当前正常下电逻辑：电源就绪复位掩码解除 + 南桥S4延迟信号（确认进入S4状态）
热跳变紧急下电逻辑：电源就绪复位掩码解除 + 南桥热跳变信号 + 运行状态
pgood_rst_mask ：电源就绪复位掩码（ pgood_rst_mask=1 时屏蔽下电，用于上电初期电源未稳定阶段）；
pch_slp4_n_delay ：南桥 S4 睡眠信号延迟（防抖后的值，确保南桥确实进入 S4 状态，避免误触发下电）；
pch_thermtrip_n ：南桥热跳变信号（低有效，表示 CPU / 南桥过温，需紧急下电
---------------------------------------------------------------------------------------------------------------*/
// Shutdown events
//assign rt_normal_pwr_down    = ~pgood_rst_mask &(~turn_system_on | ( pch_thermtrip_n_delay & pch_slp4_n));
assign rt_normal_pwr_down    = ~pgood_rst_mask &  pch_slp4_n_delay	 ;
assign rt_thermtrip_pwr_down = ~pgood_rst_mask &  pch_thermtrip_n & st_steady_pwrok	 ;
//assign rt_thermtrip_pwr_down = ~pgood_rst_mask &(~turn_system_on | (pch_thermtrip_n & pch_slp4_n_delay)); 


/* ------------------------------------------------------------------------------------------------------------
电源就绪原始信号（pgd_raw） pgd_raw 是系统电源就绪的核心标志，直接决定是否允许 CPU / PSU 进入工作状态，需严格确保无故障时才置位
//置位条件：需同时满足三个条件：
//1.pgd_so_far=1：所有已使能电源组均正常就绪；
//2.st_steady_pwrok=1：状态机进入 “电源稳定” 状态（S0）；
//3.~rt_critical_fail_check=1：无运行时故障；
//失能条件：任一条件不满足时立即失能（如突发运行时故障，pgd_raw 实时清零，触发下电）
---------------------------------------------------------------------------------------------------------------*/
//addr t_thermtrip_pwr_down
//assign rt_normal_pwr_down = ~pgood_rst_mask &( ~pch_slp4_n | ~turn_system_on); 

// pgd_raw asserts on SM_STEADY_PWROK while pgd_so_far is high and
// rt_critical_fail_check is low. If any of these two terms switches states,
// pgd_raw will immediately de-asserts.
always @(posedge clk or posedge reset) begin
  if (reset)
    pgd_raw <= 1'b0;
  else if (t1us)
    pgd_raw <= pgd_so_far & st_steady_pwrok & ~rt_critical_fail_check; // 1us同步更新：累计电源就绪 + 运行稳定状态 + 无运行时故障
  else
    pgd_raw <= pgd_so_far & pgd_raw & ~rt_critical_fail_check; // 非同步阶段：保持就绪状态，但需实时检测故障（故障立即失能）
end
endmodule
