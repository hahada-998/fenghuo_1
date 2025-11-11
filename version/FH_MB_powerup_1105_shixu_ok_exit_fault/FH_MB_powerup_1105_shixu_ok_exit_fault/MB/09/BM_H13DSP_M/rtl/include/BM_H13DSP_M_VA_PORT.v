//=================================================================================================
// Copyright(c) 
// Filename   : BM_H13DSP_M_VA_PORT.v
// Project    : BM_H13DSP_M  
// Author     : 
// Date       : 2024-01-07
//Simulator   : Lattice Diamond 3.12
//FPGA        : LCMXO3LF_6900C_5BG400C
// Email      : cloudnineinfo.com
// Company    : 
// Description: BM_H13DSP_M Top Code
// History    :
// Date      By          Revision  Change Description

           
//=================================================================================================
//------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BM_H13DSP_M  : TWO CPLD,this Code for Master CPLD(U103)
//-------------------------------------------------------------------------------
module  BM_H13DSP_M(

/********************************Signal Start**********************************/
//I/O       Signal                           PIN                        Internal Default OD
//JTAG
// input   i_PAL_TCK                                                                 /* synthesis LOC = "C9 "*/,    //default 1 active 0           I
// input   i_PAL_TMS                                                                 /* synthesis LOC = "D9 "*/,    //default 1 active 0           I
// output  o_PAL_TDO                                                                 /* synthesis LOC = "E8 "*/,    //default 0 pull up en         O
// input   i_PAL_TDI                                                                 /* synthesis LOC = "C7 "*/,    //default 1 active 0           I
input   i_HDR_N                                                                   /* synthesis LOC = "F2 "*/,    //default 1 active 0           I

//CPLD SET
input   i_CPLD_JTAG_EN                                                            /* synthesis LOC = "C13 "*/,    //default 1 active 0           I
input   i_CPLD_DONE                                                               /* synthesis LOC = "A19 "*/,    //default 1 active 0           I
input   i_CPLD2_JTAGEN_R                                                          /* synthesis LOC = "W10 "*/,    //default 1 active 0           I


input   i_CPLD_HOLD_N_R                                                           /* synthesis LOC = "C10 "*/,    //default 1 active 0           I


input   i_CPLD_INITN                                                              /* synthesis LOC = "C17 "*/,    //default 1 active 0           I
input   i_CPLD_PROGRAM_N                                                          /* synthesis LOC = "D13 "*/,    //default 1 active 0           I
input   i_CPLD_SN                                                                 /* synthesis LOC = "Y20 "*/,    //default 1 active 0           I   
  
//PWR/RST BTN
input   i_FM_PWRBTN_OUT_N_R                                                       /* synthesis LOC = "A13 "*/,    //default 1 active 0           I

//CLK
input   i_CLK_25M_CPLD                                                            /* synthesis LOC = "E2  "*/,    //default 1 active 0           I
output o_PAL_DB2000_1_PWRGD_R                                                     /* synthesis LOC = "A5  "*/,    //default 0 pull up en         O
output o_PAL_DB2000_2_PWRGD_R                                                     /* synthesis LOC = "V12 "*/,    //default 0 pull up en         O
output o_CLK_DB2000_1_1_OE_N                                                      /* synthesis LOC = "B6  "*/,    //default 0 pull up en         O
output o_CLK_DB2000_1_2_OE_N                                                      /* synthesis LOC = "B5  "*/,    //default 0 pull up en         O

//M<-->S SGPIO
input i_RVD_GPIO1_R 														      /* synthesis LOC = "A11 "*/,    //default 1 active 0           I
input i_RVD_GPIO2_R 														      /* synthesis LOC = "A15 "*/,    //default 1 active 0           I


output o_CPLD_SGPIO0_CLK_R                                                        /* synthesis LOC = "W11 "*/,    //default 0 pull up en         O
input   i_CPLD_SGPIO0_MISO_R                                                      /* synthesis LOC = "Y14 "*/,    //default 1 active 0           I
output o_CPLD_SGPIO0_LD_N_R                                                       /* synthesis LOC = "W12 "*/,    //default 0 pull up en         O
output o_CPLD_SGPIO0_MOSI_R                                                       /* synthesis LOC = "Y12 "*/,    //default 0 pull up en         O

output o_CPLD_SGPIO1_CLK_R                                                        /* synthesis LOC = "Y13 "*/,    //default 0 pull up en         O
input   i_CPLD_SGPIO1_MISO_R                                                      /* synthesis LOC = "W14 "*/,    //default 1 active 0           I
output o_CPLD_SGPIO1_LD_N_R                                                       /* synthesis LOC = "Y11 "*/,    //default 0 pull up en         O
output o_CPLD_SGPIO1_MOSI_R                                                       /* synthesis LOC = "W13 "*/,    //default 0 pull up en         O

//BMC   BIOS
inout   io_I2C2_UPDATE_SCL                                                        /* synthesis LOC = "C11 "*/,    //default 1 active 0           I
inout   io_I2C2_UPDATE_SDA                                                        /* synthesis LOC = "D11 "*/,    //default 1 active 0           I
inout   io_I2C2_PAL_SDA                                                           /* synthesis LOC = "Y9  "*/,    //default 1 active 0           I
input   i_I2C2_PAL_SCL                                                            /* synthesis LOC = "W9  "*/,    //default 1 active 0           I

input   i_SS_PAL_DATA_IN_R                                                        /* synthesis LOC = "A14 "*/,    //default 1 active 0           I
output  o_SS_PAL_CLK_R                                                            /* synthesis LOC = "B12 "*/,    //default 0 pull up en         O
output  o_SS_PAL_LOAD_N_R                                                         /* synthesis LOC = "A12 "*/,    //default 0 pull up en         O
output  o_SS_PAL_DATA_OUT_R                                                       /* synthesis LOC = "B13 "*/,    //default 0 pull up en         O
output  o_PAL_BMC_PERST_N_R                                                       /* synthesis LOC = "C1  "*/,    //default 0 pull up en         O

//ESPI
input   i_CPLD_ESPI_D0                                                            /* synthesis LOC = "N14 "*/,    //default 1 active 0           I
output o_CPLD_ESPI_D1                                                             /* synthesis LOC = "R16 "*/,    //default 0 pull up en         O
output o_CPLD_ESPI_D2                                                             /* synthesis LOC = "M14 "*/,    //default 0 pull up en         O
output o_CPLD_ESPI_D3                                                             /* synthesis LOC = "V17 "*/,    //default 0 pull up en         O
input   i_CPLD_ESPI_CLK                                                           /* synthesis LOC = "P15 "*/,    //default 1 active 0           I
output o_CPLD_ESPI_ALERT_N                                                        /* synthesis LOC = "R17 "*/,    //default 0 pull up en         O
input   i_CPLD_ESPI_CS_N                                                          /* synthesis LOC = "N19 "*/,    //default 1 active 0           I
input   i_CPLD_ESPI_RESET_N                                                       /* synthesis LOC = "U17 "*/,    //default 0 pull up en         O

//SLIMSAS
input   i_SATA1_BACKPLANE_TYPE                                                    /* synthesis LOC = "D2  "*/,    //default 1 active 0           I
output o_PAL_SATA1_CONTROLLER0_R                                                  /* synthesis LOC = "F6  "*/,    //default 1 active 0           I

//CPU0
inout   o_P0_DIMM_GL_PCAMP_R      /* synthesis LOC = "A8  "*/,    //default 1 active 0      I    
inout   o_P0_DIMM_AF_PCAMP_R      /* synthesis LOC = "T14 "*/,    //default 1 active 0      I    
input   i_P0_SP5R_R_1             /* synthesis LOC = "A7  "*/,    //default 1 active 0      I  P0状态信息
input   i_P0_SP5R_R_2             /* synthesis LOC = "B15 "*/,    //default 1 active 0      I  P0状态信息
input   i_P0_SP5R_R_3             /* synthesis LOC = "R15 "*/,    //default 1 active 0      I  P0状态信息
input   i_P0_SP5R_R_4             /* synthesis LOC = "K6  "*/,    //default 1 active 0      I  P0状态信息
input   i_P0_PRSNT_N              /* synthesis LOC = "B16 "*/,    //default 1 active 0      I  P0存在
input   i_P0_SGPIO_LD_R           /* synthesis LOC = "K16 "*/,    //default 1 active 0      I  未使用 
input   i_P0_SGPIO_DATA_R         /* synthesis LOC = "L17 "*/,    //default 1 active 0      I  未使用 
input   i_CPU0_SGPIO0_CLK         /* synthesis LOC = "H17 "*/,    //default 1 active 0      I  未使用 
input   i_CPU0_SGPIO1_CLK         /* synthesis LOC = "H18 "*/,    //default 1 active 0      I  未使用 
input   i_CPU0_SGPIO2_CLK         /* synthesis LOC = "G20 "*/,    //default 1 active 0      I  未使用 
input   i_CPU0_SGPIO3_CLK         /* synthesis LOC = "G15 "*/,    //default 1 active 0      I  未使用
input   i_P0_CORETYPE_0           /* synthesis LOC = "T16 "*/,    //default 1 active 0      I  P0状态信息
input   i_P0_CORETYPE_1           /* synthesis LOC = "W20 "*/,    //default 1 active 0      I  P0状态信息
input   i_P0_CORETYPE_2           /* synthesis LOC = "U15 "*/,    //default 1 active 0      I  P0状态信息
input   i_P0_XTRIG_N_4            /* synthesis LOC = "J18 "*/,    //default 1 active 0      I  未使用
input   i_P0_XTRIG_N_5            /* synthesis LOC = "K20 "*/,    //default 1 active 0      I  未使用
input   i_P0_XTRIG_N_6            /* synthesis LOC = "J17 "*/,    //default 1 active 0      I  未使用
input   i_P0_XTRIG_N_7            /* synthesis LOC = "J20 "*/,    //default 1 active 0      I  未使用
input   i_P0_UART_TXD_0           /* synthesis LOC = "M16 "*/,    //default 1 active 0      I
output  o_P0_UART_RXD_0           /* synthesis LOC = "F19 "*/,    //default 0 pull up en    O
input   i_P0_UART_TXD_1           /* synthesis LOC = "K15 "*/,    //default 1 active 0      I
output  o_P0_UART_RXD_1           /* synthesis LOC = "M19 "*/,    //default 0 pull up en    O

input   i_P0_THERMTRIP_N                                                          /* synthesis LOC = "G17 "*/,    //default 1 active 0           I
input   i_P0_PCIE_RST_N_0                                                         /* synthesis LOC = "H20 "*/,    //default 1 active 0           I
input   i_P0_PCIE_RST_N_1                                                         /* synthesis LOC = "F20 "*/,    //default 1 active 0           I
output o_P0_PCIE_WAKE_N_R                                                         /* synthesis LOC = "L19 "*/,    //default 0 pull up en         O
input   i_P0_CPLD_SPARE_0                                                         /* synthesis LOC = "J16 "*/,    //default 1 active 0           I
input   i_P0_CPLD_SPARE_1                                                         /* synthesis LOC = "N16 "*/,    //default 1 active 0           I
input   i_P0_CPLD_SPARE_2                                                         /* synthesis LOC = "F17 "*/,    //default 1 active 0           I
input   i_P0_CPLD_SPARE_3                                                         /* synthesis LOC = "F15 "*/,    //default 1 active 0           I
input   i_P0_SMERR_N                                                              /* synthesis LOC = "E17 "*/,    //default 1 active 0           I
input   i_PAL_P0_VDD_CORE_1_OCP_N                                                 /* synthesis LOC = "U19 "*/,    //default 1 active 0           I
input   i_P0_VDD_CORE_0_OCP_N_R                                                   /* synthesis LOC = "E20 "*/,    //default 1 active 0           I
input   i_P0_CPLD_SCL                                                             /* synthesis LOC = "Y2  "*/,    //default 1 active 0           I
inout   io_P0_CPLD_SDA                                                            /* synthesis LOC = "Y3  "*/,    //default 1 active 0           I
input   i_P0_SPD_HOST_CTRL_N                                                      /* synthesis LOC = "M15 "*/,    //default 1 active 0           I
input   i_P0_I3C_APML_ALERT_N                                                     /* synthesis LOC = "N15 "*/,    //default 1 active 0           I
input   i_P0_SLP_S3_N                                                             /* synthesis LOC = "F16 "*/,    //default 1 active 0           I
input   i_P0_SLP_S5_N                                                             /* synthesis LOC = "G16 "*/,    //default 1 active 0           I
output o_P0_RSMRST_N                                                              /* synthesis LOC = "D17 "*/,    //default 0 pull up en         O
output o_HDT_CPU_PWROK                                                            /* synthesis LOC = "N20 "*/,    //default 0 pull up en         O
output o_P0_SPI_CLK_STRAP                                                         /* synthesis LOC = "B20 "*/,    //default 0 pull up en         O
output o_P0_SYS_RESET_R_N                                                         /* synthesis LOC = "F18 "*/,    //default 0 pull up en         O
output o_P0_PWR_GOOD                                                              /* synthesis LOC = "L16 "*/,    //default 0 pull up en         O
input   i_P0_PWRGD_VDD_3V3_STBY                                                   /* synthesis LOC = "T1  "*/,    //default 1 active 0           I

input   i_P0_PWRGD_OUT                                                            /* synthesis LOC = "J15 "*/,    //default 1 active 0           I
input   i_P0_RESET_N                                                              /* synthesis LOC = "K17 "*/,    //default 1 active 0           I
input   i_P0_PWROK                                                                /* synthesis LOC = "M20 "*/,    //default 1 active 0           I
output o_P0_WAFL_STRAP_SEL_R                                                      /* synthesis LOC = "P19 "*/,    //default 0 pull up en         O
output o_P0_PROCHOT_N                                                             /* synthesis LOC = "L20 "*/,    //default 0 pull up en         O
output o_P0_PWR_BTN_R_N                                                           /* synthesis LOC = "C18 "*/,    //default 0 pull up en         O
output o_PAL_P0_PRSENT_HDT                                                        /* synthesis LOC = "E19 */,    //default 0 pull up en         O
output o_P0_KBRST_N                                                               /* synthesis LOC = "U20 "*/,    //default 0 pull up en         O
output o_P0_NMI_SYNC_FLOOD_N                                                      /* synthesis LOC = "H19 "*/,    //default 0 pull up en         O
output o_P0_FORCE_SELFREFRESH_R                                                   /* synthesis LOC = "T20 "*/,    //default 0 pull up en         O
input   i_P0_BIOS_POST_STAGE_R_N                                                  /* synthesis LOC = "D18 "*/,    //default 1 active 0           I
output o_PAL_TPCM_BIOS_DONE_R_N                                                   /* synthesis LOC = "C19 "*/,    //default 0 pull up en         O
output o_HDT_CPU_RESET_N                                                          /* synthesis LOC = "P20 "*/,    //default 0 pull up en         O
output o_PAL_BMC_POST_DONE_FLAG_R                                                 /* synthesis LOC = "G19 "*/,    //default 0 pull up en         O
inout   o_PAL_BIOS_DEBUG_R_N                                                      /* synthesis LOC = "D20 "*/,    //default 1 active 0           I
output o_PAL_TPCM_IRQ_R_L                                                         /* synthesis LOC = "Y18 "*/,    //default 0 pull up en         O
output o_PAL_TPCM_BMC_DONE_R_N                                                    /* synthesis LOC = "D19 "*/,    //default 0 pull up en         O
output o_PAL_CLEAR_CMOS_R_N                                                       /* synthesis LOC = "J19 "*/,    //default 0 pull up en         O

//CPU1
inout   o_P1_DIMM_GL_PCAMP_R                                                      /* synthesis LOC = "V16 "*/,    //default 1 active 0           I
inout   o_P1_DIMM_AF_PCAMP_R                                                      /* synthesis LOC = "P13 "*/,    //default 1 active 0           I
output o_PAL_P1_PRSENT_HDT                                                        /* synthesis LOC = "K14 "*/,    //default 0 pull up en         O
input   i_P1_XTRIG_R_N_4                                                          /* synthesis LOC = "J14 "*/,    //default 1 active 0           I
input   i_P1_XTRIG_R_N_5                                                          /* synthesis LOC = "H14 "*/,    //default 1 active 0           I
input   i_P1_XTRIG_R_N_7                                                          /* synthesis LOC = "H15 "*/,    //default 1 active 0           I
input   i_P1_XTRIG_R_N_6                                                          /* synthesis LOC = "H16 "*/,    //default 1 active 0           I
input   i_P1_SP5R_R_1                                                             /* synthesis LOC = "P8  "*/,    //default 1 active 0           I
input   i_P1_SP5R_R_2                                                             /* synthesis LOC = "V9  "*/,    //default 1 active 0           I
input   i_P1_SP5R_R_3                                                             /* synthesis LOC = "U9  "*/,    //default 1 active 0           I
input   i_P1_SP5R_R_4                                                             /* synthesis LOC = "P12 "*/,    //default 1 active 0           I
inout   o_P1_PWR_GOOD                                                             /* synthesis LOC = "L15 "*/,    //default 1 active 0           I


input   i_P1_PWRGD_VDD_3V3_STBY                                                   /* synthesis LOC = "T11 "*/,    //default 1 active 0           I


input   i_P1_CORETYPE_0                                                           /* synthesis LOC = "V10 "*/,    //default 1 active 0           I
input   i_P1_CORETYPE_1                                                           /* synthesis LOC = "T7  "*/,    //default 1 active 0           I
input   i_P1_CORETYPE_2                                                           /* synthesis LOC = "T10 "*/,    //default 1 active 0           I
input   i_P1_PCIE_RST_N_0                                                         /* synthesis LOC = "P16 "*/,    //default 1 active 0           I
input   i_P1_PCIE_RST_N_1                                                         /* synthesis LOC = "T17 "*/,    //default 1 active 0           I
inout   o_P1_PROCHOT_N                                                            /* synthesis LOC = "T18 "*/,    //default 1 active 0           I


output o_P1_PWR_BTN_N                                                             /* synthesis LOC = "Y19 "*/,    //default 0 pull up en         O


input   i_P1_RESET_N                                                              /* synthesis LOC = "C20 "*/,    //default 1 active 0           I
input   i_P1_SMERR_N                                                              /* synthesis LOC = "M17 "*/,    //default 1 active 0           I
output o_P1_SYS_RESET_N                                                           /* synthesis LOC = "V19 "*/,    //default 0 pull up en         O
output o_P1_RSMRST_N                                                              /* synthesis LOC = "N17 "*/,    //default 0 pull up en         O

output o_P1_FORCE_SELFREFRESH_R                                                   /* synthesis LOC = "U18 "*/,    //default 0 pull up en         O
input   i_P1_PWROK                                                                /* synthesis LOC = "K18 "*/,    //default 1 active 0           I
output o_P1_KBRST_N                                                               /* synthesis LOC = "V20 "*/,    //default 0 pull up en         O
input   i_P1_SLP_S5_N                                                             /* synthesis LOC = "W18 "*/,    //default 1 active 0           I
input   i_P1_SLP_S3_N                                                             /* synthesis LOC = "V15 "*/,    //default 1 active 0           I
input   i_P1_PWRGD_OUT                                                            /* synthesis LOC = "P17 "*/,    //default 1 active 0           I
input   i_P1_THERMTRIP_N                                                          /* synthesis LOC = "M18 "*/,    //default 1 active 0           I
output o_P1_PCIE_WAKE_N_R                                                         /* synthesis LOC = "R19 "*/,    //default 0 pull up en         O
input   i_P1_VDD_CORE_0_OCP_N_R                                                   /* synthesis LOC = "N18 "*/,    //default 1 active 0           I
input   i_PAL_P1_VDD_CORE_1_OCP_N                                                 /* synthesis LOC = "T19 "*/,    //default 1 active 0           I
inout   o_P1_NMI_SYNC_FLOOD_N                                                     /* synthesis LOC = "P18 "*/,    //default 1 active 0           I
input   i_P1_I3C_APML_ALERT_N                                                     /* synthesis LOC = "K19 "*/,    //default 1 active 0           I
input   i_P1_PRSNT_N                                                              /* synthesis LOC = "R10 "*/,    //default 1 active 0           I

//PWR_SEQ
output o_P0_VDD_3V3_STBY_EN_R                                                     /* synthesis LOC = "U1  "*/,    //default 0 pull up en         O
output o_P1_VDD_3V3_STBY_EN_R                                                     /* synthesis LOC = "P11 "*/,    //default 0 pull up en         O

output o_PAL_P0_VDD_18_STBY_EN_R                                                  /* synthesis LOC = "R1  "*/,    //default 0 pull up en         O
output o_PAL_P0_VDDIO_EN_R                                                        /* synthesis LOC = "F12 "*/,    //default 0 pull up en         O
output o_PAL_P0_VDD_11_SUS_EN                                                     /* synthesis LOC = "A17 "*/,    //default 0 pull up en         O
input   i_PAL_P0_SLP_S3_N                                                          /* synthesis LOC = "Y1  "*/,   //default 1 active 0           I
input   i_PGD_P0_VDD_CORE_0                                                       /* synthesis LOC = "V2  "*/,    //default 1 active 0           I
//G9 改悬空input   i_PGD_P0_VDD_11_SUS                                                       /* synthesis LOC = "G9  "*/,    //default 1 active 0           I

input   i_P0_VR_I2C_ALERT_N                                                       /* synthesis LOC = "F11 "*/,    //default 1 active 0           I
input   i_P1_VR_I2C_ALERT_N                                                       /* synthesis LOC = "U14 "*/,    //default 1 active 0           I

output o_PAL_P0_VDD_CORE_1_11_SUS_RST_L_N                                         /* synthesis LOC = "A20 "*/,    //default 0 pull up en         O
output o_PAL_P0_VDDIO_RST_N                                                       /* synthesis LOC = "C14 "*/,    //default 0 pull up en         O
input   i_P0_VDDIO_OCP_N                                                          /* synthesis LOC = "B18 "*/,    //default 1 active 0           I

input   i_PGD_P0_VDD_CORE_1                                                       /* synthesis LOC = "A18 "*/,    //default 1 active 0           I
output o_PAL_P0_VDD_SOC_EN                                                        /* synthesis LOC = "W1  "*/,    //default 0 pull up en         O
output o_PAL_P0_VDD_CORE_1_EN_R                                                   /* synthesis LOC = "B19 "*/,    //default 0 pull up en         O
input   i_PGD_P0_VDDIO                                                            /* synthesis LOC = "G14 "*/,    //default 1 active 0           I
output o_PAL_P0_VDD_CORE_0_EN_R                                                   /* synthesis LOC = "U2  "*/,    //default 0 pull up en         O
output o_PAL_P0_VDD_CORE_0_SOC_RST_L_N                                            /* synthesis LOC = "T2  "*/,    //default 0 pull up en         O
input   i_PGD_P0_VDD_SOC_0                                                        /* synthesis LOC = "R2  "*/,    //default 1 active 0           I
input   i_PWRGD_P3V3_STBY                                                         /* synthesis LOC = "B3  "*/,    //default 1 active 0           I
output o_P0_I2C_9617_EN                                                           /* synthesis LOC = "B2  "*/,    //default 0 pull up en         O
 
output o_PAL_P12V_CPU1_ON                                                         /* synthesis LOC = "N6  "*/,    //default 0 pull up en         O
output o_PAL_P12V_CPU0_ON                                                         /* synthesis LOC = "T6  "*/,    //default 0 pull up en         O
input   i_PAL_P12V_CPU1_GOK                                                       /* synthesis LOC = "U6  "*/,    //default 1 active 0           I
input   i_PAL_P12V_CPU0_GOK                                                       /* synthesis LOC = "P6  "*/,    //default 1 active 0           I
input   i_PAL_P12V_CPU0_OC                                                        /* synthesis LOC = "R6  "*/,    //default 1 active 0           I
input   i_PAL_P12V_CPU1_OC                                                        /* synthesis LOC = "V6  "*/,    //default 1 active 0           I

input   i_PGD_P0_VDD_18_STBY                                                      /* synthesis LOC = "P1  "*/,    //default 1 active 0           I
input   i_PGD_P1_VDD_18_STBY                                                      /* synthesis LOC = "U10 "*/,    //default 1 active 0           I

input   i_PGD_P1_VDD_CORE_0                                                       /* synthesis LOC = "Y16 "*/,    //default 1 active 0           I
output o_PAL_P1_VDD_CORE_0_EN_R                                                   /* synthesis LOC = "P14 "*/,    //default 0 pull up en         O
output o_PAL_P1_VDD_SOC_EN                                                        /* synthesis LOC = "R8  "*/,    //default 0 pull up en         O

output o_PAL_P1_VDD_CORE_1_11_SUS_RST_L_N                                         /* synthesis LOC = "R11 "*/,    //default 0 pull up en         O
input   i_PGD_P1_VDD_11_SUS                                                       /* synthesis LOC = "V14 "*/,    //default 1 active 0           I

input   i_P1V8_STBY_PG                                                            /* synthesis LOC = "A3  "*/,    //default 1 active 0           I
input   i_PGD_P1_VDDIO                                                            /* synthesis LOC = "U12 "*/,    //default 1 active 0           I
output o_P1_VDDIO_RST_L_N                                                         /* synthesis LOC = "T13 "*/,    //default 0 pull up en         O
output o_PAL_P1_VDD_18_STBY_EN_R                                                  /* synthesis LOC = "W8  "*/,    //default 0 pull up en         O
output o_PAL_P1_VDDIO_EN_R                                                        /* synthesis LOC = "V13 "*/,    //default 0 pull up en         O
output o_PAL_P1_VDD_CORE_0_SOC_RST_L_N                                            /* synthesis LOC = "R14 "*/,    //default 0 pull up en         O
output o_PAL_P1_VDD_11_SUS_EN                                                     /* synthesis LOC = "R13 "*/,    //default 0 pull up en         O
input   i_PGD_P1_VDD_CORE_1                                                       /* synthesis LOC = "T12 "*/,    //default 1 active 0           I
output o_PAL_P1_VDD_CORE_1_EN_R                                                   /* synthesis LOC = "U11 "*/,    //default 0 pull up en         O
input   i_PGD_P1_VDD_SOC_0                                                        /* synthesis LOC = "R12 "*/,    //default 1 active 0           I
output o_PAL_BMC_AUX_PGD                                                          /* synthesis LOC = "W17 "*/,    //default 0 pull up en         O

//P2 o_PAL_SPI1_BMC_WP_N 攄1�7 PAL_TPM_EN
output o_PAL_TPM_EN                                                               /* synthesis LOC = "P2  "*/,    //default 0 pull up en         O

//R20 PAL_TPM_EN 攄1�7 SPI1_BMC_WP_N_1V8
output o_SPI1_BMC_WP_N_1V8                                                        /* synthesis LOC = "R20 "*/,    //default 0 pull up en         O
input   i_P1_VDDIO_OCP_N                                                          /* synthesis LOC = "W16 "*/,    //default 1 active 0           I
output o_P1V0_STBY_M2_EN                                                          /* synthesis LOC = "D1  "*/,    //default 0 pull up en         O
input   i_PG_P1V0_STBY_M2_R                                                       /* synthesis LOC = "F7  "*/,    //default 1 active 0           I

//OTHER
input  i_SCM_ROT_CPU_RST_N_R                                                      /* synthesis LOC = "A16 "*/,    //default 1 active 0           I
//J4改悬穄1�7 output o_P0_VPP_9545_6_RST_N_R                                                    /* synthesis LOC = "J4  "*/,    //default 0 pull up en         O
output o_P0_VPP_9545_5_RST_N_R                                                    /* synthesis LOC = "C15 "*/,    //default 0 pull up en         O
output o_P0_VPP_9545_4_RST_N_R                                                    /* synthesis LOC = "L6  "*/,    //default 0 pull up en         O
output o_P0_VPP_9545_3_RST_N_R                                                    /* synthesis LOC = "M6  "*/,    //default 0 pull up en         O
output o_P0_VPP_9545_2_RST_N_R                                                    /* synthesis LOC = "W19 "*/,    //default 0 pull up en         O
output o_P0_VPP_9545_1_RST_N_R                                                    /* synthesis LOC = "E1  "*/,    //default 0 pull up en         O
output o_PAL_P0_I2C5_9548_RST_R                                                   /* synthesis LOC = "Y17 "*/,    //default 0 pull up en         O     
output o_BIOS_POST_CMPLT_BMC_N_R                                                  /* synthesis LOC = "B14 "*/,    //default 0 pull up en         O
output o_PAL_I3C_MUX_EN_R_N                                                       /* synthesis LOC = "G12 "*/,    //default 0 pull up en         O

//直接赋��和使能其他配置
output o_I3C_MUX_SEL_R_0                                                          /* synthesis LOC = "M1  "*/,    //default 0 pull up en         O
output o_I3C_MUX_OE_N_R_0                                                         /* synthesis LOC = "L1  "*/,    //default 0 pull up en         O
output o_I3C_MUX_SEL_R_1                                                          /* synthesis LOC = "L2  "*/,    //default 0 pull up en         O
output o_I3C_MUX_OE_N_R_1                                                         /* synthesis LOC = "M2  "*/,    //default 0 pull up en         O
output o_I3C_MUX_SEL_R_2                                                          /* synthesis LOC = "P10 "*/,    //default 0 pull up en         O
output o_I3C_MUX_OE_N_R_2                                                         /* synthesis LOC = "P9  "*/,    //default 0 pull up en         O
output o_I3C_MUX_SEL_R_3                                                          /* synthesis LOC = "R9  "*/,    //default 0 pull up en         O
output o_I3C_MUX_OE_N_R_3                                                         /* synthesis LOC = "R7  "*/,    //default 0 pull up en         O

output o_BMC_I2C4_9548_4_RST_N_R                                                  /* synthesis LOC = "T8  "*/,    //default 0 pull up en         O
output o_BMC_I2C4_9548_3_RST_N_R                                                  /* synthesis LOC = "D14 "*/,   //default 0 pull up en         O
output o_BMC_I2C4_9548_2_RST_N_R                                                  /* synthesis LOC = "F8  "*/,    //default 0 pull up en         O
output o_BMC_I2C4_9548_1_RST_N_R                                                  /* synthesis LOC = "T9  "*/,    //default 0 pull up en         O

output o_BMC_JTAG_TRST_R_N                                                        /* synthesis LOC = "C16 "*/,    //default 0 pull up en         O
input   i_HDT_CONN_TESTEN                                                         /* synthesis LOC = "L14 "*/,    //default 1 active 0           I
input   i_UART_SYS_RX_R                                                           /* synthesis LOC = "F1  "*/,    //default 1 active 0           I
output o_UART_SYS_TX_R                                                            /* synthesis LOC = "G1  "*/,    //default 0 pull up en         O

output o_PAL_BAT_SENSE_R                                                          /* synthesis LOC = "V8  "*/,    //default 0 pull up en         O
input   i_IRQ_SPI_TPM_N                                                           /* synthesis LOC = "A9  "*/,    //default 1 active 0           I
input   i_PAL_JTAG_DBREQ_N                                                        /* synthesis LOC = "A4  "*/,    //default 1 active 0           I
input   i_PG_PVCC_HPMOS_R                                                         /* synthesis LOC = "G8  "*/,    //default 1 active 0           I
output o_PAL_PVCC_HPMOS_EN_R                                                      /* synthesis LOC = "F9  "*/,    //default 0 pull up en         O
input   i_HPM_STBY_EN_R                                                            /* synthesis LOC = "B10 "*/,   //default 1 active 0           I

input   i_P0_USB_OC2_N_R                                                          /* synthesis LOC = "P7  "*/,    //default 1 active 0           I
input   i_FM_RSTBTN_OUT_N_R                                                       /* synthesis LOC = "K1  "*/,    //default 1 active 0           I
input   i_PAL_BMC_JTAG_DBREQ                                                      /* synthesis LOC = "B4  "*/,    //default 1 active 0           I
input   i_FM_CPU_SMERR_LVC3_N_R                                                    /* synthesis LOC = "B7  "*/,   //default 1 active 0           I
input   i_FM_HPM_STBY_RDY_LVC3_R                                                  /* synthesis LOC = "B11 "*/,    //default 1 active 0           I
input   i_FM_BMC_RDY_R                                                            /* synthesis LOC = "N1  "*/,    //default 1 active 0           I
input   i_SCM_SYS_PWROK_R                                                         /* synthesis LOC = "B9  "*/,    //default 1 active 0           I
output o_TPM_IO2_RST                                                              /* synthesis LOC = "A10 "*/,    //default 0 pull up en         O
output o_PAL_RST_RTC                                                              /* synthesis LOC = "V1 "*/,    //default 0 pull up en         O
input   i_RTC_INTA_N                                                              /* synthesis LOC = "W2  "*/,    //default 1 active 0           I
output o_PAL_CMOS_CLEAR_R                                                         /* synthesis LOC = "A2  "*/,    //default 0 pull up en         O
output o_BMC_JTAG_MUX_S                                                           /* synthesis LOC = "A1  "*/,    //default 0 pull up en         O
output o_EEPROM_WP_N_R                                                            /* synthesis LOC = "G2  "*/,    //default 0 pull up en         O

input   i_CPLD1_CPLD2_RSV1                                                        /* synthesis LOC = "W15 "*/,    //default 1 active 0           I
output o_CPLD1_CPLD2_RSV2                                                         /* synthesis LOC = "Y15 "*/,    //default 0 pull up en         O



//new
input   i_PGD_P0_VDD_11_SUS                                                       /* synthesis LOC = "B8  "*/,    //default 1 active 0           I
output o_P0_VPP_9545_6_RST_N_R                                                    /* synthesis LOC = "M3  "*/     //default 0 pull up en         O
);



