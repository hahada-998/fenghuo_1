`timescale 1ns / 1ps

module Power_FaultB 
(
input  i_clk,
input  i_rst_n,
input  i_1SEC,

input  i_clr_flag,

input  i_pgd_p3v3_stby       , //1
input  i_p3v3_stby_en        ,

input  i_pwrgd_p12v          , //2
input  i_p12v_en             ,

input  i_pwrgd_p5v_stby      , //3
input  i_p5v_stby_en         ,
input  i_pwrgd_p1v2_stby     , //4
input  i_p1v2_stby_en        ,
input  i_pwrgd_p1v8_stby     , //5
input  i_p1v8_stby_en        ,

input  i_cmu_pwr_en             ,
input  i_cmu_pg_p5v0_stby       ,  //6
input  i_cmu_pg_p3v3_stby       ,  //7
input  i_cmu_pg_p3v3_stby_rgm   ,  //8
input  i_cmu_pg_p2v5_stby       ,  //9
input  i_cmu_pg_p1v8_stby       ,  //10
input  i_cmu_pg_p1v2_stby       ,  //11
input  i_cmu_pg_p1v0_stby       ,  //12

input  i_pwrgd_pch_pvnn          , //13
input  i_pvnn_pch_en             ,
input  i_pwrgd_pch_p1v05         , //14
input  i_p1v05_pch_en            ,

input  i_pgd_p5v                 , //15
input  i_p5v_en                  ,

input  i_pwrgd_pvpp_hbm_cpu0         , //16
input  i_pvpp_hbm_cpu0_en            ,
input  i_pwrgd_pvccfa_ehv_cpu0       , //17
input  i_pvccfa_ehv_cpu0_en          ,
input  i_pwrgd_pvccfa_ehv_fivra_cpu0 , //18
input  i_pvccfa_ehv_fivra_cpu0_en    ,
input  i_pwrgd_pvccinfaon_cpu0       , //19
input  i_pvccinfaon_cpu0_en          ,
input  i_pwrgd_pvnn_main_cpu0        , //20
input  i_pvnn_main_cpu0_en           ,
input  i_pwrgd_pvccd_hv_cpu0         , //21
input  i_pvccd_hv_cpu0_en            ,
input  i_pwrgd_pvccin_cpu0           , //22
input  i_pvccin_cpu0_en              ,

// input  i_pwrgd_pvpp_hbm_cpu1         , //23
// input  i_pvpp_hbm_cpu1_en            ,
// input  i_pwrgd_pvccfa_ehv_cpu1       , //24
// input  i_pvccfa_ehv_cpu1_en          ,
// input  i_pwrgd_pvccfa_ehv_fivra_cpu1 , //25
// input  i_pvccfa_ehv_fivra_cpu1_en    ,
// input  i_pwrgd_pvccinfaon_cpu1       , //26
// input  i_pvccinfaon_cpu1_en          ,
// input  i_pwrgd_pvnn_main_cpu1        , //27
// input  i_pvnn_main_cpu1_en           ,
// input  i_pwrgd_pvccd_hv_cpu1         , //28
// input  i_pvccd_hv_cpu1_en            ,
// input  i_pwrgd_pvccin_cpu1           , //29
// input  i_pvccin_cpu1_en              ,

input  i_pvpp_hbm_cpu1_fault_det         ,
input  i_pvccfa_ehv_cpu1_fault_det       ,
input  i_pvccfa_ehv_fivra_cpu1_fault_det ,
input  i_pvccinfaon_cpu1_fault_det       ,
input  i_pvnn_main_cpu1_fault_det        ,
input  i_pvccd_hv_cpu1_fault_det         ,
input  i_pvccin_cpu1_fault_det           ,

input  i_cpu0Mem_ab_pwr_flt          , //30
input  i_cpu0Mem_cd_pwr_flt          , //31
input  i_cpu0Mem_ef_pwr_flt          , //32
input  i_cpu0Mem_gh_pwr_flt          , //33

input  i_cpu1Mem_ab_pwr_flt          , //34
input  i_cpu1Mem_cd_pwr_flt          , //35
input  i_cpu1Mem_ef_pwr_flt          , //36
input  i_cpu1Mem_gh_pwr_flt          , //37
output [7:0] o_pwr_flt_code              

);

reg  [7:0] r_timeout_code;



wire w_any_pwr_fault_det                   ;

wire w_p3v3_stby_fault_det                 ; //1
wire w_p12v_fault_det                      ; //2
wire w_p5v_stby_fault_det                  ; //3
wire w_p1v2_stby_fault_det                 ; //4
wire w_p1v8_stby_fault_det                 ; //5
wire w_cmu_p5v0_stby_fault_det             ; //6
wire w_cmu_p3v3_stby_fault_det             ; //7
wire w_cmu_p3v3_stby_rgm_fault_det         ; //8
wire w_cmu_p2v5_stby_fault_det             ; //9
wire w_cmu_p1v8_stby_fault_det             ; //10
wire w_cmu_p1v2_stby_fault_det             ; //11
wire w_cmu_p1v0_stby_fault_det             ; //12
wire w_pvnn_pch_fault_det                  ; //13
wire w_p1v05_pch_fault_det                 ; //14
wire w_p5v_fault_det                       ; //15
wire w_pvpp_hbm_cpu0_fault_det             ; //16
wire w_pvccfa_ehv_cpu0_fault_det           ; //17
wire w_pvccfa_ehv_fivra_cpu0_fault_det     ; //18
wire w_pvccinfaon_cpu0_fault_det           ; //19
wire w_pvnn_main_cpu0_fault_det            ; //20
wire w_pvccd_hv_cpu0_fault_det             ; //21
wire w_pvccin_cpu0_fault_det               ; //22
wire w_pvpp_hbm_cpu1_fault_det             ; //23
wire w_pvccfa_ehv_cpu1_fault_det           ; //24
wire w_pvccfa_ehv_fivra_cpu1_fault_det     ; //25
wire w_pvccinfaon_cpu1_fault_det           ; //26
wire w_pvnn_main_cpu1_fault_det            ; //27
wire w_pvccd_hv_cpu1_fault_det             ; //28
wire w_pvccin_cpu1_fault_det               ; //29



assign w_pvpp_hbm_cpu1_fault_det         = i_pvpp_hbm_cpu1_fault_det         ;
assign w_pvccfa_ehv_cpu1_fault_det       = i_pvccfa_ehv_cpu1_fault_det       ;
assign w_pvccfa_ehv_fivra_cpu1_fault_det = i_pvccfa_ehv_fivra_cpu1_fault_det ;
assign w_pvccinfaon_cpu1_fault_det       = i_pvccinfaon_cpu1_fault_det       ;
assign w_pvnn_main_cpu1_fault_det        = i_pvnn_main_cpu1_fault_det        ;
assign w_pvccd_hv_cpu1_fault_det         = i_pvccd_hv_cpu1_fault_det         ;
assign w_pvccin_cpu1_fault_det           = i_pvccin_cpu1_fault_det           ;



assign o_pwr_flt_code = r_timeout_code;

assign  w_any_pwr_fault_det   = w_p3v3_stby_fault_det                |  //1
                                w_p12v_fault_det                     |  //2
                                w_p5v_stby_fault_det                 |  //3
                                w_p1v2_stby_fault_det                |  //4
                                w_p1v8_stby_fault_det                |  //5
                                w_cmu_p5v0_stby_fault_det            |  //6
                                w_cmu_p3v3_stby_fault_det            |  //7
                                w_cmu_p3v3_stby_rgm_fault_det        |  //8
                                w_cmu_p2v5_stby_fault_det            |  //9
                                w_cmu_p1v8_stby_fault_det            |  //10
                                w_cmu_p1v2_stby_fault_det            |  //11
                                w_cmu_p1v0_stby_fault_det            |  //12
                                w_pvnn_pch_fault_det                 |  //13
                                w_p1v05_pch_fault_det                |  //14
                                w_p5v_fault_det                      |  //15
                                w_pvpp_hbm_cpu0_fault_det            |  //16
                                w_pvccfa_ehv_cpu0_fault_det          |  //17
                                w_pvccfa_ehv_fivra_cpu0_fault_det    |  //18
                                w_pvccinfaon_cpu0_fault_det          |  //19
                                w_pvnn_main_cpu0_fault_det           |  //20
                                w_pvccd_hv_cpu0_fault_det            |  //21
                                w_pvccin_cpu0_fault_det              |  //22
                                w_pvpp_hbm_cpu1_fault_det            |  //23
                                w_pvccfa_ehv_cpu1_fault_det          |  //24
                                w_pvccfa_ehv_fivra_cpu1_fault_det    |  //25
                                w_pvccinfaon_cpu1_fault_det          |  //26
                                w_pvnn_main_cpu1_fault_det           |  //27
                                w_pvccd_hv_cpu1_fault_det            |  //28
                                w_pvccin_cpu1_fault_det              |  //29
                                i_cpu0Mem_ab_pwr_flt                 |  //30
                                i_cpu0Mem_cd_pwr_flt                 |  //31
                                i_cpu0Mem_ef_pwr_flt                 |  //32
                                i_cpu0Mem_gh_pwr_flt                 |  //33
                                i_cpu1Mem_ab_pwr_flt                 |  //34
                                i_cpu1Mem_cd_pwr_flt                 |  //35
                                i_cpu1Mem_ef_pwr_flt                 |  //36
                                i_cpu1Mem_gh_pwr_flt                    //37
								;
								


//------------------------------------------------------------------------------
// p3v3_stby Fault detect                                    1
//------------------------------------------------------------------------------
wire w_p3v3_stby_en_check;

edge_delay #(.CNTR_NBITS(2)) p3v3_stby_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_p3v3_stby_en),
  .delay_output  (w_p3v3_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p3v3_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_p3v3_stby_en && w_p3v3_stby_en_check),	//in
  .vrm_pgood        (i_pgd_p3v3_stby),						//in
  .vrm_chklive_en   (w_p3v3_stby_en_check),				//in
  .vrm_chklive_dis  (~w_p3v3_stby_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_p3v3_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// p12v Fault detect                                           2
//------------------------------------------------------------------------------
wire w_p12v_en_check;

edge_delay #(.CNTR_NBITS(2)) p12v_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_p12v_en),
  .delay_output  (w_p12v_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p12v_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_p12v_en && w_p12v_en_check),	//in
  .vrm_pgood        (i_pwrgd_p12v),						//in
  .vrm_chklive_en   (w_p12v_en_check),				//in
  .vrm_chklive_dis  (~w_p12v_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_p12v_fault_det)				//out
);

//------------------------------------------------------------------------------
// p5v_stby Fault detect                                         3
//------------------------------------------------------------------------------
wire w_p5v_stby_en_check;

edge_delay #(.CNTR_NBITS(2)) p5v_stby_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_p5v_stby_en),
  .delay_output  (w_p5v_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p5v_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_p5v_stby_en && w_p5v_stby_en_check),	//in
  .vrm_pgood        (i_pwrgd_p5v_stby),						//in
  .vrm_chklive_en   (w_p5v_stby_en_check),				//in
  .vrm_chklive_dis  (~w_p5v_stby_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_p5v_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// p1v2_stby Fault detect                                         4
//------------------------------------------------------------------------------
wire w_p1v2_stby_en_check;

edge_delay #(.CNTR_NBITS(2)) p1v2_stby_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_p1v2_stby_en),
  .delay_output  (w_p1v2_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v2_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_p1v2_stby_en && w_p1v2_stby_en_check),	//in
  .vrm_pgood        (i_pwrgd_p1v2_stby),						//in
  .vrm_chklive_en   (w_p1v2_stby_en_check),				//in
  .vrm_chklive_dis  (~w_p1v2_stby_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_p1v2_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// p1v8_stby Fault detect                                         5
//------------------------------------------------------------------------------
wire w_p1v8_stby_en_check;

edge_delay #(.CNTR_NBITS(2)) p1v8_stby_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_p1v8_stby_en),
  .delay_output  (w_p1v8_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v8_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_p1v8_stby_en && w_p1v8_stby_en_check),	//in
  .vrm_pgood        (i_pwrgd_p1v8_stby),						//in
  .vrm_chklive_en   (w_p1v8_stby_en_check),				//in
  .vrm_chklive_dis  (~w_p1v8_stby_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_p1v8_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// cmu_p5v0_stby Fault detect                                         6
//------------------------------------------------------------------------------

wire w_cmu_pwr_en_check;  //2023-11-21 add for debug

edge_delay #(.CNTR_NBITS(3)) cmu_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (3'b101),
  .cnt_step      (i_1SEC),
  .signal_in     (i_cmu_pwr_en),
  .delay_output  (w_cmu_pwr_en_check)
);


fault_detectB_chklive #(.NUMBER_OF_VRM(1)) cmu_p5v0_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_cmu_pwr_en && w_cmu_pwr_en_check),	//in
  .vrm_pgood        (i_cmu_pg_p5v0_stby),						//in
  .vrm_chklive_en   (w_cmu_pwr_en_check),				//in
  .vrm_chklive_dis  (~w_cmu_pwr_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_cmu_p5v0_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// cmu_p3v3_stby Fault detect                                         7
//------------------------------------------------------------------------------
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) cmu_p3v3_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_cmu_pwr_en && w_cmu_pwr_en_check),	//in
  .vrm_pgood        (i_cmu_pg_p3v3_stby),						//in
  .vrm_chklive_en   (w_cmu_pwr_en_check),				//in
  .vrm_chklive_dis  (~w_cmu_pwr_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_cmu_p3v3_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// cmu_p3v3_stby_rgm Fault detect                                         8
//------------------------------------------------------------------------------
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) cmu_p3v3_stby_rgm_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_cmu_pwr_en && w_cmu_pwr_en_check),	//in
  .vrm_pgood        (i_cmu_pg_p3v3_stby_rgm),						//in
  .vrm_chklive_en   (w_cmu_pwr_en_check),				//in
  .vrm_chklive_dis  (~w_cmu_pwr_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_cmu_p3v3_stby_rgm_fault_det)				//out
);

//------------------------------------------------------------------------------
// cmu_p2v5_stby Fault detect                                             9
//------------------------------------------------------------------------------
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) cmu_p2v5_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_cmu_pwr_en && w_cmu_pwr_en_check),	//in
  .vrm_pgood        (i_cmu_pg_p2v5_stby),						//in
  .vrm_chklive_en   (w_cmu_pwr_en_check),				//in
  .vrm_chklive_dis  (~w_cmu_pwr_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_cmu_p2v5_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// cmu_p1v8_stby Fault detect                                             10
//------------------------------------------------------------------------------
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) cmu_p1v8_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_cmu_pwr_en && w_cmu_pwr_en_check),	//in
  .vrm_pgood        (i_cmu_pg_p1v8_stby),						//in
  .vrm_chklive_en   (w_cmu_pwr_en_check),				//in
  .vrm_chklive_dis  (~w_cmu_pwr_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_cmu_p1v8_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// cmu_p1v2_stby Fault detect                                             11
//------------------------------------------------------------------------------
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) cmu_p1v2_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_cmu_pwr_en && w_cmu_pwr_en_check),	//in
  .vrm_pgood        (i_cmu_pg_p1v2_stby),						//in
  .vrm_chklive_en   (w_cmu_pwr_en_check),				//in
  .vrm_chklive_dis  (~w_cmu_pwr_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_cmu_p1v2_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// cmu_p1v0_stby Fault detect                                             12
//------------------------------------------------------------------------------
fault_detectB_chklive #(.NUMBER_OF_VRM(1)) cmu_p1v0_stby_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_cmu_pwr_en && w_cmu_pwr_en_check),	//in
  .vrm_pgood        (i_cmu_pg_p1v0_stby),						//in
  .vrm_chklive_en   (w_cmu_pwr_en_check),				//in
  .vrm_chklive_dis  (~w_cmu_pwr_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_cmu_p1v0_stby_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvnn_pch Fault detect                                          13
//------------------------------------------------------------------------------
wire w_pvnn_pch_en_check;

edge_delay #(.CNTR_NBITS(2)) pvnn_pch_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvnn_pch_en),
  .delay_output  (w_pvnn_pch_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvnn_pch_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvnn_pch_en && w_pvnn_pch_en_check),	//in
  .vrm_pgood        (i_pwrgd_pch_pvnn),						//in
  .vrm_chklive_en   (w_pvnn_pch_en_check),				//in
  .vrm_chklive_dis  (~w_pvnn_pch_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvnn_pch_fault_det)				//out
);

//------------------------------------------------------------------------------
// p1v05_pch Fault detect                                          14
//------------------------------------------------------------------------------
wire w_p1v05_pch_en_check;

edge_delay #(.CNTR_NBITS(2)) p1v05_pch_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_p1v05_pch_en),
  .delay_output  (w_p1v05_pch_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v05_pch_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_p1v05_pch_en && w_p1v05_pch_en_check),	//in
  .vrm_pgood        (i_pwrgd_pch_p1v05),						//in
  .vrm_chklive_en   (w_p1v05_pch_en_check),				//in
  .vrm_chklive_dis  (~w_p1v05_pch_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_p1v05_pch_fault_det)				//out
);

//------------------------------------------------------------------------------
// p5v Fault detect                                              15
//------------------------------------------------------------------------------
wire w_p5v_en_check;

edge_delay #(.CNTR_NBITS(2)) p5v_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_p5v_en),
  .delay_output  (w_p5v_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p5v_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_p5v_en && w_p5v_en_check),	//in
  .vrm_pgood        (i_pgd_p5v),						//in
  .vrm_chklive_en   (w_p5v_en_check),				//in
  .vrm_chklive_dis  (~w_p5v_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_p5v_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvpp_hbm_cpu0 Fault detect                                              16
//------------------------------------------------------------------------------
wire w_pvpp_hbm_cpu0_en_check;

edge_delay #(.CNTR_NBITS(2)) pvpp_hbm_cpu0_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvpp_hbm_cpu0_en),
  .delay_output  (w_pvpp_hbm_cpu0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvpp_hbm_cpu0_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvpp_hbm_cpu0_en && w_pvpp_hbm_cpu0_en_check),	//in
  .vrm_pgood        (i_pwrgd_pvpp_hbm_cpu0),						//in
  .vrm_chklive_en   (w_pvpp_hbm_cpu0_en_check),				//in
  .vrm_chklive_dis  (~w_pvpp_hbm_cpu0_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvpp_hbm_cpu0_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvccfa_ehv_cpu0 Fault detect                                     17
//------------------------------------------------------------------------------
wire w_pvccfa_ehv_cpu0_en_check;

edge_delay #(.CNTR_NBITS(2)) pvccfa_ehv_cpu0_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvccfa_ehv_cpu0_en),
  .delay_output  (w_pvccfa_ehv_cpu0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccfa_ehv_cpu0_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvccfa_ehv_cpu0_en && w_pvccfa_ehv_cpu0_en_check),	//in
  .vrm_pgood        (i_pwrgd_pvccfa_ehv_cpu0),						//in
  .vrm_chklive_en   (w_pvccfa_ehv_cpu0_en_check),				//in
  .vrm_chklive_dis  (~w_pvccfa_ehv_cpu0_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvccfa_ehv_cpu0_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvccfa_ehv_fivra_cpu0 Fault detect                               18
//------------------------------------------------------------------------------
wire w_pvccfa_ehv_fivra_cpu0_en_check;

edge_delay #(.CNTR_NBITS(2)) pvccfa_ehv_fivra_cpu0_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvccfa_ehv_fivra_cpu0_en),
  .delay_output  (w_pvccfa_ehv_fivra_cpu0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccfa_ehv_fivra_cpu0_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvccfa_ehv_fivra_cpu0_en && w_pvccfa_ehv_fivra_cpu0_en_check),	//in
  .vrm_pgood        (i_pwrgd_pvccfa_ehv_fivra_cpu0),						//in
  .vrm_chklive_en   (w_pvccfa_ehv_fivra_cpu0_en_check),				//in
  .vrm_chklive_dis  (~w_pvccfa_ehv_fivra_cpu0_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvccfa_ehv_fivra_cpu0_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvccinfaon_cpu0 Fault detect                               19
//------------------------------------------------------------------------------
wire w_pvccinfaon_cpu0_en_check;

edge_delay #(.CNTR_NBITS(2)) pvccinfaon_cpu0_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvccinfaon_cpu0_en),
  .delay_output  (w_pvccinfaon_cpu0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccinfaon_cpu0_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvccinfaon_cpu0_en && w_pvccinfaon_cpu0_en_check),	//in
  .vrm_pgood        (i_pwrgd_pvccinfaon_cpu0),						//in
  .vrm_chklive_en   (w_pvccinfaon_cpu0_en_check),				//in
  .vrm_chklive_dis  (~w_pvccinfaon_cpu0_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvccinfaon_cpu0_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvnn_main_cpu0 Fault detect                               20
//------------------------------------------------------------------------------
wire w_pvnn_main_cpu0_en_check;

edge_delay #(.CNTR_NBITS(2)) pvnn_main_cpu0_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvnn_main_cpu0_en),
  .delay_output  (w_pvnn_main_cpu0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvnn_main_cpu0_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvnn_main_cpu0_en && w_pvnn_main_cpu0_en_check),	//in
  .vrm_pgood        (i_pwrgd_pvnn_main_cpu0),						//in
  .vrm_chklive_en   (w_pvnn_main_cpu0_en_check),				//in
  .vrm_chklive_dis  (~w_pvnn_main_cpu0_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvnn_main_cpu0_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvccd_hv_cpu0 Fault detect                               21
//------------------------------------------------------------------------------
wire w_pvccd_hv_cpu0_en_check;

edge_delay #(.CNTR_NBITS(2)) pvccd_hv_cpu0_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvccd_hv_cpu0_en),
  .delay_output  (w_pvccd_hv_cpu0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccd_hv_cpu0_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvccd_hv_cpu0_en && w_pvccd_hv_cpu0_en_check),	//in
  .vrm_pgood        (i_pwrgd_pvccd_hv_cpu0),						//in
  .vrm_chklive_en   (w_pvccd_hv_cpu0_en_check),				//in
  .vrm_chklive_dis  (~w_pvccd_hv_cpu0_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvccd_hv_cpu0_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvccin_cpu0 Fault detect                               22
//------------------------------------------------------------------------------
wire w_pvccin_cpu0_en_check;

edge_delay #(.CNTR_NBITS(2)) pvccin_cpu0_en_check_inst (
  .clk           (i_clk),
  .reset         (i_rst_n),
  .cnt_size      (2'b10),
  .cnt_step      (i_1SEC),
  .signal_in     (i_pvccin_cpu0_en),
  .delay_output  (w_pvccin_cpu0_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccin_cpu0_fault_detect_inst (
  .clk              (i_clk),								//in
  .reset            (i_rst_n),							//in
  .vrm_enable       (i_pvccin_cpu0_en && w_pvccin_cpu0_en_check),	//in
  .vrm_pgood        (i_pwrgd_pvccin_cpu0),						//in
  .vrm_chklive_en   (w_pvccin_cpu0_en_check),				//in
  .vrm_chklive_dis  (~w_pvccin_cpu0_en_check),				//in
  .critical_fail    (1'b0),					            //in
  .fault_clear      (i_clr_flag),						//in
  .lock             (w_any_pwr_fault_det),				//in
  .any_vrm_fault    (),						            //out
  .vrm_fault        (w_pvccin_cpu0_fault_det)				//out
);

//------------------------------------------------------------------------------
// pvpp_hbm_cpu1 Fault detect                                              23
//------------------------------------------------------------------------------
wire w_pvpp_hbm_cpu1_en_check;

// edge_delay #(.CNTR_NBITS(2)) pvpp_hbm_cpu1_en_check_inst (
  // .clk           (i_clk),
  // .reset         (i_rst_n),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_1SEC),
  // .signal_in     (i_pvpp_hbm_cpu1_en),
  // .delay_output  (w_pvpp_hbm_cpu1_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvpp_hbm_cpu1_fault_detect_inst (
  // .clk              (i_clk),								//in
  // .reset            (i_rst_n),							//in
  // .vrm_enable       (i_pvpp_hbm_cpu1_en && w_pvpp_hbm_cpu1_en_check),	//in
  // .vrm_pgood        (i_pwrgd_pvpp_hbm_cpu1),						//in
  // .vrm_chklive_en   (w_pvpp_hbm_cpu1_en_check),				//in
  // .vrm_chklive_dis  (~w_pvpp_hbm_cpu1_en_check),				//in
  // .critical_fail    (1'b0),					            //in
  // .fault_clear      (i_clr_flag),						//in
  // .lock             (w_any_pwr_fault_det),				//in
  // .any_vrm_fault    (),						            //out
  // .vrm_fault        (w_pvpp_hbm_cpu1_fault_det)				//out
// );

//------------------------------------------------------------------------------
// pvccfa_ehv_cpu1 Fault detect                                     24
//------------------------------------------------------------------------------
wire w_pvccfa_ehv_cpu1_en_check;

// edge_delay #(.CNTR_NBITS(2)) pvccfa_ehv_cpu1_en_check_inst (
  // .clk           (i_clk),
  // .reset         (i_rst_n),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_1SEC),
  // .signal_in     (i_pvccfa_ehv_cpu1_en),
  // .delay_output  (w_pvccfa_ehv_cpu1_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccfa_ehv_cpu1_fault_detect_inst (
  // .clk              (i_clk),								//in
  // .reset            (i_rst_n),							//in
  // .vrm_enable       (i_pvccfa_ehv_cpu1_en && w_pvccfa_ehv_cpu1_en_check),	//in
  // .vrm_pgood        (i_pwrgd_pvccfa_ehv_cpu1),						//in
  // .vrm_chklive_en   (w_pvccfa_ehv_cpu1_en_check),				//in
  // .vrm_chklive_dis  (~w_pvccfa_ehv_cpu1_en_check),				//in
  // .critical_fail    (1'b0),					            //in
  // .fault_clear      (i_clr_flag),						//in
  // .lock             (w_any_pwr_fault_det),				//in
  // .any_vrm_fault    (),						            //out
  // .vrm_fault        (w_pvccfa_ehv_cpu1_fault_det)				//out
// );

//------------------------------------------------------------------------------
// pvccfa_ehv_fivra_cpu1 Fault detect                               25
//------------------------------------------------------------------------------
wire w_pvccfa_ehv_fivra_cpu1_en_check;

// edge_delay #(.CNTR_NBITS(2)) pvccfa_ehv_fivra_cpu1_en_check_inst (
  // .clk           (i_clk),
  // .reset         (i_rst_n),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_1SEC),
  // .signal_in     (i_pvccfa_ehv_fivra_cpu1_en),
  // .delay_output  (w_pvccfa_ehv_fivra_cpu1_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccfa_ehv_fivra_cpu1_fault_detect_inst (
  // .clk              (i_clk),								//in
  // .reset            (i_rst_n),							//in
  // .vrm_enable       (i_pvccfa_ehv_fivra_cpu1_en && w_pvccfa_ehv_fivra_cpu1_en_check),	//in
  // .vrm_pgood        (i_pwrgd_pvccfa_ehv_fivra_cpu1),						//in
  // .vrm_chklive_en   (w_pvccfa_ehv_fivra_cpu1_en_check),				//in
  // .vrm_chklive_dis  (~w_pvccfa_ehv_fivra_cpu1_en_check),				//in
  // .critical_fail    (1'b0),					            //in
  // .fault_clear      (i_clr_flag),						//in
  // .lock             (w_any_pwr_fault_det),				//in
  // .any_vrm_fault    (),						            //out
  // .vrm_fault        (w_pvccfa_ehv_fivra_cpu1_fault_det)				//out
// );

//------------------------------------------------------------------------------
// pvccinfaon_cpu1 Fault detect                               26
//------------------------------------------------------------------------------
wire w_pvccinfaon_cpu1_en_check;

// edge_delay #(.CNTR_NBITS(2)) pvccinfaon_cpu1_en_check_inst (
  // .clk           (i_clk),
  // .reset         (i_rst_n),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_1SEC),
  // .signal_in     (i_pvccinfaon_cpu1_en),
  // .delay_output  (w_pvccinfaon_cpu1_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccinfaon_cpu1_fault_detect_inst (
  // .clk              (i_clk),								//in
  // .reset            (i_rst_n),							//in
  // .vrm_enable       (i_pvccinfaon_cpu1_en && w_pvccinfaon_cpu1_en_check),	//in
  // .vrm_pgood        (i_pwrgd_pvccinfaon_cpu1),						//in
  // .vrm_chklive_en   (w_pvccinfaon_cpu1_en_check),				//in
  // .vrm_chklive_dis  (~w_pvccinfaon_cpu1_en_check),				//in
  // .critical_fail    (1'b0),					            //in
  // .fault_clear      (i_clr_flag),						//in
  // .lock             (w_any_pwr_fault_det),				//in
  // .any_vrm_fault    (),						            //out
  // .vrm_fault        (w_pvccinfaon_cpu1_fault_det)				//out
// );

//------------------------------------------------------------------------------
// pvnn_main_cpu1 Fault detect                               27
//------------------------------------------------------------------------------
wire w_pvnn_main_cpu1_en_check;

// edge_delay #(.CNTR_NBITS(2)) pvnn_main_cpu1_en_check_inst (
  // .clk           (i_clk),
  // .reset         (i_rst_n),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_1SEC),
  // .signal_in     (i_pvnn_main_cpu1_en),
  // .delay_output  (w_pvnn_main_cpu1_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvnn_main_cpu1_fault_detect_inst (
  // .clk              (i_clk),								//in
  // .reset            (i_rst_n),							//in
  // .vrm_enable       (i_pvnn_main_cpu1_en && w_pvnn_main_cpu1_en_check),	//in
  // .vrm_pgood        (i_pwrgd_pvnn_main_cpu1),						//in
  // .vrm_chklive_en   (w_pvnn_main_cpu1_en_check),				//in
  // .vrm_chklive_dis  (~w_pvnn_main_cpu1_en_check),				//in
  // .critical_fail    (1'b0),					            //in
  // .fault_clear      (i_clr_flag),						//in
  // .lock             (w_any_pwr_fault_det),				//in
  // .any_vrm_fault    (),						            //out
  // .vrm_fault        (w_pvnn_main_cpu1_fault_det)				//out
// );

//------------------------------------------------------------------------------
// pvccd_hv_cpu1 Fault detect                               28
//------------------------------------------------------------------------------
wire w_pvccd_hv_cpu1_en_check;

// edge_delay #(.CNTR_NBITS(2)) pvccd_hv_cpu1_en_check_inst (
  // .clk           (i_clk),
  // .reset         (i_rst_n),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_1SEC),
  // .signal_in     (i_pvccd_hv_cpu1_en),
  // .delay_output  (w_pvccd_hv_cpu1_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccd_hv_cpu1_fault_detect_inst (
  // .clk              (i_clk),								//in
  // .reset            (i_rst_n),							//in
  // .vrm_enable       (i_pvccd_hv_cpu1_en && w_pvccd_hv_cpu1_en_check),	//in
  // .vrm_pgood        (i_pwrgd_pvccd_hv_cpu1),						//in
  // .vrm_chklive_en   (w_pvccd_hv_cpu1_en_check),				//in
  // .vrm_chklive_dis  (~w_pvccd_hv_cpu1_en_check),				//in
  // .critical_fail    (1'b0),					            //in
  // .fault_clear      (i_clr_flag),						//in
  // .lock             (w_any_pwr_fault_det),				//in
  // .any_vrm_fault    (),						            //out
  // .vrm_fault        (w_pvccd_hv_cpu1_fault_det)				//out
// );

//------------------------------------------------------------------------------
// pvccin_cpu1 Fault detect                               29
//------------------------------------------------------------------------------
wire w_pvccin_cpu1_en_check;

// edge_delay #(.CNTR_NBITS(2)) pvccin_cpu1_en_check_inst (
  // .clk           (i_clk),
  // .reset         (i_rst_n),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_1SEC),
  // .signal_in     (i_pvccin_cpu1_en),
  // .delay_output  (w_pvccin_cpu1_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) pvccin_cpu1_fault_detect_inst (
  // .clk              (i_clk),								//in
  // .reset            (i_rst_n),							//in
  // .vrm_enable       (i_pvccin_cpu1_en && w_pvccin_cpu1_en_check),	//in
  // .vrm_pgood        (i_pwrgd_pvccin_cpu1),						//in
  // .vrm_chklive_en   (w_pvccin_cpu1_en_check),				//in
  // .vrm_chklive_dis  (~w_pvccin_cpu1_en_check),				//in
  // .critical_fail    (1'b0),					            //in
  // .fault_clear      (i_clr_flag),						//in
  // .lock             (w_any_pwr_fault_det),				//in
  // .any_vrm_fault    (),						            //out
  // .vrm_fault        (w_pvccin_cpu1_fault_det)				//out
// );

// error code 
always@(posedge i_clk or posedge i_rst_n)
begin
    if(i_rst_n)
	begin
	    r_timeout_code    <= 8'h00;
	end
	else if(i_clr_flag)
	    r_timeout_code    <= 8'h00;
	else if(~i_clr_flag)
	begin
	    if(w_p3v3_stby_fault_det)
		    r_timeout_code    <= 8'h00;//8'h01;
		else if(w_p12v_fault_det)
		    r_timeout_code    <= 8'h02;
		else if(w_p5v_stby_fault_det)
		    r_timeout_code    <= 8'h03;
		else if(w_p1v2_stby_fault_det)
		    r_timeout_code    <= 8'h04;
            
		// else if(w_p1v8_stby_fault_det)
		    // r_timeout_code    <= 8'h05;
            
		else if(w_cmu_p5v0_stby_fault_det)
		    r_timeout_code    <= 8'h00;//8'h06;
		else if(w_cmu_p3v3_stby_fault_det)
		    r_timeout_code    <= 8'h00;//8'h07;
		else if(w_cmu_p3v3_stby_rgm_fault_det)
		    r_timeout_code    <= 8'h00;//8'h08;
		else if(w_cmu_p2v5_stby_fault_det)
		    r_timeout_code    <= 8'h00;//8'h09;
		else if(w_cmu_p1v8_stby_fault_det)
		    r_timeout_code    <= 8'h00;//8'h0a;
		else if(w_cmu_p1v2_stby_fault_det)
		    r_timeout_code    <= 8'h00;//8'h0b;
		else if(w_cmu_p1v0_stby_fault_det)
		    r_timeout_code    <= 8'h00;//8'h0c;
		else if(w_pvnn_pch_fault_det)
		    r_timeout_code    <= 8'h0d;
		else if(w_p1v05_pch_fault_det)
		    r_timeout_code    <= 8'h0e;
		else if(w_p5v_fault_det)
		    r_timeout_code    <= 8'h0f;
		else if(w_pvpp_hbm_cpu0_fault_det)
		    r_timeout_code    <= 8'h10;
		else if(w_pvccfa_ehv_cpu0_fault_det)
		    r_timeout_code    <= 8'h11;
		else if(w_pvccfa_ehv_fivra_cpu0_fault_det)
		    r_timeout_code    <= 8'h12;
		else if(w_pvccinfaon_cpu0_fault_det)
		    r_timeout_code    <= 8'h13;
		else if(w_pvnn_main_cpu0_fault_det)
		    r_timeout_code    <= 8'h14;
		else if(w_pvccd_hv_cpu0_fault_det)
		    r_timeout_code    <= 8'h15;
		else if(w_pvccin_cpu0_fault_det)
		    r_timeout_code    <= 8'h16;
		else if(w_pvpp_hbm_cpu1_fault_det)
		    r_timeout_code    <= 8'h17;
		else if(w_pvccfa_ehv_cpu1_fault_det)
		    r_timeout_code    <= 8'h18;		
		else if(w_pvccfa_ehv_fivra_cpu1_fault_det)
		    r_timeout_code    <= 8'h19;
		else if(w_pvccinfaon_cpu1_fault_det)
		    r_timeout_code    <= 8'h1a;
		else if(w_pvnn_main_cpu1_fault_det)
		    r_timeout_code    <= 8'h1b;
		else if(w_pvccd_hv_cpu1_fault_det)
		    r_timeout_code    <= 8'h1c;	
		else if(w_pvccin_cpu1_fault_det)
		    r_timeout_code    <= 8'h1d;
		else if(i_cpu0Mem_ab_pwr_flt)
		    r_timeout_code    <= 8'h1e;
		else if(i_cpu0Mem_cd_pwr_flt)
		    r_timeout_code    <= 8'h1f;
		else if(i_cpu0Mem_ef_pwr_flt)
		    r_timeout_code    <= 8'h20;		
		else if(i_cpu0Mem_gh_pwr_flt)
		    r_timeout_code    <= 8'h21;
		else if(i_cpu1Mem_ab_pwr_flt)
		    r_timeout_code    <= 8'h22;
		else if(i_cpu1Mem_cd_pwr_flt)
		    r_timeout_code    <= 8'h23;
		else if(i_cpu1Mem_ef_pwr_flt)
		    r_timeout_code    <= 8'h24;		
		else if(i_cpu1Mem_gh_pwr_flt)
		    r_timeout_code    <= 8'h25;
	end
	else
	begin
	    r_timeout_code  <= 8'h00;
	end
end



endmodule
