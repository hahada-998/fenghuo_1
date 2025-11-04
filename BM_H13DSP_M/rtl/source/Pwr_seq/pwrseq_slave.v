//=================================================================================================
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : pwrseq_slaveoutput v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2017-07-18
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description: This module handles power enablement and fault detectionoutput  It relies on
//   pwrseq_master module for much of the control hereoutput 
//   SHARED_P5V_STBY_HPMOS: When set, platform uses P5V_STBY as the HPMOS sourceoutput  Sequencer ensures
//     that P5V_STBY is up when HPMOS enable is turned on and any rails that depend on HPMOSoutput 
//     Default: 1'b0
//   S5DEV_STUCKON_FAULT_CHK: When set, enable stuckon fault check for s5dev where PGD is asserted
//     while EN is de-assertedoutput 
//     Default: 1'b0
//   BOUND_SYS_PWROK: If set, wait for delay of 25ms once in SM_STEADY_OK before asserting 
//     pch_sys_pwrok instead of waiting on gmt_sysrst_noutput  If cleared, wait for de-assertion of 
//     gmt_sysrst_n before asserting pch_sys_pwrokoutput  This parameter allows bounding the
//     pch_sys_pwrok assertion to bound PCH's PROCPWRGD to PLTRST# delayoutput 
//     Default: 1'b1
//   NUM_CPU: Number of CPUs to support
//     Default: 2
//   NUM_OPT_AUX: Number of additional aux rails to support and checkoutput  If this is a not zero, the
//     opt_aux_pgd rails are monitored when opt_check_en is enabledoutput  Any fault detected will be 
//     binned to any_aux_vrm_faultoutput  If set to 0, the check is disabledoutput  Note there is no separate
//     parameter to enable checkingoutput 
//     Default: 0
//   NUM_S5DEV: Number of S5 devices (ALOM/BLOM/Tbird mezz) to supportoutput  A value of 0 disables supportoutput 
//     Default: 0
//   NUM_SAS: Number of SAS device (AROC/BROC) to supportoutput  A value of 0 disables
//     supportoutput 
//     Default: 0
//   NUM_HD_BP: Number of HDD backplane to supportoutput  A value of 0 disables supportoutput 
//     Default: 0
//   NUM_M2_BP
//   - Number of M2 backplane to supportoutput  A value of 0 disables supportoutput 
//     Default: 0
//   NUM_RISER: Number of riser card to supportoutput  A value of 0 disables supportoutput 
//     Default: 0
//   NUM_MEZZ: Number of c-class blade mezz card to supportoutput  A value of 0 disables supportoutput 
//     Default: 0
//   HPMOS_TYPE: Used only when BT_MODE is setoutput  When clear, the corresponding HPMOS type is VRDoutput 
//     When set, it's pass-thru fet which will depend on HPMOS_OWNERoutput  This is NUM_CPU wide 
//     parameter with each bit corresponding to each CPUoutput 
//     Default: 2'b10 (CPU1 = FET, CPU0 = VRD)
//   HPMOS_OWNER: Used only when BT_MODE is setoutput  Specifies which HPMOS source is used for the 
//     corresponding CPUoutput  Each corresponds to 2 bits in this arrayoutput  For example, 8'b01_00_00_00
//     means CPU0/CPU1/CPU2's source is CPU0output   CPU3's source is CPU1output 
//     Default: 4'b00_00 (CPU0/CPU1 source is CPU0)
//   RECOV_FAULT_MASK: Determines which fault is recoverableoutput  Search for fault_vec_mapping below
//     for signal mappingoutput 
//     Default: 40'bx
//   LIM_RECOV_FAULT_MASK: Determines which fault has limited recovery via 3-strikeoutput 
//     Default: 40'bx
//   NON_RECOV_FAULT_MASK: Determines which fault has no recovery (needs aux power cycle)output 
//     Default: 40'bx
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================
//`include "as03mb03_define.vh"

