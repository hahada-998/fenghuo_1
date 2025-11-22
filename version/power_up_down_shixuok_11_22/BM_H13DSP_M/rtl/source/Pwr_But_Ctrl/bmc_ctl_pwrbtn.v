

//1. bmcͨ��i2c�Ĵ���д��cpu board��
//2. cpu board ͨ��lvdsд��icb board;
//3. icb board ִ��power button������
//4. icb board ͨ��lvds�ش�����ִ����ɱ�־λ��cpu board, cpu board ����Ĵ���״̬��

//bmc_ctl_pwrbtn 是 BMC 软控制电源按钮的核心模块，负责接收 BMC 下发的软开关机 / 复位指令（脉冲信号），通过计时生成符合硬件要求的控制信号
//同时输出操作完成反馈与事件标志，实现 “BMC 远程控制” 与 “硬件时序适配” 的联动。

module bmc_ctl_pwrbtn(
    // 1. 时钟与复位端口（时序基准）
    input  wire i_clk,                // 输入：工作时钟（如50MHz，模块时序基准）
    input  wire i_rst_n,              // 输入：全局复位（低电平有效，初始化内部状态）
    input  wire i_clk_20ms,           // 输入：20ms时钟使能（时间基准，用于计时）
    
    // 2. 硬件状态与按钮反馈端口
    input  wire i_pwrbtn_n,           // 输入：到PCH的电源按钮信号（来自Pwr_But_Ctrl，反馈当前按钮状态）
    input  wire i_slps4_n,            // 输入：S4休眠状态信号（低电平有效，标识系统是否处于S4状态）
    
    // 3. BMC下发的软控制指令（输入，脉冲信号）
    input  wire i_bmc_sbtn_poweron,   // 输入：BMC软开机指令（生成500ms高脉冲，触发开机）
    input  wire i_bmc_lbtn_powerdown, // 输入：BMC硬关机指令（生成6s高脉冲，触发强制关机）
    input  wire i_bmc_sbtn_powerdown, // 输入：BMC软关机指令（生成500ms高脉冲，触发正常关机）
    input  wire i_bmc_sbtn_wc,        // 输入：BMC软开机事件清除（W0C：Write 0 to Clear，写0清除事件标志）
    input  wire i_bmc_lbtn_wc,        // 输入：BMC硬关机事件清除（W0C，写0清除事件标志）
    input  wire i_bmc_sbtn_sys_wc,    // 输入：BMC软复位事件清除（W0C，写0清除事件标志）
    
    // 4. BMC操作完成反馈（输出，告知BMC指令已执行）
    output wire o_bmc_sbtn_poweron_done,   // 输出：软开机操作完成（1=完成，0=未完成）
    output wire o_bmc_lbtn_powerdown_done, // 输出：硬关机操作完成（1=完成，0=未完成）
    output wire o_bmc_sbtn_powerdown_done, // 输出：软关机操作完成（1=完成，0=未完成）
    
    // 5. 电源按钮事件标志（输出，告知下游模块触发对应动作）
    output wire o_sbtn_pwron_evt,    // 输出：软开机事件（1=触发开机，0=无）
    output wire o_lbtn_pwrdown_evt,  // 输出：硬关机事件（1=触发关机，0=无）
    output wire o_sbtn_sysrst_evt,   // 输出：软复位事件（1=触发复位，0=无）
    
    // 6. BMC控制的电源按钮信号（输出，用于控制PCH）
    output wire o_bmc_ctl_pwrbtn_n
);

// 1. 内部计时寄存器：用于累计BMC指令的持续时间（单位：20ms）
reg [5:0] r_sbtn_pwron_cnt;        // 软开机计时（6位：最大计数63，对应63×20ms=1.26s，满足500ms需求）
reg [11:0] r_lbtn_pwrdown_cnt;     // 硬关机计时（12位：最大计数4095，对应4095×20ms=81.9s，满足6s需求）
reg [5:0] r_sbtn_pwrdown_cnt;      // 软关机计时（6位：最大计数63，对应1.26s，满足500ms需求）

