//=================================================================================================
// Copyright(c) 
// Filename   : BM_H13DSP_S_VA_PORT.v
// Project    : BM_H13DSP_S  
// Author     : 
// Date       : 2024-01-07
//Simulator   : Lattice Diamond 3.12
//FPGA        : LCMXO3LF_6900C_5BG400C
// Email      : cloudnineinfo.com
// Company    : 
// Description: BM_H13DSP_S Top Code
// History    :
// Date      By          Revision  Change Description

           
//=================================================================================================
//------------------------------------------------------------------------------
//-- Principle of Naming:
//-- In BM_H13DSP_S  : TWO CPLD,this Code for Master CPLD(U247)
//-------------------------------------------------------------------------------


module  BM_H13DSP_S(

/********************************Signal Start**********************************/
//I/O       Signal                           PIN                        Internal Default OD
output o_CPLD2_JTAGEN                                             /* synthesis LOC = "C13"*/,    //default 0 pull up en         O
// input   i_PAL2_TCK                                                /* synthesis LOC = "C9 "*/,    //default 1 active 0           I
// input   i_PAL2_TMS                                                /* synthesis LOC = "D9 "*/,    //default 1 active 0           I
// input   i_PAL2_TDI                                                /* synthesis LOC = "C7 "*/,    //default 1 active 0           I
// output o_PAL2_TDO                                                 /* synthesis LOC = "E8 "*/,    //default 0 pull up en         O

input   i_HDR_PAL2_N                                              /* synthesis LOC = "B9 "*/,    //default 1 active 0           I
input   i_CPLD2_DONE                                              /* synthesis LOC = "A19"*/,    //default 1 active 0           I
input   i_CPLD2_INIT_N                                            /* synthesis LOC = "C17"*/,    //default 1 active 0           I
input   i_CPLD2_PROGRAM_N                                         /* synthesis LOC = "D13"*/,    //default 1 active 0           I
input   i_CPLD2_HOLD_N_R                                          /* synthesis LOC = "K18"*/,    //default 1 active 0           I
input   i_CPLD2_SN                                                /* synthesis LOC = "Y20"*/,    //default 1 active 0           I

//SW
input   i_SW_1                                                    /* synthesis LOC = "A2 "*/,    //default 1 active 0           I
input   i_SW_3                                                    /* synthesis LOC = "A3 "*/,    //default 1 active 0           I
input   i_SW_5                                                    /* synthesis LOC = "A4 "*/,    //default 1 active 0           I
input   i_SW_7                                                    /* synthesis LOC = "A5 "*/,    //default 1 active 0           I
input   i_SW_2                                                    /* synthesis LOC = "B3 "*/,    //default 1 active 0           I
input   i_SW_4                                                    /* synthesis LOC = "B4 "*/,    //default 1 active 0           I
input   i_SW_6                                                    /* synthesis LOC = "B5 "*/,    //default 1 active 0           I
input   i_SW_8                                                    /* synthesis LOC = "B6 "*/,    //default 1 active 0           I
//I2C
inout   io_I2C2_2_UPDATE_SDA                                      /* synthesis LOC = "D11"*/,    //default 1 active 0           I
inout   io_I2C2_2_UPDATE_SCL                                      /* synthesis LOC = "C11"*/,    //default 1 active 0           I

inout   io_I2C2_PAL2_SDA                                      /* synthesis LOC = "B18"*/,    //default 1 active 0           I
input   i_I2C2_PAL2_SCL                                       /* synthesis LOC = "A18"*/,    //default 1 active 0           I

//JTAG 
input   i_JTAG_BMC_TRST_R                                         /* synthesis LOC = "G10"*/,    //default 1 active 0           I
//TPM
input   i_PAL_TPM_MODULE_PRSNT_N                                  /* synthesis LOC = "D15"*/,    //default 1 active 0           I
input   i_PAL_SLIMSAS1_PRSNT_N                                    /* synthesis LOC = "E14"*/,    //default 1 active 0           I
input   i_PAL_TMP1_ALERT_N                                        /* synthesis LOC = "G11"*/,    //default 1 active 0           I
input   i_PAL_TMP2_ALERT_N                                        /* synthesis LOC = "F5 "*/,    //default 1 active 0           I
input   i_PAL_TMP3_ALERT_N                                        /* synthesis LOC = "F10"*/,    //default 1 active 0           I
input   i_PAL_TMP4_ALERT_N                                        /* synthesis LOC = "F7 "*/,    //default 1 active 0           I

//OCP

output o_SMB_PEHP_CPU0_OCP_ALERT                                  /* synthesis LOC = "V16"*/,    //default 0 pull up en         O
output o_SMB_PEHP_CPU1_OCP_ALERT                                  /* synthesis LOC = "M1 "*/,    //default 0 pull up en         O

//M<-->S SGPIO
input   i_CPLD_SGPIO0_CLK                                         /* synthesis LOC = "L20 "*/,    //default 0 pull up en         O
output  o_CPLD_SGPIO0_MISO                                        /* synthesis LOC = "R20 "*/,    //default 1 active 0           I
input   i_CPLD_SGPIO0_LD_N                                        /* synthesis LOC = "M20 "*/,    //default 0 pull up en         O
input   i_CPLD_SGPIO0_MOSI                                        /* synthesis LOC = "M19 "*/,    //default 0 pull up en         O
input   i_CPLD_SGPIO1_CLK                                         /* synthesis LOC = "N20 "*/,    //default 0 pull up en         O
output  o_CPLD_SGPIO1_MISO                                        /* synthesis LOC = "T19 "*/,    //default 1 active 0           I
input   i_CPLD_SGPIO1_LD_N                                        /* synthesis LOC = "L19 "*/,    //default 0 pull up en         O
input   i_CPLD_SGPIO1_MOSI                                        /* synthesis LOC = "P20 "*/,    //default 0 pull up en         O

//LED
output o_LED1_N                                                   /* synthesis LOC = "K20 "*/,    //default 0 pull up en         O
output o_LED2_N                                                   /* synthesis LOC = "C20 "*/,    //default 0 pull up en         O
output o_LED3_N                                                   /* synthesis LOC = "D20 "*/,    //default 0 pull up en         O
output o_LED4_N                                                   /* synthesis LOC = "E20 "*/,    //default 0 pull up en         O
output o_LED5_N                                                   /* synthesis LOC = "J20 "*/,    //default 0 pull up en         O
output o_LED6_N                                                   /* synthesis LOC = "H20 "*/,    //default 0 pull up en         O
output o_LED7_N                                                   /* synthesis LOC = "G20 "*/,    //default 0 pull up en         O
output o_LED8_N                                                   /* synthesis LOC = "F20 "*/,    //default 0 pull up en         O

//MCIO
inout   io_P0_MCIOP0A_PWR_EN_R                                    /* synthesis LOC = "W1 "*/,    //default 0 pull up en         O
inout   io_P0_MCIOP0C_PWR_EN_R                                    /* synthesis LOC = "Y5 "*/,    //default 0 pull up en         O
inout   io_P0_MCIOP1A_PWR_EN_R                                    /* synthesis LOC = "Y9 "*/,    //default 0 pull up en         O
inout   io_P0_MCIOP1C_PWR_EN_R                                    /* synthesis LOC = "W14"*/,    //default 0 pull up en         O
inout   io_P0_MCIOP2A_PWR_EN_R                                    /* synthesis LOC = "L14"*/,    //default 0 pull up en         O
inout   io_P0_MCIOP2C_PWR_EN_R                                    /* synthesis LOC = "B8 "*/,    //default 0 pull up en         O
inout   io_P0_MCIOP3A_PWR_EN_R                                    /* synthesis LOC = "P17"*/,    //default 0 pull up en         O
inout   io_P0_MCIOP3C_PWR_EN_R                                    /* synthesis LOC = "T16"*/,    //default 0 pull up en         O
inout   io_P0_MCIOG3A_PWR_EN_R                                    /* synthesis LOC = "F19"*/,    //default 0 pull up en         O
inout   io_P0_MCIOG3C_PWR_EN_R                                    /* synthesis LOC = "B19"*/,    //default 0 pull up en         O


inout   io_P1_MCIOP0A_PWR_EN_R                                    /* synthesis LOC = "T5 "*/,    //default 0 pull up en         O
inout   io_P1_MCIOP0C_PWR_EN_R                                    /* synthesis LOC = "D5 "*/,    //default 0 pull up en         O
inout   io_P1_MCIOP1A_PWR_EN_R                                    /* synthesis LOC = "J4 "*/,    //default 0 pull up en         O
inout   io_P1_MCIOP1C_PWR_EN_R                                    /* synthesis LOC = "E2 "*/,    //default 0 pull up en         O
inout   io_P1_MCIOP2A_PWR_EN_R                                    /* synthesis LOC = "H3 "*/,    //default 0 pull up en         O
inout   io_P1_MCIOP2C_PWR_EN_R                                    /* synthesis LOC = "K5 "*/,    //default 0 pull up en         O
inout   io_P1_MCIOP3A_PWR_EN_R                                    /* synthesis LOC = "V8 "*/,    //default 0 pull up en         O
inout   io_P1_MCIOP3C_PWR_EN_R                                    /* synthesis LOC = "U10"*/,    //default 0 pull up en         O
inout   io_P1_MCIOG1A_PWR_EN_R                                    /* synthesis LOC = "T13"*/,    //default 0 pull up en         O
inout   io_P1_MCIOG1C_PWR_EN_R                                    /* synthesis LOC = "R9 "*/,    //default 0 pull up en         O

output o_P0_MCIOP0A_PERST_N_R                                     /* synthesis LOC = "T7 "*/,    //default 0 pull up en         O
output o_P0_MCIOP0C_PERST_N_R                                     /* synthesis LOC = "W8 "*/,    //default 0 pull up en         O
output o_P0_MCIOP1A_PERST_N_R                                     /* synthesis LOC = "W12"*/,    //default 0 pull up en         O
output o_P0_MCIOP1C_PERST_N_R                                     /* synthesis LOC = "Y16"*/,    //default 0 pull up en         O
output o_P0_MCIOP2A_PERST_N_R                                     /* synthesis LOC = "K17"*/,    //default 0 pull up en         O
output o_P0_MCIOP2C_PERST_N_R                                     /* synthesis LOC = "F6 "*/,    //default 0 pull up en         O
output o_P0_MCIOP3A_PERST_N_R                                     /* synthesis LOC = "R17"*/,    //default 0 pull up en         O
output o_P0_MCIOP3C_PERST_N_R                                     /* synthesis LOC = "U14"*/,    //default 0 pull up en         O
output o_P0_MCIOG3A_PERST_N_R                                     /* synthesis LOC = "D12"*/,    //default 0 pull up en         O
output o_P0_MCIOG3C_PERST_N_R                                     /* synthesis LOC = "F11"*/,    //default 0 pull up en         O
output o_P0_MCIOP4A_PERST_N_R                                     /* synthesis LOC = "H7 "*/,    //default 0 pull up en         O

output o_P1_MCIOP0A_PERST_N_R                                     /* synthesis LOC = "R7 "*/,    //default 0 pull up en         O
output o_P1_MCIOP0C_PERST_N_R                                     /* synthesis LOC = "P13"*/,    //default 0 pull up en         O
output o_P1_MCIOP1A_PERST_N_R                                     /* synthesis LOC = "B2 "*/,    //default 0 pull up en         O
output o_P1_MCIOP1C_PERST_N_R                                     /* synthesis LOC = "H4 "*/,    //default 0 pull up en         O
output o_P1_MCIOP2A_PERST_N_R                                     /* synthesis LOC = "J2 "*/,    //default 0 pull up en         O
output o_P1_MCIOP2C_PERST_N_R                                     /* synthesis LOC = "L4 "*/,    //default 0 pull up en         O
output o_P1_MCIOP3A_PERST_N_R                                     /* synthesis LOC = "V9 "*/,    //default 0 pull up en         O
output o_P1_MCIOP3C_PERST_N_R                                     /* synthesis LOC = "T11"*/,    //default 0 pull up en         O
output o_P1_MCIOG1A_PERST_N_R                                     /* synthesis LOC = "P8 "*/,    //default 0 pull up en         O
output o_P1_MCIOG1C_PERST_N_R                                     /* synthesis LOC = "N5 "*/,    //default 0 pull up en         O
output o_P1_MCIOP4A_PERST_N_R                                     /* synthesis LOC = "G5 "*/,    //default 0 pull up en         O

output o_P0_MCIOP0A_GPU_THROTTLE_N_R                              /* synthesis LOC = "Y1 "*/,    //default 0 pull up en         O
output o_P0_MCIOP0C_GPU_THROTTLE_N_R                              /* synthesis LOC = "W6 "*/,    //default 0 pull up en         O
output o_P0_MCIOP1A_GPU_THROTTLE_N_R                              /* synthesis LOC = "W10"*/,    //default 0 pull up en         O
output o_P0_MCIOP1C_GPU_THROTTLE_N_R                              /* synthesis LOC = "Y14"*/,    //default 0 pull up en         O
output o_P0_MCIOP2A_GPU_THROTTLE_N_R                              /* synthesis LOC = "N16"*/,    //default 0 pull up en         O
output o_P0_MCIOP2C_GPU_THROTTLE_N_R                              /* synthesis LOC = "A8 "*/,    //default 0 pull up en         O
output o_P0_MCIOP3A_GPU_THROTTLE_N_R                              /* synthesis LOC = "T18"*/,    //default 0 pull up en         O
output o_P0_MCIOP3C_GPU_THROTTLE_N_R                              /* synthesis LOC = "U15"*/,    //default 0 pull up en         O
output o_P0_MCIOG3A_GPU_THROTTLE_N_R                              /* synthesis LOC = "D18"*/,    //default 0 pull up en         O
output o_P0_MCIOG3C_GPU_THROTTLE_N_R                              /* synthesis LOC = "D17"*/,    //default 0 pull up en         O

output o_P1_MCIOP0A_GPU_THROTTLE_N_R                              /* synthesis LOC = "T4 "*/,    //default 0 pull up en         O
output o_P1_MCIOP0C_GPU_THROTTLE_N_R                              /* synthesis LOC = "N14"*/,    //default 0 pull up en         O
output o_P1_MCIOP1A_GPU_THROTTLE_N_R                              /* synthesis LOC = "E3 "*/,    //default 0 pull up en         O
output o_P1_MCIOP1C_GPU_THROTTLE_N_R                              /* synthesis LOC = "F2 "*/,    //default 0 pull up en         O
output o_P1_MCIOP2A_GPU_THROTTLE_N_R                              /* synthesis LOC = "G3 "*/,    //default 0 pull up en         O
output o_P1_MCIOP2C_GPU_THROTTLE_N_R                              /* synthesis LOC = "K2 "*/,    //default 0 pull up en         O
output o_P1_MCIOP3A_GPU_THROTTLE_N_R                              /* synthesis LOC = "U9 "*/,    //default 0 pull up en         O
output o_P1_MCIOP3C_GPU_THROTTLE_N_R                              /* synthesis LOC = "U11"*/,    //default 0 pull up en         O
output o_P1_MCIOG1A_GPU_THROTTLE_N_R                              /* synthesis LOC = "T12"*/,    //default 0 pull up en         O
output o_P1_MCIOG1C_GPU_THROTTLE_N_R                              /* synthesis LOC = "P6 "*/,    //default 0 pull up en         O
   

input   i_P0_MCIOP0A_NVME0_PRSNT_N_R                              /* synthesis LOC = "Y4 "*/,    //default 1 active 0           I
input   i_P0_MCIOP0A_NVME1_PRSNT_N_R                              /* synthesis LOC = "W5 "*/,    //default 1 active 0           I
input   i_P0_MCIOP0C_NVME0_PRSNT_N_R                              /* synthesis LOC = "W9 "*/,    //default 1 active 0           I
input   i_P0_MCIOP0C_NVME1_PRSNT_N_R                              /* synthesis LOC = "V17"*/,    //default 1 active 0           I
input   i_P0_MCIOP1A_NVME0_PRSNT_N_R                              /* synthesis LOC = "Y13"*/,    //default 1 active 0           I
input   i_P0_MCIOP1A_NVME1_PRSNT_N_R                              /* synthesis LOC = "Y12"*/,    //default 1 active 0           I
input   i_P0_MCIOP1C_NVME0_PRSNT_N_R                              /* synthesis LOC = "Y18"*/,    //default 1 active 0           I
input   i_P0_MCIOP1C_NVME1_PRSNT_N_R                              /* synthesis LOC = "Y19"*/,    //default 1 active 0           I
input   i_P0_MCIOP2A_NVME0_PRSNT_N_R                              /* synthesis LOC = "R13"*/,    //default 1 active 0           I
input   i_P0_MCIOP2A_NVME1_PRSNT_N_R                              /* synthesis LOC = "P12"*/,    //default 1 active 0           I
input   i_P0_MCIOP2C_NVME0_PRSNT_N_R                              /* synthesis LOC = "E6 "*/,    //default 1 active 0           I
input   i_P0_MCIOP2C_NVME1_PRSNT_N_R                              /* synthesis LOC = "D7 "*/,    //default 1 active 0           I
input   i_P0_MCIOP3A_NVME0_PRSNT_N_R                              /* synthesis LOC = "J18"*/,    //default 1 active 0           I
input   i_P0_MCIOP3A_NVME1_PRSNT_N_R                              /* synthesis LOC = "K19"*/,    //default 1 active 0           I
input   i_P0_MCIOP3C_NVME0_PRSNT_N_R                              /* synthesis LOC = "N17"*/,    //default 1 active 0           I
input   i_P0_MCIOP3C_NVME1_PRSNT_N_R                              /* synthesis LOC = "T17"*/,    //default 1 active 0           I
input   i_P0_MCIOG3A_NVME0_PRSNT_N_R                              /* synthesis LOC = "C12"*/,    //default 1 active 0           I
input   i_P0_MCIOG3A_NVME1_PRSNT_N_R                              /* synthesis LOC = "E17"*/,    //default 1 active 0           I
input   i_P0_MCIOG3C_NVME0_PRSNT_N_R                              /* synthesis LOC = "D6 "*/,    //default 1 active 0           I
input   i_P0_MCIOG3C_NVME1_PRSNT_N_R                              /* synthesis LOC = "E19"*/,    //default 1 active 0           I
 
input   i_P1_MCIOP0A_NVME0_PRSNT_N_R                              /* synthesis LOC = "T6 "*/,    //default 1 active 0           I
input   i_P1_MCIOP0A_NVME1_PRSNT_N_R                              /* synthesis LOC = "R4 "*/,    //default 1 active 0           I
input   i_P1_MCIOP0C_NVME0_PRSNT_N_R                              /* synthesis LOC = "K6 "*/,    //default 1 active 0           I
input   i_P1_MCIOP0C_NVME1_PRSNT_N_R                              /* synthesis LOC = "C4 "*/,    //default 1 active 0           I
input   i_P1_MCIOP1A_NVME0_PRSNT_N_R                              /* synthesis LOC = "D2 "*/,    //default 1 active 0           I
input   i_P1_MCIOP1A_NVME1_PRSNT_N_R                              /* synthesis LOC = "C2 "*/,    //default 1 active 0           I
input   i_P1_MCIOP1C_NVME0_PRSNT_N_R                              /* synthesis LOC = "M5 "*/,    //default 1 active 0           I
input   i_P1_MCIOP1C_NVME1_PRSNT_N_R                              /* synthesis LOC = "G4 "*/,    //default 1 active 0           I
input   i_P1_MCIOP2A_NVME0_PRSNT_N_R                              /* synthesis LOC = "H2 "*/,    //default 1 active 0           I
input   i_P1_MCIOP2A_NVME1_PRSNT_N_R                              /* synthesis LOC = "R2 "*/,    //default 1 active 0           I
input   i_P1_MCIOP2C_NVME0_PRSNT_N_R                              /* synthesis LOC = "K4 "*/,    //default 1 active 0           I
input   i_P1_MCIOP2C_NVME1_PRSNT_N_R                              /* synthesis LOC = "U4 "*/,    //default 1 active 0           I
input   i_P1_MCIOP3A_NVME0_PRSNT_N_R                              /* synthesis LOC = "F8 "*/,    //default 1 active 0           I
input   i_P1_MCIOP3A_NVME1_PRSNT_N_R                              /* synthesis LOC = "L3 "*/,    //default 1 active 0           I
input   i_P1_MCIOP3C_NVME0_PRSNT_N_R                              /* synthesis LOC = "E7 "*/,    //default 1 active 0           I
input   i_P1_MCIOP3C_NVME1_PRSNT_N_R                              /* synthesis LOC = "N3 "*/,    //default 1 active 0           I
input   i_P1_MCIOG1A_NVME0_PRSNT_N_R                              /* synthesis LOC = "P15"*/,    //default 1 active 0           I
input   i_P1_MCIOG1A_NVME1_PRSNT_N_R                              /* synthesis LOC = "T10"*/,    //default 1 active 0           I
input   i_P1_MCIOG1C_NVME0_PRSNT_N_R                              /* synthesis LOC = "R5 "*/,    //default 1 active 0           I
input   i_P1_MCIOG1C_NVME1_PRSNT_N_R                              /* synthesis LOC = "P5 "*/,    //default 1 active 0           I
input   i_P1_MCIOP4A_NVME0_PRSNT_N_R                              /* synthesis LOC = "L5 "*/,    //default 1 active 0           I


output o_P0_MCIOP0A_RSV_R                                         /* synthesis LOC = "W3 "*/,    //default 0 pull up en         O
output o_P0_MCIOP0C_RSV_R                                         /* synthesis LOC = "Y7 "*/,    //default 0 pull up en         O
output o_P0_MCIOP1A_RSV_R                                         /* synthesis LOC = "Y11"*/,    //default 0 pull up en         O
output o_P0_MCIOP1C_RSV_R                                         /* synthesis LOC = "W16"*/,    //default 0 pull up en         O
output o_P0_MCIOP2A_RSV_R                                         /* synthesis LOC = "R11"*/,    //default 0 pull up en         O
output o_P0_MCIOP2C_RSV_R                                         /* synthesis LOC = "F9 "*/,    //default 0 pull up en         O
output o_P0_MCIOP3A_RSV_R                                         /* synthesis LOC = "M18"*/,    //default 0 pull up en         O
output o_P0_MCIOP3C_RSV_R                                         /* synthesis LOC = "P18"*/,    //default 0 pull up en         O
output o_P0_MCIOG3A_RSV_R                                         /* synthesis LOC = "H18"*/,    //default 0 pull up en         O
output o_P0_MCIOG3C_RSV_R                                         /* synthesis LOC = "C18"*/,    //default 0 pull up en         O

output o_P1_MCIOP0A_RSV_R                                         /* synthesis LOC = "T3 "*/,    //default 0 pull up en         O
output o_P1_MCIOP0C_RSV_R                                         /* synthesis LOC = "P14"*/,    //default 0 pull up en         O
output o_P1_MCIOP1A_RSV_R                                         /* synthesis LOC = "F3 "*/,    //default 0 pull up en         O
output o_P1_MCIOP1C_RSV_R                                         /* synthesis LOC = "G2 "*/,    //default 0 pull up en         O
output o_P1_MCIOP2A_RSV_R                                         /* synthesis LOC = "V4 "*/,    //default 0 pull up en         O
output o_P1_MCIOP2C_RSV_R                                         /* synthesis LOC = "V6 "*/,    //default 0 pull up en         O
output o_P1_MCIOP3A_RSV_R                                         /* synthesis LOC = "M2 "*/,    //default 0 pull up en         O
output o_P1_MCIOP3C_RSV_R                                         /* synthesis LOC = "P3 "*/,    //default 0 pull up en         O
output o_P1_MCIOG1A_RSV_R                                         /* synthesis LOC = "R12"*/,    //default 0 pull up en         O
output o_P1_MCIOG1C_RSV_R                                         /* synthesis LOC = "N6 "*/,    //default 0 pull up en         O


input   i_P0_MCIOP0A_WAKE_N_R                                      /* synthesis LOC = "Y2 "*/,    //default 1 active 0           I
input   i_P0_MCIOP0C_WAKE_N_R                                      /* synthesis LOC = "W7 "*/,    //default 1 active 0           I
input   i_P0_MCIOP1A_WAKE_N_R                                      /* synthesis LOC = "W11"*/,    //default 1 active 0           I
input   i_P0_MCIOP1C_WAKE_N_R                                      /* synthesis LOC = "Y15"*/,    //default 1 active 0           I
input   i_P0_MCIOP2A_WAKE_N_R                                      /* synthesis LOC = "R8 "*/,    //default 1 active 0           I
input   i_P0_MCIOP2C_WAKE_N_R                                      /* synthesis LOC = "D8 "*/,    //default 1 active 0           I
input   i_P0_MCIOP3A_WAKE_N_R                                      /* synthesis LOC = "L17"*/,    //default 1 active 0           I
input   i_P0_MCIOP3C_WAKE_N_R                                      /* synthesis LOC = "N18"*/,    //default 1 active 0           I
input   i_P0_MCIOG3A_WAKE_N_R                                      /* synthesis LOC = "G19"*/,    //default 1 active 0           I
input   i_P0_MCIOG3C_WAKE_N_R                                      /* synthesis LOC = "D19"*/,    //default 1 active 0           I

input   i_P1_MCIOP0A_WAKE_N_R                                      /* synthesis LOC = "R3 "*/,    //default 1 active 0           I
input   i_P1_MCIOP0C_WAKE_N_R                                      /* synthesis LOC = "E4 "*/,    //default 1 active 0           I
input   i_P1_MCIOP1A_WAKE_N_R                                      /* synthesis LOC = "C3 "*/,    //default 1 active 0           I
input   i_P1_MCIOP1C_WAKE_N_R                                      /* synthesis LOC = "F4 "*/,    //default 1 active 0           I
input   i_P1_MCIOP2A_WAKE_N_R                                      /* synthesis LOC = "V2 "*/,    //default 1 active 0           I
input   i_P1_MCIOP2C_WAKE_N_R                                      /* synthesis LOC = "U5 "*/,    //default 1 active 0           I
input   i_P1_MCIOP3A_WAKE_N_R                                      /* synthesis LOC = "M3 "*/,    //default 1 active 0           I
input   i_P1_MCIOP3C_WAKE_N_R                                      /* synthesis LOC = "P2 "*/,    //default 1 active 0           I
input   i_P1_MCIOG1A_WAKE_N_R                                      /* synthesis LOC = "M7 "*/,    //default 1 active 0           I
input   i_P1_MCIOG1C_WAKE_N_R                                      /* synthesis LOC = "R6 "*/,    //default 1 active 0           I

input   i_P0_MCIOP0A_CB_ID0_R                                     /* synthesis LOC = "W2  "*/,    //default 1 active 0           I
input   i_P0_MCIOP0A_CB_ID1_R                                     /* synthesis LOC = "W4  "*/,    //default 1 active 0           I
input   i_P0_MCIOP0C_CB_ID0_R                                     /* synthesis LOC = "Y6  "*/,    //default 1 active 0           I
input   i_P0_MCIOP0C_CB_ID1_R                                     /* synthesis LOC = "Y8  "*/,    //default 1 active 0           I
input   i_P0_MCIOP1A_CB_ID0_R                                     /* synthesis LOC = "Y10 "*/,    //default 1 active 0           I
input   i_P0_MCIOP1A_CB_ID1_R                                     /* synthesis LOC = "W13 "*/,    //default 1 active 0           I
input   i_P0_MCIOP1C_CB_ID0_R                                     /* synthesis LOC = "W15 "*/,    //default 1 active 0           I
input   i_P0_MCIOP1C_CB_ID1_R                                     /* synthesis LOC = "Y17 "*/,    //default 1 active 0           I
input   i_P0_MCIOP2A_CB_ID0_R                                     /* synthesis LOC = "R16 "*/,    //default 1 active 0           I
input   i_P0_MCIOP2A_CB_ID1_R                                     /* synthesis LOC = "P16 "*/,    //default 1 active 0           I
input   i_P0_MCIOP2C_CB_ID0_R                                     /* synthesis LOC = "D10 "*/,    //default 1 active 0           I
input   i_P0_MCIOP2C_CB_ID1_R                                     /* synthesis LOC = "C10 "*/,    //default 1 active 0           I
input   i_P0_MCIOP3A_CB_ID0_R                                     /* synthesis LOC = "P10 "*/,    //default 1 active 0           I
input   i_P0_MCIOP3A_CB_ID1_R                                     /* synthesis LOC = "P11 "*/,    //default 1 active 0           I
input   i_P0_MCIOP3C_CB_ID0_R                                     /* synthesis LOC = "R10 "*/,    //default 1 active 0           I
input   i_P0_MCIOP3C_CB_ID1_R                                     /* synthesis LOC = "T9  "*/,    //default 1 active 0           I
input   i_P0_MCIOG3A_CB_ID0_R                                     /* synthesis LOC = "F18 "*/,    //default 1 active 0           I
input   i_P0_MCIOG3A_CB_ID1_R                                     /* synthesis LOC = "G17 "*/,    //default 1 active 0           I
input   i_P0_MCIOG3C_CB_ID0_R                                     /* synthesis LOC = "C19 "*/,    //default 1 active 0           I
input   i_P0_MCIOG3C_CB_ID1_R                                     /* synthesis LOC = "C14 "*/,    //default 1 active 0           I
input   i_P0_MCIOP4A_CB_ID1_R                                     /* synthesis LOC = "G14 "*/,    //default 1 active 0           I

input   i_P1_MCIOP0A_CB_ID0_R                                     /* synthesis LOC = "H6  "*/,    //default 1 active 0           I
input   i_P1_MCIOP0A_CB_ID1_R                                     /* synthesis LOC = "C6  "*/,    //default 1 active 0           I
input   i_P1_MCIOP0C_CB_ID0_R                                     /* synthesis LOC = "P4  "*/,    //default 1 active 0           I
input   i_P1_MCIOP0C_CB_ID1_R                                     /* synthesis LOC = "M6  "*/,    //default 1 active 0           I
input   i_P1_MCIOP1A_CB_ID0_R                                     /* synthesis LOC = "M4  "*/,    //default 1 active 0           I
input   i_P1_MCIOP1A_CB_ID1_R                                     /* synthesis LOC = "N4  "*/,    //default 1 active 0           I
input   i_P1_MCIOP1C_CB_ID0_R                                     /* synthesis LOC = "L7  "*/,    //default 1 active 0           I
input   i_P1_MCIOP1C_CB_ID1_R                                     /* synthesis LOC = "L6  "*/,    //default 1 active 0           I
input   i_P1_MCIOP2A_CB_ID0_R                                     /* synthesis LOC = "V3  "*/,    //default 1 active 0           I
input   i_P1_MCIOP2A_CB_ID1_R                                     /* synthesis LOC = "J3  "*/,    //default 1 active 0           I
input   i_P1_MCIOP2C_CB_ID0_R                                     /* synthesis LOC = "U6  "*/,    //default 1 active 0           I
input   i_P1_MCIOP2C_CB_ID1_R                                     /* synthesis LOC = "L2  "*/,    //default 1 active 0           I
input   i_P1_MCIOP3A_CB_ID0_R                                     /* synthesis LOC = "N2  "*/,    //default 1 active 0           I
input   i_P1_MCIOP3A_CB_ID1_R                                     /* synthesis LOC = "T8  "*/,    //default 1 active 0           I
input   i_P1_MCIOP3C_CB_ID0_R                                     /* synthesis LOC = "R1  "*/,    //default 1 active 0           I
input   i_P1_MCIOP3C_CB_ID1_R                                     /* synthesis LOC = "V10 "*/,    //default 1 active 0           I
input   i_P1_MCIOP4A_CB_ID1_R                                     /* synthesis LOC = "G6  "*/,    //default 1 active 0           I
input   i_P1_MCIOG1A_CB_ID0_R                                     /* synthesis LOC = "N15 "*/,    //default 1 active 0           I
input   i_P1_MCIOG1A_CB_ID1_R                                     /* synthesis LOC = "P9  "*/,    //default 1 active 0           I
input   i_P1_MCIOG1C_CB_ID0_R                                     /* synthesis LOC = "R15 "*/,    //default 1 active 0           I
input   i_P1_MCIOG1C_CB_ID1_R                                     /* synthesis LOC = "R14 "*/,    //default 1 active 0           I


input   i_P0_MCIOP0A_DATAIN                                       /* synthesis LOC = "Y3  "*/,    //default 1 active 0           I
output  o_P0_MCIOP0A_CLK                                          /* synthesis LOC = "U17 "*/,    //default 0 pull up en         O
output  o_P0_MCIOP0A_LD                                           /* synthesis LOC = "U18 "*/,    //default 0 pull up en         O

//CLK
output  o_CLK_GEN_INTR_N_R                                        /* synthesis LOC = "A13  "*/,     //default 0 pull up en       O
output  o_CLK_GEN_LOL_N_R                                         /* synthesis LOC = "U20  "*/,     //default 0 pull up en       O
input   i_CLK_PAL2_IN_25M                                         /* synthesis LOC = "U1   "*/,    //default 1 active 0          I
output o_CLK_GEN_FINC_R                                           /* synthesis LOC = "T20  "*/,    //default 0 pull up en        O
output o_CLK_GEN_RST_N_R                                          /* synthesis LOC = "A14  "*/,    //default 0 pull up en        O
output o_CLK_GEN_OE_N_R                                           /* synthesis LOC = "A15  "*/,    //default 0 pull up en        O
output o_CLK_GEN_FDEC_R                                           /* synthesis LOC = "A16  "*/,    //default 0 pull up en        O
output o_CLK_GEN_I2C_SEL_R                                        /* synthesis LOC = "A17  "*/,    //default 0 pull up en        O
output o_CLK_DB2000_2_1_OE_N                                      /* synthesis LOC = "P1   "*/,    //default 0 pull up en        O
output o_CLK_DB2000_2_2_OE_N                                      /* synthesis LOC = "A1   "*/,    //default 0 pull up en        O

//OTHER
output o_RST_I2C1_MUX_N_R                                         /* synthesis LOC = "B1  "*/,    //default 0 pull up en         O
output o_RST_I2C2_MUX_N_R                                         /* synthesis LOC = "B17 "*/,    //default 0 pull up en         O
output o_RST_I2C3_MUX_N_R                                         /* synthesis LOC = "A20 "*/,    //default 0 pull up en         O

output o_PCIE_SATA_RST_N                                          /* synthesis LOC = "V19 "*/,    //default 0 pull up en         O
output o_PCIE_SATA_WAKE_R_N                                       /* synthesis LOC = "L15 "*/,    //default 0 pull up en         O

output o_SW_BIOS_FLASH_SPI_S_R                                    /* synthesis LOC = "A10 "*/,    //default 0 pull up en         O
output o_SW_BIOS_SPI_OE                                           /* synthesis LOC = "A9  "*/,    //default 0 pull up en         O
output o_BIOS_FLASH_RESET_R_N                                     /* synthesis LOC = "A11 "*/,    //default 0 pull up en         O

output o_SW_BIOS_QSPI_S_R                                         /* synthesis LOC = "A12 "*/,    //default 0 pull up en         O
output o_SW_QSPI_OE_R                                             /* synthesis LOC = "B16 "*/,    //default 0 pull up en         O
output o_PAL_SPI_BIOS_UPDATA_EN                                   /* synthesis LOC = "J16 "*/,    //default 0 pull up en         O

input   i_PAL_PE_WAKE_N                                           /* synthesis LOC = "B20 "*/,    //default 1 active 0           I
input   i_PAL_NODE1_TYPE                                          /* synthesis LOC = "F16 "*/,    //default 1 active 0           I
output  o_PAL_SPI1_BMC_HOLD                                       /* synthesis LOC = "H19 "*/,    //default 0 pull up en         O
input   i_PAL_S5_CPU_SHTDN_R                                      /* synthesis LOC = "V1  "*/,   //default 1 active 0            I


input   i_BOARD_ID0                                               /* synthesis LOC = "N1  "*/,    //default 1 active 0           I
input   i_BOARD_ID1                                               /* synthesis LOC = "L1  "*/,    //default 1 active 0           I
input   i_BOARD_ID2                                               /* synthesis LOC = "K1  "*/,    //default 1 active 0           I
input   i_BOARD_ID3                                               /* synthesis LOC = "J1  "*/,    //default 1 active 0           I

output  o_SATA1_RSV                                               /* synthesis LOC = "F14 "*/,    //default 0 pull up en         O
input   i_PWRGD_SYS_PWROK_R                                       /* synthesis LOC = "G9  "*/,    //default 1 active 0           I

input   i_PCA_REVISION_0                                          /* synthesis LOC = "E1  "*/,    //default 1 active 0           I
input   i_PCA_REVISION_1                                          /* synthesis LOC = "D1  "*/,    //default 1 active 0           I
input   i_PCA_REVISION_2                                          /* synthesis LOC = "C1  "*/,    //default 1 active 0           I
input   i_PCB_REVISION_0                                          /* synthesis LOC = "H1  "*/,    //default 1 active 0           I
input   i_PCB_REVISION_1                                          /* synthesis LOC = "G1  "*/,    //default 1 active 0           I
input   i_PCB_REVISION_2                                          /* synthesis LOC = "F1  "*/,    //default 1 active 0           I

output o_M2_GPIO6_R                                               /* synthesis LOC = "M15  "*/,    //default 0 pull up en        O
output o_M2_GPIO7_R                                               /* synthesis LOC = "M16  "*/,    //default 0 pull up en        O

input   i_BREAK_DET_DO_N                                          /* synthesis LOC = "F17  "*/,    //default 1 active 0           I
input   i_LEAKAGE_PRSNT_N                                         /* synthesis LOC = "D14  "*/,    //default 1 active 0           I
input   i_LEAKAGE_DET_DO_N                                        /* synthesis LOC = "C16  "*/,    //default 1 active 0           I
input   i_BREAK_DET1_DO_N                                         /* synthesis LOC = "J6   "*/,    //default 1 active 0           I
input   i_LEAKAGE_PRSNT1_N                                        /* synthesis LOC = "J5   "*/,    //default 1 active 0           I
input   i_LEAKAGE_DET1_DO_N                                       /* synthesis LOC = "K7   "*/,    //default 1 active 0           I

input   i_PAL_MEN_CPU_SHTDN_R                                     /* synthesis LOC = "B11  "*/,    //default 1 active 0           I

input   i_PAL_P12V_CPU1_DIMM_GOK                                  /* synthesis LOC = "J19  "*/,    //default 1 active 0           I
input   i_PAL_P12V_CPU1_DIMM_OC                                   /* synthesis LOC = "K16  "*/,    //default 1 active 0           I
output o_PAL_P12V_CPU1_DIMM_ON                                    /* synthesis LOC = "M17  "*/,    //default 0 pull up en         O

input   i_PAL_P12V_CPU0_DIMM_GOK                                  /* synthesis LOC = "U12  "*/,    //default 1 active 0           I
input   i_PAL_P12V_CPU0_DIMM_OC                                   /* synthesis LOC = "V13  "*/,    //default 1 active 0           I
output o_PAL_P12V_CPU0_DIMM_ON                                    /* synthesis LOC = "V12  "*/,    //default 0 pull up en         O

input   i_SMB_CPU0_ALERT_N_R                                      /* synthesis LOC = "B12  "*/,    //default 1 active 0           I

output o_P0_SPI_TPM_CS_N_3V3                                      /* synthesis LOC = "C15  "*/,    //default 0 pull up en         O
output o_P0_I2C5_9617_EN                                          /* synthesis LOC = "A6   "*/,    //default 0 pull up en         O

input   i_PAL_PCH_INTRUDER                                        /* synthesis LOC = "F12  "*/,    //default 1 active 0           I
input   i_PCH_INTRUDER_CABLE_INST_R_N                             /* synthesis LOC = "D16  "*/,    //default 1 active 0           I
output o_P12V_DISCHARGE_R                                         /* synthesis LOC = "L16  "*/,    //default 0 pull up en         O

output o_CPLD1_CPLD2_RSV1_R                                       /* synthesis LOC = "W20 "*/,    //default 0 pull up en         O
input   i_CPLD1_CPLD2_RSV2_R                                      /* synthesis LOC = "V20 "*/     //default 1 active 0           I
);



