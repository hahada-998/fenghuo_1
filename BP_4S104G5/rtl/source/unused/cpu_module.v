

module cpu_module(

input clk,
input reset,
input t512us,

input i_p0_pwrgood,
input i_p1_pwrgood,
input i_p0_rsmrset,
input i_p1_rsmrset,
input i_p0_pwr_btn_n,

output o_p0_pwrok,
output o_p1_pwrok,
output o_p0_pwrgoodout,
output o_p1_pwrgoodout,
output o_p0_slp_s3_n,
output o_p0_slp_s5_n,

output o_p0_prsnt_n,
output o_p1_prsnt_n

);




wire i_p0_pwrgood_delay_2ms;
wire i_p1_pwrgood_delay_2ms;
wire i_cpu_pwrok_delay_30ms;

reg r_p0_slp_s3_n;
reg r_p0_slp_s5_n;

edge_delay #(
  .CNTR_NBITS    (2)
) sb_cpu0_pgout_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t512us),
  .signal_in     (i_p0_pwrgood & (r_p0_slp_s3_n) & (r_p0_slp_s5_n)),
  .delay_output  (i_p0_pwrgood_delay_2ms)
);

edge_delay #(
  .CNTR_NBITS    (2)
) sb_cpu1_pgout_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (2'b10),
  .cnt_step      (t512us),
  .signal_in     (i_p1_pwrgood & (r_p0_slp_s3_n) & (r_p0_slp_s5_n)),
  .delay_output  (i_p1_pwrgood_delay_2ms)
);

edge_delay #(
  .CNTR_NBITS    (6)
) sb_cpu_pwrok_inst (
  .clk           (clk),
  .reset         (reset),
  .cnt_size      (6'h3C),//60*0.5=30ms
  .cnt_step      (t512us),
  .signal_in     (i_p0_pwrgood & (r_p0_slp_s3_n) & (r_p0_slp_s5_n)),
  .delay_output  (i_cpu_pwrok_delay_30ms)
);

reg r_p0_pwrok;
reg r_p1_pwrok;

always @(posedge reset or posedge clk)
begin
  if (reset)begin 
    r_p0_pwrok <= 1'b1;
	r_p1_pwrok <= 1'b1;
	end
	else begin
    r_p0_pwrok <= i_p0_pwrgood;//i_cpu_pwrok_delay_30ms;
	r_p1_pwrok <= i_p0_pwrgood;//i_cpu_pwrok_delay_30ms;	
	end
	
end

reg r_p0_pwrgood;
reg r_p1_pwrgood;


always @(posedge reset or posedge clk)
begin
  if (reset)begin 
    r_p0_pwrgood <= 1'b0;
	r_p1_pwrgood <= 1'b0;
	end
	else begin
    r_p0_pwrgood <= i_p0_pwrgood;
	r_p1_pwrgood <= i_p1_pwrgood;
	end
	
end


assign o_p0_pwrok = r_p0_pwrok;
assign o_p1_pwrok = r_p1_pwrok;

assign o_p0_pwrgoodout = reset ? 1'b0 : i_p0_pwrgood;//i_p0_pwrgood_delay_2ms ;
assign o_p1_pwrgoodout = reset ? 1'b0 : i_p1_pwrgood;//i_p1_pwrgood_delay_2ms ;


always @(posedge reset or negedge i_p0_pwr_btn_n)
begin
  if (reset)begin 
    r_p0_slp_s3_n <= 1'b0;
	r_p0_slp_s5_n <= 1'b0;
	end
	else begin
    r_p0_slp_s3_n <= ~r_p0_slp_s3_n;
	r_p0_slp_s5_n <= ~r_p0_slp_s5_n;	
	end
	
end

assign o_p0_slp_s3_n = r_p0_slp_s3_n;
assign o_p0_slp_s5_n = r_p0_slp_s5_n;


reg r_p0_prsnt_n;
reg r_p1_prsnt_n;

always @(posedge reset or posedge clk)
begin
  if (reset)begin 
    r_p0_prsnt_n <= 1'b1;
	r_p1_prsnt_n <= 1'b1;
	end
	else begin
    r_p0_prsnt_n <= 1'b0;	
	r_p1_prsnt_n <= 1'b0;
	end
end

assign o_p0_prsnt_n = r_p0_prsnt_n;
assign o_p1_prsnt_n = r_p1_prsnt_n;

endmodule 