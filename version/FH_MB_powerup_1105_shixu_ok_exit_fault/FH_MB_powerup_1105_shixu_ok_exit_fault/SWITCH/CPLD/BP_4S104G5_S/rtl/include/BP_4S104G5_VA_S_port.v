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
module BP_4S104G5_S(

//CPLD
// input   i_CPLD2_TMS  	            /* synthesis LOC = "B8 "*/,      //
// input   i_CPLD2_TCK  	            /* synthesis LOC = "A7 "*/,      //
// input   i_CPLD2_TDI  	            /* synthesis LOC = "A6 "*/,      //
// output  o_CPLD2_TDO                 /* synthesis LOC = "C6 "*/,      //

input   i_CPLD2_CLK	                /* synthesis LOC = "C8 "*/,      //Y
input   i_CPLD2_HDR_R	            /* synthesis LOC = "B6 "*/,      //Y
input   i_CPLD2_JTAGEN_N	        /* synthesis LOC = "C10"*/,      //Y
input   i_CPLD2_PROGRAM_N           /* synthesis LOC = "B10"*/,      //Y
input   i_CPLD2_INIT_N              /* synthesis LOC = "A13"*/,      //Y
input   i_CPLD2_DONE                /* synthesis LOC = "C13"*/,      //Y
input   i_CPLD2_PULLUP_SN           /* synthesis LOC = "R12"*/,      //Y
output  o_CPLD2_LED2_N	            /* synthesis LOC = "P12"*/,      //Y
output  o_CPLD2_LED3_N	            /* synthesis LOC = "T13"*/,      //Y

input   i_I2C1_CPLD2_REG_SCL	    /* synthesis LOC = "B9 "*/,      //Y
inout   io_I2C1_CPLD2_REG_SDA	    /* synthesis LOC = "A10"*/,      //Y 
inout   io_I2C1_CPLD2_UPDATE_SCL	/* synthesis LOC = "A9"*/,       //Y
inout   io_I2C1_CPLD2_UPDATE_SDA	/* synthesis LOC = "C9 "*/,      //Y

output  o_CPLD_RSV1_R               /* synthesis LOC = "L15"*/,      //default 0 pull up en         O
output  o_CPLD_RSV2_R               /* synthesis LOC = "E11"*/,      //default 0 pull up en         O
output  o_CPLD_RSV3_R               /* synthesis LOC = "L14"*/,      //default 0 pull up en         O
output  o_CPLD_RSV4_R               /* synthesis LOC = "G14"*/,      //default 0 pull up en         O
output  o_CPLD_RSV5_R               /* synthesis LOC = "G13"*/,      //default 0 pull up en         O
output  o_CPLD_RSV6_R               /* synthesis LOC = "J15"*/,      //default 0 pull up en         O

input   i_SCPLD_SGPIO_DATA_IN       /* synthesis LOC = "F13"*/,      //default 1 active 0           I
output  o_SCPLD_SGPIO_DATA_OUT      /* synthesis LOC = "K15"*/,      //default 0 pull up en         O
input   i_SCPLD_SGPIO_CLK           /* synthesis LOC = "A8 "*/,      //default 1 active 0           I
input   i_SCPLD_SGPIO_LD            /* synthesis LOC = "D11"*/,      //default 1 active 0           I
 
//MCIO
inout   io_MCIO01A_PWR_EN_R         /* synthesis LOC = "M9 "*/,      //default 0 pull up en         O
inout   io_MCIO01C_PWR_EN_R         /* synthesis LOC = "F5 "*/,      //default 0 pull up en         O
inout   io_MCIO02A_PWR_EN_R         /* synthesis LOC = "R16"*/,      //default 0 pull up en         O
inout   io_MCIO02C_PWR_EN_R         /* synthesis LOC = "J16"*/,      //default 0 pull up en         O
inout   io_MCIO11A_PWR_EN_R         /* synthesis LOC = "M7 "*/,      //default 0 pull up en         O
inout   io_MCIO11C_PWR_EN_R         /* synthesis LOC = "P4 "*/,      //default 0 pull up en         O
inout   io_MCIO12A_PWR_EN_R         /* synthesis LOC = "F8 "*/,      //default 0 pull up en         O
inout   io_MCIO12C_PWR_EN_R         /* synthesis LOC = "M11"*/,      //default 0 pull up en         O
inout   io_MCIO21A_PWR_EN_R         /* synthesis LOC = "J4 "*/,      //default 0 pull up en         O
inout   io_MCIO21C_PWR_EN_R         /* synthesis LOC = "G3 "*/,      //default 0 pull up en         O
inout   io_MCIO22A_PWR_EN_R         /* synthesis LOC = "N1 "*/,      //default 0 pull up en         O
inout   io_MCIO22C_PWR_EN_R         /* synthesis LOC = "M3 "*/,      //default 0 pull up en         O
inout   io_MCIO31A_PWR_EN_R         /* synthesis LOC = "F16"*/,      //default 0 pull up en         O
inout   io_MCIO31C_PWR_EN_R         /* synthesis LOC = "C16"*/,      //default 0 pull up en         O
inout   io_MCIO32A_PWR_EN_R         /* synthesis LOC = "C7 "*/,      //default 0 pull up en         O
inout   io_MCIO32C_PWR_EN_R         /* synthesis LOC = "F9 "*/,      //default 0 pull up en         O

input   i_MCIO01A_PE_WAKE_R_N   /* synthesis LOC = "G6 "*/,          //default 1 active 0           I
input   i_MCIO01C_PE_WAKE_R_N   /* synthesis LOC = "L10"*/,          //default 1 active 0           I
input   i_MCIO02A_PE_WAKE_R_N   /* synthesis LOC = "J14"*/,          //default 1 active 0           I
input   i_MCIO02C_PE_WAKE_R_N   /* synthesis LOC = "K12"*/,          //default 1 active 0           I
input   i_MCIO11A_PE_WAKE_R_N   /* synthesis LOC = "M6 "*/,          //default 1 active 0           I
input   i_MCIO11C_PE_WAKE_R_N   /* synthesis LOC = "R4 "*/,          //default 1 active 0           I
input   i_MCIO12A_PE_WAKE_R_N   /* synthesis LOC = "N14"*/,          //default 1 active 0           I
input   i_MCIO12C_PE_WAKE_R_N   /* synthesis LOC = "P11"*/,          //default 1 active 0           I
input   i_MCIO21A_PE_WAKE_R_N   /* synthesis LOC = "H5 "*/,          //default 1 active 0           I
input   i_MCIO21C_PE_WAKE_R_N   /* synthesis LOC = "G4 "*/,          //default 1 active 0           I
input   i_MCIO22A_PE_WAKE_R_N   /* synthesis LOC = "P2 "*/,          //default 1 active 0           I
input   i_MCIO22C_PE_WAKE_R_N   /* synthesis LOC = "M2 "*/,          //default 1 active 0           I
input   i_MCIO31A_PE_WAKE_R_N   /* synthesis LOC = "D15"*/,          //default 1 active 0           I
input   i_MCIO31C_PE_WAKE_R_N   /* synthesis LOC = "D16"*/,          //default 1 active 0           I
input   i_MCIO32A_PE_WAKE_R_N   /* synthesis LOC = "B7 "*/,          //default 1 active 0           I
input   i_MCIO32C_PE_WAKE_R_N   /* synthesis LOC = "E9 "*/,          //default 1 active 0           I

input   i_MCIO01A_NVME0_PRSNT_R_N   /* synthesis LOC = "M10"*/,     //default 1 active 0           I
input   i_MCIO01A_NVME1_PRSNT_R_N   /* synthesis LOC = "N9 "*/,     //default 1 active 0           I
input   i_MCIO01C_NVME0_PRSNT_R_N   /* synthesis LOC = "F7 "*/,     //default 1 active 0           I
input   i_MCIO01C_NVME1_PRSNT_R_N   /* synthesis LOC = "F4 "*/,     //default 1 active 0           I
input   i_MCIO02A_NVME0_PRSNT_R_N   /* synthesis LOC = "T14"*/,     //default 1 active 0           I
input   i_MCIO02A_NVME1_PRSNT_R_N   /* synthesis LOC = "P16"*/,     //default 1 active 0           I
input   i_MCIO02C_NVME0_PRSNT_R_N   /* synthesis LOC = "K16"*/,     //default 1 active 0           I
input   i_MCIO02C_NVME1_PRSNT_R_N   /* synthesis LOC = "H14"*/,     //default 1 active 0           I
input   i_MCIO11A_NVME0_PRSNT_R_N   /* synthesis LOC = "N8 "*/,     //default 1 active 0           I
input   i_MCIO11A_NVME1_PRSNT_R_N   /* synthesis LOC = "M8 "*/,     //default 1 active 0           I
input   i_MCIO11C_NVME0_PRSNT_R_N   /* synthesis LOC = "L5 "*/,     //default 1 active 0           I
input   i_MCIO11C_NVME1_PRSNT_R_N   /* synthesis LOC = "P5 "*/,     //default 1 active 0           I
input   i_MCIO12A_NVME0_PRSNT_R_N   /* synthesis LOC = "J13"*/,     //default 1 active 0           I
input   i_MCIO12A_NVME1_PRSNT_R_N   /* synthesis LOC = "G5 "*/,     //default 1 active 0           I
input   i_MCIO12C_NVME0_PRSNT_R_N   /* synthesis LOC = "L13"*/,     //default 1 active 0           I
input   i_MCIO12C_NVME1_PRSNT_R_N   /* synthesis LOC = "P13"*/,     //default 1 active 0           I
input   i_MCIO21A_NVME0_PRSNT_R_N   /* synthesis LOC = "J2 "*/,     //default 1 active 0           I
input   i_MCIO21A_NVME1_PRSNT_R_N   /* synthesis LOC = "J3 "*/,     //default 1 active 0           I
input   i_MCIO21C_NVME0_PRSNT_R_N   /* synthesis LOC = "H3 "*/,     //default 1 active 0           I
input   i_MCIO21C_NVME1_PRSNT_R_N   /* synthesis LOC = "H4 "*/,     //default 1 active 0           I
input   i_MCIO22A_NVME0_PRSNT_R_N   /* synthesis LOC = "R1 "*/,     //default 1 active 0           I
input   i_MCIO22A_NVME1_PRSNT_R_N   /* synthesis LOC = "P1 "*/,     //default 1 active 0           I
input   i_MCIO22C_NVME0_PRSNT_R_N   /* synthesis LOC = "N3 "*/,     //default 1 active 0           I
input   i_MCIO22C_NVME1_PRSNT_R_N   /* synthesis LOC = "N2 "*/,     //default 1 active 0           I
input   i_MCIO31A_NVME0_PRSNT_R_N   /* synthesis LOC = "D14"*/,     //default 1 active 0           I
input   i_MCIO31A_NVME1_PRSNT_R_N   /* synthesis LOC = "C12"*/,     //default 1 active 0           I
input   i_MCIO31C_NVME0_PRSNT_R_N   /* synthesis LOC = "E16"*/,     //default 1 active 0           I
input   i_MCIO31C_NVME1_PRSNT_R_N   /* synthesis LOC = "C15"*/,     //default 1 active 0           I
input   i_MCIO32A_NVME0_PRSNT_R_N   /* synthesis LOC = "C5 "*/,     //default 1 active 0           I
input   i_MCIO32A_NVME1_PRSNT_R_N   /* synthesis LOC = "D6 "*/,     //default 1 active 0           I
input   i_MCIO32C_NVME0_PRSNT_R_N   /* synthesis LOC = "D8 "*/,     //default 1 active 0           I
input   i_MCIO32C_NVME1_PRSNT_R_N   /* synthesis LOC = "E8 "*/,     //default 1 active 0           I

input   i_MCIO01A_CB_ID0_R          /* synthesis LOC = "T7 "*/,     //default 1 active 0           I
input   i_MCIO01A_CB_ID1_R          /* synthesis LOC = "R7 "*/,     //default 1 active 0           I
input   i_MCIO01C_CB_ID0_R          /* synthesis LOC = "T9 "*/,     //default 1 active 0           I
input   i_MCIO01C_CB_ID1_R          /* synthesis LOC = "T8 "*/,     //default 1 active 0           I
input   i_MCIO02A_CB_ID0_R          /* synthesis LOC = "T11"*/,     //default 1 active 0           I
input   i_MCIO02A_CB_ID1_R          /* synthesis LOC = "T12"*/,     //default 1 active 0           I
input   i_MCIO02C_CB_ID0_R          /* synthesis LOC = "T10"*/,     //default 1 active 0           I
input   i_MCIO02C_CB_ID1_R          /* synthesis LOC = "R11"*/,     //default 1 active 0           I
input   i_MCIO11A_CB_ID0_R          /* synthesis LOC = "R6 "*/,     //default 1 active 0           I
input   i_MCIO11A_CB_ID1_R          /* synthesis LOC = "T5 "*/,     //default 1 active 0           I
input   i_MCIO11C_CB_ID0_R          /* synthesis LOC = "R5 "*/,     //default 1 active 0           I
input   i_MCIO11C_CB_ID1_R          /* synthesis LOC = "T4 "*/,     //default 1 active 0           I
input   i_MCIO12A_CB_ID0_R          /* synthesis LOC = "T6 "*/,     //default 1 active 0           I
input   i_MCIO12A_CB_ID1_R          /* synthesis LOC = "R10"*/,     //default 1 active 0           I
input   i_MCIO12C_CB_ID0_R          /* synthesis LOC = "R9 "*/,     //default 1 active 0           I
input   i_MCIO12C_CB_ID1_R          /* synthesis LOC = "R8 "*/,     //default 1 active 0           I
input   i_MCIO21A_CB_ID0_R          /* synthesis LOC = "F1 "*/,     //default 1 active 0           I
input   i_MCIO21A_CB_ID1_R          /* synthesis LOC = "G1 "*/,     //default 1 active 0           I
input   i_MCIO21C_CB_ID0_R          /* synthesis LOC = "D1 "*/,     //default 1 active 0           I
input   i_MCIO21C_CB_ID1_R          /* synthesis LOC = "E1 "*/,     //default 1 active 0           I
input   i_MCIO22A_CB_ID0_R          /* synthesis LOC = "L1 "*/,     //default 1 active 0           I
input   i_MCIO22A_CB_ID1_R          /* synthesis LOC = "K1 "*/,     //default 1 active 0           I
input   i_MCIO22C_CB_ID0_R          /* synthesis LOC = "J1 "*/,     //default 1 active 0           I
input   i_MCIO22C_CB_ID1_R          /* synthesis LOC = "H2 "*/,     //default 1 active 0           I
input   i_MCIO31A_CB_ID0_R          /* synthesis LOC = "B13"*/,     //default 1 active 0           I
input   i_MCIO31A_CB_ID1_R          /* synthesis LOC = "A14"*/,     //default 1 active 0           I
input   i_MCIO31C_CB_ID0_R          /* synthesis LOC = "B14"*/,     //default 1 active 0           I
input   i_MCIO31C_CB_ID1_R          /* synthesis LOC = "A15"*/,     //default 1 active 0           I
input   i_MCIO32A_CB_ID0_R          /* synthesis LOC = "B3 "*/,     //default 1 active 0           I
input   i_MCIO32A_CB_ID1_R          /* synthesis LOC = "B1 "*/,     //default 1 active 0           I
input   i_MCIO32C_CB_ID0_R          /* synthesis LOC = "A3 "*/,     //default 1 active 0           I
input   i_MCIO32C_CB_ID1_R          /* synthesis LOC = "B4 "*/,     //default 1 active 0           I

output  o_MCIO01_11_GPU_THROTTLE_R_N /* synthesis LOC = "P8 "*/,     //default 0 pull up en         O
output  o_MCIO02_12_GPU_THROTTLE_R_N /* synthesis LOC = "T15"*/,     //default 0 pull up en         O
output  o_MCIO21_31_GPU_THROTTLE_R_N /* synthesis LOC = "B16"*/,     //default 0 pull up en         O
output  o_MCIO22_32_GPU_THROTTLE_R_N /* synthesis LOC = "M1 "*/,     //default 0 pull up en         O

//NVME
input   i_NVME1_CB_ID0_R            /* synthesis LOC = "K11 "*/,     //default 1 active 0           I
input   i_NVME1_CB_ID1_R            /* synthesis LOC = "K13 "*/,     //default 1 active 0           I
input   i_NVME2_CB_ID0_R            /* synthesis LOC = "P9  "*/,     //default 1 active 0           I
input   i_NVME2_CB_ID1_R            /* synthesis LOC = "N10 "*/,     //default 1 active 0           I
input   i_NVME3_CB_ID0_R            /* synthesis LOC = "L2  "*/,     //default 1 active 0           I
input   i_NVME3_CB_ID1_R            /* synthesis LOC = "L3  "*/,     //default 1 active 0           I
input   i_NVME4_CB_ID0_R            /* synthesis LOC = "A12 "*/,     //default 1 active 0           I
input   i_NVME4_CB_ID1_R            /* synthesis LOC = "B11 "*/,     //default 1 active 0           I

input   i_NVME3_PRSNT0_R_N          /* synthesis LOC = "K2 "*/,     //default 1 active 0           I
input   i_NVME3_PRSNT1_R_N          /* synthesis LOC = "K3 "*/,     //default 1 active 0           I
input   i_NVME4_PRSNT0_R_N          /* synthesis LOC = "B12 "*/,    //default 1 active 0           I
input   i_NVME4_PRSNT1_R_N          /* synthesis LOC = "A11 "*/,    //default 1 active 0           I

//NPU
output  o_NPU1_4_GPU_THROTTLE_R_N   /* synthesis LOC = "G11"*/,     //default 0 pull up en         O
output  o_NPU5_8_GPU_THROTTLE_R_N   /* synthesis LOC = "L4 "*/,     //default 0 pull up en         O

input   i_NPU1A_CB_ID1_R            /* synthesis LOC = "L16"*/,     //default 1 active 0           I
input   i_NPU1C_CB_ID1_R            /* synthesis LOC = "M16"*/,     //default 1 active 0           I
input   i_NPU2A_CB_ID1_R            /* synthesis LOC = "N15"*/,     //default 1 active 0           I
input   i_NPU2C_CB_ID1_R            /* synthesis LOC = "M15"*/,     //default 1 active 0           I
input   i_NPU3A_CB_ID1_R            /* synthesis LOC = "F10"*/,     //default 1 active 0           I
input   i_NPU3C_CB_ID1_R            /* synthesis LOC = "L12"*/,     //default 1 active 0           I
input   i_NPU4A_CB_ID1_R            /* synthesis LOC = "E10"*/,     //default 1 active 0           I
input   i_NPU4C_CB_ID1_R            /* synthesis LOC = "H12"*/,     //default 1 active 0           I
input   i_NPU5A_CB_ID1_R            /* synthesis LOC = "G12"*/,     //default 1 active 0           I
input   i_NPU5C_CB_ID1_R            /* synthesis LOC = "H13"*/,     //default 1 active 0           I
input   i_NPU6A_CB_ID1_R            /* synthesis LOC = "F12"*/,     //default 1 active 0           I
input   i_NPU6C_CB_ID1_R            /* synthesis LOC = "H1 "*/,     //default 1 active 0           I
input   i_NPU7A_CB_ID1_R            /* synthesis LOC = "G16"*/,     //default 1 active 0           I
input   i_NPU7C_CB_ID1_R            /* synthesis LOC = "H16"*/,     //default 1 active 0           I
input   i_NPU8A_CB_ID1_R            /* synthesis LOC = "G15"*/,     //default 1 active 0           I
input   i_NPU8C_CB_ID1_R            /* synthesis LOC = "F14"*/,     //default 1 active 0           I

//NIC
output  o_NIC1_4_GPU_THROTTLE_R_N   /* synthesis LOC = "K5 "*/,      //default 0 pull up en         O
output  o_NIC5_8_GPU_THROTTLE_R_N   /* synthesis LOC = "E15"*/,      //default 0 pull up en         O

input   i_NIC1A_CB_ID0_R            /* synthesis LOC = "L9  "*/,    //default 1 active 0           I
input   i_NIC1A_CB_ID1_R            /* synthesis LOC = "R13 "*/,    //default 1 active 0           I
input   i_NIC1C_CB_ID0_R            /* synthesis LOC = "L8  "*/,    //default 1 active 0           I
input   i_NIC1C_CB_ID1_R            /* synthesis LOC = "R14 "*/,    //default 1 active 0           I
input   i_NIC2A_CB_ID0_R            /* synthesis LOC = "K6  "*/,    //default 1 active 0           I
input   i_NIC2A_CB_ID1_R            /* synthesis LOC = "J6  "*/,    //default 1 active 0           I
input   i_NIC2C_CB_ID0_R            /* synthesis LOC = "L7  "*/,    //default 1 active 0           I
input   i_NIC2C_CB_ID1_R            /* synthesis LOC = "K14 "*/,    //default 1 active 0           I
input   i_NIC3A_CB_ID0_R            /* synthesis LOC = "M14 "*/,    //default 1 active 0           I
input   i_NIC3A_CB_ID1_R            /* synthesis LOC = "J11 "*/,    //default 1 active 0           I
input   i_NIC3C_CB_ID0_R            /* synthesis LOC = "P15 "*/,    //default 1 active 0           I
input   i_NIC3C_CB_ID1_R            /* synthesis LOC = "J12 "*/,    //default 1 active 0           I
input   i_NIC4A_CB_ID0_R            /* synthesis LOC = "K4  "*/,    //default 1 active 0           I
input   i_NIC4A_CB_ID1_R            /* synthesis LOC = "J5  "*/,    //default 1 active 0           I
input   i_NIC4C_CB_ID0_R            /* synthesis LOC = "N16 "*/,    //default 1 active 0           I
input   i_NIC4C_CB_ID1_R            /* synthesis LOC = "H11 "*/,    //default 1 active 0           I
input   i_NIC5A_CB_ID0_R            /* synthesis LOC = "N7  "*/,    //default 1 active 0           I
input   i_NIC5A_CB_ID1_R            /* synthesis LOC = "T2  "*/,    //default 1 active 0           I
input   i_NIC5C_CB_ID0_R            /* synthesis LOC = "N6  "*/,    //default 1 active 0           I
input   i_NIC5C_CB_ID1_R            /* synthesis LOC = "R3  "*/,    //default 1 active 0           I
input   i_NIC6A_CB_ID0_R            /* synthesis LOC = "H6  "*/,    //default 1 active 0           I
input   i_NIC6A_CB_ID1_R            /* synthesis LOC = "H15 "*/,    //default 1 active 0           I
input   i_NIC6C_CB_ID0_R            /* synthesis LOC = "P6  "*/,    //default 1 active 0           I
input   i_NIC6C_CB_ID1_R            /* synthesis LOC = "T3  "*/,    //default 1 active 0           I
input   i_NIC7A_CB_ID0_R            /* synthesis LOC = "C4  "*/,    //default 1 active 0           I
input   i_NIC7A_CB_ID1_R            /* synthesis LOC = "C11 "*/,    //default 1 active 0           I
input   i_NIC7C_CB_ID0_R            /* synthesis LOC = "D3  "*/,    //default 1 active 0           I
input   i_NIC7C_CB_ID1_R            /* synthesis LOC = "D10 "*/,    //default 1 active 0           I
input   i_NIC8A_CB_ID0_R            /* synthesis LOC = "E14 "*/,    //default 1 active 0           I
input   i_NIC8A_CB_ID1_R            /* synthesis LOC = "F15 "*/,    //default 1 active 0           I
input   i_NIC8C_CB_ID0_R            /* synthesis LOC = "E7  "*/,    //default 1 active 0           I
input   i_NIC8C_CB_ID1_R            /* synthesis LOC = "D9  "*/,    //default 1 active 0           I

//SW
input   i_P0V8_SW1_ALERT_N	        /* synthesis LOC = "N11"*/,      //default 1 active 0           I

input   i_P0V8_SW1_FAULT_N	        /* synthesis LOC = "P10"*/,      //default 1 active 0           I


//OTHER
input   i_BOARD_ID0                 /* synthesis LOC = "F3 "*/,      //default 1 active 0           I
input   i_BOARD_ID1                 /* synthesis LOC = "E2 "*/,      //default 1 active 0           I
input   i_BOARD_ID2                 /* synthesis LOC = "E3 "*/,      //default 1 active 0           I
input   i_BOARD_ID3                 /* synthesis LOC = "F2 "*/,      //default 1 active 0           I
input   i_BOARD_ID4                 /* synthesis LOC = "G2 "*/,      //default 1 active 0           I

input   i_PCA_ID0                   /* synthesis LOC = "A4 "*/,      //default 1 active 0           I
input   i_PCA_ID1                   /* synthesis LOC = "B5 "*/,      //default 1 active 0           I
input   i_PCA_ID2                   /* synthesis LOC = "A5 "*/,      //default 1 active 0           I

input   i_PCB_ID0                   /* synthesis LOC = "D2 "*/,      //default 1 active 0           I
input   i_PCB_ID1                   /* synthesis LOC = "C1 "*/,      //default 1 active 0           I
input   i_PCB_ID2                   /* synthesis LOC = "C2 "*/       //default 1 active 0           I

);