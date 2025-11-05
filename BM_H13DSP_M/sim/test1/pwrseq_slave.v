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
`include "pwrseq_define.v"
module pwrseq_slave #(
  parameter SHARED_P5V_STBY_HPMOS       = 1'b0,  // 5V待机电源是否共享高压MOS管（1=共享，0=独立）
  parameter S5DEV_STUCKON_FAULT_CHK     = 1'b0,  // S5状态设备是否检测“卡死故障”（1=使能检测，0=禁用）
  parameter BOUND_SYS_PWROK             = 1'b1,  // 是否绑定系统PWROK信号（1=绑定，确保与系统状态同步）
  parameter NUM_CPU                     = 2,     // 支持的CPU数量（此处为2路CPU设计）
  parameter NUM_OPT_AUX                 = 0,     // 可选辅助设备数量（如额外风扇，0=无）
  parameter NUM_S5DEV                   = 0,     // S5状态下需供电的设备数量（如BMC，0=无）
  parameter NUM_SAS                     = 0,     // SAS硬盘数量（0=无，用于硬盘电源控制）
  parameter NUM_HD_BP                   = 0,     // 硬盘背板数量（0=无）
  parameter NUM_M2_BP                   = 0,     // M.2背板数量（0=无）
  parameter NUM_RISER                   = 0,     // 扩展卡 riser 数量（0=无）
  parameter NUM_MEZZ                    = 0,     // 夹层卡数量（0=无）
//parameter   [NUM_CPU-1:0] HPMOS_TYPE  = 2'b10,
//parameter [2*NUM_CPU-1:0] HPMOS_OWNER = 4'b00_00,
  parameter FAULT_VEC_SIZE              = 40,    // 故障向量位数（需覆盖所有监测的电源通道，此处40位足够）
  // bit location guide for mask below                      3         3         2         1
  //                                                        9         1         3         5         7
  // 故障等级掩码：按bit位划分故障可恢复性（1=对应bit故障属于该等级）
  parameter [FAULT_VEC_SIZE-1:0] RECOV_FAULT_MASK     = 40'b0000_1111_1111_0000_0000_0000_0000_0000_0000_0000,  // 可恢复故障（如临时电压波动，重启可恢复）
  parameter [FAULT_VEC_SIZE-1:0] LIM_RECOV_FAULT_MASK = 40'b0011_0000_0000_1111_1111_1111_1111_1111_1111_1001,  // 有限可恢复故障（如多次波动后需硬件检查）
  parameter [FAULT_VEC_SIZE-1:0] NON_RECOV_FAULT_MASK = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) // 不可恢复故障（如短路，需更换硬件）
(

//base signal  Clocks and resets
  input     wire    clk          ,       // clock
  input     wire    reset      ,       // reset
  input     wire    t1us        ,       // 10ns pulse every 1us
  input     wire    t512us    ,       // 10ns pulse every 5ms
  input     wire    t1ms        ,       // 10ns pulse every 1ms
  input     wire    t2ms        ,       // 10ns pulse every 2ms
  input     wire    t64ms      ,       // 10ns pulse every 64ms
  input     wire    t1s          ,       // 10ns pulse every 1s
  
  input     wire    keep_alive_on_fault ,
 //from pwrseq_master 
  input     wire    [5:0]   power_seq_sm          ,     //current power sequencer state  
  input     wire    dc_on_wait_complete         ,	   //in FROM MASTER
  input     wire    rt_critical_fail_store   ,	   //in FROM MASTER
  input     wire    fault_clear                         ,	   //in FROM MASTER 

 //to pwrseq_master   
  output    reg      pgd_so_far				    ,  
  output    wire    s5dev_pwren_request		    ,       	
  output    wire    s5dev_pwrdis_request	            ,           
  output    reg      any_pwr_fault_det		    , 
  output    wire    any_aux_vrm_fault		    ,   
  output    reg      any_recov_fault			    ,   
  output    reg      any_lim_recov_fault		    ,          	
  output    reg      any_non_recov_fault		    , 

 //from Power Controller PG signal   
  input     wire    p5v_stby_pg  		        ,
  input     wire    grp_b_p0_33_s5_pg	        ,
  input     wire    grp_b_p1_33_s5_pg	        ,
  input     wire    grp_b_p0_18_s5_pg	        ,
  input     wire    grp_b_p1_18_s5_pg	        ,                
  input     wire    p3v3_stby_pg                   ,
  input     wire    p12v_stby_pg                   ,
  
  input     wire    p12v_efuse_pg		                ,
  input     wire    p12v_ssd_efuse_pg	                , 
  input     wire    p12v_p0_dimm_pg		        , 
  input     wire    p12v_p1_dimm_pg		        ,  
  input     wire    p5v_pg				        ,
  input     wire    grp_c_p0_pg			        ,
  input     wire    grp_c_p1_pg			        ,
  input     wire    grp_d_vddio_p0_pg	                ,  
  input     wire    grp_d_vddio_p1_pg	                ,
  input     wire    grp_d_soc_p0_pg		        ,
  input     wire    grp_d_soc_p1_pg		        ,  
  input     wire    grp_d_p0_vddcore0_pg	        ,
  input     wire    grp_d_p1_vddcore0_pg	        ,  
  input     wire    grp_d_p0_vddcore1_pg	        ,
  input     wire    grp_d_p1_vddcore1_pg	        ,
  input     wire    i_pwrgd_ocp0_nic_pwrgd	,
  
  // input         wire       [2:0]pcb_id                      ,
  
//Fault Detect Signal  
  output    reg      [5:0]    pwrseq_sm_fault_det	,    // SM state where fault occurred
  output    wire    p5v_stby_fault_det			,
  output    wire    grp_c_p0_fault_det			,
  output    wire    grp_c_p1_fault_det			,  
  output    wire    grp_d_vddio_p0_fault_det	        , 
  output    wire    grp_d_vddio_p1_fault_det	        ,   
  output    wire    grp_d_soc_p0_fault_det		,  
  output    wire    grp_d_soc_p1_fault_det		,  
  output    wire    grp_d_p0_vddcore0_fault_det	,
  output    wire    grp_d_p1_vddcore0_fault_det	,  
  output    wire    grp_d_p0_vddcore1_fault_det	,
  output    wire    grp_d_p1_vddcore1_fault_det	,  
  
  
  output    wire    grp_b_p0_33_s5_fault_det	,
  output    wire    grp_b_p1_33_s5_fault_det	,
  output    wire    grp_b_p0_18_s5_fault_det	,
  output    wire    grp_b_p1_18_s5_fault_det	,
  
  output    wire    p3v3_stby_fault_det            ,
  // output         wire           p12v_stby_fault_det         ,  
  output    wire    p5v_fault_det			,
  // output		wire			p12v_efuse_fault_det		,
  // output		wire			p12v_ssd_efuse_fault_det	,
  // output		wire			p12v_p0_dimm_fault_det		,
  // output		wire			p12v_p1_dimm_fault_det		, 

  //to Power Controller Enable Pin
  output    wire    p5v_stby_en      	        ,
  output    wire    p5v_stby_usb_en		,
  output    wire    grp_b_p0_33_s5_en	,
  output    wire    grp_b_p1_33_s5_en	,
  output    wire    grp_b_p0_18_s5_en	,
  output    wire    grp_b_p1_18_s5_en	,
  output    wire    power_supply_on		,
  // output		wire		   p12_en_p0_dimm_1		,
  // output		wire		   p12_en_p1_dimm_1		,
  // output          wire                   p12_en_p0_dimm_2     ,
  // output          wire                   p12_en_p1_dimm_2     ,
  output    wire    p5v_en				,
  output    wire    grp_c_p0_vdd11_en	,
  output    wire    grp_c_p1_vdd11_en	,
  output    wire    grp_d_p0_vddio_en	,
  output    wire    grp_d_p1_vddio_en	,
  output    wire    grp_d_p0_soc_en		,
  output    wire    grp_d_p1_soc_en		,
  output    wire    grp_d_p0_vddcore0_en	,
  output    wire    grp_d_p1_vddcore0_en	,
  output    wire    grp_d_p0_vddcore1_en	,
  output    wire    grp_d_p1_vddcore1_en	,
  output    wire    ocp_aux_en			,
  output    wire    ocp_main_en			,
  // output		wire		   usb_ponrst_r_n		,
  // output		wire		   tpcm_reset_n			, 

  //from CPU
  input     wire    [NUM_CPU-1:0]   i_cpu_pwrok	, 
  input     wire    [NUM_CPU-1:0]   i_cpu_prsnt_n    ,	
  
  //to CPU  
  output    wire    o_p0_pwr_good			        , //for AMD PWR_GOOD
  output    wire    [NUM_CPU-1:0]   o_cpu_pwrok	,
  output    wire    o_rsmrst_n				        ,
  
  //to system reset
  output    reg      reached_sm_wait_powerok	,
  /* 
  上板使用  
  */
  output reg reg_pwr_btn_l_n
  );

//------------------------------------------------------------------------------
// Power sequence state definition
//------------------------------------------------------------------------------

reg reg_rsmrst_l			        ;//CPU复位控制寄存器,低电平有效（_n表示低有效），1=释放复位，0=强制CPU复位
reg reg_p5v_stby_en			;// 5V待机电源使能目标状态，1=开启，0=关闭    待机电源是系统上电第一步，需优先缓存状态确保稳定供电
reg reg_p5v_stby_usb_en           ; // 5V待机USB电源使能目标状态，1=开启，0=关闭  USB待机用于唤醒功能，需单独控制
reg reg_grp_b_33_s5_en		; // CPU B组3.3V S5电源使能目标状态，1=开启，0=关闭
reg reg_grp_b_18_s5_en		; // CPU B组1.8V S5电源使能目标状态
reg reg_power_supply_on		;  // 12V主电源总使能目标状态，1=开启，0=关闭
reg reg_p5v_en				;// 5V主电源使能目标状态
reg reg_grp_c_en			        ; // CPU C组电源（如1.1V SUS）使能目标状态
reg reg_grp_d_vddio_en		;// CPU D组IO电源（如1.05V VDDIO）使能目标状态
reg reg_grp_d_soc_en		        ;// CPU D组SOC电源（如0.8V VDDSOC）使能目标状态
reg reg_grp_d_vddcore0_en	;// CPU D组核心0电源（如0.9V VDDCORE）使能目标状态
reg reg_grp_d_vddcore1_en	;// CPU D组核心1电源（如0.9V VDDCORE）使能目标状态
reg reg_ocp_aux_en			;// OCP扩展卡辅助电源使能目标状态，1=开启，0=关闭
reg reg_ocp_main_en			; // OCP扩展卡主电源使能目标状态，1=开启，0=关闭
// reg reg_usb_ponrst_r_n		;
// reg reg_tpcm_reset_n		;
reg reg_s5dev_pwren_request	; // S5设备（如BMC）上电请求目标状态，1=请求上电，0=请求下电
reg reg_cpu_pwrgood	                ;// P0 CPU电源好（PWR_GOOD）目标状态
reg [NUM_CPU-1:0] reg_pwrok    ;// 多CPU电源好（PWROK）目标状态，1=电源就绪，0=未就绪
// reg reg_p12_en_dimm                   ; 

wire    st_reset_state            ;  // 映射“复位状态”（`SM_RESET_STATE），1=当前为复位状态
wire    st_off_standby            ;  // 映射“待机关闭状态”（`SM_OFF_STANDBY），1=当前为待机关闭
wire    st_en_telem                  ;  // 映射“使能遥测状态”（`SM_EN_TELEM），1=当前为使能遥测
wire    st_en_main_efuse        ;  // 映射“使能主EFUSE状态”（`SM_EN_MAIN_EFUSE），1=当前为使能主EFUSE
wire    st_en_grp_atx              ;  // 映射“使能ATX组电源状态”（``SM_EN_GRP_ATX），1=当前为使能ATX组
wire    st_en_grp_c                  ;  // 映射“使能C组电源状态”（`SM_EN_GRP_C），1=当前为使能C组
wire    st_en_grp_d_vddio      ;  // 映射“使能D组IO电源状态”（`SM_EN_GRP_D_VDDIO），1=当前为使能IO电源
wire    st_en_grp_d_vddcore0;  // 映射“使能D组核心0电源状态”（`SM_EN_GRP_D_VDDCORE0），1=当前为使能核心0
wire    st_en_grp_d_vddcore1;  // 映射“使能D组核心1电源状态”（`SM_EN_GRP_D_VDDCORE1），1=当前为使能核心1
wire    st_wait_powerok          ;  // 映射“等待电源就绪状态”（`SM_WAIT_POWEROK），1=当前为等待电源就绪
wire    st_steady_pwrok          ;  // 映射“电源稳定运行状态”（`SM_STEADY_PWROK），1=当前为稳定运行
wire    st_critical_fail        ;  // 映射“临界故障状态”（`SM_CRITICAL_FAIL），1=当前为临界故障
wire    st_disable_main_efuse;  // 映射“关闭主EFUSE状态”（`SM_DISABLE_MAIN_EFUSE），1=当前为关闭主EFUSE
wire    st_halt_power_cycle   ;  // 映射“暂停电源循环状态”（`SM_HALT_POWER_CYCLE），1=当前为暂停循环
wire    st_aux_fail_recovery ;  // 映射“辅助故障恢复状态”（`SM_AUX_FAIL_RECOVERY），1=当前为故障恢复


