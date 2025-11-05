//=================================================================================================
// Copyright(c)
// Filename   : BP_4S104G5
// Project    : BP_4S104G5
// Author     :
// Date       : 2024-4-9
//Simulator   : Lattice Diamond 3.12
//FPGA        : LCMXO3LF_6900C_5BG400C
// Email      : cloudnineinfo.com
// Company    :
// Description: BP_4S104G5 Top Code
// History    :
// Date      By          Revision  Change Description
//-------------------------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BP_4S104G5  : one CPLD,this Code for CPLD_U1  J68

//--------------------------------------------------------------------------------------------------

//=================================================================================================

`include "BP_4S104G5_VA_port.v"


//-------------------------------------------------------------------------------------------------
// define parameter
//-------------------------------------------------------------------------------------------------

`define PRODUCT_ID      8'h33
`define VENDER_ID       8'h08

`define Year            8'h25
`define Month           8'h02
`define Day             8'h08
`define CPLD_VERSION    8'h11
`define DEBUG_VERSION   8'h00





localparam FAN_NUM = 15  ;





//-------------------------------------------------------------------------------------------------
//For pll_inst
//-------------------------------------------------------------------------------------------------
wire clk_50m ;
wire clk_25m ;
wire pll_lock;	//锁相环锁定，一个来自PULL(锁相环）模块的状态标志信号，用于指示pll的输出始终是否已达到稳定和同步的状态

// wire [7:0] uart_slave_test ;
//-------------------------------------------------------------------------------------------------
//For pon_reset_inst
//-------------------------------------------------------------------------------------------------
wire pon_reset_n                ;	//上电复位信号，作为所有需要复位的逻辑的根复位信号
wire pon_reset_db_n             ;	//经过消抖处理后的上电复位信号，用于驱动对复位边沿敏感的逻辑
wire pgd_aux_system             ;	//辅助系统电源良好信号
wire pgd_aux_system_sasd        ;	//上述信号经过某种处理的信号，用于触发安全相关的序列
// wire pgd_aux_bmc                ;//From CMU，BMC的辅助电源良好信号
wire done_booting_delayed = 1'b1;//input; define constant 1;延迟后的启动完成标志信号，用于确保之前的所有操作都已完成和稳定

//-------------------------------------------------------------------------------------------------
//For timer_gen_inst 定时器/时钟生成模块
//-------------------------------------------------------------------------------------------------
	//tick 脉冲信号，大部分时间保持低电平，在每个时间周期内产生一个时钟周期宽度的高电平脉冲
wire t40ns_tick ;	//40纳秒 脉冲
wire t1us_tick  ;	//1微秒 脉冲
wire t2us_tick  ;
wire t16us_tick ;
wire t32us_tick ;
wire t128us_tick;
wire t512us_tick;
wire t1ms_tick  ;	//1毫秒 脉冲
wire t2ms_tick  ;
wire t32ms_tick ;
wire t64ms_tick ;
wire t128ms_tick;
wire t256ms_tick;
wire t512ms_tick;
wire t1s_tick   ;	//1秒 脉冲
wire t0p5hz_clk ;	//低频时钟信号（频率<1khz）0.5HZ时钟，周期2秒
wire t1hz_clk   ;	//1HZ时钟，周期1秒
wire t2p5hz_clk ;	//2.5HZ时钟，周期0.4秒
wire t4hz_clk   ;	//4HZ时钟，周期0.25秒
wire t16khz_clk ;	//高频时钟信号（频率>1kh）16kHZ,周期62.5微秒，常用于高级PWM
wire t6m25_clk  ;	
// wire t16m6_clk  ;




wire w_pch_slp5_n   ;	//pch发出的一种睡眠状态信号，低电平有效，表示系统正在或已经处于一种低功耗睡眠状态
wire w_p12v_pg_db         ;	//02 经过消抖处理的12v电源良好信号
wire w_rst_pltrst_n        ;	//平台复位信号
//-------------------------------------------------------------------------------------------------
//For NC PIN
//-------------------------------------------------------------------------------------------------
//将一系列未被顶层模块逻辑使用的输入信号，通过一个假的逻辑操作连接起来，最终输出到一个未连接的引脚（NC-No Connect）,防止综合工具将其优化掉
wire w_nc_pin ;

assign w_nc_pin =  
                   i_SPI_RESET_R_N    |
                   i_CPLD1_HDR_R      |
                   i_CPLD1_JTAGEN     |
                   i_CPLD1_PROGRAM_N  |
                   i_CPLD1_INIT_N     |
                   i_CPLD1_DONE       |
                   i_CPLD1_PULLUP_SN  |
                   i_SW0_SDB_TX_R	|
                   i_SW1_SDB_TX_R	|
                   i_SW2_SDB_TX_R	|
                   i_SW3_SDB_TX_R	|
                   i_SW0_UART_TX_R |
                   i_SW1_UART_TX_R |
                   i_SW2_UART_TX_R |
                   i_SW3_UART_TX_R |
                   i_BMC_SW_UART_TX0_R
                   ;


assign o_SMB_NIC_RST_N_R = 1'bz;	//输出给NIC芯片的低电平有效的复位信号（R表示在PCB上通过上拉电阻处理），当FPGA输出高阻态（z）时，上拉电阻会将物理电平拉高到VCC，既无效状态（因为_N是低有效），从而使NIC处于非复位，正常工作

// assign o_PAL_HSC0_RESTART_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ;  //2024-6-18 chg 1'bz;

assign o_PAL_HSC0_RESTART_R = 1'b0; //2024-12-24 输出给第0个热插拔控制器的重启信号，0表示恒定驱动为逻辑低电平，为了在FPGA启动后，立即并持续地禁止热插拔控制器的重启功能。
//将 RESTART 默认驱动为无效状态（通常是低电平），可以防止系统在上电或FPGA配置过程中因信号抖动而意外触发电源重启，这是一个非常重要的安全措施

//-------------------------------------------------------------------------------------------------
// RETIMER_RESET START 2024-7-10 ADD 标记当前代码块石“Retimer芯片复位与电源使能控制逻辑的起始部分”，方便后续快速定位Retimer相关控制代码
//-------------------------------------------------------------------------------------------------
wire w_RETIMER1_0P9_PG; //这些信号不是CPLD内部生成的，而是从Retimer芯片的“电源正常引脚（PG Pin）”输入到CPLD的外部信号（PCB上Retimer芯片的PG引脚会通过布线连接到CPLD的某个IO引脚，
wire w_RETIMER2_0P9_PG; //在TOP模块中用wire定义为输入线网，后续会在UCF约束中通过LOC绑定到CPLD的物理引脚）  可在接口文档中查找到
wire w_RETIMER3_0P9_PG; //核心功能：反馈Retimer芯片0.9V电源是否正常
wire w_RETIMER4_0P9_PG; // 当Retimer的0.9V电源电压在合格范围内时，Retimer的PG 引脚输出高电平，w_RETIMERx_0P9_PG 为1
wire w_RETIMER5_0P9_PG; //当电源电压异常（如上电初期未稳定，过亚/欠压）时，PG引脚输出低电平，w_RETIMERx_0P9_PG 为0
wire w_RETIMER6_0P9_PG;
wire w_RETIMER7_0P9_PG;
wire w_RETIMER8_0P9_PG;

// assign o_RETIMER1_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER2_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER3_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER4_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER5_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER6_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER7_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   
// assign o_RETIMER8_RESET_N_R = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //w_rst_pltrst_n ; //2024-7-1   


// wire w_rst_pltrst_pos ;
// Edge_Detect Edge_Detect_U1(    
    // .i_clk               (clk_50m),        
    // .i_rst_n             (pon_reset_n),       
    // .i_signal            (w_rst_pltrst_n),
    
    // .o_signal_pos        (w_rst_pltrst_pos),
    // .o_signal_neg        (),
    // .o_signal_invert     ()
// );

// reg r_rst_pltrst_pos ;
// always@(posedge clk_50m or negedge pon_reset_n) begin
	// if(~pon_reset_n) begin
		// r_rst_pltrst_pos <=1'b0;
	// end
	// else if(w_rst_pltrst_pos) begin
		// r_rst_pltrst_pos <=1'b1;
	// end
	// else begin
		// r_rst_pltrst_pos <= r_rst_pltrst_pos;
	// end
// end

// assign o_RETIMER1_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER2_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER3_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER4_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER5_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER6_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER7_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   
// assign o_RETIMER8_RESET_N_R = w_pch_slp5_n & r_rst_pltrst_pos ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug  


     // w_RETIMER1_0P9_PG（大写）是原始输出信号，w_retimer1_0p9_pg_dly10ms（小写）是延迟后信号，代码风格约定，通过大小写区分原始输入和内部处理后信号
wire w_retimer1_0p9_pg_dly10ms ; //2024-7-10 add  w_RETIMER1_0P9_PG延迟信号，将Retimer1的PG（电源正常信号）延迟10ms后输出，用于后续的复位释放逻辑，因为Retimer电源刚稳定
                                 //（PG变高）时，芯片内部电路还未完全初始化，直接释放复位会导致Retimer工作异常，需延迟10ms等待芯片稳定
//edge_delay是一个通用的信号延迟模块。功能是：根据输入时钟，复位信号和配置参数，将输入信号（signal_in)延迟指定时间后，从delay_output输出
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer1_0p9_pg ( //DELAY_MODE =0 for rise 参数化配置，通过#（...)给模块内部参数赋值，决定延迟模块的工作模式
  .clk         (clk_50m),         //输入。模块内部端口clk，绑定的TOP模块信号clk_50m。CPLD中最常用的系统时钟是50MHZ，edge_delay需基于此时钟计数实现延迟，所以接clk_50m
  .reset       (~pgd_aux_system), //输入。模块的异步复位信号（高电平复位，低电平正常工作）。pgd_aux_system是CPLD的系统电源正常信号（上电后，pgd_aux_system变高表示正常）；加~表示“当CPLD电源异常时，reset为高，edge_delay复位（不工作）；当CPLD电源正常时，reset为低，模块开始工作——确保延迟逻辑只在CPLD自身电源稳定后才运行
  .cnt_size    (3'd5),            //输入。延迟计数阈值——模块内部计数器从0计数到cnt_size完成一次延迟
  .cnt_step    (t2ms_tick),       //输入。计数触发脉冲——每收到一个t2ms_tick脉冲，模块内部计数器加1。t2ms_tick是内部另一个模块生成的2ms周期脉冲信号，用t2ms_tick作为计数步长，可减少edge_delay模块的计数器位数
  .signal_in   (w_RETIMER1_0P9_PG),     //this signal from 0 to 1 输入。需要延迟的原始信号——即Retimer1的0.9v电源正常信号，目标是延迟Retimer1的PG信号，所以将其接入signal_in
  .delay_output(w_retimer1_0p9_pg_dly10ms)  //输出。延迟后的信号——即PG信号延迟10ms后的结果。延迟后的信号需要用于后续Retimer复位释放（如当w_retimer1_0p9_pg_dly10ms变高时，CPLD向Retimer1发送复位释放信号），所以将输出绑定到这个延迟信号
  );
  
wire w_retimer2_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer2_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER2_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer2_0p9_pg_dly10ms)  
  );
  
wire w_retimer3_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer3_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER3_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer3_0p9_pg_dly10ms)  
  );

wire w_retimer4_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer4_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER4_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer4_0p9_pg_dly10ms)  
  );

wire w_retimer5_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer5_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER5_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer5_0p9_pg_dly10ms)  
  );

wire w_retimer6_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer6_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER6_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer6_0p9_pg_dly10ms)  
  );

wire w_retimer7_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer7_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER7_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer7_0p9_pg_dly10ms)  
  );

wire w_retimer8_0p9_pg_dly10ms ; //2024-7-10 add 
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_retimer8_0p9_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_RETIMER8_0P9_PG),     //this signal from 0 to 1
  .delay_output(w_retimer8_0p9_pg_dly10ms)  
  );

assign o_RETIMER1_RESET_N_R = w_retimer1_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   //当w_retimer1_0p9_pg_dly10ms为高电平（1‘b1）时，o_RETIMER1_RESET_N_R实时输出高电平（1’b1）
assign o_RETIMER2_RESET_N_R = w_retimer2_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   //当w_retimer1_0p9_pg_dly10ms为低电平（1‘b0）时，o_RETIMER1_RESET_N_R实时输出低电平（1’b0）  
assign o_RETIMER3_RESET_N_R = w_retimer3_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   //CPLD向第1个Retimer芯片输出的低电平有效复位信号，用于控制Retimer的复位状态
assign o_RETIMER4_RESET_N_R = w_retimer4_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   //当该信号为低电平时，芯片处于复位状态（内部电路初始化，不工作）；高电平时，芯片复位释放（完成初始化，进入正常工作状态）
assign o_RETIMER5_RESET_N_R = w_retimer5_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   //该代码是对应Retimer芯片上电复位流程的最后一步，Retimer的复位信号需要实时响应电源状态：当Retimer的电源稳定且延迟10ms后（w_retimer1_0p9_pg_dly10ms=1），必须立即释放复位（o_RETIMER1_RESET_N_R=1）；
assign o_RETIMER6_RESET_N_R = w_retimer6_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   //若电源异常w_retimer1_0p9_pg_dly10ms=0），必须立即拉低复位（o_RETIMER1_RESET_N_R=0）
assign o_RETIMER7_RESET_N_R = w_retimer7_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug   //使用assign是因为它的连续赋值特性符合需求，输入信号变化时输出无延迟响应，确保Retimer在电源异常时能被快速复位保护
assign o_RETIMER8_RESET_N_R = w_retimer8_0p9_pg_dly10ms ? 1'b1 : 1'b0 ;  //2024-7-10 add for debug  

//把Retimer1的整个控制逻辑串联，其信号的流转关系：
//1.w_RETIMER1_0P9_PG:Retimer1的0.9v电源正常信号（电源稳定时变高）；
//2.edge_delay模块：将w_RETIMER1_0P9_PG延迟10ms，输出w_retimer1_0p9_pg_dly10ms（确保电源稳定后等待芯片内部初始化）；
//3.assign语句：将w_retimer1_0p9_pg_dly10ms直接映射为o_RETIMER1_RESET_N_R（电源稳定+延迟后没，释放复位）
//  Retimer1上电初期：电源未稳定（w_RETIMER1_0P9_PG=0）-延迟信号为0-复位信号o_RETIMER1_RESET_N_R=0（芯片复位）；
//  电源稳定10ms后：w_RETIMER1_0P9_PG=1-延迟信号为1-复位信号o_RETIMER1_RESET_N_R=1（芯片复位释放，开始工作）。



//-------------------------------------------------------------------------------------------------
// RETIMER_RESET END
//-------------------------------------------------------------------------------------------------

// assign o_BP_9548_RST_N_R = 1'bz;        //CPLD输出给BP9548芯片的复位控制信号，用于控制BP9548芯片的复位/工作状态（低电平触发复位，高电平正常工作）

