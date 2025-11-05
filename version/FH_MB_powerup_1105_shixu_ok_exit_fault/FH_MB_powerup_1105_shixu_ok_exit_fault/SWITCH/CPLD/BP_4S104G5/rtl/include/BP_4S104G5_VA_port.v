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

//CPLD
// input   i_CPLD1_TMS  	            /* synthesis LOC = "D9 "*/,      //Y
// input   i_CPLD1_TCK  	            /* synthesis LOC = "C9 "*/,      //Y
// input   i_CPLD1_TDI  	            /* synthesis LOC = "C7 "*/,      //Y
// output  o_CPLD1_TDO                 /* synthesis LOC = "E8 "*/,      //Y

input   i_CPLD1_CLK	                /* synthesis LOC = "B10"*/,      //Y
input   i_CPLD1_HDR_R	            /* synthesis LOC = "C12"*/,      //Y
input   i_CPLD1_JTAGEN	            /* synthesis LOC = "C13"*/,      //Y
input   i_CPLD1_PROGRAM_N           /* synthesis LOC = "D13"*/,      //Y
input   i_CPLD1_INIT_N              /* synthesis LOC = "C17"*/,      //Y
input   i_CPLD1_DONE                /* synthesis LOC = "A19"*/,      //Y
input   i_CPLD1_PULLUP_SN           /* synthesis LOC = "Y20"*/,      //Y
output  o_CPLD1_LED0_N	            /* synthesis LOC = "W3 "*/,      //Y
output  o_CPLD1_LED1_N	            /* synthesis LOC = "Y2 "*/,      //Y

output  o_CPLD_RSV1	                /* synthesis LOC = "B13"*/,      //Y
output  o_CPLD_RSV2	                /* synthesis LOC = "A17"*/,      //Y
output  o_CPLD_RSV3	                /* synthesis LOC = "B12"*/,      //Y
output  o_CPLD_RSV4	                /* synthesis LOC = "B14"*/,      //Y
output  o_CPLD_RSV5	                /* synthesis LOC = "A18"*/,      //Y
output  o_CPLD_RSV6	                /* synthesis LOC = "B17"*/,      //Y

//TX/RX
input   i_SW0_SDB_TX_R	            /* synthesis LOC = "P14"*/,      //Y
input   i_SW1_SDB_TX_R	            /* synthesis LOC = "C14"*/,      //Y
input   i_SW2_SDB_TX_R	            /* synthesis LOC = "D17"*/,      //Y
input   i_SW3_SDB_TX_R	            /* synthesis LOC = "A20"*/,      //Y
output  o_SW0_SDB_RX_R	            /* synthesis LOC = "T12"*/,      //Y
output  o_SW1_SDB_RX_R	            /* synthesis LOC = "C15"*/,      //Y
output  o_SW2_SDB_RX_R	            /* synthesis LOC = "C18"*/,      //Y
output  o_SW3_SDB_RX_R	            /* synthesis LOC = "B19"*/,      //Y
input   i_SW0_UART_TX_R	            /* synthesis LOC = "Y8 "*/,      //Y
input   i_SW1_UART_TX_R	            /* synthesis LOC = "A9 "*/,      //Y
input   i_SW2_UART_TX_R	            /* synthesis LOC = "B6 "*/,      //Y
input   i_SW3_UART_TX_R	            /* synthesis LOC = "B20"*/,      //Y
output  o_SW0_UART_RX_R	            /* synthesis LOC = "W4 "*/,      //Y
output  o_SW1_UART_RX_R	            /* synthesis LOC = "C3 "*/,      //Y
output  o_SW2_UART_RX_R	            /* synthesis LOC = "N4 "*/,      //Y
output  o_SW3_UART_RX_R	            /* synthesis LOC = "C16"*/,      //Y

output  o_BMC_SW_UART_RX0_R	        /* synthesis LOC = "Y11"*/,      //Y
input   i_BMC_SW_UART_TX0_R	        /* synthesis LOC = "T10"*/,      //Y

