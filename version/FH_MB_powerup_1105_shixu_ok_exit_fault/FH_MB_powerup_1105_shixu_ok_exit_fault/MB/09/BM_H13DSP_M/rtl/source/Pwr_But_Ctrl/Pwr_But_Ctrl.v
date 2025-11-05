//Pwr_But_Ctrl 是电源按钮控制的核心子模块，负责物理按钮防抖、长 / 短按判断、多源按钮信号融合，以及根据系统状态（S0/S5）和 BMC 激活状态输出到 PCH 的电源控制信号。

`timescale 1ns / 1ps

module Pwr_But_Ctrl #(parameter PWRBTN_LONG = 4 )
(
input  wire       i_clk   ,		//input Clk
input  wire       i_rst_n ,		//Global rst,Active Low
input  wire       i_20mSEC,
		          
input  wire       i_PWRBTN_OUT_disable,
		          
input  wire       i_disable_button,			// 1'b1 is disable, 1'b0 is enable;  1'b1 for General items.
input  wire       i_BMC_active0_n,             // 1'b1: BMC die,  1'b0: BMC active, default low when AC in;  if no function of BMC controled power on, this signal shuold 1'b1.
input  wire       i_FP_PWR_BTN_MUX_N,			//Power Button
		          
input  wire       i_FM_BMC_PWRBTN_OUT_CPLD_N,	//Power on/off signal from BMC
input  wire       i_DBP_POWER_BTN_N         ,	//Power on/off signal from DBP 
		          
		          
input  wire       i_state_s0,
input  wire       i_state_s5,
		          
input  wire       i_bmc_clear_data    ,        //high pulse for BMC clear latch data
input  wire       i_BMC_active1_n     ,        // 1'b1: BMC die,  1'b0: BMC active, default high when AC in
output wire       o_pwrbtn_short      ,
output wire       o_pwrbtn_long       ,
output wire [3:0] o_PWRBTN_state      ,
output wire [1:0] o_pwr_btn_state     ,
output wire       o_pwr_btn_dly       ,

output wire       o_FM_BMC_PWRBTN_OUT_B_N		//Power on/off signal to PCH

);

// 1. 滤波后按钮信号：存储3路按钮（物理/ BMC/ DBP）经防抖滤波后的稳定信号
wire w_PWR_BTN_Filter;    // 物理按钮（ i_FP_PWR_BTN_MUX_N ）滤波后信号
wire w_BMC_PWR_BTN_Filter;// BMC按钮（i_FM_BMC_PWRBTN_OUT_CPLD_N）滤波后信号
wire w_DBP_POWER_filter;  // DBP扩展板按钮（i_DBP_POWER_BTN_N）滤波后信号

// 2. 按钮有效信号：直接映射滤波后信号（可扩展增加“信号有效性判断”，如电平超时检测）
wire w_PWR_BTN_GD;     // 物理按钮有效信号（=w_PWR_BTN_Filter）
wire w_BMC_PWR_BTN_GD; // BMC按钮有效信号（=w_BMC_PWR_BTN_Filter）
wire w_DBP_POWER_GD;   // DBP按钮有效信号（=w_DBP_POWER_filter）
wire w_PWR_BTN_OUT;    // 3路按钮信号“与融合”后的总信号（判断是否触发开关机）

// 3. 按钮控制使能信号：判断当前系统状态是否允许按钮操作
wire w_Pwrbtn_control;  

// 4. 按钮边沿检测寄存器：用于捕捉按钮信号的上升沿/下降沿（判断按下/松开动作）
reg r_pwr_btn_dly1, r_pwr_btn_dly2;  // 物理按钮信号的1级/2级延时寄存器
wire w_pwr_btn_neg, w_pwr_btn_pos;   // 物理按钮的下降沿（按下）/上升沿（松开）检测信号

// 5. 电源状态寄存器：存储当前系统的电源操作状态（如“关机中”“开机中”）
reg [1:0] r_power_state;


//1. 按钮防抖逻辑（lowpass_filter模块）
//物理按钮按下 / 松开时会有机械抖动（通常 10~20ms），直接采样会导致误判，模块通过 3 级低通滤波（lowpass_filter）消除抖动：
lowpass_filter #
(
    .TOTAL_STAGES           ( 3 ),// 3级滤波（需连续3次采样一致才确认状态）
    .INIT_VALUE             (1'b1)// 初始值为1（按钮未按下时为高电平）
)PwrBtn_Filter
(
    .i_clk             ( i_clk ),
    .i_rst_n           ( i_rst_n ),
    .i_filter_en       ( i_20mSEC ),// 20ms使能（每20ms采样一次）
    .i_data_in         ( i_FP_PWR_BTN_MUX_N ),// 原始按钮信号
    .o_data_out        ( w_PWR_BTN_Filter )
);

lowpass_filter #
(
    .TOTAL_STAGES           ( 3 ),
    .INIT_VALUE             (1'b1)
)BMC_PwrBtn_Filter
(
    .i_clk             ( i_clk ),
    .i_rst_n           ( i_rst_n ),
    .i_filter_en       ( 1'b1 ),
    .i_data_in         ( i_FM_BMC_PWRBTN_OUT_CPLD_N ),
    .o_data_out        ( w_BMC_PWR_BTN_Filter )
);

lowpass_filter #
(
    .TOTAL_STAGES           ( 3 ),
    .INIT_VALUE             (1'b1)
)DBP_BTN_Filter
(
    .i_clk             ( i_clk ),
    .i_rst_n           ( i_rst_n ),
    .i_filter_en       ( 1'b1 ),
    .i_data_in         ( i_DBP_POWER_BTN_N ),
    .o_data_out        ( w_DBP_POWER_filter )
);

//有效信号映射：直接将滤波后的信号作为“有效信号”（无额外判断，可扩展增加电平校验）
assign w_PWR_BTN_GD     = w_PWR_BTN_Filter;    // 物理按钮滤波后即视为有效
assign w_BMC_PWR_BTN_GD = w_BMC_PWR_BTN_Filter;// BMC按钮滤波后即视为有效
assign w_DBP_POWER_GD   = w_DBP_POWER_filter;  // DBP按钮滤波后即视为有效

//3路按钮信号融合：采用“与逻辑”，只有3路均为同一状态（高/低）时，总信号才生效
assign w_PWR_BTN_OUT    = w_PWR_BTN_GD & w_BMC_PWR_BTN_GD & w_DBP_POWER_GD;

// 按钮操作使能判断：当前系统状态是否允许按钮操作
// 逻辑拆解：
// - 场景1：系统在S0（运行）状态 + 物理按钮未禁用（~i_disable_button=1）→ 允许按钮操作（关机/复位）
// - 场景2：系统在S5（休眠）状态 + BMC未激活（i_BMC_active0_n=1）→ 允许按钮操作（开机）
// - 两种场景满足其一，即允许按钮操作（w_Pwrbtn_control=1）
assign w_Pwrbtn_control = (i_state_s0 &  (~i_disable_button )) || (i_state_s5 &  i_BMC_active0_n);

wire w_FM_BMC_PWRBTN_OUT_B_N_pre;
// 到PCH的控制信号预生成：结合“操作使能”与“3路按钮融合信号”
assign w_FM_BMC_PWRBTN_OUT_B_N_pre =  (w_Pwrbtn_control?w_PWR_BTN_GD :1'b1)
                                     & w_BMC_PWR_BTN_GD 
							         & w_DBP_POWER_GD ;
                              
// 最终输出到PCH的控制信号：增加“输出禁用”开关（ i_PWRBTN_OUT_disable =1时强制输出高电平，禁用操作）
// 逻辑： i_PWRBTN_OUT_disable=0 → 输出预生成信号；i_PWRBTN_OUT_disable=1 → 输出1（不触发PCH操作）
assign o_FM_BMC_PWRBTN_OUT_B_N = (~i_PWRBTN_OUT_disable)?w_FM_BMC_PWRBTN_OUT_B_N_pre:1'b1;  //2023-11-20 add back
                                
//=long/short press====================================================================================================
reg r_Pwrbtn_short = 1'b0;
reg r_Pwrbtn_long  = 1'b0;

reg [7:0] r_cnt_pwr_btn;

reg [7:0] r_cnt_100ms;
reg r_clk_100ms;

//2. 长 / 短按判断逻辑（基于PWRBTN_LONG）

// 1. 100ms时钟生成（5个20ms周期=100ms）
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n) 
    begin
        r_cnt_100ms <= 8'd0;
	    r_clk_100ms <= 1'b0;
    end
	else 
	begin
        if(r_cnt_100ms==8'd5)
            r_cnt_100ms <= 8'd0;
		else if(i_20mSEC)
			r_cnt_100ms <= r_cnt_100ms+8'd1;
		else
			r_cnt_100ms <= r_cnt_100ms;
		
		if(r_cnt_100ms==8'd5)// 每100ms输出一个脉冲
			r_clk_100ms <= 1'b1;
		else
			r_clk_100ms <= 1'b0;
	end
end


// 物理按钮信号两级延时：用于边沿检测（消除毛刺，稳定捕捉边沿）
always@(posedge i_clk or negedge i_rst_n) 
begin
	if(!i_rst_n)  // 复位状态：两级延时寄存器均置1（对应按钮未按下时的高电平）
	begin
		r_pwr_btn_dly1  <= 1'b1;  // 1级延时（当前周期的滤波后信号）
		r_pwr_btn_dly2  <= 1'b1;  // 2级延时（上一周期的滤波后信号）
	end
	else  // 正常工作：每时钟周期更新延时寄存器（移位操作）
    begin
        r_pwr_btn_dly1 <= w_PWR_BTN_Filter;    // 1级延时 = 当前滤波后信号
        r_pwr_btn_dly2 <= r_pwr_btn_dly1 ;     // 2级延时 = 上一周期的1级延时信号
    end
end

// 下降沿检测（按钮按下）：上一周期为高（r_pwr_btn_dly2=1），当前周期为低（r_pwr_btn_dly1=0）
assign w_pwr_btn_neg = (!r_pwr_btn_dly1) && (r_pwr_btn_dly2) ;

// 上升沿检测（按钮松开）：上一周期为低（r_pwr_btn_dly2=0），当前周期为高（r_pwr_btn_dly1=1）
assign w_pwr_btn_pos = r_pwr_btn_dly1 && (!r_pwr_btn_dly2) ;

// 时钟周期	w_PWR_BTN_Filter（当前信号）	r_pwr_btn_dly1（1 级延时）	r_pwr_btn_dly2（2 级延时）	w_pwr_btn_neg（下降沿）	 动作解读
// 1	             1（未按下）	                    1	                         1	                   0	              无动作
// 2	             0（按下）	                        0	                         1	                   1（高脉冲）	       按钮按下
// 3	             0（保持按下）	                    0	                         0	                   0	               无动作

// 2. 按键计数与长/短按判断
always@(posedge i_clk or negedge i_rst_n) 
begin
	if(!i_rst_n) 
	begin
		r_cnt_pwr_btn  <= 8'h00;    // 按键计数寄存器
		r_Pwrbtn_short <= 1'b0;     // 短按标志
		r_Pwrbtn_long  <= 1'b0;     // 长按标志
	end
	else begin
		// 按键松开时（下降沿），计数清零
		if(w_pwr_btn_neg) 					          r_cnt_pwr_btn	<= 8'h00;
		// 计数达到阈值（PWRBTN_LONG×10+1），停止计数
		else if ( r_cnt_pwr_btn == (PWRBTN_LONG*10 +1))  r_cnt_pwr_btn	<= r_cnt_pwr_btn ;
		// 按键按下且100ms脉冲到来，计数+1
		else if ( (~w_PWR_BTN_Filter) & r_clk_100ms   )    r_cnt_pwr_btn	<= r_cnt_pwr_btn + 1'b1 ;
        else                                          r_cnt_pwr_btn	<= r_cnt_pwr_btn ;

		// 按键按下（上升沿）且BMC激活，判断长/短按
		if(w_pwr_btn_pos & (~i_BMC_active1_n  ) ) 
		begin
			// 计数≤PWRBTN_LONG×10（4×10=40 → 40×100ms=4s？此处需注意：原代码可能存在笔误，应为PWRBTN_LONG×1 → 4×100ms=400ms）
			if(r_cnt_pwr_btn<=(PWRBTN_LONG*10) )   r_Pwrbtn_short  <=1'b1;
			// 计数达到PWRBTN_LONG×10+1，判定为长按
			if(r_cnt_pwr_btn==(PWRBTN_LONG*10 +1)) r_Pwrbtn_long   <=1'b1;
		end
		 // BMC清除信号到来，清除长/短按标志
	    else if(i_bmc_clear_data)
		begin
		    r_Pwrbtn_short <= 1'b0;
		    r_Pwrbtn_long  <= 1'b0;			
		end
		else         
		begin
		    r_Pwrbtn_short <= r_Pwrbtn_short;
		    r_Pwrbtn_long  <= r_Pwrbtn_long ;		
		end
	end
end
//100ms 计时：通过r_cnt_100ms对 20ms 使能计数，每 5 次（100ms）生成一个r_clk_100ms脉冲，作为计数基准；
//长 / 短按阈值：PWRBTN_LONG=4时，短按≤4×100ms=400ms，长按＞400ms（原代码PWRBTN_LONG×10可能为笔误，需结合实际需求调整）；
//标志锁存：检测到长 / 短按后，锁存标志（r_Pwrbtn_short/r_Pwrbtn_long），直到i_bmc_clear_data清除，避免重复触发。

// 短按标志输出：1=检测到短按，0=无短按
assign o_pwrbtn_short = r_Pwrbtn_short ;

// 长按标志输出：1=检测到长按，0=无长按
assign o_pwrbtn_long  = r_Pwrbtn_long  ;
//========================================================== 

//power state===============================================
// 电源状态机：根据按钮边沿和系统当前状态，更新电源操作状态
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin  // 复位状态：状态置为2'b11（初始空闲状态）
		r_power_state		<= 2'b11;
	end
	else begin
		// 场景1：按钮松开（w_pwr_btn_neg=1）+ 系统在S0（运行）+ BMC激活（~i_BMC_active1_n=1）
		// 动作：触发关机，状态置为2'b01（S0→关机中）
		if(w_pwr_btn_neg && i_state_s0 && (~i_BMC_active1_n ))
			r_power_state	<= 2'b01;
		
		// 场景2：按钮松开（w_pwr_btn_neg=1）+ 系统不在S0（如S5）+ BMC激活（~i_BMC_active1_n=1）
		// 动作：触发开机，状态置为2'b00（S5→开机中）
		else if(w_pwr_btn_neg && ~i_state_s0 && (~i_BMC_active1_n ))
			r_power_state	<= 2'b00;
		
		// 场景3：BMC清除信号（i_bmc_clear_data=1）→ 状态复位为2'b11（空闲状态）
		else if(i_bmc_clear_data) 
			r_power_state	<= 2'b11;
		
		// 其他场景：状态保持不变（如按钮未松开、BMC未激活）
		else
			r_power_state	<= r_power_state;
	end
end
// assign o_PWRBTN_state = {r_power_state,r_Pwrbtn_short,r_Pwrbtn_long};
// 4位电源状态输出：整合“电源操作状态”+“长按标志”+“短按标志”，供下游模块（如BMC）读取
// 格式：{r_power_state（2位）, r_Pwrbtn_long（1位）, r_Pwrbtn_short（1位）}
assign o_PWRBTN_state = {r_power_state,r_Pwrbtn_long,r_Pwrbtn_short};  
// r_power_state	状态含义	触发条件	                                  作用
// 2'b11	         空闲状态	复位或 BMC 清除	                    标识当前无电源操作，可接受新操作
// 2'b01	         关机中	    S0 状态下按钮松开 + BMC 激活	    通知下游模块（如 PCH）执行关机时序
// 2'b00	         开机中   	非 S0 状态下按钮松开 + BMC 激活	    通知下游模块（如 PCH）执行开机时序

//==========================================================


///////////////////////////////////////2023-6-1 add //////////////////////////////////////////////////////////////////////////////////////////////////
// 1. AC上电初始化计数器：记录AC上电后的时间（单位：20ms），最大计数4550（对应91s）
// 注释说明：20ms × 4550 = 91s，2023-6-5版本将原40s计时调整为90s（实际最大计时91s，预留1s过渡）
reg [12:0] r_ac_init_cnt ; 


// 2. 电源按钮阶段状态寄存器：标识当前处于AC上电后的哪个阶段（共4个阶段，2位足够表示）
reg [1:0] r_pwr_btn_state;

// 3. 按钮控制寄存器：
reg r_pwr_btn;        // 最终用于控制的按钮信号（输出到下游逻辑）
reg r_pwr_btn_dly;    // 按钮延时信号（用于特定阶段的操作锁存）

// timer cnt ：AC上电计时器，累计上电后的时间（单位：20ms）
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin  // 复位状态：计时器清零（上电初始时刻，时间从0开始）
		r_ac_init_cnt		<= 13'd0;
	end
	else begin
		// 场景1：计数达到最大值4550（对应91s）→ 停止计数（保持最大值，避免溢出）
		if(r_ac_init_cnt >= 13'd4550)   //20ms * 4550 = 91s（计时终点）
		    r_ac_init_cnt	<= r_ac_init_cnt;
		// 场景2：未到最大值，且20ms使能信号有效（每20ms触发一次）→ 计数+1
		else if(i_20mSEC )
		    r_ac_init_cnt	<= r_ac_init_cnt + 1;
		// 场景3：20ms使能无效→ 计数保持不变（确保计时仅在20ms周期更新）
		else 
		    r_ac_init_cnt	<= r_ac_init_cnt;
	end
end
// 计时逻辑拆解（关键时间点）：
// 计数（r_ac_init_cnt）	对应时间（20ms × 计数）	    阶段意义
// 0	                     0s	                     上电复位完成，计时开始
// 500	                     10s（20ms×500）	     硬件初始化第一阶段结束
// 4500	                     90s（20ms×4500）	     硬件初始化第二阶段结束
// 4550	                     91s（20ms×4550）	     上电初始化全部完成


//pwr_on stage 根据 r_ac_init_cnt 的计数结果，将 AC 上电后分为4 个阶段，通过 r_pwr_btn_state 标识，为不同阶段的按钮控制提供依据
// pwr_on stage ：根据AC上电计时，划分按钮的4个工作阶段
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin  // 复位状态：默认处于阶段0（上电初始阶段）
		r_pwr_btn_state		<= 2'd0;
	end
	else begin
		// 阶段0：计时<500（<10s）→ 硬件初始化初期，禁止按钮操作
		if(r_ac_init_cnt < 13'd500)   //< 10s
		    r_pwr_btn_state	<= 2'd0;
		// 阶段1：计时500~4499（10s~90s）→ 硬件部分就绪，允许有限按钮操作
		else if(r_ac_init_cnt < 13'd4500 && r_ac_init_cnt >= 13'd500 ) // 10s-90s
		    r_pwr_btn_state	<= 2'd1;
		// 阶段2：计时4500~4549（90s~91s）→ 硬件即将完全就绪，过渡阶段
		else if(r_ac_init_cnt < 13'd4550 && r_ac_init_cnt >= 13'd4500 ) // 90s-91s
		    r_pwr_btn_state	<= 2'd2;
		// 阶段3：计时≥4550（>91s）→ 硬件完全就绪，允许正常按钮操作
		else if(r_ac_init_cnt >= 13'd4550 ) // > 91s
		    r_pwr_btn_state	<= 2'd3;
	end
end

// pwr_btn ：根据当前上电阶段，控制按钮输出信号与延时信号
always@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin  // 复位状态：按钮信号置1（未按下状态），延时信号置1（无锁存）
		r_pwr_btn		    <= 1'b1;
		r_pwr_btn_dly		<= 1'b1;
	end
	else begin
		// 阶段0（0~10s）：硬件未就绪→ 强制按钮信号为1（无论物理按钮是否按下，均不触发操作）
		if(r_pwr_btn_state ==  2'd0)   // < 10s
		    r_pwr_btn		<= 1'b1;
		
		// 阶段1（10~90s）：部分就绪+物理按钮按下（~i_FP_PWR_BTN_MUX_N=1）→ 
		// 1. r_pwr_btn=1：暂不触发实际操作；2. r_pwr_btn_dly=0：锁存“按钮按下”动作
		else if(r_pwr_btn_state ==  2'd1 && ~i_FP_PWR_BTN_MUX_N ) begin // 10s-90s
		    r_pwr_btn		<= 1'b1;
			r_pwr_btn_dly	<= 1'b0;
		end
		
		// 阶段2（90~91s）或阶段3（>91s）：硬件就绪→ 按钮信号跟随物理按钮（按下=0，松开=1）
		else if(r_pwr_btn_state ==  2'd2 || r_pwr_btn_state ==  2'd3 ) // > 90s
		    r_pwr_btn		<= i_FP_PWR_BTN_MUX_N;
		
		// 其他场景（如阶段1但按钮未按下）→ 保持原有状态（避免无意义的信号翻转）
		else begin
		    r_pwr_btn		<= r_pwr_btn;
			r_pwr_btn_dly	<= r_pwr_btn_dly;
		end
	end
end
//1. 阶段 0（0~10s）：强制禁止操作
//无论用户是否按下物理按钮（i_FP_PWR_BTN_MUX_N 为 0 或 1），r_pwr_btn 始终为 1（未按下状态）；
// 目的：此时硬件（如电源模块、PCH 复位）未就绪，即使按下按钮也无法正常触发开关机，强制禁止可避免硬件损坏或系统卡死。
// 2. 阶段 1（10~90s）：操作锁存（预触发）
// 当用户按下物理按钮（~i_FP_PWR_BTN_MUX_N=1）时：
// r_pwr_btn=1：暂不输出 “按下” 信号，避免硬件未完全就绪时触发操作；
// r_pwr_btn_dly=0：锁存 “用户按下按钮” 的动作（相当于 “预触发”）；
// 目的：满足用户 “提前按下按钮，硬件就绪后自动执行操作” 的需求，提升体验（无需用户等待 91s 后再次按下）。
// 3. 阶段 2~3（>90s）：正常控制
// r_pwr_btn 直接跟随物理按钮信号（i_FP_PWR_BTN_MUX_N）：
// 用户按下按钮→ i_FP_PWR_BTN_MUX_N=0 → r_pwr_btn=0（触发操作）；
// 用户松开按钮→ i_FP_PWR_BTN_MUX_N=1 → r_pwr_btn=1（停止操作）；
// 目的：硬件完全就绪，按钮控制恢复正常，确保操作实时响应。

// assign o_FM_BMC_PWRBTN_OUT_B_N = r_pwr_btn && ((r_pwr_btn_state ==  2'd2) ? r_pwr_btn_dly : 1'b1); 
// 4. 输出端口赋值：将内部状态寄存器映射到模块输出，供外部模块（如BMC）读取
assign o_pwr_btn_state =  r_pwr_btn_state ; // 输出当前按钮阶段状态
assign o_pwr_btn_dly   =  r_pwr_btn_dly   ; // 输出按钮延时信号



endmodule