// assign o_UBB_PEX_STRAP0_R = 1'bz;       //CPLD输出给UBB模块PCIe的初始化配置信号，用于设定PCIe总线的硬件参数，这类信号通常在系统上电时由外部电路配置，CPLD暂不干预
// assign o_UBB_PEX_STRAP1_R = 1'bz;
// assign o_FPGA_EROT_RECOV_N_R = 1'bz;    //CPLD输出给外部FPGA的错误恢复控制信号，用于触发FPGA的错误恢复流程
// assign o_FPGA_EROT_RST_N_R	 = 1'bz;
// assign o_FPGA_BOOT_EN_R	= 1'bz;    
// assign o_HGX_DETECT_N_R	= 1'bz;    
// assign o_NVLINK_REFCLK_SELECT_R = 1'bz;

// assign o_DS160_TX_READ_EN_N = 1'bz; //CPLD输出给DS160芯片发送端的读使能信号，用于允许/禁止DS160芯片的发送数据读取操作
// assign o_DS160_RX_READ_EN_N = 1'bz;


assign o_I2C_RST0_R_N = 1'bz;      //CPL输出给第0路的I2C总线设备（如传感器，EEPROM）的复位信号，用于控制该路的I2C设备的复位/使能
assign o_I2C_RST1_R_N = 1'bz;
assign o_I2C_RST2_N_R = 1'bz;
assign o_I2C_RST3_N_R = 1'bz;
assign o_I2C_RST4_7_R_N = 1'bz;


//-------------------------------------------------------------------------------------------------
// SYS Clock
//-------------------------------------------------------------------------------------------------
//pll_i25M_o50M_o25M是一个锁相环模块。PLL的核心功能是：接受一个原始输入时钟，通过内部的相位锁定，倍频/分频，相位调整等逻辑，生成多个频率稳定，相位同步的输出时钟，同时提供锁定状态信号（表明输出时钟是否稳定可用）
pll_i25M_o50M_o25M pll_inst(  //pll_inst是PLL模块的实例名，括号内的信号分为输入端口和输出端口
  .CLKI  (i_CPLD1_CLK), //in  CPLD的原始时钟输入，是PLL的时钟源
  .RST   (~i_P3V3_STBY_PG ), //in  //.RST   (i_CPLD_RESET_N ),PLL的复位控制信号，决定PLL是否初始化。i_P3V3_STBY_PG指3.3V待机电源正常信号（电源模块输出，高电平表示3.3v电压稳定）;~是取反：意味当3.3v电源不稳定时（i_P3V3_STBY_PG=0），RST=1，PLL复位初始化
  .CLKOP (clk_50m        ), //out  50Mhz in fact CLKOP是PLL模块的标准输出端口名（OP=Output Primary），clk_50m中接受该时钟的信号（供后续逻辑如edge_delay模块使用）
  .CLKOS (clk_25m        ), //out; 25MHZ in fact    for  bmc_cpld_i2c_ram only 辅助输出端口，clk_25m,仅仅供TOP内的bmc_cpld_i2c_ram使用
  .LOCK  (pll_lock       )  //out  PLL的锁定状态信号，高电平表示PLL工作正常（输入时钟稳定的，输出时钟频率/相位已锁定），低电平表示PLL未锁定（输出时钟不可用），后续逻辑会依赖pll_lock判断时钟是否可用
);

