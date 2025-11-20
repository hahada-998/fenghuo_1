`timescale 1ns/1ps

module tb_power_button;

    // Testbench signals
    reg         clk_50m;
    reg         pon_reset_n;
    reg         db_i_fm_pwrbtn_out_n_r;
    reg         w_st_steady_pwrok;
    wire        pch_pwrbtn;
    wire        pch_thrmtrip;
    logic   t1us_tick, t512us_tick, t2ms_tick, t32ms_tick, t256ms_tick, t512ms_tick, t1s_tick;
    
    // Clock generation
    initial begin
        clk_50m = 0;
        forever #10 clk_50m = ~clk_50m; // 50MHz clock
    end
    
    // Initial conditions
    initial begin
        pon_reset_n = 0;
        db_i_fm_pwrbtn_out_n_r = 1; // Not pressed
        w_st_steady_pwrok = 0;
        t1s_tick = 0;
    
        #50;
        pon_reset_n = 1; // Release reset
    
        #100;
        w_st_steady_pwrok = 1; // Set steady power OK
    
        // Simulate button press
        #200;
        db_i_fm_pwrbtn_out_n_r = 0; // Press button
        #1000;
        db_i_fm_pwrbtn_out_n_r = 1; // Release button
    
        // Simulate t1s tick
        #500;
        t1s_tick = 1;
        #20;
        t1s_tick = 0;
    
        #1000;
        $finish;
    end

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
    
    // Instantiate the power_button module

power_button #(
    .BL_MODE(1'b0)
) power_button_inst_local (
  .clk                   (clk_50m),
  .reset                 (~pon_reset_n),          // 模块 reset 为高有效 -> 取反 pon_reset_n
  
  .t1s                   (t512us_tick),
  .gpo_pwr_btn_mask      (1'b0),                  // 不屏蔽物理按键
  .xreg_pwr_btn_passthru (1'b0),                  // 未使用 BL passthru
  .xreg_vir_pwr_btn      (1'b0),                  // 未使用虚拟按键
  .defeat_pwr_btn_dis_n  (1'b1),                  // 维护开关不禁用按键（高=不禁用）
  .turn_on_override      (1'b0),                  // 不强制开机
  .sys_sw_in_n           (db_i_fm_pwrbtn_out_n_r),// 你的物理按键，低有效
  .gmt_shutdown          (1'b0),                  // 无 GMT shutdown
  .gmt_wakeup_n          (1'b1),                  // 无 wakeup（gmt_wakeup_n 低为唤醒）
  .cpu_thermtrip         (1'b0),
  .pch_thermtrip         (1'b0),
  .temp_deadly           (1'b0),
  .interlock_broken      (1'b0),
  .pch_slp4_n            (1'b1),                  // 非 SLP4
  .st_steady_pwrok       (w_st_steady_pwrok),     // 置 1 以允许 force_off -> THRMTRIP 生效
  .pch_pwrbtn            (pch_pwrbtn),            // 输出：按键指示（active-high）
  .pch_thrmtrip          (pch_thrmtrip)           // 输出：热断电指示（active-high）
);


endmodule