//MCIO
output  o_MCIO01A_PE_RST_R_N	    /* synthesis LOC = "U18"*/,      //Y
output  o_MCIO01C_PE_RST_R_N	    /* synthesis LOC = "W2 "*/,      //Y
output  o_MCIO02A_PE_RST_R_N	    /* synthesis LOC = "Y1 "*/,      //Y
output  o_MCIO11A_PE_RST_R_N	    /* synthesis LOC = "K2 "*/,      //Y
output  o_MCIO11C_PE_RST_R_N	    /* synthesis LOC = "N3 "*/,      //Y
output  o_MCIO12A_PE_RST_R_N	    /* synthesis LOC = "T2 "*/,      //Y
output  o_MCIO21A_PE_RST_R_N	    /* synthesis LOC = "H7 "*/,      //Y
output  o_MCIO21C_PE_RST_R_N	    /* synthesis LOC = "D8 "*/,      //Y
output  o_MCIO22A_PE_RST_R_N	    /* synthesis LOC = "N2 "*/,      //Y
output  o_MCIO31A_PE_RST_R_N	    /* synthesis LOC = "M20"*/,      //Y
output  o_MCIO31C_PE_RST_R_N	    /* synthesis LOC = "K16"*/,      //Y
output  o_MCIO32A_PE_RST_R_N	    /* synthesis LOC = "M17"*/,      //Y


output  o_MCIO01A_CB_RSV_R	        /* synthesis LOC = "M16"*/,      //Y
output  o_MCIO01C_CB_RSV_R	        /* synthesis LOC = "L15"*/,      //Y
output  o_MCIO02A_CB_RSV_R	        /* synthesis LOC = "R4 "*/,      //Y
output  o_MCIO02C_CB_RSV_R	        /* synthesis LOC = "H17"*/,      //Y
output  o_MCIO11A_CB_RSV_R	        /* synthesis LOC = "K4 "*/,      //Y
output  o_MCIO11C_CB_RSV_R	        /* synthesis LOC = "K1 "*/,      //Y
output  o_MCIO12A_CB_RSV_R	        /* synthesis LOC = "P3 "*/,      //Y
output  o_MCIO12C_CB_RSV_R	        /* synthesis LOC = "M2 "*/,      //Y
output  o_MCIO21A_CB_RSV_R	        /* synthesis LOC = "K7 "*/,      //Y
output  o_MCIO21C_CB_RSV_R	        /* synthesis LOC = "L7 "*/,      //Y
output  o_MCIO22A_CB_RSV_R	        /* synthesis LOC = "P2 "*/,      //Y
output  o_MCIO22C_CB_RSV_R	        /* synthesis LOC = "G15"*/,      //Y
output  o_MCIO31A_CB_RSV_R	        /* synthesis LOC = "J18"*/,      //Y
output  o_MCIO31C_CB_RSV_R	        /* synthesis LOC = "K20"*/,      //Y
output  o_MCIO32A_CB_RSV_R	        /* synthesis LOC = "V19"*/,      //Y
output  o_MCIO32C_CB_RSV_R	        /* synthesis LOC = "J15"*/,      //Y


input   i_MCIO01A_ALERT_R_N	        /* synthesis LOC = "R2 "*/,      //Y
input   i_MCIO01C_ALERT_R_N	        /* synthesis LOC = "J17"*/,      //Y
input   i_MCIO11A_ALERT_R_N	        /* synthesis LOC = "P1 "*/,      //Y
input   i_MCIO11C_ALERT_R_N	        /* synthesis LOC = "L1 "*/,      //Y
input   i_MCIO21A_ALERT_R_N	        /* synthesis LOC = "M3 "*/,      //Y
input   i_MCIO21C_ALERT_R_N	        /* synthesis LOC = "F16"*/,      //Y
input   i_MCIO31A_ALERT_R_N	        /* synthesis LOC = "V13"*/,      //Y
input   i_MCIO31C_ALERT_R_N	        /* synthesis LOC = "F14"*/,      //Y

//I2C
input   i_I2C1_CPLD1_REG_SCL	    /* synthesis LOC = "A11"*/,      //Y
inout   io_I2C1_CPLD1_REG_SDA	    /* synthesis LOC = "A12"*/,      //Y 
inout   io_I2C1_CPLD1_UPDATE_SCL	/* synthesis LOC = "C11"*/,      //Y
inout   io_I2C1_CPLD1_UPDATE_SDA	/* synthesis LOC = "D11"*/,      //Y

output  o_I2C_RST0_R_N	            /* synthesis LOC = "A8 "*/,      //Y
output  o_I2C_RST1_R_N	            /* synthesis LOC = "C8 "*/,      //Y
output  o_I2C_RST2_R_N	            /* synthesis LOC = "W6 "*/,      //Y
output  o_I2C_RST3_R_N	            /* synthesis LOC = "C6 "*/,      //Y
output  o_I2C_RST4_7_R_N	        /* synthesis LOC = "Y17"*/,      //Y

