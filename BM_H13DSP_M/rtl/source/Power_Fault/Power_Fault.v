//=================================================================================================

`timescale 1ns / 1ps

module Power_Fault #(
parameter BYTE_NO_REG = 8'h14
)
(
input  i_clk,
input  i_rst_n,
input  i_20mSEC,

input  i_fault_int_ign,
input  i_delay_int_ign,

input  i_clr_flag,
output o_pwr_err_int,
output o_delay_err_int,
//Byte1
input  i_P12V_PVDDQ_STDN_0,
input  i_P12V_PVDDQ_STDN_1,
input  i_P12V_PVDDQ_STDN_2,
input  i_P12V_PVDDQ_STDN_3,
//Byte2
input  i_PWRGD_P12V_0_STBY,          //P12V_STBY
input  i_PWRGD_P12V_1_STBY,          //P12V_STBY
input  i_PWRGD_P5V_STBY,             //P5V_STBY
input  i_PWRGD_P3V3_STBY,            //P3V3_STBY
input  i_PWRGD_P1V8_STBY,
input  i_PWRGD_P3V3_BMC_RGM_STBY,
input  i_PWRGD_P2V5_STBY,
input  i_PWRGD_P1V2_STBY,
//Byte3
input  i_PWRGD_P1V0_BMC_STBY,
input  i_FM_PVNN_PCH_STBY_EN,
input  i_PWRGD_PVNN_PCH_STBY,
input  i_FM_P1V05_PCH_STBY_EN,
input  i_PWRGD_P1V05_PCH_STBY,
input  i_RST_RSMRST_N,
input  i_BMC_SRST_N,
input  i_PWRGD_DSW_PWROK,
input  i_FM_SLP_SUS_RSM_RST_N,
//Byte4
input  i_FM_SLPS4_N,
input  i_FM_SLPS3_N,
input  i_PWRGD_PS0_PWROK,
input  i_PWRGD_PS1_PWROK,
input  i_PWRGD_PS2_PWROK,
input  i_PWRGD_PS3_PWROK,
input  i_PWRGD_PS4_PWROK,
input  i_PWRGD_PS5_PWROK,
input  i_PWRGD_PS_PWROK,
//Byte5
input  i_FM_P12V_CPU0_EN,
input  i_FM_P12V_CPU1_EN,
input  i_PWRGD_CPU0_DIMM_PWROK,
input  i_PWRGD_CPU1_DIMM_PWROK,
input  i_PWRGD_P12V_CPU0_PCIE,
input  i_PWRGD_P12V_CPU1_PCIE,
input  i_FM_P12V_FAN_EN,
input  i_PWRGD_P12V_FAN,
input  i_FM_P5V_P3V3_EN,
input  i_PWRGD_P5V,
input  i_PWRGD_P5V_HDD,
input  i_PWRGD_P3V3,
//Byte6
input  i_PWRGD_DRAMPWRGD_CPU0_AB,
input  i_PWRGD_DRAMPWRGD_CPU0_CD,
input  i_PWRGD_DRAMPWRGD_CPU0_EF,
input  i_PWRGD_DRAMPWRGD_CPU0_GH,
input  i_PWRGD_DRAMPWRGD_CPU1_AB,
input  i_PWRGD_DRAMPWRGD_CPU1_CD,
input  i_PWRGD_DRAMPWRGD_CPU1_EF,
input  i_PWRGD_DRAMPWRGD_CPU1_GH,
//Byte7
input  i_adr_sel,
input  i_PWRGD_FAIL_CPU0_AB,
input  i_PWRGD_FAIL_CPU0_CD,
input  i_PWRGD_FAIL_CPU0_EF,
input  i_PWRGD_FAIL_CPU0_GH,
input  i_PWRGD_FAIL_CPU1_AB,
input  i_PWRGD_FAIL_CPU1_CD,
input  i_PWRGD_FAIL_CPU1_EF,
input  i_PWRGD_FAIL_CPU1_GH,
//Byte8
input  i_M_AB_CPU0_RESET_N,
input  i_M_CD_CPU0_RESET_N,
input  i_M_EF_CPU0_RESET_N,
input  i_M_GH_CPU0_RESET_N,
input  i_M_AB_CPU1_RESET_N,
input  i_M_CD_CPU1_RESET_N,
input  i_M_EF_CPU1_RESET_N,
input  i_M_GH_CPU1_RESET_N,
//Byte9
input  i_M_AB_CPU0_FPGA_RESET_N,
input  i_M_CD_CPU0_FPGA_RESET_N,
input  i_M_EF_CPU0_FPGA_RESET_N,
input  i_M_GH_CPU0_FPGA_RESET_N,
input  i_M_AB_CPU1_FPGA_RESET_N,
input  i_M_CD_CPU1_FPGA_RESET_N,
input  i_M_EF_CPU1_FPGA_RESET_N,
input  i_M_GH_CPU1_FPGA_RESET_N,
//Byte10
input  i_cpu_pwr_en,
input  i_FM_PVCCD_HV_CPU0_EN,         //CPU VR EN MEMORY PVCCD_HV
input  i_FM_PVPP_HBM_CPU0_EN,         //CPU VR EN PVPP_HBM
input  i_FM_PVCCFA_EHV_CPU0_EN,       //CPU VR EN PVCCFA_EHV
input  i_FM_PVCCFA_EHV_FIVRA_CPU0_EN, //CPU VR EN PVCCFA_EHV_FIVRA
input  i_FM_PVCCINFAON_CPU0_EN,       //CPU VR EN PVCCINFAON
input  i_FM_PVNN_MAIN_CPU0_EN,        //CPU VR EN PVNN
input  i_FM_PVCCIN_CPU0_EN,           //CPU VR EN PVCCIN

input  i_PWRGD_PVCCD_HV_CPU0,         // CPU VR MEMORY PWRGD PVCCD_HV
input  i_PWRGD_PVPP_HBM_CPU0,         // CPU VR PWRGD PVPP_HBM
input  i_PWRGD_PVCCFA_EHV_CPU0,       // CPU VR PWRGD PVCCFA_EHV
input  i_PWRGD_PVCCFA_EHV_FIVRA_CPU0, // CPU VR PWRGD PVCCFA_EHV_FIVRA
input  i_PWRGD_PVCCINFAON_CPU0,       // CPU VR PWRGD PVCCINFAON
input  i_PWRGD_PVNN_MAIN_CPU0,        // CPU VR PWRGD PVNN
input  i_PWRGD_PVCCIN_CPU0,           // CPU VR PVCCIN
//Byte11
input  i_FM_PVCCD_HV_CPU1_EN,         //CPU VR EN MEMORY PVCCD_HV
input  i_FM_PVPP_HBM_CPU1_EN,         //CPU VR EN PVPP_HBM
input  i_FM_PVCCFA_EHV_CPU1_EN,       //CPU VR EN PVCCFA_EHV
input  i_FM_PVCCFA_EHV_FIVRA_CPU1_EN, //CPU VR EN PVCCFA_EHV_FIVRA
input  i_FM_PVCCINFAON_CPU1_EN,       //CPU VR EN PVCCINFAON
input  i_FM_PVNN_MAIN_CPU1_EN,        //CPU VR EN PVNN
input  i_FM_PVCCIN_CPU1_EN,           //CPU VR EN PVCCIN

input  i_PWRGD_PVCCD_HV_CPU1,         // CPU VR MEMORY PWRGD PVCCD_HV
input  i_PWRGD_PVPP_HBM_CPU1,         // CPU VR PWRGD PVPP_HBM
input  i_PWRGD_PVCCFA_EHV_CPU1,       // CPU VR PWRGD PVCCFA_EHV
input  i_PWRGD_PVCCFA_EHV_FIVRA_CPU1, // CPU VR PWRGD PVCCFA_EHV_FIVRA
input  i_PWRGD_PVCCINFAON_CPU1,       // CPU VR PWRGD PVCCINFAON
input  i_PWRGD_PVNN_MAIN_CPU1,        // CPU VR PWRGD PVNN
input  i_PWRGD_PVCCIN_CPU1,           // CPU VR PVCCIN
//Byte12
input  i_PWRGD_PLT_AUX_CPU0,          //CPU PRWGD PLATFORM AUXILIARY
input  i_PWRGD_PLT_AUX_CPU1,          //CPU PRWGD PLATFORM AUXILIARY
input  i_PWRGD_S0_PWROK_CPU0,
input  i_PWRGD_S0_PWROK_CPU1,
input  i_PWRGD_PCH_PWROK,
input  i_PWRGD_SYS_PWROK,
input  i_PWRGD_CPU0_LVC3,
input  i_PWRGD_CPU1_LVC3,
//Byte13
input  i_PWRGD_CPUPWRGD,
input  i_RST_PLTRST_N,

//Byte14
input  i_FM_OCP0_P12V_P3V3_STBY_EN,
input  i_PWRGD_P12V_STBY_OCP0,
input  i_PWRGD_P3V3_STBY_0CP0,
input  i_RST_OCP0_PERST_N,
input  i_PWRGD_OCP0_NIC_PWRGD,

input  i_FM_OCP1_P12V_P3V3_STBY_EN,
input  i_PWRGD_P12V_STBY_OCP1,
input  i_PWRGD_P3V3_STBY_0CP1,
input  i_RST_OCP1_PERST_N,
input  i_PWRGD_OCP1_NIC_PWRGD,

//Byte18
input  [3:0]i_dbg_mst_st,
//Byte19
input  [3:0]i_dbg_pch_st,
//Byte20
input  [3:0]i_dbg_cpu0_st,
input  [3:0]i_dbg_cpu1_st,

output o_power_fault,
output [8*BYTE_NO_REG-1 : 0]o_data_out
);
//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
localparam LOW     = 1'b0;
localparam HIGH    = 1'b1;
localparam Z       = 1'bz;
localparam T10S    = 500;  //SIM 10 (200ms)
localparam T5S     = 250;  //SIM 5  (100ms)
//////////////////////////////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////////////////////////////
wire [7:0]w_data_out[0:BYTE_NO_REG-1];
wire w_FM_SLPS3_neg;
reg  r_PWRGD_DOWN;
wire w_aux_ok;

reg  r_power_fault;
wire w_power_fault;
wire w_power_fault_neg;

wire w_fault_all;
wire w_fault_all_aux;
wire w_fault_all_core;

wire w_fault_all_neg;
wire w_fault_all_aux_neg;
wire w_fault_all_core_neg;

reg  r_aux_int;
reg  r_core_int;
//Power on delay
wire w_20mSEC_pos;
reg  [8:0]r_cnt_delay_AC;         //Max 500*20ms = 10s;
reg  [7:0]r_cnt_delay_DC;         //Max 250*20ms = 5s;
reg  r_AC_delay;
reg  r_DC_delay;
reg  r_pwr_fail_flag;

//Byte1
reg  [2:0]r_power_err_flag;
wire [3:0]w_P12V_PVDDQ_STDN;
wire [3:0]w_P12V_PVDDQ_STDN_latch;
wire [3:0]w_P12V_PVDDQ_STDN_fault;
//Byte2
wire w_P12V_0_STBY_latch;
wire w_P12V_0_STBY_fault;
wire w_P12V_1_STBY_latch;
wire w_P12V_1_STBY_fault;
wire w_P5V_STBY_latch;
wire w_P5V_STBY_fault;
wire w_P3V3_STBY_latch;
wire w_P3V3_STBY_fault;
wire [3:0]w_BMC_PW_EN;
wire [3:0]w_BMC_PW_GD;
wire [3:0]w_BMC_PW_latch;
wire [3:0]w_BMC_PW_fault;
//Byte3
wire w_PWRGD_P1V0_BMC_STBY_latch;
wire w_PWRGD_P1V0_BMC_STBY_fault;
wire [1:0]w_PCH_PW_EN;
wire [1:0]w_PCH_PW_GD;
wire [1:0]w_PCH_PW_latch;
wire [1:0]w_PCH_PW_fault;

reg  r_RST_RSMRST_N;
reg  r_BMC_SRST_N;
reg  r_PWRGD_DSW_PWROK;
reg  r_FM_SLP_SUS_RSM_RST_N;
//Byte4
reg  r_FM_SLPS4_N;
reg  r_FM_SLPS3_N;
reg  r_PWRGD_PS0_PWROK;
reg  r_PWRGD_PS1_PWROK;
reg  r_PWRGD_PS2_PWROK;
reg  r_PWRGD_PS3_PWROK;
reg  r_PWRGD_PS4_PWROK;
reg  r_PWRGD_PS5_PWROK;
//Byte5
wire [7:0]w_Byte5_PW_EN;
wire [7:0]w_Byte5_PW_GD;
wire [7:0]w_Byte5_PW_latch;
wire [7:0]w_Byte5_PW_fault;
//Byte6
reg  r_PWRGD_DRAMPWRGD_CPU0_AB;
reg  r_PWRGD_DRAMPWRGD_CPU0_CD;
reg  r_PWRGD_DRAMPWRGD_CPU0_EF;
reg  r_PWRGD_DRAMPWRGD_CPU0_GH;
reg  r_PWRGD_DRAMPWRGD_CPU1_AB;
reg  r_PWRGD_DRAMPWRGD_CPU1_CD;
reg  r_PWRGD_DRAMPWRGD_CPU1_EF;
reg  r_PWRGD_DRAMPWRGD_CPU1_GH;
//Byte7
wire [7:0]w_Byte7_PW_EN;
wire [7:0]w_Byte7_PW_GD;
wire [7:0]w_Byte7_PW_latch;
wire [7:0]w_Byte7_PW_fault;
//Byte8
reg  r_M_AB_CPU0_RESET_N;
reg  r_M_CD_CPU0_RESET_N;
reg  r_M_EF_CPU0_RESET_N;
reg  r_M_GH_CPU0_RESET_N;
reg  r_M_AB_CPU1_RESET_N;
reg  r_M_CD_CPU1_RESET_N;
reg  r_M_EF_CPU1_RESET_N;
reg  r_M_GH_CPU1_RESET_N;
//Byte9
reg  r_M_AB_CPU0_FPGA_RESET_N;
reg  r_M_CD_CPU0_FPGA_RESET_N;
reg  r_M_EF_CPU0_FPGA_RESET_N;
reg  r_M_GH_CPU0_FPGA_RESET_N;
reg  r_M_AB_CPU1_FPGA_RESET_N;
reg  r_M_CD_CPU1_FPGA_RESET_N;
reg  r_M_EF_CPU1_FPGA_RESET_N;
reg  r_M_GH_CPU1_FPGA_RESET_N;
//Byte10
wire [6:0]w_Byte10_PW_EN;
wire [6:0]w_Byte10_PW_GD;
wire [6:0]w_Byte10_PW_latch;
wire [6:0]w_Byte10_PW_fault;
//Byte11
wire [6:0]w_Byte11_PW_EN;
wire [6:0]w_Byte11_PW_GD;
wire [6:0]w_Byte11_PW_latch;
wire [6:0]w_Byte11_PW_fault;
//Byte12
reg  r_PWRGD_PLT_AUX_CPU0;          //CPU PRWGD PLATFORM AUXILIARY
reg  r_PWRGD_PLT_AUX_CPU1;          //CPU PRWGD PLATFORM AUXILIARY
reg  r_PWRGD_S0_PWROK_CPU0;
reg  r_PWRGD_S0_PWROK_CPU1;
reg  r_PWRGD_PCH_PWROK;
reg  r_PWRGD_SYS_PWROK;
reg  r_PWRGD_CPU0_LVC3;
reg  r_PWRGD_CPU1_LVC3;
//Byte13
reg  r_PWRGD_CPUPWRGD;
reg  r_RST_PLTRST_N;
//Byte14
wire [5:0]w_Byte14_PW_EN;
wire [5:0]w_Byte14_PW_GD;
wire [5:0]w_Byte14_PW_latch;
wire [5:0]w_Byte14_PW_fault;

//Byte18
reg  [3:0]r_dbg_mst_st;
//Byte19
reg  [3:0]r_dbg_pch_st;
//Byte20
reg  [3:0]r_dbg_cpu0_st;
reg  [3:0]r_dbg_cpu1_st;
//////////////////////////////////////////////////////////////////////////////////
// Continuous assignments
//////////////////////////////////////////////////////////////////////////////////
assign w_aux_ok    = i_PWRGD_PS_PWROK & i_PWRGD_P12V_0_STBY & i_PWRGD_P12V_1_STBY & i_PWRGD_P5V_STBY & i_PWRGD_P3V3_STBY;

assign w_fault_all = (& w_P12V_PVDDQ_STDN_fault) &
                     w_P12V_0_STBY_fault & w_P12V_1_STBY_fault & w_P5V_STBY_fault & w_P3V3_STBY_fault & (& w_BMC_PW_fault) &
                     w_PWRGD_P1V0_BMC_STBY_fault & (& w_PCH_PW_fault) &
                     (& w_Byte5_PW_fault) &
                     (& w_Byte7_PW_fault) &
                     (& w_Byte10_PW_fault) &
                     (& w_Byte11_PW_fault) &
                     (& w_Byte14_PW_fault);

assign w_power_fault = w_P12V_0_STBY_fault & w_P12V_1_STBY_fault & w_P5V_STBY_fault & w_P3V3_STBY_fault & (& w_BMC_PW_fault) &
                       w_PWRGD_P1V0_BMC_STBY_fault & (& w_PCH_PW_fault) &
                       (& w_Byte5_PW_fault) &
                       (& w_Byte7_PW_fault) &
                       (& w_Byte10_PW_fault) &
                       (& w_Byte11_PW_fault) &
                       (& w_Byte14_PW_fault);

assign w_fault_all_aux  = w_P12V_0_STBY_fault & w_P12V_1_STBY_fault & w_P5V_STBY_fault & w_P3V3_STBY_fault & (& w_BMC_PW_fault) &
                          w_PWRGD_P1V0_BMC_STBY_fault & (& w_PCH_PW_fault);
assign w_fault_all_core = (& w_P12V_PVDDQ_STDN_fault) &
                          (& w_Byte5_PW_fault) &
                          (& w_Byte7_PW_fault) &
                          (& w_Byte10_PW_fault) &
                          (& w_Byte11_PW_fault) &
                          (& w_Byte14_PW_fault);

assign o_power_fault   = r_power_fault;
assign o_pwr_err_int   = r_aux_int | r_core_int;
assign o_delay_err_int = r_AC_delay | r_DC_delay;
//Byte1
assign w_P12V_PVDDQ_STDN = {i_P12V_PVDDQ_STDN_0,i_P12V_PVDDQ_STDN_1,i_P12V_PVDDQ_STDN_2,i_P12V_PVDDQ_STDN_3};
//Byte2
assign w_BMC_PW_EN = {i_PWRGD_P3V3_STBY,i_PWRGD_P1V8_STBY,i_PWRGD_P1V8_STBY,i_PWRGD_P2V5_STBY};
assign w_BMC_PW_GD = {i_PWRGD_P1V8_STBY,i_PWRGD_P3V3_BMC_RGM_STBY,i_PWRGD_P2V5_STBY,i_PWRGD_P1V2_STBY};
//Byte3
assign w_PCH_PW_EN = {i_FM_PVNN_PCH_STBY_EN,i_FM_P1V05_PCH_STBY_EN};
assign w_PCH_PW_GD = {i_PWRGD_PVNN_PCH_STBY,i_PWRGD_P1V05_PCH_STBY};
//Byte5
assign w_Byte5_PW_EN = {i_FM_P12V_CPU0_EN,i_FM_P12V_CPU1_EN,i_FM_P12V_CPU0_EN,i_FM_P12V_CPU1_EN,
                        i_FM_P12V_FAN_EN,i_FM_P5V_P3V3_EN,i_FM_P5V_P3V3_EN,i_FM_P5V_P3V3_EN};
assign w_Byte5_PW_GD = {i_PWRGD_CPU0_DIMM_PWROK,i_PWRGD_CPU1_DIMM_PWROK,i_PWRGD_P12V_CPU0_PCIE,i_PWRGD_P12V_CPU1_PCIE,
                        i_PWRGD_P12V_FAN,i_PWRGD_P5V,i_PWRGD_P5V_HDD,i_PWRGD_P3V3};
//Byte7
assign w_Byte7_PW_EN = {{8{(i_FM_SLPS3_N & i_FM_SLPS4_N)}}};
assign w_Byte7_PW_GD = {i_PWRGD_FAIL_CPU0_AB,i_PWRGD_FAIL_CPU0_CD,i_PWRGD_FAIL_CPU0_EF,i_PWRGD_FAIL_CPU0_GH,
                        i_PWRGD_FAIL_CPU1_AB,i_PWRGD_FAIL_CPU1_CD,i_PWRGD_FAIL_CPU1_EF,i_PWRGD_FAIL_CPU1_GH};
//Byte10
assign w_Byte10_PW_EN = {i_FM_PVCCD_HV_CPU0_EN,i_FM_PVPP_HBM_CPU0_EN,i_FM_PVCCFA_EHV_CPU0_EN,i_FM_PVCCFA_EHV_FIVRA_CPU0_EN,
                         i_FM_PVCCINFAON_CPU0_EN,i_FM_PVNN_MAIN_CPU0_EN,i_FM_PVCCIN_CPU0_EN};
assign w_Byte10_PW_GD = {i_PWRGD_PVCCD_HV_CPU0,i_PWRGD_PVPP_HBM_CPU0,i_PWRGD_PVCCFA_EHV_CPU0,i_PWRGD_PVCCFA_EHV_FIVRA_CPU0,
                         i_PWRGD_PVCCINFAON_CPU0,i_PWRGD_PVNN_MAIN_CPU0,i_PWRGD_PVCCIN_CPU0};
//Byte11
assign w_Byte11_PW_EN = {i_FM_PVCCD_HV_CPU1_EN,i_FM_PVPP_HBM_CPU1_EN,i_FM_PVCCFA_EHV_CPU1_EN,i_FM_PVCCFA_EHV_FIVRA_CPU1_EN,
                         i_FM_PVCCINFAON_CPU1_EN,i_FM_PVNN_MAIN_CPU1_EN,i_FM_PVCCIN_CPU1_EN};
assign w_Byte11_PW_GD = {i_PWRGD_PVCCD_HV_CPU1,i_PWRGD_PVPP_HBM_CPU1,i_PWRGD_PVCCFA_EHV_CPU1,i_PWRGD_PVCCFA_EHV_FIVRA_CPU1,
                         i_PWRGD_PVCCINFAON_CPU1,i_PWRGD_PVNN_MAIN_CPU1,i_PWRGD_PVCCIN_CPU1};
//Byte14
assign w_Byte14_PW_EN = {i_FM_OCP0_P12V_P3V3_STBY_EN,i_FM_OCP0_P12V_P3V3_STBY_EN,i_RST_OCP0_PERST_N,
                         i_FM_OCP1_P12V_P3V3_STBY_EN,i_FM_OCP1_P12V_P3V3_STBY_EN,i_RST_OCP1_PERST_N};
assign w_Byte14_PW_GD = {i_PWRGD_P12V_STBY_OCP0,i_PWRGD_P3V3_STBY_0CP0,i_PWRGD_OCP0_NIC_PWRGD,
                         i_PWRGD_P12V_STBY_OCP1,i_PWRGD_P3V3_STBY_0CP1,i_PWRGD_OCP1_NIC_PWRGD};

assign w_data_out[0] = {r_power_err_flag[2:0],w_P12V_PVDDQ_STDN_latch[3:0],1'b1};
assign w_data_out[1] = {w_P12V_0_STBY_latch,w_P12V_1_STBY_latch,w_P5V_STBY_latch,w_P3V3_STBY_latch,w_BMC_PW_latch[3:0]};
assign w_data_out[2] = {w_PWRGD_P1V0_BMC_STBY_latch,w_PCH_PW_latch[1:0],r_RST_RSMRST_N,
                        r_BMC_SRST_N,r_PWRGD_DSW_PWROK,r_FM_SLP_SUS_RSM_RST_N,1'b1};
assign w_data_out[3] = {r_FM_SLPS4_N,r_FM_SLPS3_N,r_PWRGD_PS0_PWROK,r_PWRGD_PS1_PWROK,
                        r_PWRGD_PS2_PWROK,r_PWRGD_PS3_PWROK,r_PWRGD_PS4_PWROK,r_PWRGD_PS5_PWROK};
assign w_data_out[4] = w_Byte5_PW_latch;
assign w_data_out[5] = {r_PWRGD_DRAMPWRGD_CPU0_AB,r_PWRGD_DRAMPWRGD_CPU0_CD,
                        r_PWRGD_DRAMPWRGD_CPU0_EF,r_PWRGD_DRAMPWRGD_CPU0_GH,
                        r_PWRGD_DRAMPWRGD_CPU1_AB,r_PWRGD_DRAMPWRGD_CPU1_CD,
                        r_PWRGD_DRAMPWRGD_CPU1_EF,r_PWRGD_DRAMPWRGD_CPU1_GH};
assign w_data_out[6] = w_Byte7_PW_latch[7:0];
assign w_data_out[7] = {r_M_AB_CPU0_RESET_N,r_M_CD_CPU0_RESET_N,r_M_EF_CPU0_RESET_N,r_M_GH_CPU0_RESET_N,
                        r_M_AB_CPU1_RESET_N,r_M_CD_CPU1_RESET_N,r_M_EF_CPU1_RESET_N,r_M_GH_CPU1_RESET_N};
assign w_data_out[8] = {r_M_AB_CPU0_FPGA_RESET_N,r_M_CD_CPU0_FPGA_RESET_N,
                        r_M_EF_CPU0_FPGA_RESET_N,r_M_GH_CPU0_FPGA_RESET_N,
                        r_M_AB_CPU1_FPGA_RESET_N,r_M_CD_CPU1_FPGA_RESET_N,
                        r_M_EF_CPU1_FPGA_RESET_N,r_M_GH_CPU1_FPGA_RESET_N};
assign w_data_out[9]  = {w_Byte10_PW_latch[6:0],1'b1};
assign w_data_out[10] = {w_Byte11_PW_latch[6:0],1'b1};
assign w_data_out[11] = {r_PWRGD_PLT_AUX_CPU0,r_PWRGD_PLT_AUX_CPU1,r_PWRGD_S0_PWROK_CPU0,r_PWRGD_S0_PWROK_CPU1,
                         r_PWRGD_PCH_PWROK,r_PWRGD_SYS_PWROK,r_PWRGD_CPU0_LVC3,r_PWRGD_CPU1_LVC3};
assign w_data_out[12] = {r_PWRGD_CPUPWRGD,r_RST_PLTRST_N,6'b111111};
assign w_data_out[13] = {w_Byte14_PW_latch[5:0],2'b11};
assign w_data_out[14] = 8'hff;
assign w_data_out[15] = 8'hff;
assign w_data_out[16] = 8'hff;
assign w_data_out[17] = {4'b0000,r_dbg_mst_st[3:0]};
assign w_data_out[18] = {r_dbg_pch_st[3:0],4'b0000};
assign w_data_out[19] = {r_dbg_cpu0_st[3:0],r_dbg_cpu1_st[3:0]};

assign o_data_out = {w_data_out[19],w_data_out[18],w_data_out[17],w_data_out[16],
                     w_data_out[15],w_data_out[14],w_data_out[13],w_data_out[12],
                     w_data_out[11],w_data_out[10],w_data_out[9],w_data_out[8],
                     w_data_out[7],w_data_out[6],w_data_out[5],w_data_out[4],
                     w_data_out[3],w_data_out[2],w_data_out[1],w_data_out[0]};
//////////////////////////////////////Byte1/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////4st Bit////////////////////////////////////// //
genvar iB1;
generate
    for (iB1=0; iB1<4; iB1=iB1+1)
    begin : Byte1
    Pwr_Error_Latch#(  
    .EDGE              (1'b1),                            //Rising edge
    .EN_JUDGE          (1'b1),                            //To judge if there is power en
    .EDGE_LATCH_EN     (1'b1),                            //Enable signal edge latch
    .EXT_LATCH_EN      (1'b1)                             //Enable external signal latch
    )Pwr_Error_Latch_B1b4
    (
    .i_clk             (i_clk),
    .i_rst_n           (i_rst_n),
    
    .i_clr_flag        (i_clr_flag),
    .i_PWR_EN          (~i_fault_int_ign),                //To judge power en or power good;
    .i_latch_flag      (w_fault_all_neg),
    .i_signal          (w_P12V_PVDDQ_STDN[iB1]),
    .o_signal_latch    (w_P12V_PVDDQ_STDN_latch[iB1]),
    .o_fault_n         (w_P12V_PVDDQ_STDN_fault[iB1])
    );
    end
endgenerate
//////////////////////////////////////Byte2/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7st Bit////////////////////////////////////// //
Pwr_Error_Latch#(  
.EDGE              (1'b0),                            //Falling edge
.EN_JUDGE          (1'b1),                            //To judge if there is power en
.EDGE_LATCH_EN     (1'b1),                            //Enable signal edge latch
.EXT_LATCH_EN      (1'b1)                             //Enable external signal latch
)Pwr_Error_Latch_B2b7
(
.i_clk             (i_clk),
.i_rst_n           (i_rst_n),

.i_clr_flag        (i_clr_flag),
.i_PWR_EN          (i_PWRGD_PS_PWROK & (~i_fault_int_ign)),       //To judge power en or power good;
.i_latch_flag      (w_fault_all_neg),
.i_signal          (i_PWRGD_P12V_0_STBY),
.o_signal_latch    (w_P12V_0_STBY_latch),
.o_fault_n         (w_P12V_0_STBY_fault)
);

/////////////////////////////////////6st Bit////////////////////////////////////// //
Pwr_Error_Latch#(  
.EDGE              (1'b0),                            //Falling edge
.EN_JUDGE          (1'b1),                            //To judge if there is power en
.EDGE_LATCH_EN     (1'b1),                            //Enable signal edge latch
.EXT_LATCH_EN      (1'b1)                             //Enable external signal latch
)Pwr_Error_Latch_B2b6
(
.i_clk             (i_clk),
.i_rst_n           (i_rst_n),

.i_clr_flag        (i_clr_flag),
.i_PWR_EN          (i_PWRGD_PS_PWROK & (~i_fault_int_ign)),       //To judge power en or power good;
.i_latch_flag      (w_fault_all_neg),
.i_signal          (i_PWRGD_P12V_1_STBY),
.o_signal_latch    (w_P12V_1_STBY_latch),
.o_fault_n         (w_P12V_1_STBY_fault)
);
/////////////////////////////////////5st Bit////////////////////////////////////// //
Pwr_Error_Latch#(  
.EDGE              (1'b0),                            //Falling edge
.EN_JUDGE          (1'b1),                            //To judge if there is power en
.EDGE_LATCH_EN     (1'b1),                            //Enable signal edge latch
.EXT_LATCH_EN      (1'b1)                             //Enable external signal latch
)Pwr_Error_Latch_B2b5
(
.i_clk             (i_clk),
.i_rst_n           (i_rst_n),

.i_clr_flag        (i_clr_flag),
.i_PWR_EN          (i_PWRGD_PS_PWROK & i_PWRGD_P12V_0_STBY & i_PWRGD_P12V_1_STBY & (~i_fault_int_ign)),       //To judge power en or power good;
.i_latch_flag      (w_fault_all_neg),
.i_signal          (i_PWRGD_P5V_STBY),
.o_signal_latch    (w_P5V_STBY_latch),
.o_fault_n         (w_P5V_STBY_fault)
);
/////////////////////////////////////4st Bit////////////////////////////////////// //
Pwr_Error_Latch#(  
.EDGE              (1'b0),                            //Falling edge
.EN_JUDGE          (1'b1),                            //To judge if there is power en
.EDGE_LATCH_EN     (1'b1),                            //Enable signal edge latch
.EXT_LATCH_EN      (1'b1)                             //Enable external signal latch
)Pwr_Error_Latch_B2b4
(
.i_clk             (i_clk),
.i_rst_n           (i_rst_n),

.i_clr_flag        (i_clr_flag),
.i_PWR_EN          (i_PWRGD_PS_PWROK & i_PWRGD_P12V_0_STBY & i_PWRGD_P12V_1_STBY & i_PWRGD_P5V_STBY & (~i_fault_int_ign)),       //To judge power en or power good;
.i_latch_flag      (w_fault_all_neg),
.i_signal          (i_PWRGD_P3V3_STBY),
.o_signal_latch    (w_P3V3_STBY_latch),
.o_fault_n         (w_P3V3_STBY_fault)
);
/////////////////////////////////////3~0st Bit///////////////////////////////// //
genvar iB2;
generate
    for (iB2=0; iB2<4; iB2=iB2+1)
    begin : Byte2
    Pwr_Error_Latch#(  
    .EDGE                    (1'b0),                           //Falling edge
    .EN_JUDGE                (1'b1),                           //To judge if there is power en
    .EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
    .EXT_LATCH_EN            (1'b1)                            //Enable external signal latch
    )Pwr_Error_Latch_B2
    (
    .i_clk                   (i_clk),
    .i_rst_n                 (i_rst_n),
    
    .i_clr_flag              (i_clr_flag),
    .i_PWR_EN                (w_BMC_PW_EN[iB2] & w_aux_ok & (~i_fault_int_ign)),       //To judge power en or power good;
    .i_latch_flag            (w_fault_all_neg),
    .i_signal                (w_BMC_PW_GD[iB2]),
    .o_signal_latch          (w_BMC_PW_latch[iB2]),
    .o_fault_n               (w_BMC_PW_fault[iB2])
    );
	 
    end
endgenerate

//////////////////////////////////////Byte3/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

///////////////////////////////////////7st Bit//////////////////////////////////// //
Pwr_Error_Latch#(  
.EDGE                    (1'b0),                           //Falling edge
.EN_JUDGE                (1'b1),                           //To judge if there is power en
.EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
.EXT_LATCH_EN            (1'b1)                            //Enable external signal latch
)Pwr_Error_Latch_B3b7
(
.i_clk                   (i_clk),
.i_rst_n                 (i_rst_n),

.i_clr_flag              (i_clr_flag),
.i_PWR_EN                (i_PWRGD_P1V2_STBY & w_aux_ok & (~i_fault_int_ign)),       //To judge power en or power good;
.i_latch_flag            (w_fault_all_neg),
.i_signal                (i_PWRGD_P1V0_BMC_STBY),
.o_signal_latch          (w_PWRGD_P1V0_BMC_STBY_latch),
.o_fault_n               (w_PWRGD_P1V0_BMC_STBY_fault)
);
/////////////////////////////////////6~5st Bit///////////////////////////////// //
genvar iB3;
generate
    for (iB3=0; iB3<2; iB3=iB3+1)
    begin : Byte3
    Pwr_Error_Latch#(  
    .EDGE                    (1'b0),                           //Falling edge
    .EN_JUDGE                (1'b1),                           //To judge if there is power en
    .EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
    .EXT_LATCH_EN            (1'b1)                            //Enable external signal latch
    )Pwr_Error_Latch_B3
    (
    .i_clk                   (i_clk),
    .i_rst_n                 (i_rst_n),
    
    .i_clr_flag              (i_clr_flag),
    .i_PWR_EN                (w_PCH_PW_EN[iB3] & w_aux_ok & (~i_fault_int_ign)),       //To judge power en or power good;
    .i_latch_flag            (w_fault_all_neg),
    .i_signal                (w_PCH_PW_GD[iB3]),
    .o_signal_latch          (w_PCH_PW_latch[iB3]),
    .o_fault_n               (w_PCH_PW_fault[iB3])
    );
    end
endgenerate

////////////////////////////////////4~1st Bit///////////////////////////////////// //
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_RST_RSMRST_N             <= i_RST_RSMRST_N;
        r_BMC_SRST_N               <= i_BMC_SRST_N;
        r_PWRGD_DSW_PWROK          <= i_PWRGD_DSW_PWROK;
        r_FM_SLP_SUS_RSM_RST_N     <= i_FM_SLP_SUS_RSM_RST_N;
    end
    else if(o_pwr_err_int)
    begin
        r_RST_RSMRST_N             <= r_RST_RSMRST_N;
        r_BMC_SRST_N               <= r_BMC_SRST_N;
        r_PWRGD_DSW_PWROK          <= r_PWRGD_DSW_PWROK;
        r_FM_SLP_SUS_RSM_RST_N     <= r_FM_SLP_SUS_RSM_RST_N;
    end
    else
    begin
        r_RST_RSMRST_N             <= i_RST_RSMRST_N;
        r_BMC_SRST_N               <= i_BMC_SRST_N;
        r_PWRGD_DSW_PWROK          <= i_PWRGD_DSW_PWROK;
        r_FM_SLP_SUS_RSM_RST_N     <= i_FM_SLP_SUS_RSM_RST_N;
    end
end
//////////////////////////////////////Byte4/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

////////////////////////////////////7~4st Bit///////////////////////////////////// //
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_FM_SLPS4_N      <= i_FM_SLPS4_N;
        r_FM_SLPS3_N      <= i_FM_SLPS3_N;
        r_PWRGD_PS0_PWROK <= i_PWRGD_PS0_PWROK;
        r_PWRGD_PS1_PWROK <= i_PWRGD_PS1_PWROK;
        r_PWRGD_PS2_PWROK <= i_PWRGD_PS2_PWROK;
        r_PWRGD_PS3_PWROK <= i_PWRGD_PS3_PWROK;
        r_PWRGD_PS4_PWROK <= i_PWRGD_PS4_PWROK;
        r_PWRGD_PS5_PWROK <= i_PWRGD_PS5_PWROK;
    end
    else if(o_pwr_err_int)
    begin
        r_FM_SLPS4_N      <= r_FM_SLPS4_N;
        r_FM_SLPS3_N      <= r_FM_SLPS3_N;
        r_PWRGD_PS0_PWROK <= r_PWRGD_PS0_PWROK;
        r_PWRGD_PS1_PWROK <= r_PWRGD_PS1_PWROK;
        r_PWRGD_PS2_PWROK <= r_PWRGD_PS2_PWROK;
        r_PWRGD_PS3_PWROK <= r_PWRGD_PS3_PWROK;
        r_PWRGD_PS4_PWROK <= r_PWRGD_PS4_PWROK;
        r_PWRGD_PS5_PWROK <= r_PWRGD_PS5_PWROK;
    end
    else
    begin
        r_FM_SLPS4_N      <= i_FM_SLPS4_N;
        r_FM_SLPS3_N      <= i_FM_SLPS3_N;
        r_PWRGD_PS0_PWROK <= i_PWRGD_PS0_PWROK;
        r_PWRGD_PS1_PWROK <= i_PWRGD_PS1_PWROK;
        r_PWRGD_PS2_PWROK <= i_PWRGD_PS2_PWROK;
        r_PWRGD_PS3_PWROK <= i_PWRGD_PS3_PWROK;
        r_PWRGD_PS4_PWROK <= i_PWRGD_PS4_PWROK;
        r_PWRGD_PS5_PWROK <= i_PWRGD_PS5_PWROK;
    end
end
//////////////////////////////////////Byte5/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~1st Bit///////////////////////////////// //
genvar iB5;
generate
    for (iB5=0; iB5<8; iB5=iB5+1)
    begin : Byte5
    Pwr_Error_Latch#(  
    .EDGE                    (1'b0),                           //Falling edge
    .EN_JUDGE                (1'b1),                           //To judge if there is power en
    .EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
    .EXT_LATCH_EN            (1'b1)                            //Enable external signal latch
    )Pwr_Error_Latch_B5
    (
    .i_clk                   (i_clk),
    .i_rst_n                 (i_rst_n),
    
    .i_clr_flag              (i_clr_flag),
    .i_PWR_EN                (w_Byte5_PW_EN[iB5] & w_aux_ok & (~i_fault_int_ign)),       //To judge power en or power good;
    .i_latch_flag            (w_fault_all_neg),
    .i_signal                (w_Byte5_PW_GD[iB5]),
    .o_signal_latch          (w_Byte5_PW_latch[iB5]),
    .o_fault_n               (w_Byte5_PW_fault[iB5])
    );
    end
endgenerate
//////////////////////////////////////Byte6/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~0st Bit////////////////////////////////////// //
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_PWRGD_DRAMPWRGD_CPU0_AB <= i_PWRGD_DRAMPWRGD_CPU0_AB;
        r_PWRGD_DRAMPWRGD_CPU0_CD <= i_PWRGD_DRAMPWRGD_CPU0_CD;
        r_PWRGD_DRAMPWRGD_CPU0_EF <= i_PWRGD_DRAMPWRGD_CPU0_EF;
        r_PWRGD_DRAMPWRGD_CPU0_GH <= i_PWRGD_DRAMPWRGD_CPU0_GH;
        r_PWRGD_DRAMPWRGD_CPU1_AB <= i_PWRGD_DRAMPWRGD_CPU1_AB;
        r_PWRGD_DRAMPWRGD_CPU1_CD <= i_PWRGD_DRAMPWRGD_CPU1_CD;
        r_PWRGD_DRAMPWRGD_CPU1_EF <= i_PWRGD_DRAMPWRGD_CPU1_EF;
        r_PWRGD_DRAMPWRGD_CPU1_GH <= i_PWRGD_DRAMPWRGD_CPU1_GH;
    end
    else if(o_pwr_err_int)
    begin
        r_PWRGD_DRAMPWRGD_CPU0_AB <= r_PWRGD_DRAMPWRGD_CPU0_AB;
        r_PWRGD_DRAMPWRGD_CPU0_CD <= r_PWRGD_DRAMPWRGD_CPU0_CD;
        r_PWRGD_DRAMPWRGD_CPU0_EF <= r_PWRGD_DRAMPWRGD_CPU0_EF;
        r_PWRGD_DRAMPWRGD_CPU0_GH <= r_PWRGD_DRAMPWRGD_CPU0_GH;
        r_PWRGD_DRAMPWRGD_CPU1_AB <= r_PWRGD_DRAMPWRGD_CPU1_AB;
        r_PWRGD_DRAMPWRGD_CPU1_CD <= r_PWRGD_DRAMPWRGD_CPU1_CD;
        r_PWRGD_DRAMPWRGD_CPU1_EF <= r_PWRGD_DRAMPWRGD_CPU1_EF;
        r_PWRGD_DRAMPWRGD_CPU1_GH <= r_PWRGD_DRAMPWRGD_CPU1_GH;
    end
    else
    begin
        r_PWRGD_DRAMPWRGD_CPU0_AB <= i_PWRGD_DRAMPWRGD_CPU0_AB;
        r_PWRGD_DRAMPWRGD_CPU0_CD <= i_PWRGD_DRAMPWRGD_CPU0_CD;
        r_PWRGD_DRAMPWRGD_CPU0_EF <= i_PWRGD_DRAMPWRGD_CPU0_EF;
        r_PWRGD_DRAMPWRGD_CPU0_GH <= i_PWRGD_DRAMPWRGD_CPU0_GH;
        r_PWRGD_DRAMPWRGD_CPU1_AB <= i_PWRGD_DRAMPWRGD_CPU1_AB;
        r_PWRGD_DRAMPWRGD_CPU1_CD <= i_PWRGD_DRAMPWRGD_CPU1_CD;
        r_PWRGD_DRAMPWRGD_CPU1_EF <= i_PWRGD_DRAMPWRGD_CPU1_EF;
        r_PWRGD_DRAMPWRGD_CPU1_GH <= i_PWRGD_DRAMPWRGD_CPU1_GH;
    end
end
//////////////////////////////////////Byte7/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~0st Bit////////////////////////////////////// //
genvar iB7;
generate
    for (iB7=0; iB7<8; iB7=iB7+1)
    begin : Byte7
    Pwr_Error_Latch#(  
    .EDGE                    (1'b0),                           //Falling edge
    .EN_JUDGE                (1'b1),                           //To judge if there is power en
    .EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
    .EXT_LATCH_EN            (1'b1)                             //Enable external signal latch
    )Pwr_Error_Latch_B7
    (
    .i_clk                   (i_clk),
    .i_rst_n                 (i_rst_n),

    .i_clr_flag              (i_clr_flag),
    .i_PWR_EN                (w_Byte7_PW_EN[iB7] & w_aux_ok & (~i_adr_sel) & (~i_fault_int_ign)),       //To judge power en or power good;
    .i_latch_flag            (w_fault_all_neg),
    .i_signal                (w_Byte7_PW_GD[iB7]),
    .o_signal_latch          (w_Byte7_PW_latch[iB7]),
    .o_fault_n               (w_Byte7_PW_fault[iB7])
    );
    end
endgenerate
//////////////////////////////////////Byte8/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~0st Bit////////////////////////////////////// //
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_M_AB_CPU0_RESET_N <= i_M_AB_CPU0_RESET_N;
        r_M_CD_CPU0_RESET_N <= i_M_CD_CPU0_RESET_N;
        r_M_EF_CPU0_RESET_N <= i_M_EF_CPU0_RESET_N;
        r_M_GH_CPU0_RESET_N <= i_M_GH_CPU0_RESET_N;
        r_M_AB_CPU1_RESET_N <= i_M_AB_CPU1_RESET_N;
        r_M_CD_CPU1_RESET_N <= i_M_CD_CPU1_RESET_N;
        r_M_EF_CPU1_RESET_N <= i_M_EF_CPU1_RESET_N;
        r_M_GH_CPU1_RESET_N <= i_M_GH_CPU1_RESET_N;
    end
    else if(o_pwr_err_int)
    begin
        r_M_AB_CPU0_RESET_N <= r_M_AB_CPU0_RESET_N;
        r_M_CD_CPU0_RESET_N <= r_M_CD_CPU0_RESET_N;
        r_M_EF_CPU0_RESET_N <= r_M_EF_CPU0_RESET_N;
        r_M_GH_CPU0_RESET_N <= r_M_GH_CPU0_RESET_N;
        r_M_AB_CPU1_RESET_N <= r_M_AB_CPU1_RESET_N;
        r_M_CD_CPU1_RESET_N <= r_M_CD_CPU1_RESET_N;
        r_M_EF_CPU1_RESET_N <= r_M_EF_CPU1_RESET_N;
        r_M_GH_CPU1_RESET_N <= r_M_GH_CPU1_RESET_N;
    end
    else
    begin
        r_M_AB_CPU0_RESET_N <= i_M_AB_CPU0_RESET_N;
        r_M_CD_CPU0_RESET_N <= i_M_CD_CPU0_RESET_N;
        r_M_EF_CPU0_RESET_N <= i_M_EF_CPU0_RESET_N;
        r_M_GH_CPU0_RESET_N <= i_M_GH_CPU0_RESET_N;
        r_M_AB_CPU1_RESET_N <= i_M_AB_CPU1_RESET_N;
        r_M_CD_CPU1_RESET_N <= i_M_CD_CPU1_RESET_N;
        r_M_EF_CPU1_RESET_N <= i_M_EF_CPU1_RESET_N;
        r_M_GH_CPU1_RESET_N <= i_M_GH_CPU1_RESET_N;
    end
end
//////////////////////////////////////Byte9/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~0st Bit////////////////////////////////////// //
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_M_AB_CPU0_FPGA_RESET_N <= i_M_AB_CPU0_FPGA_RESET_N;
        r_M_CD_CPU0_FPGA_RESET_N <= i_M_CD_CPU0_FPGA_RESET_N;
        r_M_EF_CPU0_FPGA_RESET_N <= i_M_EF_CPU0_FPGA_RESET_N;
        r_M_GH_CPU0_FPGA_RESET_N <= i_M_GH_CPU0_FPGA_RESET_N;
        r_M_AB_CPU1_FPGA_RESET_N <= i_M_AB_CPU1_FPGA_RESET_N;
        r_M_CD_CPU1_FPGA_RESET_N <= i_M_CD_CPU1_FPGA_RESET_N;
        r_M_EF_CPU1_FPGA_RESET_N <= i_M_EF_CPU1_FPGA_RESET_N;
        r_M_GH_CPU1_FPGA_RESET_N <= i_M_GH_CPU1_FPGA_RESET_N;
    end
    else if(o_pwr_err_int)
    begin
        r_M_AB_CPU0_FPGA_RESET_N <= r_M_AB_CPU0_FPGA_RESET_N;
        r_M_CD_CPU0_FPGA_RESET_N <= r_M_CD_CPU0_FPGA_RESET_N;
        r_M_EF_CPU0_FPGA_RESET_N <= r_M_EF_CPU0_FPGA_RESET_N;
        r_M_GH_CPU0_FPGA_RESET_N <= r_M_GH_CPU0_FPGA_RESET_N;
        r_M_AB_CPU1_FPGA_RESET_N <= r_M_AB_CPU1_FPGA_RESET_N;
        r_M_CD_CPU1_FPGA_RESET_N <= r_M_CD_CPU1_FPGA_RESET_N;
        r_M_EF_CPU1_FPGA_RESET_N <= r_M_EF_CPU1_FPGA_RESET_N;
        r_M_GH_CPU1_FPGA_RESET_N <= r_M_GH_CPU1_FPGA_RESET_N;
    end
    else
    begin
        r_M_AB_CPU0_FPGA_RESET_N <= i_M_AB_CPU0_FPGA_RESET_N;
        r_M_CD_CPU0_FPGA_RESET_N <= i_M_CD_CPU0_FPGA_RESET_N;
        r_M_EF_CPU0_FPGA_RESET_N <= i_M_EF_CPU0_FPGA_RESET_N;
        r_M_GH_CPU0_FPGA_RESET_N <= i_M_GH_CPU0_FPGA_RESET_N;
        r_M_AB_CPU1_FPGA_RESET_N <= i_M_AB_CPU1_FPGA_RESET_N;
        r_M_CD_CPU1_FPGA_RESET_N <= i_M_CD_CPU1_FPGA_RESET_N;
        r_M_EF_CPU1_FPGA_RESET_N <= i_M_EF_CPU1_FPGA_RESET_N;
        r_M_GH_CPU1_FPGA_RESET_N <= i_M_GH_CPU1_FPGA_RESET_N;
    end
end
//////////////////////////////////////Byte10////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~1st Bit///////////////////////////////// //
genvar iB10;
generate
    for (iB10=0; iB10<7; iB10=iB10+1)
    begin : Byte10
    Pwr_Error_Latch#(  
    .EDGE                    (1'b0),                           //Falling edge
    .EN_JUDGE                (1'b1),                           //To judge if there is power en
    .EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
    .EXT_LATCH_EN            (1'b1)                            //Enable external signal latch
    )Pwr_Error_Latch_B10
    (
    .i_clk                   (i_clk),
    .i_rst_n                 (i_rst_n),
    
    .i_clr_flag              (i_clr_flag),
    .i_PWR_EN                (w_Byte10_PW_EN[iB10] & w_aux_ok & i_cpu_pwr_en & (~i_fault_int_ign)),       //To judge power en or power good;
    .i_latch_flag            (w_fault_all_neg),
    .i_signal                (w_Byte10_PW_GD[iB10]),
    .o_signal_latch          (w_Byte10_PW_latch[iB10]),
    .o_fault_n               (w_Byte10_PW_fault[iB10])
    );
    end
endgenerate
//////////////////////////////////////Byte11/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~1st Bit///////////////////////////////// //
genvar iB11;
generate
    for (iB11=0; iB11<7; iB11=iB11+1)
    begin : Byte12
    Pwr_Error_Latch#(  
    .EDGE                    (1'b0),                           //Falling edge
    .EN_JUDGE                (1'b1),                           //To judge if there is power en
    .EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
    .EXT_LATCH_EN            (1'b1)                            //Enable external signal latch
    )Pwr_Error_Latch_B12
    (
    .i_clk                   (i_clk),
    .i_rst_n                 (i_rst_n),
    
    .i_clr_flag              (i_clr_flag),
    .i_PWR_EN                (w_Byte11_PW_EN[iB11] & w_aux_ok & i_cpu_pwr_en & (~i_fault_int_ign)),       //To judge power en or power good;
    .i_latch_flag            (w_fault_all_neg),
    .i_signal                (w_Byte11_PW_GD[iB11]),
    .o_signal_latch          (w_Byte11_PW_latch[iB11]),
    .o_fault_n               (w_Byte11_PW_fault[iB11])
    );
    end
endgenerate
///////////////////////////////////Byte12~Byte13/////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_PWRGD_PLT_AUX_CPU0  <= i_PWRGD_PLT_AUX_CPU0;
        r_PWRGD_PLT_AUX_CPU1  <= i_PWRGD_PLT_AUX_CPU1;
        r_PWRGD_S0_PWROK_CPU0 <= i_PWRGD_S0_PWROK_CPU0;
        r_PWRGD_S0_PWROK_CPU1 <= i_PWRGD_S0_PWROK_CPU1;
        r_PWRGD_PCH_PWROK     <= i_PWRGD_PCH_PWROK;
        r_PWRGD_SYS_PWROK     <= i_PWRGD_SYS_PWROK;
        r_PWRGD_CPU0_LVC3     <= i_PWRGD_CPU0_LVC3;
        r_PWRGD_CPU1_LVC3     <= i_PWRGD_CPU1_LVC3;

        r_PWRGD_CPUPWRGD      <= i_PWRGD_CPUPWRGD;
        r_RST_PLTRST_N        <= i_RST_PLTRST_N;
    end
    else if(o_pwr_err_int)
    begin
        r_PWRGD_PLT_AUX_CPU0  <= r_PWRGD_PLT_AUX_CPU0;
        r_PWRGD_PLT_AUX_CPU1  <= r_PWRGD_PLT_AUX_CPU1;
        r_PWRGD_S0_PWROK_CPU0 <= r_PWRGD_S0_PWROK_CPU0;
        r_PWRGD_S0_PWROK_CPU1 <= r_PWRGD_S0_PWROK_CPU1;
        r_PWRGD_PCH_PWROK     <= r_PWRGD_PCH_PWROK;
        r_PWRGD_SYS_PWROK     <= r_PWRGD_SYS_PWROK;
        r_PWRGD_CPU0_LVC3     <= r_PWRGD_CPU0_LVC3;
        r_PWRGD_CPU1_LVC3     <= r_PWRGD_CPU1_LVC3;

        r_PWRGD_CPUPWRGD      <= r_PWRGD_CPUPWRGD;
        r_RST_PLTRST_N        <= r_RST_PLTRST_N;
    end
    else
    begin
        r_PWRGD_PLT_AUX_CPU0  <= i_PWRGD_PLT_AUX_CPU0;
        r_PWRGD_PLT_AUX_CPU1  <= i_PWRGD_PLT_AUX_CPU1;
        r_PWRGD_S0_PWROK_CPU0 <= i_PWRGD_S0_PWROK_CPU0;
        r_PWRGD_S0_PWROK_CPU1 <= i_PWRGD_S0_PWROK_CPU1;
        r_PWRGD_PCH_PWROK     <= i_PWRGD_PCH_PWROK;
        r_PWRGD_SYS_PWROK     <= i_PWRGD_SYS_PWROK;
        r_PWRGD_CPU0_LVC3     <= i_PWRGD_CPU0_LVC3;
        r_PWRGD_CPU1_LVC3     <= i_PWRGD_CPU1_LVC3;

        r_PWRGD_CPUPWRGD      <= i_PWRGD_CPUPWRGD;
        r_RST_PLTRST_N        <= i_RST_PLTRST_N;
    end
end
//////////////////////////////////////Byte14/////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //

/////////////////////////////////////7~2st Bit///////////////////////////////// //
genvar iB14;
generate
    for (iB14=0; iB14<6; iB14=iB14+1)
    begin : Byte14
    Pwr_Error_Latch#(  
    .EDGE                    (1'b0),                           //Falling edge
    .EN_JUDGE                (1'b1),                           //To judge if there is power en
    .EDGE_LATCH_EN           (1'b1),                           //Enable signal edge latch
    .EXT_LATCH_EN            (1'b1)                            //Enable external signal latch
    )Pwr_Error_Latch_B14
    (
    .i_clk                   (i_clk),
    .i_rst_n                 (i_rst_n),
    
    .i_clr_flag              (i_clr_flag),
    .i_PWR_EN                (w_Byte14_PW_EN[iB14] & w_aux_ok & (~i_fault_int_ign)),       //To judge power en or power good;
    .i_latch_flag            (w_fault_all_neg),
    .i_signal                (w_Byte14_PW_GD[iB14]),
    .o_signal_latch          (w_Byte14_PW_latch[iB14]),
    .o_fault_n               (w_Byte14_PW_fault[iB14])
    );
    end
endgenerate
//////////////////////////////////Byte18~Byte20/////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_dbg_mst_st   <= i_dbg_mst_st;
        r_dbg_pch_st   <= i_dbg_pch_st;
        r_dbg_cpu0_st  <= i_dbg_cpu0_st;
        r_dbg_cpu1_st  <= i_dbg_cpu1_st;
    end
    else if(o_delay_err_int)
    begin
        r_dbg_mst_st   <= r_dbg_mst_st;
        r_dbg_pch_st   <= r_dbg_pch_st;
        r_dbg_cpu0_st  <= r_dbg_cpu0_st;
        r_dbg_cpu1_st  <= r_dbg_cpu1_st;
    end
    else
    begin
        r_dbg_mst_st   <= i_dbg_mst_st;
        r_dbg_pch_st   <= i_dbg_pch_st;
        r_dbg_cpu0_st  <= i_dbg_cpu0_st;
        r_dbg_cpu1_st  <= i_dbg_cpu1_st;
    end
end
////////////////////////////////////////////////////////////////////////////////// //
////////////////////////////////////////////////////////////////////////////////// //
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_power_fault <= 1'b0;
    else if(w_power_fault_neg && ~i_fault_int_ign)
        r_power_fault <= 1'b1;
    else
        r_power_fault <= r_power_fault;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_aux_int <= 1'b0;
    else if(w_fault_all_aux_neg && ~i_fault_int_ign)
        r_aux_int <= 1'b1;
    else
        r_aux_int <= r_aux_int;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_core_int <= 1'b0;
    else if(w_fault_all_core_neg && ~i_fault_int_ign)
        r_core_int <= 1'b1;
    else
        r_core_int <= r_core_int;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_PWRGD_DOWN <= 1'b0;
    else if(i_dbg_mst_st == 4'd3)                    //The last state of power off sequence(ST_OFF state)
        r_PWRGD_DOWN <= 1'b0;
    else if(w_FM_SLPS3_neg)
        r_PWRGD_DOWN <= 1'b1;
    else
        r_PWRGD_DOWN <= r_PWRGD_DOWN;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_power_err_flag <= 3'b111;
    else if(i_clr_flag)
        r_power_err_flag <= 3'b111;
    else if(w_fault_all_neg && i_RST_PLTRST_N)                      //S0 Fault
        r_power_err_flag <= 3'b000;
    else if(w_fault_all_neg && r_PWRGD_DOWN)                        //S0 to S5 Fault
        r_power_err_flag <= 3'b010;
    else if(w_fault_all_neg && i_FM_SLPS3_N)                        //S5 to S0 Fault
        r_power_err_flag <= 3'b001;
    else if(w_fault_all_neg && i_PWRGD_PS_PWROK)                    //S5 Fault
        r_power_err_flag <= 3'b011;
    else
        r_power_err_flag <= r_power_err_flag;
end

//////////////////////////////////////////////////////////////////////////////
//Add power on delay error due to the frame has been changed on 20190701
//////////////////////////////////////////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_pwr_fail_flag <= 1'b0;
    else if(w_fault_all_neg)
        r_pwr_fail_flag <= 1'b1;
    else
        r_pwr_fail_flag <= r_pwr_fail_flag;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_delay_AC <= 9'd0;
    else if(r_pwr_fail_flag || i_PWRGD_P1V05_PCH_STBY || i_clr_flag || i_delay_int_ign)
        r_cnt_delay_AC <= 9'd0;
    else if(r_cnt_delay_AC >= T10S)
        r_cnt_delay_AC <= T10S;
    else if(r_cnt_delay_AC < T10S && w_20mSEC_pos && (~i_PWRGD_P1V05_PCH_STBY) && (~r_pwr_fail_flag))
        r_cnt_delay_AC <= r_cnt_delay_AC + 1'b1;
    else
        r_cnt_delay_AC <= r_cnt_delay_AC;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_cnt_delay_DC <= 8'd0;
    else if(~i_FM_SLPS3_N | r_pwr_fail_flag | i_RST_PLTRST_N || (i_clr_flag && i_FM_SLPS3_N && (r_cnt_delay_DC < T5S)) || i_delay_int_ign)
        r_cnt_delay_DC <= 8'd0;
    else if(r_cnt_delay_DC >= T5S)  //8'd25 Sim
        r_cnt_delay_DC <= T5S;
    else if(r_cnt_delay_DC < T5S && w_20mSEC_pos && i_FM_SLPS3_N && (~i_RST_PLTRST_N) && (~r_pwr_fail_flag))
        r_cnt_delay_DC <= r_cnt_delay_DC + 1'b1;
    else
        r_cnt_delay_DC <= r_cnt_delay_DC;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_AC_delay <= 1'b0;
    else if(i_clr_flag && i_PWRGD_P1V05_PCH_STBY)
        r_AC_delay <= 1'b0;
    else if(~i_PWRGD_P1V05_PCH_STBY && (r_cnt_delay_AC == T10S))
        r_AC_delay <= 1'b1;
    else
        r_AC_delay <= r_AC_delay;
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_DC_delay <= 1'b0;
    else if(i_clr_flag && (i_RST_PLTRST_N || (~i_FM_SLPS3_N) || (i_FM_SLPS3_N && (r_cnt_delay_DC < T5S))))
        r_DC_delay <= 1'b0;
    else if(~i_RST_PLTRST_N && (r_cnt_delay_DC == T5S))
        r_DC_delay <= 1'b1;
    else
        r_DC_delay <= r_DC_delay;
end
//////////////////////////////////////////////////////////////////////////////////
// Submodule                                                                      
//////////////////////////////////////////////////////////////////////////////////
Edge_Detect Edge_Detect_U0(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (w_fault_all),

.o_signal_pos     (),
.o_signal_neg     (w_fault_all_neg),
.o_signal_invert  ()
);

Edge_Detect Edge_Detect_U1(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (w_fault_all_aux),

.o_signal_pos     (),
.o_signal_neg     (w_fault_all_aux_neg),
.o_signal_invert  ()
);

Edge_Detect Edge_Detect_U2(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (w_fault_all_core),

.o_signal_pos     (),
.o_signal_neg     (w_fault_all_core_neg),
.o_signal_invert  ()
);

Edge_Detect Edge_Detect_U3(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (i_FM_SLPS3_N),

.o_signal_pos     (),
.o_signal_neg     (w_FM_SLPS3_neg),
.o_signal_invert  ()
);

Edge_Detect Edge_Detect_U4(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (i_20mSEC),

.o_signal_pos     (w_20mSEC_pos),
.o_signal_neg     (),
.o_signal_invert  ()
);

Edge_Detect Edge_Detect_U5(
.i_clk            (i_clk),           //input Clk
.i_rst_n          (i_rst_n),         //Global rst,Active Low
.i_signal         (w_power_fault),

.o_signal_pos     (),
.o_signal_neg     (w_power_fault_neg),
.o_signal_invert  ()
);

endmodule
