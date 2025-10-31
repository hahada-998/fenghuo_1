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
`include "pwrseq_define.vh"
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
    input   logic                                         clk                                      , // 时钟信号
    input   logic                                         reset                                    , // 复位信号
    input   logic                                         cmu_fault_clear_rst                      , // CMU故障清除复位信号   

    // 定时信号
    input   logic                                         t1us                                     , // 每1微秒的脉冲信号
    input   logic                                         t512us                                   , // 每512微秒的脉冲信号
    input   logic                                         t256ms                                   , // 每256毫秒的脉冲信号
    input   logic                                         t512ms                                   , // 每512毫秒的脉冲信号
    input   logic                                         t1s_tick                                 , // 每1秒的脉冲信号
    input   logic                                         sequence_tick                            , // 用于上电/下电状态的看门狗超时计时
    input   logic                                         psu_on_tick                              , // 用于PSU开启状态的看门狗超时计时 

    // 电源按钮和南桥状态/控制信号
    input   logic                                         sys_sw_in_n                              , // 系统电源按钮开关
    input   logic                                         pch_slp4_n                               , // 南桥系统睡眠状态
    input   logic                                         p0_pwrbtn_n                              , // 南桥电源按钮输入
    input   logic [1:0]                                   pch_thermtrip_n                          , // 南桥热保护信号
    output  logic                                         force_pwrbtn_n                           , // 强制南桥切换到S5状态
    input   logic [1:0]                                   cpu_thermtrip_fault_det                  , // CPU热保护故障检测信号
    input   logic [5:0]                                   power_seq_sm_fb                          , // 电源序列状态机反馈信号
    input   logic                                         mux_sel                                  , // 多路复用选择信号               

    // 控制和状态信号
    input   logic                                         xr_ps_en                                 , // 系统允许上电信号
    input   logic                                         pwron_override_n                         , // 上电覆盖信号
    input   logic                                         interlock_broken                         , // 联锁断开指示信号
    input   logic                                         allow_recovery                           , // 允许电源按键从HALT_POWER_CYCLE恢复
    input   logic                                         aux_video_holdoff                        , // 允许AUX视频延迟上电
    input   logic                                         pgood_rst_mask                           , // 用于屏蔽关机事件的复位掩码
    // input   logic                                         bmc_ready_out_n                          , // BMC就绪信号
    input   logic                                         bmc_clr_stby_tmout_n                     , // BMC清除待机超时信号

    // input   logic                                         cpu_mcp_en                               , // 任何CPU启用MCP以启用P1V0_CPU和PVMCP_CPU电源轨
    input   logic                                         keep_alive_on_fault                      , // 在上电过程中防止进入关键故障状态

    // S5设备控制信号
    input   logic                                         s5dev_pwren_request                      , // S5设备上电请求信号
    input   logic                                         s5dev_pwrdis_request                     , // S5设备断电请求信号

    // 从序列器接口信号
    input   logic                                         pgd_so_far                               , // 当前整体电源状态（Power Good）
    input   logic                                         any_pwr_fault_det                        , // 任意类型的电源故障检测信号
    input   logic                                         any_lim_recov_fault                      , // 任意有限恢复故障信号
    input   logic                                         any_non_recov_fault                      , // 任意不可恢复故障信号

    //-------------------------------------------------------------------------------------------------------------------------------------------------------
    // 输出信号
    //-------------------------------------------------------------------------------------------------------------------------------------------------------
    // 电源状态信号
    output  logic                                         pgd_raw                                   , // 电源良好信号（在SM_STEADY_OK状态下无故障时有效）

    // 状态信号
    output  logic                                         dc_on_wait_complete                       , // DC上电等待完成标志（4秒标志，用于从序列器检测卡住状态）
    output  logic                                         rt_critical_fail_store                    , // 运行时关键故障存储标志
    output  logic                                         fault_clear                               , // 故障清除信号
    output  logic                                         cmu_fault_clear                           , // CMU故障清除信号
    output  logic [5:0]                                   power_seq_sm                              , // 电源序列状态机的当前状态

    // 故障状态信号
    output  logic                                         fault_power                               , // 电源故障激活标志
    output  logic                                         stby_failure_detected                     , // 待机故障检测标志（映射到Xreg byte07[4]）
    output  logic                                         po_failure_detected                       , // 上电故障检测标志（映射到Xreg byte07[2]）
    output  logic                                         rt_failure_detected                       , // 运行时故障检测标志（映射到Xreg byte07[5]）
    output  logic                                         cpld_latch_sys_off                        , // 系统处于不可恢复状态标志（映射到Xreg byte08[6]）

    // 系统状态信号
    output  logic                                         turn_on_wait                              , // 系统等待上电标志
    output  logic                                         po_failure_detected_set                     // 上电故障检测设置标志
);

// 计算信号位宽
function integer clogb2 (input [31:0] value);
    reg [31:0] tmp;
    begin
          tmp = (value <= 2) ? 2 : (value - 1);
          for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1)
            tmp = tmp >> 1;
    end
endfunction
localparam LIM_RECOV_RETRY_NBITS = clogb2(LIM_RECOV_MAX_RETRY_ATTEMPT);

// FSM
logic  [5:0]                                  state                             ; // 当前状态
logic  [5:0]                                  state_ns                          ; // 下一状态

logic                                         st_off_standby                    ; //状态机 SM_OFF_STANDBY 状态
logic                                         st_ps_on                          ; //状态机 SM_PS_ON 状态
logic                                         st_steady_pwrok                   ; //状态机 SM_STEADY_PWROK 状态
logic                                         st_critical_fail                  ; //状态机 SM_CRITICAL_FAIL 状态
logic                                         st_halt_power_cycle               ; //状态机 SM_HALT_POWER_CYCLE 状态
logic                                         st_disable_main_efuse             ; //状态机 SM_DISABLE_MAIN_EFUSE 状态


// Watchdog logic
logic   [WDT_NBITS-1:0]                       wdt_counter                       ; // 看门狗计数器
logic                                         wdt_tick                          ; // 看门狗计数器的时钟信号
logic   [5:0]                                 power_seq_sm_last                 ; // 上一个状态
logic                                         wdt_counter_clr                   ; // 看门狗计数器清零信号

// Timeout flags
logic                                        grp_a_pwrok_timeout                ;
logic                                        grp_b_pwrok_timeout                ;
logic                                        pon_watchdog_timeout               ;
logic                                        psu_watchdog_timeout               ;
logic                                        efuse_watchdog_timeout             ;

//reg  vcore_watchdog_timeout;
logic                                        pdn_watchdog_timeout               ;
logic                                        dispg_watchdog_timeout             ;

//reg  disable_intel_vccin_timeout;
logic                                        disable_3v3_timeout                ;
logic                                        pon_65ms_watchdog_timeout          ;
logic                                        pf_on_wait_complete                ;
logic                                        po_on_wait_complete                ; // PCH 按键（或 PO）等待完成（用于触发强制按键时序）
logic                                        s5_devices_on_wait_complete        ;
logic                                        rsmrst_release_timeout             ;
logic                                        rsmrst_release_fail_en             ;

// 按钮逻辑
logic                                        p0_pwrbtn_n_ne                     ; // 电源按钮的下降沿检测信号 
logic                                        sys_sw_in_n_ne                     ; // 系统开关的下降沿检测信号 
logic                                        assert_power_button                ; // 表示电源按钮被按下 
logic                                        assert_physical_button             ; // 表示物理按钮被按下 
logic                                        assert_button_clr                  ; // 清除按钮按下标志 
logic                                        rt_normal_pwr_down_flag            ; 

// 故障标志
logic                                        stby_failure_detected_clr          ; // 清除待机故障标志
logic                                        stby_failure_detected_set          ; // 设置待机故障标志
logic                                        po_failure_detected_clr            ; // 清除上电故障标志
//reg  po_failure_detected_set;
logic                                        rt_failure_detected_clr            ; // 清除运行时故障标志
logic                                        rt_failure_detected_set            ; // 设置运行时故障标志

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// 有限恢复逻辑
// 实现有限恢复逻辑，允许系统在故障后尝试恢复一定次数
//-------------------------------------------------------------------------------------------------------------------------------------------------------
logic                                        ready_for_recov                    ; // 表示系统是否准备好进行恢复
logic                                        ready_for_recov_clr                ; // 清除恢复标志
logic                                        ready_for_recov_set                ; // 设置恢复标志
logic   [LIM_RECOV_RETRY_NBITS-1:0]          lim_recov_retry_count              ; // 恢复重试计数器
logic                                        lim_recov_retry_incr               ; // 增加恢复重试计数器
logic                                        lim_recov_retry_clr                ; // 清除恢复重试计数器
logic                                        lim_recov_retry_max                ; // 表示恢复重试次数是否达到最大值

logic                                        off_state                          ; // 表示系统处于关闭状态
logic                                        turn_system_on                     ; // 表示系统请求上电
// wire pch_thermtrip_n_delay;
logic                                        pch_slp4_n_delay                   ; // 延迟的SLP4#信号, 检测南桥（PCH）是否处于睡眠状态
logic                                        fault_clear_ns                     ; // 故障清除的下一个状态信号

// State transition
logic                                        grp_a_state_trans_en               ;
logic                                        grp_a_critical_fail_en             ;
logic                                        grp_b_state_trans_en               ;
logic                                        grp_b_critical_fail_en             ;
logic                                        pwrup_state_trans_en               ;
logic                                        pwron_critical_fail_en             ;
logic                                        psu_critical_fail_en               ;
logic                                        efuse_critical_fail_en             ;
//reg  vcore_critical_fail_en;
logic                                        wait_steady_pwrok_fail_en          ;
logic                                        rt_critical_fail_check             ;
logic                                        rt_normal_pwr_down		            ;
logic                                        rt_thermtrip_pwr_down	            ;
logic                                        rsmrst_release_trans_en            ;

/* ------------------------------------------------------------------------------------------------------------
主板上下电状态机
---------------------------------------------------------------------------------------------------------------*/
always @(posedge clk) begin
    if (reset)
        state <= SM_RESET_STATE ; // 初始复位状态
    else if(t1us)
        state <= state_ns       ; // 复位状态维持1us后，进入后续状态
end

always @(*) begin
    if (reset)
        state_ns = SM_RESET_STATE ;
    else begin
        case(state)
            // 0x00: 状态解释？？？
            SM_RESET_STATE:begin 
                if(power_seq_sm_fb == SM_OFF_STANDBY && (mux_sel == 1'b0))
                    state_ns = SM_OFF_STANDBY     ; 
                else if(power_seq_sm_fb == SM_STEADY_PWROK && (mux_sel == 1'b0))
                    state_ns = SM_STEADY_PWROK    ; 
                else
                    state_ns = SM_EN_GRP_A    ; 
            end

            // 0x01: 状态解释？？？
            SM_EN_GRP_A:begin
                if(grp_a_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;
                else if(grp_a_state_trans_en)
                    state_ns = SM_RSMRST_DISABLE  ;
            end

            // 0x02: 状态解释？？？
            SM_RSMRST_DISABLE:begin 
                if(pwron_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;
                else if(pwrup_state_trans_en)
                    state_ns = SM_EN_GRP_B_33_S5  ;
            end

            // 0x03: 状态解释？？？
            SM_EN_GRP_B_33_S5: begin   
                if(grp_b_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;
                else if(grp_b_state_trans_en)
                    state_ns = SM_EN_GRP_B_18_S5  ;
            end

            // 0x04: 状态解释？？？
            SM_EN_GRP_B_18_S5:begin   
                if(grp_b_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL   ;	
                else if(grp_b_state_trans_en)
                    state_ns = SM_EN_P5V_STBY     ;
            end
	
            // 0x05: 状态解释？？？
            SM_EN_P5V_STBY:begin          
                if(grp_b_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if(grp_b_state_trans_en)
                    state_ns = SM_EN_RSMRST_RELEASE ;
            end
	
            // 0x06: 状态解释？？？ 
            SM_EN_RSMRST_RELEASE:begin   
                if (rsmrst_release_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if(rsmrst_release_trans_en) 
                    state_ns = SM_OFF_STANDBY       ;
            end	

            // 0x07: 状态解释？？？
            SM_ENABLE_S5_DEVICES: begin
                if (pwron_critical_fail_en)
                    // - Fault detected while trying to turn on S5 device.
                    // - Non-BL/BT, go to Disable S5 device.
                    state_ns = SM_DISABLE_S5_DEVICES;
                else if (pwrup_state_trans_en)
                    state_ns = SM_OFF_STANDBY       ;
            end

            // 0x08: 状态解释？？？
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

            // 0x09: 状态解释？？？
            SM_PS_ON: begin
                if (psu_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if (psu_watchdog_timeout && pgd_so_far)
                    state_ns = SM_EN_TELEM          ;
            end

            // 0x0A: 状态解释？？？
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

            // 0x0B: 状态解释？？？
            SM_EN_MAIN_EFUSE: begin
                if (efuse_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if (efuse_watchdog_timeout && pgd_so_far)
                    state_ns = SM_EN_GRP_ATX        ;
            end

            // 0x0C: 状态解释？？？
            SM_EN_GRP_ATX: begin
                if (pwron_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL    ;
                else if (pwrup_state_trans_en)
                    state_ns = SM_EN_GRP_C         ;
            end

            // 0x0D: 状态解释？？？
            SM_EN_GRP_C: begin
                if (pwron_critical_fail_en)
                    state_ns = SM_CRITICAL_FAIL     ;
                else if (pwrup_state_trans_en)
                    state_ns = SM_EN_GRP_D_VDDIO    ;
            end


            // 0x0E: 状态解释？？？
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

            // 0x0F: 状态解释？？？
            SM_EN_GRP_D_SOC: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_EN_GRP_D_VDDCORE0;
                end
            end

            // 0x10: 状态解释？？？
            SM_EN_GRP_D_VDDCORE0: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_EN_GRP_D_VDDCORE1;
                end
            end

            // 0x11: 状态解释？？？
            SM_EN_GRP_D_VDDCORE1: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_EN_PGOOD_RELEASE;
                end
            end

            // 0x12: 状态解释？？？
            SM_EN_PGOOD_RELEASE: begin
                if (pwron_critical_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en) begin
                    state_ns = SM_WAIT_POWEROK;
                end
            end

            // 0x19: 状态解释？？？
            SM_WAIT_POWEROK: begin
                if (wait_steady_pwrok_fail_en) begin
                    state_ns = SM_CRITICAL_FAIL;
                    po_failure_detected_set = 1'b1;
                end
                else if (pwrup_state_trans_en && pgd_so_far) begin
                    state_ns = SM_STEADY_PWROK;
                end
            end

            // 0x20: 状态解释？？？
            SM_STEADY_PWROK: begin
                if (rt_critical_fail_store && !pgood_rst_mask)
                    state_ns = SM_CRITICAL_FAIL;
                else if(rt_thermtrip_pwr_down) 
                    state_ns = SM_CRITICAL_FAIL;
                else if(rt_normal_pwr_down)
                    state_ns = SM_DISABLE_PWRGD; 
            end

            // 0x34: 状态解释？？？
            SM_CRITICAL_FAIL: begin
                state_ns = SM_DISABLE_PWRGD;
            end

            // 0x21 -> 0x2F: 关断序列（按顺序）
            SM_DISABLE_PWRGD: begin
                if (dispg_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_VDDCORE1;
            end

            // 0x22: 状态解释？？？
            SM_DISABLE_GRP_D_VDDCORE1: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_VDDCORE0;
            end

            // 0x23: 状态解释？？？
            SM_DISABLE_GRP_D_VDDCORE0: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_SOC;
            end

            // 0x24: 状态解释？？？
            SM_DISABLE_GRP_D_SOC: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_D_VDDIO;
            end

            // 0x25: 状态解释？？？
            SM_DISABLE_GRP_D_VDDIO: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_C;
            end

            // 0x26: 状态解释？？？
            SM_DISABLE_GRP_C: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_GRP_ATX;
            end

            // 0x27: 状态解释？？？
            SM_DISABLE_GRP_ATX: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_MAIN_EFUSE;
            end

            //  0x28: 状态解释？？？
            SM_DISABLE_MAIN_EFUSE: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_TELEM;
                off_state = 1'b0;
            end

            //  0x29: 状态解释？？？
            SM_DISABLE_TELEM: begin
                if (pdn_watchdog_timeout)
                    state_ns = SM_DISABLE_PS_ON;
            end

            //  0x2A: 状态解释？？？
            SM_DISABLE_PS_ON: begin
                if (pdn_watchdog_timeout)
                    state_ns = ((any_pwr_fault_det & ~keep_alive_on_fault) || (cpu_thermtrip_fault_det)) ? SM_DISABLE_S5_DEVICES : SM_OFF_STANDBY;
            end

            // 0x2B: 状态解释？？？
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

            // 0x2C: 状态解释？？？
            SM_HALT_POWER_CYCLE: begin
                if (ready_for_recov && !any_non_recov_fault) begin
                    if (!lim_recov_retry_max)
                        if ((assert_power_button && (allow_recovery || ~any_lim_recov_fault)) ||
                            (assert_physical_button && !allow_recovery && any_lim_recov_fault) || bmc_clr_stby_tmout_n) begin
                                state_ns = SM_AUX_FAIL_RECOVERY;
                        end
                end
            end

            // 0x2D: 状态解释？？？
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
状态监控, 状态挂死时 “状态超时标志信号” 信号, 供外部模块使用
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

// 各类挂死的超时标志, 达到阈值时置位，直到下次清零 
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
状态监控, 状态完成时标志信号, 供外部模块使用
---------------------------------------------------------------------------------------------------------------*/
always @(posedge clk or posedge reset) begin
    if(reset) begin
        dc_on_wait_complete         <= 1'b0;
        po_on_wait_complete         <= 1'b0;
        s5_devices_on_wait_complete <= 1'b0;
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

always @(posedge clk or posedge reset)begin
  if (reset)
      assert_power_button <= 1'b0;
  else if(assert_button_clr || ~force_pwrbtn_n)
      assert_power_button <= 1'b0;
  else if(p0_pwrbtn_n_ne && off_state)
      assert_power_button <= 1'b1;
end

always @(posedge clk or posedge reset) begin
  if(reset)
      assert_physical_button <= 1'b0;
  else if(assert_button_clr)
      assert_physical_button <= 1'b0;
  else if(sys_sw_in_n_ne && st_halt_power_cycle)
      assert_physical_button <= 1'b1;
end

//------------------------------------------------------------------------------
// force_pwrbtn_n
// - Asserts low when power sequencer needs to toggle SB power button input.
// - Note the differet behavior between BL and non-BL platform
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
    if (reset)
        force_pwrbtn_n <= 1'b1;
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
        force_pwrbtn_n <= ~((st_halt_power_cycle & fault_power& ~pf_on_wait_complete) ||   
                            (st_off_standby & fault_power & (po_on_wait_complete) & assert_power_button  & ~pch_slp4_n));                    
    end
end

//------------------------------------------------------------------------------
// turn_on_wait
// - Asserts when system has been triggered to turn on and keep asserted until
//   SM_STEADY_PWROK or SM_CRITICAL_FAIL is reached.
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
// cpld_latch_sys_off
// - Asserts when in SM_HALT_POWER_CYCLE and we've reached the max number of
//   retry attempt. Aux power cycle is required.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    cpld_latch_sys_off <= 1'b0;
  else
    cpld_latch_sys_off <= st_halt_power_cycle & lim_recov_retry_max;
end

//------------------------------------------------------------------------------
// stby, poweron and runtime fault flags
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)begin
    if(reset)
        stby_failure_detected <= 1'b0;
    else if(t1us && stby_failure_detected_clr)
        stby_failure_detected <= 1'b0;
    else if(t1us && stby_failure_detected_set)
        stby_failure_detected <= 1'b1;
end

always @(posedge clk or posedge reset)begin
    if(reset)
        po_failure_detected <= 1'b0;
    else if(t1us && po_failure_detected_clr)
        po_failure_detected <= 1'b0;
    else if(t1us && po_failure_detected_set)
        po_failure_detected <= 1'b1;
end

always @(posedge clk or posedge reset)begin
    if(reset)
        rt_failure_detected <= 1'b0;
    else if(t1us && rt_failure_detected_clr)
        rt_failure_detected <= 1'b0;
    else if(t1us && rt_failure_detected_set)
        rt_failure_detected <= 1'b1;
end

always @(posedge clk or posedge reset) begin
    if(reset)
        fault_power <= 1'b0;
    else if(t1us)
        fault_power <= stby_failure_detected | po_failure_detected | rt_failure_detected;
end

//------------------------------------------------------------------------------
// Limited-recovery logic
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
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}};
  else if (t1us && lim_recov_retry_clr)
    lim_recov_retry_count <= {LIM_RECOV_RETRY_NBITS{1'b0}};
  else if (t1us && lim_recov_retry_incr)
    lim_recov_retry_count <= lim_recov_retry_count + 1'b1;
end

assign lim_recov_retry_max = (lim_recov_retry_count == LIM_RECOV_MAX_RETRY_ATTEMPT);

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

edge_delay #(
  .CNTR_NBITS    (2)
) sb_pch_slp4_delay_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t512us),
  .signal_in     (~pch_slp4_n & st_steady_pwrok),
  .delay_output  (pch_slp4_n_delay)
);

//------------------------------------------------------------------------------
// fault_clear
// - Clears any outstanding faults on AUX_FAIL_RECOVERY state or during the
//   start of power on sequence.
// - Registered fault_clear to ease out timing since that drives all fault_detectB
//   instances in this module. The extra clock is here is acceptable since SM
//   changes state only every 1us.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    fault_clear <= 1'b0;
  else
    fault_clear <= fault_clear_ns;
end

always @(posedge cmu_fault_clear_rst or posedge fault_clear_ns) begin
  if (cmu_fault_clear_rst)
    cmu_fault_clear <= 1'b0;
  else
    cmu_fault_clear <= 1'b1;
end

//------------------------------------------------------------------------------
// state transition logic
// - These signals are used by SM to steer state transition. The logic are
//   too big to put in the SM block so an intermediate variable is used.
//------------------------------------------------------------------------------
// Asserts when SM is ready to move to the next VRD enablement
always @(posedge clk or posedge reset) begin
  if (reset) begin
    grp_a_state_trans_en  <= 1'b0;
    grp_b_state_trans_en  <= 1'b0;
    pwrup_state_trans_en  <= 1'b0;
	rsmrst_release_trans_en  <= 1'b0;
  end
  else begin
    grp_a_state_trans_en    <= grp_a_pwrok_timeout    & pgd_so_far;
    grp_b_state_trans_en    <= grp_b_pwrok_timeout    & pgd_so_far;
    pwrup_state_trans_en    <= pon_watchdog_timeout   & pgd_so_far;
	rsmrst_release_trans_en <= rsmrst_release_timeout & pgd_so_far ;
  end
end

// Registered to ease timing
always @(posedge clk or posedge reset) begin
  if (reset) begin
        grp_a_critical_fail_en       <= 1'b0;
        grp_b_critical_fail_en       <= 1'b0;
        pwron_critical_fail_en       <= 1'b0;
        psu_critical_fail_en           <= 1'b0;
        efuse_critical_fail_en       <= 1'b0;
    //    vcore_critical_fail_en    <= 1'b0;
        wait_steady_pwrok_fail_en <= 1'b0;
        rsmrst_release_fail_en	   <= 1'b0;
  end
  else if (keep_alive_on_fault) begin
        grp_a_critical_fail_en       <= 1'b0;
        grp_b_critical_fail_en       <= 1'b0;
        pwron_critical_fail_en       <= 1'b0;
        psu_critical_fail_en           <= 1'b0;
        efuse_critical_fail_en       <= 1'b0;
    //    vcore_critical_fail_en    <= 1'b0;
        wait_steady_pwrok_fail_en <= 1'b0;
        rsmrst_release_fail_en	   <= 1'b0;
  end
  else begin
        grp_a_critical_fail_en       <= (grp_a_pwrok_timeout              & ~pgd_so_far) | any_pwr_fault_det;
        grp_b_critical_fail_en       <= (grp_b_pwrok_timeout              & ~pgd_so_far) | any_pwr_fault_det;
        pwron_critical_fail_en       <= (pon_watchdog_timeout            & ~pgd_so_far) | any_pwr_fault_det;
        psu_critical_fail_en           <= (psu_watchdog_timeout            & ~pgd_so_far) | any_pwr_fault_det;
        efuse_critical_fail_en       <= (efuse_watchdog_timeout        & ~pgd_so_far) | any_pwr_fault_det;
    //  vcore_critical_fail_en    <= (vcore_watchdog_timeout     & ~pgd_so_far) | any_pwr_fault_det;
        wait_steady_pwrok_fail_en <= (pon_65ms_watchdog_timeout  & ~pgd_so_far) | any_pwr_fault_det;
        rsmrst_release_fail_en	   <= (rsmrst_release_timeout	      & ~pgd_so_far) | any_pwr_fault_det;
  end
end

// On fault during runtime, assert flag for the duration of SM_STEADY_OK until
// FSM transitions to SM_CRITICAL_FAIL. Flag deasserts on entry to SM_CRITICAL_FAIL.
assign rt_critical_fail_check = (any_pwr_fault_det & ~keep_alive_on_fault) | interlock_broken;

always @(posedge clk or posedge reset) begin
  if (reset)
    rt_critical_fail_store <= 1'b0;
  else
    rt_critical_fail_store <= ( st_steady_pwrok  & rt_critical_fail_check) |
                                                      (~st_critical_fail & rt_critical_fail_store);
end

// Shutdown events
//assign rt_normal_pwr_down    = ~pgood_rst_mask &(~turn_system_on | ( pch_thermtrip_n_delay & pch_slp4_n));
assign rt_normal_pwr_down    = ~pgood_rst_mask &  pch_slp4_n_delay	 ;
assign rt_thermtrip_pwr_down = ~pgood_rst_mask &  pch_thermtrip_n & st_steady_pwrok	 ;
//assign rt_thermtrip_pwr_down = ~pgood_rst_mask &(~turn_system_on | (pch_thermtrip_n & pch_slp4_n_delay)); 


//addr t_thermtrip_pwr_down
//assign rt_normal_pwr_down = ~pgood_rst_mask &( ~pch_slp4_n | ~turn_system_on); 

// pgd_raw asserts on SM_STEADY_PWROK while pgd_so_far is high and
// rt_critical_fail_check is low. If any of these two terms switches states,
// pgd_raw will immediately de-asserts.
always @(posedge clk or posedge reset) begin
  if (reset)
    pgd_raw <= 1'b0;
  else if (t1us)
    pgd_raw <= pgd_so_far & st_steady_pwrok & ~rt_critical_fail_check;
  else
    pgd_raw <= pgd_so_far & pgd_raw & ~rt_critical_fail_check;
end
endmodule