//PAL
input   i_P3V3_STBY_PG	            /* synthesis LOC = "T13"*/,      //Y
input   i_PAL_P12V_PG	            /* synthesis LOC = "R7 "*/,      //Y
input   i_PAL_P12V_STBY_PG	        /* synthesis LOC = "U17"*/,      //Y
input   i_PAL_P12V_STBY_FLTB	    /* synthesis LOC = "U14"*/,      //Y
input   i_PAL_P12V_OC   	        /* synthesis LOC = "T4 "*/,      //Y
input   i_P12V_SNS_ALERT   	        /* synthesis LOC = "Y3 "*/,      //Y

output  o_PAL_P12V_EN_R	            /* synthesis LOC = "Y14"*/,      //Y


input   i_P0V8_SW0_PWRGD	        /* synthesis LOC = "T16"*/,      //Y
input   i_P0V8_SW1_PWRGD	        /* synthesis LOC = "H3 "*/,      //Y
input   i_P0V8_SW2_PWRGD	        /* synthesis LOC = "A10"*/,      //Y
input   i_P0V8_SW3_PWRGD	        /* synthesis LOC = "F17"*/,      //Y

input   i_PG_P1V8_R	                /* synthesis LOC = "T18"*/,      //Y
input   i_PG_P5V0_R	                /* synthesis LOC = "U2 "*/,      //Y
input   i_PG_P1V8_PLL_R	            /* synthesis LOC = "T17"*/,      //Y

output  o_CT_P1V25_SW_EN_R	        /* synthesis LOC = "W7 "*/,      //Y
output  o_PAL_SW_PWR_EN_R	        /* synthesis LOC = "T5 "*/,      //Y

output  o_PAL_DB2000_PWRGD0	        /* synthesis LOC = "W8 "*/,      //Y
output  o_PAL_DB2000_PWRGD1	        /* synthesis LOC = "G2 "*/,      //Y
output  o_PAL_DB2000_PWRGD2	        /* synthesis LOC = "A2 "*/,      //Y
output  o_PAL_DB2000_PWRGD3	        /* synthesis LOC = "B9 "*/,      //Y

input   i_CT_P1V25_SW0_PG	        /* synthesis LOC = "R19"*/,      //Y
input   i_CT_P1V25_SW1_PG	        /* synthesis LOC = "G9 "*/,      //Y
input   i_CT_P1V25_SW2_PG	        /* synthesis LOC = "M18"*/,      //Y
input   i_CT_P1V25_SW3_PG	        /* synthesis LOC = "K19"*/,      //Y



output  o_P1V8_EN_R	                /* synthesis LOC = "W16"*/,      //Y
output  o_P5V0_EN_R	                /* synthesis LOC = "Y5 "*/,      //Y

output  o_P1V8_PLL_EN_R	            /* synthesis LOC = "Y16"*/,      //Y

//MB
input   i_MB_VPP0_ALT_R_N	        /* synthesis LOC = "U19"*/,      //Y
input   i_MB_VPP1_ALT_R_N	        /* synthesis LOC = "J3 "*/,      //Y
input   i_MB_VPP2_ALT_R_N	        /* synthesis LOC = "J6 "*/,      //Y
input   i_MB_VPP3_ALT_R_N	        /* synthesis LOC = "H18"*/,      //Y

//NVME
output  o_NVME1_RSV_R    	        /* synthesis LOC = "H16"*/,      //Y
output  o_NVME2_RSV_R    	        /* synthesis LOC = "N1 "*/,      //Y
output  o_NVME3_RSV_R    	        /* synthesis LOC = "F11"*/,      //Y
output  o_NVME4_RSV_R   	        /* synthesis LOC = "H15"*/,      //Y


output  o_NVME1_RST_R_N  	        /* synthesis LOC = "K18"*/,      //Y
output  o_NVME2_RST_R_N  	        /* synthesis LOC = "L2 "*/,      //Y
output  o_NVME3_RST_R_N  	        /* synthesis LOC = "E14"*/,      //Y
output  o_NVME4_RST_R_N  	        /* synthesis LOC = "K15"*/,      //Y


input   i_NVME1_PRSNT0_R_N	        /* synthesis LOC = "U15"*/,      //Y
input   i_NVME1_PRSNT1_R_N	        /* synthesis LOC = "L17"*/,      //Y
input   i_NVME2_PRSNT0_R_N	        /* synthesis LOC = "J4 "*/,      //Y
input   i_NVME2_PRSNT1_R_N	        /* synthesis LOC = "L3 "*/,      //Y