module pwrseq_slave #(
    parameter SHARED_P5V_STBY_HPMOS       = 1'b0; // 是否使用 P5V_STBY 作为 HPMOS 电源
    parameter S5DEV_STUCKON_FAULT_CHK     = 1'b0; // 是否启用 S5 设备卡死故障检查
    parameter BOUND_SYS_PWROK             = 1'b1; // 是否绑定系统电源 OK 信号
    parameter NUM_CPU                     = 2;    // 支持的 CPU 数量
    parameter NUM_OPT_AUX                 = 0;    // 额外辅助电源数量
    parameter NUM_S5DEV                   = 0;    // S5 设备数量
    parameter NUM_SAS                     = 0;    // SAS 设备数量
    parameter NUM_HD_BP                   = 0;    // HDD 背板数量
    parameter NUM_M2_BP                   = 0;    // M.2 背板数量
    parameter NUM_RISER                   = 0;    // Riser 卡数量
    parameter NUM_MEZZ                    = 0;    // Mezz 卡数量
    //parameter   [NUM_CPU-1:0] HPMOS_TYPE  = 2'b10,
    //parameter   [2*NUM_CPU-1:0] HPMOS_OWNER = 4'b00_00,
    parameter FAULT_VEC_SIZE              = 40;   // 故障向量大小
    // bit location guide for mask below                      3         3         2         1
    //                                                        9         1         3         5         7
    parameter [FAULT_VEC_SIZE-1:0] RECOV_FAULT_MASK     = 40'b0000_1111_1111_0000_0000_0000_0000_0000_0000_0000,
    parameter [FAULT_VEC_SIZE-1:0] LIM_RECOV_FAULT_MASK = 40'b0011_0000_0000_1111_1111_1111_1111_1111_1111_1001,
    parameter [FAULT_VEC_SIZE-1:0] NON_RECOV_FAULT_MASK = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) 
    (
    // 时钟和复位信号
    input wire clk                ;                // 时钟信号
    input wire reset              ;              // 复位信号

    // 定时信号
    input wire t1us               ;               // 每 1us 的脉冲信号
    input wire t512us             ;             // 每 512us 的脉冲信号
    input wire t1ms               ;               // 每 1ms 的脉冲信号
    input wire t2ms;               // 每 2ms 的脉冲信号
    input wire t64ms;              // 每 64ms 的脉冲信号
    input wire t1s;                // 每 1s 的脉冲信号
  
    // 来自 pwrseq_master 的信号
    input wire keep_alive_on_fault;    // 故障时保持电源开启
    input wire [5:0] power_seq_sm;     // 当前电源状态机状态
    input wire dc_on_wait_complete;    // DC 上电等待完成信号
    input wire rt_critical_fail_store; // 关键故障存储信号
    input wire fault_clear;            // 故障清除信号

    //to pwrseq_master   
    output    reg      pgd_so_far				          ,  
    output    wire     s5dev_pwren_request		    ,       	
    output    wire     s5dev_pwrdis_request	      ,           
    output    reg      any_pwr_fault_det		      , 
    output    wire     any_aux_vrm_fault		      ,   
    output    reg      any_recov_fault			      ,   
    output    reg      any_lim_recov_fault		    ,          	
    output    reg      any_non_recov_fault		    , 

    // 电源控制器 PG 信号
    input     wire     p5v_stby_pg;         // P5V_STBY 电源良好信号
    input     wire     grp_b_p0_33_s5_pg;   // S5 电源良好信号 (P0 3.3V)
    input     wire     grp_b_p1_33_s5_pg;   // S5 电源良好信号 (P1 3.3V)
    input     wire     grp_b_p0_18_s5_pg;   // S5 电源良好信号 (P0 1.8V)
    input     wire     grp_b_p1_18_s5_pg;   // S5 电源良好信号 (P1 1.8V)
    input     wire     p3v3_stby_pg;        // P3V3_STBY 电源良好信号
    input     wire     p12v_stby_pg;        // P12V_STBY 电源良好信号
    input     wire     p12v_efuse_pg;       // P12V EFUSE 电源良好信号
    input     wire     p12v_ssd_efuse_pg;   // P12V SSD EFUSE 电源良好信号
    input     wire     p12v_p0_dimm_pg;     // P12V DIMM 电源良好信号 (P0)
    input     wire     p12v_p1_dimm_pg;     // P12V DIMM 电源良好信号 (P1)
    input     wire     p5v_pg;              // P5V 电源良好信号
    input     wire     grp_c_p0_pg;         // GRP_C 电源良好信号 (P0)
    input     wire     grp_c_p1_pg;         // GRP_C 电源良好信号 (P1)
    input     wire     grp_d_vddio_p0_pg;   // GRP_D VDDIO 电源良好信号 (P0)
    input     wire     grp_d_vddio_p1_pg;   // GRP_D VDDIO 电源良好信号 (P1)
    input     wire     grp_d_soc_p0_pg;     // GRP_D SOC 电源良好信号 (P0)
    input     wire     grp_d_soc_p1_pg;     // GRP_D SOC 电源良好信号 (P1)
    input     wire     grp_d_p0_vddcore0_pg;// GRP_D VDDCORE0 电源良好信号 (P0)
    input     wire     grp_d_p1_vddcore0_pg;// GRP_D VDDCORE0 电源良好信号 (P1)
    input     wire     grp_d_p0_vddcore1_pg;// GRP_D VDDCORE1 电源良好信号 (P0)
    input     wire     grp_d_p1_vddcore1_pg;// GRP_D VDDCORE1 电源良好信号 (P1)
    input     wire     i_pwrgd_ocp0_nic_pwrgd; // OCP 电源良好信号
  
    // input         wire       [2:0]pcb_id                      ,
  
    // 故障检测信号
    output    reg [5:0] pwrseq_sm_fault_det; // 故障发生时的状态机状态
    output    wire      p5v_stby_fault_det;       // P5V_STBY 故障检测信号
    output    wire      grp_c_p0_fault_det;       // GRP_C P0 故障检测信号
    output    wire      grp_c_p1_fault_det;       // GRP_C P1 故障检测信号
    output    wire      grp_d_vddio_p0_fault_det; // GRP_D VDDIO P0 故障检测信号
    output    wire      grp_d_vddio_p1_fault_det; // GRP_D VDDIO P1 故障检测信号
    output    wire      grp_d_soc_p0_fault_det;   // GRP_D SOC P0 故障检测信号
    output    wire      grp_d_soc_p1_fault_det;   // GRP_D SOC P1 故障检测信号
    output    wire      grp_d_p0_vddcore0_fault_det; // GRP_D VDDCORE0 P0 故障检测信号
    output    wire      grp_d_p1_vddcore0_fault_det; // GRP_D VDDCORE0 P1 故障检测信号
    output    wire      grp_d_p0_vddcore1_fault_det; // GRP_D VDDCORE1 P0 故障检测信号
    output    wire      grp_d_p1_vddcore1_fault_det; // GRP_D VDDCORE1 P1 故障检测信号 
  
    output wire grp_b_p0_33_s5_fault_det; // GRP_B P0 3.3V S5 故障检测信号
    output wire grp_b_p1_33_s5_fault_det; // GRP_B P1 3.3V S5 故障检测信号
    output wire grp_b_p0_18_s5_fault_det; // GRP_B P0 1.8V S5 故障检测信号
    output wire grp_b_p1_18_s5_fault_det; // GRP_B P1 1.8V S5 故障检测信号
  
    output wire p3v3_stby_fault_det;      // P3V3_STBY 故障检测信号
    // output         wire           p12v_stby_fault_det         ,  
    output wire p5v_fault_det;            // P5V 故障检测信号
    // output		wire			p12v_efuse_fault_det		,
    // output		wire			p12v_ssd_efuse_fault_det	,
    // output		wire			p12v_p0_dimm_fault_det		,
    // output		wire			p12v_p1_dimm_fault_det		, 

    // 电源使能信号
    output wire p5v_stby_en;              // P5V_STBY 电源使能信号
    output wire p5v_stby_usb_en;          // P5V_STBY USB 电源使能信号
    output wire grp_b_p0_33_s5_en;        // GRP_B P0 3.3V S5 电源使能信号
    output wire grp_b_p1_33_s5_en;        // GRP_B P1 3.3V S5 电源使能信号
    output wire grp_b_p0_18_s5_en;        // GRP_B P0 1.8V S5 电源使能信号
    output wire grp_b_p1_18_s5_en;        // GRP_B P1 1.8V S5 电源使能信号
    output wire power_supply_on;          // 主电源使能信号
    // output		wire		   p12_en_p0_dimm_1		,
    // output		wire		   p12_en_p1_dimm_1		,
    // output          wire                   p12_en_p0_dimm_2     ,
    // output          wire                   p12_en_p1_dimm_2     ,
    output wire p5v_en;                   // P5V 电源使能信号
    output wire grp_c_p0_vdd11_en;        // GRP_C P0 VDD11 电源使能信号
    output wire grp_c_p1_vdd11_en;        // GRP_C P1 VDD11 电源使能信号
    output wire grp_d_p0_vddio_en;        // GRP_D P0 VDDIO 电源使能信号
    output wire grp_d_p1_vddio_en;        // GRP_D P1 VDDIO 电源使能信号
    output wire grp_d_p0_soc_en;          // GRP_D P0 SOC 电源使能信号
    output wire grp_d_p1_soc_en;          // GRP_D P1 SOC 电源使能信号
    output wire grp_d_p0_vddcore0_en;     // GRP_D P0 VDDCORE0 电源使能信号
    output wire grp_d_p1_vddcore0_en;     // GRP_D P1 VDDCORE0 电源使能信号
    output wire grp_d_p0_vddcore1_en;     // GRP_D P0 VDDCORE1 电源使能信号
    output wire grp_d_p1_vddcore1_en;     // GRP_D P1 VDDCORE1 电源使能信号
    output wire ocp_aux_en;               // 辅助电源使能信号
    output wire ocp_main_en;              // 主电源使能信号
    // output		wire		   usb_ponrst_r_n		,
    // output		wire		   tpcm_reset_n			, 

    // CPU 信号
    input wire [NUM_CPU-1:0] i_cpu_pwrok;    // CPU 电源 OK 信号
    input wire [NUM_CPU-1:0] i_cpu_prsnt_n;  // CPU 存在信号
  
    // 输出到 CPU 的信号
    output wire o_p0_pwr_good;            // P0 电源良好信号
    output wire [NUM_CPU-1:0] o_cpu_pwrok;// CPU 电源 OK 信号
    output wire o_rsmrst_n;               // RSMRST 信号
  
    //to system reset
    output    reg      reached_sm_wait_powerok	
);