//-------------------------------------------------------------------------------------------------
// SYS RST
//-------------------------------------------------------------------------------------------------
//pon_reset 模块是整个CPLD系统的核心复位控制模块，负责生成系统各阶段的复位信号，确保芯片上电，时钟稳定后所有逻辑按序初始化。
//根据电源状态，时钟锁定状态和系统启动进度，生成一系列时序可控，逻辑可靠的复位信号，确保整个CPLD系统及外部设备在电源稳定——时钟稳定——初始化完成的流程中安全启动，避免因上电时序混乱导致的逻辑错误
pon_reset pon_reset_inst(
  .clk                  (clk_50m),              //in 模块的工作时钟，来自PLL模块的50MHZ时钟，用于复位信号的同步和延时控制，确保复位信号与系统时钟对齐，避免异步复位导致的亚稳态
  .pll_lock             (pll_lock),             //in 来自PLL模块的锁定信号，高电平表示PLL输出的50MHZ/25MHZ时钟已稳定可用；低电平表示时钟未锁定（此时不能释放复位）
  .pgd_p3v3_stby        (i_P3V3_STBY_PG ),      //in 3.3V待机电源的电源正常信号：高电平表示3.3v电源稳定（系统上电的基础条件）；低电平表示电源位就绪（需保持复位）
  .pgd_aux_gmt          (1'b1),                 //in, all BMC power ok 辅助电源的电源正常信号，此处设置为1表示辅助电源始终稳定
  .done_booting         (1'b1),                 //in 启动完成标志：高电平表示系统固件加载完成；此处硬编码为1，表示当前设计中无需等待固件加载
  .done_booting_delayed (done_booting_delayed), //in;  delayed version of done_booting (if not used, set to 1'b1) 延迟后的启动完成标志
  .pon_reset_n          (pon_reset_n),          //out; master AUX power-on reset (based on pgd_p3v3_stby) 全局复位信号（低有效），系统上电初期为低电平，当电源（pgd_p3v3_stby）和时钟（pll_lock）都稳定后变高（释放全局复位）
  .pon_reset_db_n       (pon_reset_db_n),       //out; when done_booting_delayed not usd;  pon_reset_db_n = pon_reset_n.  去抖后的全局复位信号
  .pgd_aux_system       (pgd_aux_system),       //out; 辅助电源的电源正常信号，高电平表示辅助电源稳定（供edge_delay等模块作为复位条件）
  .pgd_aux_system_sasd  (pgd_aux_system_sasd),  //out; SASD version of pgd_aux_system; pgd_aux_system_sasd = pgd_aux_system
  .cpld_ready           ()                      //未连接，CPLD自身初始化完成的标志，此处未连接，表示当前设计中无需使用该信号
);

//-------------------------------------------------------------------------------------------------
// Generate Timer Ticks (1-clk wide pulse) And Slow 50% Duty Cycle Clock
//-------------------------------------------------------------------------------------------------
timer_gen timer_gen_inst(
  .clk      (clk_50m),
  .reset    (~pon_reset_n),
  .t40ns    (t40ns_tick ),
  .t80ns    (),
  .t160ns   (),
  .t1us     (t1us_tick  ),
  .t2us     (t2us_tick  ),
  .t16us    (t16us_tick ),
  .t32us    (t32us_tick ),
  .t128us   (t128us_tick),
  .t512us   (t512us_tick),
  .t1ms     (t1ms_tick  ),
  .t2ms     (t2ms_tick  ),
  .t16ms    (),
  .t32ms    (t32ms_tick ),
  .t64ms    (t64ms_tick ),
  .t128ms   (t128ms_tick),
  .t256ms   (t256ms_tick),
  .t512ms   (t512ms_tick),
  .t1s      (t1s_tick   ),
  .clk_0p5hz(t0p5hz_clk	),
  .clk_1hz  (t1hz_clk   ),
  .clk_2p5hz(t2p5hz_clk ),
  .clk_4hz  (t4hz_clk   ),
  .clk_16khz(t16khz_clk ),
  .clk_6m25 (t6m25_clk  )
);





//-------------------------------------------------------------------------------------------------
// Pwrgood Debounce  电源正常信号（Power Good，PG）进行去抖
//-------------------------------------------------------------------------------------------------

wire w_p3v3_stby_pg_db    ;//01 3.3v待机电源的稳定正常信号
wire w_p12v_pg_db         ;//02 
wire w_p0v8_sw0_pwrgd_db  ;//03 第0路0.8v开关电源的稳定正常信号
wire w_p0v8_sw1_pwrgd_db  ;//04 第1路0.8v开关电源的稳定正常信号
wire w_p0v8_sw2_pwrgd_db  ;//05 第2路0.8v开关电源的稳定正常信号
wire w_p0v8_sw3_pwrgd_db  ;//06 第3路0.8v开关电源的稳定正常信号
wire w_ct_p1v25_sw0_pg_db ;//07 核心控制模块第0路1.25v电源的稳定正常信号
wire w_ct_p1v25_sw1_pg_db ;//08 核心控制模块第1路1.25v电源的稳定正常信号
wire w_ct_p1v25_sw2_pg_db ;//09 核心控制模块第2路1.25v电源的稳定正常信号
wire w_ct_p1v25_sw3_pg_db ;//10 核心控制模块第3路1.25v电源的稳定正常信号
wire w_pg_p5v0_r_db       ;//11 5.0v主电源的稳定正常信号
wire w_pg_p1v8_r_db       ;//12
wire w_pg_p1v8_pll_r_db   ;//13 PLL专用1.8v电源的稳定正常信号
wire w_pal_p12v_stby_pg_db;//14 12v待机电源的稳定正常信号

//Active High
//If The Un-Debounced Signal Starts Low Initially Such As PGD, Use PGM_DEBOUNCE_N.
//For Signal That Starts High Like Power Buttons,Use PGM_DEBOUNCE.
//PGM_DEBOUNCE_N是一个多路信号去抖的复用模块。通过#（参数列表）对模块进行“定制化配置”，使其适应不同数量的信号去抖需求
PGM_DEBOUNCE_N #(.SIGCNT(14),.NBITS(2'b11),.ENABLE(1'b1)) //参数1：需要去抖的信号总数（13）路；参数2：计数器位数（3位，用于控制去抖时间）；参数3：模块使能（始终使能）
db_power_pg(
  .clk         (clk_50m),
  .rst_n       (pon_reset_n),
  .timer_tick  (t1us_tick),  
  .din         ({                             //13路原始PG信号（输入总线）
				i_P3V3_STBY_PG               ,//01
				i_PAL_P12V_PG                ,//02
				i_P0V8_SW0_PWRGD             ,//03
				i_P0V8_SW1_PWRGD             ,//04
				i_P0V8_SW2_PWRGD             ,//05
				i_P0V8_SW3_PWRGD             ,//06
				i_CT_P1V25_SW0_PG            ,//07
				i_CT_P1V25_SW1_PG            ,//08
				i_CT_P1V25_SW2_PG            ,//09
				i_CT_P1V25_SW3_PG            ,//10
				i_PG_P5V0_R                  ,//11
				i_PG_P1V8_R                  ,//12
				i_PG_P1V8_PLL_R              ,//13
        i_PAL_P12V_STBY_PG            //14

				}),
  .dout        ({                               //13路去抖后PG信号（输出总线）
				w_p3v3_stby_pg_db              ,//01
				w_p12v_pg_db                   ,//02
				w_p0v8_sw0_pwrgd_db            ,//03
				w_p0v8_sw1_pwrgd_db            ,//04
				w_p0v8_sw2_pwrgd_db            ,//05
				w_p0v8_sw3_pwrgd_db            ,//06
				w_ct_p1v25_sw0_pg_db           ,//07
				w_ct_p1v25_sw1_pg_db           ,//08
				w_ct_p1v25_sw2_pg_db           ,//09
				w_ct_p1v25_sw3_pg_db           ,//10
				w_pg_p5v0_r_db                 ,//11
				w_pg_p1v8_r_db                 ,//12
				w_pg_p1v8_pll_r_db             ,//13
        w_pal_p12v_stby_pg_db           //14

				})
);

// wire w_psu0_pwrok_n_db;//01 第0号电源模块的稳定工作状态信号（低电平表示正常）
// wire w_psu1_pwrok_n_db;//02 第1号电源模块的稳定工作状态信号（低电平表示正常）
// wire w_psu2_pwrok_n_db;//03 第2号电源模块的稳定工作状态信号（低电平表示正常）
// wire w_psu3_pwrok_n_db;//04 第3号电源模块的稳定工作状态信号（低电平表示正常）
// wire w_psu4_pwrok_n_db;//05 第4号电源模块的稳定工作状态信号（低电平表示正常）
// wire w_psu5_pwrok_n_db;//06 第5号电源模块的稳定工作状态信号（低电平表示正常）


// PGM_DEBOUNCE #(.SIGCNT(6), .NBITS (2'b11), .ENABLE(1'b1)) db_inst_psu0_pwrok_n( //同上一致
//   .clk(clk_50m),   //时钟源
//   .timer_tick(t512us_tick), //时间基准：512us脉冲，因为PSU信号的抖动周期比电源PG信号更长，需更长的去抖时间
//   .rst(~pon_reset_n),       //复位信号：高电平有效，同上不同是因为PGM_DEBOUNCEPGM_DEBOUNCE模块内部设计为高电平有效复位（与PGM_DEBOUNCE_N的低电平有效复位相反），通过~pon_reset_n适配全局复位信号
//   .din({
//   	    i_PSU0_PWROK_N, //01
// 		i_PSU1_PWROK_N, //02
// 		i_PSU2_PWROK_N, //03
// 		i_PSU3_PWROK_N, //04
// 		i_PSU4_PWROK_N, //05
// 		i_PSU5_PWROK_N  //06
// 	  }),
//   .dout({
// 	    w_psu0_pwrok_n_db, //01
// 		w_psu1_pwrok_n_db, //02
// 		w_psu2_pwrok_n_db, //03
// 		w_psu3_pwrok_n_db, //04
// 		w_psu4_pwrok_n_db, //05
// 		w_psu5_pwrok_n_db  //06

//        })
// );


// edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_inst_n ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (4'd10),
  // .cnt_step    (t1ms_tick),
  // .signal_in   (db_i_pal_bmc_srst_n_r),     //this signal from mb  from 0 to 1
  // .delay_output(w_pal_bmc_srst_n_dly10ms)  //from mb to bmc delay 10ms
  // );






//-------------------------------------------------------------------------------------------------
//From MB SGPIO
//-------------------------------------------------------------------------------------------------


// wire w_t4hz_clk_from_mb    ; //2024-7-1 add 
wire w_cpld_pch_rsmrst_n_r ;//CPLD发送给PCH（平台控制中枢，主板核心芯片）的复位控制信号；低电平时触发PCH复位，高电平释放复位
wire w_bmc_active0_n       ;//指示BMC是否处于活动状态：低电平表示BMC正常工作，高电平可能表示BMC故障或未启动，供CPLD判断
wire w_pgd_p5v             ;//高电平表示5V电源稳定输出


//-------------------------------------------------------------------------------------------------
//To MB SGPIO
//-------------------------------------------------------------------------------------------------
reg r_sw0_spi_cs_sel_r ; //spi_cs:SPI总线片选信号sel_r：选择/配置
reg r_sw1_spi_cs_sel_r ; //第0路开关电源的SPI片选控制寄存器：高/低电平选中或取消选中该模块，实现CPLD对开关电源的单独配置
reg r_sw2_spi_cs_sel_r ;
reg r_sw3_spi_cs_sel_r ;



//-------------------------------------------------------------------------------------------------
// SGPIO data
//-------------------------------------------------------------------------------------------------
wire [59:0] mcpld_to_scpld_p2s_data;//s2p:串行转并行——主CPLD到开关电源CPLD的串并转换数据总线 接受主CPLD发送的串行数据，并转换为并行数据，供开关电源CPLD解析执行
wire [59:0] scpld_to_mcpld_s2p_data;//p2s:并行转串行——开关电源CPLD到主CPLD的并串转换数据总线 将开关电源CPLD的并行状态数据转换为串行数据，发送给主CPLD,实现状态回传

reg [51:0] scpld_to_mcpld_data_filter; //data_filter:数据过滤 主CPLD发送给开关电源CPLD的经过过滤的数据寄存器，存储主CPLD到开关电源CPLD的控制指令，并通过过滤逻辑确保数据可靠，避免噪声干扰
reg mb_sgpio_fail;  //mb:主板 主板SGPIO总线故障标志寄存器；当SGPIO总线通信异常时，寄存器置1，用于触发故障告警

//mcpld ---> scpld
assign  mcpld_to_scpld_p2s_data[59]      = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[58]      = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[57]      = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[56]      = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[55:16]   = 'b0                                        ;

assign  mcpld_to_scpld_p2s_data[15]        = 1'b0        ;

assign  mcpld_to_scpld_p2s_data[14]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[13]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[12]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[11]        = 1'b0        ;

assign  mcpld_to_scpld_p2s_data[10]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[9]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[8]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[7]        = 1'b0        ;

assign  mcpld_to_scpld_p2s_data[6]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[5]        = 1'b0        ;
assign  mcpld_to_scpld_p2s_data[4]        = 1'b0        ;

                                                            
assign  mcpld_to_scpld_p2s_data[3]        = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[2]        = 1'b1                                       ;
assign  mcpld_to_scpld_p2s_data[1]        = 1'b0                                       ;
assign  mcpld_to_scpld_p2s_data[0]        = 1'b1                                       ;






//scpld ---> mcpld  scpld 到 mcpld 的信号赋值，从 scpld_to_mcpld_data_filter 中提取不同位，用于各类状态或控制

// assign w_t4hz_clk_from_mb                = mcpld_to_scpld_data_filter[5]       ; //2024-7-1 add 
assign w_P0V8_SW1_ALERT_N             = scpld_to_mcpld_data_filter[15]       ;
assign w_P0V8_SW1_FAULT_N             = scpld_to_mcpld_data_filter[14]       ;
assign w_pgd_p5v                         = scpld_to_mcpld_data_filter[2]       ;
assign w_rst_pltrst_n                    = scpld_to_mcpld_data_filter[1]       ;  //控制整个平台的复位：低电平触发全局复位，高电平释放，确保系统各模块按序启动
assign w_pch_slp5_n                      = scpld_to_mcpld_data_filter[0]       ;  //控制PCH的休眠模式：低电平表示进入睡眠状态，高电平表示PCH唤醒并正常工作
//mcpld_to_scpld_data_filter（主CPLD发送的过滤后数据）的低五位分别赋值给上述控制信号——主CPLD通过mcpld_to_scpld_s2p_data总线发送控制指令——经mcpld_to_scpld_data_filter过滤后
//——解析出具体的控制信号（如pch复位，bmc状态）——驱动相应模块

//-------------------------------------------------------------------------------------------------
// SW_CPLD_U1 SGPIO Moudule       SW_CPLD_U1 is slave
//-------------------------------------------------------------------------------------------------

always@(posedge clk_50m or negedge pon_reset_n)
	begin
		if(~pon_reset_n)
			begin
				scpld_to_mcpld_data_filter <= {52{1'b0}};
				mb_sgpio_fail <=1'b0;
			end
		else if
			((scpld_to_mcpld_s2p_data[3:0] == 4'b0101)&& (scpld_to_mcpld_s2p_data[59:56] == 4'b1010))
			begin
				scpld_to_mcpld_data_filter <= scpld_to_mcpld_s2p_data[55:4];
				mb_sgpio_fail <=1'b0;
			end
		else
			begin
				scpld_to_mcpld_data_filter <= scpld_to_mcpld_data_filter;
				mb_sgpio_fail <=1'b1;
			end

end


//M CPLD ---> SW CPLD 串行转并行从模块，将主板发送的串行数据（1位，逐位传输）转为并行数据（60位，同时处理），供mcpld_to_scpld_s2p_data解析
s2p_slave #(.NBIT(60)) inst_mb_to_slv_s2p( //MBIT表示数据位宽（60）位，通过修改NBIT即可适配不同位宽的串行通信需求，无需修改模块内部逻辑，同前面的PGM_DEBOUNCE的SIGCNT参数类似
	.clk   (clk_50m                 ),//时钟信号
	.rst   (~pon_reset_n            ),//复位信号（高电平有效）
	.si    (i_MCPLD_SGPIO_DATA_OUT	    ),//SGPIO_MOSI Serial Signal input 串行数据输入：主板通过该引脚逐位发送数据，是转换的原始数据
	.po    (scpld_to_mcpld_s2p_data),//Parallel Signal output 并行数据输出：将串行输入的60位数据转换为并行格式（一次输出60位），供CPLD内部逻辑直接使用
	.sld_n (i_MCPLD_SGPIO_LD	        ),//SGPIO_LOAD 加载控制信号（低电平有效）：指示串行数据传输的起始/结束，低电平时模块开始接受数据，高电平时锁存并行输出
	.sclk  (i_MCPLD_SGPIO_CLK		    ) //SGPIO_CLK 串行始终信号：由主板提供，用于同步串行数据传输，决定数据传输速率
);
//两者配合形成双向串行通信链路，是CPLD与主板（如BMC，PCH）之间传递控制指令，状态信息的核心通道（此处通过SGPIO总线实现，即Serial GPIO，串行通用输入输出）
// SW CPLD ---> M CPLD 并行转串行从模块，将CPLD内部的并行数据转为串行数据，发送给主板，实现CPLD到主板的反向数据回传
p2s_slave #(.NBIT(60)) inst_slv_to_mb_p2s(
	.clk   (clk_50m				    ),
	.rst   (~pon_reset_n			),
	.pi    (mcpld_to_scpld_p2s_data),//Parallel Signal input 并行数据输入：CPLD内部生成的60位数据，需转换为串行发送给主板
	.so    (o_MCPLD_SGPIO_DATA_IN		),//SGPIO_MISO Serial Signal output串行数据输出：将60位并行数据逐位发送到主板，每一个sclk始终沿发送1位
	.sld_n (i_MCPLD_SGPIO_LD   	    ),//SGPIO_LOAD
	.sclk  (i_MCPLD_SGPIO_CLK	        ) //SGPIO_CLK 与s2p_slave共用（由主板提供），确保双向数据传输的时钟同步（避免收发速率不匹配）
);

//-------------------------------------------------------------------------------------------------
// SGPIO WDT 2024-7-1 add
// ------------------------------------------------------------------------------------------------
// wire w_sgpio_active0_n;

// WDT#(.WDT_TIMIEOUT (2'd2), .RST_VLU(1'b0) ) SGPIO_WDT  
// (
// .i_clk         (clk_50m), 
// .i_rst_n       (pon_reset_n), 
// .i_wdt_en      (1'b1), 
// .i_WDT_cnt_clk (t2p5hz_clk  ), 
// .i_WDT_cnt_clr (w_t4hz_clk_from_mb ), 
// .o_WDT_timeout (w_sgpio_active0_n)  // defaulte 0; SGPIO die: 1; SGPIO active: 0 ; 
// );


// assign w_led_control[4] = w_sgpio_active0_n ? 1'b1 : 1'b0 ; //SGPIO die light the led 

assign o_debug_led2 = mb_sgpio_fail ? 1'b0 : 1'b1 ; //2024-7-1 add SGPIO die light the led

//-------------------------------------------------------------------------------------------------
// pvt SW_165_0
//-------------------------------------------------------------------------------------------------

wire [5:0]pvti_ss_count;

//U95
wire w_PAL_FAN14_PRSNT_N;
wire w_PAL_FAN5_PRSNT_N ;
wire w_TEMP_ALERT_1_R   ;
wire w_PAL_FAN10_PRSNT_N;
wire w_PAL_FAN4_PRSNT_N ;
wire w_PAL_FAN9_PRSNT_N ;
wire w_PAL_FAN15_PRSNT_N;
wire w_SW0_CLKREQ_N_R   ;
//U96
wire w_PAL_FAN13_PRSNT_N;
wire w_PAL_FAN1_PRSNT_N ;
wire w_PAL_FAN6_PRSNT_N ;
wire w_PAL_FAN11_PRSNT_N;
wire w_PAL_FAN12_PRSNT_N;
wire w_PAL_FAN7_PRSNT_N ;
wire w_PAL_FAN2_PRSNT_N ;
wire w_TEMP_ALERT_0_R   ;
//U101
wire w_TEMP_ALERT_2_R  ;
wire w_PAL_FAN3_PRSNT_N;
wire w_PAL_FAN8_PRSNT_N;
wire w_NICBOX_PRSNT_N_R;
wire w_SW2_CLKREQ_N_R  ;
wire w_PSU2_PRSNT_R    ;
wire w_PSU1_PRSNT_R    ;
wire w_PSU0_PRSNT_R    ;
//U97
wire w_TEMP_ALERT_3_R;
wire w_HSC0_PG       ;
wire w_HSC0_FAULT    ;
wire w_HSC0_GPIO1_R  ;
wire w_HSC0_GPIO2_R  ;
wire w_PSU3_PRSNT_R  ;
wire w_PSU4_PRSNT_R  ;
wire w_PSU5_PRSNT_R  ;
//U98
wire w_P0V8_SW2_FAULT_N;
wire w_P0V8_SW2_ALERT_N;
wire w_P0V8_SW2_VRHOT_N;
wire w_SW3_CLKREQ_N_R  ;
wire w_MCIO21A_CFG_N_R ;
wire w_MCIO21C_CFG_N_R ;
wire w_MCIO22A_CFG_N_R ;
wire w_MCIO22C_CFG_N_R ;
//U102
wire w_MCIO01C_CFG_N_R ;
wire w_MCIO01A_CFG_N_R ;
wire w_P0V8_SW0_ALERT_N;
wire w_P0V8_SW0_VRHOT_N;
wire w_P0V8_SW0_FAULT_N;
wire w_MCIO02A_CFG_N_R ;
wire w_MCIO02C_CFG_N_R ;
wire w_BPTB_PRSNT_N_R  ;
//U103
wire w_MCIO31C_CFG_N_R ;
wire w_MCIO32A_CFG_N_R ;
wire w_MCIO32C_CFG_N_R ;
wire w_MCIO31A_CFG_N_R ;
wire w_MBP_PRSNT_N_R   ;
wire w_P0V8_SW3_VRHOT_N;
wire w_P0V8_SW3_FAULT_N;
wire w_P0V8_SW3_ALERT_N;






assign w_TEMP_ALERT_0_R = i_TEMP_ALERT_0_R;
assign w_TEMP_ALERT_1_R = i_TEMP_ALERT_1_R;
assign w_TEMP_ALERT_2_R = i_TEMP_ALERT_2_R;
assign w_TEMP_ALERT_3_R = i_TEMP_ALERT_3_R;

assign w_P0V8_SW0_ALERT_N = i_P0V8_SW0_ALERT_N;
// assign w_P0V8_SW1_ALERT_N = i_P0V8_SW1_ALERT_N;
assign w_P0V8_SW2_ALERT_N = i_P0V8_SW2_ALERT_N;
assign w_P0V8_SW3_ALERT_N = i_P0V8_SW3_ALERT_N;

assign  w_P0V8_SW0_VRHOT_N = i_P0V8_SW0_VRHOT_N;
assign  w_P0V8_SW1_VRHOT_N = i_P0V8_SW1_VRHOT_N;
assign  w_P0V8_SW2_VRHOT_N = i_P0V8_SW2_VRHOT_N;
assign  w_P0V8_SW3_VRHOT_N = i_P0V8_SW3_VRHOT_N;

assign  w_P0V8_SW0_FAULT_N = i_P0V8_SW0_FAULT_N;
// assign  w_P0V8_SW1_FAULT_N = i_P0V8_SW1_FAULT_N;
assign  w_P0V8_SW2_FAULT_N = i_P0V8_SW2_FAULT_N;
assign  w_P0V8_SW3_FAULT_N = i_P0V8_SW3_FAULT_N;

assign  w_SW0_CLKREQ_N_R = i_SW0_CLKREQ_N_R;
assign  w_SW1_CLKREQ_N_R = i_SW1_CLKREQ_N_R;
assign  w_SW2_CLKREQ_N_R = i_SW2_CLKREQ_N_R;
assign  w_SW3_CLKREQ_N_R = i_SW3_CLKREQ_N_R;
// pvt_gpi #(
//   .TOTAL_BIT_COUNT(56),			//告诉模块需采集56路信号，因此pata_data是56位总线
//   .DEFAULT_STATE(56'h0),		//复位时的默认输出值：56位全0
//   .NUMBER_OF_COUNTER_BITS(6)	//计数器位数：6位（最大计数63，覆盖56位需求）
// ) pvt_SW_inst (
//   .clk           (clk_50m),            //in系统时钟
//   .reset_n       (pon_reset_n),        //in复位信号，低有效
//   .clk_ena       (t16us_tick),         //in时钟使能信号（16us脉冲），控制采集速率
//   .serclk_in     (o_74LV165_CLK_R),    //in串行时钟输入（来自74LV165的时钟输出），实际与输出复用
//   .par_load_in_n (o_74LV165_LD_R),     //in并行加载控制输入（低有效），与输出复用，用于控制74LV165加载并行数据
//   .sdi           (i_74LV165_DATA_IN_R),//in串行数据输入，接受外部芯片转换后的串行信号
//   .bit_idx_in    (pvti_ss_count),      //in位索引输入，标记当前采集到的信号位置（如第0位，第1位）
//   .bit_idx_out   (pvti_ss_count),      //out位索引输出，与输入复用，形成环路，用于计数递推
//   .serclk_out    (o_74LV165_CLK_R ),   //out串行时钟输出，发送给74LV165，控制其串行数据输出的速率（每时钟沿输出1位）
//   .par_load_out_n(o_74LV165_LD_R),     //out并行加载控制输出（低有效），发送给74LV165，控制其加载外部并行信号到内部寄存器

//   .par_data ({							//56位并行数据总线，整合所有采集到的外部状态信号
//             w_PAL_FAN14_PRSNT_N,w_PAL_FAN5_PRSNT_N,w_TEMP_ALERT_1_R,w_PAL_FAN10_PRSNT_N,	//FANx：第x号风扇 PRSNT_N：在位检测（低有效）——第1~15号风扇是否安装到位（低电平表示已安装）
//             w_PAL_FAN4_PRSNT_N,w_PAL_FAN9_PRSNT_N,w_PAL_FAN15_PRSNT_N,w_SW0_CLKREQ_N_R,		//w_TEMP_ALERT_0_R~3 TEMP_ALERT:温度警告 x：第x路温度传感器 ——第0~3路温度传感器的告警信号（高电平表示温度超限）
//             //U95																			//w_SW0_CLKREQ_N_R~3 SWx:第x路开关电源 CLKREQ_N:时钟请求（低有效）——第0~3路开关电源的时钟使能请求（低电平需要表示需要时钟），开关电源工作时需外部时钟同步，通过该信号向CPLD请求时钟，CPLD根据请求状态控制时钟输出
//             w_PAL_FAN13_PRSNT_N,w_PAL_FAN1_PRSNT_N,w_PAL_FAN6_PRSNT_N,w_PAL_FAN11_PRSNT_N,	//w_PSU0_PRSNT_R~5  PSUx:第x号电源模块 PRSNT_N：在位检测（低有效） ——第0~5号电源模块是否安装到位
//             w_PAL_FAN12_PRSNT_N,w_PAL_FAN7_PRSNT_N,w_PAL_FAN2_PRSNT_N,w_TEMP_ALERT_0_R,		//w_HSC0_PG HSC0供电正常（高有效）
// 			//U96																			//w_HSC0_FAULT HSC0故障信号（高电平表示故障）
// 			w_TEMP_ALERT_2_R,w_PAL_FAN3_PRSNT_N,w_PAL_FAN8_PRSNT_N,w_NICBOX_PRSNT_N_R,		//w_HSC0_GPIO1_R~2 HSCO的通用IO信号
// 			w_SW2_CLKREQ_N_R,w_PSU2_PRSNT_R,w_PSU1_PRSNT_R,w_PSU0_PRSNT_R,					//w_P0V8_SW2_fAULT_N P0V8_SWx:第x路0.8V开关电源 FAULT_N：故障（低有效） ALERT_N:告警 VRHOT_N:电压调节器过热
// 			//U101																			//w_MCIO21A_CFG_N_R MCIO：多通道输入输出连接器 x：连接器编号 CFG_N:配置状态 ——各类连接器的硬件配置状态
// 			w_TEMP_ALERT_3_R,w_HSC0_PG,w_HSC0_FAULT,w_HSC0_GPIO1_R,							//w_NICBOX_PRSNT_N_R NICBOX:网卡模块 ——网卡模块是否安装到位
// 			w_HSC0_GPIO2_R,w_PSU3_PRSNT_R,w_PSU4_PRSNT_R,w_PSU5_PRSNT_R, 					//w_BPTB_PRSNT_N_R BPTB:背板测试板 ——测试板是否安装
// 			//U97																			//w_MBP_PRSNT_N_R  MBP：主板保护板 ——保护板是否安装
// 			w_P0V8_SW2_FAULT_N,w_P0V8_SW2_ALERT_N,w_P0V8_SW2_VRHOT_N,w_SW3_CLKREQ_N_R,
// 			w_MCIO21A_CFG_N_R,w_MCIO21C_CFG_N_R,w_MCIO22A_CFG_N_R,w_MCIO22C_CFG_N_R,
// 			//U98
// 			w_MCIO01C_CFG_N_R,w_MCIO01A_CFG_N_R,w_P0V8_SW0_ALERT_N,w_P0V8_SW0_VRHOT_N,
// 			w_P0V8_SW0_FAULT_N,w_MCIO02A_CFG_N_R,w_MCIO02C_CFG_N_R,w_BPTB_PRSNT_N_R,
// 			//U102
// 			w_MCIO31C_CFG_N_R,w_MCIO32A_CFG_N_R,w_MCIO32C_CFG_N_R,w_MCIO31A_CFG_N_R,
// 			w_MBP_PRSNT_N_R,w_P0V8_SW3_VRHOT_N,w_P0V8_SW3_FAULT_N,w_P0V8_SW3_ALERT_N
// 			//U103
//             })	//pvt_gpi模块采集的信号（如风扇状态，温度告警）是系统监控的原始数据，这些数据会被后续逻辑使用
// );//eg：w_TEMP_ALERT_0_R（温度告警）被采集到par_data后，会通过前文的p2s_slave模块转换为串行信号发送给BMC，有BMC触发告警通知


//-------------------------------------------------------------------------------------------------
// pvt SW_165_1
//-------------------------------------------------------------------------------------------------

wire [3:0]pvti_ss_count1;


//U104
wire w_BOARD_ID4;
wire w_BOARD_ID3;
wire w_BOARD_ID2;
wire w_BOARD_ID1;
wire w_BOARD_ID0;
wire w_PCB_ID2  ;
wire w_PCB_ID1  ;
wire w_PCB_ID0  ;
wire w_PCA_ID0  ;
wire w_PCA_ID1  ;
wire w_PCA_ID2  ;
//U105
wire w_MCIO11A_CFG_N_R ;
wire w_P0V8_SW1_FAULT_N;
wire w_P0V8_SW1_ALERT_N;
wire w_P0V8_SW1_VRHOT_N;
wire w_SW1_CLKREQ_N_R  ;
wire w_MCIO11C_CFG_N_R ;
wire w_MCIO12A_CFG_N_R ;
wire w_MCIO12C_CFG_N_R ;


// pvt_gpi #(
//   .TOTAL_BIT_COUNT(16),
//   .DEFAULT_STATE(16'h0),
//   .NUMBER_OF_COUNTER_BITS(4)
// ) pvt1_SW_inst (
//   .clk           (clk_50m),               //in
//   .reset_n       (pon_reset_n),           //in
//   .clk_ena       (t16us_tick),            //in
//   .serclk_in     (o_74LV165_1_CLK_R),     //in
//   .par_load_in_n (o_74LV165_1_LD_R),      //in
//   .sdi           (i_74LV165_1_DATA_IN_R), //in
//   .bit_idx_in    (pvti_ss_count1),        //in
//   .bit_idx_out   (pvti_ss_count1),        //out
//   .serclk_out    (o_74LV165_1_CLK_R ),    //out
//   .par_load_out_n(o_74LV165_1_LD_R),      //out

//   .par_data ({
//             w_BOARD_ID4,w_BOARD_ID3,w_BOARD_ID2,w_BOARD_ID1,//w_BOARD_ID0~4：板卡ID 用于系统识别板卡型号：5位二进制可表示32种不同板卡，BMC读取该id后可加载对应驱动程序或配置参数
// 		    w_BOARD_ID0,w_PCB_ID2,w_PCB_ID1,w_PCB_ID0,//w_PCB_ID0~2：PCB板版本ID 用于硬件版本追溯：3位二进制可表示8种版本，若出现硬件故障，可通过该ID定位具体版本的设计缺陷
// 			//U104      w_P0V8_SW1_FAULT_N：低电平表示电源输出异常     w_P0V8_SW1_ALERT_N：低电平表示电源接近故障阈值，提前出发维护通知   w_P0V8_SW1_VRHOT_N：低电平表示电源内部电压调节器（VR）温度过高
// 			w_MCIO11A_CFG_N_R,w_P0V8_SW1_FAULT_N,w_P0V8_SW1_ALERT_N,w_P0V8_SW1_VRHOT_N, //w_SW1_CLKREQ_N_R：电源时钟请求，低电平表示电源需要外部时钟同步，CPLD收到请求后输出对应时钟，确保电源稳定工作
// 			w_SW1_CLKREQ_N_R,w_MCIO11C_CFG_N_R,w_MCIO12A_CFG_N_R,w_MCIO12C_CFG_N_R //w_MCIOxxx_CFG_N_R:某组连接器硬件配置 表示连接器的速率/协议配置，CPLD读取后初始化对应通信模块
// 			//U105

//             })
// );


//-------------------------------------------------------------------------------------------------
// pvt NIC_165
//-------------------------------------------------------------------------------------------------

wire [5:0]pvti_nic_ss_count;

//U42
// wire w_RETIMER1_0P9_PG;
// wire w_RETIMER2_0P9_PG;
// wire w_RETIMER3_0P9_PG;
// wire w_RETIMER4_0P9_PG;
// wire w_RETIMER5_0P9_PG;
// wire w_RETIMER6_0P9_PG;
// wire w_RETIMER7_0P9_PG;
// wire w_RETIMER8_0P9_PG;
//U43
wire w_SLOT1_WAKE_N;
wire w_SLOT2_WAKE_N;
wire w_SLOT3_WAKE_N;
wire w_SLOT4_WAKE_N;
wire w_SLOT5_WAKE_N;
wire w_SLOT6_WAKE_N;
wire w_SLOT7_WAKE_N;
wire w_SLOT8_WAKE_N;
//U44
wire w_NIC_SLOT1_PRSNT_N;
wire w_NIC_SLOT2_PRSNT_N;
wire w_NIC_SLOT3_PRSNT_N;
wire w_NIC_SLOT4_PRSNT_N;
wire w_NIC_SLOT5_PRSNT_N;
wire w_NIC_SLOT6_PRSNT_N;
wire w_NIC_SLOT7_PRSNT_N;
wire w_NIC_SLOT8_PRSNT_N;
//U45
wire w_NIC_PCB_VER_ID0;
wire w_NIC_PCB_VER_ID1;
wire w_NIC_PCB_VER_ID2;
wire w_NIC_BOARD_ID0  ;
wire w_NIC_BOARD_ID1  ;
wire w_NIC_BOARD_ID2  ;
wire w_NIC_BOARD_ID3  ;
wire w_NIC_BOARD_ID4  ;
//U52
wire w_RETIMER1_1P8_PG;
wire w_RETIMER2_1P8_PG;
wire w_U52_C_NC_PIN   ;
wire w_U52_D_NC_PIN   ;
wire w_U52_E_NC_PIN   ;
wire w_U52_F_NC_PIN   ;
wire w_U52_G_NC_PIN   ;
wire w_U52_H_NC_PIN   ;


wire w_pal_rst_sw0_3_nic_vpp1_n_r;
wire w_pal_rst_sw0_vpp2_n_r;
wire w_pal_rst_sw1_vpp2_n_r;
wire w_pal_rst_sw2_vpp2_n_r;
wire w_pal_rst_sw3_vpp2_n_r;

wire w_sw0_npu_clk_oe_n_r;
wire w_sw1_npu_clk_oe_n_r;
wire w_sw2_npu_clk_oe_n_r;
wire w_sw3_npu_clk_oe_n_r;

wire w_sw0_mcio2_clk_oe_n_r;
wire w_sw1_mcio2_clk_oe_n_r;
wire w_sw2_mcio2_clk_oe_n_r;
wire w_sw3_mcio2_clk_oe_n_r;
// pvt_gpi #(
//   .TOTAL_BIT_COUNT(40),
//   .DEFAULT_STATE(40'h0),
//   .NUMBER_OF_COUNTER_BITS(6)
// ) pvt_nic_inst (	//nic：网卡相关信号采集
//   .clk           (clk_50m),            //in
//   .reset_n       (pon_reset_n),        //in
//   .clk_ena       (t16us_tick),         //in
//   .serclk_in     (o_C),  //in 串行时钟，专属网卡SGPIO总线
//   .par_load_in_n (o_NIC_SGPIO_SLOAD_R),//in 并行加载控制，专属
//   .sdi           (i_NIC_SGPIO_SDI_R  ),//in 串行数据输入，接受40路信号的串行数据流
//   .bit_idx_in    (pvti_nic_ss_count),  //in 网卡专用位索引计数器，记录当前采集到的位序
//   .bit_idx_out   (pvti_nic_ss_count),  //out
//   .serclk_out    (o_NIC_SGPIO_CLK_R ), //out 
//   .par_load_out_n(o_NIC_SGPIO_SLOAD_R),//out

//   .par_data ({ //40位并行数据总线，整合所有网卡和扩展槽相关信号
//             w_RETIMER8_0P9_PG,w_RETIMER7_0P9_PG,w_RETIMER6_0P9_PG,w_RETIMER5_0P9_PG,//w_RETIMER1_0P9_PG~8 监控网卡PCIe链路中8路0.9v电压的稳定性：高电平表示电压正常
// 			w_RETIMER4_0P9_PG,w_RETIMER3_0P9_PG,w_RETIMER2_0P9_PG,w_RETIMER1_0P9_PG,
// 			//2025-1-23 chg 1-8 to 8-1
// 			//U42
// 			w_SLOT8_WAKE_N,w_SLOT7_WAKE_N,w_SLOT6_WAKE_N,w_SLOT5_WAKE_N,//w_SLOT1_WAKE_N~8 第1~8号扩展槽的远程唤醒请求：接受扩展槽中网卡的唤醒请求：当网卡需要远程启动，会拉低该信号，CPLD检测到后通知唤醒BMC唤醒系统
// 			w_SLOT4_WAKE_N,w_SLOT3_WAKE_N,w_SLOT2_WAKE_N,w_SLOT1_WAKE_N,//需上拉电阻（避免悬空误触发）
// 			//2025-1-23 chg 1-8 to 8-1
// 			//U43
// 			w_NIC_SLOT8_PRSNT_N,w_NIC_SLOT7_PRSNT_N,w_NIC_SLOT6_PRSNT_N,w_NIC_SLOT5_PRSNT_N,//w_NIC_SLOT1_PRSNT_N~8 第1~8号插槽中是否安装网卡 监测各插槽的网卡物理安装状态：低电平表示网卡已插入
// 			w_NIC_SLOT4_PRSNT_N,w_NIC_SLOT3_PRSNT_N,w_NIC_SLOT2_PRSNT_N,w_NIC_SLOT1_PRSNT_N,
// 			//2025-1-23 chg 1-8 to 8-1
// 			//U44
// 			w_NIC_PCB_VER_ID0,w_NIC_PCB_VER_ID1,w_NIC_PCB_VER_ID2,w_NIC_BOARD_ID0,//w_NIC_PCB_VER_ID0~2 网卡PCB板的生产版本 3位2进制可表示8种版本，用于硬件追溯
// 			w_NIC_BOARD_ID1,w_NIC_BOARD_ID2,w_NIC_BOARD_ID3,w_NIC_BOARD_ID4,//w_NIC_BOARD_ID0~5 NIC_BOARD_ID：网卡板卡ID，5位二进制可表示32种网卡型号，BMC读取后加载对应驱动和配置参数
// 			//U45
// 			w_RETIMER2_1P8_PG,w_RETIMER1_1P8_PG,w_U52_C_NC_PIN,w_U52_D_NC_PIN, //cdms202501100001 w_RETIMER2_1P8_PG~1 第1~2路热timer的1.8v供电状态 Retimer是高速信号传输的关键器件，监控其供电状态可确保信号完整性：高表示正常
// 			w_U52_E_NC_PIN,w_U52_F_NC_PIN,w_U52_G_NC_PIN,w_U52_H_NC_PIN//w_U52_C_NC_PIN~H U52：某个未焊接或预留的芯片位号 PIN：引脚 硬件设计中预留的冗余引脚
// 			//U52
// 			//2025-1-10   chg w_RETIMER1_1P8_PG,w_RETIMER2_1P8_PG, to w_RETIMER2_1P8_PG ,w_RETIMER1_1P8_PG //cdms202501100001
			
			
//             })
// );



/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//PWR SEQ Start
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/

wire w_psu0_ctl ;	//电源控制信号，用于开启/关闭对应电源模块的输出
wire w_psu1_ctl ;
wire w_psu2_ctl ;
wire w_psu3_ctl ;
wire w_psu4_ctl ;
wire w_psu5_ctl ;



assign o_P5V0_EN_R = w_p3v3_stby_pg_db ? 1'b1 : 1'b0 ;	//该信号用于控制5.0v电源的输出：当信号为高电平时，5.0v电源开启；低电平时，电源关闭。当w_p3v3_stby_pg_db位高电平时，o_P5V0_EN输出1；否则为0

/////////////////////////////////////////////////////////////////////////////////////////////////////2024-7-25 modify

// wire w_p12v_pg_db_dly10ms ;
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p12v_pg_10ms ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (3'd5),
  // .cnt_step    (t2ms_tick),
  // .signal_in   (w_p12v_pg_db  ),     //this signal from 0 to 1
  // .delay_output(w_p12v_pg_db_dly10ms)  
  // );

// assign o_P1V8_EN     = w_p12v_pg_db_dly10ms ? 1'b1 : 1'b0 ; //2024-7-25  
// assign o_P1V8_PLL_EN = w_p12v_pg_db_dly10ms ? 1'b1 : 1'b0 ; //2024-7-25 


// wire w_p1v8_pg_db_dly10ms ;
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p1v8_pg_10ms ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (3'd5),
  // .cnt_step    (t2ms_tick),
  // .signal_in   (w_pg_p1v8_pll_r_db & w_pg_p1v8_r_db  ),     //this signal from 0 to 1
  // .delay_output(w_p1v8_pg_db_dly10ms)  
  // );

// assign o_CT_P1V25_SW_EN = w_p1v8_pg_db_dly10ms ? 1'b1 : 1'b0 ;

// wire w_p1v25_pg_db_dly10ms ;
// edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p1v25_pg_10ms ( //DELAY_MODE =0 for rise 
  // .clk         (clk_50m),
  // .reset       (~pgd_aux_system),
  // .cnt_size    (3'd5),
  // .cnt_step    (t2ms_tick),
  // .signal_in   (w_ct_p1v25_sw0_pg_db & 
                // w_ct_p1v25_sw1_pg_db & 
				// w_ct_p1v25_sw2_pg_db & 
				// w_ct_p1v25_sw3_pg_db ),     //this signal from 0 to 1
  // .delay_output(w_p1v25_pg_db_dly10ms)  
  // );

// assign o_P0V8_SW_EN = w_p1v25_pg_db_dly10ms ? 1'b1 : 1'b0 ;

///////////////////////////////////////////////////////////////////////////////////////////////////2024-8-17 


assign o_P0V8_SW_EN_R = w_p12v_pg_db ? 1'b1 : 1'b0 ; //w_p12v_pg_db ? 1'b1 : 1'b0 ; 2024-7-24

wire w_p0v8_sw_pg_dly10ms ; //2024-8-19 chg 50ms to 10ms 声明单比特线网信号，用于0.8v电源良好信号延迟10ms后的输出
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p0v8_pg_50ms ( //DELAY_MODE =0 for rise CNTR_NBITS设为3（计数器位数，决定计数范围），DELAY_MODE设为1'b0（延迟模式，这里表示上升沿延迟等含义）
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),			//计数大小，这里设为5，决定延迟时长相关的计数
  .cnt_step    (t2ms_tick),		//计数步长输入，周期为2ms的脉冲信号，用于计数
  .signal_in   (w_p0v8_sw0_pwrgd_db & 
                w_p0v8_sw1_pwrgd_db &
				w_p0v8_sw2_pwrgd_db &
				w_p0v8_sw3_pwrgd_db  ),     //this signal from 0 to 1,输入信号，多个电源良好信号的与操作结果,signal_in为高电平的条件是 “0.8V 电源域下的 4 个电源模块（0~3）均输出稳定电压，且各自的电源良好信号已消抖
  .delay_output(w_p0v8_sw_pg_dly10ms)  		//延迟后的输出信号，即w_p0v8_sw_pg_dly10ms
  );
//当w_p0v8_sw_pg_dly10ms为高电平时，o_CT_P1V25_SW_EN输出1；否则输出0
assign o_CT_P1V25_SW_EN_R = w_p0v8_sw_pg_dly10ms ? 1'b1 : 1'b0 ;		//根据延迟后的信号w_p0v8_sw_pg_dly10ms控制o_CT_P1V25_SW_EN的使能


wire w_p1v25_sw_pg_dly10ms ; //2024-8-19 chg 50ms to 10ms
edge_delay #(.CNTR_NBITS(3), .DELAY_MODE(1'b0)) edge_delay_p1v25_pg_50ms ( //DELAY_MODE =0 for rise  参数配置同之前的edge_delay模块，CNTR_NBITS为3，DELAY_MODE为1'b0
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (3'd5),
  .cnt_step    (t2ms_tick),
  .signal_in   (w_ct_p1v25_sw0_pg_db & 
                w_ct_p1v25_sw1_pg_db & 
				w_ct_p1v25_sw2_pg_db & 
				w_ct_p1v25_sw3_pg_db  ),     //this signal from 0 to 1 signal_in为高电平的条件是 “1LV25 电源域下的 4 个电源模块（0~3）均输出稳定电压，且信号已消抖”。
  .delay_output(w_p1v25_sw_pg_dly10ms)  		// 延迟后的输出信号
  );

assign o_P1V8_PLL_EN_R = w_p1v25_sw_pg_dly10ms ? 1'b1 : 1'b0 ;//当w_plv25_sw_pg_dly10ms为高电平时，o_P1V8_PLL_EN输出1；否则输出0. 控制P1V8 PLL（锁相环）的使能
assign o_P1V8_EN_R = w_p1v25_sw_pg_dly10ms ? 1'b1 : 1'b0 ;//控制P1V8电源的使能
///////////////////////////////////////////////////////////////////////////////////////////////////


// assign o_P5V_VGA_EN = 1'b1 ;			//直接赋值，使o_P5V_VGA_EN恒为高电平，用于使能P5V_VGA相关电源
// assign o_P5V_RIGHTEAR_USB_EN = 1'b1 ;	//直接赋值，使o_P5V_RIGHTEAR_USB_EN恒为高电平，使能右耳USB相关P5V电源
// assign o_P5V_STBY_USB_EN = 1'b1 ;		//直接赋值，使o_P5V_STBY_USB_EN恒为高电平，使能待机USB相关P5V电源



wire w_p0v8_sw_pg_dly100ms ; //2024-7-2 add  声明单比特线网信号，用于P0V8电源良好信号延迟100ms后的输出
edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b0)) edge_delay_p0v8_pg ( //DELAY_MODE =0 for rise  CNTR_NBITS设为6（计数器位数更多，计数范围更大，对应更长延迟），DELAY_MODE设为1'b0
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (6'd50),						//// 计数大小设为50，结合cnt_step决定延迟时长
  .cnt_step    (t2ms_tick),
  .signal_in   (w_p0v8_sw0_pwrgd_db |
                w_p0v8_sw1_pwrgd_db |
                w_p0v8_sw2_pwrgd_db |
                w_p0v8_sw3_pwrgd_db  ),     //this signal from 0 to 1,输入信号，多个电源良好信号的或操作结果
  .delay_output(w_p0v8_sw_pg_dly100ms)  
  );

assign o_PAL_DB2000_PWRGD0	= w_p0v8_sw_pg_dly100ms ? 1'b1 : 1'b0 ;//2024-7-2 add for debug //2024-7-10 add back 用于调试等场景，指示DB2000相关的电源良好状态
assign o_PAL_DB2000_PWRGD1	= w_p0v8_sw_pg_dly100ms ? 1'b1 : 1'b0 ;
assign o_PAL_DB2000_PWRGD2	= w_p0v8_sw_pg_dly100ms ? 1'b1 : 1'b0 ;
assign o_PAL_DB2000_PWRGD3	= w_p0v8_sw_pg_dly100ms ? 1'b1 : 1'b0 ;


assign o_PAL_P12V_EN_R = w_p3v3_stby_pg_db ? 1'b1 : 1'b0 ; //控制P12V电源的使能：当w_p3v3_stby_pg_db为高电平时，o_PAL_P12V_EN_R输出1，开启P12V电源；否则输出0，关闭电源
assign o_PAL_SW_PWR_EN_R  = w_p12v_pg_db ? 1'b1 : 1'b0 ; //控制开关电源的使能：当w_p12v_pg_db为高电平时，o_PAL_SW_PWR_EN_R输出1，开启开关电源；否则输出0，关闭电源
// assign o_PAL_DB2000_PWRGD	= 1'b1 ;//2024-5-15  
// assign o_PAL_DB2000_1_PWRGD = w_pch_slp5_n & w_p12v_pg_db? 1'b1 : 1'b0 ; //2024-6-18 chg 1'b1 当w_pch_slp5_n和w_plv2_pg_db都为高电平时，o_PAL_DB2000_1_PWRGD输出1；否则输出0.结合多个信号状态，指示另一路DB2000相关的电源良好状态



 
//-------------------------------------------------------------------------------------------------
//NIC PWR SEQ
//-------------------------------------------------------------------------------------------------

wire w_retimer1_1p8_pg_dly5ms ;		//用于Retimer1模块的1P8电源良好信号延迟5ms后的输出
wire w_retimer2_1p8_pg_dly5ms ;		//用于Retimer2模块的1P8电源良好信号延迟5ms后的输出


wire w_slot1_thorttle_r; //bmc reg ctl	用于表示不同插槽（slot1 - slot8）的限流（throttle）控制信号
wire w_slot2_thorttle_r; //bmc reg ctl	bmc reg ctrl”为注释，说明这些信号与BMC寄存器控制相关
wire w_slot3_thorttln_r; //bmc reg ctl	分别对应 8 个插槽的限流控制信号，用于控制各插槽的电流，避免过载等情况。
wire w_slot4_thorttle_r; //bmc reg ctl
wire w_slot5_thorttle_r; //bmc reg ctl
wire w_slot6_thorttle_r; //bmc reg ctl
wire w_slot7_thorttle_r; //bmc reg ctl
wire w_slot8_thorttle_r; //bmc reg ctl


edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_retimer1_1p8_pg ( //DELAY_MODE =0 for rise CNTR_NBITS设为4（计数器位数，决定计数范围），DELAY_MODE设为1'b0（延迟模式，这里表示上升沿延迟等含义）
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),		//复位输入，低电平有效（~表示取反）
  .cnt_size    (4'd5),					//计数大小，这里设为5，结合cnt_step决定延迟时长
  .cnt_step    (t1ms_tick),				//计数步长输入，用于计数 输入信号，Retimer1模块的1P8电源良好信号
  .signal_in   (w_RETIMER1_1P8_PG),     //this signal from 0 to 1
  .delay_output(w_retimer1_1p8_pg_dly5ms)  //延迟后的输出信号
  );
  
edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_retimer2_1p8_pg ( //DELAY_MODE =0 for rise 
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (4'd5),
  .cnt_step    (t1ms_tick),
  .signal_in   (w_RETIMER2_1P8_PG),     //this signal from 0 to 1
  .delay_output(w_retimer2_1p8_pg_dly5ms)  
  );

// assign o_PAL_RETIMER1_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;	//当w_retimer1_1p8_pg_dly5ms为高电平时，o_PAL_RETIMER1_0P9_EN_R输出1；否则输出
// assign o_PAL_RETIMER3_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;	//根据Retimer1模块延迟后的1P8电源良好信号，控制相关0.9V电源的使能
// assign o_PAL_RETIMER5_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
// assign o_PAL_RETIMER7_0P9_EN_R = w_retimer1_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;

// assign o_PAL_RETIMER2_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;	//当w_retimer2_1p8_pg_dly5ms为高电平时，o_PAL_RETIMER2_0P9_EN_R输出1；否则输出0
// assign o_PAL_RETIMER4_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;	//根据Retimer2模块延迟后的1P8电源良好信号，控制相关0.9V电源的使能
// assign o_PAL_RETIMER6_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;
// assign o_PAL_RETIMER8_0P9_EN_R = w_retimer2_1p8_pg_dly5ms ? 1'b1 : 1'b0 ;




//-------------------------------------------------------------------------------------------------
//BP SIGNAL CONTROL 
//-------------------------------------------------------------------------------------------------


wire w_cpld_pch_rsmrst_n_dly1ms ;	//用于CPLD（复杂可编程逻辑器件）到PCH（平台控制器中心）的复位信号延迟ms后的输出

edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_pch_rsmrst_n ( //DELAY_MODE =0 for rise CNTR_NBITS设为4（计数器位数，决定计数范围），DELAY_MODE设为1'b0（延迟模式，这里表示上升沿延迟等含义）
  .clk         (clk_50m),
  .reset       (~pgd_aux_system),
  .cnt_size    (4'd1),						// 计数大小，这里设为1，结合cnt_step决定延迟时长
  .cnt_step    (t1ms_tick),
  .signal_in   (w_cpld_pch_rsmrst_n_r),     //this signal from 0 to 1 输入信号，CPLD到PCH的复位信号（低电平有效，_n表示低有效）
  .delay_output(w_cpld_pch_rsmrst_n_dly1ms) //延迟后的输出信号
  );



//-------------------------------------------------------------------------------------------------
//RST SIGNAL CONTROL （复位信号控制）
//-------------------------------------------------------------------------------------------------

wire [7:0] w_bmc_ctrl_nic_rst ;	// 是 BMC 控制 NIC 复位的 8 位信号，可对多个 NIC 设备复位进行精细控制
wire w_sw0_pex_perst_r_n;
wire w_sw1_pex_perst_r_n;
wire w_sw2_pex_perst_r_n;
wire w_sw3_pex_perst_r_n;


assign o_SW0_PEX_PERST_R_N = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back 将w_rst_pltrst_n信号分别赋值给o_SW0_PEX_PERST_N_R至o_SW3_PEX_PERST_N_R输出端口
assign o_SW1_PEX_PERST_R_N = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back	控制不同SW（可能是交换模块或插槽）的PCI Express设备复位（PERST，PCI Express Reset）
assign o_SW2_PEX_PERST_R_N = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back
assign o_SW3_PEX_PERST_R_N = w_rst_pltrst_n ;  //2024-6-22 del for debug //2024-6-26 add back



// wire w_p0v8_pg_dly250ms ; //2024-6-22 add 
// edge_delay #(.CNTR_NBITS(4), .DELAY_MODE(1'b0)) edge_delay_p0v8_pg ( //DELAY_MODE =0 for rise 
//   .clk         (clk_50m),
//   .reset       (~pgd_aux_system),
//   .cnt_size    (4'd2),
//   .cnt_step    (t128ms_tick),
//   .signal_in   (w_p0v8_sw0_pwrgd_db &
//                 w_p0v8_sw1_pwrgd_db &
//                 w_p0v8_sw2_pwrgd_db &
//                 w_p0v8_sw3_pwrgd_db  ),     //this signal from 0 to 1
//   .delay_output(w_p0v8_pg_dly250ms)  
//   );

// assign o_SW0_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;
// assign o_SW1_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;
// assign o_SW2_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;
// assign o_SW3_PEX_PERST_N_R = w_p0v8_pg_dly250ms ? 1'b1 : 1'b0 ;



assign o_NVME1_RST_R_N  = w_rst_pltrst_n ;	//控制不同SW的NVMe（非易失性内存 express）设备复位
assign o_NVME2_RST_R_N  = w_rst_pltrst_n ;
assign o_NVME3_RST_R_N  = w_rst_pltrst_n ;
assign o_NVME4_RST_R_N  = w_rst_pltrst_n ;



// assign o_NIC1_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[0] ; //2024-10-10 add & w_bmc_ctl_nic_rst 控制第1个NIC（网络接口控制器）的PCI Express设备复位（PERST，低有效，_N表示低有效，_R表示寄存器相关或高有效逻辑）
// assign o_NIC2_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[1] ; //2024-10-10 add 当w_rst_pltrst_n（系统复位信号，低有效）和w_bmc_ctrl_nic_rst[0]（BMC控制NIC复位的第0位）都为高电平时，o_NIC1_PERST_N_R输出1；否则输出0
// assign o_NIC3_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[2] ; //2024-10-10 add 
// assign o_NIC4_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[3] ; //2024-10-10 add 
// assign o_NIC5_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[4] ; //2024-10-10 add 
// assign o_NIC6_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[5] ; //2024-10-10 add 
// assign o_NIC7_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[6] ; //2024-10-10 add 
// assign o_NIC8_PERST_N_R = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[7] ; //2024-10-10 add 

assign o_NIC1A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[0]  ;
assign o_NIC1C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[0]  ;
assign o_NIC2A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[1]  ;
assign o_NIC2C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[1]  ;
assign o_NIC3A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[2]  ;
assign o_NIC3C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[2]  ;
assign o_NIC4A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[3]  ;
assign o_NIC4C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[3]  ;
assign o_NIC5A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[4]  ;
assign o_NIC5C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[4]  ;
assign o_NIC6A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[5]  ;
assign o_NIC6C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[5]  ;
assign o_NIC7A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[6]  ;
assign o_NIC7C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[6]  ;
assign o_NIC8A_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[7]  ;
assign o_NIC8C_RST_R_N = w_rst_pltrst_n & w_bmc_ctrl_nic_rst[7]  ;

assign  o_NPU1A_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU1C_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU2A_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU2C_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU3A_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU3C_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU4A_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU4C_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU5A_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU5C_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU6A_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU6C_RST_R_N	 =  w_rst_pltrst_n;   
assign  o_NPU7A_RST_R_N  = 	w_rst_pltrst_n;   
assign  o_NPU7C_RST_R_N  = 	w_rst_pltrst_n;   
assign  o_NPU8A_RST_R_N  = 	w_rst_pltrst_n;   
assign  o_NPU8C_RST_R_N  = 	w_rst_pltrst_n;   



//-------------------------------------------------------------------------------------------------
//BREATH LED //2024-5-16 add
//-------------------------------------------------------------------------------------------------

wire w_debug_led1 ;			//用于调试LED的中间信号
// 实例化breath_led模块，模块名为debug_led1
breath_led debug_led1(
    .sys_clk     (clk_50m),  //时钟信号50Mhz
    .sys_rst_n   (pon_reset_n),  //复位信号
	.sys_pwr_ok  (w_p3v3_stby_pg_db), // 系统电源良好信号，3.3V待机电源稳定后为高

    .led         (o_debug_led1)     // 呼吸灯输出信号，控制LED的呼吸效果
);

assign o_debug_led1 = w_debug_led1;//将w_debug_led1信号赋值给o_debug_led1输出端口，传递呼吸灯控制信号



/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//PWR SEQ End 电源时序结束标识
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/


//-------------------------------------------------------------------------------------------------
//SW_CS_SEL 交换模块片选选择
//-------------------------------------------------------------------------------------------------

reg r_sw0_spi_cs_sel_r ; //用于SPI（串行外设接口）片选控制
reg r_sw1_spi_cs_sel_r ;
reg r_sw2_spi_cs_sel_r ;
reg r_sw3_spi_cs_sel_r ;

// 声明寄存器，用于各交换模块SPI片选的错误标志
reg r_sw0_spi_cs_sel_err_flag ;//声明的错误标志寄存器（r_sw0_spi_cs_sel_err_flag 等）用于标记各交换模块 SPI 片选过程中的错误状态，便于系统故障检测与诊断
reg r_sw1_spi_cs_sel_err_flag ;
reg r_sw2_spi_cs_sel_err_flag ;
reg r_sw3_spi_cs_sel_err_flag ;


//SW0模块的时序逻辑，在时钟 clk_50m 上升沿或复位信号 pon_reset_n 下降沿触发
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw0_spi_cs_sel_r <= 1'b0;			// SPI 片选信号置为 0，不选中任何 SPI 从设备
		r_sw0_spi_cs_sel_err_flag <=1'b0;	// SPI 片选错误标志置为 0，表示无错误
	end
	else if((w_MCIO01A_CFG_N_R == 1'b0) & (w_MCIO01C_CFG_N_R == 1'b0) &&   
	        (w_MCIO02A_CFG_N_R == 1'b1) & (w_MCIO02C_CFG_N_R == 1'b1) )begin	//当 w_MCIO01A_CFG_N_R、w_MCIO01C_CFG_N_R 为 0，且 w_MCIO02A_CFG_N_R、w_MCIO02C_CFG_N_R 为 1 时
		r_sw0_spi_cs_sel_r <= 1'b0;			  // SPI 片选信号置为 0
		r_sw0_spi_cs_sel_err_flag <=1'b0;	  // 错误标志置为 0，此配置下无错误	
	end
	else if((w_MCIO01A_CFG_N_R == 1'b0) & (w_MCIO01C_CFG_N_R == 1'b0) &&   
	        (w_MCIO02A_CFG_N_R == 1'b0) & (w_MCIO02C_CFG_N_R == 1'b0) )begin	//当 w_MCIO01A_CFG_N_R、w_MCIO01C_CFG_N_R、w_MCIO02A_CFG_N_R、w_MCIO02C_CFG_N_R 都为 0 时
		r_sw0_spi_cs_sel_r <= 1'b1;				// SPI 片选信号置为 1，选中对应 SPI 从设备
		r_sw0_spi_cs_sel_err_flag <=1'b0;		// 错误标志置为 0，此配置合法
	end
	else begin
		r_sw0_spi_cs_sel_r <= 1'b0;				 // SPI 片选信号置为 0
		r_sw0_spi_cs_sel_err_flag <=1'b1;		 // 错误标志置为 1，表示配置异常
	end
end
//w_MCIOXXA_CFG_N_R、w_MCIOXXC_CFG_N_R（XX 为 01、11、21、31 等）：是MCIO 接口的配置信号（_N 表示低电平有效，_R 表示与寄存器或高有效逻辑相关）
//用于指示 MCIO 接口的工作模式或状态，代码中通过这些信号的组合判断当前配置是否合法，进而决定 SPI 片选和错误标志的状态
//SW1
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw1_spi_cs_sel_r <= 1'b0;
		r_sw1_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO11A_CFG_N_R == 1'b0) & (w_MCIO11C_CFG_N_R == 1'b0) &&   
	        (w_MCIO12A_CFG_N_R == 1'b1) & (w_MCIO12C_CFG_N_R == 1'b1) )begin
		r_sw1_spi_cs_sel_r <= 1'b0;
		r_sw1_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO11A_CFG_N_R == 1'b0) & (w_MCIO11C_CFG_N_R == 1'b0) &&   
	        (w_MCIO12A_CFG_N_R == 1'b0) & (w_MCIO12C_CFG_N_R == 1'b0) )begin
		r_sw1_spi_cs_sel_r <= 1'b1;
		r_sw1_spi_cs_sel_err_flag <=1'b0;
	end
	else begin
		r_sw1_spi_cs_sel_r <= 1'b0;
		r_sw1_spi_cs_sel_err_flag <=1'b1;
	end