input   i_NVME1_ALERT_R_N	        /* synthesis LOC = "L16"*/,      //Y
input   i_NVME2_ALERT_R_N	        /* synthesis LOC = "L4 "*/,      //Y
input   i_NVME3_ALERT_R_N	        /* synthesis LOC = "E15"*/,      //Y
input   i_NVME4_ALERT_R_N	        /* synthesis LOC = "G14"*/,      //Y


output  o_NVME1_POWER_EN_R	        /* synthesis LOC = "U20"*/,      //Y
output  o_NVME2_POWER_EN_R	        /* synthesis LOC = "M1 "*/,      //Y
output  o_NVME3_POWER_EN_R	        /* synthesis LOC = "D12"*/,      //Y
output  o_NVME4_POWER_EN_R	        /* synthesis LOC = "K14"*/,      //Y

//SGPIO
input   i_MCPLD_SGPIO_CLK	        /* synthesis LOC = "A13 "*/,      //Y
input   i_MCPLD_SGPIO_LD	        /* synthesis LOC = "A14 "*/,      //Y
output  o_MCPLD_SGPIO_DATA_IN	    /* synthesis LOC = "A16 "*/,      //Y
input   i_MCPLD_SGPIO_DATA_OUT	    /* synthesis LOC = "B18 "*/,      //Y

//NPU
input   i_NPU1_4_WAKE_R_N	        /* synthesis LOC = "T11"*/,      //Y
input   i_NPU5_8_WAKE_R_N	        /* synthesis LOC = "H19"*/,      //Y

output  o_NPU1A_POWER_EN_R	        /* synthesis LOC = "U1 "*/,      //Y
output  o_NPU1C_POWER_EN_R	        /* synthesis LOC = "T1 "*/,      //Y
output  o_NPU2A_POWER_EN_R	        /* synthesis LOC = "V4 "*/,      //Y
output  o_NPU2C_POWER_EN_R	        /* synthesis LOC = "U10"*/,      //Y
output  o_NPU3A_POWER_EN_R	        /* synthesis LOC = "F8 "*/,      //Y
output  o_NPU3C_POWER_EN_R	        /* synthesis LOC = "G12"*/,      //Y
output  o_NPU4A_POWER_EN_R	        /* synthesis LOC = "G10"*/,      //Y
output  o_NPU4C_POWER_EN_R	        /* synthesis LOC = "E6 "*/,      //Y
output  o_NPU5A_POWER_EN_R	        /* synthesis LOC = "F12"*/,      //Y
output  o_NPU5C_POWER_EN_R	        /* synthesis LOC = "N6 "*/,      //Y
output  o_NPU6A_POWER_EN_R	        /* synthesis LOC = "D16"*/,      //Y
output  o_NPU6C_POWER_EN_R	        /* synthesis LOC = "C19"*/,      //Y
output  o_NPU7A_POWER_EN_R	        /* synthesis LOC = "M19"*/,      //Y
output  o_NPU7C_POWER_EN_R	        /* synthesis LOC = "G20"*/,      //Y
output  o_NPU8A_POWER_EN_R	        /* synthesis LOC = "L19"*/,      //Y
output  o_NPU8C_POWER_EN_R	        /* synthesis LOC = "F18"*/,      //Y

output  o_NPU1A_RSV_R   	        /* synthesis LOC = "R20"*/,      //Y
output  o_NPU1C_RSV_R   	        /* synthesis LOC = "R5 "*/,      //Y
output  o_NPU2A_RSV_R   	        /* synthesis LOC = "V2 "*/,      //Y
output  o_NPU2C_RSV_R   	        /* synthesis LOC = "V6 "*/,      //Y
output  o_NPU3A_RSV_R   	        /* synthesis LOC = "E7 "*/,      //Y
output  o_NPU3C_RSV_R   	        /* synthesis LOC = "G11"*/,      //Y
output  o_NPU4A_RSV_R   	        /* synthesis LOC = "F6 "*/,      //Y
output  o_NPU4C_RSV_R   	        /* synthesis LOC = "F5 "*/,      //Y
output  o_NPU5A_RSV_R	            /* synthesis LOC = "F19"*/,      //Y
output  o_NPU5C_RSV_R	            /* synthesis LOC = "P5 "*/,      //Y
output  o_NPU6A_RSV_R   	        /* synthesis LOC = "G19"*/,      //Y
output  o_NPU6C_RSV_R   	        /* synthesis LOC = "J19"*/,      //Y
output  o_NPU7A_RSV_R   	        /* synthesis LOC = "E20"*/,      //Y
output  o_NPU7C_RSV_R   	        /* synthesis LOC = "H20"*/,      //Y
output  o_NPU8A_RSV_R   	        /* synthesis LOC = "L20"*/,      //Y
output  o_NPU8C_RSV_R   	        /* synthesis LOC = "D19"*/,      //Y

