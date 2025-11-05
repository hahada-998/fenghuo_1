
//RESET
localparam [5:0] SM_RESET_STATE				=6'h00;             //复位状态。模块初始化或复位时的初始状态，所有电源使能、控制信号均处于默认 / 复位态

//GRP_A
localparam [5:0] SM_EN_GRP_A			    =6'h01;//o_PAL_P5V_STBY_EN_R=1'b1; UID\DRMOS  使能电源组 A。用于开启 UID、DRMOS 等相关的 5V 待机电源（如 o_PAL_P5V_STBY_EN_R 置 1）
localparam [5:0] SM_RSMRST_DISABLE			=6'h02;//o_P0_RSMRST_N=1'b0; 禁用 RSMRST 信号。将南桥复位信号 o_P0_RSMRST_N 置 0，保持南桥复位状态
localparam [5:0] SM_EN_GRP_B_33_S5 			=6'h03;//o_P0_VDDC_EN_R=1'b1; o_P1_VDDC_EN_R=1'b1; 使能 S5 状态下的电源组 B（3.3V 域）。开启 CPU 相关的 3.3V 待机电源（如 o_P0_VDDC_EN_R 置 1


//GRP_B
localparam [5:0] SM_EN_GRP_B_18_S5			=6'h04;//o_PAL_P0_VDD_18_STBY_EN_R=1'b1; o_P1_VDD_18_STBY_EN=1'b1; 使能 S5 状态下的电源组 B（1.8V 域）。开启 CPU 相关的 1.8V 待机电源（如 o_PAL_P0_VDD_18_STBY_EN_R 置 1）
localparam [5:0] SM_EN_P5V_STBY				=6'h05;//o_PAL_USB_VBUS1_EN_R=1'b1; o_PAL_USB_VBUS2_EN_R=1'b1; 使能 5V 待机电源。开启 USB 总线等外设的 5V 待机电源（如 o_PAL_USB_VBUS1_EN_R 置 1）
localparam [5:0] SM_EN_RSMRST_RELEASE		=6'h06;//o_P0_RSMRST_N=1'b1;o_P1_RSMRST_N=1'b1; 释放 RSMRST 信号。将南桥复位信号 o_P0_RSMRST_N 置 1，解除南桥复位，允许南桥初始化
localparam [5:0] SM_ENABLE_S5_DEVICES		=6'h07;//passthrough  使能 S5 状态下的设备电源。开启 S5 状态下需保持供电的外设（如管理芯片、部分传感器）
localparam [5:0] SM_OFF_STANDBY				=6'h08;//S5 Power OK 待机下电状态。S5 状态下电源就绪确认，标志待机阶段电源时序完成

//GRP_C_Early
localparam [5:0] SM_PS_ON					=6'h09;//passthrough 	电源模块使能。触发电源供应单元（PSU）的主电源使能，进入上电流程
localparam [5:0] SM_EN_TELEM				=6'h10;//passthrough    使能遥测功能。开启电源、温度等遥测模块，用于系统健康监控
localparam [5:0] SM_EN_MAIN_EFUSE			=6'h11;//o_PAL_P12V_EFUSE_EN_R=1'b1;o_PAL_CPU0_DIMM_EFUSE_EN_R=1'b1; o_PAL_CPU1_DIMM_EFUSE_EN_R=1'b1; o_PAL_P12V_SSD_EFUSE_EN_R=1'b1;使能主 eFuse 电源。开启 CPU 内存、SSD 等核心部件的 eFuse 供电（如 o_PAL_P12V_EFUSE_EN_R 置 1）
localparam [5:0] SM_EN_GRP_ATX				=6'h12;//o_PAL_P3V3_EN_R=1'b1; 使能 ATX 电源组。开启 3.3V 等 ATX 标准电源轨（如 o_PAL_P3V3_EN_R 置 1）

//GRP_C
localparam [5:0] SM_EN_GRP_C				=6'h13;//o_PAL_P0_VDD_11_SUS_EN=1'b1; o_PAL_P1_VDD_11_SUS_EN=1'1b1; 使能电源组 C。开启 CPU 相关的 1.1V 挂起电源（如 o_PAL_P0_VDD_11_SUS_EN 置 1）

