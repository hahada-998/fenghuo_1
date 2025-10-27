
//RESET
localparam [5:0] SM_RESET_STATE				=6'h00;

//GRP_A
localparam [5:0] SM_EN_GRP_A				        =6'h01;//o_PAL_P5V_STBY_EN_R=1'b1; UID\DRMOS
localparam [5:0] SM_RSMRST_DISABLE			=6'h02;//o_P0_RSMRST_N=1'b0;
localparam [5:0] SM_EN_GRP_B_33_S5 			=6'h03;//o_P0_VDDC_EN_R=1'b1; o_P1_VDDC_EN_R=1'b1;


//GRP_B
localparam [5:0] SM_EN_GRP_B_18_S5			=6'h04;//o_PAL_P0_VDD_18_STBY_EN_R=1'b1; o_P1_VDD_18_STBY_EN=1'b1;
localparam [5:0] SM_EN_P5V_STBY				=6'h05;//o_PAL_USB_VBUS1_EN_R=1'b1; o_PAL_USB_VBUS2_EN_R=1'b1;
localparam [5:0] SM_EN_RSMRST_RELEASE		=6'h06;//o_P0_RSMRST_N=1'b1;o_P1_RSMRST_N=1'b1;
localparam [5:0] SM_ENABLE_S5_DEVICES		=6'h07;//passthrough
localparam [5:0] SM_OFF_STANDBY				=6'h08;//S5 Power OK

//GRP_C_Early
localparam [5:0] SM_PS_ON					=6'h09;//passthrough
localparam [5:0] SM_EN_TELEM				=6'h10;//passthrough
localparam [5:0] SM_EN_MAIN_EFUSE			=6'h11;//o_PAL_P12V_EFUSE_EN_R=1'b1;o_PAL_CPU0_DIMM_EFUSE_EN_R=1'b1; o_PAL_CPU1_DIMM_EFUSE_EN_R=1'b1; o_PAL_P12V_SSD_EFUSE_EN_R=1'b1;
localparam [5:0] SM_EN_GRP_ATX				=6'h12;//o_PAL_P3V3_EN_R=1'b1;

//GRP_C
localparam [5:0] SM_EN_GRP_C				=6'h13;//o_PAL_P0_VDD_11_SUS_EN=1'b1; o_PAL_P1_VDD_11_SUS_EN=1'1b1;

//GRP_D
localparam [5:0] SM_EN_GRP_D_VDDIO			=6'h14;//o_PAL_P0_VDDIO_EN_R=1'b1; 		o_PAL_P1_VDDIO_EN_R=1'b1;
localparam [5:0] SM_EN_GRP_D_SOC			=6'h15;//o_PAL_P0_VDD_SOC_EN=1'b1; 		o_PAL_P1_VDD_SOC_EN=1'b1;
localparam [5:0] SM_EN_GRP_D_VDDCORE0		=6'h16;//o_PAL_P0_VDD_CORE_0_EN_R=1'b1; o_PAL_P1_VDD_CORE_0_EN_R=1'b1; 
localparam [5:0] SM_EN_GRP_D_VDDCORE1		=6'h17;//o_PAL_P0_VDD_CORE_1_EN_R=1'b1; o_PAL_P1_VDD_CORE_1_EN_R=1'b1;
localparam [5:0] SM_EN_PGOOD_RELEASE		=6'h18;//o_P0_PWR_GOOD=1'b1;
localparam [5:0] SM_WAIT_POWEROK			=6'h19;//
localparam [5:0] SM_STEADY_PWROK			=6'h20;//S0 Power Ok 

//GRP_D_DOWN
localparam [5:0] SM_DISABLE_PWRGD			=6'h21;
localparam [5:0] SM_DISABLE_GRP_D_VDDCORE1	=6'h22;
localparam [5:0] SM_DISABLE_GRP_D_VDDCORE0	=6'h23;
localparam [5:0] SM_DISABLE_GRP_D_SOC		=6'h24;
localparam [5:0] SM_DISABLE_GRP_D_VDDIO	=6'h25;

//GRP_C_DOWN
localparam [5:0] SM_DISABLE_GRP_C			=6'h26;
localparam [5:0] SM_DISABLE_GRP_ATX		=6'h27;
localparam [5:0] SM_DISABLE_MAIN_EFUSE		=6'h28;
localparam [5:0] SM_DISABLE_TELEM			=6'h29;
localparam [5:0] SM_DISABLE_PS_ON			=6'h30;

//GRP_B
localparam [5:0] SM_DISABLE_S5_DEVICES		=6'h31;

//FAULT
localparam [5:0] SM_HALT_POWER_CYCLE		=6'h32;
localparam [5:0] SM_AUX_FAIL_RECOVERY		=6'h33;
localparam [5:0] SM_CRITICAL_FAIL			=6'h34;