output  o_NPU1A_RST_R_N	            /* synthesis LOC = "P19"*/,      //Y
output  o_NPU1C_RST_R_N	            /* synthesis LOC = "T20"*/,      //Y
output  o_NPU2A_RST_R_N	            /* synthesis LOC = "V3 "*/,      //Y
output  o_NPU2C_RST_R_N	            /* synthesis LOC = "V8 "*/,      //Y
output  o_NPU3A_RST_R_N	            /* synthesis LOC = "E2 "*/,      //Y
output  o_NPU3C_RST_R_N	            /* synthesis LOC = "F4 "*/,      //Y
output  o_NPU4A_RST_R_N	            /* synthesis LOC = "F3 "*/,      //Y
output  o_NPU4C_RST_R_N	            /* synthesis LOC = "G4 "*/,      //Y
output  o_NPU5A_RST_R_N	            /* synthesis LOC = "D18"*/,      //Y
output  o_NPU5C_RST_R_N	            /* synthesis LOC = "G7 "*/,      //Y
output  o_NPU6A_RST_R_N	            /* synthesis LOC = "G8 "*/,      //Y
output  o_NPU6C_RST_R_N	            /* synthesis LOC = "G13"*/,      //Y
output  o_NPU7A_RST_R_N  	        /* synthesis LOC = "N18"*/,      //Y 
output  o_NPU7C_RST_R_N  	        /* synthesis LOC = "F20"*/,      //Y
output  o_NPU8A_RST_R_N  	        /* synthesis LOC = "E19"*/,      //Y
output  o_NPU8C_RST_R_N  	        /* synthesis LOC = "E17"*/,      //Y

//NIC
input   i_NIC1_4_WAKE_R_N	        /* synthesis LOC = "P15"*/,      //Y
input   i_NIC5_8_WAKE_R_N	        /* synthesis LOC = "P8 "*/,      //Y

output  o_NIC1A_POWER_EN_R	        /* synthesis LOC = "R16"*/,      //Y
output  o_NIC1C_POWER_EN_R	        /* synthesis LOC = "T14"*/,      //Y
output  o_NIC2A_POWER_EN_R	        /* synthesis LOC = "R13"*/,      //Y
output  o_NIC2C_POWER_EN_R	        /* synthesis LOC = "R12"*/,      //Y
output  o_NIC3A_POWER_EN_R	        /* synthesis LOC = "W1 "*/,      //Y
output  o_NIC3C_POWER_EN_R	        /* synthesis LOC = "P12"*/,      //Y
output  o_NIC4A_POWER_EN_R	        /* synthesis LOC = "T8 "*/,      //Y
output  o_NIC4C_POWER_EN_R	        /* synthesis LOC = "T7 "*/,      //Y
output  o_NIC5A_POWER_EN_R	        /* synthesis LOC = "D2 "*/,      //Y
output  o_NIC5C_POWER_EN_R	        /* synthesis LOC = "G6 "*/,      //Y
output  o_NIC6A_POWER_EN_R	        /* synthesis LOC = "P7 "*/,      //Y
output  o_NIC6C_POWER_EN_R	        /* synthesis LOC = "L5 "*/,      //Y
output  o_NIC7A_POWER_EN_R	        /* synthesis LOC = "M15"*/,      //Y
output  o_NIC7C_POWER_EN_R	        /* synthesis LOC = "R3 "*/,      //Y
output  o_NIC8A_POWER_EN_R	        /* synthesis LOC = "C2 "*/,      //Y
output  o_NIC8C_POWER_EN_R	        /* synthesis LOC = "R1 "*/,      //Y