//------------------------------------------------------------------------------
// Power sequence state definition
//------------------------------------------------------------------------------
`include "pwrseq_define.vh"

reg reg_rsmrst_l			        ;
reg reg_p5v_stby_en			;
reg reg_p5v_stby_usb_en           ; 
reg reg_grp_b_33_s5_en		;
reg reg_grp_b_18_s5_en		;
reg reg_power_supply_on		;
reg reg_p5v_en				;
reg reg_grp_c_en			        ;
reg reg_grp_d_vddio_en		;
reg reg_grp_d_soc_en		        ;
reg reg_grp_d_vddcore0_en	;
reg reg_grp_d_vddcore1_en	;
reg reg_ocp_aux_en			;
reg reg_ocp_main_en			;
// reg reg_usb_ponrst_r_n		;
// reg reg_tpcm_reset_n		;
reg reg_s5dev_pwren_request	;
reg reg_cpu_pwrgood	                ;
reg [NUM_CPU-1:0] reg_pwrok    ;
// reg reg_p12_en_dimm                   ; 

wire    st_reset_state            ;
wire    st_off_standby            ;
wire    st_en_telem                  ;
wire    st_en_main_efuse        ;
wire    st_en_grp_atx              ;
wire    st_en_grp_c                  ;
wire    st_en_grp_d_vddio      ;
wire    st_en_grp_d_vddcore0;
wire    st_en_grp_d_vddcore1;
wire    st_wait_powerok          ;
wire    st_steady_pwrok          ;
wire    st_critical_fail        ;
wire    st_disable_main_efuse;
wire    st_halt_power_cycle   ;
wire    st_aux_fail_recovery ;


assign p5v_stby_en			=	reg_p5v_stby_en			&	( ~p5v_stby_fault_det 									| keep_alive_on_fault )	;
assign p5v_stby_usb_en  	        =	reg_p5v_stby_usb_en		;//&((~p5v_stby_usb0_fault_det & ~p5v_stby_usb1_fault_det) 	| keep_alive_on_fault )	;  
assign grp_b_p0_33_s5_en	        =	reg_grp_b_33_s5_en		&	(~grp_b_p0_33_s5_fault_det | keep_alive_on_fault )	;//~i_cpu_prsnt_n[0] & (~grp_b_p0_33_s5_fault_det | keep_alive_on_fault )	;
assign grp_b_p1_33_s5_en	        =	reg_grp_b_33_s5_en		&	~i_cpu_prsnt_n[1] & (~grp_b_p1_33_s5_fault_det | keep_alive_on_fault )	;
assign grp_b_p0_18_s5_en	        =	reg_grp_b_18_s5_en		&	(~grp_b_p0_18_s5_fault_det | keep_alive_on_fault )	;//~i_cpu_prsnt_n[0] & (~grp_b_p0_18_s5_fault_det | keep_alive_on_fault )	;
assign grp_b_p1_18_s5_en	        =	reg_grp_b_18_s5_en		&	~i_cpu_prsnt_n[1] & (~grp_b_p1_18_s5_fault_det | keep_alive_on_fault )	;

assign power_supply_on		=	reg_power_supply_on	| keep_alive_on_fault 	;
// assign power_supply_on		=	reg_power_supply_on		& 	((/* ~p12v_efuse_fault_det &  */~p12v_ssd_efuse_fault_det)	| keep_alive_on_fault )	;
// assign p12_en_p0_dimm_1		=	reg_p12_en_dimm		    &	~i_cpu_prsnt_n[0] & (~p12v_p0_dimm_fault_det 			| keep_alive_on_fault )	; 	
// assign p12_en_p1_dimm_1		=	reg_p12_en_dimm		    &	~i_cpu_prsnt_n[1] & (~p12v_p1_dimm_fault_det 			| keep_alive_on_fault )	; 
// assign p12_en_p0_dimm_2		=	reg_power_supply_on		&	~i_cpu_prsnt_n[0] & (~p12v_p0_dimm_fault_det 			| keep_alive_on_fault )	; 
// assign p12_en_p1_dimm_2		=	reg_power_supply_on		&	~i_cpu_prsnt_n[1] & (~p12v_p1_dimm_fault_det 			| keep_alive_on_fault )	; 

assign p5v_en				=	reg_p5v_en				&	(~p5v_fault_det | keep_alive_on_fault )	;
assign grp_c_p0_vdd11_en	        =	reg_grp_c_en			&	~i_cpu_prsnt_n[0] & (~grp_c_p0_fault_det			 | keep_alive_on_fault )	;
assign grp_c_p1_vdd11_en	        =	reg_grp_c_en			&	~i_cpu_prsnt_n[1] & (~grp_c_p1_fault_det			 | keep_alive_on_fault )	;
assign grp_d_p0_vddio_en	        =	reg_grp_d_vddio_en		&	~i_cpu_prsnt_n[0] & (~grp_d_vddio_p0_fault_det 	 | keep_alive_on_fault )	;
assign grp_d_p1_vddio_en	        =	reg_grp_d_vddio_en		&	~i_cpu_prsnt_n[1] & (~grp_d_vddio_p1_fault_det 	 | keep_alive_on_fault )	;
assign grp_d_p0_soc_en		=	reg_grp_d_soc_en		&	~i_cpu_prsnt_n[0] & (~grp_d_soc_p0_fault_det		 | keep_alive_on_fault )	;
assign grp_d_p1_soc_en		=	reg_grp_d_soc_en		&	~i_cpu_prsnt_n[1] & (~grp_d_soc_p1_fault_det		 | keep_alive_on_fault )	;
assign grp_d_p0_vddcore0_en	=	reg_grp_d_vddcore0_en	&	~i_cpu_prsnt_n[0] & (~grp_d_p0_vddcore0_fault_det | keep_alive_on_fault )	;
assign grp_d_p1_vddcore0_en	=	reg_grp_d_vddcore0_en	&	~i_cpu_prsnt_n[1] & (~grp_d_p1_vddcore0_fault_det | keep_alive_on_fault )	;
assign grp_d_p0_vddcore1_en	=	reg_grp_d_vddcore1_en	&	~i_cpu_prsnt_n[0] & (~grp_d_p0_vddcore1_fault_det | keep_alive_on_fault )	;
assign grp_d_p1_vddcore1_en	=	reg_grp_d_vddcore1_en	&	~i_cpu_prsnt_n[1] & (~grp_d_p1_vddcore1_fault_det | keep_alive_on_fault )	;

assign ocp_aux_en			=	reg_ocp_aux_en	;
assign ocp_main_en			=	reg_ocp_main_en	;

// assign tpcm_reset_n			=	reg_tpcm_reset_n	;
// assign usb_ponrst_r_n		=	reg_usb_ponrst_r_n	;

assign o_cpu_pwrok			=	reg_pwrok				;
assign o_p0_pwr_good		        =	reg_cpu_pwrgood			;
assign o_rsmrst_n			=	reg_rsmrst_l			;

assign s5dev_pwren_request	= reg_s5dev_pwren_request;    	
assign s5dev_pwrdis_request   = 1'b0;  

//------------------------------------------------------------------------------
// Reset and SM states
// - The st_* stuff are just convenience variable that can be used throughout.
//------------------------------------------------------------------------------
assign  st_reset_state                  = (power_seq_sm == SM_RESET_STATE              );
assign  st_off_standby                  = (power_seq_sm == SM_OFF_STANDBY              );
assign  st_en_telem                        = (power_seq_sm == SM_EN_TELEM                    );
assign  st_en_main_efuse              = (power_seq_sm == SM_EN_MAIN_EFUSE          );
assign  st_en_grp_atx                    = (power_seq_sm == SM_EN_GRP_ATX                );
assign  st_en_grp_c                        = (power_seq_sm == SM_EN_GRP_C                    );
assign  st_en_grp_d_vddio            = (power_seq_sm == SM_EN_GRP_D_VDDIO        );
assign  st_en_grp_d_vddcore0      = (power_seq_sm == SM_EN_GRP_D_VDDCORE0  );
assign  st_en_grp_d_vddcore1      = (power_seq_sm == SM_EN_GRP_D_VDDCORE1  );
assign  st_wait_powerok                = (power_seq_sm == SM_WAIT_POWEROK            );
assign  st_steady_pwrok                = (power_seq_sm == SM_STEADY_PWROK            );
assign  st_critical_fail              = (power_seq_sm == SM_CRITICAL_FAIL          );
assign  st_disable_main_efuse    = (power_seq_sm == SM_DISABLE_MAIN_EFUSE);
assign  st_halt_power_cycle        = (power_seq_sm == SM_HALT_POWER_CYCLE    );
assign  st_aux_fail_recovery      = (power_seq_sm == SM_AUX_FAIL_RECOVERY  );

/*******************************************************************************
//------------------------------------------------------------------------------
// State Machine action  Start
//------------------------------------------------------------------------------
********************************************************************************/
always @(posedge clk or posedge reset) begin
  if (reset) begin
              reg_rsmrst_l				<= 1'b0;
              reg_p5v_stby_en			<= 1'b0;
              reg_p5v_stby_usb_en		<= 1'b0;  
              reg_grp_b_33_s5_en		<= 1'b0;
              reg_grp_b_18_s5_en		<= 1'b0;
              reg_power_supply_on		<= 1'b0;
              reg_p5v_en				<= 1'b0;
              reg_grp_c_en				<= 1'b0;
              reg_grp_d_vddio_en		<= 1'b0;
              reg_grp_d_soc_en			<= 1'b0;
              reg_grp_d_vddcore0_en	<= 1'b0;
              reg_grp_d_vddcore1_en	<= 1'b0;
              reg_cpu_pwrgood			<= 1'b0;	
              reached_sm_wait_powerok	<= 1'b0;
              reg_pwrok				<= 2'b0;
              reg_s5dev_pwren_request	<= 1'b1;
              // reg_p12_en_dimm			<= 1'b0;  
  end
  else if (t1us) begin
    case (power_seq_sm)
      SM_RESET_STATE : begin
              reg_rsmrst_l				<= 1'b0;
              reg_p5v_stby_en			<= 1'b0;
              reg_p5v_stby_usb_en		<= 1'b0;
              reg_grp_b_33_s5_en		<= 1'b0;
              reg_grp_b_18_s5_en		<= 1'b0;
              reg_power_supply_on		<= 1'b0;
              reg_p5v_en				<= 1'b0;
              reg_grp_c_en				<= 1'b0;
              reg_grp_d_vddio_en		<= 1'b0;
              reg_grp_d_soc_en			<= 1'b0;
              reg_grp_d_vddcore0_en	<= 1'b0;
              reg_grp_d_vddcore1_en	<= 1'b0;
              reg_cpu_pwrgood			<= 1'b0;
              reached_sm_wait_powerok	<= 1'b0;
              reg_pwrok				<= 2'b0;
              reg_ocp_aux_en			<= 1'b0;
              reg_ocp_main_en		        <= 1'b0;
              // reg_usb_ponrst_r_n		<= 1'b0;
              // reg_tpcm_reset_n	   		<= 1'b0;
              reg_s5dev_pwren_request	<= 1'b1;
              // reg_p12_en_dimm			<= 1'b0;  
      end
      SM_EN_GRP_A : begin
      //no action execution 
            reg_p5v_stby_en        <= 1'b1; 
            // reg_p12_en_dimm        <= 1'b1;  //20220713 d00412
      end
      
      SM_RSMRST_DISABLE : begin
            reg_rsmrst_l      	   <= 1'b0;
            reg_s5dev_pwren_request	<= 1'b1;
      end	
      
      SM_EN_P5V_STBY : begin
            reg_p5v_stby_usb_en    <= 1'b1;
      end	  
      
      SM_EN_GRP_B_33_S5 : begin
            reg_grp_b_33_s5_en		<= 1'b1; 
      end
      
      SM_EN_GRP_B_18_S5 : begin
            reg_grp_b_18_s5_en		<= 1'b1;   
      end
      
      SM_EN_RSMRST_RELEASE : begin
            reg_rsmrst_l           <= 1'b1;
      end
      
      SM_ENABLE_S5_DEVICES : begin
	//no action execution
            reg_ocp_aux_en			<= 1'b1;
            reg_s5dev_pwren_request	<= 1'b0;
      end	  
      
      SM_OFF_STANDBY: begin
        //no action execution
            // reg_usb_ponrst_r_n	    <= 1'b1;
            // reg_tpcm_reset_n		    <= 1'b1;
            reg_p5v_stby_en                  <= 1'b1;
            reg_p5v_stby_usb_en          <= 1'b1;
            reg_grp_b_33_s5_en	    <= 1'b1;
            reg_grp_b_18_s5_en	    <= 1'b1;
            reg_rsmrst_l                        <= 1'b1;
            reg_s5dev_pwren_request  <= 1'b0;
            reg_ocp_aux_en		    <= 1'b1;
            // reg_p12_en_dimm                  <= 1'b1;
      end	 
      
      SM_PS_ON : begin
        //no action execution
		// reg_usb_ponrst_r_n <= 1'b1;
      end
      
      SM_EN_TELEM : begin
        //reg_pal_pvcc_hpmos_sw_r  <=1'b1;
		//no action execution
		// for drmos power enable 
      end
      
      SM_EN_MAIN_EFUSE : begin
            reg_power_supply_on    	   <= 1'b1;
            reg_ocp_main_en		       <= 1'b1;
      end	
      
      SM_EN_GRP_ATX : begin
	  //for CMU P3V3 & MB P3V3
            reg_p5v_en              <= 1'b1;  
      end
      
      SM_EN_GRP_C : begin
            reg_grp_c_en			<= 1'b1;  
      end
      
      SM_EN_GRP_D_VDDIO : begin
            reg_grp_d_vddio_en		<= 1'b1;  
      end	  
      
      SM_EN_GRP_D_SOC : begin
            reg_grp_d_soc_en		<= 1'b1;
      end	
  	  
      SM_EN_GRP_D_VDDCORE0 : begin
            reg_grp_d_vddcore0_en	<= 1'b1;  
      end	
      
      SM_EN_GRP_D_VDDCORE1 : begin
            reg_grp_d_vddcore1_en	<= 1'b1;  
      end	
      
      SM_EN_PGOOD_RELEASE : begin
            reg_cpu_pwrgood <= 1'b1;
      end
      
      SM_WAIT_POWEROK : begin
            reached_sm_wait_powerok <= 1'b1;  
            reg_pwrok 				<= 1'b1;
      end	  
      
      SM_STEADY_PWROK :begin
	  //no action execution
            reg_power_supply_on    	       <= 1'b1;
            reg_ocp_main_en		       <= 1'b1;	  
            reg_p5v_en                             <= 1'b1;
            reg_grp_c_en			       <= 1'b1;
            reg_grp_d_vddio_en	       <= 1'b1;
            reg_grp_d_soc_en		       <= 1'b1; 		
            reg_grp_d_vddcore0_en	       <= 1'b1;
            reg_grp_d_vddcore1_en	       <= 1'b1;
            reg_cpu_pwrgood                     <= 1'b1;
            reached_sm_wait_powerok     <= 1'b1;  
            reg_pwrok 				       <= 1'b1;
            reg_p5v_stby_en                     <= 1'b1;
            reg_p5v_stby_usb_en             <= 1'b1;
            reg_grp_b_33_s5_en	       <= 1'b1;		
            reg_grp_b_18_s5_en	       <= 1'b1;
            reg_rsmrst_l                           <= 1'b1;
            reg_s5dev_pwren_request     <= 1'b0;
            // reg_usb_ponrst_r_n		   <= 1'b1;
            // reg_tpcm_reset_n		   <= 1'b1;
            reg_ocp_aux_en		       <= 1'b1;
            // reg_p12_en_dimm            <= 1'b1; 
	  end
      
      SM_CRITICAL_FAIL : begin
      //no action execution
      end
      
      SM_DISABLE_PWRGD : begin
            reg_cpu_pwrgood <= 1'b0;
            reached_sm_wait_powerok <= 1'b0;
            reg_pwrok 		<= 1'b0;
            reg_ocp_main_en	<= 1'b0;
      end
      
      SM_DISABLE_GRP_D_VDDCORE1 : begin
            reg_grp_d_vddcore1_en	<= 1'b0;  
      end	

      SM_DISABLE_GRP_D_VDDCORE0 : begin
            reg_grp_d_vddcore0_en	<= 1'b0;  
      end	
       
      SM_DISABLE_GRP_D_SOC : begin
            reg_grp_d_soc_en	<= 1'b0;  
      end		 
       
      SM_DISABLE_GRP_D_VDDIO : begin
            reg_grp_d_vddio_en	<= 1'b0;  
      end		 
	 
      SM_DISABLE_GRP_C : begin
            reg_grp_c_en	<= 1'b0;  
      end	
	  
      SM_DISABLE_GRP_ATX : begin
            reg_p5v_en              <= 1'b0;
        // reg_usb_ponrst_r_n       <= 1'b0;		
      end
	  
      SM_DISABLE_MAIN_EFUSE : begin
            reg_power_supply_on      <= 1'b0;
		//reg_ocp_main_en		     <= 1'b0;
      end

      SM_DISABLE_TELEM : begin
	  //no action execution
      end

      SM_DISABLE_PS_ON : begin
      //no action execution
      end

      SM_AUX_FAIL_RECOVERY : begin
      //no action execution
      end
	  
      SM_HALT_POWER_CYCLE : begin
	  //no action execution
      end
	  
      SM_DISABLE_S5_DEVICES : begin
	  //no action execution
	  reg_p5v_stby_usb_en <= 1'b0;
      end
	  
      default : begin
	  reg_rsmrst_l				<= 1'b0;
	  reg_p5v_stby_en			<= 1'b0;
	  reg_p5v_stby_usb_en		<= 1'b0;
	  reg_grp_b_33_s5_en		        <= 1'b0;
	  reg_grp_b_18_s5_en		        <= 1'b0;
	  reg_power_supply_on		<= 1'b0;
	  reg_ocp_aux_en			        <= 1'b0;
	  reg_ocp_main_en		        <= 1'b0;
	  reg_p5v_en				<= 1'b0;
	  reg_grp_c_en				<= 1'b0;
	  reg_grp_d_vddio_en		        <= 1'b0;
	  reg_grp_d_soc_en			<= 1'b0;
	  reg_grp_d_vddcore0_en		<= 1'b0;
	  reg_grp_d_vddcore1_en		<= 1'b0;
	  reg_cpu_pwrgood			<= 1'b0;	
	  reached_sm_wait_powerok	<= 1'b0;
	  reg_pwrok					<= 2'b0;
	  // reg_usb_ponrst_r_n		<= 1'b0;
	  // reg_tpcm_reset_n			<= 1'b0;
	  reg_s5dev_pwren_request	<= 1'b1;
	  // reg_p12_en_dimm			<= 1'b0;  
      end
    endcase
  end
end
/*******************************************************************************
//------------------------------------------------------------------------------
// State Machine action  End
//------------------------------------------------------------------------------
********************************************************************************/

/*******************************************************************************
//------------------------------------------------------------------------------
// Fault Detect Start
//------------------------------------------------------------------------------
********************************************************************************/
//Fault Flag
wire [FAULT_VEC_SIZE-1:0] fault_vec;
wire [FAULT_VEC_SIZE-1:0] any_recov_fault_vec;
wire [FAULT_VEC_SIZE-1:0] any_lim_recov_fault_vec;
wire [FAULT_VEC_SIZE-1:0] any_non_recov_fault_vec;
wire any_recov_fault_c;
wire any_lim_recov_fault_c;
wire any_non_recov_fault_c;
wire aux_fault;

assign any_aux_vrm_fault = aux_fault;

//------------------------------------------------------------------------------
// P5V_STBY Fault detect 
//------------------------------------------------------------------------------
wire p5v_stby_en_check;

edge_delay #(.CNTR_NBITS(2)) p5v_stby_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (p5v_stby_en),
  .delay_output  (p5v_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p5v_stby_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (p5v_stby_en && p5v_stby_en_check),	//in
  .vrm_pgood        (p5v_stby_pg),						//in
  .vrm_chklive_en   (p5v_stby_en_check),				//in
  .vrm_chklive_dis  (~p5v_stby_en_check),				//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (aux_fault),						//out
  .vrm_fault        (p5v_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// P3V3 Fault detect 
//------------------------------------------------------------------------------
wire p5v_en_check;

edge_delay #(.CNTR_NBITS(2)) p5v_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (p5v_en),
  .delay_output  (p5v_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p5v_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (p5v_en && p5v_en_check),			//in
  .vrm_pgood        (p5v_pg),							//in
  .vrm_chklive_en   (p5v_en_check),					//in
  .vrm_chklive_dis  (~p5v_en_check),					//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (p5v_fault_det)					//out
);

//------------------------------------------------------------------------------
// P12V Fault detect 
//------------------------------------------------------------------------------
// wire power_supply_on_check;

// edge_delay #(.CNTR_NBITS(2)) power_supply_on_check_inst (
  // .clk           (clk),
  // .reset         (reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (t64ms),
  // .signal_in     (power_supply_on),
  // .delay_output  (power_supply_on_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p12v_efuse_fault_detect_inst (
  // .clk              (clk),								//in
  // .reset            (reset),							//in
  // .vrm_enable       (power_supply_on && power_supply_on_check),			//in
  // .vrm_pgood        (p12v_efuse_pg),							//in
  // .vrm_chklive_en   (power_supply_on_check),					//in
  // .vrm_chklive_dis  (~power_supply_on_check),					//in
  // .critical_fail    (st_critical_fail),							//in
  // .fault_clear      (fault_clear),								//in
  // .lock             (any_pwr_fault_det),						//in
  // .any_vrm_fault    (),											//out
  // .vrm_fault        (p12v_efuse_fault_det)						//out
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p12v_ssd_efuse_fault_detect_inst (
  // .clk              (clk),								//in
  // .reset            (reset),							//in
  // .vrm_enable       (power_supply_on && power_supply_on_check),		//in
  // .vrm_pgood        (p12v_ssd_efuse_pg),							//in
  // .vrm_chklive_en   (power_supply_on_check),						//in
  // .vrm_chklive_dis  (~power_supply_on_check),						//in
  // .critical_fail    (st_critical_fail),								//in
  // .fault_clear      (fault_clear),									//in
  // .lock             (any_pwr_fault_det),							//in
  // .any_vrm_fault    (),												//out
  // .vrm_fault        (p12v_ssd_efuse_fault_det)						//out
// );

// wire p12_en_p0_dimm_check;
// wire p12_en_p0_dimm;
// wire p12_en_p1_dimm;
// edge_delay #(.CNTR_NBITS(2)) p12_en_p0_dimm_check_inst (
  // .clk           (clk),
  // .reset         (reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (t64ms),
  // .signal_in     (p12_en_p0_dimm),
  // .delay_output  (p12_en_p0_dimm_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p12v_p0_dimm_fault_detect_inst (
  // .clk              (clk),								//in
  // .reset            (reset),							//in
  // .vrm_enable       (p12_en_p0_dimm && p12_en_p0_dimm_check),		//in
  // .vrm_pgood        (p12v_p0_dimm_pg),								//in
  // .vrm_chklive_en   (p12_en_p0_dimm_check),							//in
  // .vrm_chklive_dis  (~p12_en_p0_dimm_check),						//in
  // .critical_fail    (st_critical_fail),								//in
  // .fault_clear      (fault_clear),									//in
  // .lock             (any_pwr_fault_det),							//in
  // .any_vrm_fault    (),												//out
  // .vrm_fault        (p12v_p0_dimm_fault_det)						//out
// );

// assign p12_en_p0_dimm = (pcb_id == `VERSION_C ) ? p12_en_p0_dimm_1 : p12_en_p0_dimm_2;
// assign p12_en_p1_dimm = (pcb_id == `VERSION_C ) ? p12_en_p1_dimm_1 : p12_en_p1_dimm_2;
// assign p12_en_p0_dimm =  p12_en_p0_dimm_1 ;
// assign p12_en_p1_dimm =  p12_en_p1_dimm_1 ;