assign p5v_stby_en			=	reg_p5v_stby_en			&	( ~p5v_stby_fault_det 									| keep_alive_on_fault )	;
assign p5v_stby_usb_en  	        =	reg_p5v_stby_usb_en		;//&((~p5v_stby_usb0_fault_det & ~p5v_stby_usb1_fault_det) 	| keep_alive_on_fault )	;  
// P0 CPU B组3.3V S5电源使能：目标状态 + 无故障 + （注释：CPU在位）
assign grp_b_p0_33_s5_en	        =	reg_grp_b_33_s5_en		&	(~grp_b_p0_33_s5_fault_det | keep_alive_on_fault )	;//~i_cpu_prsnt_n[0] & (~grp_b_p0_33_s5_fault_det | keep_alive_on_fault )	;
assign grp_b_p1_33_s5_en	        =	reg_grp_b_33_s5_en		&	~i_cpu_prsnt_n[1] & (~grp_b_p1_33_s5_fault_det | keep_alive_on_fault )	;
assign grp_b_p0_18_s5_en	        =	reg_grp_b_18_s5_en		&	(~grp_b_p0_18_s5_fault_det | keep_alive_on_fault )	;//~i_cpu_prsnt_n[0] & (~grp_b_p0_18_s5_fault_det | keep_alive_on_fault )	;
assign grp_b_p1_18_s5_en	        =	reg_grp_b_18_s5_en		&	~i_cpu_prsnt_n[1] & (~grp_b_p1_18_s5_fault_det | keep_alive_on_fault )	;
// 12V主电源使能：目标状态 + 故障保持（特殊逻辑：故障时强制保持，避免主电源频繁开关）
assign power_supply_on		=	reg_power_supply_on	| keep_alive_on_fault 	;
// assign power_supply_on		=	reg_power_supply_on		& 	((/* ~p12v_efuse_fault_det &  */~p12v_ssd_efuse_fault_det)	| keep_alive_on_fault )	;
// assign p12_en_p0_dimm_1		=	reg_p12_en_dimm		    &	~i_cpu_prsnt_n[0] & (~p12v_p0_dimm_fault_det 			| keep_alive_on_fault )	; 	
// assign p12_en_p1_dimm_1		=	reg_p12_en_dimm		    &	~i_cpu_prsnt_n[1] & (~p12v_p1_dimm_fault_det 			| keep_alive_on_fault )	; 
// assign p12_en_p0_dimm_2		=	reg_power_supply_on		&	~i_cpu_prsnt_n[0] & (~p12v_p0_dimm_fault_det 			| keep_alive_on_fault )	; 
// assign p12_en_p1_dimm_2		=	reg_power_supply_on		&	~i_cpu_prsnt_n[1] & (~p12v_p1_dimm_fault_det 			| keep_alive_on_fault )	; 
// 5V主电源使能：目标状态 + 无故障
assign p5v_en				=	reg_p5v_en				&	(~p5v_fault_det | keep_alive_on_fault )	;
//CPU C组电源使能（分P0/P1）：目标状态 + CPU在位 + 无故障
assign grp_c_p0_vdd11_en	        =	reg_grp_c_en			&	~i_cpu_prsnt_n[0] & (~grp_c_p0_fault_det			 | keep_alive_on_fault )	;
assign grp_c_p1_vdd11_en	        =	reg_grp_c_en			&	~i_cpu_prsnt_n[1] & (~grp_c_p1_fault_det			 | keep_alive_on_fault )	;
//CPU D组电源使能（IO/SOC/核心，分P0/P1）：目标状态 + CPU在位 + 无故障
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
assign  st_reset_state               = (power_seq_sm == `SM_RESET_STATE                 );
assign  st_off_standby               = (power_seq_sm == `SM_OFF_STANDBY                 );
assign  st_en_telem                  = (power_seq_sm == `SM_EN_TELEM                    );
assign  st_en_main_efuse             = (power_seq_sm == `SM_EN_MAIN_EFUSE               );
assign  st_en_grp_atx                = (power_seq_sm == `SM_EN_GRP_ATX                  );
assign  st_en_grp_c                  = (power_seq_sm == `SM_EN_GRP_C                    );
assign  st_en_grp_d_vddio            = (power_seq_sm == `SM_EN_GRP_D_VDDIO              );
assign  st_en_grp_d_vddcore0         = (power_seq_sm == `SM_EN_GRP_D_VDDCORE0           );
assign  st_en_grp_d_vddcore1         = (power_seq_sm == `SM_EN_GRP_D_VDDCORE1           );
assign  st_wait_powerok              = (power_seq_sm == `SM_WAIT_POWEROK                );
assign  st_steady_pwrok              = (power_seq_sm == `SM_STEADY_PWROK                );
assign  st_critical_fail             = (power_seq_sm == `SM_CRITICAL_FAIL               );
assign  st_disable_main_efuse        = (power_seq_sm == `SM_DISABLE_MAIN_EFUSE          );
assign  st_halt_power_cycle          = (power_seq_sm == `SM_HALT_POWER_CYCLE            );
assign  st_aux_fail_recovery         = (power_seq_sm == `SM_AUX_FAIL_RECOVERY           );

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
              reg_pwr_btn_l_n         <= 1'b1;
              // reg_p12_en_dimm			<= 1'b0;  
  end
  else if (t1us) begin
    case (power_seq_sm)
      `SM_RESET_STATE : begin
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
      `SM_EN_GRP_A : begin
      //no action execution 
            reg_p5v_stby_en        <= 1'b1; 
            // reg_p12_en_dimm        <= 1'b1;  //20220713 d00412
      end
      
      `SM_RSMRST_DISABLE : begin
            reg_rsmrst_l      	   <= 1'b0;
            reg_s5dev_pwren_request	<= 1'b1;
      end	
      
      `SM_EN_P5V_STBY : begin
            reg_p5v_stby_usb_en    <= 1'b1;
      end	  
      
      `SM_EN_GRP_B_33_S5 : begin
            reg_grp_b_33_s5_en		<= 1'b1; 
      end
      
      `SM_EN_GRP_B_18_S5 : begin
            reg_grp_b_18_s5_en		<= 1'b1;   
      end
      
      `SM_EN_RSMRST_RELEASE : begin
            reg_rsmrst_l           <= 1'b1;
            
      end
      
      `SM_ENABLE_S5_DEVICES : begin
	//no action execution
            reg_ocp_aux_en			<= 1'b1;
            reg_s5dev_pwren_request	<= 1'b0;
      end	  
      
      `SM_OFF_STANDBY: begin
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
            reg_pwr_btn_l_n        <= 1'b0;
      end	 
      
      `SM_PS_ON : begin
        //no action execution
		    // reg_usb_ponrst_r_n <= 1'b1;
        reg_pwr_btn_l_n          <= 1'b1;
      end
      
      `SM_EN_TELEM : begin
        //reg_pal_pvcc_hpmos_sw_r  <=1'b1;
		//no action execution
		// for drmos power enable 
      end
      
      `SM_EN_MAIN_EFUSE : begin
            reg_power_supply_on    	   <= 1'b1;
            reg_ocp_main_en		       <= 1'b1;
      end	
      
      `SM_EN_GRP_ATX : begin
	  //for CMU P3V3 & MB P3V3
            reg_p5v_en              <= 1'b1;  
      end
      
      `SM_EN_GRP_C : begin
            reg_grp_c_en			<= 1'b1;  
      end
      
      `SM_EN_GRP_D_VDDIO : begin
            reg_grp_d_vddio_en		<= 1'b1;  
      end	  
      
      `SM_EN_GRP_D_SOC : begin
            reg_grp_d_soc_en		<= 1'b1;
      end	
  	  
      `SM_EN_GRP_D_VDDCORE0 : begin
            reg_grp_d_vddcore0_en	<= 1'b1;  
      end	
      
      `SM_EN_GRP_D_VDDCORE1 : begin
            reg_grp_d_vddcore1_en	<= 1'b1;  
      end	
      
      `SM_EN_PGOOD_RELEASE : begin
            reg_cpu_pwrgood <= 1'b1;
      end
      
      `SM_WAIT_POWEROK : begin
            reached_sm_wait_powerok <= 1'b1;  
            reg_pwrok 				<= 1'b1;
      end	  
      
      `SM_STEADY_PWROK :begin
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
      
      `SM_CRITICAL_FAIL : begin
      //no action execution
      end
      
      `SM_DISABLE_PWRGD : begin
            reg_cpu_pwrgood <= 1'b0;
            reached_sm_wait_powerok <= 1'b0;
            reg_pwrok 		<= 1'b0;
            reg_ocp_main_en	<= 1'b0;
      end
      
      `SM_DISABLE_GRP_D_VDDCORE1 : begin
            reg_grp_d_vddcore1_en	<= 1'b0;  
      end	

      `SM_DISABLE_GRP_D_VDDCORE0 : begin
            reg_grp_d_vddcore0_en	<= 1'b0;  
      end	
       
      `SM_DISABLE_GRP_D_SOC : begin
            reg_grp_d_soc_en	<= 1'b0;  
      end		 
       
      `SM_DISABLE_GRP_D_VDDIO : begin
            reg_grp_d_vddio_en	<= 1'b0;  
      end		 
	 
      `SM_DISABLE_GRP_C : begin
            reg_grp_c_en	<= 1'b0;  
      end	
	  
      `SM_DISABLE_GRP_ATX : begin
            reg_p5v_en              <= 1'b0;
        // reg_usb_ponrst_r_n       <= 1'b0;		
      end
	  
      `SM_DISABLE_MAIN_EFUSE : begin
            reg_power_supply_on      <= 1'b0;
		//reg_ocp_main_en		     <= 1'b0;
      end

      `SM_DISABLE_TELEM : begin
	  //no action execution
      end

      `SM_DISABLE_PS_ON : begin
      //no action execution
      end

      `SM_AUX_FAIL_RECOVERY : begin
      //no action execution
      end
	  
      `SM_HALT_POWER_CYCLE : begin
	  //no action execution
      end
	  
      `SM_DISABLE_S5_DEVICES : begin
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
//Fault Flag：故障检测的核心中间信号，用于汇总、分类所有电源通道的故障状态
wire [FAULT_VEC_SIZE-1:0] fault_vec;               // 故障向量：按位记录各电源通道的故障状态（1=对应通道故障）
wire [FAULT_VEC_SIZE-1:0] any_recov_fault_vec;     // 可恢复故障向量：仅标记“可恢复故障”的通道（与掩码配合）
wire [FAULT_VEC_SIZE-1:0] any_lim_recov_fault_vec; // 有限可恢复故障向量：仅标记“有限可恢复故障”的通道
wire [FAULT_VEC_SIZE-1:0] any_non_recov_fault_vec; // 不可恢复故障向量：仅标记“不可恢复故障”的通道
wire any_recov_fault_c;                             // 可恢复故障汇总：1=存在至少一个可恢复故障
wire any_lim_recov_fault_c;                         // 有限可恢复故障汇总：1=存在至少一个有限可恢复故障
wire any_non_recov_fault_c;                         // 不可恢复故障汇总：1=存在至少一个不可恢复故障
wire aux_fault;                                     // 辅助VRM故障标志：1=辅助电源（如5V待机）存在故障

assign any_aux_vrm_fault = aux_fault;               // 对外输出：辅助VRM故障信号（连接到主模块）

//------------------------------------------------------------------------------
// P5V_STBY Fault detect：5V待机电源故障检测（系统上电的第一个电源，需优先监测）
//------------------------------------------------------------------------------
wire p5v_stby_en_check;  // 5V待机电源使能的“稳定确认信号”（延迟后输出，过滤瞬时波动）

// 延迟滤波模块：确保电源使能信号稳定一段时间后，才开始故障检测（避免使能瞬间的不稳定状态）
edge_delay #(.CNTR_NBITS(2)) p5v_stby_en_check_inst (
  .clk           (clk),                // 系统时钟（如50MHz）
  .reset         (reset),              // 全局复位（高电平有效）
  .cnt_size      (2'b10),              // 计数阈值：2^2=4个步长（配合cnt_step=64ms，总延迟=4*64ms=256ms）
  .cnt_step      (t64ms),              // 计数步长：每64ms触发一次计数
  .signal_in     (p5v_stby_en),        // 输入信号：5V待机电源使能信号（可能有瞬时波动）
  .delay_output  (p5v_stby_en_check)   // 输出信号：延迟稳定后的使能确认信号（1=使能已稳定≥256ms）
);

// 故障检测模块：核心逻辑是“当电源使能后，若电源好信号未置1，则判定为故障”
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p5v_stby_fault_detect_inst (
  .clk              (clk),                              // 系统时钟
  .reset            (reset),                            // 全局复位
  .vrm_enable       (p5v_stby_en && p5v_stby_en_check), // 电源使能有效：使能信号为1且已稳定（p5v_stby_en_check=1）
  .vrm_pgood        (p5v_stby_pg),                      // 电源好信号：1=电源稳定，0=电源异常
  .vrm_chklive_en   (p5v_stby_en_check),                // 故障检测使能：稳定确认后开启检测（1=允许检测）
  .vrm_chklive_dis  (~p5v_stby_en_check),               // 故障检测禁用：未稳定时关闭检测（1=禁止检测）
  .critical_fail    (st_critical_fail),                 // 临界故障状态：1=系统已进入故障状态，停止新故障判断
  .fault_clear      (fault_clear),                      // 故障清除信号：1=清除当前故障标志
  .lock             (any_pwr_fault_det),                // 故障锁定：1=已有其他故障，保持当前故障状态
  .any_vrm_fault    (aux_fault),                        // 输出：辅助VRM故障汇总（5V待机属于辅助电源）
  .vrm_fault        (p5v_stby_fault_det)                // 输出：5V待机电源故障标志（1=故障，0=正常）
);


//------------------------------------------------------------------------------
// P5V Fault detect：5V主电源故障检测（为IO设备、小功率外设供电）
//------------------------------------------------------------------------------
wire p5v_en_check;  // 5V主电源使能的“稳定确认信号”

// 延迟滤波模块：确保5V主电源使能稳定后再检测故障（延迟=4*64ms=256ms）
edge_delay #(.CNTR_NBITS(2)) p5v_en_check_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t64ms),
  .signal_in     (p5v_en),          // 输入：5V主电源使能信号
  .delay_output  (p5v_en_check)     // 输出：延迟稳定后的使能确认信号
);