end

//SW2
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw2_spi_cs_sel_r <= 1'b0;
		r_sw2_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO21A_CFG_N_R == 1'b0) & (w_MCIO21C_CFG_N_R == 1'b0) &&   
	        (w_MCIO22A_CFG_N_R == 1'b1) & (w_MCIO22C_CFG_N_R == 1'b1) )begin
		r_sw2_spi_cs_sel_r <= 1'b0;
		r_sw2_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO21A_CFG_N_R == 1'b0) & (w_MCIO21C_CFG_N_R == 1'b0) &&   
	        (w_MCIO22A_CFG_N_R == 1'b0) & (w_MCIO22C_CFG_N_R == 1'b0) )begin
		r_sw2_spi_cs_sel_r <= 1'b1;
		r_sw2_spi_cs_sel_err_flag <=1'b0;
	end
	else begin
		r_sw2_spi_cs_sel_r <= 1'b0;
		r_sw2_spi_cs_sel_err_flag <=1'b1;
	end
end

//SW3
always@(posedge clk_50m or negedge pon_reset_n) begin
	if(~pon_reset_n) begin
		r_sw3_spi_cs_sel_r <= 1'b0;
		r_sw3_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO31A_CFG_N_R == 1'b0) & (w_MCIO31C_CFG_N_R == 1'b0) &&   
	        (w_MCIO32A_CFG_N_R == 1'b1) & (w_MCIO32C_CFG_N_R == 1'b1) )begin
		r_sw3_spi_cs_sel_r <= 1'b0;
		r_sw3_spi_cs_sel_err_flag <=1'b0;
	end
	else if((w_MCIO31A_CFG_N_R == 1'b0) & (w_MCIO31C_CFG_N_R == 1'b0) &&   
	        (w_MCIO32A_CFG_N_R == 1'b0) & (w_MCIO32C_CFG_N_R == 1'b0) )begin
		r_sw3_spi_cs_sel_r <= 1'b1;
		r_sw3_spi_cs_sel_err_flag <=1'b0;
	end
	else begin
		r_sw3_spi_cs_sel_r <= 1'b0;
		r_sw3_spi_cs_sel_err_flag <=1'b1;
	end