// wire p12_en_p1_dimm_check;

// edge_delay #(.CNTR_NBITS(2)) p12_en_p1_dimm_check_inst (
  // .clk           (clk),
  // .reset         (reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (t64ms),
  // .signal_in     (p12_en_p1_dimm),
  // .delay_output  (p12_en_p1_dimm_check)
// );
// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p12v_p1_dimm_fault_detect_inst (
  // .clk              (clk),								//in
  // .reset            (reset),							//in
  // .vrm_enable       (p12_en_p1_dimm && p12_en_p1_dimm_check),		//in
  // .vrm_pgood        (p12v_p1_dimm_pg),								//in
  // .vrm_chklive_en   (p12_en_p1_dimm_check),							//in
  // .vrm_chklive_dis  (~p12_en_p1_dimm_check),						//in
  // .critical_fail    (st_critical_fail),								//in
  // .fault_clear      (fault_clear),									//in
  // .lock             (any_pwr_fault_det),							//in
  // .any_vrm_fault    (),												//out
  // .vrm_fault        (p12v_p1_dimm_fault_det)						//out
// );

//------------------------------------------------------------------------------
// P0_VDD_18_S5 & P1_VDD_18_S5 Fault detect 
//------------------------------------------------------------------------------
wire grp_b_p0_18_s5_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_b_p0_18_s5_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_b_p0_18_s5_en),
  .delay_output  (grp_b_p0_18_s5_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_b_p0_18_s5_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_b_p0_18_s5_en && grp_b_p0_18_s5_en_check),	//in
  .vrm_pgood        (grp_b_p0_18_s5_pg),						//in
  .vrm_chklive_en   (grp_b_p0_18_s5_en_check),					//in
  .vrm_chklive_dis  (~grp_b_p0_18_s5_en_check),					//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_b_p0_18_s5_fault_det)			//out
);

