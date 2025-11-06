/* =============================================================================================================
// Copyright(c) 
// Filename   : BM_H13DSP_M_TOP
// Project    : BM_H13DSP_M
// Author     : 
// Date       : 2025-01-07
// Simulator   : Lattice Diamond 3.12
// FPGA        : LCMXO3LF_6900C_5BG400C
// Email      : cloudnineinfo.com
// Company    : 
// Description: BM_H13DSP_M Top Code
// History    :
// Date      By          Revision  Change Description
//------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BM_H13DSP_M  : ONE CPLD,this Code for Master CPLD_U1
//-- CPLD     BOARD NAME            PCB CODE        BOARD ID     TAG NO    JTAG CON

//-- CPLD     BM_H13DSP_M      

//-------------------------------------------------------------------------------

模块功能：
主板CPLD顶层模块，负责电源管理、复位控制、故障处理、MCIO通信、板卡检测以及与外部设备（如 BMC、BIOS）的交互。
===============================================================================================================*/
`include "BM_H13DSP_M_VA_PORT.v"
// `include "BM_H13DSP_define.vh" 
`include "pwrseq_define.vh" 

// CPU/PSU 信息
`define NUM_CPU                        2'h02  // CPU的数量2
`define NUM_PSU                        3'h04  // 电源模块数量4

// CPLD 信息
`define PRODUCT_ID                     8'h33  // 产品ID，标识具体的产品型号
`define VENDER_ID                      8'h08  // 供应商ID，标识供应商信息

`define Year                           8'h25  // 产品年份，2025年
`define Month                          8'h03  // 产品月份，3月
`define Day                            8'h13  // 产品日期，13日
`define CPLD_VERSION                   8'h01  // CPLD固件版本号
`define DEBUG_VERSION                  8'h00  // 调试版本号

// 服务器 信息
`define PRODUCT_LINE_C2                8'h48  // 产品线标识，C2产品线
`define PRODUCT_GEN_ID_C3              8'h06  // 产品代数标识，C3代产品
`define SERVER_ID_C5                   8'h41  // 服务器ID，标识服务器型号为G7466
`define BOARD_ID_C6                    8'h01  // 板卡ID，标识具体的板卡型号

//--------------------------------------------------------------------------------------------------------------------------------------------------
// 例化二级模块pll相关信号
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire                    clk_50m ;         // 50 MHz时钟信号，由PLL模块生成
wire                    clk_25m ;         // 25 MHz时钟信号，由PLL模块生成
// wire                   clk_2p5m ;      // 2.5 MHz时钟信号（未使用）
wire                    pll_lock;         // PLL锁定信号，高电平表示PLL已锁定到输入时钟

//-------------------------------------------------------------------------------------------------
// 例化二级模块time_gen相关信号
//-------------------------------------------------------------------------------------------------
wire                    t40ns_tick;       // 40纳秒定时脉冲
wire                    t1us_tick;        // 1微秒定时脉冲
wire                    t2us_tick;        // 2微秒定时脉冲
wire                    t16us_tick;       // 16微秒定时脉冲
wire                    t32us_tick;       // 32微秒定时脉冲
wire                    t128us_tick;      // 128微秒定时脉冲
wire                    t512us_tick;      // 512微秒定时脉冲
wire                    t1ms_tick;        // 1毫秒定时脉冲
wire                    t2ms_tick;        // 2毫秒定时脉冲
wire                    t16ms_tick;       // 16毫秒定时脉冲
wire                    t32ms_tick;       // 32毫秒定时脉冲
wire                    t64ms_tick;       // 64毫秒定时脉冲
wire                    t128ms_tick;      // 128毫秒定时脉冲
wire                    t256ms_tick;      // 256毫秒定时脉冲
wire                    t512ms_tick;      // 512毫秒定时脉冲
wire                    t1s_tick;         // 1秒定时脉冲
wire                    t1hz_clk;         // 1 Hz时钟信号
wire                    t2p5hz_clk;       // 2.5 Hz时钟信号
wire                    t4hz_clk;         // 4 Hz时钟信号
wire                    t16khz_clk;       // 16 kHz时钟信号
wire                    t6m25_clk;        // 6.25 MHz时钟信号
wire                    t16m6_clk;        // 16.6 MHz时钟信号

//-------------------------------------------------------------------------------------------------
// 例化二级模块ClkDivTree相关信号
//-------------------------------------------------------------------------------------------------
wire                    w1uSCE;           // 1微秒时钟使能信号
wire                    w10uSCE;          // 10微秒时钟使能信号
wire                    w50uSCE;          // 50微秒时钟使能信号
wire                    w500uSCE;         // 500微秒时钟使能信号
wire                    w1mSCE;           // 1毫秒时钟使能信号
wire                    w250mSCE;         // 250毫秒时钟使能信号
wire                    w10mSCE;          // 10毫秒时钟使能信号
wire                    w20mSCE;          // 20毫秒时钟使能信号
wire                    w1SCE;            // 1秒时钟使能信号

//-------------------------------------------------------------------------------------------------
// 例化二级模块pon_reset相关信号
//-------------------------------------------------------------------------------------------------
wire                    pon_reset_n;                 // 电源复位信号，低电平有效
wire                    pon_reset_db_n;              // 去抖动后的电源复位信号，低电平有效
wire                    pgd_aux_system;              // 辅助系统电源良好信号
wire                    pgd_aux_system_sasd;         // 辅助系统电源良好信号的SASD版本
wire                    pgd_aux_bmc;                 // BMC辅助电源良好信号
wire                    done_booting_delayed = 1'b1; // 延迟的启动完成信号，固定为高电平

assign                  pgd_aux_bmc          = 1'b1; // 将BMC辅助电源良好信号固定为高电平


//--------------------------------------------------------------------------------------------------------------------------------------------------
//For db_inst_amd_cpu_prsnt
//--------------------------------------------------------------------------------------------------------------------------------------------------
<<<<<<< HEAD
wire    [1:0]           db_cpu_prsnt_n                            ; // 最终对外使用的 CPU 在位信号（低电平有效）
wire    [1:0]           db_cpu_prsnt_n_db                         ; // 来自去抖模块的原始输出（中间信号）
wire                    db_i_p0_spd_host_ctrl_n                   ;

//--------------------------------------------------------------------------------------------------------------------------------------------------
// 本地拨码开关模拟寄存器（仅顶层内部使用，硬件测试时可在约束或测试固件里赋值/映射）
// 说明：拨码低有效 (0 = 强制“在位”), 默认不覆盖（override = 1'b0）
//--------------------------------------------------------------------------------------------------------------------------------------------------
reg     [1:0]           r_dip_cpu_prsnt_n = 2'b00                 ; // 默认均为 1 -> 表示“不在位”
reg                     r_dip_cpu_prsnt_override = 1'b1           ; // 1 = 使用拨码覆盖，0 = 使用真实去抖信号
reg                     r_cpu_pwrbtn_force_n = 1'b0               ; // CPU 电源按钮强制信号，低电平有效，默认不强制

//--------------------------------------------------------------------------------------------------------------------------------------------------
// For cpu_module_u1:Assume the CPU is Present 
// 模块使能与电源状态信号
// 这类信号用于检测 CPU 模块的电源状态（如各电源轨是否稳定）、模块使能状态以及部件存在性
// 是 CPU 模块正常工作的基础状态监测与控制信号
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire                    w_cpu_module_en_n		                      ; // CPU 模块使能（低电平有效），控制 CPU 模块是否使能
wire                    w_cpu_module_p0_pwrok	                    ; // CPU 模块 P0 电源好信号，指示 P0 电源轨稳定(未使用)
wire                    w_cpu_module_p1_pwrok	                    ; // CPU 模块 P1 电源好信号，指示 P1 电源轨稳定(未使用)
wire                    w_cpu_module_p0_pwrgdout	                ; // CPU 模块 P0 电源好输出，用于级联或反馈 P0 电源状态(未使用)
wire                    w_cpu_module_p1_pwrgdout	                ; // CPU 模块 P1 电源好输出，用于级联或反馈 P1 电源状态(未使用)
wire                    w_cpu_module_p0_slp_s3_n	                ; // CPU 模块的P0睡眠信号，S3状态（低有效）
wire                    w_cpu_module_p0_slp_s5_n	                ; // CPU 模块的P0睡眠信号，S5状态（低有效）
wire                    w_cpu_module_p0_prsnt_n	                  ; // CPU 模块 P0 存在检测（低电平有效），检测 P0 相关部件是否存在
wire                    w_cpu_module_p1_prsnt_n	                  ; // CPU 模块 P1 存在检测（低电平有效），检测 P1 相关部件是否存在

//--------------------------------------------------------------------------------------------------------------------------------------------------
// for sync_cpu_data_low
// 数据同步与 PCIe 复位信号
// 主要用于跨时钟域的信号同步（如电源好、复位信号），确保信号在不同时钟域间传输时的稳定性
// 同时包含 PCIe 接口的复位控制与 BIOS 启动阶段的监测信号
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire                    db_i_p0_slp_s3_n	                        ; // P0 睡眠 S3 状态（低电平有效），同步后的信号 
wire                    db_i_p0_slp_s5_n	                        ; // P0 睡眠 S5 状态（低电平有效），同步后的信号
wire                    db_i_p1_slp_s3_n	                        ; // P1 睡眠 S3 状态（低电平有效），同步后的信号 
wire                    db_i_p1_slp_s5_n	                        ; // P1 睡眠 S5 状态（低电平有效），同步后的信号
wire                    db_i_p0_pwrok		                          ; // P0 电源好信号（同步后），确保跨时钟域时的稳定性
wire                    db_i_p1_pwrok		                          ; // P1 电源好信号（同步后），确保跨时钟域时的稳定性
wire                    db_i_p0_reset_n	                          ; // P0 复位信号（低电平有效，同步后），用于 P0 模块复位
wire                    db_i_p1_reset_n	                          ; // P1 复位信号（低电平有效，同步后），用于 P0 模块复位
wire                    db_i_p0_pwrgd_out	                        ; // P0 电源好输出（同步后）
wire                    db_i_p1_pwrgd_out	                        ; // P1 电源好输出（同步后）
wire                    db_i_p0_smerr_n	                          ; //unused // P0 严重错误（低电平有效，未使用）
wire                    db_i_p1_smerr_n	                          ; //unused // P1 严重错误（低电平有效，未使用）
wire                    db_i_fm_cpu_smerr_lvc3_n_r	              ;  
wire                    db_i_p0_pcie_rst_n_0                      ; // P0 PCIe 复位信号（低电平有效，初始级）
wire                    db_i_p0_pcie_rst_n_1                      ; // P0 PCIe 复位信号（低电平有效，次级）
wire                    db_i_p1_pcie_rst_n_0                      ; // P1 PCIe 复位信号（低电平有效，初始级）
wire                    db_i_p1_pcie_rst_n_1                      ; // P1 PCIe 复位信号（低电平有效，次级）
wire                    db_i_p0_bios_post_stage_r_n               ; // P0 BIOS 启动阶段信号（低电平有效），指示 BIOS 启动进度

=======
wire    [1:0]           db_cpu_prsnt_n			                ; // 最终对外使用的 CPU 在位信号（低电平有效）
wire    [1:0]           db_cpu_prsnt_n_db                   ; // 来自去抖模块的原始输出（中间信号）  
wire                    db_i_p0_spd_host_ctrl_n             ; //主机控制相关的输入信号 


// 本地拨码开关模拟寄存器（仅顶层内部使用，硬件测试时可在约束或测试固件里赋值/映射）
// 说明：拨码低有效 (0 = 强制“在位”), 默认不覆盖（override = 1'b0）
reg     [1:0]           r_dip_cpu_prsnt_n        = 2'b00    ; // 默认均为 1 -> 表示“不在位”
reg                     r_dip_cpu_prsnt_override = 1'b1     ; // 1 = 使用拨码覆盖，0 = 使用真实去抖信号
reg                     r_cpu_pwrbtn_force_n     = 1'b0     ; // CPU 电源按钮强制信号，低电平有效，默认不强制

/*--------------------------------------------------------------------------------------------------------------------------------------------------
// For cpu_module_u1:Assume the CPU is Present CPU 
// 模块使能与电源状态信号
// 这类信号用于检测 CPU 模块的电源状态（如各电源轨是否稳定）、模块使能状态以及部件存在性
// 是 CPU 模块正常工作的基础状态监测与控制信号。
--------------------------------------------------------------------------------------------------------------------------------------------------*/
wire                    w_cpu_module_en_n		                ; // CPU 模块使能（低电平有效），控制 CPU 模块是否使能
wire                    w_cpu_module_p0_pwrok	              ; // CPU 模块 P0 电源好信号，指示 P0 电源轨稳定
wire                    w_cpu_module_p1_pwrok	              ; // CPU 模块 P1 电源好信号，指示 P1 电源轨稳定
wire                    w_cpu_module_p0_pwrgdout	          ; // CPU 模块 P0 电源好输出，用于级联或反馈 P0 电源状态
wire                    w_cpu_module_p1_pwrgdout	          ; // CPU 模块 P1 电源好输出，用于级联或反馈 P1 电源状态
wire                    w_cpu_module_p0_slp_s3_n	          ; // CPU 模块的P0睡眠信号，S3状态（低有效）
wire                    w_cpu_module_p0_slp_s5_n	          ; // CPU 模块的P0睡眠信号，S5状态（低有效）
wire                    w_cpu_module_p0_prsnt_n	            ; // CPU 模块 P0 存在检测（低电平有效），检测 P0 相关部件是否存在
wire                    w_cpu_module_p1_prsnt_n	            ; // CPU 模块 P1 存在检测（低电平有效），检测 P1 相关部件是否存在

/*--------------------------------------------------------------------------------------------------------------------------------------------------
// for sync_cpu_data_low
// 数据同步与 PCIe 复位信号
// 主要用于跨时钟域的信号同步（如电源好、复位信号），确保信号在不同时钟域间传输时的稳定性
// 同时包含 PCIe 接口的复位控制与 BIOS 启动阶段的监测信号。
--------------------------------------------------------------------------------------------------------------------------------------------------*/
wire                    db_i_p0_slp_s3_n	                  ; // P0 睡眠 S3 状态（低电平有效），同步后的信号 
wire                    db_i_p0_slp_s5_n	                  ; // P0 睡眠 S5 状态（低电平有效），同步后的信号
wire                    db_i_p1_slp_s3_n	                  ; // P1 睡眠 S3 状态（低电平有效），同步后的信号 
wire                    db_i_p1_slp_s5_n	                  ; // P1 睡眠 S5 状态（低电平有效），同步后的信号
wire                    db_i_p0_pwrok		                    ; // P0 电源好信号（同步后），确保跨时钟域时的稳定性
wire                    db_i_p1_pwrok		                    ; // P1 电源好信号（同步后），确保跨时钟域时的稳定性
wire                    db_i_p0_reset_n	                    ; // P0 复位信号（低电平有效，同步后），用于 P0 模块复位
wire                    db_i_p1_reset_n	                    ; // P1 复位信号（低电平有效，同步后），用于 P0 模块复位
wire                    db_i_p0_pwrgd_out	                  ; // P0 电源好输出（同步后）
wire                    db_i_p1_pwrgd_out	                  ; // P1 电源好输出（同步后）
wire                    db_i_p0_smerr_n	                    ; // P0 严重错误（低电平有效，未使用）
wire                    db_i_p1_smerr_n	                    ; // P1 严重错误（低电平有效，未使用）

wire                    db_i_fm_cpu_smerr_lvc3_n_r	        ; 

wire                    db_i_p0_pcie_rst_n_0                ; // P0 PCIe 复位信号（低电平有效，初始级）
wire                    db_i_p0_pcie_rst_n_1                ; // P0 PCIe 复位信号（低电平有效，次级）
wire                    db_i_p1_pcie_rst_n_0                ; // P1 PCIe 复位信号（低电平有效，初始级）
wire                    db_i_p1_pcie_rst_n_1                ; // P1 PCIe 复位信号（低电平有效，次级）
wire                    db_i_p0_bios_post_stage_r_n         ; // P0 BIOS 启动阶段信号（低电平有效），指示 BIOS 启动进度
>>>>>>> e195096c027b929d0adc57e9f44ea3efe77971d6
//btn
wire                    db_i_pal_pwr_btn_n	                ;
wire                    db_i_pal_ext_rst_n	                ;
wire                    db_i_pal_bmcuid_button              ;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for db_vr_ocp_low
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    db_i_p0_vdd_core_0_ocp_n_r	;
wire    db_i_pal_p0_vdd_core_1_ocp_n	;
wire    db_i_p0_vddio_ocp_n			;
wire    db_i_p1_vdd_core_0_ocp_n_r	;
wire    db_i_pal_p1_vdd_core_1_ocp_n	;
wire    db_i_p1_vddio_ocp_n			;
//psu
wire    db_i_ps1_prsnt                    ;
wire    db_i_ps1_dcok_n                  ;
wire    db_i_ps1_smb_alert            ;
wire    db_i_ps1_acfail_n              ;
wire    db_i_ps2_prsnt                    ;
wire    db_i_ps2_dcok_n                  ;
wire    db_i_ps2_smb_alert            ;
wire    db_i_ps2_acfail_n              ;
wire    db_i_ps3_prsnt                    ;
wire    db_i_ps4_prsnt                    ;
wire    w_ps4_prsnt                       ;
wire    w_ps3_prsnt                       ;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for db_alert  
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C7 VR_Alert
wire    db_i_p0_vr_i2c7_alert_n		;
wire    db_i_p1_vr_i2c7_alert_n		;
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for db_inst_pwrgood
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    db_i_pg_p12v_ssd_efuse			;
wire    db_i_p1v8_stby_pg				;//01
wire    db_i_pwrgd_p3v3_stby			;//02
wire    db_i_pg_p5v_stby				;//03
wire    db_i_pgd_p0_vdd_18_stby              ;//04
wire    db_i_pgd_p1_vdd_18_stby		;//05
wire    db_i_pgd_p0_vddc				;//06
wire    db_i_pgd_p1_vddc                            ;//07
wire    db_i_pgd_p0_vdd_11_sus		;//08
wire    db_i_pgd_p1_vdd_11_sus                ;//09
wire    db_i_pgd_p0_vdd_core_0		;//10
wire    db_i_pgd_p1_vdd_core_0		;//11
wire    db_i_pgd_p0_vdd_core_1		;//12
wire    db_i_pgd_p1_vdd_core_1		;//13
wire    db_i_pgd_p0_vdd_soc_0			;//14
wire    db_i_pgd_p1_vdd_soc_0			;//15
wire    db_i_pgd_p0_vddio				;//16
wire    db_i_pgd_p1_vddio				;//17
wire    db_i_pgd_p3v3_stby_b                    ;//18
wire    db_i_pgd_p1v2_stby                        ;//19
wire    db_i_pgd_p5v                                    ;//20
wire    w_p0_dimm_af_pcamp_r				;	
wire    w_p0_dimm_gl_pcamp_r				;	
wire    w_p1_dimm_af_pcamp_r				;	
wire    w_p1_dimm_gl_pcamp_r				;	
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for cup_thermtrip 
//--------------------------------------------------------------------------------------------------------------------------------------------------   
wire    [1:0]   db_cpu_thermaltrip_n			; 
wire    [1:0]   cpu_thermtrip_fault_det		;
// wire amd_cpu_thrmtrip				;    
wire    w_cpu0_thermaltrip_clr			;
wire    w_cpu1_thermaltrip_clr			;
wire    w_cpupwrok_rise_dly2ms			;
wire    [1:0]   w_cpu_thermtrip_event			;
wire    w_cpu0_prochot					;	
wire    w_cpu1_prochot					;	
wire    w_force_allpwron_ctl			;	

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for pwrseq_master_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    [5:0]   w_power_seq_sm			;
wire    w_st_reset_state					;
wire    w_st_off_standby					;
wire    w_st_steady_pwrok				;
wire    w_st_halt_power_cycle			;
wire    w_st_aux_fail_recovery			;
wire    w_st_disable_grp_d_vddio			;	
wire    w_st_critical_fail				;	
wire    w_force_pwrbtn_n					;
wire    w_pgd_raw						;
wire    w_s5dev_aux_pwren_request		;
wire    w_s5dev_aux_pwrdis_request		;
wire    w_pgd_so_far						;
wire    w_any_pwr_fault_det				;
wire    w_any_lim_recov_fault			;
wire    w_any_non_recov_fault			;
wire    w_any_recov_fault				;
wire    w_dc_on_wait_complete			;	//out, TO SLAVE,
wire    w_rt_critical_fail_store		;
wire    w_fault_clear					;
wire    w_cmu_fault_clear				;	
wire    w_power_fault					;
wire    w_stby_failure_detected			;
wire    w_stb_pwron_tmout_fail_clr		;	
wire    w_stb_pwrdown_ukwn_fail_clr		;	
wire    w_poweron_tmout_fail_clr			;	
wire    w_dc_failure_detected			;
wire    w_rt_failure_detected			;
wire    w_cpld_latch_sys_off				;
wire    w_turn_on_wait					;
wire    w_power_on_fail_err_code_clr		;	
wire    w_power_down_fail_err_code_clr	;	
wire    w_keep_alive_on_fault			;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for pwrseq_slave_inst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_all_power_pg			        ;
wire    w_all_stby_power_pg			    ;
wire    w_all_main_power_pg			    ;
wire    w_any_aux_vrm_fault			    ;
wire    w_cpu_sys_pwrok					;
wire    w_p5v_stby_en 					;
wire    w_p5v_stby_usb_en				;	
wire    w_grp_b_p0_33_s5_en				;
wire    w_grp_b_p1_33_s5_en				;
wire    w_grp_b_p0_18_s5_en				;
wire    w_grp_b_p1_18_s5_en				;
wire    w_p12_en							;
wire    w_p5v_en						;
wire    w_grp_c_p0_vdd11_en				;
wire    w_grp_c_p1_vdd11_en				;
wire    w_grp_d_p0_vddio_en				;
wire    w_grp_d_p1_vddio_en				;
wire    w_grp_d_p0_soc_en				;
wire    w_grp_d_p1_soc_en				;
wire    w_grp_d_p0_vddcore0_en			;
wire    w_grp_d_p1_vddcore0_en			;
wire    w_grp_d_p0_vddcore1_en			;
wire    w_grp_d_p1_vddcore1_en			;
wire    [5:0]   w_pwrseq_sm_fault_det		;
wire    w_p5v_stby_fault_det				;
wire    w_grp_c_p0_fault_det				;
wire    w_grp_d_vddio_p0_fault_det		;
wire    w_grp_d_soc_p0_fault_det			;
wire    w_grp_d_p0_vddcore0_fault_det	;
wire    w_grp_d_p0_vddcore1_fault_det	;
wire    w_grp_c_p1_fault_det				;
wire    w_grp_d_vddio_p1_fault_det		;
wire    w_grp_d_soc_p1_fault_det			;
wire    w_grp_d_p1_vddcore0_fault_det	;
wire    w_grp_d_p1_vddcore1_fault_det	;
wire    w_grp_b_p0_33_s5_fault_det		;
wire    w_grp_b_p0_18_s5_fault_det		;
wire    w_p3v3_stby_fault_det			;	
wire    w_p1v0_stby_m2_fault_det			;	
wire    w_p5v_fault_det					;
wire    [1:0]   w_cpu_pwrok					;
wire    w_cpu_pwr_good					;
wire    w_cpu1_pwr_good					;
wire    [1:0]   o_cpu_pwrok					;
wire    w_rsmrst_n						;
 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//for bmc clear 
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_clr_cmos_done_rst		;
wire    w_clr_cmos_flg			;
wire    w_clr_cmos_done		;
wire    w_bmc_nmi_ctl			;
wire    w_bmc_nmi_ctl_done		;
wire    w_bmc_nmi_ctl_rst		;
wire    w_p0_nmi_sync_flood_n	;
wire    w_p1_nmi_sync_flood_n	;
wire    w_rtc_senor_sw			;
wire    w_ctl_scaled_bat_test_en_r;
wire    w_sys_debug_mode		;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for error code add 
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    [7:0]   r_pwrdrop_code			;
wire    [7:0]   r_timeout_code			;
wire    w_bmc_stby_failure_detected		;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for PCIe Rst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_pcie_genz_rst_n_r			;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for Moc Rst
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_sm_steady_pwrok_state		;
wire    w_p0_prochot_n				;
wire    w_p1_prochot_n				;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for sgpio
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_uid_btn_n				;	
wire    w_eeprom_wp					; //disable write-protect 1:enable write-protect 0:disable write-protect
wire    w_ocp_aux_en					;
wire    w_ocp_main_en				;
wire    w_i3c_mux_en					; 
wire    w_i3c_remote_cs					; 
wire    w_bmc_i2c5_9548_rst_n		;
wire    w_bmc_i2c9_9548_1_rst_n		;
wire    w_bmc_i2c9_9548_2_rst_n		;
wire    w_bmc_i2c9_9548_3_rst_n		;
wire    w_bmc_i2c9_9548_4_rst_n		;
wire    w_p0_vpp_9545_1_rst_n		;
wire    w_p0_vpp_9545_2_rst_n		;
wire    w_p12v_stby_fault_det		;
wire    w_usb_ponrst_r_n				;
wire    w_tpcm_reset_n_reg			;
wire    w_jtag_cpld_bmc_ntrst_reg	;
wire    w_dimm_alarm_flag			;

//--------------------------------------------------------------------------------------------------------------------------------------------------
//for hitless 
//--------------------------------------------------------------------------------------------------------------------------------------------------
reg      [5:0]  r_power_seq_sm_fb			;	
wire    w_mux_sel						;	
wire    w_p0_sys_reset_r_n				;
wire    w_p0_kbrst_n						; 	
wire    w_p1_kbrst_n						; 	
wire    w_bmc_jtag_trst_r_n			;
// wire    w_pal_i3c_mux_en_r_n			;
wire    w_p0_pcie_wake_n_r			;
wire    w_p1_pcie_wake_n_r			;	
wire    w_pal_p0_vdd_core_0_soc_rst_l_n	;
wire    w_pal_p1_vdd_core_0_soc_rst_l_n	;
wire    w_pal_p0_vdd_core_1_11_sus_rst_l_n	;
wire    w_p1_vdd_core_1_11_sus_rst_l_n;
wire    w_pal_p0_vddio_rst_n				;
wire    w_p1_vddio_rst_l_n;

wire    [7:0]   w_p0_mciop0a_slot_id;
wire    [7:0]   w_p0_mciop0c_slot_id;
wire    [7:0]   w_p0_mciop1a_slot_id;//0
wire    [7:0]   w_p0_mciop1c_slot_id;//1
wire    [7:0]   w_p0_mciop2a_slot_id;//2
wire    [7:0]   w_p0_mciop2c_slot_id;//3
wire    [7:0]   w_p0_mciop3a_slot_id;//4
wire    [7:0]   w_p0_mciop3c_slot_id;//5
wire    [7:0]   w_p0_mciog3a_slot_id;//6
wire    [7:0]   w_p0_mciog3c_slot_id;//7
wire    [7:0]   w_p1_mciop0a_slot_id;//10
wire    [7:0]   w_p1_mciop0c_slot_id;//11
wire    [7:0]   w_p1_mciop1a_slot_id;//12
wire    [7:0]   w_p1_mciop1c_slot_id;//13
wire    [7:0]   w_p1_mciop2a_slot_id;//14
wire    [7:0]   w_p1_mciop2c_slot_id;//15
wire    [7:0]   w_p1_mciop3a_slot_id;//16
wire    [7:0]   w_p1_mciop3c_slot_id;//17
wire    [7:0]   w_p1_mciog1a_slot_id;//8
wire    [7:0]   w_p1_mciog1c_slot_id;//9

wire db_i_pwr_btn_cpld_n_r				;	//PWR BUTTON 
wire w_bmc_sbtn_reset_ctl			;
//DATA from S_CPLD (U247)
wire    [3:0]   w_board_id;
wire    [2:0]   w_pcb_version;
wire    [2:0]   w_pca_version;
wire    w_P1_MCIOP0A_CB_ID0_R;
wire    w_P1_MCIOP0A_CB_ID1_R;
wire    w_P1_MCIOP0C_CB_ID0_R;
wire    w_P1_MCIOP0C_CB_ID1_R;
wire    w_P1_MCIOP1A_CB_ID0_R;
wire    w_P1_MCIOP1A_CB_ID1_R;
wire    w_P1_MCIOP1C_CB_ID0_R;
wire    w_P1_MCIOP1C_CB_ID1_R;
wire    w_P1_MCIOP2A_CB_ID0_R;
wire    w_P1_MCIOP2A_CB_ID1_R;
wire    w_P1_MCIOP2C_CB_ID0_R;
wire    w_P1_MCIOP2C_CB_ID1_R;

wire    w_bmc_extrst_uid;
wire    w_usb2_lcd_oc_n;
wire    w_usb_inner_overcur3;

wire    w_PAL_BP1_PRSNT_N;
wire    w_PAL_BP2_PRSNT_N;
wire    w_PAL_BP3_PRSNT_N;
wire    w_PAL_BP4_PRSNT_N;
wire    w_PAL_BP5_PRSNT_N;
wire    w_PAL_BP8_PRSNT_N;
wire    w_uid_sw_in_n;
wire    w_ps1_p12v_on_r;
wire    w_ps2_p12v_on_r;
wire    w_FM_P12V_EN;
wire    w_PWRGD_P12V_PS3_PS4;
wire    w_PWRGD_P12V;
wire    w_PS3_PS4_ACFAIL;
wire    w_pal_ps_off_r;
wire    w_pal_dual_en_r;
wire    w_clk_gen_en_r_n;
wire    w_pal_db2000_1_pwrgd_r;
wire    w_pal_db2000_2_pwrgd_r;
wire    w_clk_db2000_1_1_oe_n;
wire    w_clk_db2000_1_2_oe_n;
wire    w_fm_pld_db800_3_clks_dev_en_r;
wire    w_clk_db800_3_1_oe_n_r;
wire    w_clk_db800_3_2_oe_n_r;
wire    w_pal_bmc_srst_n_r;
wire    w_p12v_slot_0_on;
wire    w_p12v_slot_1_on;
wire    w_p12v_slot_2_on;
wire    w_slot_0_on_dly_10ms;
wire    w_slot_1_on_dly_10ms;
wire    w_slot_2_on_dly_10ms;
wire    w_p12v_slot_0_on_r;
wire    w_p12v_slot_1_on_r;
wire    w_p12v_slot_2_on_r;
wire    w_p0_mciop0a_gpu_throttle_n_r;
wire    w_p0_mciop0c_gpu_throttle_n_r;
wire    w_p0_pcie_wake_n;
wire    w_p1_pcie_wake_n;
wire    [7:0]   w_led_control;
wire    w_p5v_vga2_en_n_r;
wire    w_pal_p5v_en_r;
wire    w_pal_bmc_aux_pgd;
wire    w_p1v0_stby_m2_en;

wire    w_cpld_sgpio0_clk_r;
wire    w_cpld_sgpio0_ld_n_r;
wire    w_cpld_sgpio0_mosi_r;
wire    w_cpld_sgpio1_clk_r;
wire    w_cpld_sgpio1_ld_n_r;
wire    w_cpld_sgpio1_mosi_r;
wire    w_PAL_OCP1_PRSNT_B3_N;//2025-03-06 add

wire    w_BREAK_DET_DO_N      ;
wire    w_LEAKAGE0_PRSNT_N  ;
wire    w_LEAKAGE_DET_DO_N  ;
wire    w_BREAK_DET1_DO_N    ;
wire    w_LEAKAGE_PRSNT1_N  ;
wire    w_LEAKAGE_DET1_DO_N;
wire    [1:0]   w_bf_type;
//-------------------------------------------------------------------------------------------------
//Switch1 & ZT1 BOARD
//-------------------------------------------------------------------------------------------------
wire w_tpm431_alert_n_sw       ; //u7
wire w_ina3221_pwr_alert_sw    ; //u7
wire w_pal_3v3_pgd1_r_sw       ; //u7
wire w_pal_3v3_pgd2_r_sw       ; //u7
wire w_pal_3v3_pgd3_r_sw       ; //u7
wire w_pal_3v3_pgd4_r_sw       ; //u7
wire w_pal_3v3_pgd5_r_sw       ; //u7
wire w_u3_nc7_sw               ; //u7

wire w_slot1_prsnt_n_sw        ; //u9
wire w_slot2_prsnt_n_sw        ; //u9
wire w_slot3_prsnt_n_sw        ; //u9
wire w_slot4_prsnt_n_sw        ; //u9
wire w_slot5_prsnt_n_sw        ; //u9
wire w_slot6_prsnt_n_sw        ; //u9
wire w_slot7_prsnt_n_sw        ; //u9
wire w_slot8_prsnt_n_sw        ; //u9

wire w_slot9_prsnt_n_sw        ; //u10
wire w_slot10_prsnt_n_sw       ; //u10
wire w_slot11_prsnt_n_sw       ; //u10
wire w_slot12_prsnt_n_sw       ; //u10
wire w_slot13_prsnt_n_sw       ; //u10
wire w_mcio1_prsnt_n_sw        ; //u10
wire w_mcio2_prsnt_n_sw        ; //u10
wire w_mcio3_prsnt_n_sw        ; //u10

wire w_mcio4_prsnt_n_sw        ; //u38
wire w_mcio5_prsnt_n_sw        ; //u38
wire w_mcio6_prsnt_n_sw        ; //u38
wire w_mcio7_prsnt_n_sw        ; //u38
wire w_mcio8_prsnt_n_sw        ; //u38
wire w_mcio9_prsnt_n_sw        ; //u38
wire w_mcio10_prsnt_n_sw       ; //u38
wire w_mcio11_prsnt_n_sw       ; //u38

wire w_mcio12_prsnt_n_sw       ; //u5
wire w_mcio13_prsnt_n_sw       ; //u5
wire w_pcb_version2_sw         ; //u5
wire w_pcb_version1_sw         ; //u5
wire w_pcb_version0_sw         ; //u5
wire w_pca_version2_sw         ; //u5
wire w_pca_version1_sw         ; //u5
wire w_pca_version0_sw         ; //u5

wire w_board_id0_sw            ;  //u6
wire w_board_id1_sw            ;  //u6
wire w_board_id2_sw            ;  //u6
wire w_board_id3_sw            ;  //u6
wire w_board_id4_sw            ;  //u6
wire w_board_id5_sw            ;  //u6
wire w_board_id6_sw            ;  //u6
wire w_board_id7_sw            ;  //u6

wire w_ct_p1v25_sw0_pg_sw      ; //u41
wire w_ct_p1v25_sw1_pg_sw      ; //u41
wire w_p0v8_sw0_pwrgd_sw       ; //u41
wire w_p0v8_sw1_pwrgd_sw       ; //u41
wire w_slot1_wake_n_sw         ; //u41
wire w_slot2_wake_n_sw         ; //u41
wire w_slot3_wake_n_sw         ; //u41
wire w_slot4_wake_n_sw         ; //u41

wire w_slot5_wake_n_sw         ; //u44
wire w_slot6_wake_n_sw         ; //u44
wire w_slot7_wake_n_sw         ; //u44
wire w_slot8_wake_n_sw         ; //u44
wire w_slot9_wake_n_sw         ; //u44
wire w_slot10_wake_n_sw        ; //u44
wire w_slot11_wake_n_sw        ; //u44
wire w_slot12_wake_n_sw        ; //u44

// wire w_pal_p12v_drop_sw            ; //u40
// wire w_pg_p5v0_r_sw                ; //u40
// wire w_pg_p1v8_r_sw                ; //u40
// wire w_pg_p1v8_pll_r_sw            ; //u40
// wire w_db2000_pwrgd0_sw            ; //u40
// wire w_db2000_pwrgd1_sw            ; //u40
// wire w_mcio_slot13_prsnt_n_1_sw    ; //u40
// wire w_u40_nc7_sw                  ; //u40
//zt
wire w_tpm431_alert_n_zt       ;//u3
wire w_ina3221_pwr_alert_zt    ;//u3
wire w_pal_3v3_pgd1_r_zt       ;//u3
wire w_pal_3v3_pgd2_r_zt       ;//u3
wire w_pal_3v3_pgd3_r_zt       ;//u3
wire w_pal_3v3_pgd4_r_zt       ;//u3
wire w_pal_3v3_pgd5_r_zt       ;//u3
wire w_u3_nc7_zt               ;//u3

wire w_slot1_prsnt_n_zt        ;//u7
wire w_slot2_prsnt_n_zt        ;//u7
wire w_slot3_prsnt_n_zt        ;//u7
wire w_slot4_prsnt_n_zt        ;//u7
wire w_slot5_prsnt_n_zt        ;//u7
wire w_slot6_prsnt_n_zt        ;//u7
wire w_slot7_prsnt_n_zt        ;//u7
wire w_slot8_prsnt_n_zt        ;//u7
//in ZT BOARD                           
wire w_slot9_prsnt_n_zt        ;//u8    
wire w_slot10_prsnt_n_zt       ;//u8    
wire w_slot11_prsnt_n_zt       ;//u8    
wire w_slot12_prsnt_n_zt       ;//u8    
wire w_slot13_prsnt_n_zt       ;//u8    
wire w_mcio1_prsnt_n_zt        ;//u8    
wire w_mcio2_prsnt_n_zt        ;//u8    
wire w_mcio3_prsnt_n_zt        ;//u8    

wire w_mcio4_prsnt_n_zt        ;//u4    
wire w_mcio5_prsnt_n_zt        ;//u4    
wire w_mcio6_prsnt_n_zt        ;//u4    
wire w_mcio7_prsnt_n_zt        ;//u4    
wire w_mcio8_prsnt_n_zt        ;//u4    
wire w_mcio9_prsnt_n_zt        ;//u4    
wire w_mcio10_prsnt_n_zt       ;//u4    
wire w_mcio11_prsnt_n_zt       ;//u4    

wire w_mcio12_prsnt_n_zt       ;//u5    
wire w_mcio13_prsnt_n_zt       ;//u5    
wire w_pcb_version2_zt         ;//u5    
wire w_pcb_version1_zt         ;//u5    
wire w_pcb_version0_zt         ;//u5    
wire w_pca_version2_zt         ;//u5    
wire w_pca_version1_zt         ;//u5    
wire w_pca_version0_zt         ;//u5    
 
wire w_board_id0_zt            ;//u6    
wire w_board_id1_zt            ;//u6    
wire w_board_id2_zt            ;//u6    
wire w_board_id3_zt            ;//u6    
wire w_board_id4_zt            ;//u6    
wire w_board_id5_zt            ;//u6    
wire w_board_id6_zt            ;//u6    
wire w_board_id7_zt            ;//u6    
  
wire w_mcio1_prsnt_n_1_zt      ;//u18   
wire w_mcio2_prsnt_n_1_zt      ;//u18   
wire w_mcio3_prsnt_n_1_zt      ;//u18   
wire w_mcio4_prsnt_n_1_zt      ;//u18   
wire w_mcio5_prsnt_n_1_zt      ;//u18   
wire w_mcio7_prsnt_n_1_zt      ;//u18   
wire w_mcio9_prsnt_n_1_zt      ;//u18   
wire w_mcio10_prsnt_n_1_zt     ;//u18   

wire w_mcio11_prsnt_n_1_zt     ;//u19   
wire w_mcio12_prsnt_n_1_zt     ;//u19   
wire w_u19_nc2_zt              ;//u19   
wire w_u19_nc3_zt              ;//u19   
wire w_u19_nc4_zt              ;//u19   
wire w_u19_nc5_zt              ;//u19   
wire w_u19_nc6_zt              ;//u19   
wire w_u19_nc7_zt              ;//u19   

wire [5:0]pvti_zt_count;
wire w_pwr_on_dly2s;
wire w_pwr_on_dly1s5;  
wire [2:0]pvti_sw_u2_count1;

reg r_board_id0_zt     ;
reg r_board_id1_zt     ;
reg r_board_id2_zt     ;
reg r_board_id3_zt     ;
reg r_board_id4_zt     ;
reg r_board_id5_zt     ;
reg r_board_id6_zt     ;
reg r_board_id7_zt     ;

reg r_pcb_version2_zt  ;
reg r_pcb_version1_zt  ;
reg r_pcb_version0_zt  ;
reg r_pca_version2_zt  ;
reg r_pca_version1_zt  ;
reg r_pca_version0_zt  ;

reg r_mcio9_prsnt_n_zt ;
reg r_mcio7_prsnt_n_zt ;
reg r_mcio3_prsnt_n_zt ;
reg r_mcio1_prsnt_n_zt ;

reg r_mcio10_prsnt_n_zt ; //2024-9-24
reg r_mcio8_prsnt_n_zt  ; //2024-9-24
reg r_mcio6_prsnt_n_zt  ; //2024-9-24
reg r_mcio4_prsnt_n_zt  ; //2024-9-24
reg r_zt_board_prsnt_n      ;
reg     [7:0]   r_switch_mode;

wire [7:0]   w_zt_board_id;
wire [7:0]   w_sw_board_id;
wire    w_zt_board_prsnt_n;

wire w_mcio_slot11_prsnt_n_1 ;
wire w_mcio_slot9_prsnt_n    ;
wire w_mcio_slot9_prsnt_n_1  ;
wire w_mcio_slot11_prsnt_n   ;
wire w_mcio_slot13_prsnt_n_1 ;

//-------------------------------------------------------------------------------------------------
//Switch2 & ZT2 BOARD
//-------------------------------------------------------------------------------------------------
wire    w_tpm431_alert_n_sw2       ; //u7
wire    w_ina3221_pwr_alert_sw2    ; //u7
wire    w_pal_3v3_pgd1_r_sw2       ; //u7
wire    w_pal_3v3_pgd2_r_sw2       ; //u7
wire    w_pal_3v3_pgd3_r_sw2       ; //u7
wire    w_pal_3v3_pgd4_r_sw2       ; //u7
wire    w_pal_3v3_pgd5_r_sw2       ; //u7
wire    w_u3_nc7_sw2               ; //u7

wire    w_slot1_prsnt_n_sw2        ; //u9
wire    w_slot2_prsnt_n_sw2        ; //u9
wire    w_slot3_prsnt_n_sw2        ; //u9
wire    w_slot4_prsnt_n_sw2        ; //u9
wire    w_slot5_prsnt_n_sw2        ; //u9
wire    w_slot6_prsnt_n_sw2        ; //u9
wire    w_slot7_prsnt_n_sw2        ; //u9
wire    w_slot8_prsnt_n_sw2        ; //u9

wire    w_slot9_prsnt_n_sw2        ; //u10
wire    w_slot10_prsnt_n_sw2       ; //u10
wire    w_slot11_prsnt_n_sw2       ; //u10
wire    w_slot12_prsnt_n_sw2       ; //u10
wire    w_slot13_prsnt_n_sw2       ; //u10
wire    w_mcio1_prsnt_n_sw2        ; //u10
wire    w_mcio2_prsnt_n_sw2        ; //u10
wire    w_mcio3_prsnt_n_sw2        ; //u10

wire    w_mcio4_prsnt_n_sw2        ; //u38
wire    w_mcio5_prsnt_n_sw2        ; //u38
wire    w_mcio6_prsnt_n_sw2        ; //u38
wire    w_mcio7_prsnt_n_sw2        ; //u38
wire    w_mcio8_prsnt_n_sw2        ; //u38
wire    w_mcio9_prsnt_n_sw2        ; //u38
wire    w_mcio10_prsnt_n_sw2       ; //u38
wire    w_mcio11_prsnt_n_sw2       ; //u38

wire    w_mcio12_prsnt_n_sw2       ; //u5
wire    w_mcio13_prsnt_n_sw2       ; //u5
wire    w_pcb_version2_sw2         ; //u5
wire    w_pcb_version1_sw2         ; //u5
wire    w_pcb_version0_sw2         ; //u5
wire    w_pca_version2_sw2         ; //u5
wire    w_pca_version1_sw2         ; //u5
wire    w_pca_version0_sw2         ; //u5

wire    w_board_id0_sw2            ;  //u6
wire    w_board_id1_sw2            ;  //u6
wire    w_board_id2_sw2            ;  //u6
wire    w_board_id3_sw2            ;  //u6
wire    w_board_id4_sw2            ;  //u6
wire    w_board_id5_sw2            ;  //u6
wire    w_board_id6_sw2            ;  //u6
wire    w_board_id7_sw2            ;  //u6

wire    w_ct_p1v25_sw0_pg_sw2      ; //u41
wire    w_ct_p1v25_sw1_pg_sw2      ; //u41
wire    w_p0v8_sw0_pwrgd_sw2       ; //u41
wire    w_p0v8_sw1_pwrgd_sw2       ; //u41
wire    w_slot1_wake_n_sw2         ; //u41
wire    w_slot2_wake_n_sw2         ; //u41
wire    w_slot3_wake_n_sw2         ; //u41
wire    w_slot4_wake_n_sw2         ; //u41

wire    w_slot5_wake_n_sw2         ; //u44
wire    w_slot6_wake_n_sw2         ; //u44
wire    w_slot7_wake_n_sw2         ; //u44
wire    w_slot8_wake_n_sw2         ; //u44
wire    w_slot9_wake_n_sw2         ; //u44
wire    w_slot10_wake_n_sw2        ; //u44
wire    w_slot11_wake_n_sw2        ; //u44
wire    w_slot12_wake_n_sw2        ; //u44

wire    w_pal_p12v_drop_sw2            ; //u40
wire    w_pg_p5v0_r_sw2                ; //u40
wire    w_pg_p1v8_r_sw2                ; //u40
wire    w_pg_p1v8_pll_r_sw2            ; //u40
wire    w_db2000_pwrgd0_sw2            ; //u40
wire    w_db2000_pwrgd1_sw2            ; //u40
wire    w_mcio_slot13_prsnt_n_1_sw2    ; //u40
wire    w_u40_nc7_sw2                  ; //u40
//zt2
wire    w_tpm431_alert_n_zt2       ;//u3
wire    w_ina3221_pwr_alert_zt2    ;//u3
wire    w_pal_3v3_pgd1_r_zt2       ;//u3
wire    w_pal_3v3_pgd2_r_zt2       ;//u3
wire    w_pal_3v3_pgd3_r_zt2       ;//u3
wire    w_pal_3v3_pgd4_r_zt2       ;//u3
wire    w_pal_3v3_pgd5_r_zt2       ;//u3
wire    w_u3_nc7_zt2               ;//u3

wire    w_slot1_prsnt_n_zt2        ;//u7
wire    w_slot2_prsnt_n_zt2        ;//u7
wire    w_slot3_prsnt_n_zt2        ;//u7
wire    w_slot4_prsnt_n_zt2        ;//u7
wire    w_slot5_prsnt_n_zt2        ;//u7
wire    w_slot6_prsnt_n_zt2        ;//u7
wire    w_slot7_prsnt_n_zt2        ;//u7
wire    w_slot8_prsnt_n_zt2        ;//u7
//in ZT BOARD                           
wire    w_slot9_prsnt_n_zt2        ;//u8    
wire    w_slot10_prsnt_n_zt2       ;//u8    
wire    w_slot11_prsnt_n_zt2       ;//u8    
wire    w_slot12_prsnt_n_zt2       ;//u8    
wire    w_slot13_prsnt_n_zt2       ;//u8    
wire    w_mcio1_prsnt_n_zt2        ;//u8    
wire    w_mcio2_prsnt_n_zt2        ;//u8    
wire    w_mcio3_prsnt_n_zt2        ;//u8 
   
wire    w_mcio4_prsnt_n_zt2        ;//u4    
wire    w_mcio5_prsnt_n_zt2        ;//u4    
wire    w_mcio6_prsnt_n_zt2        ;//u4    
wire    w_mcio7_prsnt_n_zt2        ;//u4    
wire    w_mcio8_prsnt_n_zt2        ;//u4    
wire    w_mcio9_prsnt_n_zt2        ;//u4    
wire    w_mcio10_prsnt_n_zt2       ;//u4    
wire    w_mcio11_prsnt_n_zt2       ;//u4 
   
wire    w_mcio12_prsnt_n_zt2       ;//u5    
wire    w_mcio13_prsnt_n_zt2       ;//u5    
wire    w_pcb_version2_zt2         ;//u5    
wire    w_pcb_version1_zt2         ;//u5    
wire    w_pcb_version0_zt2         ;//u5    
wire    w_pca_version2_zt2         ;//u5    
wire    w_pca_version1_zt2         ;//u5    
wire    w_pca_version0_zt2         ;//u5  
  
wire    w_board_id0_zt2            ;//u6    
wire    w_board_id1_zt2            ;//u6    
wire    w_board_id2_zt2            ;//u6    
wire    w_board_id3_zt2            ;//u6    
wire    w_board_id4_zt2            ;//u6    
wire    w_board_id5_zt2            ;//u6    
wire    w_board_id6_zt2            ;//u6    
wire    w_board_id7_zt2            ;//u6   
  
wire    w_mcio1_prsnt_n_1_zt2      ;//u18   
wire    w_mcio2_prsnt_n_1_zt2      ;//u18   
wire    w_mcio3_prsnt_n_1_zt2      ;//u18   
wire    w_mcio4_prsnt_n_1_zt2      ;//u18   
wire    w_mcio5_prsnt_n_1_zt2      ;//u18   
wire    w_mcio7_prsnt_n_1_zt2      ;//u18   
wire    w_mcio9_prsnt_n_1_zt2      ;//u18   
wire    w_mcio10_prsnt_n_1_zt2     ;//u18 
  
wire    w_mcio11_prsnt_n_1_zt2     ;//u19   
wire    w_mcio12_prsnt_n_1_zt2     ;//u19   
wire    w_u19_nc2_zt2              ;//u19   
wire    w_u19_nc3_zt2              ;//u19   
wire    w_u19_nc4_zt2              ;//u19   
wire    w_u19_nc5_zt2              ;//u19   
wire    w_u19_nc6_zt2              ;//u19   
wire    w_u19_nc7_zt2              ;//u19   

reg      r_board_id0_zt2     ;
reg      r_board_id1_zt2     ;
reg      r_board_id2_zt2     ;
reg      r_board_id3_zt2     ;
reg      r_board_id4_zt2     ;
reg      r_board_id5_zt2     ;
reg      r_board_id6_zt2     ;
reg      r_board_id7_zt2     ;
reg      r_pcb_version2_zt2  ;
reg      r_pcb_version1_zt2  ;
reg      r_pcb_version0_zt2  ;
reg      r_pca_version2_zt2  ;
reg      r_pca_version1_zt2  ;
reg      r_pca_version0_zt2  ;
reg      r_mcio9_prsnt_n_zt2 ;
reg      r_mcio7_prsnt_n_zt2 ;
reg      r_mcio3_prsnt_n_zt2 ;
reg      r_mcio1_prsnt_n_zt2 ;
reg      r_mcio10_prsnt_n_zt2 ; //2024-9-24
reg      r_mcio8_prsnt_n_zt2  ; //2024-9-24
reg      r_mcio6_prsnt_n_zt2  ; //2024-9-24
reg      r_mcio4_prsnt_n_zt2  ; //2024-9-24

wire    w_zt2_mcio_slot11_prsnt_n_1 ;
wire    w_zt2_mcio_slot9_prsnt_n    ;
wire    w_zt2_mcio_slot9_prsnt_n_1  ;
wire    w_zt2_mcio_slot11_prsnt_n   ;
wire    w_zt2_mcio_slot13_prsnt_n_1 ;
wire    [5:0]   pvti_zt2_count;
wire    [2:0]   pvti_sw2_u2_count1;
wire    [7:0]   w_zt2_board_id;
wire    [7:0]   w_sw2_board_id;
reg      [7:0]   r_switch2_mode;
reg      r_zt2_board_prsnt_n      ;
wire    w_zt2_board_prsnt_n;

wire    w_bmc_jtag_mux_s;


wire    w_pgd_p12v_droop_neg;
reg     r_p12v_discharge_r;
wire    w_p12v_discharge_r;

//SN74LV165     PVT_DATA
//U152_DATA
wire    w_P0_MCIOP0C_CB_ID1_R;
wire    w_P0_MCIOP0C_CB_ID0_R;
wire    w_P0_MCIOP0A_CB_ID1_R;
wire    w_P0_MCIOP0A_CB_ID0_R;
wire    w_P0_MCIOP1C_CB_ID1_R;
wire    w_P0_MCIOP1C_CB_ID0_R;
wire    w_P0_MCIOP1A_CB_ID1_R;
wire    w_P0_MCIOP1A_CB_ID0_R;
//U153_DATA
wire    w_P0_MCIOP2A_CB_ID0_R;
wire    w_P0_MCIOP2A_CB_ID1_R;
wire    w_P0_MCIOP2C_CB_ID0_R;
wire    w_P0_MCIOP2C_CB_ID1_R;
wire    w_P0_MCIOP3C_CB_ID1_R;
wire    w_P0_MCIOP3C_CB_ID0_R;
wire    w_P0_MCIOP3A_CB_ID1_R;
wire    w_P0_MCIOP3A_CB_ID0_R;
//U154_DATA
wire    w_P1_MCIOG1A_CB_ID0_R;
wire    w_P1_MCIOG1A_CB_ID1_R;
wire    w_P1_MCIOG1C_CB_ID0_R;
wire    w_P1_MCIOG1C_CB_ID1_R;
wire    w_P0_MCIOG3A_CB_ID0_R;
wire    w_P0_MCIOG3A_CB_ID1_R;
wire    w_P0_MCIOG3C_CB_ID0_R;
wire    w_P0_MCIOG3C_CB_ID1_R;
//U155_DATA
wire    w_SW_1;
wire    w_SW_2;
wire    w_SW_3;
wire    w_SW_4;
wire    w_SW_5;
wire    w_SW_6;
wire    w_SW_7;
wire    w_SW_8;
//U156_DATA
wire    w_PAL_BP4_AUX_PG;
wire    w_PAL_STBY_FAN_SHTDN;
wire    w_PG_P12V_SLOT_9;
wire    w_PG_P12V_SLOT_7;
wire    w_PAL_BP6_PRSNT_N;
wire    w_P1_MCIOP4A_CB_ID1_R;
wire    w_PG_P12V_SLOT_3;
wire    w_PAL_OCP1_HP_BUTTON_N;
//U157_DATA
wire    w_PG_P12V_SLOT_6;
wire    w_FAN_PRSNT_R;
wire    w_PAL_SLIMSAS1_PRSNT_N;
wire    w_NODE1_TYPE;
wire    w_PAL_MEN_CPU_SHTDN;
wire    w_PAL_S5_CPU_SHTDN;
wire    w_U157_NC_G;
wire    w_U157_NC_H;
//U158_DATA
wire    w_P1_MCIOP3C_CB_ID1_R;
wire    w_P1_MCIOP3C_CB_ID0_R;
wire    w_P1_MCIOP3A_CB_ID1_R;
wire    w_P1_MCIOP3A_CB_ID0_R;
wire    w_OCP1_CABLE_PRSNT_R ;
wire    w_PAL_OCP1_PRSNT_B1_N;
wire    w_PAL_OCP1_PRSNT_B2_N;
wire    w_PAL_OCP1_PRSNT_B0_N;
//U159_DATA
wire    w_U159_NC_A;
wire    w_U159_NC_B;
wire    w_U159_NC_C;
wire    w_U159_NC_D;
wire    w_PAL_M2_0_PRSNT_N;
wire    w_NCSI_PRSNT_N;
wire    w_BMC_CARD_PRSNT_N;
wire    w_PAL_M2_1_PRSNT_N;

wire [6:0]pvti_ss_count;


wire    w_ocp_prsnt_n;

//-------------------------------------------------------------------------------------------------
// PLL功能模块例化（锁相环时钟生成）
// 功能：
// 1. 输入25MHz时钟信号（i_CLK_25M_CPLD），通过PLL模块生成两个输出时钟：
//    - 50MHz时钟信号（clk_50m）
//    - 25MHz时钟信号（clk_25m）
// 2. 输出PLL锁定信号（pll_lock），用于指示时钟稳定状态。
//-------------------------------------------------------------------------------------------------
pll_i25M_o50M_o25M pll_inst(
  .CLKI     (i_CLK_25M_CPLD         ), // 输入时钟信号，频率为25MHz
  .RST      (~i_PWRGD_P3V3_STBY     ), // 复位信号，低电平有效
  .CLKOP    (clk_50m                ), // 输出50MHz时钟信号
  .CLKOS    (clk_25m                ), // 输出25MHz时钟信号
  // .CLKOS2 (clk_2p5m               ), // 未使用的2.5MHz时钟信号
  .LOCK     (pll_lock               )  // 输出PLL锁定信号
);

//-------------------------------------------------------------------------------------------------
// 电源复位模块（Power-On Reset）
// 功能：
// 1. 生成系统的电源复位信号（pon_reset_n），基于电源良好信号（pgd_p3v3_stby）和PLL锁定信号（pll_lock）。
// 2. 提供去抖动后的复位信号（pon_reset_db_n）。
// 3. 生成辅助系统电源良好信号（pgd_aux_system）及其SASD版本（pgd_aux_system_sasd）。
//-------------------------------------------------------------------------------------------------
pon_reset pon_reset_inst(
  .clk                  (clk_50m                ), // 输入时钟信号，频率为50MHz
  .pll_lock             (pll_lock               ), // 输入PLL锁定信号
  .pgd_p3v3_stby        (i_PWRGD_P3V3_STBY      ), // 输入3.3V电源良好信号
  .pgd_aux_gmt          (pgd_aux_bmc            ), // 输入BMC辅助电源良好信号
  .done_booting         (1'b1                   ), // 固定高电平，表示启动完成
  .done_booting_delayed (done_booting_delayed   ), // 延迟的启动完成信号
  .pon_reset_n          (pon_reset_n            ), // 输出电源复位信号
  .pon_reset_db_n       (pon_reset_db_n         ), // 输出去抖动后的电源复位信号
  .pgd_aux_system       (pgd_aux_system         ), // 输出辅助系统电源良好信号
  .pgd_aux_system_sasd  (pgd_aux_system_sasd    ), // 输出SASD版本的辅助系统电源良好信号
  .cpld_ready           (                        )  // 未使用的CPLD准备信号
);

// ------------------------------------------------------------------------------------------------------------
// 时钟生成模块，能够基于输入时钟生成多种定时信号和慢速时钟信号
//--------------------------------------------------------------------------------------------------------------
timer_gen timer_gen_inst(
  .clk               (clk_50m          ), // 输入时钟信号，频率为 50 MHz
  .reset             (~pon_reset_n    ), // 异步复位信号，低电平有效
  .t40ns             (t40ns_tick      ), // 40 纳秒脉冲
  .t80ns             (),                 // 80 纳秒脉冲（未使用）
  .t160ns            (),                 // 160 纳秒脉冲（未使用）
  .t1us              (t1us_tick       ), // 1 微秒脉冲
  .t2us              (t2us_tick       ), // 2 微秒脉冲
  .t16us             (t16us_tick      ), // 16 微秒脉冲
  .t32us             (t32us_tick      ), // 32 微秒脉冲
  .t128us            (t128us_tick     ), // 128 微秒脉冲
  .t512us            (t512us_tick     ), // 512 微秒脉冲
  .t1ms              (t1ms_tick       ), // 1 毫秒脉冲
  .t2ms              (t2ms_tick       ), // 2 毫秒脉冲
  .t16ms             (),                 // 16 毫秒脉冲（未使用）
  .t32ms             (t32ms_tick      ), // 32 毫秒脉冲
  .t64ms             (t64ms_tick      ), // 64 毫秒脉冲
  .t128ms            (t128ms_tick     ), // 128 毫秒脉冲
  .t256ms            (t256ms_tick     ), // 256 毫秒脉冲
  .t512ms            (t512ms_tick     ), // 512 毫秒脉冲
  .t1s               (t1s_tick        ), // 1 秒脉冲
  .clk_1hz           (t1hz_clk        ), // 1 Hz 时钟信号
  .clk_2p5hz         (t2p5hz_clk      ), // 2.5 Hz 时钟信号
  .clk_4hz           (t4hz_clk        ), // 4 Hz 时钟信号
  .clk_16khz         (t16khz_clk      ), // 16 kHz 时钟信号
  .clk_6m25          (t6m25_clk       ), // 6.25 MHz 时钟信号
  .clk_16m6          (t16m6_clk       )  // 16.6 MHz 时钟信号
);

// ------------------------------------------------------------------------------------------------------------
// 生成多个同步时钟使能信号（Clock Enables, CEs) 10uS, 50uS, 500uS, 1mS, 20mS and 250mS
//--------------------------------------------------------------------------------------------------------------
ClkDivTree mClkDivTree (
    .iClk           ( clk_50m            ), // 输入时钟信号，频率为50 MHz
    .iRst           ( ~pon_reset_n       ), // 异步复位信号，低电平有效
    .o1uSCE         ( w1uSCE             ), // 输出1微秒时钟使能信号
    .o10uSCE        ( w10uSCE            ), // 输出10微秒时钟使能信号
    .o50uSCE        ( w50uSCE            ), // 输出50微秒时钟使能信号
    .o500uSCE       ( w500uSCE           ), // 输出500微秒时钟使能信号
    .o1mSCE         ( w1mSCE             ), // 输出1毫秒时钟使能信号
    .o250mSCE       ( w250mSCE           ), // 输出250毫秒时钟使能信号
    .o10mSCE        ( w10mSCE            ), // 输出10毫秒时钟使能信号
    .o20mSCE        ( w20mSCE            ), // 输出20毫秒时钟使能信号
    .o1SCE          ( w1SCE              )  // 输出1秒时钟使能信号
);

// -------------------------------------------------------------------------------------------------------------
// 内部振荡器（未使用）
//--------------------------------------------------------------------------------------------------------------
wire wb_clk;
defparam inst_osch.NOM_FREQ = "4.29";
OSCH inst_osch(
    .STDBY      (1'b0       ), // 输入，控制振荡器是否进入待机模式
    .OSC        (wb_clk     ), // 输出，振荡器生成的时钟信号
    .SEDSTDBY   (           )  // 输出，振荡器进入待机模式的状态信号（未使用）
);

// -------------------------------------------------------------------------------------------------------------
// I2C_UPDATE模块实例化
// 功能：
// 1. 通过I2C接口与外部设备（如Flash存储器）通信。
// 2. 支持Wishbone总线协议，用于主控与I2C外设之间的数据传输和配置更新。
// -------------------------------------------------------------------------------------------------------------
I2C_UPDATE inst_i2c_update_flash_config(
    .wb_clk_i    (wb_clk                ), // Wishbone 时钟信号，输入
    .wb_rst_i    (                      ), // Wishbone 复位信号，未使用
    .wb_cyc_i    (                      ), // Wishbone 总线周期信号，未使用
    .wb_stb_i    (                      ), // Wishbone 选通信号，未使用
    .wb_we_i     (                      ), // Wishbone 写使能信号，未使用
    .wb_adr_i    (                      ), // Wishbone 地址信号，未使用
    .wb_dat_i    (                      ), // Wishbone 数据输入信号，未使用
    .wb_dat_o    (                      ), // Wishbone 数据输出信号，未使用
    .wb_ack_o    (                      ), // Wishbone 应答信号，未使用
    .i2c1_irqo   (                      ), // I2C 中断信号，未使用
    .wbc_ufm_irq (                      ), // 用户闪存中断信号，未使用
    .i2c1_scl    (io_I2C7_UPDATE_SCL    ), // I2C 时钟信号，与外部设备连接
    .i2c1_sda    (io_I2C7_UPDATE_SDA    )  // I2C 数据信号，与外部设备连接
);
										   
// -------------------------------------------------------------------------------------------------------------
// PGM_DEBOUNCE模块实例化
// 功能：
// 1. 对输入信号进行去抖动处理，确保信号稳定。
// 2. 使用时钟信号和定时信号对输入信号进行采样和滤波。
// 3. 输出去抖动后的稳定信号。
// -------------------------------------------------------------------------------------------------------------
// 电源按钮信号去抖动
// 按下按钮，服务器前面的蓝色指示灯（LED）会亮起或闪烁，使操作者在机架中能快速找到目标服务器
PGM_DEBOUNCE #(
    .SIGCNT(3), 
    .NBITS(2'b10), 
    .ENABLE(1'b1)
) db_inst_pwr_btn(
    .clk(clk_50m),                      // 时钟信号，频率为50MHz
    .rst(~pon_reset_n),                 // 复位信号，低电平有效
    .timer_tick(t32ms_tick),            // 定时信号，32ms周期
    .din({
          i_PAL_PWR_BTN_N,              // 输入信号1：电源按钮信号
          i_PAL_BUTTOPN_RST_N,          // 输入信号2：外部复位按钮信号
          i_PAL_BMCUID_BUTTON           // 输入信号3：BMC UID按钮信号
        }),
    .dout({
          db_i_pwr_btn_cpld_n_r,        // 输出信号1：去抖动后的电源按钮信号
          db_i_pal_ext_rst_n,           // 输出信号2：去抖动后的外部复位按钮信号
          db_i_pal_bmcuid_button        // 输出信号3：去抖动后的BMC UID按钮信号
        }) 
);

// VR OCP信号去抖动
// 过流保护（Over Current Protection, OCP）
// 作用: VR OCP信号用于检测电压调节器是否发生了过流情况。当电流超过预设的安全阈值时，OCP信号会被触发。
// 用途: 防止电路因过流而损坏，保护电源模块和负载设备的安全。
PGM_DEBOUNCE #(
    .SIGCNT(6), 
    .NBITS(2'b10), 
    .ENABLE(1'b1)
) db_vr_ocp_low (
    .clk(clk_50m),                      // 时钟信号，频率为50MHz
    .rst(~pon_reset_n),                 // 复位信号，低电平有效
    .timer_tick(t64ms_tick),            // 定时信号，64ms周期
    .din({
          i_P0_VDD_CORE_0_OCP_N_R,      // 输入信号1：VR OCP信号1
          i_PAL_P0_VDD_CORE_1_OCP_N,    // 输入信号2：VR OCP信号2
          i_P0_VDDIO_OCP_N,             // 输入信号3：VR OCP信号3
          i_P1_VDD_CORE_0_OCP_N_R,      // 输入信号4：VR OCP信号4
          i_PAL_P1_VDD_CORE_1_OCP_N,    // 输入信号5：VR OCP信号5
          i_P1_VDDIO_OCP_N              // 输入信号6：VR OCP信号6
        }),
    .dout({
        db_i_p0_vdd_core_0_ocp_n_r,   // 输出信号1：去抖动后的VR OCP信号1
        db_i_pal_p0_vdd_core_1_ocp_n, // 输出信号2：去抖动后的VR OCP信号2
        db_i_p0_vddio_ocp_n,          // 输出信号3：去抖动后的VR OCP信号3
        db_i_p1_vdd_core_0_ocp_n_r,   // 输出信号4：去抖动后的VR OCP信号4
        db_i_pal_p1_vdd_core_1_ocp_n, // 输出信号5：去抖动后的VR OCP信号5
        db_i_p1_vddio_ocp_n           // 输出信号6：去抖动后的VR OCP信号6
      }) 
);

// PSU信号去抖动
// 监控过流情况: 检测电压调节器是否发生过流。
// 信号去抖动: 确保信号稳定，避免误判。
// 故障保护: 在过流情况下触发保护机制，防止系统损坏。
// 与电源管理交互: 确保系统能够安全地处理过流故障。
/*
PGM_DEBOUNCE #(.SIGCNT(10), .NBITS(2'b10), .ENABLE(1'b1)) db_inst_psu (
  .clk(clk_50m),                      // 时钟信号，频率为50MHz
  .rst(~pon_reset_n),                 // 复位信号，低电平有效
  .timer_tick(t64ms_tick),            // 定时信号，64ms周期
  .din({
        i_PS1_PRSNT,                  // 输入信号1：PSU1存在信号
        i_PS1_DCOK_N,                 // 输入信号2：PSU1直流电源正常信号
        i_PS1_SMB_ALERT,              // 输入信号3：PSU1 SMBus警告信号
        i_PS1_ACFAIL_N,               // 输入信号4：PSU1交流电源故障信号
        i_PS2_PRSNT,                  // 输入信号5：PSU2存在信号
        i_PS2_DCOK_N,                 // 输入信号6：PSU2直流电源正常信号
        i_PS2_SMB_ALERT,              // 输入信号7：PSU2 SMBus警告信号
        i_PS2_ACFAIL_N,               // 输入信号8：PSU2交流电源故障信号
        w_ps3_prsnt,                  // 输入信号9：PSU3存在信号
        w_ps4_prsnt                   // 输入信号10：PSU4存在信号
  }),
  .dout({
        db_i_ps1_prsnt,               // 输出信号1：去抖动后的PSU1存在信号
        db_i_ps1_dcok_n,              // 输出信号2：去抖动后的PSU1直流电源正常信号
        db_i_ps1_smb_alert,           // 输出信号3：去抖动后的PSU1 SMBus警告信号
        db_i_ps1_acfail_n,            // 输出信号4：去抖动后的PSU1交流电源故障信号
        db_i_ps2_prsnt,               // 输出信号5：去抖动后的PSU2存在信号
        db_i_ps2_dcok_n,              // 输出信号6：去抖动后的PSU2直流电源正常信号
        db_i_ps2_smb_alert,           // 输出信号7：去抖动后的PSU2 SMBus警告信号
        db_i_ps2_acfail_n,            // 输出信号8：去抖动后的PSU2交流电源故障信号
        db_i_ps3_prsnt,               // 输出信号9：去抖动后的PSU3存在信号
        db_i_ps4_prsnt                // 输出信号10：去抖动后的PSU4存在信号
  })
);
*/

//CPU Signal DEBOUNCE CPU 信号同步模块 对 CPU 相关信号进行同步处理，确保跨时钟域或异步信号在 CPU 逻辑中稳定有效
//Active Low Reset
SYNC_DATA_N #(.SIGCNT(18)) sync_cpu_data_low (
    .clk    (clk_50m),
    .rst_n  (pon_reset_n),          
    .din    ({
			        (i_P0_SLP_S3_N | w_cpu_module_p0_slp_s3_n)	,//01	P0 SLP S3 信号（低电平有效），P0 睡眠 S3 状态指示
			        (i_P0_SLP_S5_N | w_cpu_module_p0_slp_s5_n)	,//02	P0 SLP S5 信号（低电平有效），P0 睡眠 S5 状态指示
               i_P1_SLP_S3_N				                      ,//03//unused	P1 SLP S3 信号（低电平有效），P1 睡眠 S3 状态指示，标注为未使用
               i_P1_SLP_S5_N				                      ,//04//unused	P1 SLP S5 信号（低电平有效），P1 睡眠 S5 状态指示，标注为未使用
			         i_P0_PWROK								                  ,//05//& cpu_module_p0_pwrok)	, 	P0 电源好信号，P0 电源稳定指示
 			         i_P1_PWROK								                  ,//06//& cpu_module_p1_pwrok)	, 	P1 电源好信号，P1 电源稳定指示
			         i_P0_RESET_N							                  ,//07	P0 复位信号（低电平有效），P0 复位控制
			         i_P1_RESET_N							                  ,//08	P1 复位信号（低电平有效），P1 复位控制
			         i_P0_PWRGD_OUT							                ,//09//| cpu_module_p0_pwrgdout),	P0 电源好输出信号，P0 电源好对外输出           
			         i_P1_PWRGD_OUT							                ,//10//| cpu_module_p1_pwrgdout),	P1 电源好输出信号，P1 电源好对外输出 
			         i_P0_SMERR_N							                  ,//11//unused	P0 系统错误信号（低电平有效），P0 系统错误指示，标注为未使用
			         i_P1_SMERR_N							                  ,//12//unused	P1 系统错误信号（低电平有效），P1 系统错误指示，标注为未使用
			         i_P0_PCIE_RST_N_0						              ,//13	P0 PCIE 复位信号 0（低电平有效），P0 PCIE 复位控制
			         i_P0_PCIE_RST_N_1						              ,//14	P0 PCIE 复位信号 1（低电平有效），P0 PCIE 复位控制
			         i_P1_PCIE_RST_N_0						              ,//15
			         i_P1_PCIE_RST_N_1						              ,//16
			         i_P0_BIOS_POST_STAGE_R_N		                ,//17	P0 BIOS 启动阶段复位信号（低电平有效），P0 BIOS 启动阶段复位控制
               i_FM_CPU_SMERR_LVC3_N_R                     //18 前面板输入的、低有效的系统严重错误信号
			        }),			
    .dout   ({
	  		      db_i_p0_slp_s3_n			                      ,//01	同步后的 P0 SLP S3 信号（低电平有效），稳定的 P0 睡眠 S3 状态指示
	  		      db_i_p0_slp_s5_n			                      ,//02	同步后的 P0 SLP S5 信号（低电平有效），稳定的 P0 睡眠 S5 状态指示
	  		      db_i_p1_slp_s3_n			                      ,//03//unused	同步后的 P1 SLP S3 信号（低电平有效），稳定的 P1 睡眠 S3 状态指示，仍标注为未使用
	  		      db_i_p1_slp_s5_n			                      ,//04//unused   同步后的 P1 SLP S5 信号（低电平有效），稳定的 P1 睡眠 S5 状态指示，仍标注为未使用     
	  		      db_i_p0_pwrok				                        ,//05
	  		      db_i_p1_pwrok				                        ,//06
	  		      db_i_p0_reset_n				                      ,//07
	  		      db_i_p1_reset_n				                      ,//08
	  		      db_i_p0_pwrgd_out			                      ,//09
	  		      db_i_p1_pwrgd_out			                      ,//10
	  		      db_i_p0_smerr_n				                      ,//11//unused
	  		      db_i_p1_smerr_n				                      ,//12//unused
	  		      db_i_p0_pcie_rst_n_0		                    ,//13
	  		      db_i_p0_pcie_rst_n_1		                    ,//14
	  		      db_i_p1_pcie_rst_n_0		                    ,//15
	  		      db_i_p1_pcie_rst_n_1		                    ,//16
	  		      db_i_p0_bios_post_stage_r_n                 ,//17
              db_i_fm_cpu_smerr_lvc3_n_r                   //18
	  		      })      
);

//cpu thermtrip Signal DEBOUNCE	CPU 热跳闸信号消抖模块 对 CPU 热跳闸相关信号进行消抖处理，确保热跳闸信号稳定，避免因抖动导致误触发热保护													
PGM_DEBOUNCE #(
    .SIGCNT(4), 
    .NBITS(2'b10), 
    .ENABLE(1'b1)
) db_cpu_thermtrip (
    .clk(clk_50m),
    .rst(~pon_reset_n),
    .timer_tick(1'b1),
    .din({
		    i_P0_VR_I2C_ALERT_N	           ,//01	P0 VR（电压调节模块）I2C7 告警信号（低电平有效），P0 VR 通过 I2C7 产生的告警
        i_P1_VR_I2C_ALERT_N	           ,//02	P1 VR I2C7 告警信号（低电平有效），P1 VR 通过 I2C7 产生的告警
	      i_P0_THERMTRIP_N               ,//03	P0 热跳闸信号（低电平有效），P0 热保护跳闸指示
	      i_P1_THERMTRIP_N                //04	P1 热跳闸信号（低电平有效），P1 热保护跳闸指示
        }),             
    .dout({
        db_i_p0_vr_i2c_alert_n         ,//01
        db_i_p1_vr_i2c_alert_n         ,//02
        db_cpu_thermaltrip_n[0]        ,//03 
        db_cpu_thermaltrip_n[1]         //04 
  }) 
);

// PGD电源良好信号进行去抖动处理，确保信号稳定
PGM_DEBOUNCE_N #(
    .SIGCNT(21), 
    .NBITS(2'b11), 
    .ENABLE(1'b1)
) db_inst_pwrgood (
    .clk			  (clk_50m    ), // 时钟信号，频率为50MHz
    .rst_n		  (pon_reset_n), // 复位信号，低电平有效
    .timer_tick	(1'b1       ), // 定时信号，始终为高电平
    .din({
        i_P1V8_STBY_PG,              // 输入信号1 ：1.8V待机电源良好信号
        i_PWRGD_P3V3_STBY,           // 输入信号2 ：3.3V待机电源良好信号
        i_PG_P5V_STBY,               // 输入信号3 ：5V待机电源良好信号
        i_PGD_P0_VDD_18_STBY,        // 输入信号4 ：P0 1.8V待机电源良好信号
        i_PGD_P1_VDD_18_STBY,        // 输入信号5 ：P1 1.8V待机电源良好信号
        i_PGD_P0_VDDC,               // 输入信号6 ：P0核心电压电源良好信号
        i_PGD_P1_VDDC,               // 输入信号7 ：P1核心电压电源良好信号
        i_PGD_P0_VDD_11_SUS,         // 输入信号8 ：P0 1.1V挂起电源良好信号
        i_PGD_P1_VDD_11_SUS,         // 输入信号9 ：P1 1.1V挂起电源良好信号
        i_PGD_P0_VDD_CORE_0,         // 输入信号10：P0核心电压0电源良好信号
        i_PGD_P1_VDD_CORE_0,         // 输入信号11：P1核心电压0电源良好信号
        i_PGD_P0_VDD_CORE_1,         // 输入信号12：P0核心电压1电源良好信号
        i_PGD_P1_VDD_CORE_1,         // 输入信号13：P1核心电压1电源良好信号
        i_PGD_P0_VDD_SOC_0,          // 输入信号14：P0 SOC电压电源良好信号
        i_PGD_P1_VDD_SOC_0,          // 输入信号15：P1 SOC电压电源良好信号
        i_PGD_P0_VDDIO,              // 输入信号16：P0 IO电压电源良好信号
        i_PGD_P1_VDDIO,              // 输入信号17：P1 IO电压电源良好信号
        i_PGD_P3V3_STBY_B,           // 输入信号18：备用3.3V待机电源良好信号
        i_PGD_P1V2_STBY,             // 输入信号19：1.2V待机电源良好信号
        i_PGD_P5V,                   // 输入信号20：5V电源良好信号
        i_PG_P1V0_STBY_M2_R          // 输入信号21：1.0V待机电源良好信号
       }),             
  .dout({
        db_i_p1v8_stby_pg,           // 输出信号1：去抖动后的1.8V待机电源良好信号
        db_i_pwrgd_p3v3_stby,        // 输出信号2：去抖动后的3.3V待机电源良好信号
        db_i_pg_p5v_stby,            // 输出信号3：去抖动后的5V待机电源良好信号
        db_i_pgd_p0_vdd_18_stby,     // 输出信号4：去抖动后的P0 1.8V待机电源良好信号
        db_i_pgd_p1_vdd_18_stby,     // 输出信号5：去抖动后的P1 1.8V待机电源良好信号
        db_i_pgd_p0_vddc,            // 输出信号6：去抖动后的P0核心电压电源良好信号
        db_i_pgd_p1_vddc,            // 输出信号7：去抖动后的P1核心电压电源良好信号
        db_i_pgd_p0_vdd_11_sus,      // 输出信号8：去抖动后的P0 1.1V挂起电源良好信号
        db_i_pgd_p1_vdd_11_sus,      // 输出信号9：去抖动后的P1 1.1V挂起电源良好信号
        db_i_pgd_p0_vdd_core_0,      // 输出信号10：去抖动后的P0核心电压0电源良好信号
        db_i_pgd_p1_vdd_core_0,      // 输出信号11：去抖动后的P1核心电压0电源良好信号
        db_i_pgd_p0_vdd_core_1,      // 输出信号12：去抖动后的P0核心电压1电源良好信号
        db_i_pgd_p1_vdd_core_1,      // 输出信号13：去抖动后的P1核心电压1电源良好信号
        db_i_pgd_p0_vdd_soc_0,       // 输出信号14：去抖动后的P0 SOC电压电源良好信号
        db_i_pgd_p1_vdd_soc_0,       // 输出信号15：去抖动后的P1 SOC电压电源良好信号
        db_i_pgd_p0_vddio,           // 输出信号16：去抖动后的P0 IO电压电源良好信号
        db_i_pgd_p1_vddio,           // 输出信号17：去抖动后的P1 IO电压电源良好信号
        db_i_pgd_p3v3_stby_b,        // 输出信号18：去抖动后的备用3.3V待机电源良好信号
        db_i_pgd_p1v2_stby,          // 输出信号19：去抖动后的1.2V待机电源良好信号
        db_i_pgd_p5v,                // 输出信号20：去抖动后的5V电源良好信号
        db_i_pg_p1v0_stby_m2_r       // 输出信号21：去抖动后的1.0V待机电源良好信号
      }) 
);

// 设备存在信号和 SPD 主控信号信号去抖
PGM_DEBOUNCE #(
    .SIGCNT(3), 
    .NBITS(2'b11), 
    .ENABLE(1'b1)
) db_inst_amd_cpu_prsnt(   
    .clk(clk_50m),                               // 时钟信号，频率为50MHz
    .timer_tick(t512us_tick),                    // 定时信号，512微秒周期
    .rst(~pon_reset_n),                          // 复位信号，低电平有效
    .din({  
        (i_P0_PRSNT_N & w_cpu_module_p0_prsnt_n),  // 输入信号1：P0设备存在信号
        (i_P1_PRSNT_N & w_cpu_module_p1_prsnt_n),  // 输入信号2：P1设备存在信号
        i_P0_SPD_HOST_CTRL_N                     // 输入信号3：P0 SPD主控信号
        }),  
    .dout({	  
        db_cpu_prsnt_n_db[0],                       // 输出信号1：去抖动后的P0设备存在信号
        db_cpu_prsnt_n_db[1],                       // 输出信号2：去抖动后的P1设备存在信号
        db_i_p0_spd_host_ctrl_n                  // 输出信号3：去抖动后的P0 SPD主控信号
        })
);

// 最终选择逻辑：若启用覆盖，则取 r_dip_cpu_prsnt_n；否则使用去抖结果 db_cpu_prsnt_n_db
assign db_cpu_prsnt_n = r_dip_cpu_prsnt_override ? r_dip_cpu_prsnt_n : db_cpu_prsnt_n_db;

// 12V电源和12V待机电源的电压下跌信号去抖
PGM_DEBOUNCE #(.SIGCNT(2), .NBITS(2'b10), .ENABLE(1'b1)) db_p12v_droop (
  .clk(clk_50m),                      // 时钟信号，频率为50MHz
  .rst(~pon_reset_n),                 // 复位信号，低电平有效
  .timer_tick(t64ms_tick),            // 定时信号，64ms周期
  .din({
             i_PGD_P12V_DROOP,        // 输入信号1：12V电源电压下跌信号
             i_PGD_P12V_STBY_DROOP    // 输入信号2：12V待机电源电压下跌信号
  }),
  .dout({
             db_i_pgd_p12v_droop,     // 输出信号1：去抖动后的12V电源电压下跌信号
             db_i_pgd_p12v_stby_droop // 输出信号2：去抖动后的12V待机电源电压下跌信号
  })
);

// -------------------------------------------------------------------------------------------------------------
// Edge_Detect边沿检测模块实例化
// -------------------------------------------------------------------------------------------------------------
Edge_Detect Edge_Detect_U1(    // 2023-3-9 添加
    .i_clk               (clk_50m),               // 输入时钟信号，频率为 50MHz
    .i_rst_n             (pon_reset_n),           // 复位信号，低电平有效
    .i_signal            (i_PGD_P12V_DROOP),      // 输入信号：12V 电源电压下跌信号
    .o_signal_pos        (),                      // 输出信号：上升沿检测（未使用）
    .o_signal_neg        (w_pgd_p12v_droop_neg),  // 输出信号：下降沿检测
    .o_signal_invert     ()                       // 输出信号：信号翻转（未使用）
);

always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
        r_p12v_discharge_r <= 1'b0;
	end
	else if(w_pgd_p12v_droop_neg) begin
        r_p12v_discharge_r <= 1'b1;
	end
end
assign  w_p12v_discharge_r = r_p12v_discharge_r;


//-------------------------------------------------------------------------------------------------
// PVT_GPI 模块实例化
//-------------------------------------------------------------------------------------------------
// 功能：
// 1. 通过串行输入信号采集多个并行数据位。
// 2. 支持串行时钟输入和并行加载信号输入。
// 3. 输出采集到的并行数据，用于后续逻辑处理。
pvt_gpi #(
  .TOTAL_BIT_COUNT(64),               // 总位宽：64位
  .DEFAULT_STATE(64'h0),              // 默认状态：全为0
  .NUMBER_OF_COUNTER_BITS(7)          // 计数器位宽：7位
) pvt_gpi_MB_inst (
  .clk           (clk_50m),           // 输入时钟信号，频率为50MHz
  .reset_n       (pon_reset_n),       // 复位信号，低电平有效
  .clk_ena       (t16us_tick),        // 时钟使能信号，16微秒周期
  .serclk_in     (o_PVT_SS_CLK_R),    // 串行时钟输入信号
  .par_load_in_n (o_PVT_SS_LD_N_R),   // 并行加载信号输入，低电平有效
  .sdi           (i_PVT_SS_DATI),     // 串行数据输入信号
  .bit_idx_in    (pvti_ss_count),     // 输入位索引
  .bit_idx_out   (pvti_ss_count),     // 输出位索引
  .serclk_out    (o_PVT_SS_CLK_R),    // 串行时钟输出信号
  .par_load_out_n(o_PVT_SS_LD_N_R),   // 并行加载信号输出，低电平有效

  // 并行数据输出信号
  .par_data      ({
                              w_P0_MCIOP0C_CB_ID1_R, w_P0_MCIOP0C_CB_ID0_R, w_P0_MCIOP0A_CB_ID1_R, w_P0_MCIOP0A_CB_ID0_R, // U152 数据
                              w_P0_MCIOP1C_CB_ID1_R, w_P0_MCIOP1C_CB_ID0_R, w_P0_MCIOP1A_CB_ID1_R, w_P0_MCIOP1A_CB_ID0_R, // U153 数据
                              w_P0_MCIOP2A_CB_ID0_R, w_P0_MCIOP2A_CB_ID1_R, w_P0_MCIOP2C_CB_ID0_R, w_P0_MCIOP2C_CB_ID1_R, // U154 数据
                              w_P0_MCIOP3C_CB_ID1_R, w_P0_MCIOP3C_CB_ID0_R, w_P0_MCIOP3A_CB_ID1_R, w_P0_MCIOP3A_CB_ID0_R, // U155 数据
                              w_P1_MCIOG1A_CB_ID0_R, w_P1_MCIOG1A_CB_ID1_R, w_P1_MCIOG1C_CB_ID0_R, w_P1_MCIOG1C_CB_ID1_R, // U156 数据
                              w_P0_MCIOG3A_CB_ID0_R, w_P0_MCIOG3A_CB_ID1_R, w_P0_MCIOG3C_CB_ID0_R, w_P0_MCIOG3C_CB_ID1_R, // U157 数据
                              w_SW_1, w_SW_2, w_SW_3, w_SW_4, w_SW_5, w_SW_6, w_SW_7, w_SW_8,                             // U158 数据
                              w_PAL_BP4_AUX_PG, w_PAL_STBY_FAN_SHTDN, w_PG_P12V_SLOT_9, w_PG_P12V_SLOT_7,                 // U159 数据
                              w_PAL_BP6_PRSNT_N, w_P1_MCIOP4A_CB_ID1_R, w_PG_P12V_SLOT_3, w_PAL_OCP1_HP_BUTTON_N,         // U160 数据
                              w_PG_P12V_SLOT_6, w_FAN_PRSNT_R, w_PAL_SLIMSAS1_PRSNT_N, w_NODE1_TYPE,                      // U161 数据
                              w_PAL_MEN_CPU_SHTDN, w_PAL_S5_CPU_SHTDN, w_U157_NC_G, w_U157_NC_H,                          // U162 数据
                              w_P1_MCIOP3C_CB_ID1_R, w_P1_MCIOP3C_CB_ID0_R, w_P1_MCIOP3A_CB_ID1_R, w_P1_MCIOP3A_CB_ID0_R, // U163 数据
                              w_OCP1_CABLE_PRSNT_R, w_PAL_OCP1_PRSNT_B1_N, w_PAL_OCP1_PRSNT_B2_N, w_PAL_OCP1_PRSNT_B0_N,  // U164 数据
                              w_U159_NC_A, w_U159_NC_B, w_U159_NC_C, w_U159_NC_D,                                         // U165 数据
                              w_PAL_M2_0_PRSNT_N, w_NCSI_PRSNT_N, w_BMC_CARD_PRSNT_N, w_PAL_M2_1_PRSNT_N                  // U166 数据
                              })
);


// S CPLD ---> M CPLD
// 说明：s2p_master 为“串行到并行（Serial-to-Parallel）”主设备，
// master 产生串行时钟(sclk)和加载信号(sld_n)，从 S CPLD 的 MISO 读取 NBIT=200 位串行数据，
// 在完成一帧后输出并行数据 (po) 给 M CPLD 内部逻辑使用。
s2p_master #(.NBIT(200)) inst_scpld_to_mcpld_s2p(//96
    .clk          (clk_50m                 ), // 时钟，驱动移位和采样（50MHz）
    .rst          (~pon_reset_n            ), // 复位（连接 ~pon_reset_n，说明模块内部可能是主动高复位）
    .tick         (t1us_tick               ), // 时序参考脉冲（1us tick），用于定时/计数
    .si           (i_CPLD_SGPIO0_MISO_R    ), // Serial Input（来自 S_CPLD 的 MISO）
    .po           (scpld_to_mcpld_s2p_data ), // Parallel Output（N-bit 并行数据，向上游使用）
    .sld_n        (w_cpld_sgpio0_ld_n_r    ), // 输出：并行加载/帧边界信号（低有效）
    .sclk         (w_cpld_sgpio0_clk_r     )  // 输出：串行时钟，驱动外部 slave 的数据采样/移位
);

// M CPLD ---> S CPLD
// 说明：p2s_slave 为“并行到串行（Parallel-to-Serial）”从设备，
// 接收内部并行数据(pi)，在收到 sld_n/sclk 时序控制下把数据序列化并通过 so 输出（MOSI）到 S CPLD。
// 注意 sld_n 与 sclk 由上面的 s2p_master 产生，两模块共享同一对时序线（主产生， 从使用）。
p2s_slave #(.NBIT(200)) inst_mcpld_to_scpld_p2s(//96
    .clk          (clk_50m                   ), // 时钟，用于内部逻辑/同步
    .rst          (~pon_reset_n              ), // 复位（同上）
    .pi           (mcpld_to_scpld_p2s_data   ), // Parallel Input（要发送给 S_CPLD 的 N-bit 并行数据）
    .so           (w_cpld_sgpio0_mosi_r      ), // Serial Output（序列化后作为 MOSI 发出）
    .sld_n        (w_cpld_sgpio0_ld_n_r      ), // 串行装载/帧起止（由 master 驱动，为输入）
    .sclk         (w_cpld_sgpio0_clk_r       )  // 串行时钟（由 master 提供，为输入）
);
//-------------------------------------------------------------------------------------------------
//M_CPLD TO S_CPLD SGPIO    START
//-------------------------------------------------------------------------------------------------
//DATA TO S_CPLD (U247)


//-------------------------------------------------------------------------------------------------
// CPLD_U247 SGPIO data
// ------------------------------------------------------------------------------------------------
wire [199:0] mcpld_to_scpld_p2s_data   ; //2024-8-2 chg 159 to 199
wire [199:0] scpld_to_mcpld_s2p_data   ;

reg [191:0]	scpld_to_mcpld_data_filter;
reg 	      scpld_sgpio_fail          ;


//scpld ---> mcpld
assign  w_bf_type[1]                               = scpld_to_mcpld_data_filter[172]            ;
assign  w_bf_type[0]                               = scpld_to_mcpld_data_filter[171]            ;
assign  w_BREAK_DET_DO_N                       = scpld_to_mcpld_data_filter[170]            ;
assign  w_LEAKAGE0_PRSNT_N                   = scpld_to_mcpld_data_filter[169]            ;
assign  w_LEAKAGE_DET_DO_N                   = scpld_to_mcpld_data_filter[168]            ;
assign  w_BREAK_DET1_DO_N                     = scpld_to_mcpld_data_filter[167]            ;
assign  w_LEAKAGE_PRSNT1_N                   = scpld_to_mcpld_data_filter[166]            ;
assign  w_LEAKAGE_DET1_DO_N                 = scpld_to_mcpld_data_filter[165]            ;

assign  w_PAL_OCP1_PRSNT_B3_N             = scpld_to_mcpld_data_filter[164]            ;
assign  w_uid_sw_in_n                             = scpld_to_mcpld_data_filter[163]            ;

assign  w_PAL_BP1_PRSNT_N                     = scpld_to_mcpld_data_filter[162]            ;
assign  w_PAL_BP2_PRSNT_N                     = scpld_to_mcpld_data_filter[161]            ;
assign  w_PAL_BP3_PRSNT_N                     = scpld_to_mcpld_data_filter[160]            ;
assign  w_PAL_BP4_PRSNT_N                     = scpld_to_mcpld_data_filter[159]            ;
assign  w_PAL_BP5_PRSNT_N                     = scpld_to_mcpld_data_filter[158]            ;
assign  w_PAL_BP8_PRSNT_N                     = scpld_to_mcpld_data_filter[157]            ;

assign  w_p0_mciop1a_slot_id[7]         = scpld_to_mcpld_data_filter[156]            ;
assign  w_p0_mciop1a_slot_id[6]         = scpld_to_mcpld_data_filter[155]            ;
assign  w_p0_mciop1a_slot_id[5]         = scpld_to_mcpld_data_filter[154]            ;
assign  w_p0_mciop1a_slot_id[4]         = scpld_to_mcpld_data_filter[153]            ;
assign  w_p0_mciop1a_slot_id[3]         = scpld_to_mcpld_data_filter[152]            ;
assign  w_p0_mciop1a_slot_id[2]         = scpld_to_mcpld_data_filter[151]            ;
assign  w_p0_mciop1a_slot_id[1]         = scpld_to_mcpld_data_filter[150]            ;

assign  w_p0_mciop1c_slot_id[7]         = scpld_to_mcpld_data_filter[149]            ;
assign  w_p0_mciop1c_slot_id[6]         = scpld_to_mcpld_data_filter[148]            ;
assign  w_p0_mciop1c_slot_id[5]         = scpld_to_mcpld_data_filter[147]            ;
assign  w_p0_mciop1c_slot_id[4]         = scpld_to_mcpld_data_filter[146]            ;
assign  w_p0_mciop1c_slot_id[3]         = scpld_to_mcpld_data_filter[145]            ;
assign  w_p0_mciop1c_slot_id[2]         = scpld_to_mcpld_data_filter[144]            ;
assign  w_p0_mciop1c_slot_id[1]         = scpld_to_mcpld_data_filter[143]            ;

assign  w_p0_mciop2a_slot_id[7]         = scpld_to_mcpld_data_filter[142]            ;
assign  w_p0_mciop2a_slot_id[6]         = scpld_to_mcpld_data_filter[141]            ;
assign  w_p0_mciop2a_slot_id[5]         = scpld_to_mcpld_data_filter[140]            ;
assign  w_p0_mciop2a_slot_id[4]         = scpld_to_mcpld_data_filter[139]            ;
assign  w_p0_mciop2a_slot_id[3]         = scpld_to_mcpld_data_filter[138]            ;
assign  w_p0_mciop2a_slot_id[2]         = scpld_to_mcpld_data_filter[137]            ;
assign  w_p0_mciop2a_slot_id[1]         = scpld_to_mcpld_data_filter[136]            ;

assign  w_p0_mciop2c_slot_id[7]         = scpld_to_mcpld_data_filter[135]            ;
assign  w_p0_mciop2c_slot_id[6]         = scpld_to_mcpld_data_filter[134]            ;
assign  w_p0_mciop2c_slot_id[5]         = scpld_to_mcpld_data_filter[133]            ;
assign  w_p0_mciop2c_slot_id[4]         = scpld_to_mcpld_data_filter[132]            ;
assign  w_p0_mciop2c_slot_id[3]         = scpld_to_mcpld_data_filter[131]            ;
assign  w_p0_mciop2c_slot_id[2]         = scpld_to_mcpld_data_filter[130]            ;
assign  w_p0_mciop2c_slot_id[1]         = scpld_to_mcpld_data_filter[129]            ;

assign  w_p0_mciop3a_slot_id[7]         = scpld_to_mcpld_data_filter[128]            ;
assign  w_p0_mciop3a_slot_id[6]         = scpld_to_mcpld_data_filter[127]            ;
assign  w_p0_mciop3a_slot_id[5]         = scpld_to_mcpld_data_filter[126]            ;
assign  w_p0_mciop3a_slot_id[4]         = scpld_to_mcpld_data_filter[125]            ;
assign  w_p0_mciop3a_slot_id[3]         = scpld_to_mcpld_data_filter[124]            ;
assign  w_p0_mciop3a_slot_id[2]         = scpld_to_mcpld_data_filter[123]            ;
assign  w_p0_mciop3a_slot_id[1]         = scpld_to_mcpld_data_filter[122]            ;

assign  w_p0_mciop3c_slot_id[7]         = scpld_to_mcpld_data_filter[121]            ;
assign  w_p0_mciop3c_slot_id[6]         = scpld_to_mcpld_data_filter[120]            ;
assign  w_p0_mciop3c_slot_id[5]         = scpld_to_mcpld_data_filter[119]            ;
assign  w_p0_mciop3c_slot_id[4]         = scpld_to_mcpld_data_filter[118]            ;
assign  w_p0_mciop3c_slot_id[3]         = scpld_to_mcpld_data_filter[117]            ;
assign  w_p0_mciop3c_slot_id[2]         = scpld_to_mcpld_data_filter[116]            ;
assign  w_p0_mciop3c_slot_id[1]         = scpld_to_mcpld_data_filter[115]            ;

assign  w_p0_mciog3a_slot_id[7]         = scpld_to_mcpld_data_filter[114]            ;
assign  w_p0_mciog3a_slot_id[6]         = scpld_to_mcpld_data_filter[113]            ;
assign  w_p0_mciog3a_slot_id[5]         = scpld_to_mcpld_data_filter[112]            ;
assign  w_p0_mciog3a_slot_id[4]         = scpld_to_mcpld_data_filter[111]            ;
assign  w_p0_mciog3a_slot_id[3]         = scpld_to_mcpld_data_filter[110]            ;
assign  w_p0_mciog3a_slot_id[2]         = scpld_to_mcpld_data_filter[109]            ;
assign  w_p0_mciog3a_slot_id[1]         = scpld_to_mcpld_data_filter[108]            ;

assign  w_p0_mciog3c_slot_id[7]         = scpld_to_mcpld_data_filter[107]            ;
assign  w_p0_mciog3c_slot_id[6]         = scpld_to_mcpld_data_filter[106]            ;
assign  w_p0_mciog3c_slot_id[5]         = scpld_to_mcpld_data_filter[105]            ;
assign  w_p0_mciog3c_slot_id[4]         = scpld_to_mcpld_data_filter[104]            ;
assign  w_p0_mciog3c_slot_id[3]         = scpld_to_mcpld_data_filter[103]            ;
assign  w_p0_mciog3c_slot_id[2]         = scpld_to_mcpld_data_filter[102]            ;
assign  w_p0_mciog3c_slot_id[1]         = scpld_to_mcpld_data_filter[101]            ;

assign  w_p1_mciog1a_slot_id[7]         = scpld_to_mcpld_data_filter[100]            ;
assign  w_p1_mciog1a_slot_id[6]         = scpld_to_mcpld_data_filter[99]            ;
assign  w_p1_mciog1a_slot_id[5]         = scpld_to_mcpld_data_filter[98]            ;
assign  w_p1_mciog1a_slot_id[4]         = scpld_to_mcpld_data_filter[97]            ;
assign  w_p1_mciog1a_slot_id[3]         = scpld_to_mcpld_data_filter[96]            ;
assign  w_p1_mciog1a_slot_id[2]         = scpld_to_mcpld_data_filter[95]            ;
assign  w_p1_mciog1a_slot_id[1]         = scpld_to_mcpld_data_filter[94]            ;

assign  w_p1_mciog1c_slot_id[7]         = scpld_to_mcpld_data_filter[93]            ;
assign  w_p1_mciog1c_slot_id[6]         = scpld_to_mcpld_data_filter[92]            ;
assign  w_p1_mciog1c_slot_id[5]         = scpld_to_mcpld_data_filter[91]            ;
assign  w_p1_mciog1c_slot_id[4]         = scpld_to_mcpld_data_filter[90]            ;
assign  w_p1_mciog1c_slot_id[3]         = scpld_to_mcpld_data_filter[89]            ;
assign  w_p1_mciog1c_slot_id[2]         = scpld_to_mcpld_data_filter[88]            ;
assign  w_p1_mciog1c_slot_id[1]         = scpld_to_mcpld_data_filter[87]            ;

assign  w_p1_mciop0a_slot_id[7]         = scpld_to_mcpld_data_filter[86]            ;
assign  w_p1_mciop0a_slot_id[6]         = scpld_to_mcpld_data_filter[85]            ;
assign  w_p1_mciop0a_slot_id[5]         = scpld_to_mcpld_data_filter[84]            ;
assign  w_p1_mciop0a_slot_id[4]         = scpld_to_mcpld_data_filter[83]            ;
assign  w_p1_mciop0a_slot_id[3]         = scpld_to_mcpld_data_filter[82]            ;
assign  w_p1_mciop0a_slot_id[2]         = scpld_to_mcpld_data_filter[81]            ;
assign  w_p1_mciop0a_slot_id[1]         = scpld_to_mcpld_data_filter[80]            ;

assign  w_p1_mciop0c_slot_id[7]         = scpld_to_mcpld_data_filter[79]            ;
assign  w_p1_mciop0c_slot_id[6]         = scpld_to_mcpld_data_filter[78]            ;
assign  w_p1_mciop0c_slot_id[5]         = scpld_to_mcpld_data_filter[77]            ;
assign  w_p1_mciop0c_slot_id[4]         = scpld_to_mcpld_data_filter[76]            ;
assign  w_p1_mciop0c_slot_id[3]         = scpld_to_mcpld_data_filter[75]            ;
assign  w_p1_mciop0c_slot_id[2]         = scpld_to_mcpld_data_filter[74]            ;
assign  w_p1_mciop0c_slot_id[1]         = scpld_to_mcpld_data_filter[73]            ;

assign  w_p1_mciop1a_slot_id[7]         = scpld_to_mcpld_data_filter[72]            ;
assign  w_p1_mciop1a_slot_id[6]         = scpld_to_mcpld_data_filter[71]            ;
assign  w_p1_mciop1a_slot_id[5]         = scpld_to_mcpld_data_filter[70]            ;
assign  w_p1_mciop1a_slot_id[4]         = scpld_to_mcpld_data_filter[69]            ;
assign  w_p1_mciop1a_slot_id[3]         = scpld_to_mcpld_data_filter[68]            ;
assign  w_p1_mciop1a_slot_id[2]         = scpld_to_mcpld_data_filter[67]            ;
assign  w_p1_mciop1a_slot_id[1]         = scpld_to_mcpld_data_filter[66]            ;

assign  w_p1_mciop1c_slot_id[7]         = scpld_to_mcpld_data_filter[65]            ;
assign  w_p1_mciop1c_slot_id[6]         = scpld_to_mcpld_data_filter[64]            ;
assign  w_p1_mciop1c_slot_id[5]         = scpld_to_mcpld_data_filter[63]            ;
assign  w_p1_mciop1c_slot_id[4]         = scpld_to_mcpld_data_filter[62]            ;
assign  w_p1_mciop1c_slot_id[3]         = scpld_to_mcpld_data_filter[61]            ;
assign  w_p1_mciop1c_slot_id[2]         = scpld_to_mcpld_data_filter[60]            ;
assign  w_p1_mciop1c_slot_id[1]         = scpld_to_mcpld_data_filter[59]            ;

assign  w_p1_mciop2a_slot_id[7]         = scpld_to_mcpld_data_filter[58]            ;
assign  w_p1_mciop2a_slot_id[6]         = scpld_to_mcpld_data_filter[57]            ;
assign  w_p1_mciop2a_slot_id[5]         = scpld_to_mcpld_data_filter[56]            ;
assign  w_p1_mciop2a_slot_id[4]         = scpld_to_mcpld_data_filter[55]            ;
assign  w_p1_mciop2a_slot_id[3]         = scpld_to_mcpld_data_filter[54]            ;
assign  w_p1_mciop2a_slot_id[2]         = scpld_to_mcpld_data_filter[53]            ;
assign  w_p1_mciop2a_slot_id[1]         = scpld_to_mcpld_data_filter[52]            ;

assign  w_p1_mciop2c_slot_id[7]         = scpld_to_mcpld_data_filter[51]            ;
assign  w_p1_mciop2c_slot_id[6]         = scpld_to_mcpld_data_filter[50]            ;
assign  w_p1_mciop2c_slot_id[5]         = scpld_to_mcpld_data_filter[49]            ;
assign  w_p1_mciop2c_slot_id[4]         = scpld_to_mcpld_data_filter[48]            ;
assign  w_p1_mciop2c_slot_id[3]         = scpld_to_mcpld_data_filter[47]            ;
assign  w_p1_mciop2c_slot_id[2]         = scpld_to_mcpld_data_filter[46]            ;
assign  w_p1_mciop2c_slot_id[1]         = scpld_to_mcpld_data_filter[45]            ;

assign  w_p1_mciop3a_slot_id[7]         = scpld_to_mcpld_data_filter[44]            ;
assign  w_p1_mciop3a_slot_id[6]         = scpld_to_mcpld_data_filter[43]            ;
assign  w_p1_mciop3a_slot_id[5]         = scpld_to_mcpld_data_filter[42]            ;
assign  w_p1_mciop3a_slot_id[4]         = scpld_to_mcpld_data_filter[41]            ;
assign  w_p1_mciop3a_slot_id[3]         = scpld_to_mcpld_data_filter[40]            ;
assign  w_p1_mciop3a_slot_id[2]         = scpld_to_mcpld_data_filter[39]            ;
assign  w_p1_mciop3a_slot_id[1]         = scpld_to_mcpld_data_filter[38]            ;

assign  w_p1_mciop3c_slot_id[7]         = scpld_to_mcpld_data_filter[37]            ;
assign  w_p1_mciop3c_slot_id[6]         = scpld_to_mcpld_data_filter[36]            ;
assign  w_p1_mciop3c_slot_id[5]         = scpld_to_mcpld_data_filter[35]            ;
assign  w_p1_mciop3c_slot_id[4]         = scpld_to_mcpld_data_filter[34]            ;
assign  w_p1_mciop3c_slot_id[3]         = scpld_to_mcpld_data_filter[33]            ;
assign  w_p1_mciop3c_slot_id[2]         = scpld_to_mcpld_data_filter[32]            ;
assign  w_p1_mciop3c_slot_id[1]         = scpld_to_mcpld_data_filter[31]            ;

assign  w_P1_MCIOP2C_CB_ID1_R             = scpld_to_mcpld_data_filter[30]            ;
assign  w_P1_MCIOP2C_CB_ID0_R             = scpld_to_mcpld_data_filter[29]            ;
assign  w_P1_MCIOP2A_CB_ID1_R             = scpld_to_mcpld_data_filter[28]            ;
assign  w_P1_MCIOP2A_CB_ID0_R             = scpld_to_mcpld_data_filter[27]            ;

assign  w_P1_MCIOP1C_CB_ID1_R             = scpld_to_mcpld_data_filter[26]            ;
assign  w_P1_MCIOP1C_CB_ID0_R             = scpld_to_mcpld_data_filter[25]            ;
assign  w_P1_MCIOP1A_CB_ID1_R             = scpld_to_mcpld_data_filter[24]            ;
assign  w_P1_MCIOP1A_CB_ID0_R             = scpld_to_mcpld_data_filter[23]            ;

assign  w_P1_MCIOP0C_CB_ID1_R             = scpld_to_mcpld_data_filter[22]            ;
assign  w_P1_MCIOP0C_CB_ID0_R             = scpld_to_mcpld_data_filter[21]            ;
assign  w_P1_MCIOP0A_CB_ID1_R             = scpld_to_mcpld_data_filter[20]            ;
assign  w_P1_MCIOP0A_CB_ID0_R             = scpld_to_mcpld_data_filter[19]            ;

assign  w_pcb_version[2]                       = scpld_to_mcpld_data_filter[18]            ;
assign  w_pcb_version[1]                       = scpld_to_mcpld_data_filter[17]            ;
assign  w_pcb_version[0]                       = scpld_to_mcpld_data_filter[16]            ;

assign  w_pca_version[2]                       = scpld_to_mcpld_data_filter[15]            ;
assign  w_pca_version[1]                       = scpld_to_mcpld_data_filter[14]            ;
assign  w_pca_version[0]                       = scpld_to_mcpld_data_filter[13]            ;

assign  w_board_id[3]                             = scpld_to_mcpld_data_filter[12]            ;
assign  w_board_id[2]                             = scpld_to_mcpld_data_filter[11]            ;
assign  w_board_id[1]                             = scpld_to_mcpld_data_filter[10]            ;
assign  w_board_id[0]                             = scpld_to_mcpld_data_filter[9]            ;

assign  w_usb2_lcd_oc_n                         = scpld_to_mcpld_data_filter[8]            ;
assign  w_usb_inner_overcur3               = scpld_to_mcpld_data_filter[7]            ;
assign  w_bmc_extrst_uid                       = scpld_to_mcpld_data_filter[6]            ;
assign  w_p1_pcie_wake_n_r                   = scpld_to_mcpld_data_filter[5]            ;
assign  w_p0_pcie_wake_n_r                   = scpld_to_mcpld_data_filter[4]            ;
assign  w_PWRGD_P12V_PS3_PS4               = scpld_to_mcpld_data_filter[3]            ;
assign  w_PS3_PS4_ACFAIL                       = scpld_to_mcpld_data_filter[2]            ;
assign  w_ps4_prsnt                                 = scpld_to_mcpld_data_filter[1]            ;
assign  w_ps3_prsnt                                 = scpld_to_mcpld_data_filter[0]            ;

wire    w_usb_sw_s;
wire    w_bmc_ready_flag                   ;
//mcpld ---> scpld
assign  mcpld_to_scpld_p2s_data[199]      = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[198]      = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[197]      = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[196]      = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[195:56]   = 'b0                                        ;

assign  mcpld_to_scpld_p2s_data[55]        = w_SW_2        ;

assign  mcpld_to_scpld_p2s_data[54]        = w_P1_MCIOP3C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[53]        = w_P1_MCIOP3C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[52]        = w_P1_MCIOP3A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[51]        = w_P1_MCIOP3A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[50]        = w_P1_MCIOG1C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[49]        = w_P1_MCIOG1C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[48]        = w_P1_MCIOG1A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[47]        = w_P1_MCIOG1A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[46]        = w_P0_MCIOP3C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[45]        = w_P0_MCIOP3C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[44]        = w_P0_MCIOP3A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[43]        = w_P0_MCIOP3A_CB_ID0_R        ;
                                                              
assign  mcpld_to_scpld_p2s_data[42]        = w_P0_MCIOP2C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[41]        = w_P0_MCIOP2C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[40]        = w_P0_MCIOP2A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[39]        = w_P0_MCIOP2A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[38]        = w_P0_MCIOP1C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[37]        = w_P0_MCIOP1C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[36]        = w_P0_MCIOP1A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[35]        = w_P0_MCIOP1A_CB_ID0_R        ;
                                                              
assign  mcpld_to_scpld_p2s_data[34]        = w_P0_MCIOG3C_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[33]        = w_P0_MCIOG3C_CB_ID0_R        ;
assign  mcpld_to_scpld_p2s_data[32]        = w_P0_MCIOG3A_CB_ID1_R        ;
assign  mcpld_to_scpld_p2s_data[31]        = w_P0_MCIOG3A_CB_ID0_R        ;

assign  mcpld_to_scpld_p2s_data[30]        = w_led_control[7];
assign  mcpld_to_scpld_p2s_data[29]        = w_led_control[6];
assign  mcpld_to_scpld_p2s_data[28]        = w_led_control[5];
assign  mcpld_to_scpld_p2s_data[27]        = w_led_control[4];
assign  mcpld_to_scpld_p2s_data[26]        = w_led_control[3];
assign  mcpld_to_scpld_p2s_data[25]        = w_led_control[2];
assign  mcpld_to_scpld_p2s_data[24]        = w_led_control[1];
assign  mcpld_to_scpld_p2s_data[23]        = w_led_control[0];

assign  mcpld_to_scpld_p2s_data[22]        = w_usb_sw_s                         ;
assign  mcpld_to_scpld_p2s_data[21]        = db_i_pal_bmcuid_button ;
assign  mcpld_to_scpld_p2s_data[20]        = w_p12v_discharge_r         ;
assign  mcpld_to_scpld_p2s_data[19]        = db_i_p1_pcie_rst_n_1     ;
assign  mcpld_to_scpld_p2s_data[18]        = db_i_p1_pcie_rst_n_0     ;
assign  mcpld_to_scpld_p2s_data[17]        = db_i_p0_pcie_rst_n_1     ;
assign  mcpld_to_scpld_p2s_data[16]        = db_i_p0_pcie_rst_n_0     ;
assign  mcpld_to_scpld_p2s_data[15]        = w_PAL_OCP1_PRSNT_B2_N   ;//2025-03-06 DEL ~
assign  mcpld_to_scpld_p2s_data[14]        = w_PAL_OCP1_PRSNT_B1_N   ;
assign  mcpld_to_scpld_p2s_data[13]        = w_PAL_OCP1_PRSNT_B0_N   ;
assign  mcpld_to_scpld_p2s_data[12]        = db_i_pgd_p5v                     ;
assign  mcpld_to_scpld_p2s_data[11]        = db_i_p0_slp_s3_n             ;
assign  mcpld_to_scpld_p2s_data[10]        = db_i_p0_slp_s5_n             ;
assign  mcpld_to_scpld_p2s_data[9]          = db_i_pwrgd_p3v3_stby     ;
assign  mcpld_to_scpld_p2s_data[8]          = db_i_pgd_p1v2_stby         ;
assign  mcpld_to_scpld_p2s_data[7]          = w_bmc_ready_flag             ;
assign  mcpld_to_scpld_p2s_data[6]          = w_PAL_BP6_PRSNT_N           ;
assign  mcpld_to_scpld_p2s_data[5]          = w_PWRGD_P12V                     ;
assign  mcpld_to_scpld_p2s_data[4]          = w_FM_P12V_EN                     ;

assign  mcpld_to_scpld_p2s_data[3]        = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[2]        = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[1]        = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[0]        = 1'b1                                       ;

//-------------------------------------------------------------------------------------------------
// CPLD_U247 SGPIO Moudule       CPLD_U247 is slave
// ------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)
			begin
				scpld_to_mcpld_data_filter <= {192{1'b0}};
				scpld_sgpio_fail <=1'b0;
			end
		else if
			((scpld_to_mcpld_s2p_data[3:0] == 4'b0101)&& (scpld_to_mcpld_s2p_data[199:196] == 4'b1010))
			begin
				scpld_to_mcpld_data_filter <= scpld_to_mcpld_s2p_data[195:4];
				scpld_sgpio_fail <=1'b0;
			end
		else
			begin
				scpld_to_mcpld_data_filter <= scpld_to_mcpld_data_filter;
				scpld_sgpio_fail <=1'b1;
			end

end

//-------------------------------------------------------------------------------------------------
//M_CPLD TO S_CPLD SGPIO    END
//-------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------
// CMU CPLD SGPIO data
// --------------------------------------------------------------------------------------------------------------------------------------------------
wire [95:0] mbcpld_to_cmucpld_p2s_data;
wire [95:0] cmucpld_to_mcpld_s2p_data;

reg [19:0]	cmu_to_mb_data_filter;//2024-5-14 54-->19
reg 	cmucpld_sgpio_fail;

wire    w_ss_pal_clk_r;
wire    w_ss_pal_load_n_r;
wire    w_ss_pal_data_out_r;

wire    w_mb_type4                ;
wire    w_mb_type3                ;
wire    w_mb_type2                ;
wire    w_mb_type1                ;
wire    w_rfu_bit1              ;
wire    w_rfu_bit2              ;
wire    w_rfu_bit3              ;
wire    w_leakage_int             ;//2024-7-2 add 
wire    wBMC_PWR_OK;
wire    w_bmc_cpld_wdt_in;//2024-11-11 add
assign  w_mb_type4  =   1'b0    ;//mb_type: GENOA 2P4U = 4'b0110
assign  w_mb_type3  =   1'b1    ;
assign  w_mb_type2  =   1'b1    ;
assign  w_mb_type1  =   1'b0   ;

assign  w_rfu_bit1  =   1'b0    ;
assign  w_rfu_bit2  =   1'b0    ;
assign  w_rfu_bit3  =   1'b0    ;
assign  w_leakage_int  =   1'b0    ;

wire    w_bmc_active0_n                     ;
wire    w_pal_p12v_stby_drop           ;
wire    w_ale_tmp1_n                           ;
wire    w_pal_bmcuid_button_r         ;
wire    w_peci_master_sel                 ;
wire    w_pcie_pal_bmc_wake_n         ;
wire    w_password_clear                   ;
wire    w_fm_cpu1_disable_cod_n_r ;

wire    cmu_pg_p5v0_stby		       ; 
wire    cmu_pg_p3v3_stby		       ; 
wire    cmu_pg_p3v3_stby_rgm	       ; 
wire    cmu_pg_p2v5_stby		       ; 
wire    cmu_pg_p1v8_stby		       ; 
wire    cmu_pg_p1v2_stby		       ; 
wire    cmu_pg_p1v0_stby		       ; 

wire    w_bmc_onctl_n                         ;

//CMU CPLD ---> MB CPLD
assign w_bmc_cpld_wdt_in                             = cmu_to_mb_data_filter[18]; //2024-11-11 add 
assign w_bmc_active0_n                                 = cmu_to_mb_data_filter[17]; //USELESS 
assign w_pal_p12v_stby_drop                       = cmu_to_mb_data_filter[16];//USELESS
assign w_ale_tmp1_n                                       = cmu_to_mb_data_filter[15];//USELESS
assign w_pal_bmcuid_button_r                     = cmu_to_mb_data_filter[14];//USELESS
assign w_peci_master_sel                             = cmu_to_mb_data_filter[13];//USELESS
assign w_pcie_pal_bmc_wake_n                     = cmu_to_mb_data_filter[12];//USELESS
assign w_password_clear                               = cmu_to_mb_data_filter[11];//USELESS
assign w_fm_cpu1_disable_cod_n_r             = cmu_to_mb_data_filter[10];//USELESS
assign wBMC_PWR_OK                                         = cmu_to_mb_data_filter[9];
assign cmu_pg_p5v0_stby		                    = cmu_to_mb_data_filter[8];//USELESS
assign cmu_pg_p3v3_stby		                    = cmu_to_mb_data_filter[7];//USELESS
assign cmu_pg_p3v3_stby_rgm	                    = cmu_to_mb_data_filter[6];//USELESS
assign cmu_pg_p2v5_stby		                    = cmu_to_mb_data_filter[5];//USELESS
assign cmu_pg_p1v8_stby		                    = cmu_to_mb_data_filter[4];//USELESS
assign cmu_pg_p1v2_stby		                    = cmu_to_mb_data_filter[3];//USELESS
assign cmu_pg_p1v0_stby		                    = cmu_to_mb_data_filter[2];//USELESS
assign w_bmc_ready_flag                               = cmu_to_mb_data_filter[1];
assign w_bmc_onctl_n                                     = cmu_to_mb_data_filter[0];//USELESS

//MB CPLD ---> CMU CPLD
assign mbcpld_to_cmucpld_p2s_data[95]    = 1'b1                                ;
assign mbcpld_to_cmucpld_p2s_data[94]    = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[93]    = 1'b1                                ;
assign mbcpld_to_cmucpld_p2s_data[92]    = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[91:23]  = 'b0                                ;

assign mbcpld_to_cmucpld_p2s_data[22]    = w_mb_type4                     ;
assign mbcpld_to_cmucpld_p2s_data[21]    = w_mb_type3                     ;
assign mbcpld_to_cmucpld_p2s_data[20]    = w_mb_type2                     ;
assign mbcpld_to_cmucpld_p2s_data[19]    = w_mb_type1                     ;
assign mbcpld_to_cmucpld_p2s_data[18]    = w_rfu_bit3                    ;//w_rfu_bit3
assign mbcpld_to_cmucpld_p2s_data[17]    = w_rfu_bit2                     ;
assign mbcpld_to_cmucpld_p2s_data[16]    = w_rfu_bit1                     ;
assign mbcpld_to_cmucpld_p2s_data[15]    = w_leakage_int                     ;

assign mbcpld_to_cmucpld_p2s_data[14]    = ~w_bmc_extrst_uid                     ;  
assign mbcpld_to_cmucpld_p2s_data[13]    = i_FRONT_VGA_CABLE_PRSNT_N           ; 
assign mbcpld_to_cmucpld_p2s_data[12]    = i_PGD_P12V_STBY_DROOP               ;
assign mbcpld_to_cmucpld_p2s_data[11]    = w_PWRGD_P12V                        ;  
assign mbcpld_to_cmucpld_p2s_data[10]    = db_i_pwr_btn_cpld_n_r                      ;  
assign mbcpld_to_cmucpld_p2s_data[9]     = w_uid_sw_in_n                       ;  
assign mbcpld_to_cmucpld_p2s_data[8]     = 1'b1         ;//db_i_fm_plt_bmc_thermtrip_n
assign mbcpld_to_cmucpld_p2s_data[7]     = 1'b1                   ;//db_i_fm_pchhot_n
assign mbcpld_to_cmucpld_p2s_data[6]     = 1'b1          ;//db_i_fm_pch_glb_rst_warn_n
assign mbcpld_to_cmucpld_p2s_data[5]     = db_i_p0_slp_s5_n                     ;
assign mbcpld_to_cmucpld_p2s_data[4]     = db_i_p0_slp_s3_n                     ;

assign mbcpld_to_cmucpld_p2s_data[3]     = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[2]     = 1'b1                                ;
assign mbcpld_to_cmucpld_p2s_data[1]     = 1'b0                                ;
assign mbcpld_to_cmucpld_p2s_data[0]     = 1'b1                                ;
// --------------------------------------------------------------------------------------------------------------------------------------------------
// CMU CPLD SGPIO Moudule   CMU is slave
// --------------------------------------------------------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)
			begin
				cmu_to_mb_data_filter <= {20{1'b0}};
				cmucpld_sgpio_fail <=1'b0;
			end
		else if
			((cmucpld_to_mcpld_s2p_data[3:0] == 4'b0101)&& (cmucpld_to_mcpld_s2p_data[95:92] == 4'b1010))
			begin
				cmu_to_mb_data_filter <= cmucpld_to_mcpld_s2p_data[23:4];
				cmucpld_sgpio_fail <=1'b0;
			end
		else
			begin
				cmu_to_mb_data_filter <= cmu_to_mb_data_filter;
				cmucpld_sgpio_fail <=1'b1;
			end

end
//CMU CPLD ---> M CPLD
s2p_master #(.NBIT(96)) inst_cmucpld_to_mcpld_s2p(
  .clk  (clk_50m					), //in
  .rst  (~pon_reset_n				), //in
  .tick (t1us_tick					), //in
  .si   (i_SS_PAL_DATA_IN_R		    ), //in   //SGPIO_MISO  Serial Signal input
  .po   (cmucpld_to_mcpld_s2p_data	), //out  //Parallel Signal output
  .sld_n(w_ss_pal_load_n_r			), //out  //SGPIO_LOAD
  .sclk (w_ss_pal_clk_r 			)  //out  //SGPIO_CLK
);

//M CPLD  ---> CMU CPLD
p2s_slave #(.NBIT(96)) inst_mcpld_to_cmucpld_p2s(
	.clk(clk_50m					    ),//in
	.rst(~pon_reset_n				    ),//in
	.pi (mbcpld_to_cmucpld_p2s_data	    ),//in   //Parallel Signal input
	.so (w_ss_pal_data_out_r 		    ),//out  //SGPIO_MOSI Serial Signal output
	.sld_n(w_ss_pal_load_n_r		    ),//in   //SGPIO_LOAD
	.sclk(w_ss_pal_clk_r		        ) //in   //SGPIO_CLK
);
//-------------------------------------------------------------------------------------------------
// power_button
// ------------------------------------------------------------------------------------------------
//  BMC active CHECK   only bmc active can get into S0
wire    w_pwrbtn_to_pch_n ;
wire    w_bmc_ctl_pwrbtn_n;
wire    [1:0]   w_pwr_btn_state    ;
wire    w_pwr_btn_dly             ;

//from IIC_bmc
wire    w_bmc_pwrbtn_lock         ;  //bmc control,set 0 to disable physical btn
wire    w_bmc_sbtn_poweron        ; //bmc control,generate 500ms pulse       set 1 enable ______------_____
wire    w_bmc_lbtn_powerdown      ; //bmc control,generate 6s pulse
wire    w_bmc_sbtn_powerdown      ; //bmc control,generate 500ms pulse
wire    w_bmc_sbtn_wc             ; //bmc control,set 0 to clr  sbtn_pwron_evt
wire    w_bmc_lbtn_wc             ; //bmc control,set 0 to clr  lbtn_pwrdown_evt
wire    w_bmc_sbtn_sys_wc         ; //bmc control,set 0 to clr  sbtn_sysrst_evt
//To IIC_bmc
wire    w_bmc_sbtn_poweron_done   ; // virtual sbtn for pwrup event  push down more than 1s
wire    w_bmc_lbtn_powerdown_done ; // virtual lbtn  7s
wire    w_bmc_sbtn_powerdown_done ; // virtual sbtn  1s
wire    w_sbtn_pwron_evt          ; // sbtn for pwrup event push down for 500ms         in S5
wire    w_lbtn_pwrdown_evt        ; // lbtn for pwrdown event push down for 4s          in S0
wire    w_sbtn_sysrst_evt         ; // sbtn for rst event     push down for 500ms       in S0
wire    w_btn_press_flag          ;
wire    w_pal_pwrbtn_n_r          ;

// Pwr_But_Ctrl 模块实例化：电源按钮控制模块实例化，用于处理电源按钮的各种控制逻辑（电源按钮基础控制模块）
Pwr_But_Ctrl #(
.PWRBTN_LONG                  (4)
)Pwr_But_Ctrl_U0
(
.i_clk                             (clk_50m),		//input Clk
.i_rst_n                         (pon_reset_n),		//Global rst,Active Low
.i_20mSEC                       (w20mSCE),  //w20mSCE

.i_PWRBTN_OUT_disable               (1'b0),
.i_disable_button                       (1'b0),	// 1'b1 is disable, 1'b0 is enable;  1'b1 for General items.  //w_bmc_pwrbtn_lock_n_ff from IIC_bmc        1'b0   2022-12-19 delete for debug  ~r_bmc_actived  || (~w_bmc_pwrbtn_lock)
.i_BMC_active0_n                         (1'b1), // 1'b1: BMC die,  1'b0: BMC active, default low when AC in;  if no function of BMC controled power on, this signal should 1'b1.
.i_FP_PWR_BTN_MUX_N                   (db_i_pwr_btn_cpld_n_r),			//Power Button  //MB  PWR_BTN db_i_pal_pwr_btn_n
.i_FM_BMC_PWRBTN_OUT_CPLD_N   (1'b1),	//Power on/off signal from BMC
.i_DBP_POWER_BTN_N                     (1'b1),	//Power on/off signal from DBP   //from ERA BP
.i_state_s0                                   (1'b1),
.i_state_s5                                   (1'b0),
.i_bmc_clear_data                       (1'b1),        //high pulse for BMC clear latch data
.i_BMC_active1_n                         (1'b0),        // 1'b1: BMC die,  1'b0: BMC active, default high when AC in

.o_pwrbtn_short                           (        ),
.o_pwrbtn_long                             (        ),
.o_PWRBTN_state                           (        ),
.o_pwr_btn_state                         (w_pwr_btn_state),
.o_pwr_btn_dly                             (w_pwr_btn_dly  ),
.o_FM_BMC_PWRBTN_OUT_B_N         (w_pwrbtn_to_pch_n)		//Power on/off signal to PCH
);

bmc_ctl_pwrbtn bmc_ctl_pwrbtn_u0(
.i_clk                                        (clk_50m),
.i_rst_n                                    (pon_reset_n),
.i_clk_20ms                              (w20mSCE), //w20mSCE
.i_pwrbtn_n                              (w_pwrbtn_to_pch_n),  // w_pwrbtn_to_pch_n 
.i_slps4_n                                (db_i_p0_slp_s5_n),   

.i_bmc_sbtn_poweron               (w_bmc_sbtn_poweron  ),     //generate 500ms pulse
.i_bmc_lbtn_powerdown           (w_bmc_lbtn_powerdown),   //generate 6s pulse
.i_bmc_sbtn_powerdown           (w_bmc_sbtn_powerdown),   //generate 500ms pulse
.i_bmc_sbtn_wc                         (w_bmc_sbtn_wc    ),
.i_bmc_lbtn_wc                         (w_bmc_lbtn_wc    ),
.i_bmc_sbtn_sys_wc                 (w_bmc_sbtn_sys_wc),

.o_bmc_sbtn_poweron_done     (w_bmc_sbtn_poweron_done  ),
.o_bmc_lbtn_powerdown_done (w_bmc_lbtn_powerdown_done),
.o_bmc_sbtn_powerdown_done (w_bmc_sbtn_powerdown_done),
.o_sbtn_pwron_evt                   (w_sbtn_pwron_evt  ),
.o_lbtn_pwrdown_evt               (w_lbtn_pwrdown_evt),
.o_sbtn_sysrst_evt                 (w_sbtn_sysrst_evt ),
.o_bmc_ctl_pwrbtn_n               (w_bmc_ctl_pwrbtn_n)
);

assign  w_btn_press_flag       = w_sbtn_pwron_evt || w_lbtn_pwrdown_evt || w_sbtn_sysrst_evt;
assign  w_pal_pwrbtn_n_r = w_pwrbtn_to_pch_n & w_bmc_ctl_pwrbtn_n ;  //o_FM_CPLD_PWRBTN_OUT_N    cpld TO pch

//--------------------------------------------------------------------------------------------------------------------------------------------------
//power_button end
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    [3:0]w_pal_ocp1_prsnt_n;
wire    w_ocp1_x8_prsnt_n;
wire    w_ocp1_x16_prsnt_n;
assign  w_ocp_prsnt_n   =   w_PAL_OCP1_PRSNT_B3_N & w_PAL_OCP1_PRSNT_B2_N & w_PAL_OCP1_PRSNT_B1_N & w_PAL_OCP1_PRSNT_B0_N;
assign  w_pal_ocp1_prsnt_n  =   {w_PAL_OCP1_PRSNT_B3_N,w_PAL_OCP1_PRSNT_B2_N,w_PAL_OCP1_PRSNT_B1_N,w_PAL_OCP1_PRSNT_B0_N};
assign  w_ocp1_x16_prsnt_n    =   ((w_pal_ocp1_prsnt_n==4'b0100)|(w_pal_ocp1_prsnt_n==4'b0101)|
                                                               (w_pal_ocp1_prsnt_n==4'b0111)|(w_pal_ocp1_prsnt_n==4'b1100))?1'b0:1'b1;
assign  w_ocp1_x8_prsnt_n   =   w_ocp_prsnt_n ? 1'b1 : (w_ocp1_x16_prsnt_n ? 1'b0 : 1'b1);



//-------------------------------------------------------------------------------------------------
// /system reset
// ------------------------------------------------------------------------------------------------
// wire w_bmc_ctl_sys_rst;
wire w_bmc_ctl_sys_rst_done;

system_rst system_rst_u0(
.i_clk                        (clk_50m),
.i_rst_n                    (pon_reset_n),
.i_clk_20ms              (w20mSCE), //w20mSCE

.i_RST_DBP_RST_CO_R_N       (db_i_pal_ext_rst_n     ), //PAL_EXT_RST_N
.i_bmc_ctl_sys_rst             (w_bmc_sbtn_reset_ctl ),    //to generate 500ms pulse

.o_bmc_ctl_sys_rst_done   (w_bmc_ctl_sys_rst_done),
.o_RST_SYS_BTN_OUT_PLD_N (w_pal_sys_reset_od_n_r)
);
// assign o_PAL_SYS_RESET_OD_N_R = w_pal_sys_reset_od_n_r ;

//--------------------------------------------------------------------------------------------------------------------------------------------------
// MB NC_PORT 
//-------------------------------------------------------------------------------------------------------------------------------------------------- 
wire    w_nc_pin ; 
assign  w_nc_pin  = i_HDR_N_R       &
                                   i_CPLD_SN        &
                                   i_CPLD_DONE      &
                                   i_CPLD_INIT_N        &
                                   i_CPLD2_JTAGEN_R     &
                                   i_PAL_PEOGRAM_N      &
                                   i_CPLD_JTAG_EN       &
                                   i_CLK_GEN_ALERT_R_N      &
                                   i_CPLD_SGPIO1_MISO_R     &
                                   i_FAN_SPGIO_DATAIN       &
                                   i_UART_CPLD_RX_R     &
                                   // i_P0_MCIOP0A_DATAIN_R        &
                                   // i_P0_MCIOP0C_DATAIN_R        &
                                   // i_P0_MCIOP1A_DATAIN_R        &
                                   i_P0_MCIOP1AC_VPPI2C_SCL     &
                                   i_P0_MCIOP1AC_VPPI2C_SDA     &
                                   i_P0_MCIOP3A_DATAIN_R        &
                                   i_P0_MCIOP3AC_VPPI2C_SCL     &
                                   i_P0_MCIOP3AC_VPPI2C_SDA     &
                                   i_SATA1_SDATAOUT0_R      &
                                   i_SATA1_BACKPLANE_TYPE       &
                                   i_P0_SGPIO_LD_R      &
                                   i_P0_SGPIO_DATA_R        &
                                   i_CPU0_SGPIO0_CLK        &
                                   i_CPU0_SGPIO1_CLK        &                                 
                                   i_CPU0_SGPIO2_CLK        &
                                   i_CPU0_SGPIO3_CLK        &
                                   i_P0_XTRIG_N_4       &
                                   i_P0_XTRIG_N_5       &
                                   i_P0_XTRIG_N_6       &
                                   i_P0_XTRIG_N_7       &
                                   i_P1_XTRIG_N_4       &
                                   i_P1_XTRIG_N_5       &
                                   i_P1_XTRIG_N_6       &
                                   i_P1_XTRIG_N_7       &
                                   i_P0_UART_TXD_0      &
                                   i_P0_CPLD_SPARE_0    &
                                   i_P0_CPLD_SPARE_1    &
                                   i_P0_CPLD_SPARE_2    &
                                   i_P0_CPLD_SPARE_3    &
                                   i_P0_SMERR_N             &
                                   i_P1_SMERR_N     &
                                   // i_P0_CPLD_SCL        &
                                   // i_P0_CPLD_SDA        &
                                   i_HDT_CONN_TESTEN        &
                                   i_P1_SLP_S3_N        &
                                   i_P1_SLP_S5_N        &
                                   i_IRQ_SPI_TPM_N      &
                                   i_PAL_LCD_CARD_IN        &
                                   i_P0_PRSNT_N     &
                                   i_P1_PRSNT_N     &
                                   i_PG_P1V0_STBY_M2_R      &
                                   i_BMC_JTAG_DBREQ_N       &
                                   // w_mcio_slot13_prsnt_n_1_sw       &
                                   w_mcio_slot13_prsnt_n_1_sw2      &
                                   w_u19_nc4_zt     &
                                   w_u19_nc4_zt2
                                   
				  ;

//inouts
assign  w_p0_dimm_af_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;
assign  w_p0_dimm_gl_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;
assign  w_p1_dimm_af_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;
assign  w_p1_dimm_gl_pcamp_r = (w_power_seq_sm == SM_STEADY_PWROK) ? 1'b1 : 1'b0;

// --------------------------------------------------------------------------------------------------------------------------------------------------
// bmc_ready for slp_s3 
// --------------------------------------------------------------------------------------------------------------------------------------------------
wire  w_bmc_ready_pos;
reg r_bmc_ready ;

Edge_Detect Edge_Detect_U2(    
    .i_clk               (clk_50m),        
    .i_rst_n             (pon_reset_n),       
    .i_signal            (w_bmc_ready_flag ),  
    
    .o_signal_pos        (w_bmc_ready_pos),
    .o_signal_neg        (),  
    .o_signal_invert     ()
);

always @(posedge clk_50m or negedge pon_reset_n) begin
    if( !pon_reset_n)
        begin
            r_bmc_ready <= 1'b0 ;
        end
    else if(w_bmc_ready_pos) 
        begin
            r_bmc_ready <= 1'b1 ;
        end
    else if(~db_i_p0_slp_s3_n & ~w_bmc_ready_flag) 
        begin
            r_bmc_ready <= 1'b0 ;
        end
    else
        begin
            r_bmc_ready <= r_bmc_ready ;
        end
end

wire    w_sys_pwrok;

assign  w_sys_pwrok 				= w_sm_steady_pwrok_state;					//pgd_aux_system	
assign  w_sm_steady_pwrok_state	= (w_power_seq_sm==SM_STEADY_PWROK	);		//

// //--------------------------------------------------------------------------------------------------------------------------------------------------
// //cpu_thermtrip 
// //--------------------------------------------------------------------------------------------------------------------------------------------------
assign  w_cpu_thermtrip_event  = (~db_cpu_thermaltrip_n) & {`NUM_CPU{w_cpupwrok_rise_dly2ms}} & (~db_cpu_prsnt_n); 
wire    [1:0]   w_cpu_thermtrip_fault_det;
edge_delay #(.CNTR_NBITS(2), .DELAY_MODE(1'b0)) edge_delay_inst_cpupwrok (
    .clk         (clk_50m),
    .reset       (~pgd_aux_system),
    .cnt_size    (2'b10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_cpu_sys_pwrok),
    .delay_output(w_cpupwrok_rise_dly2ms)
  );

cpu_thermtrip thermtrip_int(
    .i_clk					(clk_50m				),
    .i_reset					(~pon_reset_n			),

    .i_any_pwr_fault_det		(w_any_pwr_fault_det	    ),					//0
    .i_cpu_prsnt_n			(db_cpu_prsnt_n			    ),					//0
    .i_st_steady_pwrok		(w_st_steady_pwrok		    ),					//1->0
    .i_st_critical_fail		(w_st_critical_fail		    ),					//0 -> 1 1ms
    .i_st_disable_main_efuse	(w_st_disable_grp_d_vddio  ),					//0 -> 1 6.1ms
    .i_cpu_thermtrip			(w_cpu_thermtrip_event	    ),					//0 -> 1 0.42ms
    .i_cpu_thermaltrip_clr	(w_fault_clear | ~w_cpu0_thermaltrip_clr| ~w_cpu1_thermaltrip_clr	),	
        
    .cpu_thermtrip_fault_det	(w_cpu_thermtrip_fault_det )
);


//-------------------------------------------------------------------------------------------------
//cpu thermtrip Signal Latch //2023-9-20 add
//-------------------------------------------------------------------------------------------------
wire  w_clear_register;
wire  wFM_CPU0_THERMTRIP_LVT3_Fault_N;
wire  wFM_CPU1_THERMTRIP_LVT3_Fault_N;

Signal_Latch#(
.EDGE        			(1'b0),
.INIT        			(1'b1),
.LATCH       			(1'b0),
.POWER_JUDGE  		(1'b1)
)Signal_Latch_THERMTRIP0(

    .i_Clk				(clk_50m        ),
    .i_Rst_n				(pon_reset_n),

    .i_Clr_Flag			(w_clear_register),//w_clear_register  1'b0
    .i_PWRGD_OK			(w_cpu_pwr_good & db_i_p0_pcie_rst_n_0),
    .i_Signal				(db_cpu_thermaltrip_n[0]),
    .o_Signal_Latch		(wFM_CPU0_THERMTRIP_LVT3_Fault_N),
    .o_Fault				(       )
);

Signal_Latch#(
.EDGE        			(1'b0),
.INIT        			(1'b1),
.LATCH       			(1'b0),
.POWER_JUDGE  		(1'b1)
)Signal_Latch_THERMTRIP1(

    .i_Clk				(clk_50m        ),
    .i_Rst_n				(pon_reset_n),

    .i_Clr_Flag			(w_clear_register),//w_clear_register  1'b0
    .i_PWRGD_OK			(w_cpu_pwr_good & db_i_p1_pcie_rst_n_0),
    .i_Signal				(db_cpu_thermaltrip_n[1]),
    .o_Signal_Latch		(wFM_CPU1_THERMTRIP_LVT3_Fault_N),
    .o_Fault				(       )
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU Module:Assume the CPU is Present
// CPU在位检测, 电源良好检测
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU 模块使能控制信号（低电平有效）
// 信号逻辑：
// - w_SW_1 = 0 → w_cpu_module_en_n = 0（CPU 模块使能，允许 CPU 上电、复位等逻辑工作）
// - w_SW_1 = 1 → w_cpu_module_en_n = 1（CPU 模块禁用，强制 CPU 相关逻辑不工作，常用于硬件调试或故障隔离）
// 注：w_SW_1 通常是主板上的物理拨码开关或 BMC 控制的软件开关，用于人工/远程控制 CPU 模块是否启用
assign w_cpu_module_en_n = w_SW_1  ;	//CPU 模块使能信号（低电平有效）0:CPU Module Enable  1: CPU Module disable

//Assume the CPU is Present
cpu_module cpu_module_u1	(
.clk				(clk_50m							),
.reset				((~pon_reset_n) | w_cpu_module_en_n	),
.t512us				(t512us_tick					),

.i_p0_pwrgood		(w_cpu_pwr_good					),	//from pwr_seq_slave
.i_p1_pwrgood		(db_i_p0_pwrgd_out				),	//from pwr_seq_slave		
.i_p0_rsmrset		(w_rsmrst_n						),
.i_p1_rsmrset		(w_rsmrst_n						),
.i_p0_pwr_btn_n		(~w_pal_pwrbtn_n_r				),

.o_p0_pwrok			(w_cpu_module_p0_pwrok			),
.o_p1_pwrok			(w_cpu_module_p1_pwrok			),	
.o_p0_pwrgoodout	(w_cpu_module_p0_pwrgdout			),
.o_p1_pwrgoodout	(w_cpu_module_p1_pwrgdout			),	
.o_p0_slp_s3_n		(w_cpu_module_p0_slp_s3_n			),
.o_p0_slp_s5_n		(w_cpu_module_p0_slp_s5_n			),
.o_p0_prsnt_n		(w_cpu_module_p0_prsnt_n			),
.o_p1_prsnt_n		(w_cpu_module_p1_prsnt_n			)
);

/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequence  Start
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/

assign  w_st_reset_state			        = (w_power_seq_sm==SM_RESET_STATE		);
assign  w_st_off_standby			        = (w_power_seq_sm==SM_OFF_STANDBY               );	//S5 
assign  w_st_steady_pwrok			= (w_power_seq_sm==SM_STEADY_PWROK		);	//S0
assign  w_st_halt_power_cycle		= (w_power_seq_sm==SM_HALT_POWER_CYCLE	);	//
assign  w_st_aux_fail_recovery		= (w_power_seq_sm==SM_AUX_FAIL_RECOVERY	);
assign  w_st_critical_fail			= (w_power_seq_sm==SM_CRITICAL_FAIL		);	
assign  w_st_disable_grp_d_vddio	        = (w_power_seq_sm==SM_DISABLE_GRP_D_VDDIO);	
  
//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequencer - Master : In order to shift the state
//--------------------------------------------------------------------------------------------------------------------------------------------------

assign  w_keep_alive_on_fault	=  w_force_allpwron_ctl || (~w_SW_3);//0:Enable power protect 1:Disable power protect  

pwrseq_master pwrseq_master_inst (
  .clk						(clk_50m				),	//in
  .reset					        (~pon_reset_n			),	//in
  .cmu_fault_clear_rst		(~pon_reset_n                      ),	//
  .t1us						(t1us_tick				),	//in
  .t512us					(t512us_tick			),	//in edge_delay tick
  .sequence_tick			        (t2ms_tick				),	//in 
  .psu_on_tick				(t32ms_tick				),	//in  
  .t256ms					(t256ms_tick			),	//in watch dog tick
  .t512ms					(t512ms_tick			),	//in unused 
  .t1s_tick					(t1s_tick				),	//in unused 
  
  .allow_recovery			(1'b0	),					//in
  .aux_video_holdoff		        (1'b0	),					//in
  .pgood_rst_mask			(1'b0	),					//in
  .keep_alive_on_fault		(w_keep_alive_on_fault	),	//in
  .pwron_override_n			(1'b1			                ),	//in
  .bmc_clr_stby_tmout_n		(~(w_stb_pwron_tmout_fail_clr & w_stb_pwrdown_ukwn_fail_clr & w_poweron_tmout_fail_clr)),	
  .power_seq_sm_fb			(r_power_seq_sm_fb		),	//in; 
  .mux_sel					(w_mux_sel				),	//in; 
  
  .sys_sw_in_n				(db_i_pwr_btn_cpld_n_r            ), //in; power button in board; SB (south bridge) system sleep state
  .pch_slp4_n				(db_i_p0_slp_s5_n	& r_bmc_ready 	),	//in; SB (south bridge) system sleep state   //20241231 add  r_bmc_ready
  .p0_pwrbtn_n				(~w_pal_pwrbtn_n_r			),	//in; SB power button input (same signal driven to SB PWRBTN)
  .pch_thermtrip_n			(w_cpu_thermtrip_event		),	//~amd_cpu_thrmtrip),//in, power down from power_button AMD has no PCH 
  .cpu_thermtrip_fault_det	(w_cpu_thermtrip_fault_det	),	// 
  
  .xr_ps_en					(1'b1			),				//xr_ps_enable), //in, from BMC 
  .interlock_broken			(1'b0			),				//db_cpu_prsnt_n[0] | interlock_broken),//in
  .s5dev_pwren_request		(w_s5dev_aux_pwren_request	),	//in, from pwrweq_slave
  .s5dev_pwrdis_request		(w_s5dev_aux_pwrdis_request	),	//in, from pwrweq_slave
  .pgd_so_far				(w_pgd_so_far				),	//in, FROM pwrweq_slave
  .any_pwr_fault_det		        (w_any_pwr_fault_det                ),	//in, FROM pwrweq_slave 
  .any_lim_recov_fault		(w_any_lim_recov_fault		),	//in, FROM pwrweq_slave
  .any_non_recov_fault		(w_any_non_recov_fault		),	//in, FROM pwrweq_slave
//  .bmc_ready_out_n		(~bmc_ready_out_n_r			),	//in, FROM CMU 

  .force_pwrbtn_n			(w_force_pwrbtn_n			),	//out, TO PSU(no use); forces SB to switch to S5 after power shutdown due to fault
  .pgd_raw					(w_pgd_raw					),	//out, TO PWRBTN_LEDS(no use)
  .dc_on_wait_complete		(w_dc_on_wait_complete		),	//out, TO SLAVE,
  .rt_critical_fail_store	(w_rt_critical_fail_store	),	//out, TO SLAVE/ADR/SYSTEM_RESET
  .fault_clear				(w_fault_clear				),	//out, TO SLAVE/PSU/THERMAL 
  .cmu_fault_clear			(w_cmu_fault_clear			),	//out,  
  .power_seq_sm				(w_power_seq_sm				),	//out, FSM status
  .fault_power				(w_power_fault				),	//out, TO PF/XREG/PWRBTN_LED/HEALTH_LEDS/UID/POST_LEDS/NIC_LEDS
  .stby_failure_detected	         (w_stby_failure_detected	),	//out, TO PF/XREG
  .po_failure_detected		(w_dc_failure_detected		),	//out, TO PF/XREG
  .rt_failure_detected		(w_rt_failure_detected		),	//out, TO PF/XREG
  .cpld_latch_sys_off		(w_cpld_latch_sys_off		),	//out, TO XREG
  .turn_on_wait				(w_turn_on_wait				),	//out, TO PWRBTN_LEDS
  .po_failure_detected_set	(	)                         	//out
);


//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequencer - Slave : 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//wire pal_pvcc_hpmos_sw_r;   
// wire    [2:0]   pcb_id;
// assign  pcb_id = 3'b000;

pwrseq_slave #(
  .SHARED_P5V_STBY_HPMOS(1'b1),
  .S5DEV_STUCKON_FAULT_CHK(1'b0),
  .NUM_CPU(`NUM_CPU),
  .NUM_OPT_AUX(0)
 // .NUM_S5DEV(`NUM_S5DEV),
) pwrseq_slave_inst (
  //base signal
  .clk							(clk_50m		),             
  .reset						        (~pon_reset_n	),
  .t1us							(t1us_tick		),
  .t512us						(t512us_tick	),	//unused
  .t1ms							(t1ms_tick		),
  .t2ms							(t2ms_tick		),
  .t64ms						        (t64ms_tick		),
  .t1s							(t1s_tick		),	//unused 
  
  .keep_alive_on_fault			(w_keep_alive_on_fault		),
//from pwrseq_master
  .dc_on_wait_complete			(w_dc_on_wait_complete		),	//in FROM MASTER
  .rt_critical_fail_store		(w_rt_critical_fail_store	),	//in FROM MASTER
  .fault_clear					(w_fault_clear				),	//in FROM MASTER
  .power_seq_sm					(w_power_seq_sm				),	//in FROM MASTER
//to pwrseq_master
  .pgd_so_far					(w_pgd_so_far				),
  .s5dev_pwren_request			(w_s5dev_aux_pwren_request	),       	
  .s5dev_pwrdis_request			(w_s5dev_aux_pwrdis_request	),           
  .any_pwr_fault_det			        (w_any_pwr_fault_det		),    		
  .any_lim_recov_fault			(w_any_lim_recov_fault		),          	
  .any_non_recov_fault			(w_any_non_recov_fault		),
  .any_aux_vrm_fault			        (w_any_aux_vrm_fault		),
  .any_recov_fault				(w_any_recov_fault			),

//from Power Controller PG signal 
  .p5v_stby_pg					(db_i_pg_p5v_stby			),
  .grp_b_p0_33_s5_pg			        (db_i_pgd_p0_vddc			),
  .grp_b_p1_33_s5_pg			        (db_i_pgd_p1_vddc		        ),					
  .grp_b_p0_18_s5_pg			        (db_i_pgd_p0_vdd_18_stby	),
  .grp_b_p1_18_s5_pg			        (db_i_pgd_p1_vdd_18_stby	),						
  .p3v3_stby_pg					(db_i_pwrgd_p3v3_stby		),	
  .p12v_stby_pg					(/* db_i_pg_p12v_stby_efuse */	),	 
  .p12v_efuse_pg				        (/* db_i_pg_p12v_efuse */			),  
  .p12v_ssd_efuse_pg			        (/* db_i_pg_p12v_ssd_efuse */		),    
  .p12v_p0_dimm_pg				(/* pg_cpu0_dimm_efuse */			),	//Active-low, need ~ 
  .p12v_p1_dimm_pg			        (		),  					
  .p5v_pg						(db_i_pgd_p5v			),

  .i_pwrgd_ocp0_nic_pwrgd		(/* db_i_pwrgd_ocp0_nic_pwrgd */	),
  .grp_c_p0_pg					(db_i_pgd_p0_vdd_11_sus		),
  .grp_c_p1_pg				        (db_i_pgd_p1_vdd_11_sus		),	
  .grp_d_vddio_p0_pg			        (db_i_pgd_p0_vddio			),
  .grp_d_vddio_p1_pg			        (db_i_pgd_p1_vddio		        ),	
  .grp_d_soc_p0_pg				(db_i_pgd_p0_vdd_soc_0		),
  .grp_d_soc_p1_pg			        (db_i_pgd_p1_vdd_soc_0		),	
  
  .grp_d_p0_vddcore0_pg			(db_i_pgd_p0_vdd_core_0		),
  .grp_d_p1_vddcore0_pg		        (db_i_pgd_p1_vdd_core_0		),						
  .grp_d_p0_vddcore1_pg			(db_i_pgd_p0_vdd_core_1		),
  .grp_d_p1_vddcore1_pg		        (db_i_pgd_p1_vdd_core_1		),	
  
//to Power Controller Enable Pin
  .p5v_stby_en					(w_p5v_stby_en				),
  .p5v_stby_usb_en				(w_p5v_stby_usb_en			),	
  .grp_b_p0_33_s5_en			        (w_grp_b_p0_33_s5_en		),
  .grp_b_p1_33_s5_en			        (w_grp_b_p1_33_s5_en		),						
  .grp_b_p0_18_s5_en			        (w_grp_b_p0_18_s5_en		),
  .grp_b_p1_18_s5_en			        (w_grp_b_p1_18_s5_en		),	
  .power_supply_on				(w_p12_en					),
  // .p12_en_p0_dimm_1				(w_p12_en_p0_dimm			), 
  // .p12_en_p1_dimm_1				(w_p12_en_p1_dimm		        ),						
  // .p12_en_p0_dimm_2				(			), 
  // .p12_en_p1_dimm_2				(		        ),						
  .p5v_en						(w_p5v_en					),
  .grp_c_p0_vdd11_en			        (w_grp_c_p0_vdd11_en		),
  .grp_c_p1_vdd11_en			        (w_grp_c_p1_vdd11_en		),						
  .grp_d_p0_vddio_en			        (w_grp_d_p0_vddio_en		),
  .grp_d_p1_vddio_en			        (w_grp_d_p1_vddio_en	        ),	
  .grp_d_p0_soc_en				(w_grp_d_p0_soc_en			),
  .grp_d_p1_soc_en			        (w_grp_d_p1_soc_en		        ),					
  .grp_d_p0_vddcore0_en			(w_grp_d_p0_vddcore0_en		),
  .grp_d_p1_vddcore0_en		        (w_grp_d_p1_vddcore0_en		),					
  .grp_d_p0_vddcore1_en			(w_grp_d_p0_vddcore1_en		),
  .grp_d_p1_vddcore1_en		        (w_grp_d_p1_vddcore1_en		),					
  // .pcb_id						(pcb_id						),															   
//to CMU
  // .usb_ponrst_r_n				(w_usb_ponrst_r_n			),
  // .tpcm_reset_n				        (tpcm_reset_n				), 
//to OCP
  .ocp_aux_en					(w_ocp_aux_en				),
  .ocp_main_en					(w_ocp_main_en				),	
//fault detect
  .pwrseq_sm_fault_det			(w_pwrseq_sm_fault_det		),
  .p5v_stby_fault_det			(w_p5v_stby_fault_det		),
  .grp_c_p0_fault_det			(w_grp_c_p0_fault_det		),
  .grp_c_p1_fault_det			(w_grp_c_p1_fault_det		),	
  .grp_d_vddio_p0_fault_det		(w_grp_d_vddio_p0_fault_det	), 
  .grp_d_vddio_p1_fault_det	        (w_grp_d_vddio_p1_fault_det	),	
  .grp_d_soc_p0_fault_det		(w_grp_d_soc_p0_fault_det	),  
  .grp_d_soc_p1_fault_det		(w_grp_d_soc_p1_fault_det	),	
  .grp_d_p0_vddcore0_fault_det	(w_grp_d_p0_vddcore0_fault_det),
  .grp_d_p1_vddcore0_fault_det	(w_grp_d_p1_vddcore0_fault_det),	
  .grp_d_p0_vddcore1_fault_det	(w_grp_d_p0_vddcore1_fault_det),
  .grp_d_p1_vddcore1_fault_det	(w_grp_d_p1_vddcore1_fault_det),	

  .grp_b_p0_33_s5_fault_det		(w_grp_b_p0_33_s5_fault_det	),
  .grp_b_p1_33_s5_fault_det	        (grp_b_p1_33_s5_fault_det	),	
  .grp_b_p0_18_s5_fault_det		(w_grp_b_p0_18_s5_fault_det	),
  .grp_b_p1_18_s5_fault_det	        (grp_b_p1_18_s5_fault_det	),					

  .p3v3_stby_fault_det			(w_p3v3_stby_fault_det		),	
  // .p12v_stby_fault_det			(w_p12v_stby_fault_det		),	
  .p5v_fault_det				         (w_p5v_fault_det			),
  // .p12v_efuse_fault_det			(w_p12v_efuse_fault_det		),
  // .p12v_ssd_efuse_fault_det		(w_p12v_ssd_efuse_fault_det	),
  // .p12v_p0_dimm_fault_det		(w_p12v_p0_dimm_fault_det	),
  // .p12v_p1_dimm_fault_det		(w_p12v_p1_dimm_fault_det	),			

//from CPU
  .i_cpu_pwrok					(w_cpu_pwrok				),	//from CPU PWROK
  .i_cpu_prsnt_n				(db_cpu_prsnt_n				),  //db_cpu_prsnt_n

//to CPU
  .o_p0_pwr_good				        (w_cpu_pwr_good				),	//for AMD BSP PWR_GOOD
  .o_cpu_pwrok					(o_cpu_pwrok				),	//for VR SVI RST
  .o_rsmrst_n					(w_rsmrst_n					),
  .reached_sm_wait_powerok		( )

  );


assign  w_all_stby_power_pg	= db_i_pg_p5v_stby								&
							  db_i_p1v8_stby_pg								&
							  db_i_pwrgd_p3v3_stby							&
							  // db_i_pg_p12v_stby_efuse						&
							  db_i_pgd_p0_vdd_18_stby						&
							 (db_i_pgd_p1_vdd_18_stby| db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vddc								&
							 (db_i_pgd_p1_vddc		 | db_cpu_prsnt_n[1])	;

assign  w_all_main_power_pg	=db_i_pgd_p0_vdd_11_sus						&
							 (db_i_pgd_p1_vdd_11_sus | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vddio								&
							 (db_i_pgd_p1_vddio		 | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vdd_soc_0							&
							 (db_i_pgd_p1_vdd_soc_0  | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vdd_core_0						&
							 (db_i_pgd_p1_vdd_core_0 | db_cpu_prsnt_n[1])	&
							  db_i_pgd_p0_vdd_core_1						&
							 (db_i_pgd_p1_vdd_core_1 | db_cpu_prsnt_n[1])	;//no OCP PG
							 
assign  w_all_power_pg = w_all_stby_power_pg & w_all_main_power_pg;

assign  w_cpu_sys_pwrok = db_cpu_prsnt_n[1] ? db_i_p0_pwrgd_out : (db_i_p0_pwrgd_out & db_i_p1_pwrgd_out);  

//--------------------------------------------------------------------------------------------------------------------------------------------------
//WDT 
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_bmc_warm_reset_ctl     ;

//CPU SYS_RESET
assign  w_p0_kbrst_n = ~w_bmc_warm_reset_ctl;  
assign  w_p1_kbrst_n = ~w_bmc_warm_reset_ctl;  
assign  w_cpu_pwrok[0]	= db_i_p0_pwrok;
assign  w_cpu_pwrok[1]	= db_i_p1_pwrok;
//CPU Prochot
assign  w_p0_prochot_n		= ~w_cpu0_prochot;
assign  w_p1_prochot_n		= ~w_cpu1_prochot;

wire fm_pld_db800_3_clks_en	;

/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//POWER Sequence  End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/


//--------------------------------------------------------------------------------------------------------------------------------------------------
//DIMM Fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
wire    w_p0_dimm_af_pwrgd_fail_event_clr;
wire    w_p0_dimm_gl_pwrgd_fail_event_clr;
wire    w_p1_dimm_af_pwrgd_fail_event_clr;
wire    w_p1_dimm_gl_pwrgd_fail_event_clr;

wire    w_p0_dimm_af_pwrgd_fail_event;
wire    w_p0_dimm_gl_pwrgd_fail_event;
wire    w_p1_dimm_af_pwrgd_fail_event;
wire    w_p1_dimm_gl_pwrgd_fail_event;


dimm_fail_event  cpu_dimm_fail_event(
.i_clk								(clk_50m 		),
.i_rst_n							(pon_reset_n	),
.i_dimm_pwrgd_fail_n	   		    ({
									 w_p0_dimm_af_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok),	
									 w_p0_dimm_gl_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok),
                                                                         w_p1_dimm_af_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok),
                                                                         w_p1_dimm_gl_pcamp_r | db_i_p0_bios_post_stage_r_n | (~w_st_steady_pwrok) 
                                                                         }) ,
.i_dimm_pwrgd_fail_event_clr_n		 ({
									  w_p0_dimm_af_pwrgd_fail_event_clr,
									  w_p0_dimm_gl_pwrgd_fail_event_clr,
                                                                          w_p1_dimm_af_pwrgd_fail_event_clr,
									  w_p1_dimm_gl_pwrgd_fail_event_clr
									   }),
.o_dimm_pwrgd_fail_event			 ({
									  w_p0_dimm_af_pwrgd_fail_event,
									  w_p0_dimm_gl_pwrgd_fail_event,
                                                                          w_p1_dimm_af_pwrgd_fail_event,
									  w_p1_dimm_gl_pwrgd_fail_event                                                                         
									   })
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
//error code 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//2025-2-9 add
wire    w_bmc_clr_tmout_n;
wire    [7:0]  w_pwr_flt_code;
wire    w_p1v0_stby_m2_en_check;

edge_delay #(.CNTR_NBITS(2)) p1v0_stby_m2_check_inst (
  .clk                    (clk_50m          ),
  .reset                (~pon_reset_n),
  .cnt_size          (2'b10              ),
  .cnt_step          (t64ms_tick                          ),
  .signal_in        (w_p1v0_stby_m2_en            ),
  .delay_output  (w_p1v0_stby_m2_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v0_stby_m2_fault_detect_inst (
  .clk                          (clk_50m            ),		//in
  .reset                      (~pon_reset_n  ),		//in
  .vrm_enable            (w_p1v0_stby_m2_en && w_p1v0_stby_m2_en_check),//in
  .vrm_pgood              (db_i_pg_p1v0_stby_m2_r       ),					//in
  .vrm_chklive_en    (w_p1v0_stby_m2_en_check     ),					//in
  .vrm_chklive_dis  (~w_p1v0_stby_m2_en_check   ),					//in
  .critical_fail      (w_st_critical_fail               ),					//in
  .fault_clear          (w_fault_clear                         ),					//in
  .lock                        (w_any_pwr_fault_det             ),				        //in
  .any_vrm_fault      ( ),									                //out
  .vrm_fault              (w_p1v0_stby_m2_fault_det   )					//out
);

error_code  error_code_int(
.i_clk								(clk_50m						),
.i_reset							(pon_reset_n					),
// .i_stby_failure_detected			(w_stby_failure_detected                ),
// .i_po_failure_detected				(w_dc_failure_detected			),
// .i_rt_failure_detected				(w_rt_failure_detected			),
// .i_any_pwr_fault_det				(w_any_pwr_fault_det			),
.i_power_fail_err_code_clr                   (~w_bmc_clr_tmout_n),

.i_p3v3_stby_fault_det				(w_p3v3_stby_fault_det			),	//0x02
.i_p5v0_stby_fault_det				(w_p5v_stby_fault_det			),	//0x03	//MB
.i_p12v_stby_fault_det				(1'b0			                                ),	//0x04  

.i_bmc_p3v3_bmc_rgm_fault_det		(1'b0	         ),	//0x0b	//from bmc 	
.i_bmc_p2v5_stby_fault_det			(1'b0		),	//0x0c	//from bmc
.i_bmc_p1v8_stby_fault_det			(1'b0		),	//0x0d	//from bmc
.i_bmc_p1v2_stby_fault_det			(1'b0		),	//0x0e	//from bmc
.i_cmu_p1v05_stby_fault_det			(1'b0		),	//0x0f	//from none 
.i_bmc_p1v0_stby_fault_det			(1'b0		),	//0x10	
.i_bmc_p3v3_stby_fault_det			(1'b0		),	//0x20
.i_bmc_p1v8_stby_pe_rc_fault_det	(1'b0	),	//0x21

.i_p1v0_stby_m2_fault_det			(w_p1v0_stby_m2_fault_det 	        ),	//0x22
// .i_p3v3_m2_fault_det				(1'b0		),//0x09	//from P3V3	//0x09	
.i_p5v_fault_det					(w_p5v_fault_det				),	//0x19

.i_grp_b_p0_18_s5_fault_det			(w_grp_b_p0_18_s5_fault_det		),	//0x05
.i_grp_b_p1_18_s5_fault_det			(w_grp_b_p1_18_s5_fault_det		),	//0x06	
.i_grp_b_p0_33_s5_fault_det			(w_grp_b_p0_33_s5_fault_det		),	//0x07
.i_grp_b_p1_33_s5_fault_det			(w_grp_b_p1_33_s5_fault_det		),	//0x08	 

.i_grp_c_p0_fault_det				(w_grp_c_p0_fault_det			),	//0x1e
.i_grp_c_p1_fault_det				(w_grp_c_p1_fault_det		        ),	//0x1f	 

.i_grp_d_vddio_p0_fault_det			(w_grp_d_vddio_p0_fault_det		),	//0x11
.i_grp_d_vddio_p1_fault_det			(w_grp_d_vddio_p1_fault_det		),						 
.i_grp_d_soc_p0_fault_det			(w_grp_d_soc_p0_fault_det		),  //0x13
.i_grp_d_soc_p1_fault_det			(w_grp_d_soc_p1_fault_det		),						 
.i_grp_d_p0_vddcore0_fault_det		(w_grp_d_p0_vddcore0_fault_det	),	//0x15
.i_grp_d_p0_vddcore1_fault_det		(w_grp_d_p0_vddcore1_fault_det	),	//0x16
.i_grp_d_p1_vddcore0_fault_det		(w_grp_d_p1_vddcore0_fault_det	),						 
.i_grp_d_p1_vddcore1_fault_det		(w_grp_d_p1_vddcore1_fault_det	),						 

 

    .o_pwr_flt_code                        (w_pwr_flt_code)
);

wire    w_power_fault_detected	;
assign  w_power_fault_detected	= w_rt_failure_detected | w_stby_failure_detected  ;	




//MCIO
wire    [15:0]    w_mb_to_bp_mciop0p0a_data;
wire    [15:0]    w_mb_to_bp_mciop0p0c_data;

wire    [15:0]    w_bp_to_mb_mciop0p0a_data;
wire    [15:0]    w_bp_to_mb_mciop0p0c_data;

wire    w_pal_p0_mciop0a_pwr_en;
wire    w_pal_p0_mciop0c_pwr_en;


wire    [5:0]   w_mcio_rsvd_bit15_10;
wire    [1:0]   w_mcio_rsvd_bit9_8;
wire    [2:0]   w_mcio_rsvd_bit7_5;
wire    [3:0]   w_mcio_vpp_addr_bit4_1;

assign  w_mcio_rsvd_bit15_10       =    6'b0;
assign  w_mcio_rsvd_bit9_8          =    2'b11;
assign  w_mcio_rsvd_bit7_5           =    3'b100;
assign  w_mcio_vpp_addr_bit4_1  =   4'b0000;

assign  w_mb_to_bp_mciop0p0a_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop0a_pwr_en};
assign  w_mb_to_bp_mciop0p0c_data     =   {w_mcio_rsvd_bit15_10,w_mcio_rsvd_bit9_8,w_mcio_rsvd_bit7_5,w_mcio_vpp_addr_bit4_1,w_pal_p0_mciop0c_pwr_en};

assign  w_p0_mciop0a_slot_id    =   w_bp_to_mb_mciop0p0a_data[7:0];
assign  w_p0_mciop0c_slot_id    =   w_bp_to_mb_mciop0p0c_data[7:0];

assign w_pal_p0_mciop0a_pwr_en    = (w_PWRGD_P12V && db_i_p0_slp_s5_n) ? 1'b1 : 1'b0   ;  
assign w_pal_p0_mciop0c_pwr_en    = (w_PWRGD_P12V && db_i_p0_slp_s5_n) ? 1'b1 : 1'b0   ;  

//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P0A  --> J185    MCIOP0A
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u1 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p0a_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p0a_data)  , //output
	.ser_data              (io_P0_MCIOP0A_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop0a_pwr_en    )  , //input
	.mcio_cable_id0  (w_P0_MCIOP0A_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP0A_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);
//--------------------------------------------------------------------------------------------------------------------------------------------------
// CPU0 P0C  --> J48    MCIOP0C
// -------------------------------------------------------------------------------------------------------------------------------------------------
UART_MASTER #(.NBIT_IN(16), .NBIT_OUT(16), .BPS_COUNT_NUM(48), .START_COUNT_NUM(24)) uart_master_u2 (
	.clk                        (clk_50m            )  ,             //input
	.rst                        (~pon_reset_n  )  ,             //input
	.tick                      (t16us_tick      )  ,             //input
	.send_enable        (1'b1                  )  ,             //input
         .t128ms_tick       (t128ms_tick    )  ,             //input
	.par_data_in        (w_mb_to_bp_mciop0p0c_data)  , //input 
	.par_data_out      (w_bp_to_mb_mciop0p0c_data)  , //output
	.ser_data              (io_P0_MCIOP0C_PWR_EN_R      )  , //inout
         .riser_en_out     (w_pal_p0_mciop0c_pwr_en    )  , //input
	.mcio_cable_id0  (w_P0_MCIOP0C_CB_ID0_R        )  , //input
	.mcio_cable_id1  (w_P0_MCIOP0C_CB_ID1_R        )  , //input

	.error_flag          (  )                          //output
);

assign  w_p0_mciop1a_slot_id[0] =   1'b0;
assign  w_p0_mciop1c_slot_id[0] =   1'b0;
assign  w_p0_mciop2a_slot_id[0] =   1'b0;
assign  w_p0_mciop2c_slot_id[0] =   1'b0;
assign  w_p0_mciop3a_slot_id[0] =   1'b0;
assign  w_p0_mciop3c_slot_id[0] =   1'b0;
assign  w_p0_mciog3a_slot_id[0] =   1'b0;
assign  w_p0_mciog3c_slot_id[0] =   1'b0;
assign  w_p1_mciog1a_slot_id[0] =   1'b0;
assign  w_p1_mciog1c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
assign  w_p1_mciop3a_slot_id[0] =   1'b0;
assign  w_p1_mciop3c_slot_id[0] =   1'b0;
//SERVER_ID_C5
wire    [7:0]  w_server_id_c5;

assign  w_server_id_c5  =   (w_bf_type==2'b10)?8'h60:8'h41;

//------------------------------------------------------------------------------
//ESPI
// ------------------------------------------------------------------------------    
wire [15:0]  pch_espi_addr ;
wire [7:0]   pch_espi_wdata ;
wire [7:0]   pch_espi_rdata ;
wire         pch_smbus_wdata_en ;

wire [7:0]   w_espi_debug_ram_1000;
wire [7:0]   w_espi_debug_ram_1001;
wire [7:0]   w_espi_debug_ram_1002;
wire [7:0]   w_espi_debug_ram_1003;
wire [7:0]   w_espi_debug_ram_1004;
wire [7:0]   w_espi_debug_ram_1005;
wire [7:0]   w_espi_debug_ram_1006;

wire [7:0]   w_espi_ram_1050;
wire [7:0]   w_espi_ram_1051;
wire [7:0]   w_espi_ram_1052;
wire [7:0]   w_espi_ram_1053;  //2023-11-8 add
wire [7:0]   w_espi_ram_1054;  //2023-11-8 add
wire    [7:0]   w_espi_ram_1055;
wire    [7:0]   w_espi_ram_1056;
wire    [7:0]   w_espi_ram_1057;
wire    [7:0]   w_espi_ram_1058;

espi_link bios_espi_link(
    .ESPI_CLK    (i_CPLD_ESPI_CLK    ),                                            //input
    .ESPI_RST    (i_CPLD_ESPI_RESET_N    ),                                            //input
    .ESPI_CS1    (i_CPLD_ESPI_CS_N   ),                                            //input
    .ESPI_IO_IN  (i_CPLD_ESPI_D0     ),                                            //input
    .ESPI_IO_OUT (o_CPLD_ESPI_D1    ),                                            //output
    .pch_addr    (pch_espi_addr),//pch_espi_addr                                  //output
    .pch_smbus_wdata(pch_espi_wdata),//pch_espi_wdata                             //output
    .pch_smbus_rdata(pch_espi_rdata),//pch_espi_rdata                             //input
    .pch_smbus_wdata_en(pch_smbus_wdata_en), // pch_smbus_wdata_en      //output
    .debug_flag  (       ),//debug_flag                                           //output
    .debug_flag1 (      ),//debug_flag1                                           //output
    .debug_flag2 (      )//debug_flag2                                            //output
);


/*-------------------------------------------------------------------------------------------------------------------------------------------------------
PCH_CPLD_I2C_RAM 模块实例化
功能：
eSPI 接口的数据缓存层，作用是：1.缓存 CPLD 采集的硬件状态（如 MCIO 槽线缆 ID、扩展卡槽位 ID）；2.存储 PCH 下发的配置指令；3.响应 PCH 的读写请求（PCH 读状态、写配置)
eSPI 数据缓存模块：缓存硬件状态并存储 PCH 配置指令，响应 PCH 读写请求

//为更清晰理解模块间交互，以 “PCH 读取 CPU0-P0A 槽位 ID（w_p0_mciop0a_slot_id）” 为例，梳理完整流程：
// 1.PCH 发起读请求：
// PCH 通过 eSPI 发送 “读地址 0x1100” 的串行命令（包含 CLK、CS、地址信号）；
// espi_link 模块将串行地址转换为并行地址 pch_espi_addr=16'h1100，并置 pch_smbus_wdata_en=0（标记为读操作）。
// 2.CPLD 缓存响应：
// pch_cpld_espi_ram 模块检测到 i_espi_addr=0x1100 且 i_espi_wdata_en=0，从缓存中提取 i_espi_ram_1100（即 w_p0_mciop0a_slot_id）；
// 将提取的槽位 ID 赋值给 o_espi_date_in（即 pch_espi_rdata）。
// 3.CPLD 反馈数据：
// espi_link 模块将并行数据 pch_espi_rdata 转换为串行信号，通过 ESPI_IO_OUT 发送给 PCH；
// 4.PCH 处理数据：
// PCH 接收串行数据，解析出 CPU0-P0A 槽位 ID（如 0x01 = 有卡，0x00 = 无卡），并根据结果执行后续操作（如有卡则启用该槽电源，无卡则禁用）。
---------------------------------------------------------------------------------------------------------------------------------------------------------*/
pch_cpld_espi_ram  pch_cpld_espi_ram_u1
(
    //  基础时钟与复位信号
    .i_rst_n                        (pon_reset_n                ), // 输入：全局复位（高电平有效，复位时清空所有缓存）
    .i_clk                          (clk_50m                    ), // 输入：CPLD 系统时钟（50MHz，缓存读写时序基准）
    .i_clk_10ms                     (w10mSCE                    ), // 输入：10ms 时钟使能（用于周期性更新硬件状态缓存，避免高频刷新）

    // eSPI 读写接口（与 espi_link 模块对接）
    .i_espi_addr                    (pch_espi_addr              ), // 输入：eSPI 目标地址（PCH 要读写的地址，如 0x1000）
    .i_espi_date_out                (pch_espi_wdata             ), // 输入：eSPI 写数据（PCH 写入缓存的数据，如配置指令）
    .o_espi_date_in                 (pch_espi_rdata             ), // 输出：eSPI 读数据（缓存中的硬件状态，反馈给 PCH）
    .i_espi_wdata_en                (pch_smbus_wdata_en         ), // 输入：eSPI 写使能（1=PCH 写操作，存储 i_espi_date_out 到对应地址）

    //////////////////////////////////pcie dync alloc start 0x1000-0x1005///////////////////////////
    // MCIO 槽线缆 ID 输入（CPLD 采集的硬件状态，缓存到 debug_ram）
    // 注：以下信号均为“线缆 ID 信号”（0=线缆正常连接，1=连接异常），对应不同 MCIO 槽
    // CPU0 相关 MCIO 槽线缆 ID
    .i_p0_mciog3a_cb_id0            (w_P0_MCIOG3A_CB_ID0_R      ),
    .i_p0_mciog3a_cb_id1            (w_P0_MCIOG3A_CB_ID1_R      ),
    .i_p0_mciog3c_cb_id0            (w_P0_MCIOG3C_CB_ID0_R      ),
    .i_p0_mciog3c_cb_id1            (w_P0_MCIOG3C_CB_ID1_R      ),
 
    .i_p0_mciop0a_cb_id0            (w_P0_MCIOP0A_CB_ID0_R      ),
    .i_p0_mciop0a_cb_id1            (w_P0_MCIOP0A_CB_ID1_R      ),
    .i_p0_mciop0c_cb_id0            (w_P0_MCIOP0C_CB_ID0_R      ),
    .i_p0_mciop0c_cb_id1            (w_P0_MCIOP0C_CB_ID1_R      ),
    
    .i_p0_mciop1a_cb_id0            (w_P0_MCIOP1A_CB_ID0_R      ),
    .i_p0_mciop1a_cb_id1            (w_P0_MCIOP1A_CB_ID1_R      ),
    .i_p0_mciop1c_cb_id0            (w_P0_MCIOP1C_CB_ID0_R      ),
    .i_p0_mciop1c_cb_id1            (w_P0_MCIOP1C_CB_ID1_R      ),
    
    .i_p0_mciop2a_cb_id0            (w_P0_MCIOP2A_CB_ID0_R      ),
    .i_p0_mciop2a_cb_id1            (w_P0_MCIOP2A_CB_ID1_R      ),
    .i_p0_mciop2c_cb_id0            (w_P0_MCIOP2C_CB_ID0_R      ),
    .i_p0_mciop2c_cb_id1            (w_P0_MCIOP2C_CB_ID1_R      ),

    .i_p0_mciop3a_cb_id0            (w_P0_MCIOP3A_CB_ID0_R      ),
    .i_p0_mciop3a_cb_id1            (w_P0_MCIOP3A_CB_ID1_R      ),
    .i_p0_mciop3c_cb_id0            (w_P0_MCIOP3C_CB_ID0_R      ),
    .i_p0_mciop3c_cb_id1            (w_P0_MCIOP3C_CB_ID1_R      ),

    .i_p1_mciog1a_cb_id0            (w_P1_MCIOG1A_CB_ID0_R      ),
    .i_p1_mciog1a_cb_id1            (w_P1_MCIOG1A_CB_ID1_R      ),
    .i_p1_mciog1c_cb_id0            (w_P1_MCIOG1C_CB_ID0_R      ),
    .i_p1_mciog1c_cb_id1            (w_P1_MCIOG1C_CB_ID1_R      ),

    .i_p1_mciop0a_cb_id0            (w_P1_MCIOP0A_CB_ID0_R      ),
    .i_p1_mciop0a_cb_id1            (w_P1_MCIOP0A_CB_ID1_R      ),
    .i_p1_mciop0c_cb_id0            (w_P1_MCIOP0C_CB_ID0_R      ),
    .i_p1_mciop0c_cb_id1            (w_P1_MCIOP0C_CB_ID1_R      ),

    .i_p1_mciop1a_cb_id0            (w_P1_MCIOP1A_CB_ID0_R      ),
    .i_p1_mciop1a_cb_id1            (w_P1_MCIOP1A_CB_ID1_R      ),
    .i_p1_mciop1c_cb_id0            (w_P1_MCIOP1C_CB_ID0_R      ),
    .i_p1_mciop1c_cb_id1            (w_P1_MCIOP1C_CB_ID1_R      ),

    .i_p1_mciop2a_cb_id0            (w_P1_MCIOP2A_CB_ID0_R      ),
    .i_p1_mciop2a_cb_id1            (w_P1_MCIOP2A_CB_ID1_R      ),
    .i_p1_mciop2c_cb_id0            (w_P1_MCIOP2C_CB_ID0_R      ),
    .i_p1_mciop2c_cb_id1            (w_P1_MCIOP2C_CB_ID1_R      ),

    .i_p1_mciop3a_cb_id0            (w_P1_MCIOP3A_CB_ID0_R      ),
    .i_p1_mciop3a_cb_id1            (w_P1_MCIOP3A_CB_ID1_R      ),
    .i_p1_mciop3c_cb_id0            (w_P1_MCIOP3C_CB_ID0_R      ),
    .i_p1_mciop3c_cb_id1            (w_P1_MCIOP3C_CB_ID1_R      ),

    //////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
    // 主板固定配置输入（芯片级配置，缓存到固定地址 0x00C0-0x00D0）
    .i_PRODUCT_LINE_C2	            (`PRODUCT_LINE_C2           ), // 输入：产品系列 ID（如 R6900 G5，宏定义，固定值）
    .i_PRODUCT_GEN_ID_C3            (`PRODUCT_GEN_ID_C3         ), // 输入：产品世代 ID（如 G5 世代，宏定义，固定值）
    .i_SERVER_ID_C5                 ( w_server_id_c5            ), // 输入：服务器 ID（之前定义，区分不同背板配置，如 0x41/0x60）
    .i_BOARD_ID_C6                  (`BOARD_ID_C6               ), // 输入：主板 ID（区分不同主板版本，如 Rev A/B，宏定义）
    //////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////pcie dync alloc end 0x1000-0x1005/////////////////////////
	  //test 0x1006
    // 调试缓存输出（缓存的 MCIO 槽状态，对应地址 0x1000-0x1006）
    .o_espi_debug_ram_1000          (w_espi_debug_ram_1000      ), // 输出：地址 0x1000 缓存值（P0 MCIOG3A 槽状态）
    .o_espi_debug_ram_1001          (w_espi_debug_ram_1001      ), // 输出：地址 0x1001 缓存值（P0 MCIOG3C 槽状态）
    .o_espi_debug_ram_1002          (w_espi_debug_ram_1002      ), // 输出：地址 0x1002 缓存值（P0 MCIOP0A 槽状态）
    .o_espi_debug_ram_1003          (w_espi_debug_ram_1003      ), // 输出：地址 0x1003 缓存值（P0 MCIOP0C 槽状态）
    .o_espi_debug_ram_1004          (w_espi_debug_ram_1004      ), // 输出：地址 0x1004 缓存值（P0 MCIOP1A 槽状态）
    .o_espi_debug_ram_1005          (w_espi_debug_ram_1005      ), // 输出：地址 0x1005 缓存值（P0 MCIOP1C 槽状态）
    .o_test_reg                     (w_espi_debug_ram_1006      ), // 输出：地址 0x1006 测试值（验证 eSPI 通信）

    // 配置缓存输入（PCH 下发的配置指令，对应地址 0x1050-0x1053）
    .i_espi_ram_1050                (w_espi_ram_1050            ), // 输入：地址 0x1050 配置值（PCH 下发的配置1）
    .i_espi_ram_1051                (w_espi_ram_1051            ), // 输入：地址 0x1051 配置值（PCH 下发的配置2）
    .i_espi_ram_1052                (w_espi_ram_1052            ), // 输入：地址 0x1052 配置值（PCH 下发的配置3）
    .i_espi_ram_1053                (w_espi_ram_1053            ), // 输入：地址 0x1053 配置值（PCH 下发的配置4）

    /////////////////2024-3-3 ADD/////////////////////////////////////        
    // 扩展卡槽位 ID 输入（2024-3-3 新增，缓存到地址 0x1100-0x1113）
    // 注：以下信号均为“扩展卡槽位 ID”（如 0x01=槽位有卡，0x00=无卡），对应不同 CPU 的扩展槽 
    .i_espi_ram_1100                (w_p0_mciop0a_slot_id       ), // 输入：地址 0x1100，CPU0-P0A 槽位 ID（J185）
    .i_espi_ram_1101                (w_p0_mciop0c_slot_id       ), // 输入：地址 0x1101，CPU0-P0C 槽位 ID（J48）
    .i_espi_ram_1102                (w_p0_mciop1a_slot_id       ), // 输入：地址 0x1102，CPU0-P1A 槽位 ID（J75）
    .i_espi_ram_1103                (w_p0_mciop1c_slot_id       ), // 输入：地址 0x1103，CPU0-P1C 槽位 ID（J76）
    .i_espi_ram_1104                (w_p0_mciop2a_slot_id       ), //CPU0-P2A  J40    SLOT_ID
    .i_espi_ram_1105                (w_p0_mciop2c_slot_id       ), //CPU0-P2C  J41    SLOT_ID
    .i_espi_ram_1106                (w_p0_mciop3a_slot_id       ), //CPU0-P3A  J42    SLOT_ID
    .i_espi_ram_1107                (w_p0_mciop3c_slot_id       ), //CPU0-P3C  J43    SLOT_ID
    .i_espi_ram_1108                (w_p0_mciog3a_slot_id       ), //CPU0-G3A  J45    SLOT_ID
    .i_espi_ram_1109                (w_p0_mciog3c_slot_id       ), //CPU0-G3C  J44    SLOT_ID
    
    .i_espi_ram_110a                (w_p1_mciop0a_slot_id       ),//CPU1-P0A  J73    SLOT_ID
    .i_espi_ram_110b                (w_p1_mciop0c_slot_id       ),//CPU1-P0C  J74    SLOT_ID
    .i_espi_ram_110c                (w_p1_mciop1a_slot_id       ),//CPU1-P1A  J204    SLOT_ID
    .i_espi_ram_110d                (w_p1_mciop1c_slot_id       ),//CPU1-P1C  J203    SLOT_ID
    .i_espi_ram_110e                (w_p1_mciop2a_slot_id       ),//CPU1-P2A  J205    SLOT_ID
    .i_espi_ram_110f                (w_p1_mciop2c_slot_id       ),//CPU1-P2C  J206    SLOT_ID
    .i_espi_ram_1110                (w_p1_mciop3a_slot_id       ),//CPU1-P3A  J207    SLOT_ID
    .i_espi_ram_1111                (w_p1_mciop3c_slot_id       ),//CPU1-P3C  J208    SLOT_ID
    .i_espi_ram_1112                (w_p1_mciog1a_slot_id       ),//CPU1-G1A  J210    SLOT_ID        
    .i_espi_ram_1113                (w_p1_mciog1c_slot_id       )  //CPU1-G1C  J209    SLOT_ID
);

//------------------------------------------------------------------------------------------------//
//BIOS_CPLD_IIC
//------------------------------------------------------------------------------------------------//
wire [7:0]   w_bios_debug_ram_1000;
wire [7:0]   w_bios_debug_ram_1001;
wire [7:0]   w_bios_debug_ram_1002;
wire [7:0]   w_bios_debug_ram_1003;
wire [7:0]   w_bios_debug_ram_1004;
wire [7:0]   w_bios_debug_ram_1005;
wire [7:0]   w_bios_debug_ram_1006;


/*-------------------------------------------------------------------------------------------------------------------------------------------------------
BIOS_CPLD_I2C_RAM 模块实例化
功能：
该部分代码聚焦于 服务器 BIOS 与 CPLD 之间的 I2C 接口通信，核心模块 bios_cpld_i2c_ram.“硬件状态缓存”“配置指令存储”“I2C 数据收发”
bios_cpld_i2c_ram 是 BIOS-CPLD I2C 通信的核心，集成 “数据缓存” 与 “I2C 物理层驱动”，实现 “BIOS 读状态、写配置” 的完整交互
1. 通过I2C接口与外部设备通信，支持数据的读写操作
2. 提供多个输入信号，用于传递系统状态和配置信息
3. 输出信号用于与其他模块交互，支持状态反馈和控制

//模式切换配置（如 i_switch_mode）：BIOS 根据系统负载（如高负载时）向 0x1010 地址写 “1”，CPLD 读取后切换硬件到 “高性能模式”（如提高 CPU 核心电压、PCIe 带宽）；
//扩展卡槽位 ID（如 w_p0_mciop0a_slot_id ）：BIOS 读取 0x1100 地址后，若识别到 “有卡”（0x01），则自动加载该扩展卡的驱动（如 GPU 驱动、网卡驱动），实现 “即插即用”；
//配置地址复用（如 0x1050-0x1058 与 eSPI 接口共享）：BIOS 可通过任意接口（eSPI 或 I2C）下发配置，提高系统兼容性（如 BIOS 启动初期优先用 I2C，后期用 eSPI 高速传输）

// 为清晰理解模块交互，以 “BIOS 通过 I2C 配置 CPU0-P0A 槽为‘PCIe 5.0 模式’” 为例，梳理完整流程：
// 1.BIOS 发起 I2C 写请求：
// BIOS 确定配置地址（如 0x1011 ，对应 i_switch2_mode）和配置值（1=PCIe 5.0 模式）；
// BIOS 通过 I2C 发送 “从设备地址（CPLD 的 I2C 地址）+ 写命令 + 地址 0x1011 + 数据 0x01”，SCL 时钟同步数据传输；
// CPLD 的 bios_cpld_i2c_ram 模块通过 i_scl 和 io_P0_CPLD_SDA 接收串行数据，解析出 “地址 0x1011” 和 “数据 0x01”。
// 2.CPLD 存储配置并执行：
// bios_cpld_i2c_ram 将数据 0x01 存储到 i_switch2_mode 对应的缓存地址；
// CPLD 硬件逻辑读取 i_switch2_mode=1，触发 MCIO 槽的 PCIe 模式切换（如调整 PCIe 控制器的时序、带宽参数），切换到 “PCIe 5.0 模式”。
// 3.BIOS 验证配置结果：
// BIOS 发起 I2C 读请求，读取地址 0x1011 的值；
// bios_cpld_i2c_ram 从缓存中提取数据 0x01，通过 io_P0_CPLD_SDA 反馈给 BIOS；
// BIOS 对比 “写值” 与 “读值” 一致，确认配置成功，继续后续启动流程。
---------------------------------------------------------------------------------------------------------------------------------------------------------*/
bios_cpld_i2c_ram #(
    .DLY_LEN                        (16                         )  // 50MHz,330n. I2C 通信延迟长度：50MHz 时钟下，16 个时钟周期对应延迟=16*(1/50MHz)=320ns（匹配 I2C 标准时序）
)bios_cpld_i2c_ram_u0 (
    .i_rst_n		                    (pon_reset_n	              ), // 输入：全局复位（高电平有效，复位时清空所有缓存、重置 I2C 状态机）  
    .i_clk			                    (clk_25m		                ), // 输入：CPLD 系统时钟（25MHz，I2C 时序生成与缓存更新的基准）
    .i_1ms_clk		                  (t1ms_tick		              ), // 输入：1ms 时钟使能（周期性更新硬件状态缓存，每 1ms 刷新一次，平衡实时性与功耗）	          
    .i_rst_i2c_n	                  (1'b1			                  ), // 输入：I2C 单独复位（固定为 1'b1，当前设计复用全局复位，预留单独复位功能）		
    
    // I2C 物理层信号：BIOS 与 CPLD 之间的硬件连接
    .i_scl			                    (i_P0_CPLD_SCL	            ), 
    .io_sda			                    (io_P0_CPLD_SDA	            ),

    //////////////////////////////////pcie dync alloc start 0x1000-0x1005///////////////////////////
    /*
    MCIO 槽线缆 ID 输入（CPLD 采集的硬件状态，缓存到 debug_ram）
    注：以下信号均为“线缆 ID 信号”（0=线缆正常连接，1=连接异常），对应不同 MCIO 槽，CPU0 相关 MCIO 槽线缆 ID
    */
    .i_p0_mciog3a_cb_id0            (w_P0_MCIOG3A_CB_ID0_R      ),
    .i_p0_mciog3a_cb_id1            (w_P0_MCIOG3A_CB_ID1_R      ),
    .i_p0_mciog3c_cb_id0            (w_P0_MCIOG3C_CB_ID0_R      ),
    .i_p0_mciog3c_cb_id1            (w_P0_MCIOG3C_CB_ID1_R      ),

    .i_p0_mciop0a_cb_id0            (w_P0_MCIOP0A_CB_ID0_R      ),
    .i_p0_mciop0a_cb_id1            (w_P0_MCIOP0A_CB_ID1_R      ),
    .i_p0_mciop0c_cb_id0            (w_P0_MCIOP0C_CB_ID0_R      ),
    .i_p0_mciop0c_cb_id1            (w_P0_MCIOP0C_CB_ID1_R      ),
    
    .i_p0_mciop1a_cb_id0            (w_P0_MCIOP1A_CB_ID0_R      ),
    .i_p0_mciop1a_cb_id1            (w_P0_MCIOP1A_CB_ID1_R      ),
    .i_p0_mciop1c_cb_id0            (w_P0_MCIOP1C_CB_ID0_R      ),
    .i_p0_mciop1c_cb_id1            (w_P0_MCIOP1C_CB_ID1_R      ),
    
    .i_p0_mciop2a_cb_id0            (w_P0_MCIOP2A_CB_ID0_R      ),
    .i_p0_mciop2a_cb_id1            (w_P0_MCIOP2A_CB_ID1_R      ),
    .i_p0_mciop2c_cb_id0            (w_P0_MCIOP2C_CB_ID0_R      ),
    .i_p0_mciop2c_cb_id1            (w_P0_MCIOP2C_CB_ID1_R      ),

    .i_p0_mciop3a_cb_id0            (w_P0_MCIOP3A_CB_ID0_R      ),
    .i_p0_mciop3a_cb_id1            (w_P0_MCIOP3A_CB_ID1_R      ),
    .i_p0_mciop3c_cb_id0            (w_P0_MCIOP3C_CB_ID0_R      ),
    .i_p0_mciop3c_cb_id1            (w_P0_MCIOP3C_CB_ID1_R      ),

    .i_p1_mciog1a_cb_id0            (w_P1_MCIOG1A_CB_ID0_R      ),
    .i_p1_mciog1a_cb_id1            (w_P1_MCIOG1A_CB_ID1_R      ),
    .i_p1_mciog1c_cb_id0            (w_P1_MCIOG1C_CB_ID0_R      ),
    .i_p1_mciog1c_cb_id1            (w_P1_MCIOG1C_CB_ID1_R      ),

    .i_p1_mciop0a_cb_id0            (w_P1_MCIOP0A_CB_ID0_R      ),
    .i_p1_mciop0a_cb_id1            (w_P1_MCIOP0A_CB_ID1_R      ),
    .i_p1_mciop0c_cb_id0            (w_P1_MCIOP0C_CB_ID0_R      ),
    .i_p1_mciop0c_cb_id1            (w_P1_MCIOP0C_CB_ID1_R      ),

    .i_p1_mciop1a_cb_id0            (w_P1_MCIOP1A_CB_ID0_R      ),
    .i_p1_mciop1a_cb_id1            (w_P1_MCIOP1A_CB_ID1_R      ),
    .i_p1_mciop1c_cb_id0            (w_P1_MCIOP1C_CB_ID0_R      ),
    .i_p1_mciop1c_cb_id1            (w_P1_MCIOP1C_CB_ID1_R      ),

    .i_p1_mciop2a_cb_id0            (w_P1_MCIOP2A_CB_ID0_R      ),
    .i_p1_mciop2a_cb_id1            (w_P1_MCIOP2A_CB_ID1_R      ),
    .i_p1_mciop2c_cb_id0            (w_P1_MCIOP2C_CB_ID0_R      ),
    .i_p1_mciop2c_cb_id1            (w_P1_MCIOP2C_CB_ID1_R      ),

    .i_p1_mciop3a_cb_id0            (w_P1_MCIOP3A_CB_ID0_R      ),
    .i_p1_mciop3a_cb_id1            (w_P1_MCIOP3A_CB_ID1_R      ),
    .i_p1_mciop3c_cb_id0            (w_P1_MCIOP3C_CB_ID0_R      ),
    .i_p1_mciop3c_cb_id1            (w_P1_MCIOP3C_CB_ID1_R      ),

    //////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
    // 主板固定配置输入（芯片级配置，缓存到固定地址 0x00C0-0x00D0）
    .i_PRODUCT_LINE_C2	            (`PRODUCT_LINE_C2           ), // 输入：产品系列 ID（如 R6900 G5，宏定义，固定值）
    .i_PRODUCT_GEN_ID_C3            (`PRODUCT_GEN_ID_C3         ), // 输入：产品世代 ID（如 G5 世代，宏定义，固定值）
    .i_SERVER_ID_C5                 (w_server_id_c5             ), // 输入：服务器 ID（之前定义，区分不同背板配置，如 0x41/0x60） //2025-3-13  del `SERVER_ID_C5 
    .i_BOARD_ID_C6                  (`BOARD_ID_C6               ), // 输入：主板 ID（区分不同主板版本，如 Rev A/B，宏定义）
    
    //////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////pcie dync alloc end 0x1000-0x1005/////////////////////////
	  // 调试缓存输出（缓存的 MCIO 槽状态，对应地址 0x1000-0x1006）
    // test 0x1006
    .o_espi_debug_ram_1000          (w_bios_debug_ram_1000      ), // 输出：地址 0x1000 缓存值（P0 MCIOG3A 槽状态）
    .o_espi_debug_ram_1001          (w_bios_debug_ram_1001      ), // 输出：地址 0x1001 缓存值（P0 MCIOG3C 槽状态）
    .o_espi_debug_ram_1002          (w_bios_debug_ram_1002      ), // 输出：地址 0x1002 缓存值（P0 MCIOP0A 槽状态）
    .o_espi_debug_ram_1003          (w_bios_debug_ram_1003      ), // 输出：地址 0x1003 缓存值（P0 MCIOP0C 槽状态）
    .o_espi_debug_ram_1004          (w_bios_debug_ram_1004      ), // 输出：地址 0x1004 缓存值（P0 MCIOP1A 槽状态）
    .o_espi_debug_ram_1005          (w_bios_debug_ram_1005      ), // 输出：地址 0x1005 缓存值（P0 MCIOP1C 槽状态）
    .o_test_reg                     (w_bios_debug_ram_1006      ), // 输出：地址 0x1006 测试值（BIOS 写测试数据后读回，验证 I2C 通信） 

    // 模式切换配置输入：BIOS 下发的模式控制指令，CPLD 读取后执行对应硬件动作
    .i_switch_mode                  (r_switch_mode              ), // 输入：模式切换控制（地址 0x1010）
    .i_switch2_mode                 (r_switch2_mode             ), // 输入：二级模式切换（地址 0x1011）

    // 扩展配置输入：BIOS 下发的其他硬件配置指令，对应地址 0x1050-0x1058
    .i_espi_ram_1050                (w_espi_ram_1050            ), // 输入：地址 0x1050 配置值（如 MCIO 槽电源使能参数）
    .i_espi_ram_1051                (w_espi_ram_1051            ), // 输入：地址 0x1051 配置值（如风扇转速阈值）
    .i_espi_ram_1052                (w_espi_ram_1052            ), // 输入：地址 0x1052 配置值（如温度告警阈值）
    .i_espi_ram_1053                (w_espi_ram_1053            ), // 输入：地址 0x1053 配置值（2023-11-8 新增，适配新硬件）
    .i_espi_ram_1054                (w_espi_ram_1054            ), // 输入：地址 0x1054 配置值（新增扩展配置）
    .i_espi_ram_1055                (w_espi_ram_1055            ), // 输入：地址 0x1055 配置值（新增扩展配置）
    .i_espi_ram_1056                (w_espi_ram_1056            ), // 输入：地址 0x1056 配置值（新增扩展配置）
    .i_espi_ram_1057                (w_espi_ram_1057            ), // 输入：地址 0x1057 配置值（新增扩展配置）
    .i_espi_ram_1058                (w_espi_ram_1058            ), // 输入：地址 0x1058 配置值（新增扩展配置）

    /////////////////2024-3-3 ADD/////////////////////////////////////    
    // 扩展卡槽位 ID 输入（2024-3-3 新增）：缓存到地址 0x1100-0x1113，BIOS 读取后识别扩展卡安装情况    
    .i_espi_ram_1100                (w_p0_mciop0a_slot_id       ), // CPU0-P0A  J185   SLOT_ID
    .i_espi_ram_1101                (w_p0_mciop0c_slot_id       ), // CPU0-P0C  J48    SLOT_ID
    .i_espi_ram_1102                (w_p0_mciop1a_slot_id       ), // CPU0-P1A  J75    SLOT_ID
    .i_espi_ram_1103                (w_p0_mciop1c_slot_id       ), // CPU0-P1C  J76    SLOT_ID
    .i_espi_ram_1104                (w_p0_mciop2a_slot_id       ), // CPU0-P2A  J40    SLOT_ID
    .i_espi_ram_1105                (w_p0_mciop2c_slot_id       ), // CPU0-P2C  J41    SLOT_ID
    .i_espi_ram_1106                (w_p0_mciop3a_slot_id       ), // CPU0-P3A  J42    SLOT_ID
    .i_espi_ram_1107                (w_p0_mciop3c_slot_id       ), // CPU0-P3C  J43    SLOT_ID
    .i_espi_ram_1108                (w_p0_mciog3a_slot_id       ), // CPU0-G3A  J45    SLOT_ID
    .i_espi_ram_1109                (w_p0_mciog3c_slot_id       ), // CPU0-G3C  J44    SLOT_ID
    
    .i_espi_ram_110a                (w_p1_mciop0a_slot_id       ), // CPU1-P0A  J73    SLOT_ID
    .i_espi_ram_110b                (w_p1_mciop0c_slot_id       ), // CPU1-P0C  J74    SLOT_ID
    .i_espi_ram_110c                (w_p1_mciop1a_slot_id       ), // CPU1-P1A  J204   SLOT_ID
    .i_espi_ram_110d                (w_p1_mciop1c_slot_id       ), // CPU1-P1C  J203   SLOT_ID
    .i_espi_ram_110e                (w_p1_mciop2a_slot_id       ), // CPU1-P2A  J205   SLOT_ID
    .i_espi_ram_110f                (w_p1_mciop2c_slot_id       ), // CPU1-P2C  J206   SLOT_ID
    .i_espi_ram_1110                (w_p1_mciop3a_slot_id       ), // CPU1-P3A  J207   SLOT_ID
    .i_espi_ram_1111                (w_p1_mciop3c_slot_id       ), // CPU1-P3C  J208   SLOT_ID
    .i_espi_ram_1112                (w_p1_mciog1a_slot_id       ), // CPU1-G1A  J210   SLOT_ID        
    .i_espi_ram_1113                (w_p1_mciog1c_slot_id       )  // CPU1-G1C  J209   SLOT_ID
);

//----------------------------------------------------------------------------------//
//delay
//----------------------------------------------------------------------------------//
edge_delay #(.CNTR_NBITS(1), .DELAY_MODE(1'b0)) edge_delay_rst_srst_bmc_b_n_1ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (1'b1),
    .cnt_step    (t1ms_tick),
    .signal_in   (wBMC_PWR_OK),
    .delay_output(w_pal_bmc_srst_n_r) 
  );

edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_0_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (db_i_p0_slp_s5_n),//2024-4-10 chg w_PWRGD_P12V to w_pch_slp5_n
    .delay_output(w_slot_0_on_dly_10ms)
  );

edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_1_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_0_on_dly_10ms),
    .delay_output(w_slot_1_on_dly_10ms)
  );

edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_slot_2_on_dly_10ms (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (6'd10),
    .cnt_step    (t1ms_tick),
    .signal_in   (w_slot_1_on_dly_10ms),
    .delay_output(w_slot_2_on_dly_10ms)
  );

//--------------------------------------------------------------------------------------------------------------------------------------------------
//RTC clear cmos 
//--------------------------------------------------------------------------------------------------------------------------------------------------
//RTC Sensor SW
clear_cmos clear_cmos_int(
 .i_clk					(clk_50m			),
 .i_rst_n				(~w_st_steady_pwrok & pon_reset_n	),
 .i_clr_cmos_flg		        (w_clr_cmos_flg		),//clear sig from bmc iic ram 0x03A0 bit4
 .i_t64ms_tick			(t1s_tick			),
 .o_clr_cmos_done		(w_clr_cmos_done	),//output sig to clear the cmos
 .o_clr_cmos_done_rst	(w_clr_cmos_done_rst	)

);

 clear_nmi nmi_ctl_int(
 .i_clk					(clk_50m			),
 .i_rst_n				(pon_reset_n		),
 .i_clr_nmi_flg			(w_bmc_nmi_ctl		),	//from bmc iic ram 0x03A0 bit6
 .i_t64ms_tick			(t1s_tick			),
 .o_clr_nmi_done		(w_bmc_nmi_ctl_done	),	//output sig for NMI
 .o_clr_nmi_done_rst	(w_bmc_nmi_ctl_rst	)
);
assign  w_p0_nmi_sync_flood_n = ~w_bmc_nmi_ctl_done; 
assign  w_p1_nmi_sync_flood_n = ~w_bmc_nmi_ctl_done; 

// assign o_EPR_WP_N    	= eeprom_wp;			
// assign bmc_alarm_flag	= |bmc_wdt_rst_evt;
assign w_dimm_alarm_flag	= w_p0_dimm_gl_pwrgd_fail_event | w_p0_dimm_af_pwrgd_fail_event;	//p1_dimm_gl_pwrgd_fail_event|p1_dimm_af_pwrgd_fail_event|

// assign btn_press_flag	= ~(/* db_i_pal_button_rst_n & */ db_i_pwr_btn_cpld_n_r & io_uid_btn_n);	//change to io_uid_btn_n

//--------------------------------------------------------------------------------------------------------------------------------------------------
//CPLD hitless  
//--------------------------------------------------------------------------------------------------------------------------------------------------
// wire hitless_reset_n				;
// wire hitless_en						;
//110bit 20241226
// wire [96:0] user_outputs			;	
// wire [96:0] pre_load_feedback		;	
// wire [96:0] normal_reset_value		;	

// always @(posedge clk_50m or negedge pon_reset_n)    
// begin
	// if (~pon_reset_n)
	// begin
		// power_seq_sm_fb[5:0]	<= power_seq_sm_fb[5:0]	;
		// r_uid_led_fb			<= r_uid_led_fb;				// UID LED hitless
	// end
	// else
	// begin
		// power_seq_sm_fb[5:0]	<= pre_load_feedback[5:0]	;
		// r_uid_led_fb			<= {8{pre_load_feedback[106]}}	;		// UID LED hitless
	// end
// end
//assign power_seq_sm_fb[5:0] = pre_load_feedback[5:0];	// refer 2P V16


//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- switch board signal PVT_DATA   74lv165
//-------------------------------------------------------------------------------------------------
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_2s (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (3'd2),
    .cnt_step    (t1s_tick),
    .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    .delay_output(w_pwr_on_dly2s)
  );
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_1s5 (   //DELAY_MODE =0 for rise edge
    .clk         (clk_50m),
    .reset       (~pon_reset_n),
    .cnt_size    (3'd3),
    .cnt_step    (t512ms_tick),
    .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    .delay_output(w_pwr_on_dly1s5)
  );
//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA   74lv165 //2024-1-16 add for switch debug
//-------------------------------------------------------------------------------------------------
// pvt_gpi #(
  // .TOTAL_BIT_COUNT(8),
  // .DEFAULT_STATE(8'h0),
  // .NUMBER_OF_COUNTER_BITS(3)
// ) pvt_gpi_4u_gpu_sw_inst_u2 (
  // .clk           (clk_50m),                        //in
  // .reset_n       (~w_pwr_on_dly2s & pon_reset_n ),                    //in  //2024-9-4 add & ~w_pwr_on_dly2s
  // .clk_ena       (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  // .serclk_in     (o_P0_MCIOP0A_CLK_R   ),         //in   
  // .par_load_in_n (o_P0_MCIOP0A_LD_R  ),          //in   
  // .sdi           (i_P0_MCIOP0A_DATAIN_R ),  //in   
  // .bit_idx_in    (pvti_sw_u2_count1),                  //in
  // .bit_idx_out   (pvti_sw_u2_count1),                  //out
  // .serclk_out       (o_P0_MCIOP0A_CLK_R ),        //out
  // .par_load_out_n(o_P0_MCIOP0A_LD_R  ),          //out

  // .par_data      ({
                    // w_pal_p12v_drop_sw,w_pg_p5v0_r_sw,w_pg_p1v8_r_sw,w_pg_p1v8_pll_r_sw ,
                    // w_db2000_pwrgd0_sw,w_db2000_pwrgd1_sw,w_mcio_slot13_prsnt_n_1_sw,w_u40_nc7_sw
		
			// })
// );

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- ZT board & switch board signal  all in J48 J185
//-------------------------------------------------------------------------------------------------
pvt_gpi #(
  .TOTAL_BIT_COUNT(64),
  .DEFAULT_STATE(64'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_gpi_4u_gpu_zt_inst (
  .clk                      (clk_50m),                        //in
  .reset_n              (~w_pwr_on_dly2s & pon_reset_n ),                    //in //2024-9-4 add & w_pwr_on_dly2s
  .clk_ena              (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  .serclk_in          (o_P0_MCIOP1A_CLK_R    ),        //in   o_CPU0_MCIO3A_CLK_R     J42 A8
  .par_load_in_n  (o_P0_MCIOP1A_LD_R     ),        //in   o_CPU0_MCIO3A_LD_R      J42 A9
  .sdi                      (i_P0_MCIOP1A_DATAIN_R ),        //in   i_CPU0_MCIO3A_DATAIN_R  J42 B10
  .bit_idx_in        (pvti_zt_count),                  //in
  .bit_idx_out      (pvti_zt_count),                  //out
  .serclk_out        (o_P0_MCIOP1A_CLK_R   ),         //out o_CPU0_MCIO3A_CLK_R   J42 A8
  .par_load_out_n(o_P0_MCIOP1A_LD_R     ),         //out o_CPU0_MCIO3A_LD_R    J42 A9
                   //last bit
  .par_data      ({
                                w_tpm431_alert_n_zt,w_ina3221_pwr_alert_zt,w_pal_3v3_pgd1_r_zt,w_pal_3v3_pgd2_r_zt,
                                w_pal_3v3_pgd3_r_zt,w_pal_3v3_pgd4_r_zt,w_pal_3v3_pgd5_r_zt,w_u3_nc7_zt,
                                
                                w_slot1_prsnt_n_zt,w_slot2_prsnt_n_zt,w_slot3_prsnt_n_zt,w_slot4_prsnt_n_zt,
                                w_slot5_prsnt_n_zt,w_slot6_prsnt_n_zt,w_slot7_prsnt_n_zt,w_slot8_prsnt_n_zt,

                                w_slot9_prsnt_n_zt ,w_slot10_prsnt_n_zt,w_slot11_prsnt_n_zt,w_slot12_prsnt_n_zt,
                                w_slot13_prsnt_n_zt,w_mcio1_prsnt_n_zt ,w_mcio2_prsnt_n_zt ,w_mcio3_prsnt_n_zt ,

                                w_mcio4_prsnt_n_zt ,w_mcio5_prsnt_n_zt ,w_mcio6_prsnt_n_zt ,w_mcio7_prsnt_n_zt ,
                                w_mcio8_prsnt_n_zt ,w_mcio9_prsnt_n_zt ,w_mcio10_prsnt_n_zt,w_mcio11_prsnt_n_zt,

                                w_mcio12_prsnt_n_zt,w_mcio13_prsnt_n_zt,w_pcb_version2_zt,  w_pcb_version1_zt,  
                                w_pcb_version0_zt,  w_pca_version2_zt,  w_pca_version1_zt,  w_pca_version0_zt,  

                                w_board_id0_zt,w_board_id1_zt,w_board_id2_zt,w_board_id3_zt,
                                w_board_id4_zt,w_board_id5_zt,w_board_id6_zt,w_board_id7_zt,

                                w_mcio1_prsnt_n_1_zt ,w_mcio2_prsnt_n_1_zt ,w_mcio3_prsnt_n_1_zt ,w_mcio4_prsnt_n_1_zt ,
                                w_mcio5_prsnt_n_1_zt ,w_mcio7_prsnt_n_1_zt ,w_mcio9_prsnt_n_1_zt ,w_mcio10_prsnt_n_1_zt,

                                w_mcio11_prsnt_n_1_zt,w_mcio12_prsnt_n_1_zt,w_u19_nc2_zt,w_u19_nc3_zt,
                                w_u19_nc4_zt,w_u19_nc5_zt,w_u19_nc6_zt,w_u19_nc7_zt
                                })//first bit
);
//-------------------------------------------------------------------------------------------------
// 2024-9-6 add for cable error
//-------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n) begin //2024-9-6 add 
    if(~pon_reset_n) 
    begin
            r_board_id0_zt     <= w_board_id0_zt     ;
            r_board_id1_zt     <= w_board_id1_zt     ;
            r_board_id2_zt     <= w_board_id2_zt     ;
            r_board_id3_zt     <= w_board_id3_zt     ;
            r_board_id4_zt     <= w_board_id4_zt     ;
            r_board_id5_zt     <= w_board_id5_zt     ;
            r_board_id6_zt     <= w_board_id6_zt     ;
            r_board_id7_zt     <= w_board_id7_zt     ;
            r_pcb_version2_zt  <= w_pcb_version2_zt  ;
            r_pcb_version1_zt  <= w_pcb_version1_zt  ;
            r_pcb_version0_zt  <= w_pcb_version0_zt  ;
            r_pca_version2_zt  <= w_pca_version2_zt  ;
            r_pca_version1_zt  <= w_pca_version1_zt  ;
            r_pca_version0_zt  <= w_pca_version0_zt  ;
            r_mcio9_prsnt_n_zt <= w_mcio9_prsnt_n_zt ;
            r_mcio7_prsnt_n_zt <= w_mcio7_prsnt_n_zt ;
            r_mcio3_prsnt_n_zt <= w_mcio3_prsnt_n_zt ;
            r_mcio1_prsnt_n_zt <= w_mcio1_prsnt_n_zt ;
            r_mcio10_prsnt_n_zt<= w_mcio10_prsnt_n_zt;
            r_mcio8_prsnt_n_zt <= w_mcio8_prsnt_n_zt ;
            r_mcio6_prsnt_n_zt <= w_mcio6_prsnt_n_zt ;
            r_mcio4_prsnt_n_zt <= w_mcio4_prsnt_n_zt ;
	end
	else  begin  
	    if(w_pwr_on_dly1s5) 
            begin
                r_board_id0_zt     <= r_board_id0_zt     ;
                r_board_id1_zt     <= r_board_id1_zt     ;
                r_board_id2_zt     <= r_board_id2_zt     ;
                r_board_id3_zt     <= r_board_id3_zt     ;
                r_board_id4_zt     <= r_board_id4_zt     ;
                r_board_id5_zt     <= r_board_id5_zt     ;
                r_board_id6_zt     <= r_board_id6_zt     ;
                r_board_id7_zt     <= r_board_id7_zt     ;
                r_pcb_version2_zt  <= r_pcb_version2_zt  ;
                r_pcb_version1_zt  <= r_pcb_version1_zt  ;
                r_pcb_version0_zt  <= r_pcb_version0_zt  ;
                r_pca_version2_zt  <= r_pca_version2_zt  ;
                r_pca_version1_zt  <= r_pca_version1_zt  ;
                r_pca_version0_zt  <= r_pca_version0_zt  ;
                r_mcio9_prsnt_n_zt <= r_mcio9_prsnt_n_zt ;
                r_mcio7_prsnt_n_zt <= r_mcio7_prsnt_n_zt ;
                r_mcio3_prsnt_n_zt <= r_mcio3_prsnt_n_zt ;
                r_mcio1_prsnt_n_zt <= r_mcio1_prsnt_n_zt ;
                r_mcio10_prsnt_n_zt<= r_mcio10_prsnt_n_zt;
                r_mcio8_prsnt_n_zt <= r_mcio8_prsnt_n_zt ;
                r_mcio6_prsnt_n_zt <= r_mcio6_prsnt_n_zt ;
                r_mcio4_prsnt_n_zt <= r_mcio4_prsnt_n_zt ;
            end
            else begin
                r_board_id0_zt     <= w_board_id0_zt     ;
                r_board_id1_zt     <= w_board_id1_zt     ;
                r_board_id2_zt     <= w_board_id2_zt     ;
                r_board_id3_zt     <= w_board_id3_zt     ;
                r_board_id4_zt     <= w_board_id4_zt     ;
                r_board_id5_zt     <= w_board_id5_zt     ;
                r_board_id6_zt     <= w_board_id6_zt     ;
                r_board_id7_zt     <= w_board_id7_zt     ;
                r_pcb_version2_zt  <= w_pcb_version2_zt  ;
                r_pcb_version1_zt  <= w_pcb_version1_zt  ;
                r_pcb_version0_zt  <= w_pcb_version0_zt  ;
                r_pca_version2_zt  <= w_pca_version2_zt  ;
                r_pca_version1_zt  <= w_pca_version1_zt  ;
                r_pca_version0_zt  <= w_pca_version0_zt  ;
                r_mcio9_prsnt_n_zt <= w_mcio9_prsnt_n_zt ;
                r_mcio7_prsnt_n_zt <= w_mcio7_prsnt_n_zt ;
                r_mcio3_prsnt_n_zt <= w_mcio3_prsnt_n_zt ;
                r_mcio1_prsnt_n_zt <= w_mcio1_prsnt_n_zt ;
                r_mcio10_prsnt_n_zt<= w_mcio10_prsnt_n_zt;
                r_mcio8_prsnt_n_zt <= w_mcio8_prsnt_n_zt ;
                r_mcio6_prsnt_n_zt <= w_mcio6_prsnt_n_zt ;
                r_mcio4_prsnt_n_zt <= w_mcio4_prsnt_n_zt ;
            end
	end
end

//-------------------------------------------------------------------------------------------------
// ZT board or  switch board  judge
//-------------------------------------------------------------------------------------------------
assign  w_zt_board_id ={r_board_id7_zt,r_board_id6_zt,r_board_id5_zt,r_board_id4_zt,
                        r_board_id3_zt,r_board_id2_zt,r_board_id1_zt,r_board_id0_zt}; //2024-9-6

assign  w_sw_board_id ={w_board_id7_sw,w_board_id6_sw,w_board_id5_sw,w_board_id4_sw,
                        w_board_id3_sw,w_board_id2_sw,w_board_id1_sw,w_board_id0_sw};  

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
		r_zt_board_prsnt_n <= 1'b0;
	end
	else if (w_zt_board_id == 8'h2d) begin  
	    r_zt_board_prsnt_n <= 1'b0;                                  
	end
	else 
	    r_zt_board_prsnt_n <= 1'b1;
end

assign w_zt_board_prsnt_n = r_zt_board_prsnt_n;//2024-9-9 add
//2024-4-30 SW CHG VB REMAPPED
assign  w_tpm431_alert_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_tpm431_alert_n_zt    : 1'b1 ;//u3     
assign  w_ina3221_pwr_alert_sw = (r_zt_board_prsnt_n == 1'b1) ? w_ina3221_pwr_alert_zt : 1'b1 ;//u3     
assign  w_pal_3v3_pgd1_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd1_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd2_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd2_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd3_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd3_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd4_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd4_r_zt    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd5_r_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd5_r_zt    : 1'b1 ;//u3     
assign  w_u3_nc7_sw            = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_u3_nc7_zt : 1'b1 ;//u3     

assign  w_mcio_slot11_prsnt_n_1= (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_u3_nc7_zt : 1'b1 ;//2024-9-24

assign  w_slot1_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot1_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot2_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot2_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot3_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot3_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot4_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot4_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot5_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot5_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot6_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot6_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot7_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot7_prsnt_n_zt : 1'b1     ;//u7     
assign  w_slot8_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot8_prsnt_n_zt : 1'b1     ;//u7     

assign  w_slot9_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_slot9_prsnt_n_zt  : 1'b1    ;//u8     
assign  w_slot10_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot10_prsnt_n_zt : 1'b1    ;//u8     
assign  w_slot11_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot11_prsnt_n_zt : 1'b1    ;//u8     
assign  w_slot12_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot12_prsnt_n_zt : 1'b1    ;//u8     
assign  w_slot13_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_slot13_prsnt_n_zt : 1'b1    ;//u8     
assign  w_mcio1_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio1_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio4_prsnt_n_zt : 1'b1    ;//u8    //2024-9-6 
assign  w_mcio2_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_mcio2_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio5_prsnt_n_zt : 1'b1    ;//u8     
assign  w_mcio3_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio3_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio6_prsnt_n_zt : 1'b1    ;//u8    //2024-9-6  

assign  w_mcio_slot9_prsnt_n   = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio1_prsnt_n_zt  : 1'b1    ;//2024-9-24
assign  w_mcio_slot9_prsnt_n_1 = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio2_prsnt_n_zt  : 1'b1    ;//2024-9-24
assign  w_mcio_slot11_prsnt_n  = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio3_prsnt_n_zt  : 1'b1    ;//2024-9-24

assign  w_mcio4_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio4_prsnt_n_zt  : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio7_prsnt_n_zt  : 1'b1    ;//u4     
assign  w_mcio5_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_zt  : 1'b1    ;//u4    
assign  w_mcio6_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? r_mcio6_prsnt_n_zt  : 1'b1    ;//u4     
assign  w_mcio7_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio7_prsnt_n_zt  : //2024-9-24 
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio8_prsnt_n_zt  : 1'b1    ;//u4     //2024-9-6 
assign  w_mcio8_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio8_prsnt_n_zt  : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio9_prsnt_n_zt  : 1'b1    ;//u4     
assign  w_mcio9_prsnt_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio9_prsnt_n_zt  : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? r_mcio10_prsnt_n_zt : 1'b1    ;//u4     //2024-9-6
assign  w_mcio10_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? r_mcio10_prsnt_n_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio11_prsnt_n_zt : 1'b1    ;//u4     
assign  w_mcio11_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_zt : 1'b1    ;//u4     

assign  w_mcio12_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_mcio12_prsnt_n_zt : 1'b1    ;//u5    
assign  w_mcio_slot13_prsnt_n_1= (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_mcio12_prsnt_n_zt : 1'b1    ;//2024-9-24

assign  w_mcio13_prsnt_n_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio13_prsnt_n_zt : 1'b1    ;//u5    
assign  w_pcb_version2_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pcb_version2_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version1_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pcb_version1_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version0_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pcb_version0_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version2_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pca_version2_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version1_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pca_version1_zt   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version0_sw      = (r_zt_board_prsnt_n == 1'b1) ? r_pca_version0_zt   : 1'b1    ;//u5   //2024-9-6 

assign  w_board_id0_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id0_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id1_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id1_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id2_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id2_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id3_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id3_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id4_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id4_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id5_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id5_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id6_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id6_zt : 1'b1         ;//u6    //2024-9-6
assign  w_board_id7_sw         = (r_zt_board_prsnt_n == 1'b1) ? r_board_id7_zt : 1'b1         ;//u6    //2024-9-6

assign  w_ct_p1v25_sw0_pg_sw   = (r_zt_board_prsnt_n == 1'b1) ? w_mcio1_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_ct_p1v25_sw1_pg_sw   = (r_zt_board_prsnt_n == 1'b1) ? w_mcio2_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_p0v8_sw0_pwrgd_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio3_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_p0v8_sw1_pwrgd_sw    = (r_zt_board_prsnt_n == 1'b1) ? w_mcio4_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot1_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot2_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio7_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot3_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio9_prsnt_n_1_zt  : 1'b1  ;//u18    
assign  w_slot4_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio10_prsnt_n_1_zt : 1'b1  ;//u18    

assign  w_slot5_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_1_zt : 1'b1  ;//u19    
assign  w_slot6_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_mcio12_prsnt_n_1_zt : 1'b1  ;//u19    
assign  w_slot7_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc2_zt          : 1'b1  ;//u19    
assign  w_slot8_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc3_zt          : 1'b1  ;//u19    
assign  w_slot9_wake_n_sw      = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc4_zt          : 1'b1  ;//u19    
assign  w_slot10_wake_n_sw     = (r_zt_board_prsnt_n == 1'b1) ? w_u19_nc5_zt          : 1'b1  ;//u19    
assign  w_slot11_wake_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_u19_nc6_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_u19_nc4_zt : 1'b1  ;//u19    
assign  w_slot12_wake_n_sw     = (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0d) ? w_u19_nc7_zt : //2024-9-24
                                 (r_zt_board_prsnt_n == 1'b1) && (w_sw_board_id == 8'h0c) ? w_u19_nc5_zt : 1'b1  ;//u19    

//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------
//bit0 X16 Cpu0_PE0: J48-A10  i_CPU0_MCIO0C_NVME0_PRSNT_N_R == w_mcio1_prsnt_n_sw
//bit1 X16 Cpu0 PE1: J75-A10  i_MCIO1A4_NVME0_PRSNT_N_R == w_mcio3_prsnt_n_sw
//bit2 X16 Cpu1_PE0: J74-A10  w_cpu1_mcio0c4_nvme0_prsnt_n == w_mcio7_prsnt_n_sw
//bit3 X16 Cpu1 PE1: J204-A10 w_pal_mcio18_nvme0_prsnt_n == w_mcio9_prsnt_n_sw

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
	    r_switch_mode <= 8'hff; //espi reg 0x1010  BMC_IIC_REG 0x008d
	end
	else begin
	    if(r_zt_board_prsnt_n == 1'b0) begin //zt board
		    r_switch_mode <= 8'hff;  
		end
		else if(w_sw_board_id == 8'h0c) begin //104 switch
                    case({w_mcio9_prsnt_n_sw,w_mcio7_prsnt_n_sw,w_mcio3_prsnt_n_sw,w_mcio1_prsnt_n_sw}) 
                        4'b0000: r_switch_mode <= 8'h01;   //8GPU HPC模式
                        4'b0110: r_switch_mode <= 8'h02;   //8GPU 并行模式 或耥HPC模式
                        4'b1110: r_switch_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch_mode <= 8'hff;   //未接
                        default: r_switch_mode <= 8'hff;
                    endcase
		end
		else if(w_sw_board_id == 8'h0d) begin //144 switch
                    case({w_mcio9_prsnt_n_sw,w_mcio7_prsnt_n_sw,w_mcio3_prsnt_n_sw,w_mcio1_prsnt_n_sw}) 
                        4'b0000: r_switch_mode <= 8'h01;   //8GPU HPC模式
                        4'b1010: r_switch_mode <= 8'h02;   //8GPU 并行模式
                        4'b1110: r_switch_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch_mode <= 8'hff;   //未接
                        default: r_switch_mode <= 8'hff;
                    endcase
		end
	end
end
//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- switch2 board signal PVT_DATA   74lv165
//-------------------------------------------------------------------------------------------------

// wire w_pwr_on_dly2s;
// wire w_pwr_on_dly1s5;  

// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_2s (   //DELAY_MODE =0 for rise edge
    // .clk         (clk_50m),
    // .reset       (~pon_reset_n),
    // .cnt_size    (3'd2),
    // .cnt_step    (t1s_tick),
    // .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    // .delay_output(w_pwr_on_dly2s)
  // );
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_dc_pwr_on_1s5 (   //DELAY_MODE =0 for rise edge
    // .clk         (clk_50m),
    // .reset       (~pon_reset_n),
    // .cnt_size    (3'd3),
    // .cnt_step    (t512ms_tick),
    // .signal_in   (db_i_p0_slp_s3_n & db_i_pgd_p5v),
    // .delay_output(w_pwr_on_dly1s5)
  // );
//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA   74lv165 //2024-1-16 add for switch debug
//-------------------------------------------------------------------------------------------------
pvt_gpi #(
  .TOTAL_BIT_COUNT(8),
  .DEFAULT_STATE(8'h0),
  .NUMBER_OF_COUNTER_BITS(3)
) pvt_gpi_4u_gpu_sw2_inst_u2 (
  .clk           (clk_50m),                        //in
  .reset_n       (~w_pwr_on_dly2s & pon_reset_n ),                    //in  //2024-9-4 add & ~w_pwr_on_dly2s
  .clk_ena       (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  .serclk_in     (o_P0_MCIOP0C_CLK_R   ),         //in   
  .par_load_in_n (o_P0_MCIOP0C_LD_R  ),          //in   
  .sdi           (i_P0_MCIOP0C_DATAIN_R ),  //in   
  .bit_idx_in    (pvti_sw2_u2_count1),                  //in
  .bit_idx_out   (pvti_sw2_u2_count1),                  //out
  .serclk_out       (o_P0_MCIOP0C_CLK_R ),        //out
  .par_load_out_n(o_P0_MCIOP0C_LD_R  ),          //out

  .par_data      ({
                    w_pal_p12v_drop_sw2,w_pg_p5v0_r_sw2,w_pg_p1v8_r_sw2,w_pg_p1v8_pll_r_sw2 ,
                    w_db2000_pwrgd0_sw2,w_db2000_pwrgd1_sw2,w_mcio_slot13_prsnt_n_1_sw2,w_u40_nc7_sw2
		
			})
);
//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- PVT_DATA    //2024-1-16 add for switch2 debug
//-------------------------------------------------------------------------------------------------
wire [7:0]  w_164_test_data ;
wire w_164_mr_n;

s2p_164  s2p_164_u1(   //#(parameter NBIT = 8)
  .i_clk     (clk_50m)  ,
  .i_rst     (~pon_reset_n)  ,
  .tick      (t1us_tick)  ,
  .CLK_1ms  (w1mSCE) ,
  
  .i_mr_n    (w_164_mr_n)  ,
  .pi        (w_164_test_data)  ,   //2024-2-18 chg w_164_test_data to 8'h55
  .so        (o_P0_MCIOP0C_WAKE_N_R)  ,    //2024-2-22 chg J48  B29  o_CPU0_MCIO0_WAKE_N_R  TO J185 B29  o_CPU0_MCIO0A_WAKE_N_R
  .sld_n     (o_P0_MCIOP0A_WAKE_N_R)  ,    //2024-2-22 chg J185 B29  o_CPU0_MCIO0A_WAKE_N_R TO J48  B29  o_CPU0_MCIO0_WAKE_N_R
  .o_sclk    (o_P0_MCIOP0C_RSV_R)        //2024-2-22 chg J48  B30  o_CPU0_MCIO0C_RSV_R    TO J185 B30  o_CPU0_MCIO0A_RSV_R
) ;
// assign o_CPU0_MCIO0C_RSV_R = 1'b1 ; //2024-2-22 CHG TO USE AS EN , ALWAYS SET HIGH

//-------------------------------------------------------------------------------------------------
// CPU0 PE0 --- ZT2 board & switch2 board signal  all in J48 J185
//-------------------------------------------------------------------------------------------------
pvt_gpi #(
  .TOTAL_BIT_COUNT(64),
  .DEFAULT_STATE(64'h0),
  .NUMBER_OF_COUNTER_BITS(6)
) pvt_gpi_4u_gpu_zt2_inst (
  .clk                      (clk_50m),                        //in
  .reset_n              (~w_pwr_on_dly2s & pon_reset_n ),                    //in //2024-9-4 add & w_pwr_on_dly2s
  .clk_ena              (t1ms_tick),                     //in  //2024-9-3 t16us_tick
  .serclk_in          (o_P0_MCIOP0A_CLK_R    ),        //in   o_CPU0_MCIO3A_CLK_R     J42 A8
  .par_load_in_n  (o_P0_MCIOP0A_LD_R     ),        //in   o_CPU0_MCIO3A_LD_R      J42 A9
  .sdi                      (i_P0_MCIOP0A_DATAIN_R ),        //in   i_CPU0_MCIO3A_DATAIN_R  J42 B10
  .bit_idx_in        (pvti_zt2_count),                  //in
  .bit_idx_out      (pvti_zt2_count),                  //out
  .serclk_out        (o_P0_MCIOP0A_CLK_R   ),         //out o_CPU0_MCIO3A_CLK_R   J42 A8
  .par_load_out_n(o_P0_MCIOP0A_LD_R     ),         //out o_CPU0_MCIO3A_LD_R    J42 A9
                   //last bit
  .par_data      ({
                                w_tpm431_alert_n_zt2,w_ina3221_pwr_alert_zt2,w_pal_3v3_pgd1_r_zt2,w_pal_3v3_pgd2_r_zt2,
                                w_pal_3v3_pgd3_r_zt2,w_pal_3v3_pgd4_r_zt2,w_pal_3v3_pgd5_r_zt2,w_u3_nc7_zt2,
                                
                                w_slot1_prsnt_n_zt2,w_slot2_prsnt_n_zt2,w_slot3_prsnt_n_zt2,w_slot4_prsnt_n_zt2,
                                w_slot5_prsnt_n_zt2,w_slot6_prsnt_n_zt2,w_slot7_prsnt_n_zt2,w_slot8_prsnt_n_zt2,

                                w_slot9_prsnt_n_zt2 ,w_slot10_prsnt_n_zt2,w_slot11_prsnt_n_zt2,w_slot12_prsnt_n_zt2,
                                w_slot13_prsnt_n_zt2,w_mcio1_prsnt_n_zt2 ,w_mcio2_prsnt_n_zt2 ,w_mcio3_prsnt_n_zt2 ,

                                w_mcio4_prsnt_n_zt2 ,w_mcio5_prsnt_n_zt2 ,w_mcio6_prsnt_n_zt2 ,w_mcio7_prsnt_n_zt2 ,
                                w_mcio8_prsnt_n_zt2 ,w_mcio9_prsnt_n_zt2 ,w_mcio10_prsnt_n_zt2,w_mcio11_prsnt_n_zt2,

                                w_mcio12_prsnt_n_zt2,w_mcio13_prsnt_n_zt2,w_pcb_version2_zt2,  w_pcb_version1_zt2,  
                                w_pcb_version0_zt2,  w_pca_version2_zt2,  w_pca_version1_zt2,  w_pca_version0_zt2,  

                                w_board_id0_zt2,w_board_id1_zt2,w_board_id2_zt2,w_board_id3_zt2,
                                w_board_id4_zt2,w_board_id5_zt2,w_board_id6_zt2,w_board_id7_zt2,

                                w_mcio1_prsnt_n_1_zt2 ,w_mcio2_prsnt_n_1_zt2 ,w_mcio3_prsnt_n_1_zt2 ,w_mcio4_prsnt_n_1_zt2 ,
                                w_mcio5_prsnt_n_1_zt2 ,w_mcio7_prsnt_n_1_zt2 ,w_mcio9_prsnt_n_1_zt2 ,w_mcio10_prsnt_n_1_zt2,

                                w_mcio11_prsnt_n_1_zt2,w_mcio12_prsnt_n_1_zt2,w_u19_nc2_zt2,w_u19_nc3_zt2,
                                w_u19_nc4_zt2,w_u19_nc5_zt2,w_u19_nc6_zt2,w_u19_nc7_zt2
                                })//first bit
);

//-------------------------------------------------------------------------------------------------
// 2024-9-6 add for cable error
//-------------------------------------------------------------------------------------------------
always@(posedge clk_50m or negedge pon_reset_n) begin //2024-9-6 add 
    if(~pon_reset_n) 
    begin
            r_board_id0_zt2     <= w_board_id0_zt2     ;
            r_board_id1_zt2     <= w_board_id1_zt2     ;
            r_board_id2_zt2     <= w_board_id2_zt2     ;
            r_board_id3_zt2     <= w_board_id3_zt2     ;
            r_board_id4_zt2     <= w_board_id4_zt2     ;
            r_board_id5_zt2     <= w_board_id5_zt2     ;
            r_board_id6_zt2     <= w_board_id6_zt2     ;
            r_board_id7_zt2     <= w_board_id7_zt2     ;
            r_pcb_version2_zt2  <= w_pcb_version2_zt2  ;
            r_pcb_version1_zt2  <= w_pcb_version1_zt2  ;
            r_pcb_version0_zt2  <= w_pcb_version0_zt2  ;
            r_pca_version2_zt2  <= w_pca_version2_zt2  ;
            r_pca_version1_zt2  <= w_pca_version1_zt2  ;
            r_pca_version0_zt2  <= w_pca_version0_zt2  ;
            r_mcio9_prsnt_n_zt2 <= w_mcio9_prsnt_n_zt2 ;
            r_mcio7_prsnt_n_zt2 <= w_mcio7_prsnt_n_zt2 ;
            r_mcio3_prsnt_n_zt2 <= w_mcio3_prsnt_n_zt2 ;
            r_mcio1_prsnt_n_zt2 <= w_mcio1_prsnt_n_zt2 ;
            r_mcio10_prsnt_n_zt2<= w_mcio10_prsnt_n_zt2;
            r_mcio8_prsnt_n_zt2 <= w_mcio8_prsnt_n_zt2 ;
            r_mcio6_prsnt_n_zt2 <= w_mcio6_prsnt_n_zt2 ;
            r_mcio4_prsnt_n_zt2 <= w_mcio4_prsnt_n_zt2 ;
	end
	else  begin  
	    if(w_pwr_on_dly1s5) 
            begin
                r_board_id0_zt2     <= r_board_id0_zt2     ;
                r_board_id1_zt2     <= r_board_id1_zt2     ;
                r_board_id2_zt2     <= r_board_id2_zt2     ;
                r_board_id3_zt2     <= r_board_id3_zt2     ;
                r_board_id4_zt2     <= r_board_id4_zt2     ;
                r_board_id5_zt2     <= r_board_id5_zt2     ;
                r_board_id6_zt2     <= r_board_id6_zt2     ;
                r_board_id7_zt2     <= r_board_id7_zt2     ;
                r_pcb_version2_zt2  <= r_pcb_version2_zt2  ;
                r_pcb_version1_zt2  <= r_pcb_version1_zt2  ;
                r_pcb_version0_zt2  <= r_pcb_version0_zt2  ;
                r_pca_version2_zt2  <= r_pca_version2_zt2  ;
                r_pca_version1_zt2  <= r_pca_version1_zt2  ;
                r_pca_version0_zt2  <= r_pca_version0_zt2  ;
                r_mcio9_prsnt_n_zt2 <= r_mcio9_prsnt_n_zt2 ;
                r_mcio7_prsnt_n_zt2 <= r_mcio7_prsnt_n_zt2 ;
                r_mcio3_prsnt_n_zt2 <= r_mcio3_prsnt_n_zt2 ;
                r_mcio1_prsnt_n_zt2 <= r_mcio1_prsnt_n_zt2 ;
                r_mcio10_prsnt_n_zt2<= r_mcio10_prsnt_n_zt2;
                r_mcio8_prsnt_n_zt2 <= r_mcio8_prsnt_n_zt2 ;
                r_mcio6_prsnt_n_zt2 <= r_mcio6_prsnt_n_zt2 ;
                r_mcio4_prsnt_n_zt2 <= r_mcio4_prsnt_n_zt2 ;
            end
            else begin
                r_board_id0_zt2     <= w_board_id0_zt2     ;
                r_board_id1_zt2     <= w_board_id1_zt2     ;
                r_board_id2_zt2     <= w_board_id2_zt2     ;
                r_board_id3_zt2     <= w_board_id3_zt2     ;
                r_board_id4_zt2     <= w_board_id4_zt2     ;
                r_board_id5_zt2     <= w_board_id5_zt2     ;
                r_board_id6_zt2     <= w_board_id6_zt2     ;
                r_board_id7_zt2     <= w_board_id7_zt2     ;
                r_pcb_version2_zt2  <= w_pcb_version2_zt2  ;
                r_pcb_version1_zt2  <= w_pcb_version1_zt2  ;
                r_pcb_version0_zt2  <= w_pcb_version0_zt2  ;
                r_pca_version2_zt2  <= w_pca_version2_zt2  ;
                r_pca_version1_zt2  <= w_pca_version1_zt2  ;
                r_pca_version0_zt2  <= w_pca_version0_zt2  ;
                r_mcio9_prsnt_n_zt2 <= w_mcio9_prsnt_n_zt2 ;
                r_mcio7_prsnt_n_zt2 <= w_mcio7_prsnt_n_zt2 ;
                r_mcio3_prsnt_n_zt2 <= w_mcio3_prsnt_n_zt2 ;
                r_mcio1_prsnt_n_zt2 <= w_mcio1_prsnt_n_zt2 ;
                r_mcio10_prsnt_n_zt2<= w_mcio10_prsnt_n_zt2;
                r_mcio8_prsnt_n_zt2 <= w_mcio8_prsnt_n_zt2 ;
                r_mcio6_prsnt_n_zt2 <= w_mcio6_prsnt_n_zt2 ;
                r_mcio4_prsnt_n_zt2 <= w_mcio4_prsnt_n_zt2 ;
            end
	end
end

//-------------------------------------------------------------------------------------------------
// ZT board or  switch board  judge
//-------------------------------------------------------------------------------------------------

assign  w_zt2_board_id ={r_board_id7_zt2,r_board_id6_zt2,r_board_id5_zt2,r_board_id4_zt2,
                        r_board_id3_zt2,r_board_id2_zt2,r_board_id1_zt2,r_board_id0_zt2}; //2024-9-6

assign  w_sw2_board_id ={w_board_id7_sw2,w_board_id6_sw2,w_board_id5_sw2,w_board_id4_sw2,
                        w_board_id3_sw2,w_board_id2_sw2,w_board_id1_sw2,w_board_id0_sw2};  

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
		r_zt2_board_prsnt_n <= 1'b0;
	end
	else if (w_zt2_board_id == 8'h2d) begin  
	    r_zt2_board_prsnt_n <= 1'b0;                                  
	end
	else 
	    r_zt2_board_prsnt_n <= 1'b1;
end

assign w_zt2_board_prsnt_n = r_zt2_board_prsnt_n;//2024-9-9 add
//2024-4-30 SW CHG VB REMAPPED
assign  w_tpm431_alert_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_tpm431_alert_n_zt2    : 1'b1 ;//u3     
assign  w_ina3221_pwr_alert_sw2 = (r_zt2_board_prsnt_n == 1'b1) ? w_ina3221_pwr_alert_zt2 : 1'b1 ;//u3     
assign  w_pal_3v3_pgd1_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd1_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd2_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd2_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd3_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd3_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd4_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd4_r_zt2    : 1'b1 ;//u3     
assign  w_pal_3v3_pgd5_r_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_pal_3v3_pgd5_r_zt2    : 1'b1 ;//u3     
assign  w_u3_nc7_sw2            = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_u3_nc7_zt2 : 1'b1 ;//u3     

assign  w_zt2_mcio_slot11_prsnt_n_1= (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_u3_nc7_zt2 : 1'b1 ;//2024-9-24

assign  w_slot1_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot1_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot2_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot2_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot3_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot3_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot4_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot4_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot5_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot5_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot6_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot6_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot7_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot7_prsnt_n_zt2 : 1'b1     ;//u7     
assign  w_slot8_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_slot8_prsnt_n_zt2 : 1'b1     ;//u7     

assign  w_slot9_prsnt_n_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? w_slot9_prsnt_n_zt2  : 1'b1    ;//u8     
assign  w_slot10_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot10_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_slot11_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot11_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_slot12_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot12_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_slot13_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_slot13_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_mcio1_prsnt_n_sw2      = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio1_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio4_prsnt_n_zt2 : 1'b1    ;//u8    //2024-9-6 
assign  w_mcio2_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_mcio2_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio5_prsnt_n_zt2 : 1'b1    ;//u8     
assign  w_mcio3_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio3_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio6_prsnt_n_zt2 : 1'b1    ;//u8    //2024-9-6  

assign  w_zt2_mcio_slot9_prsnt_n     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio1_prsnt_n_zt2  : 1'b1    ;//2024-9-24
assign  w_zt2_mcio_slot9_prsnt_n_1 = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio2_prsnt_n_zt2  : 1'b1    ;//2024-9-24
assign  w_zt2_mcio_slot11_prsnt_n   = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio3_prsnt_n_zt2  : 1'b1    ;//2024-9-24

assign  w_mcio4_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio4_prsnt_n_zt2  : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio7_prsnt_n_zt2  : 1'b1    ;//u4     
assign  w_mcio5_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_zt2  : 1'b1    ;//u4    
assign  w_mcio6_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? r_mcio6_prsnt_n_zt2  : 1'b1    ;//u4     
assign  w_mcio7_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio7_prsnt_n_zt2  : //2024-9-24 
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio8_prsnt_n_zt2  : 1'b1    ;//u4     //2024-9-6 
assign  w_mcio8_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio8_prsnt_n_zt2  : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio9_prsnt_n_zt2  : 1'b1    ;//u4     
assign  w_mcio9_prsnt_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio9_prsnt_n_zt2  : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? r_mcio10_prsnt_n_zt2 : 1'b1    ;//u4     //2024-9-6
assign  w_mcio10_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? r_mcio10_prsnt_n_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio11_prsnt_n_zt2 : 1'b1    ;//u4     
assign  w_mcio11_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_zt2 : 1'b1    ;//u4     

assign  w_mcio12_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_mcio12_prsnt_n_zt2 : 1'b1    ;//u5    
assign  w_zt2_mcio_slot13_prsnt_n_1= (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_mcio12_prsnt_n_zt2 : 1'b1    ;//2024-9-24

assign  w_mcio13_prsnt_n_sw2    = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio13_prsnt_n_zt2 : 1'b1    ;//u5    
assign  w_pcb_version2_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pcb_version2_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version1_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pcb_version1_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pcb_version0_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pcb_version0_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version2_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pca_version2_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version1_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pca_version1_zt2   : 1'b1    ;//u5   //2024-9-6 
assign  w_pca_version0_sw2      = (r_zt2_board_prsnt_n == 1'b1) ? r_pca_version0_zt2   : 1'b1    ;//u5   //2024-9-6 

assign  w_board_id0_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id0_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id1_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id1_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id2_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id2_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id3_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id3_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id4_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id4_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id5_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id5_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id6_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id6_zt2 : 1'b1         ;//u6    //2024-9-6
assign  w_board_id7_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? r_board_id7_zt2 : 1'b1         ;//u6    //2024-9-6

assign  w_ct_p1v25_sw0_pg_sw2   = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio1_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_ct_p1v25_sw1_pg_sw2   = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio2_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_p0v8_sw0_pwrgd_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio3_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_p0v8_sw1_pwrgd_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio4_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot1_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio5_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot2_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio7_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot3_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio9_prsnt_n_1_zt2  : 1'b1  ;//u18    
assign  w_slot4_wake_n_sw2         = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio10_prsnt_n_1_zt2 : 1'b1  ;//u18    

assign  w_slot5_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio11_prsnt_n_1_zt2 : 1'b1  ;//u19    
assign  w_slot6_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_mcio12_prsnt_n_1_zt2 : 1'b1  ;//u19    
assign  w_slot7_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc2_zt2          : 1'b1  ;//u19    
assign  w_slot8_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc3_zt2          : 1'b1  ;//u19    
assign  w_slot9_wake_n_sw2       = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc4_zt2          : 1'b1  ;//u19    
assign  w_slot10_wake_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) ? w_u19_nc5_zt2          : 1'b1  ;//u19    
assign  w_slot11_wake_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_u19_nc6_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_u19_nc4_zt2 : 1'b1  ;//u19    
assign  w_slot12_wake_n_sw2     = (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0d) ? w_u19_nc7_zt2 : //2024-9-24
                                 (r_zt2_board_prsnt_n == 1'b1) && (w_sw2_board_id == 8'h0c) ? w_u19_nc5_zt2 : 1'b1  ;//u19    

//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------
//bit0 X16 Cpu0_PE0: J48-A10  i_CPU0_MCIO0C_NVME0_PRSNT_N_R == w_mcio1_prsnt_n_sw
//bit1 X16 Cpu0 PE1: J75-A10  i_MCIO1A4_NVME0_PRSNT_N_R == w_mcio3_prsnt_n_sw
//bit2 X16 Cpu1_PE0: J74-A10  w_cpu1_mcio0c4_nvme0_prsnt_n == w_mcio7_prsnt_n_sw
//bit3 X16 Cpu1 PE1: J204-A10 w_pal_mcio18_nvme0_prsnt_n == w_mcio9_prsnt_n_sw

always@(posedge clk_50m or negedge pon_reset_n) begin
    if(~pon_reset_n) begin
	    r_switch2_mode <= 8'hff; //espi reg 0x1010  BMC_IIC_REG 0x008d
	end
	else begin
	    if(r_zt2_board_prsnt_n == 1'b0) begin //zt board
		    r_switch2_mode <= 8'hff;  
		end
		else if(w_sw2_board_id == 8'h0c) begin //104 switch
                    case({w_mcio9_prsnt_n_sw2,w_mcio7_prsnt_n_sw2,w_mcio3_prsnt_n_sw2,w_mcio1_prsnt_n_sw2}) 
                        4'b0000: r_switch2_mode <= 8'h01;   //8GPU HPC模式
                        4'b0110: r_switch2_mode <= 8'h02;   //8GPU 并行模式 或耥HPC模式
                        4'b1110: r_switch2_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch2_mode <= 8'hff;   //未接
                        default: r_switch2_mode <= 8'hff;
                    endcase
		end
		else if(w_sw2_board_id == 8'h0d) begin //144 switch
                    case({w_mcio9_prsnt_n_sw2,w_mcio7_prsnt_n_sw2,w_mcio3_prsnt_n_sw2,w_mcio1_prsnt_n_sw2}) 
                        4'b0000: r_switch2_mode <= 8'h01;   //8GPU HPC模式
                        4'b1010: r_switch2_mode <= 8'h02;   //8GPU 并行模式
                        4'b1110: r_switch2_mode <= 8'h03;   //8GPU 串行模式
                        4'b1111: r_switch2_mode <= 8'hff;   //未接
                        default: r_switch2_mode <= 8'hff;
                    endcase
		end
	end
end
//-------------------------------------------------------------------------------------------------
//switch_mode //2024-9-6 
// ------------------------------------------------------------------------------------------------
wire    w_sw_board_prsnt_n;
wire    w_sw2_board_prsnt_n;
wire    w_fan_pwr_en;

assign  w_sw_board_prsnt_n  =   (w_sw_board_id==8'h0d)?1'b0:1'b1;
assign  w_sw2_board_prsnt_n  =   (w_sw2_board_id==8'h0d)?1'b0:1'b1;

assign  w_espi_ram_1055[0]  =   w_zt_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[1]  =   w_zt2_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[2]  =   w_sw_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[3]  =   w_sw2_board_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[4]  =   w_ocp1_x8_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[5]  =   w_ocp1_x16_prsnt_n?1'b1:1'b0;
assign  w_espi_ram_1055[7:6]  = 2'b11;
assign  w_espi_ram_1056 =   8'hff;
assign  w_espi_ram_1057 =   8'hff;
assign  w_espi_ram_1058 =   8'hff;

//------------------------------------------------------------------------------------------------//
assign  w_FM_P12V_EN =  db_i_pwrgd_p3v3_stby ? 1'b1 : 1'b0 ;//P12_MAIN pwr up when cpld work  
assign  w_PWRGD_P12V =   (~i_PS1_DCOK_N & i_PS1_PRSNT) || (~i_PS2_DCOK_N & i_PS2_PRSNT) || w_PWRGD_P12V_PS3_PS4 ;
assign  w_ps2_p12v_on_r  = w_FM_P12V_EN & db_i_ps2_prsnt ;
assign  w_ps1_p12v_on_r  = w_FM_P12V_EN & db_i_ps1_prsnt ;

assign  w_pal_ps_off_r = (db_i_ps1_acfail_n&&db_i_ps2_acfail_n&&w_PS3_PS4_ACFAIL)?1'b0:1'b1 ;  
assign  w_pal_dual_en_r = w_PWRGD_P12V  ? 1'b1 : 1'b0 ;
assign  w_clk_gen_en_r_n    =   1'b0;
assign  w_pal_db2000_1_pwrgd_r    = db_i_pgd_p5v ? 1'b1 : 1'b0 ;
assign  w_pal_db2000_2_pwrgd_r    = db_i_pgd_p5v ? 1'b1 : 1'b0 ;
assign  w_clk_db2000_1_1_oe_n    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_clk_db2000_1_2_oe_n    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_fm_pld_db800_3_clks_dev_en_r  =   fm_pld_db800_3_clks_en&&db_i_pgd_p5v;
assign  w_clk_db800_3_1_oe_n_r    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_clk_db800_3_2_oe_n_r    = db_i_pgd_p5v ? 1'b0 : 1'b1 ;
assign  w_cpld_sgpio1_clk_r  =1'bz;
assign  w_cpld_sgpio1_ld_n_r=1'bz;
assign  w_cpld_sgpio1_mosi_r=1'bz;
assign  w_p12v_slot_0_on_r  =   w_p12v_slot_0_on & (w_slot_0_on_dly_10ms ||(~w_SW_2 && db_i_p0_slp_s5_n));
assign  w_p12v_slot_1_on_r  =   w_p12v_slot_1_on & (w_slot_1_on_dly_10ms ||(~w_SW_2 && db_i_p0_slp_s5_n));
assign  w_p12v_slot_2_on_r  =   w_p12v_slot_2_on & (w_slot_2_on_dly_10ms ||(~w_SW_2 && db_i_p0_slp_s5_n));
assign  w_p0_pcie_wake_n    =     w_p0_pcie_wake_n_r;
assign  w_p1_pcie_wake_n    =   w_p1_pcie_wake_n_r;

assign  w_pal_p0_vdd_core_0_soc_rst_l_n	    = (~db_cpu_prsnt_n[0]) & db_i_p0_pwrok ;
assign  w_pal_p1_vdd_core_0_soc_rst_l_n        = (~db_cpu_prsnt_n[1]) & db_i_p1_pwrok ;
assign  w_pal_p0_vdd_core_1_11_sus_rst_l_n  = (~db_cpu_prsnt_n[0]) & db_i_p0_pwrok ;
assign  w_p1_vdd_core_1_11_sus_rst_l_n          = (~db_cpu_prsnt_n[1]) & db_i_p1_pwrok ;
assign  w_pal_p0_vddio_rst_n				    = (~db_cpu_prsnt_n[0]) & db_i_p0_pwrok ;
assign  w_p1_vddio_rst_l_n                                  = (~db_cpu_prsnt_n[1]) & db_i_p1_pwrok ;

assign  w_p5v_vga2_en_n_r   =   db_i_pgd_p5v ? 1'b0 : 1'b1;
assign  w_pal_p5v_en_r  =   w_p5v_en&&w_PWRGD_P12V;
assign  w_pal_bmc_aux_pgd   =   w_clr_cmos_done ? 1'b0 : db_i_pwrgd_p3v3_stby;
assign  w_p1v0_stby_m2_en   =   w_PWRGD_P12V&&db_i_p0_slp_s5_n;

// assign  w_pal_i3c_mux_en_r_n	=  ~w_i3c_mux_en		;
assign  w_bmc_jtag_trst_r_n  = w_jtag_cpld_bmc_ntrst_reg;	
	
assign  w_p0_sys_reset_r_n   = w_pal_sys_reset_od_n_r;		
assign  w_cpu1_pwr_good  =   db_i_p0_pwrgd_out ? 1'b1 : 1'b0;
assign  w_fan_pwr_en = (~w_ocp_prsnt_n || db_i_p0_slp_s5_n) && ~w_FAN_PRSNT_R ? 1'b1 : 1'b0 ;//2024-4-10 add

assign  w_led_control[1] =  w_power_seq_sm[0];
assign  w_led_control[2] =  w_power_seq_sm[1];
assign  w_led_control[3] =  w_power_seq_sm[2];
assign  w_led_control[7] =  w_power_seq_sm[3];
assign  w_led_control[6] =  w_power_seq_sm[4];
assign  w_led_control[5] =  w_power_seq_sm[5];
assign  w_led_control[4] =  wBMC_PWR_OK ? 1'b1 :1'b0;//wBMC_PWR_OK
assign  w_led_control[0] =  db_i_pwrgd_p3v3_stby ? t2p5hz_clk : 1'b0 ;
 

//-----------------------------------------------------------------------------------------------//
//Output SIGNAL
//-----------------------------------------------------------------------------------------------//
assign  o_PS1_P12V_ON_R                                         =   w_ps1_p12v_on_r;//1
assign  o_PS2_P12V_ON_R                                         =   w_ps2_p12v_on_r;//2
assign  o_PAL_PS_OFF_R                                           =   w_pal_ps_off_r;//3
assign  o_PAL_DUAL_EN_R                                         =   w_pal_dual_en_r;//4
assign  o_CLK_GEN_EN_R_N                                       =   w_clk_gen_en_r_n;//5
assign  o_PAL_DB2000_1_PWRGD_R                           =   w_pal_db2000_1_pwrgd_r;//6
assign  o_PAL_DB2000_2_PWRGD_R                           =   w_pal_db2000_2_pwrgd_r;//7
assign  o_CLK_DB2000_1_1_OE_N                             =   w_clk_db2000_1_1_oe_n;//8
assign  o_CLK_DB2000_1_2_OE_N                             =   w_clk_db2000_1_2_oe_n;//9
assign  o_FM_PLD_DB800_3_CLKS_DEV_EN_R           =   w_fm_pld_db800_3_clks_dev_en_r;//10
assign  o_CLK_DB800_3_1_OE_N_R                           =   w_clk_db800_3_1_oe_n_r;//11
assign  o_CLK_DB800_3_2_OE_N_R                           =   w_clk_db800_3_2_oe_n_r;//12 
assign  o_CPLD_SGPIO0_CLK_R                                 =   w_cpld_sgpio0_clk_r  ;//13
assign  o_CPLD_SGPIO0_LD_N_R                               =   w_cpld_sgpio0_ld_n_r;//14
assign  o_CPLD_SGPIO0_MOSI_R                               =   w_cpld_sgpio0_mosi_r;//15
assign  o_CPLD_SGPIO1_CLK_R                                 =   w_cpld_sgpio1_clk_r  ;//16    //rsvd
assign  o_CPLD_SGPIO1_LD_N_R                               =   w_cpld_sgpio1_ld_n_r;//17    //rsvd  
assign  o_CPLD_SGPIO1_MOSI_R                               =   w_cpld_sgpio1_mosi_r;//18    //rsvd
assign  o_SS_PAL_CLK_R                                           =   w_ss_pal_clk_r;//19
assign  o_SS_PAL_LOAD_N_R                                     =   w_ss_pal_load_n_r;//20
assign  o_SS_PAL_DATA_OUT_R                                 =   w_ss_pal_data_out_r;//21
assign  o_PAL_BMC_PERST_N_R                                 =   db_i_p0_pcie_rst_n_0;//22
assign  o_PAL_BMC_INT_N_R                                     =   1'bz;//23
assign  o_PAL_BMC_SRST_N_R                                   =   w_pal_bmc_srst_n_r;//24
assign  o_CPLD_ESPI_D2                                           =   1'bz;//25
assign  o_CPLD_ESPI_D3                                           =   1'bz;//26
assign  o_CPLD_ESPI_ALERT_N                                 =   1'bz;//27
assign  o_P12V_SLOT_0_ON                                       =   w_p12v_slot_0_on_r;//28
assign  o_P12V_SLOT_1_ON                                       =   w_p12v_slot_1_on_r;//29
assign  o_P12V_SLOT_2_ON                                       =   w_p12v_slot_2_on_r;//30
assign  o_FAN_BOARD_RST                                         =   1'b1;//31
assign  o_FAN_PWR_EN                                               =   w_fan_pwr_en;//32
assign  o_FAN_SPGIO_CLK                                         =   1'bz;//33
assign  o_FAN_SPGIO_LD                                           =   1'bz;//34
assign  o_FAN_SPGIO_DATAOUT                                 =   1'bz;//35
assign  o_P0_MCIOP0A_PERST_N_R                           =   db_i_p0_pcie_rst_n_1;//36
assign  o_P0_MCIOP0C_PERST_N_R                           =   db_i_p0_pcie_rst_n_1;//41
assign  o_P0_MCIOP0A_GPU_THROTTLE_N_R             =   w_p0_mciop0a_gpu_throttle_n_r;//37
assign  o_P0_MCIOP0C_GPU_THROTTLE_N_R             =   w_p0_mciop0c_gpu_throttle_n_r;//42
// assign  o_P0_MCIOP0A_CLK_R                                   =   1'bz;//38
// assign  o_P0_MCIOP0A_LD_R                                     =   1'bz;//39
assign  o_P0_MCIOP0A_RSV_R                                   =   1'b1;//40
// assign  o_P0_MCIOP0C_CLK_R                                   =   1'bz;//43
// assign  o_P0_MCIOP0C_LD_R                                     =   1'bz;//44
assign  o_P0_MCIOP0C_RSV_R                                   =   1'bz;//45
// assign  o_P0_MCIOP1A_CLK_R                                   =   1'bz;//46
// assign  o_P0_MCIOP1A_LD_R                                     =   1'bz;//47
assign  o_P0_MCIOP3A_CLK_R                                   =   1'bz;//48
assign  o_P0_MCIOP3A_LD_R                                     =   1'bz;//49
assign  o_SATA1_SCLOCK0_R                                     =   1'bz;//50
assign  o_SATA1_SLOAD0_R                                       =   1'bz;//51
assign  o_PD_SATA1_CONTROLLER0_R                       =   1'bz;//52
assign  o_P0_PWR_BTN_R_N                                       =   w_pal_pwrbtn_n_r;
assign  o_P1_PWR_BTN_R_N                                       =   1'bz;
assign  o_P0_SYS_RESET_R_N                                   =   w_p0_sys_reset_r_n;
assign  o_P1_SYS_RESET_R_N                                   =   w_p0_sys_reset_r_n;
assign  o_P0_PCIE_WAKE_N_R                                   =   w_p0_pcie_wake_n;//34
assign  o_P1_PCIE_WAKE_N_R                                   =   w_p1_pcie_wake_n;//34
assign  o_P0_RSMRST_N                                             =   w_rsmrst_n;
assign  o_P1_RSMRST_N                                             =   w_rsmrst_n;
assign  o_P0_PWR_GOOD                                             =   w_cpu_pwr_good;
assign  o_P1_PWR_GOOD                                             =   w_cpu1_pwr_good;
assign  o_P0_PROCHOT_N                                           =   w_p0_prochot_n;
assign  o_P1_PROCHOT_N                                           =   w_p1_prochot_n;
assign  o_P0_KBRST_N                                               =   w_p0_kbrst_n;
assign  o_P1_KBRST_N                                               =   w_p1_kbrst_n;
assign  o_P0_NMI_SYNC_FLOOD_N                             =   w_p0_nmi_sync_flood_n;
assign  o_P1_NMI_SYNC_FLOOD_N                             =   w_p1_nmi_sync_flood_n;
assign  o_P0_FORCE_SELFREFRESH_R		             = 1'bz;		//STRAP
assign  o_P1_FORCE_SELFREFRESH_R		             = 1'bz;		//STRAP
assign  o_P0_DIMM_GL_PCAMP_R                               =   w_p0_dimm_gl_pcamp_r;//53
assign  o_P0_DIMM_AF_PCAMP_R                               =   w_p0_dimm_af_pcamp_r;//54
assign  o_P1_DIMM_GL_PCAMP_R                               =   w_p1_dimm_gl_pcamp_r;//53
assign  o_P1_DIMM_AF_PCAMP_R                               =   w_p1_dimm_af_pcamp_r;//54
//uart
assign  o_P0_UART_RXD_0				             = 1'bz;//55
// assign  o_P0_UART_RXD_1			                     = w_st_steady_pwrok ? i_UART_CPLD_RX_R: 1'b0;			
// assign  o_UART_CPLD_TX_R			                     = i_P0_UART_TXD_1;
assign  o_UART_CPLD_TX_R			                     =1'bz;
assign  o_P0_UART_RXD_1			                     = w_st_steady_pwrok ? i_CPLD1_CPLD2_RSV1: 1'b0;					
assign  o_CPLD1_CPLD2_RSV2                                   =   i_P0_UART_TXD_1;

assign  o_P0_SPI_CLK_STRAP                                   =   1'bz;
assign  o_P0_SPI_T245_OE_N_R                               =   w_rsmrst_n?1'b0:1'bz;
assign  o_P0_WAFL_STRAP_SEL_R                             =   1'bz;
//HDT
assign o_PAL_P0_PRSENT_HDT	                             =	db_cpu_prsnt_n[0];
assign o_PAL_P1_PRSENT_HDT	                             =	db_cpu_prsnt_n[1];
assign  o_HDT_CPU_PWROK		                             = db_i_p0_pwrok    ;
assign o_HDT_CPU_RESET_N	                                     = i_P0_RESET_N     ;
assign  o_PAL_TPCM_BIOS_DONE_R_N		             = 1'bz;
assign  o_PAL_BMC_POST_DONE_FLAG_R		     = r_bmc_ready;
assign  o_PAL_BIOS_DEBUG_R_N                               =   w_sys_debug_mode;
assign  o_PAL_TPCM_IRQ_R_L			             = 1'bz;
assign  o_PAL_TPCM_BMC_DONE_R_N		             = 1'bz;
assign  o_P0_VDDC_EN_R                                           =   w_grp_b_p0_33_s5_en;//2025-02-09 add ||(~w_SW_4) for pwron
assign  o_P1_VDDC_EN_R                                           =   w_grp_b_p1_33_s5_en;
assign  o_PAL_P0_VDD_18_STBY_EN_R                     =   w_grp_b_p0_18_s5_en;
assign  o_P1_VDD_18_STBY_EN                                 =   w_grp_b_p1_18_s5_en;
assign  o_PAL_P0_VDDIO_EN_R                                 =   w_grp_d_p0_vddio_en ;
assign  o_PAL_P1_VDDIO_EN_R                                 =   w_grp_d_p1_vddio_en;
assign  o_PAL_P0_VDD_11_SUS_EN                           =   w_grp_c_p0_vdd11_en;
assign  o_PAL_P1_VDD_11_SUS_EN                           =   w_grp_c_p1_vdd11_en;
assign  o_PAL_P0_VDD_CORE_1_11_SUS_RST_L_N   =   w_pal_p0_vdd_core_1_11_sus_rst_l_n;
assign  o_PAL_P1_VDD_CORE_1_11_SUS_RST_L_N   =   w_p1_vdd_core_1_11_sus_rst_l_n;
assign  o_PAL_P0_VDDIO_RST_N                               =   w_pal_p0_vddio_rst_n;
assign  o_P1_VDDIO_RST_L_N                                   =   w_p1_vddio_rst_l_n;
assign  o_PAL_P0_VDD_SOC_EN                                 =   w_grp_d_p0_soc_en;
assign  o_PAL_P1_VDD_SOC_EN                                 =   w_grp_d_p1_soc_en;
assign  o_PAL_P0_VDD_CORE_1_EN_R                       =   w_grp_d_p0_vddcore1_en;
assign  o_PAL_P1_VDD_CORE_1_EN_R                       =   w_grp_d_p1_vddcore1_en;
assign  o_PAL_P0_VDD_CORE_0_EN_R                       =   w_grp_d_p0_vddcore0_en;
assign  o_PAL_P1_VDD_CORE_0_EN_R                       =   w_grp_d_p1_vddcore0_en;
assign  o_PAL_P0_VDD_CORE_0_SOC_RST_L_N         =   w_pal_p0_vdd_core_0_soc_rst_l_n;
assign  o_PAL_P1_VDD_CORE_0_SOC_RST_L_N         =   w_pal_p1_vdd_core_0_soc_rst_l_n;
assign  o_P5V_VGA2_EN_N_R                                     =   w_p5v_vga2_en_n_r;
assign  o_PAL_P3V3_STBY_EN_R                               =   1'bz;
assign  o_P3V3_STBY_B_EN_R                                   =   1'bz;
assign  o_PAL_P5V_STBY_EN_R                                 =   w_p5v_stby_en;
assign  o_P1V2_STBY_EN_R                                       =   w_p5v_stby_usb_en;
assign  o_P0_I2C_9617_EN                                       =   db_i_pgd_p0_vdd_18_stby?1'b1:1'b0;
assign  o_PAL_P5V_EN_R                                           =   w_pal_p5v_en_r;
assign  o_SCALED_BAT_TEST_EN_R                           =   w_ctl_scaled_bat_test_en_r;
assign  o_P3V_BAT_SWITCH_EN_R                             =   ~w_pal_bmc_aux_pgd;
assign  o_PAL_BAT_SENSE_R                                     =   w_rtc_senor_sw;
assign  o_PAL_BMC_AUX_PGD                                     =   w_pal_bmc_aux_pgd;
assign  o_P1V0_STBY_M2_EN                                     =   w_p1v0_stby_m2_en;
assign  o_P0_VPP_9545_1_RST_N_R                         =   w_p0_vpp_9545_1_rst_n;
assign  o_P0_VPP_9545_2_RST_N_R                         =   w_p0_vpp_9545_2_rst_n;
assign  o_PAL_P0_I2C5_9548_RST_R                       =   w_bmc_i2c5_9548_rst_n;
assign  o_BMC_I2C9_9548_1_RST_N_R                     =   w_bmc_i2c9_9548_1_rst_n;
assign  o_BMC_I2C9_9548_2_RST_N_R                     =   w_bmc_i2c9_9548_2_rst_n;
assign  o_BMC_I2C9_9548_3_RST_N_R                     =   w_bmc_i2c9_9548_3_rst_n;
assign  o_BMC_I2C9_9548_4_RST_N_R                     =   w_bmc_i2c9_9548_4_rst_n;
assign  o_BIOS_POST_CMPLT_BMC_N_R                     =   db_i_p0_bios_post_stage_r_n;
assign  o_PAL_I3C_MUX_EN_R_N                               =   ~w_i3c_mux_en;
assign  o_I3C_MUX_SEL_R_0                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_SEL_R_1                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_SEL_R_2                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_SEL_R_3                                     =   db_i_p0_spd_host_ctrl_n;
assign  o_I3C_MUX_OE_N_R_0                                   =   1'b0;
assign  o_I3C_MUX_OE_N_R_1                                   =   1'b0;
assign  o_I3C_MUX_OE_N_R_2                                   =   1'b0;
assign  o_I3C_MUX_OE_N_R_3                                   =   1'b0;
assign  o_SHORT_DET_EN_R                                       =   1'b1;
assign  o_PAL_CLEAR_CMOS_R_N                               =   (~w_clr_cmos_flg & w_st_steady_pwrok    );	
assign  o_PAL_CMOS_CLEAR_R                                   =   (w_clr_cmos_done & w_st_off_standby  );
assign  o_BMC_JTAG_MUX_S                                       =   w_bmc_jtag_mux_s;//2025-03-05 chg 1'b0 to 1'b1
assign  o_BMC_JTAG_MUX_OE_N                                 =   1'b0;
assign  o_BMC_JTAG_TRST_R_N                                 =   w_bmc_jtag_trst_r_n;
assign  o_TPM_IO2_RST                                             =   db_i_p0_pcie_rst_n_0;
assign  o_EEPROM_WP_N_R                                         =   w_eeprom_wp ? 1'b0 : 1'b1;
assign  o_PAL_PVCC_HPMOS_SW_R                             =   w_FM_P12V_EN  ;//2025-02-09 add

//-------------------------------------------------------------------------------------------------
// BMC_CPLD_I2C_RAM 模块实例化
//-------------------------------------------------------------------------------------------------
// 功能：
// 1. 通过 I2C 接口与外部设备通信，支持数据的读写操作。
// 2. 提供多个输入信号，用于传递系统状态和配置信息。
// 3. 输出信号用于与其他模块交互，支持状态反馈和控制。
bmc_cpld_i2c_ram #(
    .DLY_LEN(16) // 延迟长度，50MHz 时钟下约 330ns
) bmc_cpld_i2c_ram_u0 (
<<<<<<< HEAD
    // 时钟和复位信号
    .i_rst_n                        (pon_reset_n                      ), // 复位信号，低电平有效
    .i_clk                          (clk_25m                          ), // 时钟信号，频率为 25MHz
    .i_1ms_clk                      (t1ms_tick                        ), // 1ms 时钟信号
    .i_rst_i2c_n                    (1'b1                             ), // I2C 复位信号，始终为高电平

    // I2C 接口信号
    .i_scl                          (i_I2C7_PAL_SCL                   ), // I2C 时钟信号
    .io_sda                         (io_I2C7_PAL_SDA                  ), // I2C 数据信号（双向）

    // 系统配置信号
    .i_product_id                   (`PRODUCT_ID                      ), // 地址 0x0000, 产品 ID
    .i_vender_id                    (`VENDER_ID                       ), // 地址 0x0001, 厂商 ID
    .i_board_id                     ({4'b0000, w_board_id}            ), // 地址 0x0002, 板卡 ID
    .i_pcb_version                  ({5'b0, w_pcb_version}            ), // 地址 0x0003, PCB 版本号
    .i_bom_id                       ({5'b0, w_pca_version}            ), // 地址 0x0004, BOM ID，
    .i_cpld_version                 (`CPLD_VERSION                    ), // 地址 0x0005, CPLD 版本号
    .o_test_reg                     (                                 ), // 地址 0x0006, 测试寄存器  
    .i_year                         (`Year                            ), // 地址 0x0007, 年份
    .i_month                        (`Month                           ), // 地址 0x0008, 月份
    .i_day                          (`Day                             ), // 地址 0x0009, 日期
    .i_nc_pin                       ({7'b0, w_nc_pin}                 ), // 地址 0x000A, 未连接引脚
    .i_cpld_compa_version           (8'h00                            ), // 地址 0x000B, CPLD 兼容版本
    .i_cpld_debug_version           (`DEBUG_VERSION                   ), // 地址 0x000C, CPLD 调试版本

    // 电源上下电状态信号
    // PSU（电源）状态信号，--0x000D
    /*
    .i_PS1_PRSNT                    (db_i_ps1_prsnt                   ), // PSU1 存在信号
    .i_PS2_PRSNT                    (db_i_ps2_prsnt                   ), // PSU2 存在信号
    .i_PS3_PRSNT                    (db_i_ps3_prsnt                   ), // PSU3 存在信号
    .i_PS4_PRSNT                    (db_i_ps4_prsnt                   ), // PSU4 存在信号
    .i_PS1_ACFAIL                   (db_i_ps1_acfail_n                ), // PSU1 交流电源故障信号
    .i_PS2_ACFAIL                   (db_i_ps2_acfail_n                ), // PSU2 交流电源故障信号
    .i_PS1_DCOK                     (db_i_ps1_dcok_n                  ), // PSU1 直流电源正常信号
    .i_PS2_DCOK                     (db_i_ps2_dcok_n                  ), // PSU2 直流电源正常信号
v
    // PSU（电源）状态信号，--0x000E
    .i_PS1_ALERT                    (db_i_ps1_smb_alert               ), // PSU1 警告信号
    .i_PS2_ALERT                    (db_i_ps2_smb_alert               ), // PSU2 警告信号
    .i_PS1_P12V_ON                  (w_ps1_p12v_on_r                  ), // PSU1 12V 电源开启信号
    .i_PS2_P12V_ON                  (w_ps2_p12v_on_r                  ), // PSU2 12V 电源开启信号
    .i_PS_OFF                       (w_pal_ps_off_r                   ), // 电源关闭信号
    .i_DUAL_EN                      (w_pal_dual_en_r                  ), // 双电源使能信号
    .i_P12V_DROOP                   (db_i_pgd_p12v_droop              ), // 12V 电压下跌信号
    .i_P12V_STBY_DROOP              (db_i_pgd_p12v_stby_droop         ), // 12V 待机电压下跌信号
=======
// 时钟和复位信号
    .i_rst_n        (pon_reset_n),       // 复位信号，低电平有效
    .i_clk          (clk_25m),           // 时钟信号，频率为 25MHz
    .i_1ms_clk      (t1ms_tick),         // 1ms 时钟信号
    .i_rst_i2c_n    (1'b1),              // I2C 复位信号，始终为高电平

    // I2C 接口信号
    .i_scl          (i_I2C7_PAL_SCL),    // I2C 时钟信号
    .io_sda         (io_I2C7_PAL_SDA),   // I2C 数据信号

    // 系统配置信号
    .i_product_id           (`PRODUCT_ID),              // 产品 ID，地址 0x0000
    .i_vender_id            (`VENDER_ID),               // 厂商 ID，地址 0x0001
    .i_board_id             ({4'b0000, w_board_id}),    // 板卡 ID，地址 0x0002
    .i_pcb_version          ({5'b0, w_pcb_version}),    // PCB 版本号，地址 0x0003
    .i_bom_id               ({5'b0, w_pca_version}),    // BOM ID，地址 0x0004
    .i_cpld_version         (`CPLD_VERSION),            // CPLD 版本号，地址 0x0005
    .o_test_reg             (),                         // 测试寄存器，地址 0x0006
    .i_year                 (`Year),                    // 年份，地址 0x0007
    .i_month                (`Month),                   // 月份，地址 0x0008
    .i_day                  (`Day),                     // 日期，地址 0x0009
    .i_nc_pin               ({7'b0, w_nc_pin}),         // 未连接引脚，地址 0x000A
    .i_cpld_compa_version   (8'h00),                    // CPLD 兼容版本，地址 0x000B
    .i_cpld_debug_version   (`DEBUG_VERSION),           // CPLD 调试版本，地址 0x000C

    // 电源状态信号
    // PSU 状态信号，地址 0x000D
    .i_PS1_PRSNT            (db_i_ps1_prsnt),           // PSU1 存在信号
    .i_PS2_PRSNT            (db_i_ps2_prsnt),           // PSU2 存在信号
    .i_PS3_PRSNT            (db_i_ps3_prsnt),           // PSU3 存在信号
    .i_PS4_PRSNT            (db_i_ps4_prsnt),           // PSU4 存在信号
    .i_PS1_ACFAIL           (db_i_ps1_acfail_n),        // PSU1 交流电源故障信号
    .i_PS2_ACFAIL           (db_i_ps2_acfail_n),        // PSU2 交流电源故障信号
    .i_PS1_DCOK             (db_i_ps1_dcok_n),          // PSU1 直流电源正常信号
    .i_PS2_DCOK             (db_i_ps2_dcok_n),          // PSU2 直流电源正常信号
>>>>>>> e195096c027b929d0adc57e9f44ea3efe77971d6

    // PSU（电源）状态信号，--0x000F
    .i_P12V_DISCHARGE               (w_p12v_discharge_r               ), // 12v的放电控制信号
    */

    // 电源状态信号（逻辑输入），--0x0010
    .i_PGD_P5V_MB                   (db_i_pgd_p5v                     ), // 地址 0x0010 bit7, 5V 电源良好信号
    .i_PGD_P5V_STBY_MB              (db_i_pg_p5v_stby                 ), // 地址 0x0010 bit6, 5V 待机电源良好信号
    .i_PGD_P3V3_STBY_MB             (db_i_pwrgd_p3v3_stby             ), // 地址 0x0010 bit5, 3.3V 待机电源良好信号
    .i_PGD_P3V3_STBY_B_MB           (db_i_pgd_p3v3_stby_b             ), // 地址 0x0010 bit4, 3.3V 待机备用电源良好信号
    .i_PGD_P1V8_PCH_STBY_MB         (db_i_p1v8_stby_pg                ), // 地址 0x0010 bit3, 1.8V PCH 待机电源良好信号
    .i_PGD_P1V2_STBY_MB             (db_i_pgd_p1v2_stby               ), // 地址 0x0010 bit2, 1.2V 待机电源良好信号
    .i_PGD_P1V05_PCH_STBY_MB        (                                 ), // 地址 0x0010 bit1, 1.05V PCH 待机电源良好信号（未连接）
    .i_PGD_PVNN_PCH_STBY_MB         (                                 ), // 地址 0x0010 bit0, PVNN PCH 待机电源良好信号（未连接）

    // USB接口状态信息，--0x0011
    .i_USB_INNER_OVERCUR3           (w_usb_inner_overcur3             ), // 地址 0x0011 bit7, USB 内部过流信号
    .i_USB2_LCD_OC_N                (w_usb2_lcd_oc_n                  ), // 地址 0x0011 bit6, USB2 LCD 过流信号

    // 电源状态信号（逻辑输出），--0x0012
    .i_PAL_P5V_EN_R_MB              (w_pal_p5v_en_r                   ), // 0x0012 bit7, 5V 电源使能信号
    .i_PAL_P5V_STBY_EN_R_MB         (w_p5v_stby_en                    ), // 0x0012 bit6, 5V 待机电源使能信号
    .i_P5V_STBY_USB_EN              (w_p5v_stby_usb_en                ), // 0x0012 bit5, 5V 待机 USB 电源使能信号
    .i_P5V_EN                       (w_p5v_en                         ), // 0x0012 bit4, 5V 电源使能信号
    .i_ncsi_main_pwr_en             (w_ocp_main_en                    ), // 0x0012 bit3, 主电源使能信号
    .i_ncsi_aux_pwr_en              (w_ocp_aux_en                     ), // 0x0012 bit2, 辅助电源使能信号
    .i_PAL_PVNN_STBY_EN_R_MB        (                                 ), // 0x0012 bit1, PVNN 待机电源使能信号（未连接）
    .i_PAL_EN_PWM_CTRL_VCC_R_MB     (                                 ), // 0x0012 bit0, PWM 控制 VCC 使能信号（未连接）

    // BMC JTAG 多路复用选择信号，控制 BMC JTAG 多路复用器的通道, --0x0013
    .o_BMC_JTAG_MUX_S               (w_bmc_jtag_mux_s                 ), // BMC JTAG 多路复用选择信号，地址 0x0013，bit7，默认值 1

<<<<<<< HEAD
    // 电源状态信号（逻辑输入），--0x0020
    .i_pwrgd_vdd_33_stby0           (db_i_pgd_p0_vddc                 ), // 地址 0x0020 bit7, 3.3V 待机电源良好信号
    .i_pwrgd_vdd_18_stby0           (db_i_pgd_p0_vdd_18_stby          ), // 地址 0x0020 bit6, 1.8V 待机电源良好信号
    .i_pal_pgd_p0_vdd_core_1        (db_i_pgd_p0_vdd_core_1           ), // 地址 0x0020 bit5, 核心电源良好信号 1
    .i_pal_pgd_p0_vdd_core_0        (db_i_pgd_p0_vdd_core_0           ), // 地址 0x0020 bit4, 核心电源良好信号 0
    .i_pal_pgd_p0_vdd_soc_0         (db_i_pgd_p0_vdd_soc_0            ), // 地址 0x0020 bit3, SoC 电源良好信号
    .i_pal_pgd_p0_vddio             (db_i_pgd_p0_vddio                ), // 地址 0x0020 bit2, IO 电源良好信号
    .i_pal_pgd_p0_vdd_sus_0         (db_i_pgd_p0_vdd_11_sus           ), // 地址 0x0020 bit1, SUS 电源良好信号
    .i_pal_cpu_sys_pwrok            (w_cpu_sys_pwrok                  ), // 地址 0x0020 bit0, CPU 系统电源良好信号

    // CPU0 ALERT 电源状态信号（逻辑输入），--0x0021
    .i_p0_pwrgd_out_r               (db_i_p0_pwrgd_out                ), // 地址 0x0021 bit7, 电源输出良好信号
    .i_p0_pwrok_r                   (db_i_p0_pwrok                    ), // 地址 0x0021 bit6, 电源正常信号

    // 电源状态信号（逻辑输出），--0x0021
    .i_p0_pwr_good_r                (w_cpu_pwr_good                   ), // 地址 0x0021 bit5, 电源良好信号

    // CPU0 PWR EN 电源状态信号（逻辑输出)， --0x0022
    .i_p0_vddc_en                   (w_grp_b_p0_33_s5_en              ), // 地址 0x0022 bit7, VDDC 电源使能信号
    .i_p0_vdd_18_stby_en            (w_grp_b_p0_18_s5_en              ), // 地址 0x0022 bit6, 1.8V 待机电源使能信号
    .i_pal_p0_vdd_11_sus_en         (w_grp_c_p0_vdd11_en              ), // 地址 0x0022 bit5, 1.1V SUS 电源使能信号
    .i_pal_p0_vddio_en_r            (w_grp_d_p0_vddio_en              ), // 地址 0x0022 bit4, IO 电源使能信号
    .i_pal_p0_vdd_soc_en            (w_grp_d_p0_soc_en                ), // 地址 0x0022 bit3, SoC 电源使能信号
    .i_pal_p0_vdd_core_0_en_r       (w_grp_d_p0_vddcore0_en           ), // 地址 0x0022 bit2, 核心电源 0 使能信号
    .i_pal_p0_vdd_core_1_en_r       (w_grp_d_p0_vddcore1_en           ), // 地址 0x0022 bit1, 核心电源 1 使能信号

    // 电源状态信号（逻辑输入），--0x0023
    .i_pwrgd_vdd_18_stby1           (db_i_pgd_p1_vdd_18_stby          ), // 地址 0x0023 bit7, 1.8V 待机电源良好信号
    .i_pwrgd_vdd_33_stby1           (db_i_pgd_p1_vddc                 ), // 地址 0x0023 bit6, 3.3V 待机电源良好信号
    .i_pal_pgd_p1_vdd_core_1        (db_i_pgd_p1_vdd_core_1           ), // 地址 0x0023 bit5, 核心电源良好信号 1
    .i_pal_pgd_p1_vdd_core_0        (db_i_pgd_p1_vdd_core_0           ), // 地址 0x0023 bit4, 核心电源良好信号 0
    .i_pal_pgd_p1_vdd_soc_0         (db_i_pgd_p1_vdd_soc_0            ), // 地址 0x0023 bit3, SoC 电源良好信号
    .i_pal_pgd_p1_vddio             (db_i_pgd_p1_vddio                ), // 地址 0x0023 bit2, IO 电源良好信号
    .i_pal_pgd_p1_vdd_sus_0         (db_i_pgd_p1_vdd_11_sus           ), // 地址 0x0023 bit1, SUS 电源良好信号

    // CPU1 ALERT 电源状态信号（逻辑输入），--0x0024
    .i_p1_pwrgd_out_r               (db_i_p1_pwrgd_out                ), // 地址 0x0024 bit7, 电源良好输出信号
    .i_p1_pwrok_r                   (db_i_p1_pwrok                    ), // 地址 0x0024 bit7, 电源正常信号

    // 电源状态信号（逻辑输出），--0x0024
    .i_p1_pwr_good_r                (db_i_p0_pwrgd_out                ), // 地址 0x0024 bit5, 电源良好信号

    // CPU0 PWR EN 电源状态信号（逻辑输出)， --0x0025
    .i_p1_vdd_18_stby_en            (w_grp_b_p1_18_s5_en              ), // 地址 0x0025 bit7, 1.8V 待机电源使能信号
    .i_p1_vddc_en                   (w_grp_b_p1_33_s5_en              ), // 地址 0x0025 bit6, VDDC 电源使能信号
    .i_pal_p1_vdd_11_sus_en         (w_grp_c_p1_vdd11_en              ), // 地址 0x0025 bit5, 1.1V SUS 电源使能信号
    .i_pal_p1_vddio_en_r            (w_grp_d_p1_vddio_en              ), // 地址 0x0025 bit4, IO 电源使能信号
    .i_pal_p1_vdd_soc_en            (w_grp_d_p1_soc_en                ), // 地址 0x0025 bit3, SoC 电源使能信号
    .i_pal_p1_vdd_core_0_en_r       (w_grp_d_p1_vddcore0_en           ), // 地址 0x0025 bit2, 核心电源 0 使能信号
    .i_pal_p1_vdd_core_1_en_r       (w_grp_d_p1_vddcore1_en           ), // 地址 0x0025 bit1, 核心电源 1 使能信号

    // CPU在位检测信号（逻辑输入）CPU PRSNT --0x0030
    .i_PAL_CPU0_PRSNT_N             (db_cpu_prsnt_n[0] & w_SW_1       ), // 地址 0x0030 bit7, CPU0 存在信号
    .i_PAL_CPU1_PRSNT_N             (db_cpu_prsnt_n[1] & w_SW_1       ), // 地址 0x0030 bit6, CPU1 存在信号

    // CPU在位检测信号（逻辑输入）CPU PRSNT --0x0032
    .i_P0_SMERR_N                   (db_i_p0_smerr_n                  ), // 地址 0x003 bit7, CPU0 错误信号
    .i_P1_SMERR_N                   (db_i_p1_smerr_n                  ), // 地址 0x003 bit6, CPU1 错误信号

    // CPU状态监控信号-过热检测到(逻辑输入) --0x0033
    .i_PAL_CPU0_MEMHOT_OUT_N        (                                 ), // 地址 0x0033 bit7, CPU0 内存过热信号（未连接）
    .i_PAL_CPU0_MEMTRIP_N           (                                 ), // 地址 0x0033 bit6, CPU0 内存断电信号（未连接）
    .i_PAL_CPU0_THERMTRIP_N         (db_i_p0_pwrgd_out ? wFM_CPU0_THERMTRIP_LVT3_Fault_N : 1'b1), // 0x0033，bit5, CPU0 热断电信号 
    .i_PAL_CPU0_PROCHOT_N           (w_p0_prochot_n                   ), // 地址 0x0033 bit4, CPU0 处理器过热信号，地址 
    .i_PAL_CPU1_MEMHOT_OUT_N        (                                 ), // 地址 0x0033 bit3, CPU1 内存过热信号（未连接） 
    .i_PAL_CPU1_MEMTRIP_N           (                                 ), // 地址 0x0033 bit2, CPU1 内存断电信号（未连接） 
    .i_PAL_CPU1_THERMTRIP_N         (~(db_cpu_prsnt_n[1] & w_SW_1) & db_i_p1_pwrgd_out ? wFM_CPU1_THERMTRIP_LVT3_Fault_N : 1'b1), // 0x0033，bit1, CPU1 热断电信号
    .i_PAL_CPU1_PROCHOT_N           (w_p1_prochot_n                   ), // 地址 0x0033 bit0, CPU1 处理器过热信号


    // CPU过热信号清除 pwr_flt_clr --0x0034
    .o_bmc_clr_tmout_n              (w_bmc_clr_tmout_n                ), // 地址 0x0034，bit7，默认值 1 BMC 清除超时信号（低电平有效）
    .o_pal_cpu0_forcepr_r           (w_cpu0_prochot                   ), // 地址 0x0034，bit6，默认值 0 CPU0 热节流信号，CPU0 温度过高时的节流控制
    .o_pal_cpu1_forcepr_r           (w_cpu1_prochot                   ), // 地址 0x0034，bit5，默认值 0 CPU1 热节流信号，CPU1 温度过高时的节流控制
    .o_clear_register               (w_clear_register                 ), // 地址 0x0034，bit4，默认值 0 清除寄存器信号
    
    // .o_cpu0_prochot             (w_cpu0_prochot),    // 地址 0x02a2，bit2
    // .o_cpu1_prochot             (w_cpu1_prochot),    // 地址 0x02a9，bit2

    // 电源故障代码地址 bit7-bit0,--0x0035
    .i_pwr_flt_code                 (w_pwr_flt_code                   ), // 地址 0x0035，bit7-bit0，电源故障代码，默认值 8'h00

    //////////////0X0036 -0X004F RESERVED FOR FUTURE USE///////////////////////////////////////////////////////////////////

    // 电源按钮标志 btn_press_flag --0x0050
    .i_btn_press_flag               (w_btn_press_flag                 ), // 地址 0x0050，bit7，按钮按下标志

    // 电源slps3, slps5状态 --0x0050
    .i_slps5_sts                    (db_i_p0_slp_s5_n                 ), // 地址 0x0050，bit6，S5 状态信号
    .i_slps3_sts                    (db_i_p0_slp_s3_n                 ), // 地址 0x0050，bit5，S3 状态信号

    // btn_evt --0x0051
    .i_sbtn_pwron_evt               (w_sbtn_pwron_evt                 ), // 地址 0x0051，bit7，in S5 软按钮开机事件（S5 状态下，软按钮按下 500ms 触发，通知 BMC 执行开机）
    .i_lbtn_pwrdown_evt             (w_lbtn_pwrdown_evt               ), // 地址 0x0051，bit6，in S0 硬按钮关机事件（S0 状态下，硬按钮按下 4s 触发，通知 BMC 执行强制关机）
    .i_sbtn_sysrst_evt              (w_sbtn_sysrst_evt                ), // 地址 0x0051，bit5，in S0 软按钮复位事件（S0 状态下，软按钮按下 500ms 触发，通知 BMC 执行系统复位）

    // bmc_clr_btn_evt --0x0052
    .o_bmc_clr_sbtn_n               (w_bmc_sbtn_wc                    ), // 地址 0x0052，bit7，BMC清除软开机事件（0=清除）
    .o_bmc_clr_lbtn_n               (w_bmc_lbtn_wc                    ), // 地址 0x0052，bit6，BMC清除硬关机事件（0=清除）
    .o_bmc_clr_sbtn_sys_n           (w_bmc_sbtn_sys_wc                ), // 地址 0x0052，bit5，BMC清除软复位事件（0=清除）
=======
    //CPU0 PGD --0x0020
    .i_pwrgd_vdd_33_stby0      (db_i_pgd_p0_vddc      ),  // 3.3V 待机电源良好信号，地址 0x0020，bit7
    .i_pwrgd_vdd_18_stby0      (db_i_pgd_p0_vdd_18_stby), // 1.8V 待机电源良好信号，地址 0x0020，bit6
    .i_pal_pgd_p0_vdd_core_1   (db_i_pgd_p0_vdd_core_1),  // 核心电源良好信号 1，地址 0x0020，bit5
    .i_pal_pgd_p0_vdd_core_0   (db_i_pgd_p0_vdd_core_0),  // 核心电源良好信号 0，地址 0x0020，bit4
    .i_pal_pgd_p0_vdd_soc_0    (db_i_pgd_p0_vdd_soc_0 ),  // SoC 电源良好信号，地址 0x0020，bit3
    .i_pal_pgd_p0_vddio        (db_i_pgd_p0_vddio     ),  // IO 电源良好信号，地址 0x0020，bit2
    .i_pal_pgd_p0_vdd_sus_0    (db_i_pgd_p0_vdd_11_sus),  // SUS 电源良好信号，地址 0x0020，bit1
    .i_pal_cpu_sys_pwrok       (w_cpu_sys_pwrok       ),  // CPU 系统电源良好信号，地址 0x0020，bit0

    //CPU0 ALERT --0x0021
    .i_p0_pwrgd_out_r          (db_i_p0_pwrgd_out     ), // addr 0x0021 bit7 电源良好输出信号
    .i_p0_pwrok_r              (db_i_p0_pwrok         ), // addr 0x0021 bit6 电源正常信号
    .i_p0_pwr_good_r           (w_cpu_pwr_good        ), // addr 0x0021 bit5 电源良好信号

    //CPU0 PWR EN --0x0022
    .i_p0_vddc_en              (w_grp_b_p0_33_s5_en   ), // addr 0x0022 bit7 VDDC 电源使能信号
    .i_p0_vdd_18_stby_en       (w_grp_b_p0_18_s5_en   ), // addr 0x0022 bit6 1.8V 待机电源使能信号
    .i_pal_p0_vdd_11_sus_en    (w_grp_c_p0_vdd11_en   ), // addr 0x0022 bit5 1.1V SUS 电源使能信号
    .i_pal_p0_vddio_en_r       (w_grp_d_p0_vddio_en   ), // addr 0x0022 bit4 IO 电源使能信号
    .i_pal_p0_vdd_soc_en       (w_grp_d_p0_soc_en     ), // addr 0x0022 bit3 SoC 电源使能信号
    .i_pal_p0_vdd_core_0_en_r  (w_grp_d_p0_vddcore0_en), // addr 0x0022 bit2 核心电源 0 使能信号
    .i_pal_p0_vdd_core_1_en_r  (w_grp_d_p0_vddcore1_en), // addr 0x0022 bit1 核心电源 1 使能信号

    
    //CPU0 PGD --0x0023
    .i_pwrgd_vdd_18_stby1      (db_i_pgd_p1_vdd_18_stby), // addr 0x0023 bit7 VDDC 电源使能。
    .i_pwrgd_vdd_33_stby1      (db_i_pgd_p1_vddc       ), // addr 0x0023 bit6 1.8V 待机电源使能
    .i_pal_pgd_p1_vdd_core_1   (db_i_pgd_p1_vdd_core_1 ), // addr 0x0023 bit5 1.1V SUS 电源使能
    .i_pal_pgd_p1_vdd_core_0   (db_i_pgd_p1_vdd_core_0 ), // addr 0x0023 bit4 IO 电源使能
    .i_pal_pgd_p1_vdd_soc_0    (db_i_pgd_p1_vdd_soc_0  ), // addr 0x0023 bit3 SoC 电源使能
    .i_pal_pgd_p1_vddio        (db_i_pgd_p1_vddio      ), // addr 0x0023 bit2 核心电源 0 使能
    .i_pal_pgd_p1_vdd_sus_0    (db_i_pgd_p1_vdd_11_sus ), // addr 0x0023 bit1 核心电源 1 使能

    //CPU1 ALERT --0x0024
    .i_p1_pwrgd_out_r				   (db_i_p1_pwrgd_out		   ),	//addr 0x0024 bit7 CPU1 电源良好输出信号
    .i_p1_pwrok_r				       (db_i_p1_pwrok		       ),	//addr 0x0024 bit6 CPU1 电源就绪信号
    .i_p1_pwr_good_r			     (db_i_p0_pwrgd_out			 ),	//addr 0x0024 bit5 CPU1 电源状态良好信号

    //CPU0 PWR EN --0x0025
    .i_p1_vdd_18_stby_en       (w_grp_b_p1_18_s5_en    ), // addr 0x0025 bit7 1.8V 待机电源使能
    .i_p1_vddc_en              (w_grp_b_p1_33_s5_en    ), // addr 0x0025 bit6 3.3V 电源使能
    .i_pal_p1_vdd_11_sus_en    (w_grp_c_p1_vdd11_en    ), // addr 0x0025 bit5 1.1V SUS 电源使能
    .i_pal_p1_vddio_en_r       (w_grp_d_p1_vddio_en    ), // addr 0x0025 bit4 IO 电源使能
    .i_pal_p1_vdd_soc_en       (w_grp_d_p1_soc_en      ), // addr 0x0025 bit3 SoC 电源使能
    .i_pal_p1_vdd_core_0_en_r  (w_grp_d_p1_vddcore0_en ), // addr 0x0025 bit2 核心电源 0 使能
    .i_pal_p1_vdd_core_1_en_r  (w_grp_d_p1_vddcore1_en ), // addr 0x0025 bit1 核心电源 1 使能
	
//CPU PRSNT --0x0030
.i_PAL_CPU0_PRSNT_N                          (db_cpu_prsnt_n[0] & w_SW_1    ),     //addr 0x0030 bit7
.i_PAL_CPU1_PRSNT_N                          (db_cpu_prsnt_n[1] & w_SW_1    ),     //addr 0x0030 bit6
//CPU ERR --0x0032
.i_P0_SMERR_N                                      (db_i_p0_smerr_n                        ),      //addr 0x0032 bit7
.i_P1_SMERR_N                                      (db_i_p1_smerr_n                        ),      //addr 0x0032 bit6
//CPU THERM --0x0033
.i_PAL_CPU0_MEMHOT_OUT_N                (  )         , //addr 0x0033 bit7 
.i_PAL_CPU0_MEMTRIP_N                      (  )         , //addr 0x0033 bit6 
.i_PAL_CPU0_THERMTRIP_N                  (db_i_p0_pwrgd_out ? wFM_CPU0_THERMTRIP_LVT3_Fault_N :1'b1 )  , //addr 0x0033 bit5 
.i_PAL_CPU0_PROCHOT_N                      (w_p0_prochot_n ),                                                                                      //addr 0x0033 bit4 
.i_PAL_CPU1_MEMHOT_OUT_N                ( )         , //addr 0x0033 bit3 
.i_PAL_CPU1_MEMTRIP_N                      ( )         , //addr 0x0033 bit2
.i_PAL_CPU1_THERMTRIP_N                  (~(db_cpu_prsnt_n[1] & w_SW_1) & db_i_p1_pwrgd_out ? wFM_CPU1_THERMTRIP_LVT3_Fault_N :1'b1)  , //addr 0x0033 bit1
.i_PAL_CPU1_PROCHOT_N                      (w_p1_prochot_n )             , //addr 0x0033 bit0 


//pwr_flt_clr --0x0034
.o_bmc_clr_tmout_n                            (w_bmc_clr_tmout_n)                 , //addr 0x0034 bit7  //default 1
.o_pal_cpu0_forcepr_r                      (w_cpu0_prochot)              , //addr 0x0034 bit6  //default 0
.o_pal_cpu1_forcepr_r                      (w_cpu1_prochot)              , //addr 0x0034 bit5  //default 0
.o_clear_register                              (w_clear_register)                  , //addr 0x0034 bit4  //default 0

// .o_cpu0_prochot						(w_cpu0_prochot					),	//addr 0x02a2 bit2 
// .o_cpu1_prochot						(w_cpu1_prochot			                ),	//addr 0x02a9 bit2 

//pwr_flt_code --0x0035
.i_pwr_flt_code                                  (w_pwr_flt_code)                    , //addr 0x0035       //default 8'h00
//////////////0X0036 -0X004F RESERVED FOR FUTURE USE///////////////////////////////////////////////////////////////////
//btn_press_flag --0x0050
.i_btn_press_flag                              (w_btn_press_flag )                 , //addr 0x0050 bit7
.i_slps5_sts                                        (db_i_p0_slp_s5_n )                 , //addr 0x0050 bit6  
.i_slps3_sts                                        (db_i_p0_slp_s3_n )                 , //addr 0x0050 bit5  
//btn_evt --0x0051
.i_sbtn_pwron_evt                              (w_sbtn_pwron_evt    )               , //addr 0x0051 bit7
.i_lbtn_pwrdown_evt                          (w_lbtn_pwrdown_evt)               , //addr 0x0051 bit6
.i_sbtn_sysrst_evt                            (w_sbtn_sysrst_evt  )               , //addr 0x0051 bit5
//bmc_clr_btn_evt --0x0052
.o_bmc_clr_sbtn_n                              (w_bmc_sbtn_wc          )                , //addr 0x0052 bit7  //default 1
.o_bmc_clr_lbtn_n                              (w_bmc_lbtn_wc          )                , //addr 0x0052 bit6  //default 1
.o_bmc_clr_sbtn_sys_n                      (w_bmc_sbtn_sys_wc  )                , //addr 0x0052 bit5  //default 1
//bmc_btn_ctl --0x0053
.o_pwr_btn_lock                                  (w_bmc_pwrbtn_lock       )  		, //addr 0x0053 bit7  //default 1
.o_bmc_power_soft_ctl                      (w_bmc_sbtn_powerdown )           , //addr 0x0053 bit6  //default 0
.o_bmc_lbtn_pwrdown_ctl                  (w_bmc_lbtn_powerdown )           , //addr 0x0053 bit5  //default 0
.o_bmc_sbtn_pwron_ctl                      (w_bmc_sbtn_poweron     )           , //addr 0x0053 bit4  //default 0
.o_bmc_sbtn_sysrst_ctl                    (w_bmc_sbtn_reset_ctl )           , //addr 0x0053 bit3  //default 0
//bmc_btn_done --0x0054
.i_bmc_power_soft_done                    (w_bmc_sbtn_powerdown_done ) , //addr 0x0054 bit7
.i_bmc_lbtn_pwrdown_done                (w_bmc_lbtn_powerdown_done ) , //addr 0x0054 bit6
.i_bmc_sbtn_pwron_done                    (w_bmc_sbtn_poweron_done     ) , //addr 0x0054 bit5
.i_bmc_sbtn_sysrst_done                  (w_bmc_ctl_sys_rst_done       ) , //addr 0x0054 bit4
>>>>>>> e195096c027b929d0adc57e9f44ea3efe77971d6

    // bmc_btn_ctl --0x0053
    .o_pwr_btn_lock                 (w_bmc_pwrbtn_lock                ), // 地址 0x0053，bit7，BMC 电源按钮锁定信号，BMC 控制，置 0 禁用物理按钮，置 1 启用
    .o_bmc_power_soft_ctl           (w_bmc_sbtn_powerdown             ), // 地址 0x0053，bit6，BMC 控制的软按钮开机信号，生成 500ms 脉冲
    .o_bmc_lbtn_pwrdown_ctl         (w_bmc_lbtn_powerdown             ), // 地址 0x0053，bit5，BMC 硬按钮关机信号（BMC 生成 6s 脉冲，触发强制关机）
    .o_bmc_sbtn_pwron_ctl           (w_bmc_sbtn_poweron               ), // 地址 0x0053，bit4，BMC 软按钮关机信号（BMC 生成 500ms 脉冲，触发正常关机）
    .o_bmc_sbtn_sysrst_ctl          (w_bmc_sbtn_reset_ctl             ), // 地址 0x0053，bit3，BMC 控制的系统复位信号，用于生成 500ms 脉冲

    // bmc_btn_done --0x0054
    .i_bmc_power_soft_done          (w_bmc_sbtn_powerdown_done        ), // 地址 0x0054，bit7，软关机完成（反馈BMC）
    .i_bmc_lbtn_pwrdown_done        (w_bmc_lbtn_powerdown_done        ), // 地址 0x0054，bit6，硬关机完成（反馈BMC）
    .i_bmc_sbtn_pwron_done          (w_bmc_sbtn_poweron_done          ), // 地址 0x0054，bit5，软开机完成（反馈BMC）
    .i_bmc_sbtn_sysrst_done         (w_bmc_ctl_sys_rst_done           ), // 地址 0x0054，bit4，BMC 控制的系统复位完成信号

    // bmc_uid --0x0056
    // .i_pal_bmcuid_button            (db_i_pal_bmcuid_button           ), // 地址 0x0056，bit7，关联 pal 模块的 BMCUID 按钮,高电平有效
    // 0x0065
    .i_p1_vr_i2c_alert_n			      (~db_i_p1_vr_i2c_alert_n          ), // 地址 0x0065 bit7，P0 电压调节模块（VR）I2C 告警（低电平有效），用于检测 P0 VR 的 I2C 接口告警
    .i_p0_vr_i2c_alert_n			      (~db_i_p0_vr_i2c_alert_n          ), // 地址 0x0065 bit6，P1电压调节模块（VR）I2C 告警（低电平有效），用于检测 P1 VR 的 I2C 接口告警		
    
    /*
    // --0x0066
    .i_P0_MCIOP0A_NVME0_PRSNT_N_R   (i_P0_MCIOP0A_NVME0_PRSNT_N_R     ), // addr 0x0066 bit7 
    .i_P0_MCIOP0C_NVME0_PRSNT_N_R   (i_P0_MCIOP0C_NVME0_PRSNT_N_R     ), // addr 0x0066 bit6 
    .i_P0_MCIOP0A_NVME1_PRSNT_N_R   (i_P0_MCIOP0A_NVME1_PRSNT_N_R     ), // addr 0x0066 bit5 
    .i_P0_MCIOP0C_NVME1_PRSNT_N_R   (i_P0_MCIOP0C_NVME1_PRSNT_N_R     ), // addr 0x0066 bit4 

    // 平台级 M2_0 存在信号（低电平有效），检测平台级 M2_0 是否存在 --0x006a
    .i_pal_m2_0_prsnt_n             (w_PAL_M2_0_PRSNT_N               ), //addr 0x006a bit7 
    .i_pal_m2_1_prsnt_n             (w_PAL_M2_1_PRSNT_N               ), //addr 0x006a bit6 
    .i_pal_bp1_prsnt_n              (w_PAL_BP1_PRSNT_N                ), //addr 0x006a bit5
    .i_pal_bp2_prsnt_n              (w_PAL_BP2_PRSNT_N                ), //addr 0x006a bit4
    .i_pal_bp3_prsnt_n              (w_PAL_BP3_PRSNT_N                ), //addr 0x006a bit3
    .i_pal_bp4_prsnt_n              (w_PAL_BP4_PRSNT_N                ), //addr 0x006a bit2
    .i_pal_bp5_prsnt_n              (w_PAL_BP5_PRSNT_N                ), //addr 0x006a bit1
    .i_pal_bp6_prsnt_n              (w_PAL_BP6_PRSNT_N                ), //addr 0x006a bit0
    // // 平台级 BP1 存在信号（低电平有效），检测平台级 BP1 是否存在 --0x006b                                                                                                           
    .i_pal_bp8_prsnt_n              (w_PAL_BP8_PRSNT_N                ), //addr 0x006b bit7
    */


    // P0 MCIOP0A GPU 降额信号（同步后，低电平有效），控制 P0 MCIOP0A GPU 降额, gpu_throttle_n--0x006c
    // .o_p0_mciop0a_gpu_throttle_n_r   (w_p0_mciop0a_gpu_throttle_n_r  ) , //addr 0x006c bit7  
    // .o_p0_mciop0c_gpu_throttle_n_r	  (w_p0_mciop0c_gpu_throttle_n_r  ) , //addr 0x006c bit6  

    // P0 PCIE 唤醒信号（低电平有效），P0 PCIE 唤醒控制, scpld_data --0x0070
    .i_p1_pcie_wake_n_r              (w_p1_pcie_wake_n                  ), //addr 0x0070 bit3
    .i_p0_pcie_wake_n_r              (w_p0_pcie_wake_n                  ), //addr 0x0070 bit2
    // I3C 多路复用使能，使能 I3C 多路复用器 --0x0073
    .o_i3c_mux_en		                 (w_i3c_mux_en	                    ), //addr 0x0073 bit7	//default 0
    // I3C 远程片选，I3C 接口的远程片选信号
    .o_i3c_remote_cs                 (w_i3c_remote_cs                   ), //addr 0x0073 bit4	//default 0


    // disable write-protect 1:enable write-protect 0:disable write-protect  EEPROM 写保护，控制 EEPROM 是否可写，EEP WR--0x0074
    .o_eeprom_wp	                   (w_eeprom_wp                       ), //addr 0x0074 bit7	//default 0
    .o_scaled_bat_test_en_r	         (w_ctl_scaled_bat_test_en_r        ), //addr 0x0074 bit6	//default 0
    .o_bmc_nmi_event                 (w_bmc_nmi_event                   ), //addr 0x0074 bit5	//default 0

    // RTC 传感器切换信号，控制 RTC 传感器的切换
    .o_rtc_senor_sw					         (w_rtc_senor_sw				            ), //addr 0x03A1 bit0 //default 0

    // pcycle--0x0076
    .o_aux_pcycle                    (w_pal_p3v3_stby_rst_r             ), //addr 0x0076 bit7 //default 0
    .o_usb_sw_s                      (w_usb_sw_s                        ), //addr 0x0076 bit6 //default 0

    // P12V 槽位 0 使能信号，控制 P12V 槽位 0 的使能 gpu_pwr --0x0077
    .o_p12v_slot_0_on                (w_p12v_slot_0_on                  ), //addr 0x0077 bit7 //default 1
    .o_p12v_slot_1_on                (w_p12v_slot_1_on                  ), //addr 0x0077 bit6 //default 1
    .o_p12v_slot_2_on                (w_p12v_slot_2_on                  ), //addr 0x0077 bit5 //default 1

    // BMC I2C9（9548 芯片）复位（低电平有效），复位 BMC 的 I2C9 接口, i2c_mux_rst -- 0x0078
    .o_bmc_i2c5_9548_rst_n			     (w_bmc_i2c5_9548_rst_n	            ), //addr 0x0078 bit7
    .o_bmc_i2c9_9548_1_rst_n		     (w_bmc_i2c9_9548_1_rst_n           ), //addr 0x0078 bit6
    .o_bmc_i2c9_9548_2_rst_n		     (w_bmc_i2c9_9548_2_rst_n           ), //addr 0x0078 bit5
    .o_bmc_i2c9_9548_3_rst_n		     (w_bmc_i2c9_9548_3_rst_n           ), //addr 0x0078 bit4
    .o_bmc_i2c9_9548_4_rst_n		     (w_bmc_i2c9_9548_4_rst_n           ), //addr 0x0078 bit3
    .o_p0_vpp_9545_1_rst_n			     (w_p0_vpp_9545_1_rst_n	            ), //addr 0x0078 bit2
    .o_p0_vpp_9545_2_rst_n			     (w_p0_vpp_9545_2_rst_n	            ), //addr 0x0078 bit1
    .o_p0_vpp_9545_3_rst_n			     (w_p0_vpp_9545_3_rst_n	            ), //addr 0x0078 bit0

    // 切换模式（8位），用于控制不同的切换模式配置 --0X0089
    .i_switch_mode                   (r_switch_mode                     ), //addr 0x0089 //default 0xff
    // 0X008A
    .o_164_mr_n                      (w_164_mr_n                        ), //addr 0x008a bit7 //default 1 //2025-1-16 del

    // P0 BIOS 启动阶段信号（低电平有效），指示 BIOS 启动进度 --0x008b
    .i_pch_bios_post_cmplt_n         (db_i_p0_bios_post_stage_r_n       ), //addr 0x008b bit7

    // .o_164_test_data              (w_164_test_data                   ), //addr 0x008c    //default 0xff //2024-5-14 chg 0f to ff
    // 切换模式 2（8位，寄存器型），用于控制切换模式 2 的配置 --0x008d
    .i_switch2_mode                  (r_switch2_mode                    ), //addr 0x008d    //default 0xff

    // 0x008e
    .i_LEAKAGE0_PRSNT_N              (~w_LEAKAGE0_PRSNT_N               ), //addr 0x008e bit7 泄漏存在 0 信号（低电平有效），检测是否存在泄漏（第 0 路相关
    .i_BREAK_DET_DO_N                (~w_BREAK_DET_DO_N                 ), //addr 0x008e bit6 断裂检测 D0 信号（低电平有效），用于检测 D0 相关的断裂情况
    .i_LEAKAGE_DET_DO_N              (~w_LEAKAGE_DET_DO_N               ), //addr 0x008e bit5 泄漏检测 D0 信号（低电平有效），用于检测 D0 相关的泄漏情况
    .i_LEAKAGE_PRSNT1_N              (~w_LEAKAGE_PRSNT1_N               ), //addr 0x008e bit4 泄漏存在 1 信号（低电平有效），检测是否存在泄漏（第 1 路相关）
    .i_BREAK_DET1_DO_N               (~w_BREAK_DET1_DO_N                ), //addr 0x008e bit3 断裂检测 1 D0 信号（低电平有效），检测 D0 相关的另一路断裂情况
    .i_LEAKAGE_DET1_DO_N             (~w_LEAKAGE_DET1_DO_N              ), //addr 0x008e bit2 泄漏检测 1 D0 信号（低电平有效），用于检测 D0 相关的另一路泄漏情况

    // 0x008f
    .o_leakage_int_mask              (w_leakage_int_mask                ), //addr 0x008f bit7  //2024-8-13 add //default 1
    // 主机控制相关的输入信号 --0x0090
    .i_p0_spd_host_ctrl_n				     (db_i_p0_spd_host_ctrl_n		        ), //addr 0x0090 bit6

    // 电源故障检测信号（逻辑输入） 
    // --0x0091
    .i_p12v_stby_fault_det			     (w_p12v_stby_fault_det				      ),	//addr 0x0091 bit7
    .i_p5v_stby_fault_det			       (w_p5v_stby_fault_det				      ),	//addr 0x0091 bit6
    .i_grp_b_p0_33_s5_fault_det		   (w_grp_b_p0_33_s5_fault_det			  ),	//addr 0x0091 bit3
    .i_grp_b_p1_33_s5_fault_det		   (w_grp_b_p1_33_s5_fault_det		    ),	//addr 0x0091 bit2	
    .i_grp_b_p0_18_s5_fault_det		   (w_grp_b_p0_18_s5_fault_det			  ),	//addr 0x0091 bit1
    .i_grp_b_p1_18_s5_fault_det		   (w_grp_b_p1_18_s5_fault_det		    ),	//addr 0x0091 bit0	
    // --0x0092
    .i_p5v_fault_det				         (w_p5v_fault_det					          ),	//addr 0x0092 bit6
    .i_p12v_efuse_fault_det			     (				                          ),	//addr 0x0092 bit5
    .i_p12v_ssd_efuse_fault_det		   (			                            ),	//addr 0x0092 bit4
    .i_p12v_p0_dimm_fault_det		     (			                            ),	//addr 0x0092 bit3
    .i_p12v_p1_dimm_fault_det		     (		                              ),	//addr 0x0092 bit2	 
    .i_grp_c_p0_fault_det			       (w_grp_c_p0_fault_det				      ),	//addr 0x0092 bit1
    .i_grp_c_p1_fault_det			       (w_grp_c_p1_fault_det		          ),	//addr 0x0092 bit0	 
    // --0x0093
    .i_grp_d_vddio_p0_fault_det		   (w_grp_d_vddio_p0_fault_det			  ),	//addr 0x0093 bit7 
    .i_grp_d_vddio_p1_fault_det		   (w_grp_d_vddio_p1_fault_det		    ),	//addr 0x0093 bit6 	   
    .i_grp_d_soc_p0_fault_det		     (w_grp_d_soc_p0_fault_det		      ),	//addr 0x0093 bit5 
    .i_grp_d_soc_p1_fault_det		     (w_grp_d_soc_p1_fault_det		      ),	//addr 0x0093 bit4	 
    .i_grp_d_p0_vddcore0_fault_det	 (w_grp_d_p0_vddcore0_fault_det     ),	//addr 0x0093 bit3
    .i_grp_d_p1_vddcore0_fault_det	 (w_grp_d_p1_vddcore0_fault_det		  ),	//addr 0x0093 bit2	 
    .i_grp_d_p0_vddcore1_fault_det	 (w_grp_d_p0_vddcore1_fault_det     ),	//addr 0x0093 bit1
    .i_grp_d_p1_vddcore1_fault_det	 (w_grp_d_p1_vddcore1_fault_det		  ),	//addr 0x0093 bit0	 

    // 电源过流保护状态信号（外部输入）
    // --0x009D
    .i_p1_vdd_core_1_ocp_n		       (~db_i_pal_p1_vdd_core_1_ocp_n	    ),	//addr 0x009D bit7	
    .i_p1_vdd_core_0_ocp_n		       (~db_i_p1_vdd_core_0_ocp_n_r	      ),	//addr 0x009D bit6	
    .i_p1_vddio_ocp_n			           (~db_i_p1_vddio_ocp_n		          ),	//addr 0x009D bit5	
    .i_p1_efuse_fault_n			         (1'b0		                          ),	//addr 0x009D bit4	
    .i_p0_vdd_core_1_ocp_n		       (~db_i_pal_p0_vdd_core_1_ocp_n	    ),	//addr 0x009D bit3
    .i_p0_vdd_core_0_ocp_n		       (~db_i_p0_vdd_core_0_ocp_n_r		    ),	//addr 0x009D bit2
    .i_p0_vddio_ocp_n			           (~db_i_p0_vddio_ocp_n				      ),	//addr 0x009D bit1

    // .i_rtc_sqw                    (~i_RTC_SQW		                    ),	//addr 0x009E bit7

    .o_pal_rst_rtc                   (w_pal_rst_rtc                     ),	//addr 0x009E bit7  平台复位 RTC（低电平有效，同步后），用于复位 RTC 模块
    .i_rtc_inta_n                    (~i_RTC_INTA_N					            ),	//addr 0x009E bit6  未使用

    .i_p1_i3c_apml_alert_n           (~i_P1_I3C_APML_ALERT_N		        ),	//addr 0x009E bit4	
    .i_p0_i3c_apml_alert_n           (~i_P0_I3C_APML_ALERT_N			      ),	//addr 0x009E bit3
    // .i_clk_gen_en_r_n                (w_clk_gen_en_r_n				          ),	//addr 0x009E bit2	
    // .i_clk_gen_alert_r_n             (~i_CLK_GEN_ALERT_R_N		          ),	//addr 0x009E bit1	

    // --0x00A0
    .o_force_allpwron_ctl            (w_force_allpwron_ctl			        ),	//addr 0x00A0 bit0	强制所有电源开启控制信号，强制开启所有电源轨

    //////////////////////////////////0x00C0-0x00D0 for FIX REG////////////////////////////////////////////////////////////
    // 主板固定配置输入（芯片级配置，缓存到固定地址 0x00C0-0x00D0）
    .i_PRODUCT_LINE_C2	             (`PRODUCT_LINE_C2                  ), //addr 0x00C2 输入：产品系列 ID（如 R6900 G5，宏定义，固定值）
    .i_PRODUCT_GEN_ID_C3             (`PRODUCT_GEN_ID_C3                ), //addr 0x00C3 输入：产品世代 ID（如 G5 世代，宏定义，固定值
    .i_SERVER_ID_C5                  (w_server_id_c5                    ), //addr 0x00C5 输入：服务器 ID（之前定义，区分不同背板配置，如 0x41/0x60） //2025-3-13`SERVER_ID_C5 
    .i_BOARD_ID_C6                   (`BOARD_ID_C6                      ), //addr 0x00C6 输入：主板 ID（区分不同主板版本，如 Rev A/B，宏定义）

    //////////////////////////////////0x00C0-0x00D0 for FIX REG////////////////////////////////////////////////////////////

    // 定义 FM PLD DB900 3 时钟使能信号 --0x00D1
    .o_fm_pld_db800_3_clks_dev_en	   (fm_pld_db800_3_clks_en		        ),	//addr 0x00D1 bit6
    // --0x00F4
    // P0 复位信号（低电平有效，同步后），用于 P0 模块复位
    // P1 复位信号（低电平有效，同步后），用于 P0 模块复位
    .i_cpu1_reset_n					        (db_i_p1_reset_n			              ),	//addr 0x00F4 bit0
    .i_cpu0_reset_n					        (db_i_p0_reset_n			              ),	//addr 0x00F4 bit0

    // --0X0103
    .i_p1_vdd_core_0_soc_rst_l_n		(db_i_p1_pwrok		                  ),	//addr 0x0103 bit7 P1 电源好信号（同步后），确保跨时钟域时的稳定性	 
    .i_p1_vdd_core_1_11_sus_rst_l_n	(db_i_p1_pwrok		                  ),	//addr 0x0103 bit6 P1 电源好信号（同步后），确保跨时钟域时的稳定性	 
    .i_p1_vddio_rst_l_n					    (db_i_p1_pwrok		                  ),	//addr 0x0103 bit5 P1 电源好信号（同步后），确保跨时钟域时的稳定性	 
    .i_p0_vddio_rst_l_n					    (db_i_p0_pwrok		                  ),	//addr 0x0103 bit4 P0 电源好信号（同步后），确保跨时钟域时的稳定性
    .i_p0_vdd_core_0_soc_rst_l_n		(db_i_p0_pwrok		                  ),	//addr 0x0103 bit3 P0 电源好信号（同步后），确保跨时钟域时的稳定性
    .i_p0_vdd_core_1_11_sus_rst_l_n	(db_i_p0_pwrok		                  ),	//addr 0x0103 bit2 P0 电源好信号（同步后），确保跨时钟域时的稳定性
    .i_cpu_sys_reset_r_n				    (db_i_pal_ext_rst_n	                ),	//addr 0x0103 bit1 按钮输出复位信号
    .i_cpu_rsmrst_r_n					      (w_rsmrst_n			                    ),	//addr 0x0103 bit0 CPU 电源好输出（2位），对外输出 CPU 电源好状态

    // JTAG CPLD BMC 测试复位（寄存器同步后），JTAG 接口相关的测试复位 
    // --0x0105
    .o_jtag_cpld_bmc_ntrst_r			  (w_jtag_cpld_bmc_ntrst_reg		      ),	//addr 0x0105 bit4
    // BMC 热复位控制信号 
    // --0x0130
    .o_bmc_warm_reset_ctl				    (w_bmc_warm_reset_ctl				        ),	//addr 0x0130 bit5

    // 电源故障检测到，检测到电源故障 
    // --0x0200 ? 0x0012
    .i_power_alarm_flag		          (w_power_fault		                  ),	//addr 0x0012 bit0
    // DC 故障检测到，检测到 DC 电源故障 
    // --0x0201 ? 0x0030
    .i_stb_pwron_tmout_fail			    (w_dc_failure_detected				      ),	//addr 0x0030 bit7
    // 待机上电超时故障清除，清除待机上电超时故障 
    // --0x0201 ? 0x0030
    .o_bmc_clr_stby_tmout_n			    (w_stb_pwron_tmout_fail_clr			    ),	//addr 0x0030 bit7      

    // 定义电源故障检测信号，用于指示系统是否存在 RT 或待机相关故障 
    // --0x0201 ? 0x0030
    .i_stb_pwrdown_ukwn_fail		    (w_power_fault_detected				      ),	//addr 0x0030 bit6  
    // 待机下电未知故障清除，清除待机下电时的未知故障 
    // --0x0201 ? 0x0030
    .o_bmc_clr_stby_pwr_drop_n		  (w_stb_pwrdown_ukwn_fail_clr		    ),	//addr 0x0030 bit6

    .i_poweron_tmout_fail			      (w_dc_failure_detected				      ),	//addr 0x0030 bit5
    // 待机下电未知故障清除，清除待机下电时的未知故障 
    // --0x0201 ? 0x0030
    .o_bmc_clr_core_tmout_n			    (w_poweron_tmout_fail_clr			      ),	//addr 0x0030 bit5 

    // 运行时故障检测到，检测到运行时故障 
    // --0x0201 ? 0x0030
    .i_powerdown_ukwn_fail			    (w_rt_failure_detected | w_stby_failure_detected  ), //addr 0x0030 bit4
    // 辅助故障恢复状态，辅助电源故障后的恢复阶段 
    // --0x0201 ? 0x0030
    .i_st_aux_fail_recovery			    (w_st_aux_fail_recovery | r_p12v_moc_stby_en_neg	), //addr 0x0030 bit3 
    // 所有电源好信号，指示所有电源轨均稳定 
    // --0x0201 ? 0x0030
    .i_system_pwr_sts				        (w_all_power_pg & db_i_p0_slp_s5_n	              ), //addr 0x0030 bit0

    // 超时错误码（8位，寄存器型），存储超时相关的错误码 
    // --0x0032
    .i_power_on_fail_err_code		    (r_timeout_code						          ),	// addr 0x0032

    // 开机失败错误码清除，清除开机失败的错误码 
    // --0x0032
    .o_power_on_fail_err_code_clr	  (w_power_on_fail_err_code_clr		    ),	// addr 0x0032 

    // 掉电错误码（8位，寄存器型），存储掉电相关的错误码
    //0x0203 ? 0x0032
    .i_power_down_fail_err_code		  (r_pwrdrop_code						          ),	//addr 0x0033 

    // 关机失败错误码清除，清除关机失败的错误码
    // 0x0204 ? 0x0033
    .o_power_down_fail_err_code_clr	(w_power_down_fail_err_code_clr		  ),	//addr 0x0033 

    // 电源序列状态机（6位），表示当前电源序列执行的状态
    // 0x0205
    .i_power_seq_state_machine		  ({2'b0,w_power_seq_sm	}			        ),	//addr 0x0035 

    // 电源序列状态机故障检测（6位），检测电源序列状态机相关故障
    // 0x0206
    .i_power_seq_fault_latch		    ({2'b0,w_pwrseq_sm_fault_det	}	    ),	//addr 0x0036

    // CPU 热跳闸故障检测信号
    // 0x02A1
    .i_cpu0_thermtrip					      (w_cpu_thermtrip_fault_det[0]	      ),	//addr 0x02a1 bit7 

    // CPU0 热跳闸清除信号，用于清除 CPU0 的热跳闸状态 
    .o_cpu0_thermtrip_clr				    (w_cpu0_thermaltrip_clr			        ),	//addr 0x02a1 bit7  

    // CPU 热跳闸故障检测信号
    // 0x02A8
    .i_cpu1_thermtrip					      (w_cpu_thermtrip_fault_det[1]	      ),	//addr 0x02a8 bit7 

    // CPU0 热跳闸清除信号，用于清除 CPU0 的热跳闸状态
    .o_cpu1_thermtrip_clr				    (w_cpu1_thermaltrip_clr			        ),	//addr 0x02a8 bit7 

    // 系统调试模式信号，使能系统调试模式
    // 0x02c0
    .o_sys_debug_mode					      (w_sys_debug_mode				            ),	//addr 0x02C0 bit0 

    // 0x02e0
    .i_p0_coretype2						      (i_P0_CORETYPE_2		                ),	//addr 0x02E0 bit6 未使用
    .i_p0_coretype1						      (i_P0_CORETYPE_1		                ),	//addr 0x02E0 bit5 未使用
    .i_p0_coretype0						      (i_P0_CORETYPE_0		                ),	//addr 0x02E0 bit4 未使用
    .i_p0_sp5r4							        (i_P0_SP5R_R_4			                ),	//addr 0x02E0 bit3 未使用
    .i_p0_sp5r3							        (i_P0_SP5R_R_3			                ),	//addr 0x02E0 bit2 未使用
    .i_p0_sp5r2							        (i_P0_SP5R_R_2			                ),	//addr 0x02E0 bit1 未使用
    .i_p0_sp5r1							        (i_P0_SP5R_R_1			                ),	//addr 0x02E0 bit0 未使用

    // 0x02e8
    .i_p1_coretype2						      (i_P1_CORETYPE_2		                ),	//addr 0x02E8 bit6 未使用	
    .i_p1_coretype1						      (i_P1_CORETYPE_1		                ),	//addr 0x02E8 bit5 未使用	
    .i_p1_coretype0						      (i_P1_CORETYPE_0		                ),	//addr 0x02E8 bit4 未使用	
    .i_p1_sp5r4							        (i_P1_SP5R_R_4			                ),	//addr 0x02E8 bit3 未使用	
    .i_p1_sp5r3							        (i_P1_SP5R_R_3			                ),	//addr 0x02E8 bit2 未使用	
    .i_p1_sp5r2							        (i_P1_SP5R_R_2			                ),	//addr 0x02E8 bit1 未使用	
    .i_p1_sp5r1							        (i_P1_SP5R_R_1			                ),	//addr 0x02E8 bit0 未使用	

    // DIMM 告警标志，DIMM（内存）的告警指示
    // 0x0300
    .i_dimm_alarm_flag					    (w_dimm_alarm_flag				          ),	//addr 0x0300 bit0

    // DIMM 故障检测信号，检测 DIMM（内存）相关的故障
    // 0x0312
    .i_p1_dimm_gl_pwrgd_fail_event		  (w_p1_dimm_gl_pwrgd_fail_event	    ),	//addr 0x0312 bit3	
    .o_p1_dimm_gl_pwrgd_fail_event_clr	(w_p1_dimm_gl_pwrgd_fail_event_clr  ),	//addr 0x0312 bit3	
    .i_p1_dimm_af_pwrgd_fail_event		  (w_p1_dimm_af_pwrgd_fail_event	    ),	//addr 0x0312 bit2	
    .o_p1_dimm_af_pwrgd_fail_event_clr	(w_p1_dimm_af_pwrgd_fail_event_clr  ),	//addr 0x0312 bit2	
    .i_p0_dimm_gl_pwrgd_fail_event		  (w_p0_dimm_gl_pwrgd_fail_event	    ),	//addr 0x0312 bit1
    .o_p0_dimm_gl_pwrgd_fail_event_clr	(w_p0_dimm_gl_pwrgd_fail_event_clr  ),	//addr 0x0312 bit1
    .i_p0_dimm_af_pwrgd_fail_event		  (w_p0_dimm_af_pwrgd_fail_event	    ),	//addr 0x0312 bit0
    .o_p0_dimm_af_pwrgd_fail_event_clr	(w_p0_dimm_af_pwrgd_fail_event_clr  ),	//addr 0x0312 bit0

    // 0x03a0
    //.o_bios_reflash						        (bios_reflash					              ),	//addr 0x03A0 bit7
    .o_bmc_nmi_ctl						          (w_bmc_nmi_ctl					            ),	//addr 0x03A0 bit6 BMC NMI 控制信号，BMC 不可屏蔽中断控制
    .i_bmc_nmi_ctl						          (w_bmc_nmi_ctl_rst				          ),	//addr 0x03A0 bit6 BMC NMI 控制复位信号，复位 BMC NMI 控制状态
    .i_bmc_clr_cmos						          (w_clr_cmos_done_rst			          ),	//addr 0x03A0 bit4 CMOS 清除完成复位信号，CMOS 清除完成后的复位控制
    .o_clr_cmos_ctl						          (w_clr_cmos_flg					            ),	//addr 0x03A0 bit4 CMOS 清除标志，标记 CMOS 清除操作的状态

    // 地址范围 0x1050-0x1058
    // eSPI 配置缓存信号：用于存储 PCH 下发的配置指令（如扩展槽电源参数），
    .o_espi_ram_1050                    (w_espi_ram_1050                    ), //addr 0x1050 //default 0xff
    .o_espi_ram_1051                    (w_espi_ram_1051                    ), //addr 0x1051 //default 0xff
    .o_espi_ram_1052                    (w_espi_ram_1052                    ), //addr 0x1052 //default 0xff
    .o_espi_ram_1053                    (w_espi_ram_1053                    ), //addr 0x1053 //default 0xff
    .o_espi_ram_1054                    (w_espi_ram_1054                    ), //addr 0x1050 //default 0xff
    .i_espi_ram_1055                    (w_espi_ram_1055                    ), //addr 0x1051 //default 0xff
    .i_espi_ram_1056                    (w_espi_ram_1056                    ), //addr 0x1052 //default 0xff
    .i_espi_ram_1057                    (w_espi_ram_1057                    ), //addr 0x1053 //default 0xff
    .i_espi_ram_1058                    (w_espi_ram_1058                    )  //addr 0x1053 //default 0xff
);


/************************************************************************************************************************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------
//I2C RAM  End
//--------------------------------------------------------------------------------------------------------------------------------------------------
/************************************************************************************************************************************************************************/


endmodule