//GRP_D
localparam [5:0] SM_EN_GRP_D_VDDIO			=6'h14;//o_PAL_P0_VDDIO_EN_R=1'b1; 		o_PAL_P1_VDDIO_EN_R=1'b1; 使能电源组 D（VDDIO 域）。开启 CPU 输入输出接口的电源（如 o_PAL_P0_VDDIO_EN_R 置 1）
localparam [5:0] SM_EN_GRP_D_SOC			=6'h15;//o_PAL_P0_VDD_SOC_EN=1'b1; 		o_PAL_P1_VDD_SOC_EN=1'b1; 使能电源组 D（SOC 域）。开启 CPU 片上系统核心的电源（如 o_PAL_P0_VDD_SOC_EN 置 1）
localparam [5:0] SM_EN_GRP_D_VDDCORE0		=6'h16;//o_PAL_P0_VDD_CORE_0_EN_R=1'b1; o_PAL_P1_VDD_CORE_0_EN_R=1'b1; 使能电源组 D（VDDCORE0 域）。开启 CPU 核心电压 0 轨的电源（如 o_PAL_P0_VDD_CORE_0_EN_R 置 1）
localparam [5:0] SM_EN_GRP_D_VDDCORE1		=6'h17;//o_PAL_P0_VDD_CORE_1_EN_R=1'b1; o_PAL_P1_VDD_CORE_1_EN_R=1'b1; 使能电源组 D（VDDCORE1 域）。开启 CPU 核心电压 1 轨的电源（如 o_PAL_P0_VDD_CORE_1_EN_R 置 1）
localparam [5:0] SM_EN_PGOOD_RELEASE		=6'h18;//o_P0_PWR_GOOD=1'b1; 	释放 PGOOD 信号。将系统电源就绪信号 o_P0_PWR_GOOD 置 1，通知系统电源全就绪
localparam [5:0] SM_WAIT_POWEROK			=6'h19;//等待电源就绪。轮询各电源轨的 PWR_OK 信号，确认电源稳定输出
localparam [5:0] SM_STEADY_PWROK			=6'h20;//S0 Power Ok  	稳定电源就绪状态。标志系统进入 S0 工作状态，所有电源轨均稳定就绪

//GRP_D_DOWN
localparam [5:0] SM_DISABLE_PWRGD			=6'h21;//禁用 PWRGD 信号。将系统电源就绪信号 o_P0_PWR_GOOD 置 0，触发下电流程
localparam [5:0] SM_DISABLE_GRP_D_VDDCORE1	=6'h22;//	禁用电源组 D（VDDCORE1 域）。关闭 CPU 核心电压 1 轨的电源
localparam [5:0] SM_DISABLE_GRP_D_VDDCORE0	=6'h23;//	禁用电源组 D（VDDCORE0 域）。关闭 CPU 核心电压 0 轨的电源
localparam [5:0] SM_DISABLE_GRP_D_SOC		=6'h24;//	禁用电源组 D（SOC 域）。关闭 CPU 片上系统核心的电源
localparam [5:0] SM_DISABLE_GRP_D_VDDIO	    =6'h25;//	禁用电源组 D（VDDIO 域）。关闭 CPU 输入输出接口的电源

//GRP_C_DOWN
localparam [5:0] SM_DISABLE_GRP_C			=6'h26;//禁用电源组 C。关闭 CPU 相关的 1.1V 挂起电源
localparam [5:0] SM_DISABLE_GRP_ATX		    =6'h27;//禁用 ATX 电源组。关闭 3.3V 等 ATX 标准电源轨
localparam [5:0] SM_DISABLE_MAIN_EFUSE		=6'h28;//	禁用主 eFuse 电源。关闭 CPU 内存、SSD 等核心部件的 eFuse 供电
localparam [5:0] SM_DISABLE_TELEM			=6'h29;//禁用遥测功能。关闭电源、温度等遥测模块，停止系统健康监控
localparam [5:0] SM_DISABLE_PS_ON			=6'h30;//禁用电源模块。关闭电源供应单元（PSU）的主电源使能，进入下电流程

//GRP_B
localparam [5:0] SM_DISABLE_S5_DEVICES		=6'h31;//禁用 S5 状态下的设备电源。关闭 S5 状态下的外设电源

//FAULT
localparam [5:0] SM_HALT_POWER_CYCLE		=6'h32;//暂停电源循环。故障时进入该状态，暂停上电 / 下电流程，等待人工干预或自动恢复
localparam [5:0] SM_AUX_FAIL_RECOVERY		=6'h33;//	辅助故障恢复。针对可重试的辅助故障（如遥测异常），执行恢复流程
localparam [5:0] SM_CRITICAL_FAIL			=6'h34;//关键故障状态。检测到致命故障（如 CPU 热跳变），触发紧急下电并锁存故障状态