output  o_NIC1A_RSV_R   	        /* synthesis LOC = "Y18"*/,      //Y
output  o_NIC1C_RSV_R   	        /* synthesis LOC = "W17"*/,      //Y
output  o_NIC2A_RSV_R   	        /* synthesis LOC = "V20"*/,      //Y
output  o_NIC2C_RSV_R   	        /* synthesis LOC = "T19"*/,      //Y
output  o_NIC3A_RSV_R   	        /* synthesis LOC = "U12"*/,      //Y
output  o_NIC3C_RSV_R   	        /* synthesis LOC = "R17"*/,      //Y
output  o_NIC4A_RSV_R   	        /* synthesis LOC = "N19"*/,      //Y
output  o_NIC4C_RSV_R   	        /* synthesis LOC = "P20"*/,      //Y
output  o_NIC5A_RSV_R   	        /* synthesis LOC = "K5 "*/,      //Y
output  o_NIC5C_RSV_R   	        /* synthesis LOC = "H6 "*/,      //Y
output  o_NIC6A_RSV_R   	        /* synthesis LOC = "R9 "*/,      //Y
output  o_NIC6C_RSV_R   	        /* synthesis LOC = "C1 "*/,      //Y
output  o_NIC7A_RSV_R   	        /* synthesis LOC = "V17"*/,      //Y
output  o_NIC7C_RSV_R   	        /* synthesis LOC = "P17"*/,      //Y
output  o_NIC8A_RSV_R   	        /* synthesis LOC = "M5 "*/,      //Y
output  o_NIC8C_RSV_R   	        /* synthesis LOC = "V15"*/,      //Y

output  o_NIC1A_RST_R_N  	        /* synthesis LOC = "R15"*/,      //Y
output  o_NIC1C_RST_R_N  	        /* synthesis LOC = "R11"*/,      //Y
output  o_NIC2A_RST_R_N  	        /* synthesis LOC = "P11"*/,      //Y
output  o_NIC2C_RST_R_N  	        /* synthesis LOC = "R10"*/,      //Y
output  o_NIC3A_RST_R_N  	        /* synthesis LOC = "P13"*/,      //Y
output  o_NIC3C_RST_R_N  	        /* synthesis LOC = "U9 "*/,      //Y
output  o_NIC4A_RST_R_N  	        /* synthesis LOC = "U6 "*/,      //Y
output  o_NIC4C_RST_R_N  	        /* synthesis LOC = "T3 "*/,      //Y
output  o_NIC5A_RST_R_N  	        /* synthesis LOC = "F7 "*/,      //Y
output  o_NIC5C_RST_R_N  	        /* synthesis LOC = "E1 "*/,      //Y
output  o_NIC6A_RST_R_N  	        /* synthesis LOC = "P6 "*/,      //Y
output  o_NIC6C_RST_R_N  	        /* synthesis LOC = "G5 "*/,      //Y
output  o_NIC7A_RST_R_N  	        /* synthesis LOC = "L14"*/,      //Y
output  o_NIC7C_RST_R_N  	        /* synthesis LOC = "V10"*/,      //Y
output  o_NIC8A_RST_R_N  	        /* synthesis LOC = "L6 "*/,      //Y
output  o_NIC8C_RST_R_N  	        /* synthesis LOC = "V9 "*/,      //Y