// 2. 操作完成标志寄存器：标识BMC指令是否执行完成
reg r_bmc_sbtn_poweron_done;       // 软开机完成标志（1=完成）
reg r_bmc_lbtn_powerdown_done;     // 硬关机完成标志（1=完成）
reg r_bmc_sbtn_powerdown_done;     // 软关机完成标志（1=完成）

// 3. 内部控制信号：BMC各指令对应的电源按钮控制信号（低电平有效）
wire w_bmc_sbtn_pwron_n;           // 软开机控制信号
wire w_bmc_lbtn_pwrdown_n;         // 硬关机控制信号
wire w_bmc_sbtn_pwrdown_n;         // 软关机控制信号

//////////////////////////////////////////////////////////////

// 1. 操作完成反馈：将内部完成标志寄存器直接输出给BMC
assign o_bmc_sbtn_poweron_done   = r_bmc_sbtn_poweron_done;  
assign o_bmc_lbtn_powerdown_done = r_bmc_lbtn_powerdown_done;
assign o_bmc_sbtn_powerdown_done = r_bmc_sbtn_powerdown_done;

// 2. BMC控制的电源按钮总信号：3路控制信号“与逻辑”融合
// 原理：只有所有指令均不触发（w_*_n=1）时，总信号才为1（不控制PCH）；任一指令触发（w_*_n=0）时，总信号为0（控制PCH执行对应动作）
assign o_bmc_ctl_pwrbtn_n      = w_bmc_sbtn_pwron_n & w_bmc_lbtn_pwrdown_n & w_bmc_sbtn_pwrdown_n; 

//////////////////////////////////////////////////////////////
//icb ִ��power button������BMC 软开机指令处理逻辑（i_bmc_sbtn_poweron）
//该逻辑负责接收 BMC 的 500ms 软开机脉冲，通过计时生成 “控制信号” 与 “完成反馈”：
// BMC软开机指令处理：累计指令持续时间，生成控制信号与完成标志
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)    // 复位状态：计时清零，完成标志置0
	begin
		r_sbtn_pwron_cnt        <= 6'd0; 
		r_bmc_sbtn_poweron_done <= 1'b0;
	end
	else 
    begin
		// 场景1：BMC软开机指令结束（i_bmc_sbtn_poweron=0）→ 计时清零，完成标志置0
		if(~i_bmc_sbtn_poweron) 
		begin
			r_sbtn_pwron_cnt         <= 6'd0;
			r_bmc_sbtn_poweron_done  <= 1'b0;		
		end
		// 场景2：计时达到50（50×20ms=1000ms）→ 计时保持，完成标志置1（标识指令执行完成）
		else if(r_sbtn_pwron_cnt >= 50)
		begin
			r_sbtn_pwron_cnt        <= r_sbtn_pwron_cnt;
			r_bmc_sbtn_poweron_done <= 1'b1;
		end
		// 场景3：BMC指令持续（i_bmc_sbtn_poweron=1）且未到计时阈值→ 20ms使能时计时+1
		else if(i_clk_20ms)
			r_sbtn_pwron_cnt  <= r_sbtn_pwron_cnt + 1;
        else  // 非20ms使能时刻→ 计时保持不变
            r_sbtn_pwron_cnt  <= r_sbtn_pwron_cnt;     		
	end
end
// 计时（r_sbtn_pwron_cnt）	对应时间（20ms× 计数）	完成标志（r_bmc_sbtn_poweron_done）	控制信号（后续赋值）	动作解读
// 0	                       0ms	                   0	                          1（不控制）	        指令未开始
// 5~31	                       100ms~620ms	           0	                          0（控制开机）	        执行开机操作
// 50	                       1000ms	               1	                          1（停止控制）	        开机操作完成

