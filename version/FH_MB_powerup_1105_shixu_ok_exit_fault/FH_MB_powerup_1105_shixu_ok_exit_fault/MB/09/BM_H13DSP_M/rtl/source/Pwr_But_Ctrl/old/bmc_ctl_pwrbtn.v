// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * Engineer:        liuqi
// * Email:           liuqic@cloudnineinfo.com
// * Module Name:     bmc_ctl_pwrbtn
// * Project Name:    xxx
// * Description:     Module Function
// *    to generate power button signals and power button log;
// * Instances:       Modules included in this file
// *    <1> Edge_Detect 
// * Modification:    The content been modified
// *    2021-02-26: New Created

//1. bmc通过i2c寄存器写入cpu board；
//2. cpu board 通过lvds写入icb board;
//3. icb board 执行power button按键；
//4. icb board 通过lvds回传按键执行完成标志位给cpu board, cpu board 清除寄存器状态；

module bmc_ctl_pwrbtn(
input  i_clk,
input  i_rst_n,
input  i_clk_20ms,
input  i_pwrbtn_n,
input  i_slps4_n,

input  i_bmc_sbtn_poweron,     //generate 500ms pulse
input  i_bmc_lbtn_powerdown,   //generate 6s pulse
input  i_bmc_sbtn_powerdown,   //generate 500ms pulse
input  i_bmc_sbtn_wc     ,     // W0C
input  i_bmc_lbtn_wc     ,     // W0C
input  i_bmc_sbtn_sys_wc ,     // W0C

output o_bmc_sbtn_poweron_done,
output o_bmc_lbtn_powerdown_done,
output o_bmc_sbtn_powerdown_done,
output o_sbtn_pwron_evt   ,
output o_lbtn_pwrdown_evt ,
output o_sbtn_sysrst_evt  ,

output o_bmc_ctl_pwrbtn_n
);

//////////////////////////////////////////////////////////////
reg [5:0] r_sbtn_pwron_cnt;
reg [11:0] r_lbtn_pwrdown_cnt;
reg [5:0] r_sbtn_pwrdown_cnt;
reg r_bmc_sbtn_poweron_done;   
reg r_bmc_lbtn_powerdown_done;
reg r_bmc_sbtn_powerdown_done;

////////////////////////////////////////////////////////////// 
wire w_bmc_sbtn_pwron_n;
wire w_bmc_lbtn_pwrdown_n;
wire w_bmc_sbtn_pwrdown_n;

//////////////////////////////////////////////////////////////

assign o_bmc_sbtn_poweron_done   = r_bmc_sbtn_poweron_done  ;
assign o_bmc_lbtn_powerdown_done = r_bmc_lbtn_powerdown_done;
assign o_bmc_sbtn_powerdown_done = r_bmc_sbtn_powerdown_done;

assign o_bmc_ctl_pwrbtn_n      = w_bmc_sbtn_pwron_n & w_bmc_lbtn_pwrdown_n & w_bmc_sbtn_pwrdown_n; 

//////////////////////////////////////////////////////////////
//icb 执行power button动作；
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)    
	begin
		r_sbtn_pwron_cnt        <= 6'd0; 
		r_bmc_sbtn_poweron_done <= 1'b0;
	end
	else 
    begin
		if(~i_bmc_sbtn_poweron) 
		begin
			r_sbtn_pwron_cnt         <= 6'd0;
			r_bmc_sbtn_poweron_done  <= 1'b0;		
		end
		else if(r_sbtn_pwron_cnt >= 50)
		begin
			r_sbtn_pwron_cnt        <= r_sbtn_pwron_cnt;
			r_bmc_sbtn_poweron_done <= 1'b1;
		end
		else if(i_clk_20ms)
			r_sbtn_pwron_cnt  <= r_sbtn_pwron_cnt + 1;
        else
            r_sbtn_pwron_cnt  <= r_sbtn_pwron_cnt;     		
	end
end


always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)    
	begin
		r_lbtn_pwrdown_cnt        <= 12'd0; 
		r_bmc_lbtn_powerdown_done <= 1'b0;
	end
	else 
    begin
		if(~i_bmc_lbtn_powerdown) 
		begin
			r_lbtn_pwrdown_cnt         <= 12'd0;
			r_bmc_lbtn_powerdown_done  <= 1'b0;		
		end
		else if(r_lbtn_pwrdown_cnt >= 350)
		begin
			r_lbtn_pwrdown_cnt        <= r_lbtn_pwrdown_cnt;
			r_bmc_lbtn_powerdown_done <= 1'b1;
		end
		else if(i_clk_20ms)
			r_lbtn_pwrdown_cnt  <= r_lbtn_pwrdown_cnt + 1;
        else
            r_lbtn_pwrdown_cnt  <= r_lbtn_pwrdown_cnt;     		
	end
end