input   i_NIC1A_PRSNT0_R_N	        /* synthesis LOC = "R8 "*/,      //Y
input   i_NIC1A_PRSNT1_R_N	        /* synthesis LOC = "Y19"*/,      //Y
input   i_NIC1C_PRSNT0_R_N	        /* synthesis LOC = "P10"*/,      //Y
input   i_NIC1C_PRSNT1_R_N	        /* synthesis LOC = "W18"*/,      //Y
input   i_NIC2A_PRSNT0_R_N	        /* synthesis LOC = "T6 "*/,      //Y
input   i_NIC2A_PRSNT1_R_N	        /* synthesis LOC = "W20"*/,      //Y
input   i_NIC2C_PRSNT0_R_N	        /* synthesis LOC = "T9 "*/,      //Y
input   i_NIC2C_PRSNT1_R_N	        /* synthesis LOC = "W19"*/,      //Y
input   i_NIC3A_PRSNT0_R_N	        /* synthesis LOC = "R14"*/,      //Y
input   i_NIC3A_PRSNT1_R_N	        /* synthesis LOC = "N14"*/,      //Y
input   i_NIC3C_PRSNT0_R_N	        /* synthesis LOC = "P9 "*/,      //Y
input   i_NIC3C_PRSNT1_R_N	        /* synthesis LOC = "P16"*/,      //Y
input   i_NIC4A_PRSNT0_R_N	        /* synthesis LOC = "U5 "*/,      //Y
input   i_NIC4A_PRSNT1_R_N	        /* synthesis LOC = "P18"*/,      //Y
input   i_NIC4C_PRSNT0_R_N	        /* synthesis LOC = "U4 "*/,      //Y
input   i_NIC4C_PRSNT1_R_N	        /* synthesis LOC = "N20"*/,      //Y
input   i_NIC5A_PRSNT0_R_N	        /* synthesis LOC = "B1 "*/,      //Y
input   i_NIC5A_PRSNT1_R_N	        /* synthesis LOC = "K6 "*/,      //Y
input   i_NIC5C_PRSNT0_R_N	        /* synthesis LOC = "F2 "*/,      //Y
input   i_NIC5C_PRSNT1_R_N	        /* synthesis LOC = "E3 "*/,      //Y
input   i_NIC6A_PRSNT0_R_N	        /* synthesis LOC = "M7 "*/,      //Y
input   i_NIC6A_PRSNT1_R_N	        /* synthesis LOC = "M14"*/,      //Y
input   i_NIC6C_PRSNT0_R_N	        /* synthesis LOC = "D1 "*/,      //Y
input   i_NIC6C_PRSNT1_R_N	        /* synthesis LOC = "J5 "*/,      //Y
input   i_NIC7A_PRSNT0_R_N	        /* synthesis LOC = "N15"*/,      //Y
input   i_NIC7A_PRSNT1_R_N	        /* synthesis LOC = "N17"*/,      //Y
input   i_NIC7C_PRSNT0_R_N	        /* synthesis LOC = "K17"*/,      //Y
input   i_NIC7C_PRSNT1_R_N	        /* synthesis LOC = "V16"*/,      //Y
input   i_NIC8A_PRSNT0_R_N	        /* synthesis LOC = "M6 "*/,      //Y
input   i_NIC8A_PRSNT1_R_N	        /* synthesis LOC = "N5 "*/,      //Y
input   i_NIC8C_PRSNT0_R_N	        /* synthesis LOC = "V1 "*/,      //Y
input   i_NIC8C_PRSNT1_R_N	        /* synthesis LOC = "N16"*/,      //Y

//RST
output  o_SW0_PEX_PERST_R_N	        /* synthesis LOC = "W13"*/,      //Y
output  o_SW1_PEX_PERST_R_N	        /* synthesis LOC = "J1 "*/,      //Y
output  o_SW2_PEX_PERST_R_N	        /* synthesis LOC = "E4 "*/,      //Y
output  o_SW3_PEX_PERST_R_N	        /* synthesis LOC = "F9 "*/,      //Y

//SW
output  o_P0V8_SW_EN_R  	        /* synthesis LOC = "F10"*/,      //Y
input   i_PAL_SW_PWR_PG	            /* synthesis LOC = "Y12"*/,      //Y

input   i_PAL_SW_GPU_PRSNT_R_N	    /* synthesis LOC = "W12"*/,      //Y


input   i_P0V8_SW0_ALERT_N	        /* synthesis LOC = "J16"*/,      //Y
input   i_P0V8_SW2_ALERT_N	        /* synthesis LOC = "J14"*/,      //Y
input   i_P0V8_SW3_ALERT_N	        /* synthesis LOC = "F15"*/,      //Y

input   i_P0V8_SW0_VRHOT_N	        /* synthesis LOC = "V14 "*/,     //Y
input   i_P0V8_SW1_VRHOT_N	        /* synthesis LOC = "H4 "*/,      //Y
input   i_P0V8_SW2_VRHOT_N	        /* synthesis LOC = "H14"*/,      //Y
input   i_P0V8_SW3_VRHOT_N	        /* synthesis LOC = "G16"*/,      //Y

input   i_P0V8_SW0_FAULT_N	        /* synthesis LOC = "V12"*/,      //Y
input   i_P0V8_SW2_FAULT_N	        /* synthesis LOC = "F13"*/,      //Y
input   i_P0V8_SW3_FAULT_N	        /* synthesis LOC = "G17"*/,      //Y

output  o_SW0_PAL_SPI_SEL_R	        /* synthesis LOC = "Y10"*/,      //Y
output  o_SW1_PAL_SPI_SEL_R	        /* synthesis LOC = "A5 "*/,      //Y
output  o_SW2_PAL_SPI_SEL_R	        /* synthesis LOC = "G3 "*/,      //Y
output  o_SW3_PAL_SPI_SEL_R	        /* synthesis LOC = "C20"*/,      //Y