wire grp_b_p1_18_s5_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_b_p1_18_s5_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_b_p1_18_s5_en),
  .delay_output  (grp_b_p1_18_s5_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_b_p1_18_s5_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_b_p1_18_s5_en && grp_b_p1_18_s5_en_check),	//in
  .vrm_pgood        (grp_b_p1_18_s5_pg),						//in
  .vrm_chklive_en   (grp_b_p1_18_s5_en_check),						//in
  .vrm_chklive_dis  (~grp_b_p1_18_s5_en_check),					//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_b_p1_18_s5_fault_det)			//out
);

//------------------------------------------------------------------------------
// P0_VDD_33_S5 & P1_VDD_33_S5 Fault detect 
//------------------------------------------------------------------------------
wire grp_b_p0_33_s5_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_b_p0_33_s5_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_b_p0_33_s5_en),
  .delay_output  (grp_b_p0_33_s5_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_b_p0_33_s5_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_b_p0_33_s5_en && grp_b_p0_33_s5_en_check),	//in
  .vrm_pgood        (grp_b_p0_33_s5_pg),						//in
  .vrm_chklive_en   (grp_b_p0_33_s5_en_check),						//in
  .vrm_chklive_dis  (~grp_b_p0_33_s5_en_check),					//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_b_p0_33_s5_fault_det)			//out
);