always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)    
	begin
		r_sbtn_pwrdown_cnt        <= 6'd0; 
		r_bmc_sbtn_powerdown_done <= 1'b0;
	end
	else 
    begin
		if(~i_bmc_sbtn_powerdown) 
		begin
			r_sbtn_pwrdown_cnt         <= 6'd0;
			r_bmc_sbtn_powerdown_done  <= 1'b0;		
		end
		else if(r_sbtn_pwrdown_cnt >= 50)
		begin
			r_sbtn_pwrdown_cnt        <= r_sbtn_pwrdown_cnt;
			r_bmc_sbtn_powerdown_done <= 1'b1;
		end
		else if(i_clk_20ms)
			r_sbtn_pwrdown_cnt  <= r_sbtn_pwrdown_cnt + 1;
        else
            r_sbtn_pwrdown_cnt  <= r_sbtn_pwrdown_cnt;     		
	end
end


assign w_bmc_sbtn_pwron_n   = ((r_sbtn_pwron_cnt >= 5) && (r_sbtn_pwron_cnt <= 31)) ? 1'b0 : 1'b1;
assign w_bmc_lbtn_pwrdown_n = ((r_lbtn_pwrdown_cnt >= 5) && (r_lbtn_pwrdown_cnt <= 305)) ? 1'b0 : 1'b1;
assign w_bmc_sbtn_pwrdown_n = ((r_sbtn_pwrdown_cnt >= 5) && (r_sbtn_pwrdown_cnt <= 31)) ? 1'b0 : 1'b1;

////////////////////////////////////////////////////////////////////////////////////
//button log
wire w_pwrbtn_pos;
wire w_pwrbtn_neg;

reg [11:0] r_pwrbtn_counter;
reg r_500ms_flag;
reg r_4s_flag;
reg r_sbtn_pwron_evt;
reg r_lbtn_pwrdown_evt;
reg r_sbtn_sysrst_evt;
reg r_slps4_state;
///////////////////////////////////////////////////////////////

assign o_sbtn_pwron_evt   = r_sbtn_pwron_evt  ;
assign o_lbtn_pwrdown_evt = r_lbtn_pwrdown_evt;
assign o_sbtn_sysrst_evt  = r_sbtn_sysrst_evt ;


//////////////////////////////////////////////////////////////


Edge_Detect Edge_Detect_u0(
.i_clk           (i_clk),           //input Clk
.i_rst_n         (i_rst_n),         //Global rst,Active Low
.i_signal        (i_pwrbtn_n),

.o_signal_pos    (w_pwrbtn_pos),
.o_signal_neg    (w_pwrbtn_neg),
.o_signal_invert ()
);

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
	begin
	    r_slps4_state  <= 1'b0;
	end
	else if(w_pwrbtn_neg)
	    r_slps4_state  <= i_slps4_n;
	else
	    r_slps4_state  <= r_slps4_state;

end



always@(posedge i_clk or negedge i_rst_n) 
begin
	if(~i_rst_n) begin 
		r_500ms_flag         <= 1'b0;
		r_4s_flag            <= 1'b0;
	end
	else begin 
		if((r_pwrbtn_counter >= 12'd200) && (w_pwrbtn_pos)) begin	
	        r_500ms_flag        <= 1'b0;	
			r_4s_flag           <= 1'b1;
		end
		else if(w_pwrbtn_pos ) begin  //20ms * 25 = 500ms 
			r_500ms_flag        <= 1'b1;	
			r_4s_flag           <= 1'b0;			  			
		end
		else begin
		    r_500ms_flag        <= 1'b0;	
			r_4s_flag           <= 1'b0;
		end
   end		
end

	
	
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n) begin
	    r_pwrbtn_counter <= 0;
	end
	else 
	begin
	    if(i_pwrbtn_n  )
		    r_pwrbtn_counter  <= 0;
		else if(i_clk_20ms & (r_pwrbtn_counter <= 1000)) // 20ms * 1000 = 20s
		    r_pwrbtn_counter  <= r_pwrbtn_counter + 1;
		else
		    r_pwrbtn_counter  <= r_pwrbtn_counter;	 
	 end
end




always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n) begin
	     r_sbtn_pwron_evt   <= 1'b0;	 
	 end
	 else begin 
		  if(~i_bmc_sbtn_wc)
		      r_sbtn_pwron_evt  <= 1'b0;
	     else if(r_500ms_flag && (~r_slps4_state))
		      r_sbtn_pwron_evt  <= 1'b1;
		  else
		      r_sbtn_pwron_evt  <= r_sbtn_pwron_evt;
	 end
end 

always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n) begin
	    r_sbtn_sysrst_evt   <= 1'b0;	 
	end
	else begin 
		if(~i_bmc_sbtn_sys_wc)
		    r_sbtn_sysrst_evt  <= 1'b0;
	    else if(r_500ms_flag & r_slps4_state)
		    r_sbtn_sysrst_evt  <= 1'b1;
		else
		    r_sbtn_sysrst_evt  <= r_sbtn_sysrst_evt;
	end
end 
	

always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin 
	     r_lbtn_pwrdown_evt	<= 1'b0;  
	end
	else begin
		if(~i_bmc_lbtn_wc)
		    r_lbtn_pwrdown_evt  <= 1'b0;
	    else if(r_4s_flag && r_slps4_state )
		    r_lbtn_pwrdown_evt  <= 1'b1; 
		else
		    r_lbtn_pwrdown_evt  <= r_lbtn_pwrdown_evt;
	end
end 	





endmodule 