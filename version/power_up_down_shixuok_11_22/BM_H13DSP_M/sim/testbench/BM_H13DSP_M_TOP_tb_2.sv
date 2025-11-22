`timescale 1ns/1ps
`include "pwrseq_define.vh"

module pwrseq_tb;

  // 时钟和复位信号
  reg clk_50m;
  reg pon_reset_n;
  reg t1us_tick, t512us_tick, t2ms_tick, t32ms_tick, t256ms_tick, t512ms_tick, t1s_tick;
  reg t1ms_tick, t64ms_tick;

  // ----- signals used by pwrseq_master (inputs from TB or slave) -----
  reg allow_recovery;
  reg aux_video_holdoff;
  reg pgood_rst_mask;
  reg pwron_override_n;
  reg bmc_clr_stby_tmout_n;
  reg sys_sw_in_n;
  reg pch_slp4_n;
  reg p0_pwrbtn_n;
  reg [1:0] pch_thermtrip_n;
  reg [1:0] cpu_thermtrip_fault_det;
  reg xr_ps_en;
  reg interlock_broken;

  // The following signals will be driven by pwrseq_slave -> so declare as wires
  wire pgd_so_far;
  wire s5dev_pwren_request;
  wire s5dev_pwrdis_request;
  wire any_pwr_fault_det;
  wire any_lim_recov_fault;
  wire any_non_recov_fault;
  wire any_aux_vrm_fault;
  wire any_recov_fault;

  // ----- outputs from pwrseq_master (to slave / to observe) -----
  wire force_pwrbtn_n;
  wire pgd_raw;
  wire dc_on_wait_complete;
  wire rt_critical_fail_store;
  wire fault_clear;
  wire cmu_fault_clear;
  wire [5:0] power_seq_sm;
  wire fault_power;
  wire stby_failure_detected;
  wire po_failure_detected;
  wire rt_failure_detected;
  wire cpld_latch_sys_off;
  wire turn_on_wait;

  // ----- signals for pwrseq_slave: PG inputs (driven by TB power model) -----
  reg db_i_pwrgd_p3v3_stby;
  reg db_i_pgd_p0_vdd_18_stby;
  reg db_i_pgd_p1_vdd_18_stby;
  reg db_i_pgd_p0_vddc;
  reg db_i_pgd_p1_vddc;
  reg db_i_pgd_p0_vdd_11_sus;
  reg db_i_pgd_p1_vdd_11_sus;
  reg db_i_pgd_p0_vddio;
  reg db_i_pgd_p1_vddio;
  reg db_i_pgd_p0_vdd_soc_0;
  reg db_i_pgd_p1_vdd_soc_0;
  reg db_i_pgd_p0_vdd_core_0;
  reg db_i_pgd_p1_vdd_core_0;
  reg db_i_pgd_p0_vdd_core_1;
  reg db_i_pgd_p1_vdd_core_1;
  reg db_i_p0_pwrgd_out;
  reg db_i_p1_pwrgd_out;

  // ----- outputs from pwrseq_slave (enable signals + fault detects) -----
  wire w_p5v_stby_en;
  wire w_p5v_stby_usb_en;
  wire w_grp_b_p0_33_s5_en;
  wire w_grp_b_p1_33_s5_en;
  wire w_grp_b_p0_18_s5_en;
  wire w_grp_b_p1_18_s5_en;
  wire w_p12_en;
  wire w_p5v_en;
  wire w_grp_c_p0_vdd11_en;
  wire w_grp_c_p1_vdd11_en;
  wire w_grp_d_p0_vddio_en;
  wire w_grp_d_p1_vddio_en;
  wire w_grp_d_p0_soc_en;
  wire w_grp_d_p1_soc_en;
  wire w_grp_d_p0_vddcore0_en;
  wire w_grp_d_p1_vddcore0_en;
  wire w_grp_d_p0_vddcore1_en;
  wire w_grp_d_p1_vddcore1_en;
  wire w_ocp_aux_en;
  wire w_ocp_main_en;

  // ----- fault detect outputs from slave (observables) -----
  wire w_pwrseq_sm_fault_det;
  wire w_p5v_stby_fault_det;
  wire w_grp_c_p0_fault_det;
  wire w_grp_c_p1_fault_det;
  wire w_grp_d_vddio_p0_fault_det;
  wire w_grp_d_vddio_p1_fault_det;
  wire w_grp_d_p0_soc_fault_det;
  wire w_grp_d_p1_soc_fault_det;
  wire w_grp_d_p0_vddcore0_fault_det;
  wire w_grp_d_p1_vddcore0_fault_det;
  wire w_grp_d_p0_vddcore1_fault_det;
  wire w_grp_d_p1_vddcore1_fault_det;
  wire w_grp_b_p0_33_s5_fault_det;
  wire w_grp_b_p1_33_s5_fault_det;
  wire w_grp_b_p0_18_s5_fault_det;
  wire w_grp_b_p1_18_s5_fault_det;
  wire w_p3v3_stby_fault_det;
  wire w_p5v_fault_det;

  // -------------------------------------------------------------------------
  // 实例化 pwrseq_master
  // -------------------------------------------------------------------------
  pwrseq_master pwrseq_master_inst (
    .clk(clk_50m),
    .reset(~pon_reset_n),
    .cmu_fault_clear_rst(~pon_reset_n),
    .t1us(t1us_tick),
    .t512us(t512us_tick),
    .sequence_tick(t2ms_tick),
    .psu_on_tick(t32ms_tick),
    .t256ms(t256ms_tick),
    .t512ms(t512ms_tick),
    .t1s_tick(t1s_tick),
    .allow_recovery(allow_recovery),
    .aux_video_holdoff(aux_video_holdoff),
    .pgood_rst_mask(pgood_rst_mask),
    .pwron_override_n(pwron_override_n),
    .bmc_clr_stby_tmout_n(bmc_clr_stby_tmout_n),
    .power_seq_sm_fb(6'b0),
    .mux_sel(1'b0),
    .sys_sw_in_n(sys_sw_in_n),
    .pch_slp4_n(pch_slp4_n),
    .p0_pwrbtn_n(p0_pwrbtn_n),
    .pch_thermtrip_n(pch_thermtrip_n[0]),
    .cpu_thermtrip_fault_det(cpu_thermtrip_fault_det[0]),
    .xr_ps_en(xr_ps_en),
    .interlock_broken(interlock_broken),
    .s5dev_pwren_request(s5dev_pwren_request),
    .s5dev_pwrdis_request(s5dev_pwrdis_request),
    .pgd_so_far(pgd_so_far),
    .any_pwr_fault_det(any_pwr_fault_det),
    .any_lim_recov_fault(any_lim_recov_fault),
    .any_non_recov_fault(any_non_recov_fault),
    .force_pwrbtn_n(force_pwrbtn_n),
    .pgd_raw(pgd_raw),
    .dc_on_wait_complete(dc_on_wait_complete),
    .rt_critical_fail_store(rt_critical_fail_store),
    .fault_clear(fault_clear),
    .cmu_fault_clear(cmu_fault_clear),
    .power_seq_sm(power_seq_sm),
    .fault_power(fault_power),
    .stby_failure_detected(stby_failure_detected),
    .po_failure_detected(po_failure_detected),
    .rt_failure_detected(rt_failure_detected),
    .cpld_latch_sys_off(cpld_latch_sys_off),
    .turn_on_wait(turn_on_wait)
  );

  // -------------------------------------------------------------------------
  // 实例化 pwrseq_slave
  // -------------------------------------------------------------------------
  pwrseq_slave #(
    .SHARED_P5V_STBY_HPMOS(1'b1),
    .S5DEV_STUCKON_FAULT_CHK(1'b0),
    .NUM_CPU(`NUM_CPU),
    .NUM_OPT_AUX(0)
  ) pwrseq_slave_inst (
    .clk(clk_50m),
    .reset(~pon_reset_n),
    .t1us(t1us_tick),
    .t512us(t512us_tick),
    .t1ms(t1ms_tick),
    .t2ms(t2ms_tick),
    .t64ms(t64ms_tick),
    .t1s(t1s_tick),

    .keep_alive_on_fault(1'b0),

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

    // PG inputs (来自 TB 电源模型)
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
    .i_cpu_prsnt_n({1'b1, 1'b1}),

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
    .p5v_fault_det(w_p5v_fault_det)
  );

  // -------------------------------------------------------------------------
  // TB 内部：更细化的 PG 模型（根据 slave 的各使能产生对应 PG）
  // -------------------------------------------------------------------------
  initial begin
    // init PGs low
    db_i_pwrgd_p3v3_stby = 0;
    db_i_pgd_p0_vdd_18_stby = 0;
    db_i_pgd_p1_vdd_18_stby = 0;
    db_i_pgd_p0_vddc = 0;
    db_i_pgd_p1_vddc = 0;
    db_i_pgd_p0_vdd_11_sus = 0;
    db_i_pgd_p1_vdd_11_sus = 0;
    db_i_pgd_p0_vddio = 0;
    db_i_pgd_p1_vddio = 0;
    db_i_pgd_p0_vdd_soc_0 = 0;
    db_i_pgd_p1_vdd_soc_0 = 0;
    db_i_pgd_p0_vdd_core_0 = 0;
    db_i_pgd_p1_vdd_core_0 = 0;
    db_i_pgd_p0_vdd_core_1 = 0;
    db_i_pgd_p1_vdd_core_1 = 0;
    db_i_p0_pwrgd_out = 0;
    db_i_p1_pwrgd_out = 0;
  end

  // group B 3.3V S5
  always @(posedge w_grp_b_p0_33_s5_en) begin
    #800; db_i_pgd_p0_vddc <= 1;
  end
  always @(negedge w_grp_b_p0_33_s5_en) begin
    #10; db_i_pgd_p0_vddc <= 0;
  end
  always @(posedge w_grp_b_p1_33_s5_en) begin
    #800; db_i_pgd_p1_vddc <= 1;
  end
  always @(negedge w_grp_b_p1_33_s5_en) begin
    #10; db_i_pgd_p1_vddc <= 0;
  end

  // group B 1.8V S5
  always @(posedge w_grp_b_p0_18_s5_en) begin
    #800; db_i_pgd_p0_vdd_18_stby <= 1;
  end
  always @(negedge w_grp_b_p0_18_s5_en) begin
    #10; db_i_pgd_p0_vdd_18_stby <= 0;
  end
  always @(posedge w_grp_b_p1_18_s5_en) begin
    #800; db_i_pgd_p1_vdd_18_stby <= 1;
  end
  always @(negedge w_grp_b_p1_18_s5_en) begin
    #10; db_i_pgd_p1_vdd_18_stby <= 0;
  end

  // p5v_stby
  always @(posedge w_p5v_stby_en) begin
    #500;
    db_i_pwrgd_p3v3_stby <= 1;
  end
  always @(negedge w_p5v_stby_en) begin
    #10;
    db_i_pwrgd_p3v3_stby <= 0;
  end

  // grp C (vdd11 sus)
  always @(posedge w_grp_c_p0_vdd11_en) begin
    #1200; db_i_pgd_p0_vdd_11_sus <= 1;
  end
  always @(negedge w_grp_c_p0_vdd11_en) begin
    #10; db_i_pgd_p0_vdd_11_sus <= 0;
  end
  always @(posedge w_grp_c_p1_vdd11_en) begin
    #1200; db_i_pgd_p1_vdd_11_sus <= 1;
  end
  always @(negedge w_grp_c_p1_vdd11_en) begin
    #10; db_i_pgd_p1_vdd_11_sus <= 0;
  end

  // grp D VDDIO / SOC / VDDCORE
  always @(posedge w_grp_d_p0_vddio_en) begin
    #1000; db_i_pgd_p0_vddio <= 1;
  end
  always @(negedge w_grp_d_p0_vddio_en) begin
    #10; db_i_pgd_p0_vddio <= 0;
  end
  always @(posedge w_grp_d_p1_vddio_en) begin
    #1000; db_i_pgd_p1_vddio <= 1;
  end
  always @(negedge w_grp_d_p1_vddio_en) begin
    #10; db_i_pgd_p1_vddio <= 0;
  end

  always @(posedge w_grp_d_p0_soc_en) begin
    #1000; db_i_pgd_p0_vdd_soc_0 <= 1;
  end
  always @(negedge w_grp_d_p0_soc_en) begin
    #10; db_i_pgd_p0_vdd_soc_0 <= 0;
  end
  always @(posedge w_grp_d_p1_soc_en) begin
    #1000; db_i_pgd_p1_vdd_soc_0 <= 1;
  end
  always @(negedge w_grp_d_p1_soc_en) begin
    #10; db_i_pgd_p1_vdd_soc_0 <= 0;
  end

  always @(posedge w_grp_d_p0_vddcore0_en) begin
    #1500; db_i_pgd_p0_vdd_core_0 <= 1;
  end
  always @(negedge w_grp_d_p0_vddcore0_en) begin
    #10; db_i_pgd_p0_vdd_core_0 <= 0;
  end
  always @(posedge w_grp_d_p1_vddcore0_en) begin
    #1500; db_i_pgd_p1_vdd_core_0 <= 1;
  end
  always @(negedge w_grp_d_p1_vddcore0_en) begin
    #10; db_i_pgd_p1_vdd_core_0 <= 0;
  end

  always @(posedge w_grp_d_p0_vddcore1_en) begin
    #1500; db_i_pgd_p0_vdd_core_1 <= 1;
  end
  always @(negedge w_grp_d_p0_vddcore1_en) begin
    #10; db_i_pgd_p0_vdd_core_1 <= 0;
  end
  always @(posedge w_grp_d_p1_vddcore1_en) begin
    #1500; db_i_pgd_p1_vdd_core_1 <= 1;
  end
  always @(negedge w_grp_d_p1_vddcore1_en) begin
    #10; db_i_pgd_p1_vdd_core_1 <= 0;
  end

  // 当 main power (w_p12_en) 上升，补充并保证 CPU PWROK 在主电源稳定后置位（冗余）
  always @(posedge w_p12_en) begin
    #2000;
    db_i_p0_pwrgd_out <= 1;
    db_i_p1_pwrgd_out <= 1;
  end
  always @(negedge w_p12_en) begin
    #10;
    db_i_p0_pwrgd_out <= 0;
    db_i_p1_pwrgd_out <= 0;
  end

  // -------------------------------------------------------------------------
  // 时钟、tick 生成
  // -------------------------------------------------------------------------
  initial begin
    clk_50m = 0;
    forever #10 clk_50m = ~clk_50m; // 50MHz
  end

  always #1 t1us_tick = ~t1us_tick;
  always #256 t512us_tick = ~t512us_tick;
  always #1000 t1ms_tick = ~t1ms_tick;
  always #2000 t2ms_tick = ~t2ms_tick;
  always #32000 t32ms_tick = ~t32ms_tick;
  always #64000 t64ms_tick = ~t64ms_tick;
  always #256000 t256ms_tick = ~t256ms_tick;
  always #512000 t512ms_tick = ~t512ms_tick;
  always #1000000 t1s_tick = ~t1s_tick;

  // -------------------------------------------------------------------------
  // 测试流程与断言（按 pwrseq_slave 的 enable 顺序做 PG 驱动，并断言 master 状态序列）
  // -------------------------------------------------------------------------
  // 上电期望序列（按 pwrseq_master 中的状态机会走的常见上电顺序）
  reg [5:0] expected_up_seq [0:18];
  integer up_len = 19;
  integer up_idx;

  initial begin
    expected_up_seq[0]  = SM_EN_GRP_A;
    expected_up_seq[1]  = SM_RSMRST_DISABLE;
    expected_up_seq[2]  = SM_EN_GRP_B_33_S5;
    expected_up_seq[3]  = SM_EN_GRP_B_18_S5;
    expected_up_seq[4]  = SM_EN_P5V_STBY;
    expected_up_seq[5]  = SM_EN_RSMRST_RELEASE;
    expected_up_seq[6]  = SM_OFF_STANDBY;
    expected_up_seq[7]  = SM_PS_ON;
    expected_up_seq[8]  = SM_EN_TELEM;
    expected_up_seq[9]  = SM_EN_MAIN_EFUSE;
    expected_up_seq[10] = SM_EN_GRP_ATX;
    expected_up_seq[11] = SM_EN_GRP_C;
    expected_up_seq[12] = SM_EN_GRP_D_VDDIO;
    expected_up_seq[13] = SM_EN_GRP_D_SOC;
    expected_up_seq[14] = SM_EN_GRP_D_VDDCORE0;
    expected_up_seq[15] = SM_EN_GRP_D_VDDCORE1;
    expected_up_seq[16] = SM_EN_PGOOD_RELEASE;
    expected_up_seq[17] = SM_WAIT_POWEROK;
    expected_up_seq[18] = SM_STEADY_PWROK;
    up_idx = 0;
  end

  reg seq_started;
  reg powered;

  initial begin
    // init ctl signals
    pon_reset_n = 0;
    allow_recovery = 0;
    aux_video_holdoff = 0;
    pgood_rst_mask = 0;
    pwron_override_n = 1;
    bmc_clr_stby_tmout_n = 1;
    sys_sw_in_n = 1;
    pch_slp4_n = 1;
    p0_pwrbtn_n = 1;
    pch_thermtrip_n = 2'b11;
    cpu_thermtrip_fault_det = 2'b00;
    xr_ps_en = 1;
    interlock_broken = 0;
    seq_started = 0;
    powered = 0;

    #200; pon_reset_n = 1;
    #500;

    // 触发上电（短按）
    $display("%0t: TB: press power button -> start sequence", $time);
    sys_sw_in_n = 0;
    #100 sys_sw_in_n = 1;
    seq_started = 1;

    // 等待到达 SM_STEADY_PWROK 或超时
    wait_for_state_or_fail(SM_STEADY_PWROK, 50_000_000); // 50 ms timeout scaled
    powered = 1;
    $display("%0t: TB: reached SM_STEADY_PWROK", $time);

    // 等待一段运行时间，再触发关机
    #50000;
    $display("%0t: TB: press power button -> request shutdown", $time);
    sys_sw_in_n = 0;
    #100 sys_sw_in_n = 1;

    // 断言：必须看到 SM_DISABLE_PWRGD 并最终回到 SM_OFF_STANDBY
    wait_for_state_or_fail(SM_DISABLE_PWRGD, 50_000_000);
    $display("%0t: TB: observed SM_DISABLE_PWRGD", $time);
    wait_for_state_or_fail(SM_OFF_STANDBY, 100_000_000);
    $display("%0t: TB: system returned to SM_OFF_STANDBY (shutdown OK)", $time);

    #100 $finish;
  end

  // 当状态变化时，若处于序列监控，按 expected_up_seq 校验顺序
  reg [5:0] prev_state;
  always @(posedge clk_50m) begin
    if (power_seq_sm !== prev_state) begin
      $display("%0t: master state %0d -> %0d", $time, prev_state, power_seq_sm);
      // 如果序列已启动并还在上电期望范围内，校验顺序
      if (seq_started && !powered) begin
        if (up_idx < up_len) begin
          if (power_seq_sm !== expected_up_seq[up_idx]) begin
            $fatal("%0t: SEQ ERROR - expected %0d but got %0d at index %0d", $time, expected_up_seq[up_idx], power_seq_sm, up_idx);
          end else begin
            $display("%0t: SEQ OK - reached expected state %0d (index %0d)", $time, power_seq_sm, up_idx);
            up_idx = up_idx + 1;
          end
        end
      end
      prev_state <= power_seq_sm;
    end
  end

  // helper task: wait for specific state with timeout (time units ns)
  task automatic wait_for_state_or_fail(input [5:0] target, input integer timeout_ns);
    time start_t;
    begin
      start_t = $time;
      while (power_seq_sm !== target) begin
        #1000;
        if (($time - start_t) > timeout_ns) begin
          $fatal("%0t: TIMEOUT waiting for state %0d (timeout %0t ns)", $time, target, timeout_ns);
        end
      end
    end
  endtask

  // ---------------- existing assertion helpers ----------------
  // 保留对 w_p5v_stby_en/w_p12_en 的原有断言（PG 到位检查）
  reg seen_p5v;
  reg seen_p12;
  initial begin seen_p5v = 0; seen_p12 = 0; end

  always @(posedge w_p5v_stby_en) begin
    seen_p5v <= 1;
    $display("%0t: observed w_p5v_stby_en asserted", $time);
    fork
      begin
        #2000;
        if (db_i_pwrgd_p3v3_stby !== 1) $fatal("%0t: PG TIMEOUT - db_i_pwrgd_p3v3_stby not asserted", $time);
        else $display("%0t: db_i_pwrgd_p3v3_stby asserted (ok)", $time);
      end
    join_none
  end

  always @(posedge w_p12_en) begin
    seen_p12 <= 1;
    $display("%0t: observed w_p12_en asserted", $time);
    fork
      begin
        #5000000;
        if (!(db_i_p0_pwrgd_out && db_i_p1_pwrgd_out)) $fatal("%0t: CPU PWROK TIMEOUT", $time);
        else $display("%0t: CPU PWROK asserted (ok)", $time);
      end
    join_none
  end

endmodule