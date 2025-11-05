
module system_rst(
input  wire i_clk,
input  wire i_rst_n,
input  wire i_clk_20ms,

input  wire i_RST_DBP_RST_CO_R_N,
input  wire i_bmc_ctl_sys_rst,    //to generate 500ms pulse

output wire o_bmc_ctl_sys_rst_done,
output wire o_RST_SYS_BTN_OUT_PLD_N
);

//////////////////////////////////////////////////////////////
// reg r_bmc_ctl_sys_rst_st;
reg r_bmc_ctl_sys_rst_done;
reg [5:0] r_bmc_ctl_sys_rst_cnt;

//////////////////////////////////////////////////////////////
wire w_bmc_ctl_sys_rst_n;
wire w_RST_DBP_RST_CO_R_N;
//////////////////////////////////////////////////////////////
assign o_bmc_ctl_sys_rst_done  = r_bmc_ctl_sys_rst_done;
assign w_bmc_ctl_sys_rst_n     = ((r_bmc_ctl_sys_rst_cnt >= 5) && (r_bmc_ctl_sys_rst_cnt <= 31)) ? 1'b0 : 1'b1;
assign o_RST_SYS_BTN_OUT_PLD_N = w_bmc_ctl_sys_rst_n && w_RST_DBP_RST_CO_R_N;
//////////////////////////////////////////////////////////////
/*
always@(posedge i_clk or negedge i_rst_n) 
begin
	if(~i_rst_n)
	begin
		r_bmc_ctl_sys_rst_st  <= 1'b0;
	end
	else if(r_bmc_ctl_sys_rst_done)
		r_bmc_ctl_sys_rst_st  <= 1'b0;
	else
		r_bmc_ctl_sys_rst_st  <= i_bmc_ctl_sys_rst;
end
*/

////////////////////////////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)    
	begin
		r_bmc_ctl_sys_rst_cnt   <= 6'd0; 
		r_bmc_ctl_sys_rst_done  <= 1'b0;
	end
	else 
    begin
		if(~i_bmc_ctl_sys_rst) 
		begin
			r_bmc_ctl_sys_rst_cnt   <= 6'd0;
			r_bmc_ctl_sys_rst_done  <= 1'b0;		
		end
		else if(r_bmc_ctl_sys_rst_cnt >= 50)
		begin
			r_bmc_ctl_sys_rst_cnt  <= r_bmc_ctl_sys_rst_cnt;
			r_bmc_ctl_sys_rst_done <= 1'b1;
		end
		else if(i_clk_20ms)
			r_bmc_ctl_sys_rst_cnt  <= r_bmc_ctl_sys_rst_cnt + 1;
        else
            r_bmc_ctl_sys_rst_cnt  <= r_bmc_ctl_sys_rst_cnt;     		
	end
end

//////////////////////////////////////////////////////////////////////
lowpass_filter#(
.TOTAL_STAGES         ('d3),
.INIT_VALUE           (1'b1)
)lowpass_filter_U0
(
.i_clk                (i_clk),
.i_rst_n              (i_rst_n),
.i_filter_en          (i_clk_20ms),
.i_data_in            (i_RST_DBP_RST_CO_R_N),
.o_data_out           (w_RST_DBP_RST_CO_R_N)
);



endmodule 