end


// assign o_SW0_SPI_CS_SEL_R = r_sw0_spi_cs_sel_r ;  //将各SW模块的SPI片选寄存器值直接赋值给对应输出端口
// assign o_SW1_SPI_CS_SEL_R = r_sw1_spi_cs_sel_r ;
// assign o_SW2_SPI_CS_SEL_R = r_sw2_spi_cs_sel_r ;
// assign o_SW3_SPI_CS_SEL_R = r_sw3_spi_cs_sel_r ;

wire [3:0] w_bmc_ctrl_sw_mode;	//用于BMC（基板管理控制器）控制SW（交换模块）的模式
wire [3:0] w_bmc_ctrl_sw_mode_mask;//2024-9-12 用于BMC控制SW模式的掩码


// assign o_SW0_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[0] ? r_sw0_spi_cs_sel_r : w_bmc_ctrl_sw_mode[0]; //根据w_bmc_ctrl_sw_mode[0]和w_bmc_ctrl_sw_mode_mask[0]的状态，选择输出r_sw0_spi_cs_sel_r或w_bmc_ctrl_sw_mode[0]，控制SW0的SPI片选
// assign o_SW1_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[1] ? r_sw1_spi_cs_sel_r : w_bmc_ctrl_sw_mode[1]; //2024-9-9 add for debug 
// assign o_SW2_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[2] ? r_sw2_spi_cs_sel_r : w_bmc_ctrl_sw_mode[2]; //2024-9-9 add for debug 
// assign o_SW3_SPI_CS_SEL_R = w_bmc_ctrl_sw_mode_mask[3] ? r_sw3_spi_cs_sel_r : w_bmc_ctrl_sw_mode[3]; //2024-9-9 add for debug 

