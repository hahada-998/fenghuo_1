module cpu_thermtrip #(parameter NUM_CPU = 2)
(
input i_clk          ,
input i_reset        ,
 
input i_cpu_thermaltrip_clr                 , 
input i_any_pwr_fault_det                   ,
input i_st_steady_pwrok                     ,
input i_st_critical_fail                    ,
input i_st_disable_main_efuse               ,
input [NUM_CPU-1:0] i_cpu_thermtrip         ,
input [NUM_CPU-1:0] i_cpu_prsnt_n           ,
    
output[NUM_CPU-1:0] cpu_thermtrip_fault_det   
             


);
genvar i;
generate for (i = 0; i < NUM_CPU; i = i + 1) begin : _CPU_THERMTRIP_DETECT_BLOCK_
  fault_detectB_chklive #(.NUMBER_OF_VRM(1)) inst_cpu_thermtrip_fault_det (
    .clk              (i_clk                              ),
    .reset            (i_reset                            ),
    .vrm_enable       (~i_cpu_prsnt_n[i]                  ),  
    .vrm_pgood        (~i_cpu_thermtrip[i]                ),
    .vrm_chklive_en   (i_st_steady_pwrok                  ),
    .vrm_chklive_dis  (i_st_disable_main_efuse            ),
    .critical_fail    (i_st_critical_fail                 ),
    .fault_clear      (i_cpu_thermaltrip_clr              ),
    .lock             (i_any_pwr_fault_det                ),
    .any_vrm_fault    (                                   ),
    .vrm_fault        (cpu_thermtrip_fault_det[i]         )
  );
end
endgenerate



endmodule