//BMC 硬关机指令处理逻辑（i_bmc_lbtn_powerdown）
// BMC硬关机指令处理：累计6s脉冲时长，生成控制信号与完成标志
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)    // 复位状态：计时清零，完成标志置0
	begin
		r_lbtn_pwrdown_cnt        <= 12'd0; 
		r_bmc_lbtn_powerdown_done <= 1'b0;
	end
	else 
    begin
		// 场景1：BMC硬关机指令结束（i_bmc_lbtn_powerdown=0）→ 计时清零，完成标志置0
		if(~i_bmc_lbtn_powerdown) 
		begin
			r_lbtn_pwrdown_cnt         <= 12'd0;
			r_bmc_lbtn_powerdown_done  <= 1'b0;		
		end
		// 场景2：计时达到350（350×20ms=7000ms）→ 计时保持，完成标志置1（操作完成）
		else if(r_lbtn_pwrdown_cnt >= 350)
		begin
			r_lbtn_pwrdown_cnt        <= r_lbtn_pwrdown_cnt;
			r_bmc_lbtn_powerdown_done <= 1'b1;
		end
		// 场景3：指令持续且未到阈值→ 20ms使能时计时+1
		else if(i_clk_20ms)
			r_lbtn_pwrdown_cnt  <= r_lbtn_pwrdown_cnt + 1;
        else  // 非20ms使能→ 计时保持
            r_lbtn_pwrdown_cnt  <= r_lbtn_pwrdown_cnt;     		
	end
end
//关键设计：计时阈值 350
//硬关机指令需求为 6s 脉冲，350×20ms=7000ms（7s），预留 1s 冗余：
//确保 BMC 的 6s 脉冲完全接收，避免因脉冲提前结束导致 “强制关机未执行”；
//7s 后置位完成标志，BMC 可确认 “强制关机已生效”


//BMC 软关机指令处理逻辑（i_bmc_sbtn_powerdown）
// BMC软关机指令处理：累计500ms脉冲时长，生成控制信号与完成标志
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)    // 复位状态：计时清零，完成标志置0
	begin
		r_sbtn_pwrdown_cnt        <= 6'd0; 
		r_bmc_sbtn_powerdown_done <= 1'b0;
	end
	else 
    begin
		// 场景1：指令结束→ 计时清零，完成标志置0
		if(~i_bmc_sbtn_powerdown) 
		begin
			r_sbtn_pwrdown_cnt         <= 6'd0;
			r_bmc_sbtn_powerdown_done  <= 1'b0;		
		end
		// 场景2：计时达到50（1000ms）→ 计时保持，完成标志置1
		else if(r_sbtn_pwrdown_cnt >= 50)
		begin
			r_sbtn_pwrdown_cnt        <= r_sbtn_pwrdown_cnt;
			r_bmc_sbtn_powerdown_done <= 1'b1;
		end
		// 场景3：指令持续且未到阈值→ 20ms使能时计时+1
		else if(i_clk_20ms)
			r_sbtn_pwrdown_cnt  <= r_sbtn_pwrdown_cnt + 1;
        else  // 非20ms使能→ 计时保持
            r_sbtn_pwrdown_cnt  <= r_sbtn_pwrdown_cnt;     		
	end
end


// 1. 软开机控制信号：计时在5~31（100ms~620ms）时置0（触发开机），其他时刻置1（不触发）
// 原理：避开指令初始的100ms（防止脉冲抖动），确保稳定触发开机
assign w_bmc_sbtn_pwron_n   = ((r_sbtn_pwron_cnt >= 5) && (r_sbtn_pwron_cnt <= 31)) ? 1'b0 : 1'b1;

// 2. 硬关机控制信号：计时在5~305（100ms~6100ms）时置0（触发关机），其他时刻置1（不触发）
// 原理：6100ms覆盖BMC的6s指令，预留100ms避开抖动
assign w_bmc_lbtn_pwrdown_n = ((r_lbtn_pwrdown_cnt >= 5) && (r_lbtn_pwrdown_cnt <= 305)) ? 1'b0 : 1'b1;

// 3. 软关机控制信号：与软开机逻辑一致（5~31对应100ms~620ms），确保稳定触发关机
assign w_bmc_sbtn_pwrdown_n = ((r_sbtn_pwrdown_cnt >= 5) && (r_sbtn_pwrdown_cnt <= 31)) ? 1'b0 : 1'b1;