assign o_SW0_SPI_CS_SEL_R = 1'b1;
assign o_SW1_SPI_CS_SEL_R = 1'b1;
assign o_SW2_SPI_CS_SEL_R = 1'b1;
assign o_SW3_SPI_CS_SEL_R = 1'b1;

// assign o_SW0_PAL_SPI_SEL_R = w_bmc_ctrl_sw_mode_mask[0] ? r_sw0_spi_cs_sel_r : w_bmc_ctrl_sw_mode[0];//控制 SPI 总线对 SW0 的片选
// assign o_SW1_PAL_SPI_SEL_R = w_bmc_ctrl_sw_mode_mask[1] ? r_sw1_spi_cs_sel_r : w_bmc_ctrl_sw_mode[1];
// assign o_SW2_PAL_SPI_SEL_R = w_bmc_ctrl_sw_mode_mask[2] ? r_sw2_spi_cs_sel_r : w_bmc_ctrl_sw_mode[2];
// assign o_SW3_PAL_SPI_SEL_R = w_bmc_ctrl_sw_mode_mask[3] ? r_sw3_spi_cs_sel_r : w_bmc_ctrl_sw_mode[3];

assign o_SW0_PAL_SPI_SEL_R = 1'bz;
assign o_SW1_PAL_SPI_SEL_R = 1'bz;
assign o_SW2_PAL_SPI_SEL_R = 1'bz;
assign o_SW3_PAL_SPI_SEL_R = 1'bz;

assign o_PAL_RST_SW0_3_NIC_VPP1_N_R = w_pal_rst_sw0_3_nic_vpp1_n_r;
assign o_PAL_RST_SW0_VPP2_N_R = w_pal_rst_sw0_vpp2_n_r;
assign o_PAL_RST_SW1_VPP2_N_R = w_pal_rst_sw1_vpp2_n_r;
assign o_PAL_RST_SW2_VPP2_N_R = w_pal_rst_sw2_vpp2_n_r;
assign o_PAL_RST_SW3_VPP2_N_R = w_pal_rst_sw3_vpp2_n_r;

assign  o_SW0_NPU_CLK_OE_N_R = w_sw0_npu_clk_oe_n_r;
assign  o_SW1_NPU_CLK_OE_N_R = w_sw1_npu_clk_oe_n_r;
assign  o_SW2_NPU_CLK_OE_N_R = w_sw2_npu_clk_oe_n_r;
assign  o_SW3_NPU_CLK_OE_N_R = w_sw3_npu_clk_oe_n_r;

assign  o_SW0_MCIO2_CLK_OE_N_R = w_sw0_mcio2_clk_oe_n_r;
assign  o_SW1_MCIO2_CLK_OE_N_R = w_sw1_mcio2_clk_oe_n_r;
assign  o_SW2_MCIO2_CLK_OE_N_R = w_sw2_mcio2_clk_oe_n_r;
assign  o_SW3_MCIO2_CLK_OE_N_R = w_sw3_mcio2_clk_oe_n_r;

assign  o_MCIO01A_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO01C_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO02A_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO11A_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO11C_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO12A_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO21A_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO21C_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO22A_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO31A_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO31C_PE_RST_R_N = w_rst_pltrst_n;
assign  o_MCIO32A_PE_RST_R_N = w_rst_pltrst_n;




//-------------------------------------------------------------------------------------------------
// Output SIGNAL
//-------------------------------------------------------------------------------------------------
assign  o_CPLD1_LED0_N = 1'bz;
assign  o_CPLD1_LED1_N = 1'bz;

assign  o_SW0_SDB_RX_R	 = 1'bz;   
assign  o_SW1_SDB_RX_R	 = 1'bz;   
assign  o_SW2_SDB_RX_R	 = 1'bz;   
assign  o_SW3_SDB_RX_R	 = 1'bz;   

assign  o_SW0_UART_RX_R	 = 1'bz;     
assign  o_SW1_UART_RX_R	 = 1'bz;     
assign  o_SW2_UART_RX_R	 = 1'bz;     
assign  o_SW3_UART_RX_R	 = 1'bz;     
assign  o_BMC_SW_UART_RX0_R = 1'bz;

assign  o_PAL_SW0_3_VPP_S0_R	    = 1'b0;
assign  o_PAL_SW0_3_VPP_S1_R	    = 1'b0;

assign  o_PAL_SPI_CSCLK_S0_R	    = 1'b0;
assign  o_PAL_SPI_CSCLK_S1_R	    = 1'b0;

assign  o_PAL_SPI_MISOMOSI_S0_R	  = 1'b0;
assign  o_PAL_SPI_MISOMOSI_S1_R	  = 1'b0;

assign  o_CPLD_RSV1	   = 1'bz;      
assign  o_CPLD_RSV2	   = 1'bz;      
assign  o_CPLD_RSV3	   = 1'bz;      
assign  o_CPLD_RSV4	   = 1'bz;      
assign  o_CPLD_RSV5	   = 1'bz;      
assign  o_CPLD_RSV6	   = 1'bz;  

assign  o_NVME1_RSV_R  = 1'bz; 	        
assign  o_NVME2_RSV_R  = 1'bz; 	        
assign  o_NVME3_RSV_R  = 1'bz; 	        
assign  o_NVME4_RSV_R  = 1'bz;	 

