//*************************************************************************\
// Copyright (c) 2010, H3C Technologies Co.,Ltd, All rights reserved
//
//                   File Name  :  NVME_UART_OUT.v
//                Project Name  :  R6900 G5
//                      Author  :  
//                     NotesID  :  
//                       Email  :  
//                      Device  :
//                     Company  :  H3C Technologies Co.,Ltd
//==========================================================================
//   Description:
//
//   Called by  :
//==========================================================================
//   Revision History:
//  Date        By          Revision    Change Description
//--------------------------------------------------------------------------
//2019/06/18   fuxingyi       1.0       Original
//2019/12/13   fuquanlong	  1.5		To be bidirectional signal
//2020/2/11    fuquanlong	  1.61		Simulation optimization
//2020/3/04    fuquanlong	  1.7		Delete interface "ser_data_in","ser_data_out","read_flag"
//										Add interface "ser_data","send_enable"
//*************************************************************************/
//UART_MASTER 是 服务器 MCIO 接口的核心通信模块，实现 “并行数据→串行数据” 的转换与双向通信，支持主板（MB）与扩展背板（BP）之间的控制指令发送（如电源使能）和状态反馈（如槽位 ID）
//模块通过状态机严格控制 UART 通信时序，包含 “帧同步、数据发送、数据接收、错误检测” 功能，确保高可靠性的串行传输。
module UART_MASTER
#(
parameter NBIT_IN = 10,
parameter NBIT_OUT = 10,
parameter BPS_COUNT_NUM =48, // BPS=1200 ,tick * BPS_COUNT_NUM 
parameter START_COUNT_NUM = 24 // Generally, START_COUNT_NUM = BPS_COUNT_NUM/2
)
(
	input clk,                     // 系统时钟（如50MHz，模块时序基准）
	input rst,                     // 全局复位（高电平有效，复位时所有状态清零）
	input tick,                    // 时钟使能脉冲（如16us，用于波特率计数触发）
	input send_enable,             // 发送使能（1=允许 MB 向 BP 发送数据，0=禁止）
    input t128ms_tick,             // 128ms 周期脉冲（每128ms触发一次通信，避免频繁发送浪费资源）
	input [NBIT_OUT-1 : 0] par_data_in, // 并行输入数据（MB→BP 的控制指令，如 MCIO 电源使能帧）
	output reg  [NBIT_IN-1 : 0] par_data_out, // 并行输出数据（BP→MB 的状态反馈，如槽位 ID）
	inout	ser_data,              // 双向串行数据线（MB与BP之间的物理通信线，发送/接收复用）
	input riser_en_out,            // 扩展卡电源使能反馈（用于校验通信有效性）
	input mcio_cable_id0,          // MCIO 线缆 ID0（检测线缆连接状态，0=正常连接）
	input mcio_cable_id1,          // MCIO 线缆 ID1（与 ID0 配合确认线缆兼容性）
	output reg  error_flag         // 错误标志（1=通信错误，如帧校验失败；0=正常）

//ser_data：双向端口是 UART 半双工通信的核心，通过 “高阻态（1'bz）” 切换发送 / 接收模式；
//mcio_cable_id0/1：用于硬件级通信校验 —— 仅当线缆正常连接（ID0=0 且 ID1=0）时才启动 UART 通信，避免无连接时的无效传输；
);

reg	 read_flag;                  // 读使能标志（1=接收模式，ser_data 设为高阻态；0=发送模式，ser_data 输出数据）
reg	 ser_data_out;               // 串行输出数据缓存（发送模式时，驱动 ser_data 端口）
wire ser_data_in ;               // 串行输入数据（接收模式时，从 ser_data 端口读取 BP 反馈数据）