////////////////////////////////////////////////////////////////////////////////////
//button log
//该部分代码是 bmc_ctl_pwrbtn 模块的物理按钮事件检测核心，负责通过 “边沿检测 + 计时判断” 区分物理电源按钮（i_pwrbtn_n）的 “短按开机”“短按复位”“长按关机” 三种操作
//并结合系统休眠状态（i_slps4_n）与 BMC 清除信号（i_bmc_*_wc）生成最终事件标志，实现 “物理按钮操作→系统响应” 的精准联动

// 1. 按钮边沿检测信号：标识物理按钮的上升沿（松开）与下降沿（按下）
wire w_pwrbtn_pos;  // 按钮上升沿（i_pwrbtn_n从0→1，对应按钮松开）
wire w_pwrbtn_neg;  // 按钮下降沿（i_pwrbtn_n从1→0，对应按钮按下）

// 2. 按钮计时与标志寄存器：
reg [11:0] r_pwrbtn_counter;  // 按钮按下时长计数器（12位，最大计数4095，对应4095×20ms=81.9s）
reg r_500ms_flag;             // 短按标志（1=按钮按下时长≈500ms，触发开机/复位）
reg r_4s_flag;                // 长按标志（1=按钮按下时长≈4s，触发强制关机）

// 3. 系统事件标志寄存器：标识当前触发的系统动作（输出到下游模块）
reg r_sbtn_pwron_evt;         // 短按开机事件（1=触发开机）
reg r_lbtn_pwrdown_evt;       // 长按关机事件（1=触发强制关机）
reg r_sbtn_sysrst_evt;        // 短按复位事件（1=触发系统复位）

// 4. 系统休眠状态锁存寄存器：锁存按钮按下时的系统S4休眠状态（避免状态变化导致误判）
reg r_slps4_state;

// 5. 事件标志输出：将内部事件寄存器映射到模块输出，供下游模块（如PCH）响应
assign o_sbtn_pwron_evt   = r_sbtn_pwron_evt  ;
assign o_lbtn_pwrdown_evt = r_lbtn_pwrdown_evt;   
assign o_sbtn_sysrst_evt  = r_sbtn_sysrst_evt ;

//////////////////////////////////////////////////////////////

// 边沿检测模块实例化：捕捉物理按钮（i_pwrbtn_n）的上升沿与下降沿
Edge_Detect Edge_Detect_u0(
    .i_clk           (i_clk),           // 输入：工作时钟（与模块一致，确保时序同步）
    .i_rst_n         (i_rst_n),         // 输入：全局复位（低电平有效，初始化边沿检测状态）
    .i_signal        (i_pwrbtn_n),      // 输入：待检测的物理按钮信号（低电平有效，按下为0）
    
    .o_signal_pos    (w_pwrbtn_pos),    // 输出：按钮上升沿（i_pwrbtn_n从0→1，对应松开）
    .o_signal_neg    (w_pwrbtn_neg),    // 输出：按钮下降沿（i_pwrbtn_n从1→0，对应按下）
    .o_signal_invert ()                 // 输出：信号反相（未使用，留空）
);
//专用模块复用：Edge_Detect 是通用边沿检测模块，实例化后无需重复编写延时逻辑，减少代码冗余与错误


//锁存 “按钮按下瞬间” 的系统 S4 休眠状态（i_slps4_n），确保后续事件判断基于 “操作发起时” 的状态，而非 “操作过程中” 的状态：
// 系统S4状态锁存：在按钮按下（下降沿）时，锁存当前i_slps4_n状态
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)  // 复位状态：锁存状态置0（默认系统未休眠）
	begin
	    r_slps4_state  <= 1'b0;
	end
	else if(w_pwrbtn_neg)  // 按钮按下（下降沿）→ 锁存当前i_slps4_n状态
	    r_slps4_state  <= i_slps4_n;
	else  // 其他时刻（按钮未按下/已松开）→ 保持锁存状态
	    r_slps4_state  <= r_slps4_state;