assign  o_MCIO01A_CB_RSV_R	= 1'bz;       
assign  o_MCIO01C_CB_RSV_R	= 1'bz;       
assign  o_MCIO02A_CB_RSV_R	= 1'bz;       
assign  o_MCIO02C_CB_RSV_R	= 1'bz;       
assign  o_MCIO11A_CB_RSV_R	= 1'bz;       
assign  o_MCIO11C_CB_RSV_R	= 1'bz;       
assign  o_MCIO12A_CB_RSV_R	= 1'bz;       
assign  o_MCIO12C_CB_RSV_R	= 1'bz;       
assign  o_MCIO21A_CB_RSV_R	= 1'bz;       
assign  o_MCIO21C_CB_RSV_R	= 1'bz;       
assign  o_MCIO22A_CB_RSV_R	= 1'bz;       
assign  o_MCIO22C_CB_RSV_R	= 1'bz;       
assign  o_MCIO31A_CB_RSV_R	= 1'bz;       
assign  o_MCIO31C_CB_RSV_R	= 1'bz;       
assign  o_MCIO32A_CB_RSV_R	= 1'bz;       
assign  o_MCIO32C_CB_RSV_R	= 1'bz;       
       
assign  o_NPU1A_RSV_R  = 1'bz;	  
assign  o_NPU1C_RSV_R  = 1'bz;	  
assign  o_NPU2A_RSV_R  = 1'bz;	  
assign  o_NPU2C_RSV_R  = 1'bz;	  
assign  o_NPU3A_RSV_R  = 1'bz;	  
assign  o_NPU3C_RSV_R  = 1'bz;	  
assign  o_NPU4A_RSV_R  = 1'bz;	  
assign  o_NPU4C_RSV_R  = 1'bz;	  
assign  o_NPU5A_RSV_R	 = 1'bz;    
assign  o_NPU5C_RSV_R	 = 1'bz;    
assign  o_NPU6A_RSV_R  = 1'bz;	  
assign  o_NPU6C_RSV_R  = 1'bz;	  
assign  o_NPU7A_RSV_R  = 1'bz;	  
assign  o_NPU7C_RSV_R  = 1'bz;	  
assign  o_NPU8A_RSV_R  = 1'bz;	  
assign  o_NPU8C_RSV_R  = 1'bz;	  

assign  o_NIC1A_RSV_R  = 1'bz; 
assign  o_NIC1C_RSV_R  = 1'bz; 
assign  o_NIC2A_RSV_R  = 1'bz; 
assign  o_NIC2C_RSV_R  = 1'bz; 
assign  o_NIC3A_RSV_R  = 1'bz; 
assign  o_NIC3C_RSV_R  = 1'bz; 
assign  o_NIC4A_RSV_R  = 1'bz; 
assign  o_NIC4C_RSV_R  = 1'bz; 
assign  o_NIC5A_RSV_R  = 1'bz; 
assign  o_NIC5C_RSV_R  = 1'bz; 
assign  o_NIC6A_RSV_R  = 1'bz; 
assign  o_NIC6C_RSV_R  = 1'bz; 
assign  o_NIC7A_RSV_R  = 1'bz; 
assign  o_NIC7C_RSV_R  = 1'bz; 
assign  o_NIC8A_RSV_R  = 1'bz; 
assign  o_NIC8C_RSV_R  = 1'bz; 

assign  o_NVME1_POWER_EN_R	= 1'bz;        
assign  o_NVME2_POWER_EN_R	= 1'bz;        
assign  o_NVME3_POWER_EN_R	= 1'bz;        
assign  o_NVME4_POWER_EN_R	= 1'bz;    

assign  o_NPU1A_POWER_EN_R	 = 1'bz;   
assign  o_NPU1C_POWER_EN_R	 = 1'bz;   
assign  o_NPU2A_POWER_EN_R	 = 1'bz;   
assign  o_NPU2C_POWER_EN_R	 = 1'bz;   
assign  o_NPU3A_POWER_EN_R	 = 1'bz;   
assign  o_NPU3C_POWER_EN_R	 = 1'bz;   
assign  o_NPU4A_POWER_EN_R	 = 1'bz;   
assign  o_NPU4C_POWER_EN_R	 = 1'bz;   
assign  o_NPU5A_POWER_EN_R	 = 1'bz;   
assign  o_NPU5C_POWER_EN_R	 = 1'bz;   
assign  o_NPU6A_POWER_EN_R	 = 1'bz;   
assign  o_NPU6C_POWER_EN_R	 = 1'bz;   
assign  o_NPU7A_POWER_EN_R	 = 1'bz;   
assign  o_NPU7C_POWER_EN_R	 = 1'bz;   
assign  o_NPU8A_POWER_EN_R	 = 1'bz;   
assign  o_NPU8C_POWER_EN_R	 = 1'bz; 

assign  o_NIC1A_POWER_EN_R	 = 1'bz;
assign  o_NIC1C_POWER_EN_R	 = 1'bz;
assign  o_NIC2A_POWER_EN_R	 = 1'bz;
assign  o_NIC2C_POWER_EN_R	 = 1'bz;
assign  o_NIC3A_POWER_EN_R	 = 1'bz;
assign  o_NIC3C_POWER_EN_R	 = 1'bz;
assign  o_NIC4A_POWER_EN_R	 = 1'bz;
assign  o_NIC4C_POWER_EN_R	 = 1'bz;
assign  o_NIC5A_POWER_EN_R	 = 1'bz;
assign  o_NIC5C_POWER_EN_R	 = 1'bz;
assign  o_NIC6A_POWER_EN_R	 = 1'bz;
assign  o_NIC6C_POWER_EN_R	 = 1'bz;
assign  o_NIC7A_POWER_EN_R	 = 1'bz;
assign  o_NIC7C_POWER_EN_R	 = 1'bz;
assign  o_NIC8A_POWER_EN_R	 = 1'bz;
assign  o_NIC8C_POWER_EN_R	 = 1'bz;



