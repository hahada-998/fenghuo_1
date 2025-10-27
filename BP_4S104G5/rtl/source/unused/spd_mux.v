//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd



module spd_mux (

input clk,
input pgd_aux_system,
input cpu_reset_l,
input step,
input cpu_spd_access,
output spd_sel,
output bmc_spd_access_en
);
	
  wire cpu_spd_access_negedge_delay;
  wire cpu_spd_access_n_negedge_delay;
	
  edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b1)) edge_delay_cpu_spd_access(
    .clk         (clk),
    .reset       (~pgd_aux_system),
    .cnt_size    (6'h32),
    .cnt_step    (step),
    .signal_in   (cpu_spd_access),
    .delay_output(cpu_spd_access_negedge_delay)
  );
  
    edge_delay #(.CNTR_NBITS(6), .DELAY_MODE(1'b1)) edge_delay_cpu_spd_access_n(
    .clk         (clk),
    .reset       (~pgd_aux_system),
    .cnt_size    (6'h32),
    .cnt_step    (step),
    .signal_in   (~cpu_spd_access),
    .delay_output(cpu_spd_access_n_negedge_delay)
  );
  
  assign bmc_spd_access_en = cpu_reset_l ? cpu_spd_access_negedge_delay : 1'b1;
  assign spd_sel = cpu_spd_access_n_negedge_delay;
  
  endmodule
		
		
		