end
//i_slps4_n=0：系统处于 S4 休眠状态（深度休眠，仅保留少量电源）；
//i_slps4_n=1：系统处于 非 S4 状态（如 S0 运行状态、S5 关机状态）。
//若按钮按下时系统在 S4（i_slps4_n=0），按下过程中系统唤醒到 S0（i_slps4_n=1），锁存 “按下瞬间” 的 S4 状态可确保事件判断正确（应触发开机，而非复位）；


// always@(posedge i_clk or negedge i_rst_n) 
// begin
	// if(~i_rst_n) begin 
		// r_500ms_flag         <= 1'b0;
		// r_4s_flag            <= 1'b0;
	// end
	// else begin 
		// if((r_pwrbtn_counter >= 12'd200) && (w_pwrbtn_pos)) begin	
	        // r_500ms_flag        <= 1'b0;	
			// r_4s_flag           <= 1'b1;
		// end
		// else if(w_pwrbtn_pos ) begin  //20ms * 25 = 500ms 
			// r_500ms_flag        <= 1'b1;	
			// r_4s_flag           <= 1'b0;			  			
		// end
		// else begin
		    // r_500ms_flag        <= 1'b0;	
			// r_4s_flag           <= 1'b0;
		// end
   // end		
// end

// 短按/长按标志生成：根据按钮按下时长与松开动作，判断是否触发500ms短按或4s长按
always@(posedge i_clk or negedge i_rst_n) 
begin
	if(~i_rst_n)  // 复位状态：短按/长按标志均置0
	begin 
		r_500ms_flag         <= 1'b0;
		r_4s_flag            <= 1'b0;
	end
	else 
	begin 
		// 场景1：计时≥200（20ms×200=4s）+ 按钮松开（上升沿）→ 置长按标志，清短按标志
		if((r_pwrbtn_counter >= 12'd200) && (w_pwrbtn_pos)) begin		
			r_4s_flag           <= 1'b1;
			r_500ms_flag        <= 1'b0;
		end
		// 场景2：计时<200（<4s）+ 按钮松开（上升沿）→ 置短按标志，清长按标志
		else if((r_pwrbtn_counter < 12'd200) && (w_pwrbtn_pos) ) begin   
			r_500ms_flag        <= 1'b1;	
            r_4s_flag           <= 1'b0;			
		end
		// 场景3：短按事件触发（开机/复位）→ 清短按标志（避免重复触发）
		else if((r_sbtn_pwron_evt == 1'b1)|| (r_sbtn_sysrst_evt== 1'b1) ) begin   
			r_500ms_flag        <= 1'b0;				  			
		end
	    // 场景4：长按事件触发（关机）→ 清长按标志（避免重复触发）
		else if(r_lbtn_pwrdown_evt == 1'b1 ) begin   
			r_4s_flag           <= 1'b0;			  			
		end
		// 场景5：其他时刻（按钮未松开/事件未触发）→ 保持标志当前状态
		else begin
		    r_500ms_flag        <= r_500ms_flag;	
			r_4s_flag           <= r_4s_flag;
		end
   end		
end
// 计时（r_pwrbtn_counter）	按钮动作	              标志状态（r_500ms_flag/r_4s_flag）	动作类型
// <200（<4s）	            松开（w_pwrbtn_pos=1）	    1/0	                                短按（触发开机 / 复位）
// ≥200（≥4s）	            松开（w_pwrbtn_pos=1）	    0/1	                                长按（触发强制关机）
// 任意	                    未松开（w_pwrbtn_pos=0）	0/0	                                无动作（按钮仍按下）
	

// 按钮按下时长计时：从按钮按下（下降沿）开始计时，松开（上升沿）或超时后停止
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)  // 复位状态：计数器清零
    begin
	    r_pwrbtn_counter <= 0;
	end
	else 
	begin
	    // 场景1：按钮按下（下降沿）→ 计数器清零（重新开始计时）
	    if(w_pwrbtn_neg)
		    r_pwrbtn_counter  <= 0;
		// 场景2：20ms使能有效 + 计数器未超时（≤1000，对应20ms×1000=20s）→ 计时+1
		else if(i_clk_20ms & (r_pwrbtn_counter <= 1000))
		    r_pwrbtn_counter  <= r_pwrbtn_counter + 1;
		// 场景3：计数器超时（>20s）或20ms使能无效→ 保持计数（避免溢出或无意义累加）
		else
		    r_pwrbtn_counter  <= r_pwrbtn_counter;	 
	 end
end




// 短按开机事件生成：短按（500ms）+ 按钮按下时系统在S4（休眠）→ 触发开机
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)  // 复位状态：开机事件标志置0
    begin
	     r_sbtn_pwron_evt   <= 1'b0;	 
	 end
	 else 
	 begin 
		  // 场景1：BMC下发清除信号（i_bmc_sbtn_wc=0，W0C机制）→ 清开机事件标志
		  if(~i_bmc_sbtn_wc)
		      r_sbtn_pwron_evt  <= 1'b0;
	     // 场景2：短按标志置1 + 锁存的S4状态为0（系统在S4休眠）→ 置开机事件标志
	     else if(r_500ms_flag && (~r_slps4_state))
		      r_sbtn_pwron_evt  <= 1'b1;
		  // 场景3：其他时刻→ 保持当前标志状态
		  else
		      r_sbtn_pwron_evt  <= r_sbtn_pwron_evt;
	 end
end 

// 短按复位事件生成：短按（500ms）+ 按钮按下时系统在非S4（运行）→ 触发复位
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(~i_rst_n)  // 复位状态：复位事件标志置0
    begin
	    r_sbtn_sysrst_evt   <= 1'b0;	 
	end
	else 
	begin 
		// 场景1：BMC下发清除信号（i_bmc_sbtn_sys_wc=0，W0C机制）→ 清复位事件标志
		if(~i_bmc_sbtn_sys_wc)
		    r_sbtn_sysrst_evt  <= 1'b0;
	    // 场景2：短按标志置1 + 锁存的S4状态为1（系统在非S4）→ 置复位事件标志
	    else if(r_500ms_flag & r_slps4_state)
		    r_sbtn_sysrst_evt  <= 1'b1;
		// 场景3：其他时刻→ 保持当前标志状态
		else
		    r_sbtn_sysrst_evt  <= r_sbtn_sysrst_evt;
	end
end 
	

// 长按关机事件生成：长按（4s）+ 按钮按下时系统在非S4（运行）→ 触发强制关机
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin 
        r_lbtn_pwrdown_evt	<= 1'b0;  // 复位状态：关机事件标志置0（无关机事件）
    end
    else begin
        // 场景1：BMC下发清除信号（i_bmc_lbtn_wc=0，W0C机制）→ 清除关机事件标志
        // 设计意图：支持BMC远程清除事件，避免事件持续触发（如故障排除后需重置）
        if(~i_bmc_lbtn_wc)
            r_lbtn_pwrdown_evt  <= 1'b0;
        
        // 场景2：长按标志置1（r_4s_flag=1）+ 锁存的S4状态为1（r_slps4_state=1，系统在非S4运行状态）
        // 触发条件：用户长按按钮4s以上且松开，且操作时系统处于运行状态→ 判定为强制关机意图
        else if(r_4s_flag && r_slps4_state )
            r_lbtn_pwrdown_evt  <= 1'b1; 
        
        // 场景3：其他情况（未满足长按+运行状态条件）→ 保持当前事件标志状态
        // 设计意图：避免无意义的信号翻转，仅在明确触发条件下更新标志
        else
            r_lbtn_pwrdown_evt  <= r_lbtn_pwrdown_evt;
    end
end 

//用户按下按钮 → Edge_Detect 检测下降沿（w_pwrbtn_neg=1）→ 锁存当前 S4 状态（r_slps4_state）→ r_pwrbtn_counter 开始计时 → 用户松开按钮 → Edge_Detect 检测上升沿（w_pwrbtn_pos=1）→ 
//根据计时结果生成 r_500ms_flag（短按）/r_4s_flag（长按）→ 结合锁存的 S4 状态生成对应事件标志（开机 / 复位 / 关机）→ BMC 处理事件后通过 W0C 信号清除标志



endmodule 