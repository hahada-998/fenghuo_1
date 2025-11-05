`timescale 1ns/1ns
module pwrseq_tb;
// 时钟和复位信号
logic   clk_50m;
logic   pon_reset_n;
logic   t1us_tick, t512us_tick, t2ms_tick, t32ms_tick, t256ms_tick, t512ms_tick, t1s_tick;

// -------------------------------------------------------------------------
// 时钟生成模块，能够基于输入时钟生成多种定时信号和慢速时钟信号
// -------------------------------------------------------------------------
initial begin
  clk_50m = 0;
  forever #2 clk_50m = ~clk_50m; // 250MHz 时钟：周期 4 ns
end

initial begin
    // 初始化控制信号
    pon_reset_n = 0;
    // 等待一段时间，释放复位
    #200;
    pon_reset_n = 1;
end 

/*
timer_gen timer_gen_inst(
  .clk               (clk_50m         ), // 输入时钟信号，频率为 50 MHz
  .reset             (~pon_reset_n    ), // 异步复位信号，低电平有效
  .t40ns             (t40ns_tick      ), // 40 纳秒脉冲
  .t80ns             (),                 // 80 纳秒脉冲（未使用）
  .t160ns            (),                 // 160 纳秒脉冲（未使用）
  .t1us              (t1us_tick       ), // 1 微秒脉冲
  .t2us              (                ), // 2 微秒脉冲
  .t16us             (                ), // 16 微秒脉冲
  .t32us             (                ), // 32 微秒脉冲
  .t128us            (                ), // 128 微秒脉冲
  .t512us            (t512us_tick     ), // 512 微秒脉冲
  .t1ms              (                ), // 1 毫秒脉冲
  .t2ms              (t2ms_tick       ), // 2 毫秒脉冲
  .t16ms             (),                 // 16 毫秒脉冲（未使用）
  .t32ms             (t32ms_tick      ), // 32 毫秒脉冲
  .t64ms             (                ), // 64 毫秒脉冲
  .t128ms            (                ), // 128 毫秒脉冲
  .t256ms            (t256ms_tick     ), // 256 毫秒脉冲
  .t512ms            (t512ms_tick     ), // 512 毫秒脉冲
  .t1s               (t1s_tick        ), // 1 秒脉冲
  .clk_1hz           (                ), // 1 Hz 时钟信号
  .clk_2p5hz         (                ), // 2.5 Hz 时钟信号
  .clk_4hz           (                ), // 4 Hz 时钟信号
  .clk_16khz         (                ), // 16 kHz 时钟信号
  .clk_6m25          (                ), // 6.25 MHz 时钟信号
  .clk_16m6          (                )  // 16.6 MHz 时钟信号
);
*/
logic            t40ns_cnt    ; // 2周期, 8ns
logic  [2:0]     t1us_cnt     ; // 8周期, 32ns 
logic  [3:0]     t512us_cnt   ; // 16周期, 64ns
logic  [4:0]     t2ms_cnt     ; // 32周期, 128ns
logic  [5:0]     t32ms_cnt    ; // 64周期, 256ns
logic  [6:0]     t256ms_cnt   ; // 128周期, 512ns
logic  [7:0]     t512ms_cnt   ; // 256周期, 1024ns
logic  [8:0]     t1s_cnt      ; // 512周期, 2048ns

always @(posedge clk_50m or negedge pon_reset_n) begin
  if (!pon_reset_n) begin
    t40ns_cnt    <= 0;
    t1us_cnt     <= 0;
    t512us_cnt   <= 0;
    t2ms_cnt     <= 0;
    t32ms_cnt    <= 0;
    t256ms_cnt   <= 0;
    t512ms_cnt   <= 0;
    t1s_cnt      <= 0;
  end 
  else begin
    t40ns_cnt    <= t40ns_cnt + 1;
    t1us_cnt     <= t1us_cnt + 1;
    t512us_cnt   <= t512us_cnt + 1;
    t2ms_cnt     <= t2ms_cnt + 1;
    t32ms_cnt    <= t32ms_cnt + 1;
    t256ms_cnt   <= t256ms_cnt + 1;
    t512ms_cnt   <= t512ms_cnt + 1;
    t1s_cnt      <= t1s_cnt + 1;
  end
end

always @(posedge clk_50m or negedge pon_reset_n) begin
  if (!pon_reset_n) begin
    t1us_tick    <= 1'b0;
    t512us_tick  <= 1'b0;
    t2ms_tick    <= 1'b0;
    t32ms_tick   <= 1'b0;
    t256ms_tick  <= 1'b0;
    t512ms_tick  <= 1'b0;
    t1s_tick     <= 1'b0;
  end 
  else begin
    if(t40ns_cnt == 1'd1)
      t1us_tick <= 1'b1;
    else 
      t1us_tick <= 1'b0;

    if(t1us_cnt == 3'd7)
      t512us_tick <= 1'b1;
    else 
      t512us_tick <= 1'b0;

    if(t512us_cnt == 4'd15) 
      t2ms_tick <= 1'b1;
    else 
      t2ms_tick <= 1'b0;

    if(t2ms_cnt == 5'd31)
      t32ms_tick <= 1'b1;
    else 
      t32ms_tick <= 1'b0;

    if(t32ms_cnt == 6'd63)
      t256ms_tick <= 1'b1;
    else 
      t256ms_tick <= 1'b0;

    if(t256ms_cnt == 7'd127)
      t512ms_tick <= 1'b1;
    else 
      t512ms_tick <= 1'b0;

    if(t512ms_cnt == 8'd255)
      t1s_tick <= 1'b1;
    else 
      t1s_tick <= 1'b0;
  end
end

// ----- signals used by pwrseq_master (inputs from TB or slave) -----
logic   allow_recovery      ;
logic   aux_video_holdoff   ;
logic   pgood_rst_mask      ;
logic   keep_alive_on_fault ;
logic   pwron_override_n    ;
logic   bmc_clr_stby_tmout_n;

logic   power_seq_sm_fb     ;
logic   mux_sel             ;
logic   sys_sw_in_n;
logic   pch_slp4_n;
logic   p0_pwrbtn_n;
logic   [1:0] pch_thermtrip_n;
logic   [1:0] cpu_thermtrip_fault_det;
logic   xr_ps_en;
logic   interlock_broken;

// The following signals will be driven by pwrseq_slave -> so declare as wires
logic   pgd_so_far;
logic   s5dev_pwren_request;
logic   s5dev_pwrdis_request;
logic   any_pwr_fault_det;
logic   any_lim_recov_fault;
logic   any_non_recov_fault;
logic   any_aux_vrm_fault;
logic   any_recov_fault;

// ----- outputs from pwrseq_master (to slave / to observe) -----
logic   force_pwrbtn_n;
logic   pgd_raw;
logic   dc_on_wait_complete;
logic   rt_critical_fail_store;
logic   fault_clear;
logic   cmu_fault_clear;
logic   [5:0] power_seq_sm;
logic   fault_power;
logic   stby_failure_detected;
logic   po_failure_detected;
logic   rt_failure_detected;
logic   cpld_latch_sys_off;
logic   turn_on_wait;
logic   po_failure_detected_set;

// ----- signals for pwrseq_slave: PG inputs (driven by our simple power model) -----
logic   db_i_pwrgd_p3v3_stby;
logic   db_i_pgd_p0_vdd_18_stby;
logic   db_i_pgd_p1_vdd_18_stby;
logic   db_i_pgd_p0_vddc;
logic   db_i_pgd_p1_vddc;
logic   db_i_pgd_p0_vdd_11_sus;
logic   db_i_pgd_p1_vdd_11_sus;
logic   db_i_pgd_p0_vddio;
logic   db_i_pgd_p1_vddio;
logic   db_i_pgd_p0_vdd_soc_0;
logic   db_i_pgd_p1_vdd_soc_0;
logic   db_i_pgd_p0_vdd_core_0;
logic   db_i_pgd_p1_vdd_core_0;
logic   db_i_pgd_p0_vdd_core_1;
logic   db_i_pgd_p1_vdd_core_1;
logic   db_i_p0_pwrgd_out;
logic   db_i_p1_pwrgd_out;
logic   db_cpu_prsnt_n_arry; // placeholder if needed

// ----- outputs from pwrseq_slave (enable signals + fault detects) -----
logic                     w_p5v_stby_en;
logic                     w_p5v_stby_usb_en;
logic                     w_grp_b_p0_33_s5_en;
logic                     w_grp_b_p1_33_s5_en;
logic                     w_grp_b_p0_18_s5_en;
logic                     w_grp_b_p1_18_s5_en;
logic                     w_p12_en;
logic                     w_p5v_en;
logic                     w_grp_c_p0_vdd11_en;
logic                     w_grp_c_p1_vdd11_en;
logic                     w_grp_d_p0_vddio_en;
logic                     w_grp_d_p1_vddio_en;
logic                     w_grp_d_p0_soc_en;
logic                     w_grp_d_p1_soc_en;
logic                     w_grp_d_p0_vddcore0_en;
logic                     w_grp_d_p1_vddcore0_en;
logic                     w_grp_d_p0_vddcore1_en;
logic                     w_grp_d_p1_vddcore1_en;
logic                     w_ocp_aux_en;
logic                     w_ocp_main_en;

// ----- fault detect outputs from slave (observables) -----
logic                     w_pwrseq_sm_fault_det;
logic                     w_p5v_stby_fault_det;
logic                     w_grp_c_p0_fault_det;
logic                     w_grp_c_p1_fault_det;
logic                     w_grp_d_vddio_p0_fault_det;
logic                     w_grp_d_vddio_p1_fault_det;
logic                     w_grp_d_p0_soc_fault_det;
logic                     w_grp_d_p1_soc_fault_det;
logic                     w_grp_d_p0_vddcore0_fault_det;
logic                     w_grp_d_p1_vddcore0_fault_det;
logic                     w_grp_d_p0_vddcore1_fault_det;
logic                     w_grp_d_p1_vddcore1_fault_det;
logic                     w_grp_b_p0_33_s5_fault_det;
logic                     w_grp_b_p1_33_s5_fault_det;
logic                     w_grp_b_p0_18_s5_fault_det;
logic                     w_grp_b_p1_18_s5_fault_det;
logic                     w_p3v3_stby_fault_det;
logic                     w_p5v_fault_det;

logic   [1:0]             w_cpu_pwrok	    ;  //from CPU PWROK
logic   [1:0]             db_cpu_prsnt_n  ;  //db_cpu_prsnt_n

// -------------------------------------------------------------------------
// 测试场景：按键上电、观察 master/slave 协同的状态机跳转
// -------------------------------------------------------------------------
initial begin
    // 初始化控制信号
    allow_recovery          = 0       ;
    aux_video_holdoff       = 0       ;
    pgood_rst_mask          = 0       ;
    keep_alive_on_fault     = 0       ;
    pwron_override_n        = 1       ;

    bmc_clr_stby_tmout_n    = 1       ;
    power_seq_sm_fb         = 6'b0    ;
    mux_sel                 = 0       ;

    sys_sw_in_n             = 1       ;
    pch_slp4_n              = 1       ;
    p0_pwrbtn_n             = 1       ;
    pch_thermtrip_n         = 2'b11   ;
    cpu_thermtrip_fault_det = 2'b11   ;

    xr_ps_en                = 1       ;
    interlock_broken        = 0       ;

    w_cpu_pwrok	            = 2'b11	  ;	//from CPU PWROK
    db_cpu_prsnt_n          = 2'b00	  ;	//from CPU PWROK

    // 等待模块上电初始化
    #700;

    // 按下电源按钮（短按）触发上电
    $display("%0t: press power button -> start sequence", $time);
    sys_sw_in_n = 0;
    #100 sys_sw_in_n = 1;

    // 等待足够时间让 master/slave 交互并产生各阶段
    #10000;

    // 注入一个临时故障（模拟从 slave 到 master 上报）
    $display("%0t: inject fault from slave", $time);
    // 通过直接拉 high any_pwr_fault_det 模拟极端场景（仅作测试）
    // 注意：any_pwr_fault_det 为 slave 输出，不能在 tb 主动赋值；这里我们通过强制模拟 slave 的行为：
    // 简单替代：在实际情况下 slave 会设置该信号，若需要可在 pwrseq_slave 内部模拟注入。
    // 为测试，直接打印当前状态并等待观察。
    #5000;

    // 触发关机（短按）
    $display("%0t: press power button -> request shutdown", $time);
    sys_sw_in_n = 0;
    #100 sys_sw_in_n = 1;

    // 等待关闭完成   
  #500000;

    $display("%0t: simulation finished", $time);
    #100 $finish;
end

  // -------------------------------------------------------------------------
  // 实例化被测模块：pwrseq_master（已存在）
  // -------------------------------------------------------------------------
  pwrseq_master pwrseq_master_inst (
    .clk                        (clk_50m                      ),
    .reset                      (~pon_reset_n                 ),
    .cmu_fault_clear_rst        (~pon_reset_n                 ),
    .t1us                       (t1us_tick                    ),
    .t512us                     (t512us_tick                  ),
    .t256ms                     (t256ms_tick                  ),
    .t512ms                     (t512ms_tick                  ),
    .t1s_tick                   (t1s_tick                     ),
    .sequence_tick              (t2ms_tick                    ),
    .psu_on_tick                (t32ms_tick                   ),

    
    

    .sys_sw_in_n                (sys_sw_in_n                  ),
    .pch_slp4_n                 (pch_slp4_n                   ),
    .p0_pwrbtn_n                (p0_pwrbtn_n                  ),
    .pch_thermtrip_n            (pch_thermtrip_n[0]           ), // master 接口以位或标量为准
    .force_pwrbtn_n             (force_pwrbtn_n               ),
    .cpu_thermtrip_fault_det    (cpu_thermtrip_fault_det[0]   ),
    .power_seq_sm_fb            (power_seq_sm_fb              ), // 如果必要可改为 loopback
    .mux_sel                    (mux_sel                      ),

    .xr_ps_en                   (xr_ps_en                     ),
    .pwron_override_n           (pwron_override_n             ),
    .interlock_broken           (interlock_broken             ),
    .allow_recovery             (allow_recovery               ),
    .aux_video_holdoff          (aux_video_holdoff            ),
    .pgood_rst_mask             (pgood_rst_mask               ),
    .bmc_clr_stby_tmout_n       (bmc_clr_stby_tmout_n         ),

    .keep_alive_on_fault        (keep_alive_on_fault          ),
    .pgd_raw                    (pgd_raw                      ),
    .s5dev_pwren_request        (s5dev_pwren_request          ),
    .s5dev_pwrdis_request       (s5dev_pwrdis_request         ),
    .pgd_so_far                 (pgd_so_far                   ),
    .any_pwr_fault_det          (any_pwr_fault_det            ),
    .any_lim_recov_fault        (any_lim_recov_fault          ),
    .any_non_recov_fault        (any_non_recov_fault          ),

    .dc_on_wait_complete        (dc_on_wait_complete          ),
    .rt_critical_fail_store     (rt_critical_fail_store       ),
    .fault_clear                (fault_clear                  ),
    .cmu_fault_clear            (cmu_fault_clear              ),
    .power_seq_sm               (power_seq_sm                 ),

    .fault_power                (fault_power                  ),
    .stby_failure_detected      (stby_failure_detected        ),
    .po_failure_detected        (po_failure_detected          ),
    .rt_failure_detected        (rt_failure_detected          ),
    .cpld_latch_sys_off         (cpld_latch_sys_off           ),
    .turn_on_wait               (turn_on_wait                 ),
    .po_failure_detected_set    (po_failure_detected_set      )
  );

  // -------------------------------------------------------------------------
  // 实例化 pwrseq_slave 并连接到 master 信号
  // -------------------------------------------------------------------------
  localparam  NUM_CPU = 2;
  pwrseq_slave #(
    .SHARED_P5V_STBY_HPMOS(1'b1),
    .S5DEV_STUCKON_FAULT_CHK(1'b0),
    .NUM_CPU(NUM_CPU),
    .NUM_OPT_AUX(0)
  ) pwrseq_slave_inst (
    .clk                (clk_50m),
    .reset              (~pon_reset_n),
    .t1us               (t1us_tick),
    .t512us             (t512us_tick),
    .t1ms               (t1ms_tick),
    .t2ms               (t2ms_tick),
    .t64ms              (t64ms_tick),
    .t1s                (t1s_tick),

    .keep_alive_on_fault(keep_alive_on_fault),

    .dc_on_wait_complete(dc_on_wait_complete),
    .rt_critical_fail_store(rt_critical_fail_store),
    .fault_clear(fault_clear),
    .power_seq_sm(power_seq_sm),

    .pgd_so_far(pgd_so_far),
    .s5dev_pwren_request(s5dev_pwren_request),
    .s5dev_pwrdis_request(s5dev_pwrdis_request),
    .any_pwr_fault_det(any_pwr_fault_det),
    .any_lim_recov_fault(any_lim_recov_fault),
    .any_non_recov_fault(any_non_recov_fault),
    .any_aux_vrm_fault(any_aux_vrm_fault),
    .any_recov_fault(any_recov_fault),

    // PG inputs (来自被测电源/仿真模型)
    .grp_b_p0_18_s5_pg(db_i_pgd_p0_vdd_18_stby),
    .grp_b_p1_18_s5_pg(db_i_pgd_p1_vdd_18_stby),
    .p3v3_stby_pg(db_i_pwrgd_p3v3_stby),
    .grp_c_p0_pg(db_i_pgd_p0_vdd_11_sus),
    .grp_c_p1_pg(db_i_pgd_p1_vdd_11_sus),
    .grp_d_vddio_p0_pg(db_i_pgd_p0_vddio),
    .grp_d_vddio_p1_pg(db_i_pgd_p1_vddio),
    .grp_d_soc_p0_pg(db_i_pgd_p0_vdd_soc_0),
    .grp_d_soc_p1_pg(db_i_pgd_p1_vdd_soc_0),
    .grp_d_p0_vddcore0_pg(db_i_pgd_p0_vdd_core_0),
    .grp_d_p1_vddcore0_pg(db_i_pgd_p1_vdd_core_0),
    .grp_d_p0_vddcore1_pg(db_i_pgd_p0_vdd_core_1),
    .grp_d_p1_vddcore1_pg(db_i_pgd_p1_vdd_core_1),
    .grp_b_p0_33_s5_pg(db_i_pgd_p0_vddc),
    .grp_b_p1_33_s5_pg(db_i_pgd_p1_vddc),
    .i_pwrgd_ocp0_nic_pwrgd(1'b0),
    .i_cpu_pwrok({db_i_p1_pwrgd_out, db_i_p0_pwrgd_out}),
    .i_cpu_prsnt_n({1'b0, 1'b0}),

    // outputs: enables
    .p5v_stby_en(w_p5v_stby_en),
    .p5v_stby_usb_en(w_p5v_stby_usb_en),
    .grp_b_p0_33_s5_en(w_grp_b_p0_33_s5_en),
    .grp_b_p1_33_s5_en(w_grp_b_p1_33_s5_en),
    .grp_b_p0_18_s5_en(w_grp_b_p0_18_s5_en),
    .grp_b_p1_18_s5_en(w_grp_b_p1_18_s5_en),
    .power_supply_on(w_p12_en),
    .p5v_en(w_p5v_en),
    .grp_c_p0_vdd11_en(w_grp_c_p0_vdd11_en),
    .grp_c_p1_vdd11_en(w_grp_c_p1_vdd11_en),
    .grp_d_p0_vddio_en(w_grp_d_p0_vddio_en),
    .grp_d_p1_vddio_en(w_grp_d_p1_vddio_en),
    .grp_d_p0_soc_en(w_grp_d_p0_soc_en),
    .grp_d_p1_soc_en(w_grp_d_p1_soc_en),
    .grp_d_p0_vddcore0_en(w_grp_d_p0_vddcore0_en),
    .grp_d_p1_vddcore0_en(w_grp_d_p1_vddcore0_en),
    .grp_d_p0_vddcore1_en(w_grp_d_p0_vddcore1_en),
    .grp_d_p1_vddcore1_en(w_grp_d_p1_vddcore1_en),
    .ocp_aux_en(w_ocp_aux_en),
    .ocp_main_en(w_ocp_main_en),

    // fault detects (observables)
    .pwrseq_sm_fault_det(w_pwrseq_sm_fault_det),
    .p5v_stby_fault_det(w_p5v_stby_fault_det),
    .grp_c_p0_fault_det(w_grp_c_p0_fault_det),
    .grp_c_p1_fault_det(w_grp_c_p1_fault_det),
    .grp_d_vddio_p0_fault_det(w_grp_d_vddio_p0_fault_det),
    .grp_d_vddio_p1_fault_det(w_grp_d_vddio_p1_fault_det),
    .grp_d_soc_p0_fault_det(w_grp_d_p0_soc_fault_det),
    .grp_d_soc_p1_fault_det(w_grp_d_p1_soc_fault_det),
    .grp_d_p0_vddcore0_fault_det(w_grp_d_p0_vddcore0_fault_det),
    .grp_d_p1_vddcore0_fault_det(w_grp_d_p1_vddcore0_fault_det),
    .grp_d_p0_vddcore1_fault_det(w_grp_d_p0_vddcore1_fault_det),
    .grp_d_p1_vddcore1_fault_det(w_grp_d_p1_vddcore1_fault_det),
    .grp_b_p0_33_s5_fault_det(w_grp_b_p0_33_s5_fault_det),
    .grp_b_p1_33_s5_fault_det(w_grp_b_p1_33_s5_fault_det),
    .grp_b_p0_18_s5_fault_det(w_grp_b_p0_18_s5_fault_det),
    .grp_b_p1_18_s5_fault_det(w_grp_b_p1_18_s5_fault_det),
    .p3v3_stby_fault_det(w_p3v3_stby_fault_det),
    .p5v_fault_det(w_p5v_fault_det),

    //to CPU
    .o_p0_pwr_good				        (w_cpu_pwr_good				  ),	//for AMD BSP PWR_GOOD
    .o_cpu_pwrok					        (o_cpu_pwrok				    ),	//for VR SVI RST
    .o_rsmrst_n					          (w_rsmrst_n					    ),	//to CPU RSMRST#
    .reached_sm_wait_powerok		  ( )
  );

  // -------------------------------------------------------------------------
  // 简单的“电源控制器 + PG”行为模型：
  // 观察 slave 的 enable 输出，当上电使能置位时，若延时后设置对应 PG 为 1，推动时序继续
  // -------------------------------------------------------------------------
  initial begin
    // 初始化 PG 信号为 0（加上电源外部所有信号良好）
    db_i_pwrgd_p3v3_stby    = 1'b1;
    db_i_pgd_p0_vdd_18_stby = 1'b1;
    db_i_pgd_p1_vdd_18_stby = 1'b1;
    db_i_pgd_p0_vddc        = 1'b1;
    db_i_pgd_p1_vddc        = 1'b1;
    db_i_pgd_p0_vdd_11_sus  = 1'b1;
    db_i_pgd_p1_vdd_11_sus  = 1'b1;
    db_i_pgd_p0_vddio       = 1'b1;
    db_i_pgd_p1_vddio       = 1'b1;
    db_i_pgd_p0_vdd_soc_0   = 1'b1;
    db_i_pgd_p1_vdd_soc_0   = 1'b1;
    db_i_pgd_p0_vdd_core_0  = 1'b1;
    db_i_pgd_p1_vdd_core_0  = 1'b1;
    db_i_pgd_p0_vdd_core_1  = 1'b1;
    db_i_pgd_p1_vdd_core_1  = 1'b1;
    db_i_p0_pwrgd_out       = 1'b1;
    db_i_p1_pwrgd_out       = 1'b1;
  end

  /*
  // 当待机电源使能（p5v_stby_en）上升后，在延时后产生待机 PG
  always @(posedge w_p5v_stby_en) begin
    // 模拟电源上电稳定延时
    #500;
    db_i_pwrgd_p3v3_stby <= 1;
    db_i_pgd_p0_vdd_18_stby <= 1;
    db_i_pgd_p0_vddc <= 1;
  end
  always @(negedge w_p5v_stby_en) begin
    #10;
    db_i_pwrgd_p3v3_stby <= 0;
    db_i_pgd_p0_vdd_18_stby <= 0;
    db_i_pgd_p0_vddc <= 0;
  end

  // 当主电源使能（pwr supply on / p12_en）上升后，在延时后产生主电源 PG
  always @(posedge w_p12_en) begin
    #2000;
    db_i_pgd_p0_vdd_11_sus <= 1;
    db_i_pgd_p1_vdd_11_sus <= 1;
    db_i_pgd_p0_vddio <= 1;
    db_i_pgd_p1_vddio <= 1;
    db_i_pgd_p0_vdd_soc_0 <= 1;
    db_i_pgd_p1_vdd_soc_0 <= 1;
    db_i_pgd_p0_vdd_core_0 <= 1;
    db_i_pgd_p1_vdd_core_0 <= 1;
    db_i_pgd_p0_vdd_core_1 <= 1;
    db_i_pgd_p1_vdd_core_1 <= 1;
    db_i_p0_pwrgd_out <= 1;
    db_i_p1_pwrgd_out <= 1;
  end
  always @(negedge w_p12_en) begin
    #10;
    db_i_pgd_p0_vdd_11_sus <= 0;
    db_i_pgd_p1_vdd_11_sus <= 0;
    db_i_pgd_p0_vddio <= 0;
    db_i_pgd_p1_vddio <= 0;
    db_i_pgd_p0_vdd_soc_0 <= 0;
    db_i_pgd_p1_vdd_soc_0 <= 0;
    db_i_pgd_p0_vdd_core_0 <= 0;
    db_i_pgd_p1_vdd_core_0 <= 0;
    db_i_pgd_p0_vdd_core_1 <= 0;
    db_i_pgd_p1_vdd_core_1 <= 0;
    db_i_p0_pwrgd_out <= 0;
    db_i_p1_pwrgd_out <= 0;
  end
  */

 



  // -------------------------- 新增：自动断言与状态监测 --------------------------
  // 目标：
  //  - 打印 power_seq_sm 的跳变
  //  - 在按键触发上电后断言：w_p5v_stby_en 在 20us 内上升；w_p12_en 在 120us 内上升
  //  - 在关机请求后断言：w_p12_en 在 50us 内下降
  reg [5:0] prev_power_seq_sm;
  reg seq_armed;
  reg seen_p5v;
  reg seen_p12;
  time seq_start_time;
  time p5v_time;
  time p12_time;

  initial begin
    prev_power_seq_sm = power_seq_sm;
    seq_armed = 0;
    seen_p5v = 0;
    seen_p12 = 0;
  end

  // 打印状态机跳变（每个时钟上升沿采样）
  always @(posedge clk_50m) begin
    if (power_seq_sm !== prev_power_seq_sm) begin
      $display("%0t: power_seq_sm changed %0d -> %0d", $time, prev_power_seq_sm, power_seq_sm);
      prev_power_seq_sm = power_seq_sm;
    end
  end


/*
  // 监测按键触发，开始计时并检查事件
  always @(posedge clk_50m) begin
    // 检测短按开始（sys_sw_in_n 拉低）
    if (!sys_sw_in_n && !seq_armed) begin
      seq_armed <= 1;
      seq_start_time = $time;
      seen_p5v <= 0;
      seen_p12 <= 0;
      p5v_time = 0;
      p12_time = 0;
      $display("%0t: sequence armed", $time);
    end

    // if armed, check timeouts and events
    if (seq_armed) begin
      // 检查 p5v_stby_en 是否在 20us(20000ns) 内上升
      if (!seen_p5v && ( ($time - seq_start_time) > 40000 )) begin
        if (!seen_p5v) begin
          $fatal("%0t: TIMEOUT - w_p5v_stby_en did not assert within 20us after button press", $time);
        end
      end

      // 检查 p12_en 是否在 120us(120000ns) 内上升（主电源）
      if (!seen_p12 && ( ($time - seq_start_time) > 120000 )) begin
        $fatal("%0t: TIMEOUT - w_p12_en did not assert within 120us after button press", $time);
      end

      // 关机检测：若曾见到 p12 并且 sys_sw_in_n 再次短按 -> 期望 p12 在 50us 内下降
      if (seen_p12 && (!sys_sw_in_n)) begin
        // 标记关机开始时间
        if (p12_time == 0) p12_time = $time;
      end
      if (p12_time != 0) begin
        if (w_p12_en == 0) begin
          $display("%0t: p12 went low during shutdown (ok)", $time);
          // reset monitor so further sequences can be tested
          seq_armed <= 0;
          seq_start_time = 0;
          p12_time = 0;
        end else if (($time - p12_time) > 50000) begin
          $fatal("%0t: TIMEOUT - w_p12_en did not deassert within 50us after shutdown request", $time);
        end
      end
    end
  end

  // 捕捉 w_p5v_stby_en 与 w_p12_en 的上升沿，记录时间并验证 PG 是否在预期延时内到位
  always @(posedge w_p5v_stby_en) begin
    seen_p5v <= 1;
    p5v_time = $time;
    $display("%0t: observed w_p5v_stby_en asserted", $time);
    // PG 模型在 TB 中会在 #500 后把 db_i_pwrgd_p3v3_stby 置 1；这里断言该 PG 在 2us 内到位
    fork
      begin
        #2000;
        if (db_i_pwrgd_p3v3_stby !== 1) begin
          $fatal("%0t: PG TIMEOUT - db_i_pwrgd_p3v3_stby did not assert within 2us after w_p5v_stby_en", $time);
        end else begin
          $display("%0t: db_i_pwrgd_p3v3_stby asserted (ok)", $time);
        end
      end
    join_none
  end

  always @(posedge w_p12_en) begin
    seen_p12 <= 1;
    $display("%0t: observed w_p12_en asserted", $time);
    // 主电源断言后，CPU pwrgd 输出应在 5ms（5000000ns）内到位（TB 使用 2000 delay，这里给足裕量）
    fork
      begin
        #5000000;
        if (!(db_i_p0_pwrgd_out && db_i_p1_pwrgd_out)) begin
          $fatal("%0t: CPU PWROK TIMEOUT - db_i_p?_pwrgd_out not both asserted within 5ms after w_p12_en", $time);
        end else begin
          $display("%0t: CPU PWROK asserted (both) (ok)", $time);
        end
      end
    join_none
  end
*/
endmodule