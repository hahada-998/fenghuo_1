//=================================================================================================
// Copyright(c) 
// Filename   : BP_4S104G5_VA_PORT.v
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


  
//=================================================================================================
//------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BP_4S104G5  : one CPLD,this Code for CPLD_U1  J68
//-------------------------------------------------------------------------------
module BP_4S104G5(

//jtag
// input   i_CPLD_JTAG_TMS	            /* synthesis LOC = "D9 "*/,      //
// input   i_CPLD_JTAG_TCK	            /* synthesis LOC = "C9 "*/,      //
// input   i_CPLD_JTAG_TDI	            /* synthesis LOC = "C7 "*/,      //
// output  o_CPLD_JTAG_TDO	            /* synthesis LOC = "E8 "*/,      //
//CLK
input   i_CPLD_CLK	                /* synthesis LOC = "B10"*/,      //Y
//FAN
output  o_PAL_FAN1_PWM	            /* synthesis LOC = "H14"*/,      //Y
output  o_PAL_FAN2_PWM	            /* synthesis LOC = "D18"*/,      //Y
output  o_PAL_FAN3_PWM	            /* synthesis LOC = "B16"*/,      //Y
output  o_PAL_FAN4_PWM	            /* synthesis LOC = "N14"*/,      //Y
output  o_PAL_FAN5_PWM	            /* synthesis LOC = "F5 "*/,      //Y
output  o_PAL_FAN6_PWM	            /* synthesis LOC = "D12"*/,      //Y
output  o_PAL_FAN7_PWM	            /* synthesis LOC = "A11"*/,      //Y
output  o_PAL_FAN8_PWM	            /* synthesis LOC = "D17"*/,      //Y
output  o_PAL_FAN9_PWM	            /* synthesis LOC = "G11"*/,      //Y
output  o_PAL_FAN10_PWM	            /* synthesis LOC = "T16"*/,      //Y
output  o_PAL_FAN11_PWM	            /* synthesis LOC = "A12"*/,      //Y
output  o_PAL_FAN12_PWM	            /* synthesis LOC = "L7 "*/,      //Y
output  o_PAL_FAN13_PWM	            /* synthesis LOC = "G12"*/,      //Y
output  o_PAL_FAN14_PWM	            /* synthesis LOC = "E4 "*/,      //Y
output  o_PAL_FAN15_PWM	            /* synthesis LOC = "T12"*/,      //Y
input   i_PAL_FAN1_TACH2	        /* synthesis LOC = "D10"*/,      //Y    i_PAL_FAN1_TACH1 //2024-5-29 exchange TACH1/2
input   i_PAL_FAN1_TACH1	        /* synthesis LOC = "K14"*/,      //Y    i_PAL_FAN1_TACH2	
input   i_PAL_FAN2_TACH2	        /* synthesis LOC = "H7 "*/,      //Y    i_PAL_FAN2_TACH1	
input   i_PAL_FAN2_TACH1	        /* synthesis LOC = "D8 "*/,      //Y    i_PAL_FAN2_TACH2	
input   i_PAL_FAN3_TACH2	        /* synthesis LOC = "C14"*/,      //Y    i_PAL_FAN3_TACH1	
input   i_PAL_FAN3_TACH1	        /* synthesis LOC = "B14"*/,      //Y    i_PAL_FAN3_TACH2	
input   i_PAL_FAN4_TACH2	        /* synthesis LOC = "F9 "*/,      //Y    i_PAL_FAN4_TACH1	
input   i_PAL_FAN4_TACH1	        /* synthesis LOC = "C8 "*/,      //Y    i_PAL_FAN4_TACH2	
input   i_PAL_FAN5_TACH2	        /* synthesis LOC = "H3 "*/,      //Y    i_PAL_FAN5_TACH1	
input   i_PAL_FAN5_TACH1	        /* synthesis LOC = "G4 "*/,      //Y    i_PAL_FAN5_TACH2	
input   i_PAL_FAN6_TACH2	        /* synthesis LOC = "G15"*/,      //Y    i_PAL_FAN6_TACH1	
input   i_PAL_FAN6_TACH1	        /* synthesis LOC = "D14"*/,      //Y    i_PAL_FAN6_TACH2	
input   i_PAL_FAN7_TACH2	        /* synthesis LOC = "J6 "*/,      //Y    i_PAL_FAN7_TACH1	
input   i_PAL_FAN7_TACH1	        /* synthesis LOC = "D16"*/,      //Y    i_PAL_FAN7_TACH2	
input   i_PAL_FAN8_TACH2	        /* synthesis LOC = "B15"*/,      //Y    i_PAL_FAN8_TACH1	
input   i_PAL_FAN8_TACH1	        /* synthesis LOC = "C15"*/,      //Y    i_PAL_FAN8_TACH2	
input   i_PAL_FAN9_TACH2	        /* synthesis LOC = "F11"*/,      //Y    i_PAL_FAN9_TACH1	
input   i_PAL_FAN9_TACH1	        /* synthesis LOC = "A10"*/,      //Y    i_PAL_FAN9_TACH2	
input   i_PAL_FAN10_TACH2	        /* synthesis LOC = "T11"*/,      //Y    i_PAL_FAN10_TACH1	
input   i_PAL_FAN10_TACH1	        /* synthesis LOC = "T8 "*/,      //Y    i_PAL_FAN10_TACH2	
input   i_PAL_FAN11_TACH2	        /* synthesis LOC = "E14"*/,      //Y    i_PAL_FAN11_TACH1	
input   i_PAL_FAN11_TACH1	        /* synthesis LOC = "D7 "*/,      //Y    i_PAL_FAN11_TACH2	
input   i_PAL_FAN12_TACH2	        /* synthesis LOC = "G5 "*/,      //Y    i_PAL_FAN12_TACH1	
input   i_PAL_FAN12_TACH1	        /* synthesis LOC = "D6 "*/,      //Y    i_PAL_FAN12_TACH2	
input   i_PAL_FAN13_TACH2	        /* synthesis LOC = "K20"*/,      //Y    i_PAL_FAN13_TACH1	
input   i_PAL_FAN13_TACH1	        /* synthesis LOC = "C16"*/,      //Y    i_PAL_FAN13_TACH2	
input   i_PAL_FAN14_TACH2	        /* synthesis LOC = "L17"*/,      //Y    i_PAL_FAN14_TACH1	
input   i_PAL_FAN14_TACH1	        /* synthesis LOC = "L3 "*/,      //Y    i_PAL_FAN14_TACH2	
input   i_PAL_FAN15_TACH2	        /* synthesis LOC = "U18"*/,      //Y    i_PAL_FAN15_TACH1	
input   i_PAL_FAN15_TACH1	        /* synthesis LOC = "V17"*/,      //Y    i_PAL_FAN15_TACH2	
output  o_PAL_FAN1_LED_G	        /* synthesis LOC = "R8 "*/,      //Y
output  o_PAL_FAN1_LED_R	        /* synthesis LOC = "H4 "*/,      //Y
output  o_PAL_FAN2_LED_G	        /* synthesis LOC = "T9 "*/,      //Y
output  o_PAL_FAN2_LED_R	        /* synthesis LOC = "G7 "*/,      //Y
output  o_PAL_FAN3_LED_G	        /* synthesis LOC = "B11"*/,      //Y
output  o_PAL_FAN3_LED_R	        /* synthesis LOC = "C12"*/,      //Y
output  o_PAL_FAN4_LED_G	        /* synthesis LOC = "B6 "*/,      //Y
output  o_PAL_FAN4_LED_R	        /* synthesis LOC = "C3 "*/,      //Y
output  o_PAL_FAN5_LED_G	        /* synthesis LOC = "E2 "*/,      //Y
output  o_PAL_FAN5_LED_R	        /* synthesis LOC = "G3 "*/,      //Y
output  o_PAL_FAN6_LED_G	        /* synthesis LOC = "F8 "*/,      //Y
output  o_PAL_FAN6_LED_R	        /* synthesis LOC = "R9 "*/,      //Y
output  o_PAL_FAN7_LED_G	        /* synthesis LOC = "W20"*/,      //Y
output  o_PAL_FAN7_LED_R	        /* synthesis LOC = "G8 "*/,      //Y
output  o_PAL_FAN8_LED_G	        /* synthesis LOC = "B9 "*/,      //Y
output  o_PAL_FAN8_LED_R	        /* synthesis LOC = "E1 "*/,      //Y
output  o_PAL_FAN9_LED_G	        /* synthesis LOC = "E7 "*/,      //Y
output  o_PAL_FAN9_LED_R	        /* synthesis LOC = "B8 "*/,      //Y
output  o_PAL_FAN10_LED_G	        /* synthesis LOC = "P7 "*/,      //Y
output  o_PAL_FAN10_LED_R	        /* synthesis LOC = "P8 "*/,      //Y
output  o_PAL_FAN11_LED_G	        /* synthesis LOC = "C10"*/,      //Y
output  o_PAL_FAN11_LED_R	        /* synthesis LOC = "F10"*/,      //Y
output  o_PAL_FAN12_LED_G	        /* synthesis LOC = "J16"*/,      //Y
output  o_PAL_FAN12_LED_R	        /* synthesis LOC = "B17"*/,      //Y
output  o_PAL_FAN13_LED_G	        /* synthesis LOC = "K16"*/,      //Y
output  o_PAL_FAN13_LED_R	        /* synthesis LOC = "K17"*/,      //Y
output  o_PAL_FAN14_LED_G	        /* synthesis LOC = "K5 "*/,      //Y
output  o_PAL_FAN14_LED_R	        /* synthesis LOC = "K6 "*/,      //Y
output  o_PAL_FAN15_LED_G	        /* synthesis LOC = "R10"*/,      //Y
output  o_PAL_FAN15_LED_R	        /* synthesis LOC = "L6 "*/,      //Y
//I2C
input   i_I2C_CPLD_SCL	            /* synthesis LOC = "K19"*/,      //Y
inout   io_I2C_CPLD_SDA	            /* synthesis LOC = "E20"*/,      //Y
inout   io_I2C9_CPLD_UPDATE_SCL	    /* synthesis LOC = "C11"*/,      //Y
inout   io_I2C9_CPLD_UPDATE_SDA	    /* synthesis LOC = "D11"*/,      //Y
output  o_SMB_NIC_RST_N_R	        /* synthesis LOC = "W17"*/,      //Y
input   i_I2C1_ALERT_N_R	        /* synthesis LOC = "P2 "*/,      //Y
input   i_I2C2_ALERT_N_R	        /* synthesis LOC = "W3 "*/,      //Y
input   i_I2C9_9548_CH4_ALERT	    /* synthesis LOC = "H6 "*/,      //Y
//pol
output  o_PAL_HSC0_EN_R	            /* synthesis LOC = "G16"*/,      //Y
output  o_PAL_HSC0_RESTART_R	    /* synthesis LOC = "C18"*/,      //Y
output  o_PAL_RAA_EN_N	            /* synthesis LOC = "G9 "*/,      //Y
input   i_P3V3_STBY_PG	            /* synthesis LOC = "A18"*/,      //Y
output  o_P5V0_EN	                /* synthesis LOC = "G19"*/,      //Y
output  o_P1V8_EN	                /* synthesis LOC = "F13"*/,      //Y
output  o_P1V8_PLL_EN	            /* synthesis LOC = "F18"*/,      //Y
output  o_P0V8_SW_EN	            /* synthesis LOC = "P10"*/,      //Y
output  o_CT_P1V25_SW_EN	        /* synthesis LOC = "B4 "*/,      //Y
input   i_PAL_RAA_CFP_R	            /* synthesis LOC = "P11"*/,      //Y
input   i_P12V_PG	                /* synthesis LOC = "G10"*/,      //Y
output  o_PAL_DB2000_PWRGD	        /* synthesis LOC = "Y4 "*/,      //Y
output  o_PAL_DB2000_1_PWRGD	    /* synthesis LOC = "P20"*/,      //Y
input   i_P0V8_SW0_PWRGD	        /* synthesis LOC = "W10"*/,      //Y
input   i_P0V8_SW1_PWRGD	        /* synthesis LOC = "C6 "*/,      //Y
input   i_P0V8_SW2_PWRGD	        /* synthesis LOC = "G6 "*/,      //Y
input   i_P0V8_SW3_PWRGD	        /* synthesis LOC = "F4 "*/,      //Y
input   i_CT_P1V25_SW0_PG	        /* synthesis LOC = "U12"*/,      //Y
input   i_CT_P1V25_SW1_PG	        /* synthesis LOC = "D5 "*/,      //Y
input   i_CT_P1V25_SW2_PG	        /* synthesis LOC = "B18"*/,      //Y
input   i_CT_P1V25_SW3_PG	        /* synthesis LOC = "F7 "*/,      //Y
input   i_PG_P5V0_R	                /* synthesis LOC = "J18"*/,      //Y
input   i_PG_P1V8_R	                /* synthesis LOC = "B12"*/,      //Y
input   i_PG_P1V8_PLL_R	            /* synthesis LOC = "F19"*/,      //Y
output  o_P5V_VGA_EN	            /* synthesis LOC = "D2 "*/,      //Y
input   i_P5V_VGA_OC	            /* synthesis LOC = "D1 "*/,      //Y
output  o_P5V_RIGHTEAR_USB_EN	    /* synthesis LOC = "U14"*/,      //Y
input   i_P5V_RIGHTEAR_USB_OC	    /* synthesis LOC = "T13"*/,      //Y
output  o_P5V_STBY_USB_EN	        /* synthesis LOC = "G13"*/,      //Y
input   i_P5V_STBY_USB_OC	        /* synthesis LOC = "H19"*/,      //Y
input   i_PSU0_PWROK_N	            /* synthesis LOC = "J15"*/,      //Y
input   i_PSU1_PWROK_N	            /* synthesis LOC = "L1 "*/,      //Y
input   i_PSU2_PWROK_N	            /* synthesis LOC = "L2 "*/,      //Y
input   i_PSU3_PWROK_N	            /* synthesis LOC = "M14"*/,      //Y
input   i_PSU4_PWROK_N	            /* synthesis LOC = "D15"*/,      //Y
input   i_PSU5_PWROK_N	            /* synthesis LOC = "F14"*/,      //Y
output  o_PSU0_PSON_R	            /* synthesis LOC = "K15"*/,      //Y
output  o_PSU1_PSON_R	            /* synthesis LOC = "L15"*/,      //Y
output  o_PSU2_PSON_R	            /* synthesis LOC = "L16"*/,      //Y
output  o_PSU3_PSON_R	            /* synthesis LOC = "P12"*/,      //Y
output  o_PSU4_PSON_R	            /* synthesis LOC = "F12"*/,      //Y
output  o_PSU5_PSON_R	            /* synthesis LOC = "P9 "*/,      //Y
input   i_SMB_PSU0_ALERT_R	        /* synthesis LOC = "M16"*/,      //Y
input   i_SMB_PSU1_ALERT_R	        /* synthesis LOC = "N17"*/,      //Y
input   i_SMB_PSU2_ALERT_R	        /* synthesis LOC = "N18"*/,      //Y
input   i_SMB_PSU3_ALERT_R	        /* synthesis LOC = "G14"*/,      //Y
input   i_SMB_PSU4_ALERT_R	        /* synthesis LOC = "F15"*/,      //Y
input   i_SMB_PSU5_ALERT_R	        /* synthesis LOC = "E15"*/,      //Y
//NIC
output  o_PAL_RETIMER1_0P9_EN_R	    /* synthesis LOC = "U19"*/,      //Y
output  o_PAL_RETIMER2_0P9_EN_R	    /* synthesis LOC = "T17"*/,      //Y
output  o_PAL_RETIMER3_0P9_EN_R	    /* synthesis LOC = "T20"*/,      //Y
output  o_PAL_RETIMER4_0P9_EN_R	    /* synthesis LOC = "R19"*/,      //Y
output  o_PAL_RETIMER5_0P9_EN_R	    /* synthesis LOC = "V20"*/,      //Y
output  o_PAL_RETIMER6_0P9_EN_R	    /* synthesis LOC = "W15"*/,      //Y
output  o_PAL_RETIMER7_0P9_EN_R	    /* synthesis LOC = "V14"*/,      //Y
output  o_PAL_RETIMER8_0P9_EN_R	    /* synthesis LOC = "W14"*/,      //Y
output  o_NICSLOT_3P3V_EN_R	        /* synthesis LOC = "W18"*/,      //Y
output  o_RETIMER_1P8V_EN_R	        /* synthesis LOC = "W19"*/,      //Y
input   i_NIC_3P3V_A_PG_R	        /* synthesis LOC = "U15"*/,      //Y
input   i_NIC_3P3V_B_PG_R	        /* synthesis LOC = "V16"*/,      //Y
input   i_RETIMER1_INT_N_R	        /* synthesis LOC = "V2 "*/,      //Y
input   i_RETIMER2_INT_N_R	        /* synthesis LOC = "R1 "*/,      //Y
input   i_RETIMER3_INT_N_R	        /* synthesis LOC = "N3 "*/,      //Y
input   i_RETIMER4_INT_N_R	        /* synthesis LOC = "T3 "*/,      //Y
input   i_RETIMER5_INT_N_R	        /* synthesis LOC = "U4 "*/,      //Y
input   i_RETIMER6_INT_N_R	        /* synthesis LOC = "T1 "*/,      //Y
input   i_RETIMER7_INT_N_R	        /* synthesis LOC = "R3 "*/,      //Y
input   i_RETIMER8_INT_N_R	        /* synthesis LOC = "V4 "*/,      //Y
output  o_RETIMER1_RESET_N_R	    /* synthesis LOC = "M7 "*/,      //Y
output  o_RETIMER2_RESET_N_R	    /* synthesis LOC = "N6 "*/,      //Y
output  o_RETIMER3_RESET_N_R	    /* synthesis LOC = "T2 "*/,      //Y
output  o_RETIMER4_RESET_N_R	    /* synthesis LOC = "V1 "*/,      //Y
output  o_RETIMER5_RESET_N_R	    /* synthesis LOC = "R5 "*/,      //Y
output  o_RETIMER6_RESET_N_R	    /* synthesis LOC = "P5 "*/,      //Y
output  o_RETIMER7_RESET_N_R	    /* synthesis LOC = "R2 "*/,      //Y
output  o_RETIMER8_RESET_N_R	    /* synthesis LOC = "N4 "*/,      //Y
output  o_SLOT1_THORTTLE_R	        /* synthesis LOC = "F20"*/,      //Y
output  o_SLOT2_THORTTLE_R	        /* synthesis LOC = "V19"*/,      //Y
output  o_SLOT3_THORTTLN_R	        /* synthesis LOC = "U20"*/,      //Y
output  o_SLOT4_THORTTLE_R	        /* synthesis LOC = "T19"*/,      //Y
output  o_SLOT5_THORTTLE_R	        /* synthesis LOC = "K18"*/,      //Y
output  o_SLOT6_THORTTLE_R	        /* synthesis LOC = "N20"*/,      //Y
output  o_SLOT7_THORTTLE_R	        /* synthesis LOC = "M20"*/,      //Y
output  o_SLOT8_THORTTLE_R	        /* synthesis LOC = "H20"*/,      //Y
//BP
output  o_BP1_PWR_EN_R	            /* synthesis LOC = "Y14"*/,      //Y
input   i_BP1_PRSNT_N_R	            /* synthesis LOC = "Y16"*/,      //Y
input   i_BP1_PWR_PG_R	            /* synthesis LOC = "Y7 "*/,      //Y
input   i_BP2_PWR_PG_R	            /* synthesis LOC = "N2 "*/,      //Y
output  o_BP2_PWR_EN_R	            /* synthesis LOC = "Y3 "*/,      //Y
input   i_BP2_PRSNT_N_R	            /* synthesis LOC = "Y6 "*/,      //Y
output  o_BP_9548_RST_N_R	        /* synthesis LOC = "C20"*/,      //Y
output  o_BPTB_EEP_WP_R	            /* synthesis LOC = "A5 "*/,      //Y
input   i_BPTB_RE_DONE_R	        /* synthesis LOC = "Y5 "*/,      //Y
output  o_BP_EEPROM_WP_R	        /* synthesis LOC = "Y8 "*/,      //Y
//UBB
input   i_GPU_BASE_FPGA_READY_R	    /* synthesis LOC = "V6 "*/,      //Y
output  o_GPU_BASE_POWER_EN_R	    /* synthesis LOC = "K1 "*/,      //Y
input   i_GPU_BASE_PWR_GD_R	        /* synthesis LOC = "Y9 "*/,      //Y
input   i_THERM_OVERT_N_R	        /* synthesis LOC = "W6 "*/,      //Y
output  o_UBB_PEX_STRAP0_R	        /* synthesis LOC = "Y18"*/,      //Y
output  o_UBB_PEX_STRAP1_R	        /* synthesis LOC = "Y13"*/,      //Y
output  o_UBB_FPGA_PEX_RST_N_R	    /* synthesis LOC = "Y11"*/,      //Y
output  o_PWR_BRAKE_N_R	            /* synthesis LOC = "W8 "*/,      //Y
input   i_FPGA_EROT_FATALERR_N_R	/* synthesis LOC = "M2 "*/,      //Y
output  o_FPGA_EROT_RECOV_N_R	    /* synthesis LOC = "W5 "*/,      //Y
output  o_FPGA_EROT_RST_N_R	        /* synthesis LOC = "Y1 "*/,      //Y
input   i_FPGA_OVERT_N_R	        /* synthesis LOC = "B7 "*/,      //Y
output  o_FPGA_BOOT_EN_R	        /* synthesis LOC = "W2 "*/,      //Y
output  o_HGX_DETECT_N_R	        /* synthesis LOC = "Y2 "*/,      //Y
output  o_NVLINK_REFCLK_SELECT_R	/* synthesis LOC = "B20"*/,      //Y
output  o_WP_HW_CTRL_N	            /* synthesis LOC = "A17"*/,      //Y
input   i_GPU_BASE_HMC_READY_R	    /* synthesis LOC = "W4 "*/,      //Y
output  o_GPU_BASE_STBY_EN_R	    /* synthesis LOC = "R6 "*/,      //Y
input   i_BASE_PRSNT_N_R	        /* synthesis LOC = "F17"*/,      //Y
input   i_HMC_PRSNT_N_R	            /* synthesis LOC = "T6 "*/,      //Y
input   i_RSVD_PARTNER0_R	        /* synthesis LOC = "U6 "*/,      //Y
input   i_RSVD_PARTNER1_R	        /* synthesis LOC = "M1 "*/,      //Y
input   i_RSVD_PARTNER2_R	        /* synthesis LOC = "P1 "*/,      //Y
input   i_RSVD_PARTNER3_R	        /* synthesis LOC = "M3 "*/,      //Y
input   i_3V3IO_RSVD0_FFU_R	        /* synthesis LOC = "W1 "*/,      //Y
input   i_3V3IO_RSVD1_FFU_R	        /* synthesis LOC = "N1 "*/,      //Y
input   i_3V3IO_RSVD2_FFU_R	        /* synthesis LOC = "K4 "*/,      //Y
input   i_3V3IO_RSVD3_FFU_R	        /* synthesis LOC = "H2 "*/,      //Y
input   i_3V3IO_RSVD4_FFU_R	        /* synthesis LOC = "J3 "*/,      //Y
input   i_3V3IO_RSVD5_FFU_R	        /* synthesis LOC = "F1 "*/,      //Y
input   i_3V3IO_RSVD1_R	            /* synthesis LOC = "A7 "*/,      //Y
input   i_3V3IO_RSVD3_R	            /* synthesis LOC = "F16"*/,      //Y
input   i_3V3IO_RSVD4_R	            /* synthesis LOC = "A20"*/,      //Y
input   i_BB_RSVD_1_R	            /* synthesis LOC = "A16"*/,      //Y
//SGPIO
input   i_MB_SGPIO_CLK	            /* synthesis LOC = "J1 "*/,      //Y
input   i_MB_SGPIO_LD	            /* synthesis LOC = "G1 "*/,      //Y
output  o_MB_SGPIO_DATA_IN	        /* synthesis LOC = "H1 "*/,      //Y
input   i_MB_SGPIO_DATA_OUT	        /* synthesis LOC = "B2 "*/,      //Y
output  o_74LV165_CLK_R	            /* synthesis LOC = "L20"*/,      //Y
output  o_74LV165_LD_R	            /* synthesis LOC = "G20"*/,      //Y
input   i_74LV165_DATA_IN_R	        /* synthesis LOC = "B19"*/,      //Y
output  o_74LV165_1_CLK_R	        /* synthesis LOC = "A1 "*/,      //Y
output  o_74LV165_1_LD_R	        /* synthesis LOC = "A2 "*/,      //Y
input   i_74LV165_1_DATA_IN_R	    /* synthesis LOC = "R20"*/,      //Y
output  o_NIC_SGPIO_CLK_R	        /* synthesis LOC = "L19"*/,      //Y
output  o_NIC_SGPIO_SLOAD_R	        /* synthesis LOC = "N19"*/,      //Y
input   i_NIC_SGPIO_SDI_R	        /* synthesis LOC = "P19"*/,      //Y
input   i_NIC_SGPIO_SDO_R	        /* synthesis LOC = "M19"*/,      //Y
//REDRIVER
output  o_PAL_SAS_PWDN_R	        /* synthesis LOC = "A14"*/,      //Y
input   i_PAL_SAS_ALL_DONE_N	    /* synthesis LOC = "P16"*/,      //Y
output  o_DS160_TX_READ_EN_N	    /* synthesis LOC = "V9 "*/,      //Y
output  o_DS160_TX_PWDN1	        /* synthesis LOC = "V8 "*/,      //Y
output  o_DS160_TX_PWDN2	        /* synthesis LOC = "V10"*/,      //Y
input   i_DS160_TX_ALL_DONE_N	    /* synthesis LOC = "T14"*/,      //Y
output  o_DS160_RX_READ_EN_N	    /* synthesis LOC = "Y12"*/,      //Y
output  o_DS160_RX_PWDN1	        /* synthesis LOC = "Y10"*/,      //Y
output  o_DS160_RX_PWDN2	        /* synthesis LOC = "E17"*/,      //Y
input   i_DS160_RX_ALL_DONE_N	    /* synthesis LOC = "C19"*/,      //Y
//USB
output  o_PAL_USBMUX_OE_N	        /* synthesis LOC = "P14"*/,      //Y
output  o_PAL_USBMUX_SEL	        /* synthesis LOC = "L5 "*/,      //Y
//RST
output  o_SW0_PEX_PERST_N_R	        /* synthesis LOC = "Y17"*/,      //Y
output  o_SW1_PEX_PERST_N_R	        /* synthesis LOC = "C1 "*/,      //Y
output  o_SW2_PEX_PERST_N_R	        /* synthesis LOC = "A15"*/,      //Y
output  o_SW3_PEX_PERST_N_R	        /* synthesis LOC = "J20"*/,      //Y
input   i_SW0_SLOT1_RST_N_R	        /* synthesis LOC = "M5 "*/,      //Y
input   i_SW0_SLOT2_RST_N_R	        /* synthesis LOC = "U9 "*/,      //Y
input   i_SW0_SLOT3_RST_N_R	        /* synthesis LOC = "L14"*/,      //Y
input   i_SW0_SLOT4_RST_N_R	        /* synthesis LOC = "J14"*/,      //Y
input   i_SW0_SLOT5_RST_N_R	        /* synthesis LOC = "M4 "*/,      //Y
input   i_SW0_SLOT6_RST_N_R	        /* synthesis LOC = "F2 "*/,      //Y
input   i_SW1_SLOT1_RST_N_R	        /* synthesis LOC = "C2 "*/,      //Y
input   i_SW1_SLOT2_RST_N_R	        /* synthesis LOC = "B3 "*/,      //Y
input   i_SW1_SLOT3_RST_N_R	        /* synthesis LOC = "J2 "*/,      //Y
input   i_SW1_SLOT4_RST_N_R	        /* synthesis LOC = "J4 "*/,      //Y
input   i_SW1_SLOT5_RST_N_R	        /* synthesis LOC = "K7 "*/,      //Y
input   i_SW1_SLOT6_RST_N_R	        /* synthesis LOC = "C4 "*/,      //Y
input   i_SW2_SLOT1_RST_N_R	        /* synthesis LOC = "H18"*/,      //Y
input   i_SW2_SLOT2_RST_N_R	        /* synthesis LOC = "D19"*/,      //Y
input   i_SW2_SLOT3_RST_N_R	        /* synthesis LOC = "F6 "*/,      //Y
input   i_SW2_SLOT4_RST_N_R	        /* synthesis LOC = "M18"*/,      //Y
input   i_SW2_SLOT5_RST_N_R	        /* synthesis LOC = "H16"*/,      //Y
input   i_SW2_SLOT6_RST_N_R	        /* synthesis LOC = "E19"*/,      //Y
input   i_SW3_SLOT1_RST_N_R	        /* synthesis LOC = "H15"*/,      //Y
input   i_SW3_SLOT2_RST_N_R	        /* synthesis LOC = "M17"*/,      //Y
input   i_SW3_SLOT3_RST_N_R	        /* synthesis LOC = "E6 "*/,      //Y
input   i_SW3_SLOT4_RST_N_R	        /* synthesis LOC = "P18"*/,      //Y
input   i_SW3_SLOT5_RST_N_R	        /* synthesis LOC = "P17"*/,      //Y
input   i_SW3_SLOT6_RST_N_R	        /* synthesis LOC = "R17"*/,      //Y
output  o_SW0_NVME1_RST_R	        /* synthesis LOC = "W16"*/,      //Y
output  o_SW1_NVME1_RST_R	        /* synthesis LOC = "T7 "*/,      //Y
output  o_SW2_NVME1_RST_R	        /* synthesis LOC = "A3 "*/,      //Y
output  o_SW3_NVME1_RST_R	        /* synthesis LOC = "A9 "*/,      //Y
output  o_UBB_PEX_RST0_N_R	        /* synthesis LOC = "W9 "*/,      //Y
output  o_UBB_PEX_RST1_N_R	        /* synthesis LOC = "W7 "*/,      //Y
output  o_UBB_PEX_RST2_N_R	        /* synthesis LOC = "Y15"*/,      //Y
input   i_PE0_PERST_R	            /* synthesis LOC = "Y19"*/,      //Y
output  o_NIC1_PERST_N_R	        /* synthesis LOC = "T4 "*/,      //Y
output  o_NIC2_PERST_N_R	        /* synthesis LOC = "R4 "*/,      //Y
output  o_NIC3_PERST_N_R	        /* synthesis LOC = "P6 "*/,      //Y
output  o_NIC4_PERST_N_R	        /* synthesis LOC = "M6 "*/,      //Y
output  o_NIC5_PERST_N_R	        /* synthesis LOC = "U1 "*/,      //Y
output  o_NIC6_PERST_N_R	        /* synthesis LOC = "U2 "*/,      //Y
output  o_NIC7_PERST_N_R	        /* synthesis LOC = "P4 "*/,      //Y
output  o_NIC8_PERST_N_R	        /* synthesis LOC = "N5 "*/,      //Y
output  o_I2C_RST0_N_R	            /* synthesis LOC = "A8 "*/,      //Y
output  o_I2C_RST1_N_R	            /* synthesis LOC = "A6 "*/,      //Y
output  o_I2C_RST2_N_R	            /* synthesis LOC = "A4 "*/,      //Y
output  o_SW0_SPI_CS_SEL_R	        /* synthesis LOC = "W11"*/,      //Y
output  o_SW1_SPI_CS_SEL_R	        /* synthesis LOC = "B1 "*/,      //Y
output  o_SW2_SPI_CS_SEL_R	        /* synthesis LOC = "A13"*/,      //Y
output  o_SW3_SPI_CS_SEL_R	        /* synthesis LOC = "J19"*/,      //Y

output  o_debug_led1	            /* synthesis LOC = "W12"*/,      //
output  o_debug_led2	            /* synthesis LOC = "W13"*/,      //

input   i_ict_tp100                 /* synthesis LOC = "V15"*/       // 2024-12-4 add for ict single board pwr on  simulate SLPS5




);