wire grp_b_p1_33_s5_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_b_p1_33_s5_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_b_p1_33_s5_en),
  .delay_output  (grp_b_p1_33_s5_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_b_p1_33_s5_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_b_p1_33_s5_en && grp_b_p1_33_s5_en_check),	//in
  .vrm_pgood        (grp_b_p1_33_s5_pg),							//in
  .vrm_chklive_en   (grp_b_p1_33_s5_en_check),						//in
  .vrm_chklive_dis  (~grp_b_p1_33_s5_en_check),						//in
  .critical_fail    (st_critical_fail),								//in
  .fault_clear      (fault_clear),									//in
  .lock             (any_pwr_fault_det),							//in
  .any_vrm_fault    (),												//out
  .vrm_fault        (grp_b_p1_33_s5_fault_det)						//out
);

//------------------------------------------------------------------------------
// P0_VDD_11_SUS & P1_VDD_11_SUS Fault detect 
//------------------------------------------------------------------------------
wire grp_c_p0_vdd11_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_c_p0_vdd11_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_c_p0_vdd11_en),
  .delay_output  (grp_c_p0_vdd11_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_c_p0_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_c_p0_vdd11_en && grp_c_p0_vdd11_en_check),	//in
  .vrm_pgood        (grp_c_p0_pg),						//in
  .vrm_chklive_en   (grp_c_p0_vdd11_en_check),			//in
  .vrm_chklive_dis  (~grp_c_p0_vdd11_en_check),			//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_c_p0_fault_det)				//out
);

