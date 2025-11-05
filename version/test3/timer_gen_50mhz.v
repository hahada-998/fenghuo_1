

module timer_gen(
  input      clk,               // main clock (50MHz)
  input      reset,             // reset

  output reg t40ns,             //      40ns
  output reg t80ns,             //      80ns
  output reg t160ns,            //     160ns
  output reg t1us,              //       1us
  output reg t2us,              //       2us
  output reg t16us,             //      16us
  output reg t32us,             //      32us
  output reg t128us,            //     128us
  output reg t512us,            //     512us
  output reg t1ms,              //   1.024ms
  output reg t2ms,              //   2.048ms
  output reg t16ms,             //  16.384ms
  output reg t32ms,             //  32.768ms
  output reg t64ms,             //  65.536ms
  output reg t128ms,            // 131.072ms
  output reg t256ms,            // 262.144ms
  output reg t512ms,            // 524.288ms
  output reg t1s,               //   1.049s

  output reg clk_1hz,           // 1Hz
  output reg clk_2p5hz,         // 2.5Hz
  output reg clk_4hz,           // 4Hz
  output reg clk_16khz,         // 16KHz
  output reg clk_6m25,          //6.25MHz
  output clk_16m6			//16.6MHz
 
);
  //实现一个0-1-2-...-7-0的循环计数器，每计数一次耗时20ns（一个时钟周期），完整周期为160ns
  reg [2:0] cnt20ns;	//定义3位寄存器作为20ns级计数器
  always@(posedge clk or posedge reset)	//时钟上升沿触发，异步复位
  begin
    if (reset)
      cnt20ns <= 3'b000;
    else if (cnt20ns==3'b111)//计数器最大计到7（3位2进制最大为111）
      cnt20ns <= 3'b000;//溢出归零
    else
      cnt20ns <= cnt20ns + 1'b1;//未溢出时，计数器+1
  end

  always@(posedge clk or posedge reset)
  begin
    if (reset) begin
      t40ns  <= 1'b0;
      t80ns  <= 1'b0;
      t160ns <= 1'b0;
    end
    else begin
      if ( cnt20ns[0]  ) t40ns  <= 1'b1; else t40ns  <= 1'b0;//生成t40ns脉冲：cnt20ns的最低位（bit0)为1时，输出高电平
      if (&cnt20ns[1:0]) t80ns  <= 1'b1; else t80ns  <= 1'b0;//生成t80ns脉冲：cnt20ns的低2位（bit1-0）全为1时（即3），输出高电平
      if (&cnt20ns[2:0]) t160ns <= 1'b1; else t160ns <= 1'b0;//生成t160ns脉冲：与t80ns逻辑相同
    end
  end

  reg   [5:0] nsec_tmr;	//6位纳秒级辅助计数器（最大计数63）
  reg   [4:0] usec_tmr;	//5位微秒级计数器（最大计数31）
  reg  [14:0] sec_tmr ;	//6位秒级辅助计数器（最大计数63）
  reg         t32us_e ;	//32微秒脉冲标志（e=edge，边缘触发）
  wire        t64ms_tick;//64毫秒脉冲（tick表示周期性脉冲）
  reg   [2:0] t200ms_tmr;//3位200毫秒级计数器（最大计数7）

//------------------------------------------------------------------------------
// Generate the timebase reference
//------------------------------------------------------------------------------
//多级计数器：将20ns时钟逐步扩展到微秒，秒级
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    nsec_tmr <=  6'b0;
    usec_tmr <=  5'b0;
    sec_tmr  <= 15'b0;
  end
  else
  begin
    nsec_tmr <= (nsec_tmr!=6'd49) ? nsec_tmr + 1'b1 : 6'd0;      // counts to 1us  1us 纳秒级计数器：每20ns计数一次，计到49后归零（周期50*20ns=10000ns=1us）
    usec_tmr <= (nsec_tmr==6'd49) ? usec_tmr + 1'b1 : usec_tmr;  // counts 1us, 2^5=32us 微秒级计数器：仅当nsec_tmr计数到49（即1us周期结束）时+1（每1us递增）
    sec_tmr  <= (t32us_e)         ? sec_tmr  + 1'b1 : sec_tmr;   // counts to 32us*2^15=1.048576s 秒级计数器：仅当32us脉冲触发时+1（每32us递增，后续用于生成ms级信号）
  end
end
//生成1us到1s的脉冲信号（高电平持续1个clk周期，即20ns）
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    t1us    <= 1'b0;
    t2us    <= 1'b0;
    t16us   <= 1'b0;
    t32us_e <= 1'b0;
    t32us   <= 1'b0;
    t128us  <= 1'b0;
    t512us  <= 1'b0;
    t1ms    <= 1'b0;
    t2ms    <= 1'b0;
    t16ms   <= 1'b0;
    t32ms   <= 1'b0;
    t64ms   <= 1'b0;
    t128ms  <= 1'b0;
    t256ms  <= 1'b0;
    t512ms  <= 1'b0;
    t1s     <= 1'b0;
  end
  else
  begin
    t1us    <= (nsec_tmr      ==6'd49);	//1us脉冲：nsec_tmr计到49时（1us周期结束瞬间）输出高电平
    t2us    <= (nsec_tmr      ==6'd49) & ( usec_tmr[0]);	//2us脉冲：1us脉冲触发时，且usec_tmr最低位为1（每2个1us脉冲输出一次）
    t16us   <= (nsec_tmr      ==6'd49) & (&usec_tmr[3:0]);	//16us脉冲：1us脉冲触发时，且usec_tmr低4位全为1（0~15——16us周期）
    t32us_e <= (nsec_tmr      ==6'd48) & (&usec_tmr[4:0]);  // 1-clk early to t32us 32us脉冲（边缘触发）：nsec_tmr=48(1us结束前20ns)且usec_tmr全为1（31——32us周期）
    t32us   <= t32us_e;						// 32us脉冲与t32us_e同步
    t128us  <= t32us_e & (&sec_tmr[1:0]);   //     128us  =32*4	32us脉冲触发时，sec_tmr低2位全为1（0~3——4*32us=128us）
    t512us  <= t32us_e & (&sec_tmr[3:0]);   //     512us  =32*16	32us脉冲触发时，sec_tmr低4位全为1（0~15——16*32us=512us）
    t1ms    <= t32us_e & (&sec_tmr[4:0]);   //   1.024ms  =32*32	32us脉冲触发时，sec_tmr低5位全为1（0~31——32*32us=1024us=1ms）
    t2ms    <= t32us_e & (&sec_tmr[5:0]);   //   2.048ms  =32*64	32us脉冲触发时，sec_tmr低6位全为1（0~63——64*32us=2048us=2ms）
    t16ms   <= t32us_e & (&sec_tmr[8:0]);   //  16.384ms  =32*512
    t32ms   <= t32us_e & (&sec_tmr[9:0]);   //  32.768ms  =32*1024
    t64ms   <= t32us_e & (&sec_tmr[10:0]);  //  65.536ms  =32*2048
    t128ms  <= t32us_e & (&sec_tmr[11:0]);  // 131.072ms  =32*4096
    t256ms  <= t32us_e & (&sec_tmr[12:0]);  // 262.144ms  =32*8192
    t512ms  <= t32us_e & (&sec_tmr[13:0]);  // 524.288ms  =32*16384
    t1s     <= t32us_e & (&sec_tmr[14:0]);  //   1.049s   =32*32768
  end
end


//------------------------------------------------------------------------------
// 50% duty cycle clocks
//------------------------------------------------------------------------------
always @(posedge clk or posedge reset)//通过脉冲触发翻转生成不同频率的时钟信号
begin
  if (reset)
  begin
    clk_1hz   <= 1'b0;
    clk_4hz   <= 1'b0;
    clk_16khz <= 1'b0;
    clk_6m25  <= 1'b0;
  end
  else
  begin
    clk_1hz   <= (t512ms) ? ~clk_1hz   : clk_1hz;	//1HZ时钟：每512ms翻转一次（=1秒周期）
    clk_4hz   <= (t128ms) ? ~clk_4hz   : clk_4hz;	//4HZ时钟：每128ms翻转一次（4*128ms=512ms=0.25秒周期）
    clk_16khz <= (t32us)  ? ~clk_16khz : clk_16khz;	//16KHZ时钟：每32us翻转一次（16kHZ=1/62.5us,32us*2=64us)
    clk_6m25  <= (t80ns)  ? ~clk_6m25  : clk_6m25;	//6.25MHZ时钟：每80ns翻转一次（6.25MHZ=160ns周期，80ns*2=160ns）
  end
end





//clk_16m6 is clk/3 Hz = 16.6MHz
/*************************************************/
// clk         = |-|_|-|_|-|_|-|_		clk：50MHz，周期 20ns（高 10ns，低 10ns）
// clk_16m6_q1 = |--|____|--|____		在 clk 上升沿触发，每 3 个 clk 周期（60ns）完成一次翻转
// clk_16m6_q2 = _|--|____|--|____		在 clk 下降沿触发，比clk_16m6_q1滞后 10ns（半个 clk 周期）
// clk_16m6	   = |---|___|---|___|---|___|---|	clk_16m6_q1 | clk_16m6_q2的结果，周期 60ns（高 30ns，低 30ns），频率 16.666MHz
/*************************************************/
reg clk_16m6_q1;				// 上升沿触发的时钟相位寄存器
reg clk_16m6_q2;         		// 下降沿触发的时钟相位寄存器       
reg [1:0] clk_16m6_q1_count;	// 上升沿计数器（2位，计数范围0-3）
reg [1:0] clk_16m6_q2_count;	// 下降沿计数器（2位）

    // -------------------- 上升沿触发逻辑 --------------------
    // 敏感列表：clk上升沿 或 reset上升沿（异步复位）
always @ (posedge clk or posedge reset) // |--|____|--|____
begin
    if (reset)
    begin
      clk_16m6_q1		<=	1'b0;
      clk_16m6_q1_count	<=	2'b00;
	end
    else if(clk_16m6_q1_count==1'b0)	// 计数器0-1时翻转，2-3时重置
    begin
       clk_16m6_q1			<=	~clk_16m6_q1;			// 取反操作（~）实现电平翻转
       clk_16m6_q1_count	<=	clk_16m6_q1_count+1'b1;	// 计数器加1
    end
    else if(clk_16m6_q1_count==1'b1)
    begin
       clk_16m6_q1 			<= 	~clk_16m6_q1;
       clk_16m6_q1_count	<=	clk_16m6_q1_count+1'b1;
     end
       else 
         begin
         clk_16m6_q1_count<=2'b00;
         end
end
    // -------------------- 下降沿触发逻辑 --------------------
    // 敏感列表：clk下降沿 或 reset上升沿（异步复位）
always @ (negedge clk or posedge reset)//_|--|____|--|____
begin 
    if (reset)
    begin
      clk_16m6_q2		<=	1'b0;
      clk_16m6_q2_count	<=	2'b00;
	end
    else if(clk_16m6_q2_count==1'b0)	// 与上升沿逻辑对称，在输入时钟下降沿触发计数和翻转
    begin	
		clk_16m6_q2			<=	~clk_16m6_q2;			// 翻转相位寄存器
		clk_16m6_q2_count	<=	clk_16m6_q2_count+1'b1;	// 计数器加1
    end
    else if(clk_16m6_q2_count==1'b1)
    begin
		clk_16m6_q2			<=	~clk_16m6_q2;
		clk_16m6_q2_count	<=	clk_16m6_q2_count+1'b1;
	end
	else 
		begin
		clk_16m6_q2_count	<=	2'b00;
		end
end
      
    // -------------------- 生成最终16MHz时钟 --------------------
    // 连续赋值：将两个相位寄存器进行或操作（|），合成最终时钟
    // 语法：assign 用于wire类型信号的组合逻辑赋值，表达式结果实时更新
assign clk_16m6 = clk_16m6_q1 | clk_16m6_q2;








// Generate 2.5Hz clock. This is not a multiple of any of the ticks so need some
// special handling by generating a 200ms. This occurs every 3 t64ms tick.
assign t64ms_tick = t32us_e & (&sec_tmr[10:0]);//生成64ms脉冲（通过sec_tmr特定位判断）
//生成2.5HZ时钟（通过移位寄存器实现分频）
always@(posedge clk or posedge reset)
begin
  if (reset)
  begin
    t200ms_tmr <= 3'b001;	//3位移位寄存器（初始值001）
    clk_2p5hz  <= 1'b0;		//2.5HZ时钟
  end
  else
  begin
    t200ms_tmr <= (t64ms_tick) ? {t200ms_tmr[1:0], t200ms_tmr[2]} : t200ms_tmr;//每收到t64ms_tick脉冲，寄存器左移一位（循环移位：001——010——100——001...)
    clk_2p5hz  <= (t64ms_tick && t200ms_tmr[2]) ? ~clk_2p5hz : clk_2p5hz;//当移位寄存器最高位为1时（每3个64ms周期，即192ms=200ms),翻转时钟
  end
end

endmodule