/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//I2C Update Start（I2C更新开始，标识I2C相关更新逻辑的起始）
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/
wire wb_clk;// 声明线网信号wb_clk，用于Wishbone总线时钟 是由 OSCH 模块生成的时钟信号，作为 Wishbone 总线的时钟源，为后续 I2C_UPDATE 模块等基于 Wishbone 总线的逻辑提供时序基准，保障总线通信的同步性
defparam inst_osch.NOM_FREQ = "4.29";// 调用defparam语句，为inst_osc模块设置参数inst_osc.NOM_FREQ为"4.29"（可能是设置振荡器标称频率）
OSCH inst_osch(				// 实例化OSCH模块，模块名为inst_osc，用于生成时钟信号
.STDBY		(1'b0		),	// 待机控制信号，1'b0表示不进入待机，正常工作
.OSC		(wb_clk		),	// 输出时钟信号，连接到wb_clk
.SEDSTDBY	(			)	// 待机状态输出，此处未使用
);
// 实例化I2C_UPDATE模块，模块名为inst_i2c_update_flash_config，用于I2C更新闪存配置
I2C_UPDATE inst_i2c_update_flash_config(
.wb_clk_i	(wb_clk	),		// Wishbone总线时钟输入，来自inst_osc生成的wb_clk
.wb_rst_i	(		),		// Wishbone总线复位输入，此处未连接
.wb_cyc_i	(		),		// Wishbone总线周期输入，此处未连接
.wb_stb_i	(		),		// Wishbone总线选通输入，此处未连接
.wb_we_i	(		),		// Wishbone总线选通输入，此处未连接
.wb_adr_i	(		),		// Wishbone总线地址输入，此处未连接
.wb_dat_i	(		),		// Wishbone总线数据输入，此处未连接
.wb_dat_o	(		),		// Wishbone总线数据输出，此处未连接
.wb_ack_o	(		),		// Wishbone总线响应输出，此处未连接
.i2c1_irqo	(						),	// I2C中断请求输出，此处未连接
.i2c1_scl	(io_I2C1_CPLD1_UPDATE_SCL),	// I2C SCL（时钟）信号
.i2c1_sda	(io_I2C1_CPLD1_UPDATE_SDA)	// I2C SDA（数据）信号

);
/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
//I2C Update End
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/

/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
// I2C RAM  Start （I2C RAM相关逻辑开始）
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/
wire [7:0] w_pca_ver;	
wire [7:0] w_pcb_ver;		//位宽[7:0]，用于存储PCB（印刷电路板）版本信息
wire [7:0] w_board_id ;		//位宽[7:0]，用于存储板卡ID信息

wire [7:0] w_nic_pcb_ver;	// 声明线网信号w_nic_pcb_ver，位宽[7:0]，用于存储NIC（网络接口控制器）PCB版本信息
wire [7:0] w_nic_board_id  ;// 声明线网信号w_nic_board_id，位宽[7:0]，用于存储NIC板卡ID信息

assign w_pca_ver  = {5'b0,w_PCA_ID2,w_PCA_ID1,w_PCA_ID0};	
assign w_pcb_ver  = {5'b0,w_PCB_ID2,w_PCB_ID1,w_PCB_ID0};	//将w_PCB_ID2、w_PCB_ID1、w_PCB_ID0拼接成8位信号，赋值给w_pcb_ver（高5位补0），生成PCB版本信息
assign w_board_id = {3'b00,w_BOARD_ID4,w_BOARD_ID3,w_BOARD_ID2,w_BOARD_ID1,w_BOARD_ID0};//将w_BOARD_ID4、w_BOARD_ID3、w_BOARD_ID2、w_BOARD_ID1、w_BOARD_ID0拼接成8位信号，赋值给w_board_id（高3位补0），生成板卡ID信息


assign w_nic_pcb_ver  = {5'b0,w_NIC_PCB_VER_ID2,w_NIC_PCB_VER_ID1,w_NIC_PCB_VER_ID0};//将w_NIC_PCB_VER_ID2、w_NIC_PCB_VER_ID1、w_NIC_PCB_VER_ID0拼接成8位信号，赋值给w_nic_pcb_ver（高5位补0），生成NIC PCB版本信息
assign w_nic_board_id = {3'b00,w_NIC_BOARD_ID4,w_NIC_BOARD_ID3,w_NIC_BOARD_ID2,w_NIC_BOARD_ID1,w_NIC_BOARD_ID0};//将w_NIC_BOARD_ID4、w_NIC_BOARD_ID3、w_NIC_BOARD_ID2、w_NIC_BOARD_ID1、w_NIC_BOARD_ID0拼接成8位信号，赋值给w_nic_board_id（高3位补0），生成NIC板卡ID信息


bmc_cpld_i2c_ram #(
.DLY_LEN       (16)   //50MHz,330ns
)bmc_cpld_i2c_ram
(
.i_rst_n        (pon_reset_n            ) ,
.i_clk          (clk_25m	            ) ,
.i_1ms_clk      (t1ms_tick              ) ,	          //t1ms_tick
.i_rst_i2c_n    (1'b1                   ) ,
.i_scl          (i_I2C1_CPLD1_REG_SCL         ) ,
.io_sda         (io_I2C1_CPLD1_REG_SDA        ) ,

.i_product_id	                        (`PRODUCT_ID)          			    , //addr 0x0000
.i_vender_id	                        (`VENDER_ID)          			    , //addr 0x0001
.i_board_id		                        (w_board_id)          	            , //addr 0x0002
.i_pcb_version	                        (w_pcb_ver)                         , //addr 0x0003
.i_bom_id		                        (w_pca_ver)      	                    , //addr 0x0004
.i_cpld_version	                        (`CPLD_VERSION)          		    , //addr 0x0005
.o_test_reg		                        (	  )                             , //addr 0x0006
.i_year			                        (`Year)                             , //addr 0x0007
.i_month		                        (`Month)                            , //addr 0x0008
.i_day			                        (`Day)                              , //addr 0x0009
.i_ncpin                                (w_nc_pin      )                    , //addr 0x000a bit0
.i_cpld_compa_version	                (8'h00)                             , //addr 0x000b 
.i_cpld_debug_version	                (`DEBUG_VERSION)                    , //addr 0x000c


.i_nic_board_id		                    (w_nic_board_id)          	        , //addr 0x0010
.i_nic_pcb_version	                  (w_nic_pcb_ver)                     , //addr 0x0011

//MCIO
.i_MCIO01A_ALERT_R_N	              (i_MCIO01A_ALERT_R_N)             , //addr 0x0012  bit7
.i_MCIO01C_ALERT_R_N	              (i_MCIO01C_ALERT_R_N)             , //addr 0x0012  bit6
.i_MCIO11A_ALERT_R_N                (i_MCIO11A_ALERT_R_N)             , //addr 0x0012  bit5
.i_MCIO11C_ALERT_R_N                (i_MCIO11C_ALERT_R_N)             , //addr 0x0012  bit4
.i_MCIO21A_ALERT_R_N                (i_MCIO21A_ALERT_R_N)             , //addr 0x0012  bit3
.i_MCIO21C_ALERT_R_N                (i_MCIO21C_ALERT_R_N)             , //addr 0x0012  bit2
.i_MCIO31A_ALERT_R_N                (i_MCIO31A_ALERT_R_N)             , //addr 0x0012  bit1
.i_MCIO31C_ALERT_R_N                (i_MCIO31C_ALERT_R_N)             , //addr 0x0012  bit0


// .i_PAL_RAA_CFP_R                        (i_PAL_RAA_CFP_R    )               , //addr 0x0013  bit7
.i_p0v8_sw0_pwrgd_db                    (w_p0v8_sw0_pwrgd_db)               , //addr 0x0013  bit6
.i_p0v8_sw1_pwrgd_db                    (w_p0v8_sw1_pwrgd_db)               , //addr 0x0013  bit5
.i_p0v8_sw2_pwrgd_db                    (w_p0v8_sw2_pwrgd_db)               , //addr 0x0013  bit4
.i_p0v8_sw3_pwrgd_db                    (w_p0v8_sw3_pwrgd_db)               , //addr 0x0013  bit3
.i_PG_P5V0_R                            (i_PG_P5V0_R        )               , //addr 0x0013  bit2
.i_PG_P1V8_R	                          (w_pg_p1v8_r_db      )              , //addr 0x0013  bit1  //2024-6-29 add
.i_PG_P1V8_PLL_R                        (w_pg_p1v8_pll_r_db  )              , //addr 0x0013  bit0  //2024-6-29 add

.i_NVME1_ALERT_R_N                      (i_NVME1_ALERT_R_N    )             , //addr 0x0014  bit7
.i_NVME2_ALERT_R_N                      (i_NVME2_ALERT_R_N    )             , //addr 0x0014  bit6
.i_NVME3_ALERT_R_N                      (i_NVME3_ALERT_R_N    )             , //addr 0x0014  bit5
.i_NVME4_ALERT_R_N                      (i_NVME4_ALERT_R_N    )             , //addr 0x0014  bit4


.i_SW0_NIC_ALERT_R_N                     (i_SW0_NIC_ALERT_R_N)                , //addr 0x0015  bit7
.i_SW1_NIC_ALERT_R_N                     (i_SW1_NIC_ALERT_R_N)                , //addr 0x0015  bit6
.i_SW2_NIC_ALERT_R_N                     (i_SW2_NIC_ALERT_R_N)                , //addr 0x0015  bit5
.i_SW3_NIC_ALERT_R_N                     (i_SW3_NIC_ALERT_R_N)                , //addr 0x0015  bit4

.i_BASE0_VPP_INT_N_R                      (i_BASE0_VPP_INT_N_R)               , //addr 0x0016  bit7
.i_BASE1_VPP_INT_N_R                      (i_BASE1_VPP_INT_N_R)               , //addr 0x0016  bit6
.i_BASE2_VPP_INT_N_R                      (i_BASE2_VPP_INT_N_R)               , //addr 0x0016  bit5
.i_BASE3_VPP_INT_N_R                      (i_BASE3_VPP_INT_N_R)               , //addr 0x0016  bit4

.i_MB_VPP0_ALT_R_N                     (i_MB_VPP0_ALT_R_N)                , //addr 0x0017  bit7
.i_MB_VPP1_ALT_R_N                     (i_MB_VPP1_ALT_R_N)                , //addr 0x0017  bit6
.i_MB_VPP2_ALT_R_N                     (i_MB_VPP2_ALT_R_N)                , //addr 0x0017  bit5
.i_MB_VPP3_ALT_R_N                     (i_MB_VPP3_ALT_R_N)                , //addr 0x0017  bit4


.i_PAL_SW_GPU_PRSNT_R_N                 (i_PAL_SW_GPU_PRSNT_R_N  )         , //addr 0x0018  bit7
.i_PAL_P12V_STBY_FLTB                   (i_PAL_P12V_STBY_FLTB  )           , //addr 0x0018  bit6
.i_PAL_P12V_OC                          (i_PAL_P12V_OC)                    , //addr 0x0018  bit5
.i_P12V_SNS_ALERT                       (i_P12V_SNS_ALERT)                 , //addr 0x0018  bit4

.i_NVME1_PRSNT0_R_N	                    (i_NVME1_PRSNT0_R_N     )          , //addr 0x0019  bit7
.i_NVME1_PRSNT1_R_N	                    (i_NVME1_PRSNT1_R_N	    )          , //addr 0x0019  bit6
.i_NVME2_PRSNT0_R_N                     (i_NVME2_PRSNT0_R_N     )          , //addr 0x0019  bit5
.i_NVME2_PRSNT1_R_N                     (i_NVME2_PRSNT1_R_N     )          , //addr 0x0019  bit4


.o_SW0_PEX_PERST_R_N                       (w_sw0_pex_perst_r_n)                  , //addr 0x001b  bit7 //default 1
.o_SW1_PEX_PERST_R_N                       (w_sw1_pex_perst_r_n)                  , //addr 0x001b  bit6 //default 1
.o_SW2_PEX_PERST_R_N                       (w_sw2_pex_perst_r_n)                  , //addr 0x001b  bit5 //default 1
.o_SW3_PEX_PERST_R_N                       (w_sw3_pex_perst_r_n)                  , //addr 0x001b  bit4 //default 1


.o_PAL_RST_SW0_3_NIC_VPP1_N_R               (w_pal_rst_sw0_3_nic_vpp1_n_r)          , //addr 0x001c  bit7 //default 1
.o_PAL_RST_SW0_VPP2_N_R                     (w_pal_rst_sw0_vpp2_n_r      )          , //addr 0x001c  bit6 //default 1
.o_PAL_RST_SW1_VPP2_N_R                     (w_pal_rst_sw1_vpp2_n_r)                , //addr 0x001c  bit5 //default 1
.o_PAL_RST_SW2_VPP2_N_R                     (w_pal_rst_sw2_vpp2_n_r)                , //addr 0x001c  bit4 //default 1
.o_PAL_RST_SW3_VPP2_N_R                     (w_pal_rst_sw3_vpp2_n_r)                , //addr 0x001c  bit3 //default 1


//CLK OE
.o_SW0_NPU_CLK_OE_N_R                       (w_sw0_npu_clk_oe_n_r)                  , //addr 0x001d  bit7 //default 1
.o_SW1_NPU_CLK_OE_N_R                       (w_sw1_npu_clk_oe_n_r)                  , //addr 0x001d  bit6 //default 1
.o_SW2_NPU_CLK_OE_N_R                       (w_sw2_npu_clk_oe_n_r)                  , //addr 0x001d  bit5 //default 1
.o_SW3_NPU_CLK_OE_N_R                       (w_sw3_npu_clk_oe_n_r)                  , //addr 0x001d  bit4 //default 1
.o_SW0_MCIO2_CLK_OE_N_R                     (w_sw0_mcio2_clk_oe_n_r)                , //addr 0x001d  bit3 //default 1
.o_SW1_MCIO2_CLK_OE_N_R                     (w_sw1_mcio2_clk_oe_n_r)                , //addr 0x001d  bit2 //default 1
.o_SW2_MCIO2_CLK_OE_N_R                     (w_sw2_mcio2_clk_oe_n_r)                , //addr 0x001d  bit1 //default 1
.o_SW3_MCIO2_CLK_OE_N_R                     (w_sw3_mcio2_clk_oe_n_r)                , //addr 0x001d  bit0 //default 1


.i_sw0_spi_cs_sel_err_flag              (r_sw0_spi_cs_sel_err_flag)         , //addr 0x001f  bit7 
.i_sw1_spi_cs_sel_err_flag              (r_sw1_spi_cs_sel_err_flag)         , //addr 0x001f  bit6 
.i_sw2_spi_cs_sel_err_flag              (r_sw2_spi_cs_sel_err_flag)         , //addr 0x001f  bit5 
.i_sw3_spi_cs_sel_err_flag              (r_sw3_spi_cs_sel_err_flag)         , //addr 0x001f  bit4 

.i_TEMP_ALERT_0_R                       (w_TEMP_ALERT_0_R)                  , //addr 0x0020  bit7 
.i_TEMP_ALERT_1_R                       (w_TEMP_ALERT_1_R)                  , //addr 0x0020  bit6 
.i_TEMP_ALERT_2_R                       (w_TEMP_ALERT_2_R)                  , //addr 0x0020  bit5 
.i_TEMP_ALERT_3_R                       (w_TEMP_ALERT_3_R)                  , //addr 0x0020  bit4 

.i_SW0_CLKREQ_N_R                       (w_SW0_CLKREQ_N_R  )                , //addr 0x0021  bit7 
.i_SW1_CLKREQ_N_R                       (w_SW1_CLKREQ_N_R  )                , //addr 0x0021  bit6 
.i_SW2_CLKREQ_N_R                       (w_SW2_CLKREQ_N_R  )                , //addr 0x0021  bit5 
.i_SW3_CLKREQ_N_R                       (w_SW3_CLKREQ_N_R  )                , //addr 0x0021  bit4 
.i_P0V8_SW0_ALERT_N                     (w_P0V8_SW0_ALERT_N)                , //addr 0x0021  bit3 
.i_P0V8_SW1_ALERT_N                     (w_P0V8_SW1_ALERT_N)                , //addr 0x0021  bit2 
.i_P0V8_SW2_ALERT_N                     (w_P0V8_SW2_ALERT_N)                , //addr 0x0021  bit1 
.i_P0V8_SW3_ALERT_N                     (w_P0V8_SW3_ALERT_N)                , //addr 0x0021  bit0 

.i_P0V8_SW0_VRHOT_N                     (w_P0V8_SW0_VRHOT_N)                , //addr 0x0022  bit7 
.i_P0V8_SW1_VRHOT_N                     (w_P0V8_SW1_VRHOT_N)                , //addr 0x0022  bit6 
.i_P0V8_SW2_VRHOT_N                     (w_P0V8_SW2_VRHOT_N)                , //addr 0x0022  bit5 
.i_P0V8_SW3_VRHOT_N                     (w_P0V8_SW3_VRHOT_N)                , //addr 0x0022  bit4 
.i_P0V8_SW0_FAULT_N                     (w_P0V8_SW0_FAULT_N)                , //addr 0x0022  bit3 
.i_P0V8_SW1_FAULT_N                     (w_P0V8_SW1_FAULT_N)                , //addr 0x0022  bit2 
.i_P0V8_SW2_FAULT_N                     (w_P0V8_SW2_FAULT_N)                , //addr 0x0022  bit1 
.i_P0V8_SW3_FAULT_N                     (w_P0V8_SW3_FAULT_N)                , //addr 0x0022  bit0 

.i_NPU1_4_WAKE_R_N                         (i_NPU1_4_WAKE_R_N)                    , //addr 0x0023  bit7 
.i_NPU5_8_WAKE_R_N                         (i_NPU5_8_WAKE_R_N)                    , //addr 0x0023  bit6 
.i_NIC1_4_WAKE_R_N                         (i_NIC1_4_WAKE_R_N)                    , //addr 0x0023  bit5 
.i_NIC5_8_WAKE_R_N                         (i_NIC5_8_WAKE_R_N)                    , //addr 0x0023  bit4 


.i_NIC1A_PRSNT0_R_N                         (i_NIC1A_PRSNT0_R_N)                 , //addr 0x0024 bit7 
.i_NIC1A_PRSNT1_R_N                         (i_NIC1A_PRSNT1_R_N)                 , //addr 0x0024 bit6 
.i_NIC1C_PRSNT0_R_N                         (i_NIC1C_PRSNT0_R_N)                 , //addr 0x0024 bit5 
.i_NIC1C_PRSNT1_R_N                         (i_NIC1C_PRSNT1_R_N)                 , //addr 0x0024 bit4 
.i_NIC2A_PRSNT0_R_N                         (i_NIC2A_PRSNT0_R_N)                 , //addr 0x0024 bit3 
.i_NIC2A_PRSNT1_R_N                         (i_NIC2A_PRSNT1_R_N)                 , //addr 0x0024 bit2 
.i_NIC2C_PRSNT0_R_N                         (i_NIC2C_PRSNT0_R_N)                 , //addr 0x0024 bit1 
.i_NIC2C_PRSNT1_R_N                         (i_NIC2C_PRSNT1_R_N)                 , //addr 0x0024 bit0 

.i_NIC3A_PRSNT0_R_N                         (i_NIC3A_PRSNT0_R_N   )              , //addr 0x0025 bit7  
.i_NIC3A_PRSNT1_R_N                         (i_NIC3A_PRSNT1_R_N   )              , //addr 0x0025 bit6  
.i_NIC3C_PRSNT0_R_N                         (i_NIC3C_PRSNT0_R_N   )              , //addr 0x0025 bit5  
.i_NIC3C_PRSNT1_R_N                         (i_NIC3C_PRSNT1_R_N   )              , //addr 0x0025 bit4  
.i_NIC4A_PRSNT0_R_N                         (i_NIC4A_PRSNT0_R_N   )              , //addr 0x0025 bit3  
.i_NIC4A_PRSNT1_R_N                         (i_NIC4A_PRSNT1_R_N   )              , //addr 0x0025 bit2  
.i_NIC4C_PRSNT0_R_N                         (i_NIC4C_PRSNT0_R_N   )              , //addr 0x0025 bit1  
.i_NIC4C_PRSNT1_R_N                         (i_NIC4C_PRSNT1_R_N   )              , //addr 0x0025 bit0  

// .o_psu0_ctl                             (w_psu0_ctl       )                 , //addr 0x0026 bit7  //default 1
// .o_psu1_ctl                             (w_psu1_ctl       )                 , //addr 0x0026 bit6  //default 1
// .o_psu2_ctl                             (w_psu2_ctl       )                 , //addr 0x0026 bit5  //default 1
// .o_psu3_ctl                             (w_psu3_ctl       )                 , //addr 0x0026 bit4  //default 1
// .o_psu4_ctl                             (w_psu4_ctl       )                 , //addr 0x0026 bit3  //default 1
// .o_psu5_ctl                             (w_psu5_ctl       )                 , //addr 0x0026 bit2  //default 1

.i_P3V3_STBY_PG                         (w_p3v3_stby_pg_db     )              , //addr 0x0027  bit7  
.i_P12V_PG                              (w_p12v_pg_db          )              , //addr 0x0027  bit6  
.i_PAL_P12V_STBY_PG                     (w_pal_p12v_stby_pg_db )              , //addr 0x0027  bit5  
.i_PAL_SW_PWR_PG                        (i_PAL_SW_PWR_PG       )              , //addr 0x0027  bit4  
.i_CT_P1V25_SW0_PG                      (w_ct_p1v25_sw0_pg_db  )              , //addr 0x0027  bit3  
.i_CT_P1V25_SW1_PG                      (w_ct_p1v25_sw1_pg_db  )              , //addr 0x0027  bit2  
.i_CT_P1V25_SW2_PG                      (w_ct_p1v25_sw2_pg_db  )              , //addr 0x0027  bit1  
.i_CT_P1V25_SW3_PG                      (w_ct_p1v25_sw3_pg_db  )              , //addr 0x0027  bit0  

.i_NIC5A_PRSNT0_R_N                      (i_NIC5A_PRSNT0_R_N)              , //addr 0x0028  bit7  
.i_NIC5A_PRSNT1_R_N                      (i_NIC5A_PRSNT1_R_N)              , //addr 0x0028  bit6  
.i_NIC5C_PRSNT0_R_N                      (i_NIC5C_PRSNT0_R_N)              , //addr 0x0028  bit5  
.i_NIC5C_PRSNT1_R_N                      (i_NIC5C_PRSNT1_R_N)              , //addr 0x0028  bit4  
.i_NIC6A_PRSNT0_R_N                      (i_NIC6A_PRSNT0_R_N)              , //addr 0x0028  bit3  
.i_NIC6A_PRSNT1_R_N                      (i_NIC6A_PRSNT1_R_N)              , //addr 0x0028  bit2  
.i_NIC6C_PRSNT0_R_N                      (i_NIC6C_PRSNT0_R_N)              , //addr 0x0028  bit1  
.i_NIC6C_PRSNT1_R_N                      (i_NIC6C_PRSNT1_R_N)              , //addr 0x0028  bit0  


.i_NIC7A_PRSNT0_R_N                      (i_NIC7A_PRSNT0_R_N)               , //addr 0x0029  bit7 
.i_NIC7A_PRSNT1_R_N                      (i_NIC7A_PRSNT1_R_N)               , //addr 0x0029  bit6 
.i_NIC7C_PRSNT0_R_N                      (i_NIC7C_PRSNT0_R_N)               , //addr 0x0029  bit5 
.i_NIC7C_PRSNT1_R_N                      (i_NIC7C_PRSNT1_R_N)               , //addr 0x0029  bit4 
.i_NIC8A_PRSNT0_R_N                      (i_NIC8A_PRSNT0_R_N)               , //addr 0x0029  bit3 
.i_NIC8A_PRSNT1_R_N                      (i_NIC8A_PRSNT1_R_N)               , //addr 0x0029  bit2 
.i_NIC8C_PRSNT0_R_N                      (i_NIC8C_PRSNT0_R_N)               , //addr 0x0029  bit1 
.i_NIC8C_PRSNT1_R_N                      (i_NIC8C_PRSNT1_R_N)               , //addr 0x0029  bit0 


.o_bmc_ctrl_sw_mode                     (w_bmc_ctrl_sw_mode)                , //addr 0x0033 bit3-0  //2024-9-9 add  //default 0000
.o_bmc_ctrl_sw_mode_mask                (w_bmc_ctrl_sw_mode_mask)           , //addr 0x0034 bit3-0  //2024-9-11 add //default 0000

.o_bmc_ctrl_nic_rst                     (w_bmc_ctrl_nic_rst)                 //addr 0x0035 bit7-0  //2024-10-10 add //default ff


);

/**************************************************************************************************/
//-------------------------------------------------------------------------------------------------
// I2C RAM  Stop
//-------------------------------------------------------------------------------------------------
/**************************************************************************************************/










endmodule