// 故障检测模块：判断5V主电源是否故障
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p5v_fault_detect_inst (
  .clk              (clk),                            // 系统时钟
  .reset            (reset),                          // 全局复位
  .vrm_enable       (p5v_en && p5v_en_check),         // 电源使能有效：使能且稳定
  .vrm_pgood        (p5v_pg),                         // 电源好信号：5V主电源稳定标志
  .vrm_chklive_en   (p5v_en_check),                   // 允许故障检测
  .vrm_chklive_dis  (~p5v_en_check),                  // 禁止故障检测
  .critical_fail    (st_critical_fail),               // 临界故障状态
  .fault_clear      (fault_clear),                    // 故障清除
  .lock             (any_pwr_fault_det),              // 故障锁定
  .any_vrm_fault    (),                               // 未使用（5V主电源不属于辅助VRM）
  .vrm_fault        (p5v_fault_det)                    // 输出：5V主电源故障标志
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

// 故障向量（fault_vec）：按位映射各电源通道的故障状态（1=对应通道故障，0=正常）
// 位序规则：从待机电源→主电源→CPU分组电源→扩展电源，覆盖所有关键供电通道
assign fault_vec[0]    = p5v_stby_fault_det         ; // 位0：5V待机电源故障（系统最基础待机电源）
assign fault_vec[1]    = 1'b0;//p5v_stby_usb0_fault_det   ; // 位1：5V待机USB0电源故障（预留，当前未启用）
assign fault_vec[2]    = 1'b0;//p5v_stby_usb1_fault_det   ; // 位2：5V待机USB1电源故障（预留，当前未启用）
assign fault_vec[3]    = 1'b0;                          // 位3：预留（用于扩展新电源通道）
assign fault_vec[4]    = p5v_fault_det             ; // 位4：5V主电源故障（为IO设备、小功率外设供电）
assign fault_vec[5]    = 1'b0;//p12v_efuse_fault_det       ; // 位5：12V主EFUSE故障（预留，EFUSE是过流保护元件）
assign fault_vec[6]    = 1'b0;//p12v_ssd_efuse_fault_det   ; // 位6：12V SSD EFUSE故障（预留，SSD专用供电保护）
assign fault_vec[7]    = 1'b0;//p12v_p0_dimm_fault_det     ; // 位7：P0 CPU内存（DIMM）12V故障（预留）
assign fault_vec[8]    = 1'b0;//p12v_p1_dimm_fault_det     ; // 位8：P1 CPU内存（DIMM）12V故障（预留）
assign fault_vec[9]    = grp_b_p0_18_s5_fault_det   ; // 位9：P0 CPU B组1.8V S5电源故障（CPU休眠唤醒供电）
assign fault_vec[10]   = grp_b_p1_18_s5_fault_det   ; // 位10：P1 CPU B组1.8V S5电源故障
assign fault_vec[11]   = grp_b_p0_33_s5_fault_det   ; // 位11：P0 CPU B组3.3V S5电源故障
assign fault_vec[12]   = grp_b_p1_33_s5_fault_det   ; // 位12：P1 CPU B组3.3V S5电源故障
assign fault_vec[13]   = grp_c_p0_fault_det         ; // 位13：P0 CPU C组电源故障（如1.1V SUS供电）
assign fault_vec[14]   = grp_c_p1_fault_det         ; // 位14：P1 CPU C组电源故障
assign fault_vec[15]   = grp_d_vddio_p0_fault_det   ; // 位15：P0 CPU D组IO电源故障（如1.05V VDDIO）
assign fault_vec[16]   = grp_d_vddio_p1_fault_det   ; // 位16：P1 CPU D组IO电源故障
assign fault_vec[17]   = grp_d_soc_p0_fault_det     ; // 位17：P0 CPU D组SOC电源故障（如0.8V VDDSOC）
assign fault_vec[18]   = grp_d_soc_p1_fault_det     ; // 位18：P1 CPU D组SOC电源故障
assign fault_vec[19]   = grp_d_p0_vddcore0_fault_det; // 位19：P0 CPU D组核心0电源故障（如0.9V VDDCORE，核心供电）
assign fault_vec[20]   = grp_d_p1_vddcore0_fault_det; // 位20：P1 CPU D组核心0电源故障
assign fault_vec[21]   = grp_d_p0_vddcore1_fault_det; // 位21：P0 CPU D组核心1电源故障
assign fault_vec[22]   = grp_d_p1_vddcore1_fault_det; // 位22：P1 CPU D组核心1电源故障
assign fault_vec[23]   = p3v3_stby_fault_det        ; // 位23：3.3V待机电源故障（辅助待机供电）
assign fault_vec[24]   = 1'b0;//p12v_stby_fault_det        ; // 位24：12V待机电源故障（预留）
assign fault_vec[39:25]= 0;   // Reserved for future power rails



//通过三个预定义的故障掩码（MASK）（RECOV_FAULT_MASK、LIM_RECOV_FAULT_MASK、NON_RECOV_FAULT_MASK），对 fault_vec 按位过滤，将故障分为三类
genvar i; // 生成变量：用于generate循环（硬件设计中批量生成电路）
// 批量生成故障等级向量：对每个故障位，用对应掩码过滤，得到各等级的故障状态
generate    
    for (i = 0; i < FAULT_VEC_SIZE; i = i + 1) begin : _fault_vec_block_
        // 1. 可恢复故障向量：仅保留“可恢复故障”位（掩码对应位为1则保留该位故障状态）
        assign any_recov_fault_vec[i]         = fault_vec[i] & RECOV_FAULT_MASK[i];
        // 2. 有限可恢复故障向量：仅保留“有限可恢复故障”位（如重试3次失败则判定为不可恢复）
        assign any_lim_recov_fault_vec[i] = fault_vec[i] & LIM_RECOV_FAULT_MASK[i];
        // 3. 不可恢复故障向量：仅保留“不可恢复故障”位（如CPU核心电源故障，必须下电）
        assign any_non_recov_fault_vec[i] = fault_vec[i] & NON_RECOV_FAULT_MASK[i];
    end
endgenerate
//假设 RECOV_FAULT_MASK[0] = 1（5V 待机电源故障是可恢复），NON_RECOV_FAULT_MASK[19] = 1（P0 CPU 核心 0 电源故障是不可恢复）：
//若 fault_vec[0] = 1（5V 待机故障），则 any_recov_fault_vec[0] = 1，any_recov_fault_c = 1（存在可恢复故障）；
//若 fault_vec[19] = 1（CPU 核心 0 故障），则 any_non_recov_fault_vec[19] = 1，any_non_recov_fault_c = 1（存在不可恢复故障）。

// 故障等级汇总：只要对应等级向量中有1位为1，就判定存在该类故障（“|”是按位或运算）
assign any_recov_fault_c         = |any_recov_fault_vec;         // 1=存在至少一个可恢复故障
assign any_lim_recov_fault_c = |any_lim_recov_fault_vec; // 1=存在至少一个有限可恢复故障
assign any_non_recov_fault_c = |any_non_recov_fault_vec; // 1=存在至少一个不可恢复故障


always @(posedge clk or posedge reset) begin // 时序逻辑：在时钟上升沿或复位时更新状态
  if (reset) begin // 复位状态：所有故障状态清零
    any_pwr_fault_det     <= 1'b0; // 全局电源故障标志：1=存在任意故障
    any_recov_fault         <= 1'b0; // 可恢复故障锁存结果
    any_lim_recov_fault <= 1'b0; // 有限可恢复故障锁存结果
    any_non_recov_fault <= 1'b0; // 不可恢复故障锁存结果
  end
  else begin // 正常工作状态：锁存当前故障等级汇总结果
    any_pwr_fault_det     <= any_recov_fault_c | any_lim_recov_fault_c | any_non_recov_fault_c;
    any_recov_fault         <= any_recov_fault_c;
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
// pwrseq_sm_fault_det：记录故障发生时的电源序列状态
// 作用：故障诊断时可通过该信号定位“故障发生的上电阶段”
//------------------------------------------------------------------------------
reg  fault_save_en; // 故障状态保存使能：1=允许更新故障时的序列状态，0=锁定状态

always @(posedge clk or posedge reset) begin
  if (reset) begin // 复位：允许保存故障状态，初始序列状态清零
    fault_save_en             <= 1'b1;
    pwrseq_sm_fault_det <= 6'b0; // 故障时的序列状态寄存器（6位对应序列状态码）
  end
  else if (t1us && fault_clear) begin // 故障清除：重新允许保存，状态清零
    fault_save_en             <= 1'b1;
    pwrseq_sm_fault_det <= 6'b0;
  end
  else if (t1us && st_critical_fail) // 进入临界故障状态：禁止更新，锁定当前状态
    fault_save_en       <= 1'b0;
  else if (t1us && fault_save_en) // 允许保存时：实时更新序列状态（直到故障发生）
    pwrseq_sm_fault_det <= power_seq_sm;
end

//------------------------------------------------------------------------------
// pgd_so_far    向主模块（pwrseq_master）反馈的 “当前电源就绪汇总状态”
// - Reflects current status of power rail pgood signal qualified by their
//   respective enable signal. This signal is used by pwrseq_master.
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset) begin
  if (reset)
    pgd_so_far <= 1'b0;
  else
    pgd_so_far <= 1'b1;// 简化版：固定输出1（实际需按“所有已使能电源的PG=1”动态判断）
end

// else begin
//   // 动态判断：所有已使能的电源，其PG信号均为1，则电源就绪（pgd_so_far=1）
//   pgd_so_far <= (p5v_stby_en ? p5v_stby_pg : 1'b1) 
//               & (p5v_en ? p5v_pg : 1'b1)
//               & (grp_b_p0_33_s5_en ? grp_b_p0_33_s5_pg : 1'b1)
//               // ... 其他电源通道的PG信号判断
//               ;
// end
//对每个电源通道，若该电源已使能（en=1），则必须其 PG 信号为 1 才计入 “就绪”；若未使能（en=0），则不影响就绪判断（按 1 处理）

endmodule