output  o_SW0_SPI_CS_SEL_R	        /* synthesis LOC = "W14"*/,      //Y
output  o_SW1_SPI_CS_SEL_R	        /* synthesis LOC = "A4 "*/,      //Y
output  o_SW2_SPI_CS_SEL_R	        /* synthesis LOC = "M4 "*/,      //Y
output  o_SW3_SPI_CS_SEL_R	        /* synthesis LOC = "D20"*/,      //Y

output  o_PAL_SW0_3_VPP_S0_R	    /* synthesis LOC = "D10"*/,      //Y
output  o_PAL_SW0_3_VPP_S1_R	    /* synthesis LOC = "D14"*/,      //Y

output  o_SW0_NPU_CLK_OE_N_R	    /* synthesis LOC = "Y9 "*/,      //Y
output  o_SW1_NPU_CLK_OE_N_R	    /* synthesis LOC = "H1 "*/,      //Y
output  o_SW2_NPU_CLK_OE_N_R	    /* synthesis LOC = "A1 "*/,      //Y
output  o_SW3_NPU_CLK_OE_N_R	    /* synthesis LOC = "C10"*/,      //Y

output  o_SW0_MCIO2_CLK_OE_N_R	    /* synthesis LOC = "W9 "*/,      //Y
output  o_SW1_MCIO2_CLK_OE_N_R	    /* synthesis LOC = "J2 "*/,      //Y
output  o_SW2_MCIO2_CLK_OE_N_R	    /* synthesis LOC = "B4 "*/,      //Y
output  o_SW3_MCIO2_CLK_OE_N_R	    /* synthesis LOC = "B8 "*/,      //Y

input   i_SW0_CLKREQ_N_R	        /* synthesis LOC = "W10"*/,     //Y
input   i_SW1_CLKREQ_N_R	        /* synthesis LOC = "H2 "*/,     //Y
input   i_SW2_CLKREQ_N_R	        /* synthesis LOC = "D5 "*/,     //Y
input   i_SW3_CLKREQ_N_R	        /* synthesis LOC = "B2 "*/,     //Y

input   i_SW0_NIC_ALERT_R_N	        /* synthesis LOC = "Y15"*/,      //Y
input   i_SW1_NIC_ALERT_R_N	        /* synthesis LOC = "Y4 "*/,      //Y
input   i_SW2_NIC_ALERT_R_N	        /* synthesis LOC = "A6 "*/,      //Y
input   i_SW3_NIC_ALERT_R_N	        /* synthesis LOC = "D7 "*/,      //Y

output  o_PAL_RST_SW0_3_NIC_VPP1_N_R/* synthesis LOC = "Y13"*/,      //Y
output  o_PAL_RST_SW0_VPP2_N_R	    /* synthesis LOC = "Y7 "*/,      //Y
output  o_PAL_RST_SW1_VPP2_N_R	    /* synthesis LOC = "F1 "*/,      //Y
output  o_PAL_RST_SW2_VPP2_N_R	    /* synthesis LOC = "P4 "*/,      //Y
output  o_PAL_RST_SW3_VPP2_N_R	    /* synthesis LOC = "D6 "*/,      //Y

//SPI
input   i_SPI_RESET_R_N  	        /* synthesis LOC = "W15"*/,      //Y

output  o_PAL_SPI_CSCLK_S0_R	    /* synthesis LOC = "B3 "*/,      //Y
output  o_PAL_SPI_CSCLK_S1_R	    /* synthesis LOC = "B5 "*/,      //Y

output  o_PAL_SPI_MISOMOSI_S0_R	    /* synthesis LOC = "A3 "*/,      //Y
output  o_PAL_SPI_MISOMOSI_S1_R	    /* synthesis LOC = "C4 "*/,      //Y

//OTHER
input   i_BASE0_VPP_INT_N_R	        /* synthesis LOC = "W5 "*/,      //Y
input   i_BASE1_VPP_INT_N_R	        /* synthesis LOC = "A7 "*/,      //Y
input   i_BASE2_VPP_INT_N_R	        /* synthesis LOC = "B7 "*/,      //Y
input   i_BASE3_VPP_INT_N_R	        /* synthesis LOC = "D15"*/,      //Y

input   i_TEMP_ALERT_0_R	        /* synthesis LOC = "G1 "*/,      //Y
input   i_TEMP_ALERT_1_R	        /* synthesis LOC = "B16"*/,      //Y
input   i_TEMP_ALERT_2_R	        /* synthesis LOC = "B11"*/,      //Y
input   i_TEMP_ALERT_3_R	        /* synthesis LOC = "R6 "*/       //Y

);