wire grp_c_p1_vdd11_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_c_p1_vdd11_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_c_p1_vdd11_en),
  .delay_output  (grp_c_p1_vdd11_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_c_p1_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_c_p1_vdd11_en && grp_c_p1_vdd11_en_check),	//in
  .vrm_pgood        (grp_c_p1_pg),						//in
  .vrm_chklive_en   (grp_c_p1_vdd11_en_check),			//in
  .vrm_chklive_dis  (~grp_c_p1_vdd11_en_check),			//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_c_p1_fault_det)				//out
);

//------------------------------------------------------------------------------
// P0_VDDIO & P1_VDDIO Fault detect 
//------------------------------------------------------------------------------
wire grp_d_p0_vddio_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p0_vddio_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p0_vddio_en),
  .delay_output  (grp_d_p0_vddio_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_vddio_p0_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p0_vddio_en && grp_d_p0_vddio_en_check),	//in
  .vrm_pgood        (grp_d_vddio_p0_pg),							//in
  .vrm_chklive_en   (grp_d_p0_vddio_en_check),			//in
  .vrm_chklive_dis  (~grp_d_p0_vddio_en_check),			//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_d_vddio_p0_fault_det)			//out
);

wire grp_d_p1_vddio_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p1_vddio_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p1_vddio_en),
  .delay_output  (grp_d_p1_vddio_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_vddio_p1_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p1_vddio_en && grp_d_p1_vddio_en_check),	//in
  .vrm_pgood        (grp_d_vddio_p1_pg),							//in
  .vrm_chklive_en   (grp_d_p1_vddio_en_check),			//in
  .vrm_chklive_dis  (~grp_d_p1_vddio_en_check),			//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_d_vddio_p1_fault_det)			//out
);

//------------------------------------------------------------------------------
// P0_VDD_SOC & P1_VDD_SOC Fault detect 
//------------------------------------------------------------------------------
wire grp_d_p0_soc_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p0_soc_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p0_soc_en),
  .delay_output  (grp_d_p0_soc_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_soc_p0_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p0_soc_en && grp_d_p0_soc_en_check),	//in
  .vrm_pgood        (grp_d_soc_p0_pg),						//in
  .vrm_chklive_en   (grp_d_p0_soc_en_check),				//in
  .vrm_chklive_dis  (~grp_d_p0_soc_en_check),				//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_d_soc_p0_fault_det)			//out
);

wire grp_d_p1_soc_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p1_soc_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p1_soc_en),
  .delay_output  (grp_d_p1_soc_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_soc_p1_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p1_soc_en && grp_d_p1_soc_en_check),	//in
  .vrm_pgood        (grp_d_soc_p1_pg),						//in
  .vrm_chklive_en   (grp_d_p1_soc_en_check),				//in
  .vrm_chklive_dis  (~grp_d_p1_soc_en_check),				//in
  .critical_fail    (st_critical_fail),					//in
  .fault_clear      (fault_clear),						//in
  .lock             (any_pwr_fault_det),				//in
  .any_vrm_fault    (),									//out
  .vrm_fault        (grp_d_soc_p1_fault_det)			//out
);

//------------------------------------------------------------------------------
// P0_VDD_CORE_0 & P1_VDD_CORE_0 Fault detect 
//------------------------------------------------------------------------------
wire grp_d_p0_vddcore0_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p0_vddcore0_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p0_vddcore0_en),
  .delay_output  (grp_d_p0_vddcore0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_p0_vddcore0_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p0_vddcore0_en && grp_d_p0_vddcore0_en_check),	//in
  .vrm_pgood        (grp_d_p0_vddcore0_pg),							//in
  .vrm_chklive_en   (grp_d_p0_vddcore0_en_check),				//in
  .vrm_chklive_dis  (~grp_d_p0_vddcore0_en_check),				//in
  .critical_fail    (st_critical_fail),						//in
  .fault_clear      (fault_clear),							//in
  .lock             (any_pwr_fault_det),					//in
  .any_vrm_fault    (),										//out
  .vrm_fault        (grp_d_p0_vddcore0_fault_det)			//out
);

wire grp_d_p1_vddcore0_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p1_vddcore0_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p1_vddcore0_en),
  .delay_output  (grp_d_p1_vddcore0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_p1_vddcore0_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p1_vddcore0_en && grp_d_p1_vddcore0_en_check),	//in
  .vrm_pgood        (grp_d_p1_vddcore0_pg),						//in
  .vrm_chklive_en   (grp_d_p1_vddcore0_en_check),				//in
  .vrm_chklive_dis  (~grp_d_p1_vddcore0_en_check),				//in
  .critical_fail    (st_critical_fail),						//in
  .fault_clear      (fault_clear),							//in
  .lock             (any_pwr_fault_det),					//in
  .any_vrm_fault    (),										//out
  .vrm_fault        (grp_d_p1_vddcore0_fault_det)			//out
);

//------------------------------------------------------------------------------
// P0_VDD_CORE_1 & P1_VDD_CORE_1 Fault detect 
//------------------------------------------------------------------------------
wire grp_d_p0_vddcore1_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p0_vddcore1_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p0_vddcore1_en),
  .delay_output  (grp_d_p0_vddcore1_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_p0_vddcore1_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p0_vddcore1_en && grp_d_p0_vddcore1_en_check),	//in
  .vrm_pgood        (grp_d_p0_vddcore1_pg),							//in
  .vrm_chklive_en   (grp_d_p0_vddcore1_en_check),				//in
  .vrm_chklive_dis  (~grp_d_p0_vddcore1_en_check),				//in
  .critical_fail    (st_critical_fail),						//in
  .fault_clear      (fault_clear),							//in
  .lock             (any_pwr_fault_det),					//in
  .any_vrm_fault    (),										//out
  .vrm_fault        (grp_d_p0_vddcore1_fault_det)			//out
);

wire grp_d_p1_vddcore1_en_check;

edge_delay #(.CNTR_NBITS(2)) grp_d_p1_vddcore1_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (grp_d_p1_vddcore1_en),
  .delay_output  (grp_d_p1_vddcore1_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) grp_d_p1_vddcore1_fault_detect_inst (
  .clk              (clk),								//in
  .reset            (reset),							//in
  .vrm_enable       (grp_d_p1_vddcore1_en && grp_d_p1_vddcore1_en_check),	//in
  .vrm_pgood        (grp_d_p1_vddcore1_pg),							//in
  .vrm_chklive_en   (grp_d_p1_vddcore1_en_check),				//in
  .vrm_chklive_dis  (~grp_d_p1_vddcore1_en_check),				//in
  .critical_fail    (st_critical_fail),						//in
  .fault_clear      (fault_clear),							//in
  .lock             (any_pwr_fault_det),					//in
  .any_vrm_fault    (),										//out
  .vrm_fault        (grp_d_p1_vddcore1_fault_det)			//out
);