// 双向端口 ser_data 方向控制：根据线缆 ID 与 read_flag 切换发送/接收模式
// 逻辑：仅当线缆正常连接（mcio_cable_id1=0且mcio_cable_id0=0）时，按 read_flag 切换；否则输出电源使能信号（riser_en_out）
assign ser_data = (mcio_cable_id1 == 1'b0 && mcio_cable_id0 == 1'b0) ? (read_flag ? 1'bz : ser_data_out) : riser_en_out;
assign ser_data_in = ser_data;    // 接收模式时，ser_data 输入数据赋值给 ser_data_in

// 函数 clogb2：计算二进制位数（用于确定计数器宽度，如 WCNT=数据计数宽度）
function integer clogb2(
  input integer value
);
  integer tmp;
  begin
    tmp = value - 1;
    for (clogb2=0; tmp>0; clogb2=clogb2+1)// 循环计算 log2(value)，得到所需位数
      tmp = tmp>>1;
    clogb2 = (clogb2 < 1) ? 1 : clogb2;// 确保最小位数为1（避免 value=0 时位数为0）
  end
endfunction

// 扩展数据宽度：在原始数据前后添加校验位（3位前缀+3位后缀），用于帧同步与错误检测
localparam NBIT_IN6 = NBIT_IN + 6;  // 接收数据扩展宽度（原始 NBIT_IN 位 + 6位校验位）
localparam NBIT_OUT6 = NBIT_OUT + 6;// 发送数据扩展宽度（原始 NBIT_OUT 位 + 6位校验位）
localparam WCNT = (NBIT_IN > NBIT_OUT) ? clogb2(NBIT_IN6) : clogb2(NBIT_OUT6); // 数据计数器宽度（取扩展后宽度的最大值）
localparam BPS_CNT = clogb2(BPS_COUNT_NUM); // 波特率计数器宽度（适配 BPS_COUNT_NUM 的最大值）
localparam WAIT_T = 5'h03;          // 等待时间阈值（发送后等待3个波特率周期，再进入接收模式）


// 内部计数器与缓存
reg [5:0] bps_count_bit;          // 波特率计数器（计数到 BPS_COUNT_NUM 时，完成一个波特率周期）
reg [4:0] wait_time;              // 等待计数器（发送后等待 WAIT_T 个周期，确保 BP 准备好反馈）
wire [NBIT_OUT6-1:0] reg_par_data_in;// 发送数据扩展缓存（添加校验位后的完整发送帧）
wire state_change;                // 状态变化标志（1=当前状态≠上一状态，用于复位计数器）
reg [2:0] curr_state;             // 当前状态（状态机核心，控制通信流程）
reg [2:0] next_state;             // 下一状态（状态机跳转逻辑输出）
reg [2:0] last_state;             // 上一状态（用于检测状态变化）
reg [WCNT-1:0] data_count;        // 数据计数器（计数发送/接收的位数）
reg [NBIT_IN6-1:0] reg_par_data_out;// 接收数据扩展缓存（存储带校验位的接收帧）

//数据扩展（NBIT_IN6/NBIT_OUT6）：在原始数据前后添加 3 位校验位（前缀 3'b010、后缀 3'b101），用于接收端校验帧完整性（避免接收无效数据）；
//read_flag 控制双向端口：发送时 read_flag=0，ser_data 输出 ser_data_out；接收时 read_flag=1，ser_data 设为高阻态，从 BP 读取数据，实现半双工通信。

// 状态定义（6个核心状态，覆盖 UART 通信全流程）
localparam IDLE = 3'b000;         // 空闲状态：等待 128ms 触发信号
localparam START = 3'b001;        // 起始位状态：发送 UART 起始位（低电平）
localparam DATA_OUT = 3'b010;     // 数据发送状态：发送扩展后的并行数据（含校验位）
localparam WAIT = 3'b011;         // 等待状态：发送完成后，等待 BP 准备反馈
localparam RESTART = 3'b100;      // 重新同步状态：等待 BP 发送的起始位
localparam DATA_IN = 3'b101;      // 数据接收状态：接收 BP 反馈的扩展数据（含校验位）

// 发送数据扩展：在原始并行数据（par_data_in）前后添加校验位（前缀 3'b010，后缀 3'b101）
assign reg_par_data_in ={3'b010,par_data_in,3'b101};

//  当前状态寄存器：时钟上升沿更新为下一状态
always@(posedge clk or posedge rst)
begin
	if (rst)
		curr_state <= IDLE;  // 复位时回到空闲状态
	else 
		curr_state <= next_state;  // 正常时更新为下一状态
end

//  等待计数器：发送后等待 WAIT_T 个周期（确保 BP 有足够时间准备反馈）
always@(posedge clk or posedge rst)
begin
    if (rst)
		wait_time <= 5'h00;  // 复位清零
	else 
	begin
		if(wait_time == WAIT_T)
			wait_time <= 5'h00;  // 达到阈值后清零
		else 
			// 仅在 WAIT 状态且波特率计数完成时，等待时间+1
			if((curr_state == WAIT)&&(bps_count_bit == BPS_COUNT_NUM))
				wait_time <= wait_time + 1'b1;
	end
end

always@(*)
begin
	
	next_state = curr_state;
		
     case(curr_state)
	 // 空闲状态：128ms 触发且发送使能时，进入起始位状态；否则保持空闲
	 IDLE:
	 begin
		if ((t128ms_tick) && send_enable)
		next_state = START;
		else 
		next_state = IDLE;
	 end

	 // 起始位状态：波特率计数完成（发送完起始位），进入数据发送状态
	 START:
	 begin
		if (bps_count_bit == BPS_COUNT_NUM)
		next_state = DATA_OUT;
		else 
		next_state = START;
	 end

	 // 数据发送状态：数据计数完成（发送完所有扩展数据位），进入等待状态
	 DATA_OUT:
	 begin
		if (data_count == NBIT_OUT6)
			next_state = WAIT;
		else 
		next_state = DATA_OUT;
	 end

	// 等待状态：等待时间达到阈值（WAIT_T），进入重新同步状态
	WAIT:
	 begin
		if(wait_time == WAIT_T)
			next_state = RESTART;
		else 
			next_state = WAIT;
	 end
	
	// 重新同步状态：检测到 BP 发送的起始位（低电平）且波特率计数完成，进入接收状态；
	// 若超时（128ms 再次触发），回到空闲状态
	 RESTART:
	 begin
		if ((~ser_data_in) && (bps_count_bit == BPS_COUNT_NUM))
			next_state = DATA_IN;
		else begin
				if(t128ms_tick)
					next_state = IDLE;
				else
					next_state = RESTART;
			end
	 end	 
	 
	 // 数据接收状态：数据计数完成且波特率计数完成（接收完所有扩展数据位），回到空闲状态
	 DATA_IN:
	 begin
		if ((data_count == NBIT_IN6)&& (bps_count_bit == BPS_COUNT_NUM))
		next_state = IDLE;
		else 
		next_state = DATA_IN;
	 end	 
	 default: 
	 begin
		next_state = IDLE;
	 end
	 endcase
end

// 上一状态寄存器：记录上一周期的状态，用于检测状态变化
always@(posedge clk or posedge rst)
begin
	if (rst)
	last_state <= IDLE;
	else 
	last_state <= curr_state;
end

assign state_change = (last_state != curr_state);  // 状态变化标志：1=状态跳转

//bps count 波特率计数器是 UART 时序的核心，通过 tick 信号触发计数，确保每个数据位的发送 / 接收时间严格匹配波特率
// 波特率计数器：计数到 BPS_COUNT_NUM 时，完成一个波特率周期（如 520.8kbps 对应 48 个 tick）
always@(posedge clk or posedge rst)
begin
    if (rst)
		bps_count_bit <= {BPS_CNT{1'b0}};  // 复位清零
	// 状态变化或计数完成时，复位计数器（确保新状态从0开始计数）
	else if (state_change | (bps_count_bit == BPS_COUNT_NUM))
		bps_count_bit <= {BPS_CNT{1'b0}};
	else if (tick)  // 每 tick 触发一次计数（如 16us 一次）
		bps_count_bit <= bps_count_bit + 1'b1;
end


//数据发送逻辑：并行→串行转换 将扩展后的并行数据（含校验位）逐位转换为串行信号，通过 ser_data 发送给 BP：
// 数据发送与接收控制：根据当前状态，控制 ser_data 方向、数据计数与缓存
always@(posedge clk or posedge rst)
begin
	if (rst)
	begin
		read_flag <= 1'b0;          // 复位时为发送模式
		ser_data_out <= 1'b1;       // 复位时串行输出高电平（UART 空闲状态）
		data_count <= {WCNT{1'b0}}; // 数据计数器清零
	end
	else 
	begin
		case (curr_state)
		// 空闲状态：初始化发送模式，数据计数清零
		IDLE :
		begin 
		ser_data_out <= 1'b1;  // UART 空闲状态为高电平
		read_flag <= 1'b0;      // 发送模式（ser_data 输出数据）
		data_count <= {WCNT{1'b0}};
		end 
		
		// 起始位状态：发送 UART 起始位（低电平，持续一个波特率周期）
		START:
		begin
			ser_data_out <= 1'b0;// UART 协议规定起始位为低电平
		end
		
		// 数据发送状态：逐位发送扩展数据（reg_par_data_in），波特率计数完成时更新数据位
		DATA_OUT:
		begin
			ser_data_out <= reg_par_data_in[data_count];// 发送当前计数位
			// 波特率计数完成时，数据计数+1（准备发送下一位）
			data_count <= (bps_count_bit == BPS_COUNT_NUM) ? data_count + 1'b1 : data_count;
		end 
		
		// 等待状态：切换为接收模式（ser_data 高阻态），数据计数清零（准备接收）
		WAIT:
		begin
			ser_data_out <= 1'bz;    // 高阻态，允许 BP 发送数据
			read_flag <= 1'b1;       // 接收模式
			data_count <= {WCNT{1'b0}};	
		end

		// 重新同步状态：无操作（等待 BP 起始位）
		RESTART:
		begin

		end
		
		// 数据接收状态：波特率计数完成时，读取串行数据到接收缓存
		DATA_IN:
		if(bps_count_bit == BPS_COUNT_NUM)
		begin
			reg_par_data_out[data_count] <= ser_data_in;// 读取当前串行位
			data_count <= data_count + 1'b1;// 数据计数+1（准备接收下一位）
		end 
		endcase
    end 
end
//起始位：UART 协议规定起始位为低电平，START 状态发送 ser_data_out=1'b0，告知 BP 后续为数据位


//数据接收与错误检测：接收完成后校验帧完整性，输出并行数据或置位错误标志
always@(posedge clk or posedge rst)
begin
	if (rst)
	begin
		par_data_out <= {NBIT_IN {1'b0}};
		error_flag  <= 1'b0;
		//reg_par_data_out<= {(NBIT_IN6){1'b0}};
	end
	// 接收完成条件：数据计数完成（接收完所有扩展位）且处于 DATA_IN 状态
	else if ((data_count == NBIT_IN6) && (curr_state == DATA_IN))
		begin
			// 校验条件：接收帧的前缀=3'b010 且 后缀=3'b101（与发送端扩展帧结构一致）
			if((reg_par_data_out[2:0] == 3'b101) && (reg_par_data_out[NBIT_IN6-1:NBIT_IN6-3] == 3'b010 ))
				// 校验通过：提取原始数据（去掉前缀3位和后缀3位）
				par_data_out <= reg_par_data_out[NBIT_IN+2:3];
			else begin
					// 校验失败：置位错误标志（告知上层模块通信异常）
					error_flag  <= 1'b1;
				end
		end
end


endmodule