//------------------------------------------------------------------------------
// Stby_Power  Fault detect 
//------------------------------------------------------------------------------
//p3v3_stby
wire   p3v3_stby_en;
wire   p3v3_stby_en_check;
assign p3v3_stby_en = 1'b1;
edge_delay #(.CNTR_NBITS(2)) p3v3_stby_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (p3v3_stby_en),
  .delay_output  (p3v3_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p3v3_stby_fault_detect_inst (
  .clk              (clk  ),							 //in
  .reset            (reset),							 //in
  .vrm_enable       (p3v3_stby_en && p3v3_stby_en_check),//in
  .vrm_pgood        (p3v3_stby_pg                      ),//in
  .vrm_chklive_en   (p3v3_stby_en_check                ),//in
  .vrm_chklive_dis  (~p3v3_stby_en_check               ),//in
  .critical_fail    (st_critical_fail                  ),//in
  .fault_clear      (fault_clear                       ),//in
  .lock             (any_pwr_fault_det                 ),//in
  .any_vrm_fault    (),								     //out
  .vrm_fault        (p3v3_stby_fault_det               ) //out
);
//p12v_stby
// wire   p12v_stby_en;
// wire   p12v_stby_en_check;
// assign p12v_stby_en = 1'b1;
// edge_delay #(.CNTR_NBITS(2)) p12v_stby_en_check_inst (
  // .clk           (clk),
  // .reset         (reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (t64ms),
  // .signal_in     (p12v_stby_en),
  // .delay_output  (p12v_stby_en_check)
// );
// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p12v_stby_fault_detect_inst (
  // .clk              (clk  ),							 //in
  // .reset            (reset),							 //in
  // .vrm_enable       (p12v_stby_en && p12v_stby_en_check),//in
  // .vrm_pgood        (p12v_stby_pg                      ),//in
  // .vrm_chklive_en   (p12v_stby_en_check                ),//in
  // .vrm_chklive_dis  (~p12v_stby_en_check               ),//in
  // .critical_fail    (st_critical_fail                  ),//in
  // .fault_clear      (fault_clear                       ),//in
  // .lock             (any_pwr_fault_det                 ),//in
  // .any_vrm_fault    (),								     //out
  // .vrm_fault        (p12v_stby_fault_det               )  //out
// );

assign fault_vec[0]    = p5v_stby_fault_det         ;
assign fault_vec[1]    = 1'b0;//p5v_stby_usb0_fault_det   ; 
assign fault_vec[2]    = 1'b0;//p5v_stby_usb1_fault_det   ; 
assign fault_vec[3]    = 1'b0;
assign fault_vec[4]    = p5v_fault_det             ;
assign fault_vec[5]    = 1'b0;//p12v_efuse_fault_det       ;  
assign fault_vec[6]    = 1'b0;//p12v_ssd_efuse_fault_det   ;
assign fault_vec[7]    = 1'b0;//p12v_p0_dimm_fault_det     ;
assign fault_vec[8]    = 1'b0;//p12v_p1_dimm_fault_det     ;
assign fault_vec[9]    = grp_b_p0_18_s5_fault_det   ;
assign fault_vec[10]   = grp_b_p1_18_s5_fault_det   ;
assign fault_vec[11]   = grp_b_p0_33_s5_fault_det   ;
assign fault_vec[12]   = grp_b_p1_33_s5_fault_det   ;
assign fault_vec[13]   = grp_c_p0_fault_det         ;
assign fault_vec[14]   = grp_c_p1_fault_det         ;
assign fault_vec[15]   = grp_d_vddio_p0_fault_det   ;
assign fault_vec[16]   = grp_d_vddio_p1_fault_det   ;
assign fault_vec[17]   = grp_d_soc_p0_fault_det     ;   
assign fault_vec[18]   = grp_d_soc_p1_fault_det     ;
assign fault_vec[19]   = grp_d_p0_vddcore0_fault_det;
assign fault_vec[20]   = grp_d_p1_vddcore0_fault_det;
assign fault_vec[21]   = grp_d_p0_vddcore1_fault_det;
assign fault_vec[22]   = grp_d_p1_vddcore1_fault_det;
assign fault_vec[23]   = p3v3_stby_fault_det        ;		
assign fault_vec[24]   = 1'b0;//p12v_stby_fault_det        ;	
assign fault_vec[39:25]= 0;   // Reserved for future power rails


genvar i;
// Mask each fault with the corresponding bits
generate    
    for (i = 0; i < FAULT_VEC_SIZE; i = i + 1) begin : _fault_vec_block_
        assign any_recov_fault_vec[i]     = fault_vec[i] & RECOV_FAULT_MASK[i];
        assign any_lim_recov_fault_vec[i] = fault_vec[i] & LIM_RECOV_FAULT_MASK[i];
        assign any_non_recov_fault_vec[i] = fault_vec[i] & NON_RECOV_FAULT_MASK[i];
    end
endgenerate

assign any_recov_fault_c     = |any_recov_fault_vec;
assign any_lim_recov_fault_c = |any_lim_recov_fault_vec;
assign any_non_recov_fault_c = |any_non_recov_fault_vec;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    any_pwr_fault_det     <= 1'b0;
    any_recov_fault         <= 1'b0;
    any_lim_recov_fault <= 1'b0;
    any_non_recov_fault <= 1'b0;
  end
  else begin
    any_pwr_fault_det   <= any_recov_fault_c | any_lim_recov_fault_c | any_non_recov_fault_c;
    any_recov_fault     <= any_recov_fault_c;
    any_lim_recov_fault <= any_lim_recov_fault_c;
    any_non_recov_fault <= any_non_recov_fault_c;
  end
end
/*******************************************************************************
//------------------------------------------------------------------------------
// Fault Detect End
//------------------------------------------------------------------------------
********************************************************************************/

//------------------------------------------------------------------------------
// pwrseq_sm_fault_det
// - Stores the power sequencer state where a power fault was detected.
//------------------------------------------------------------------------------
reg  fault_save_en;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    fault_save_en             <= 1'b1;
    pwrseq_sm_fault_det <= 6'b0;
  end
  else if (t1us && fault_clear) begin
    fault_save_en             <= 1'b1;
    pwrseq_sm_fault_det <= 6'b0;
  end
  else if (t1us && st_critical_fail)
    fault_save_en       <= 1'b0;
  else if (t1us && fault_save_en)
    pwrseq_sm_fault_det <= power_seq_sm;
end

//------------------------------------------------------------------------------
// pgd_so_far
// - Reflects current status of power rail pgood signal qualified by their
//   respective enable signal. This signal is used by pwrseq_master.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    pgd_so_far <= 1'b0;
  else
    pgd_so_far <= 1'b1;
end

endmodule