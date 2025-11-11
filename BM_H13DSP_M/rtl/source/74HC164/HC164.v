/* =============================================================================================================
模块功能
HC164 模块的主要功能是控制前面板 LED 的时钟信号和数据信号。
它通过输入的寄存器值（QQSFP28_LED_R7_reg 和 QQSFP28_LED_R8_reg）生成 LED 的数据序列，并通过时钟信号同步输出。

模块的主要功能包括：

时钟分频：生成 500ms 和 20ms 的时钟信号，用于控制 LED 的闪烁频率。
数据编码：根据输入寄存器的值生成 LED 的数据序列。
数据传输：通过时钟信号将数据序列输出到 LED。
===============================================================================================================*/
module HC164(
	input   wire   				sys_clk         	, // 系统时钟信号
	input   wire 	 			CLK_1M          	, // 1MHz 时钟信号
	input	wire 	 			sys_reset_n     	, // 系统复位信号，低电平有效
	input   wire 	 			led_refresh_flag	, // LED 刷新标志信号
		
	output 	wire    			FRONT_LED_DATA  	, // 前面板 LED 数据输出
	output 	wire    			FRONT_LED_CLK   	, // 前面板 LED 时钟输出     

    input  	wire 	[15:0] 		QSFP28_LED_R7_reg	, // 输入寄存器 R7
	input  	wire 	[15:0] 		QSFP28_LED_R8_reg	, // 输入寄存器 R8

	input  wire    				CLK_200us	 	
);
	
//****************************************
//************ Signal define *************
//****************************************
//******* parameter
parameter f_l_cnt3  			= 7'h30         		; // 数据计数器初始值

reg		[23:0] 				  r_front_led_data3 		; // 存储生成的 LED 数据序列
reg							  front_led_data_r3 		; // 当前输出的 LED 数据位
reg							  r_front_led_clk3  		; // LED 时钟信号
reg 	[6:0] 				  front_led_cnt3    		; // 数据计数器

reg							  switch_Led_cpt_d0			; // LED 刷新标志的同步寄存器
reg							  switch_Led_cpt_d1			;
reg							  switch_Led_cpt_d2			;
wire						  switch_Led_send_en		; // LED 数据发送使能信号
reg		[9:0]				  switch_Led_shift			; // LED 数据发送移位寄存器


reg  						  CLK_500ms					; // 500ms 时钟信号   
reg  						  CLK_20ms 					; // 20ms 时钟信号
reg   	[12:0] 				  cnt_500ms					; // 500ms 时钟计数器
reg   	[12:0] 				  cnt_20ms					; // 20ms 时钟计数器


//****************************************
//************ 时钟分频 ******************
//****************************************
// 生成 500ms 时钟信号
always @(posedge sys_clk or negedge sys_reset_n) begin
    if (~sys_reset_n) begin
        cnt_500ms <= 'b0;
        CLK_500ms <= 1'b0;
    end else begin
        if (CLK_200us) begin
            if (cnt_500ms != 13'd1250) begin // 0.25s
                cnt_500ms <= cnt_500ms + 1'b1;
                CLK_500ms <= CLK_500ms;
            end else begin
                cnt_500ms <= 'b0;
                CLK_500ms <= ~CLK_500ms;
            end
        end else begin
            cnt_500ms <= cnt_500ms;
            CLK_500ms <= CLK_500ms;
        end
    end
end


// 生成 20ms 时钟信号
always @(posedge sys_clk or negedge sys_reset_n) begin
    if (~sys_reset_n) begin
        cnt_20ms <= 'b0;
        CLK_20ms <= 1'b0;
    end else begin
        if (CLK_200us) begin
            if (cnt_20ms != 13'd50) begin // 0.02s
                cnt_20ms <= cnt_20ms + 1'b1;
                CLK_20ms <= CLK_20ms;
            end else begin
                cnt_20ms <= 'b0;
                CLK_20ms <= ~CLK_20ms;
            end
        end else begin
            cnt_20ms <= cnt_20ms;
            CLK_20ms <= CLK_20ms;
        end
    end
end
	
//	When two channel reception is complete, the flag signal is enabled
always @(posedge CLK_1M or negedge sys_reset_n) //Synchronization of asynchronous signals // 同步 LED 刷新标志信号
begin
	if(~sys_reset_n)begin
		switch_Led_cpt_d0	 	<= 'b0	;
		switch_Led_cpt_d1	 	<= 'b0	;
		switch_Led_cpt_d2	 	<= 'b0	;
		
	end else begin
		switch_Led_cpt_d0	 	<= led_refresh_flag ; 
		switch_Led_cpt_d1	 	<= switch_Led_cpt_d0;
		switch_Led_cpt_d2	 	<= switch_Led_cpt_d1;	
	end
end

//***************************************************
//Main switch led code decode and encode
//***************************************************
// 生成 LED 数据发送使能信号
assign	switch_Led_send_en 	=  (~switch_Led_cpt_d2) & switch_Led_cpt_d1	;//Get send enable pulse

// 生成 LED 数据发送移位寄存器	
always @(posedge CLK_1M or negedge sys_reset_n)	//To ensure that the cross-clock domain data sampling and correct
begin
	if(~sys_reset_n)begin
		switch_Led_shift	 	<= 'b0	;
	end else begin
		switch_Led_shift	 	<= {switch_Led_shift[8:0],switch_Led_send_en}	;
	end
end	
	
// Latch3: Port32-25 RGB
// 根据输入寄存器生成 LED 数据序列
always@(posedge CLK_1M)
begin
	if(switch_Led_shift[9] | CLK_20ms)begin

		r_front_led_data3[0]  	<= ~QSFP28_LED_R8_reg[12] ? (QSFP28_LED_R8_reg[15] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[15];				//Port32													
		r_front_led_data3[1]  	<= ~QSFP28_LED_R8_reg[12] ? (QSFP28_LED_R8_reg[14] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[14];		
		r_front_led_data3[2]  	<= ~QSFP28_LED_R8_reg[12] ? (QSFP28_LED_R8_reg[13] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[13];	

		r_front_led_data3[3]  	<= ~QSFP28_LED_R8_reg[8] ? (QSFP28_LED_R8_reg[11] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[11];															
		r_front_led_data3[4]  	<= ~QSFP28_LED_R8_reg[8] ? (QSFP28_LED_R8_reg[10] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[10];		
		r_front_led_data3[5]  	<= ~QSFP28_LED_R8_reg[8] ? (QSFP28_LED_R8_reg[9] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[9];	
		
		r_front_led_data3[6]  	<= ~QSFP28_LED_R8_reg[4] ? (QSFP28_LED_R8_reg[7] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[7];															
		r_front_led_data3[7]  	<= ~QSFP28_LED_R8_reg[4] ? (QSFP28_LED_R8_reg[6] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[6];		
		r_front_led_data3[8]  	<= ~QSFP28_LED_R8_reg[4] ? (QSFP28_LED_R8_reg[5] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[5];	
		
		r_front_led_data3[9]  	<= ~QSFP28_LED_R8_reg[0] ? (QSFP28_LED_R8_reg[3] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[3];														
		r_front_led_data3[10]  	<= ~QSFP28_LED_R8_reg[0] ? (QSFP28_LED_R8_reg[2] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[2];		
		r_front_led_data3[11]  	<= ~QSFP28_LED_R8_reg[0] ? (QSFP28_LED_R8_reg[1] ? 1'b1 : CLK_500ms) : QSFP28_LED_R8_reg[1];
	
		r_front_led_data3[12]  	<= ~QSFP28_LED_R7_reg[12] ? (QSFP28_LED_R7_reg[15] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[15];				//Port28															
		r_front_led_data3[13]  	<= ~QSFP28_LED_R7_reg[12] ? (QSFP28_LED_R7_reg[14] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[14];		 
		r_front_led_data3[14]  	<= ~QSFP28_LED_R7_reg[12] ? (QSFP28_LED_R7_reg[13] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[13];		

		r_front_led_data3[15]  	<= ~QSFP28_LED_R7_reg[8] ? (QSFP28_LED_R7_reg[11] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[11];															
		r_front_led_data3[16]  	<= ~QSFP28_LED_R7_reg[8] ? (QSFP28_LED_R7_reg[10] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[10];		
		r_front_led_data3[17]  	<= ~QSFP28_LED_R7_reg[8] ? (QSFP28_LED_R7_reg[9] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[9];	
		
		r_front_led_data3[18]  	<= ~QSFP28_LED_R7_reg[4] ? (QSFP28_LED_R7_reg[7] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[7];														
		r_front_led_data3[19]  	<= ~QSFP28_LED_R7_reg[4] ? (QSFP28_LED_R7_reg[6] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[6];
		r_front_led_data3[20]  	<= ~QSFP28_LED_R7_reg[4] ? (QSFP28_LED_R7_reg[5] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[5];
		
		r_front_led_data3[21]  	<= ~QSFP28_LED_R7_reg[0] ? (QSFP28_LED_R7_reg[3] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[3];														
		r_front_led_data3[22]  	<= ~QSFP28_LED_R7_reg[0] ? (QSFP28_LED_R7_reg[2] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[2];	
		r_front_led_data3[23]  	<= ~QSFP28_LED_R7_reg[0] ? (QSFP28_LED_R7_reg[1] ? 1'b1 : CLK_500ms) : QSFP28_LED_R7_reg[1];
		
		
		front_led_cnt3  <= f_l_cnt3 - 1'b1;
	end 
	else 
	begin
	if(front_led_cnt3 == 0)
	  begin
		front_led_cnt3  <= 7'b0;
	  end 
	  else 
	    begin
		  front_led_cnt3  <= front_led_cnt3 - 1'b1;
	    end
   end
end
	


//*****************************************************
//Led code of data port transmit for BCM
//*****************************************************
//12.5Mhz
always@(posedge CLK_1M)begin
	if(~sys_reset_n)
	begin
		r_front_led_clk3  <= ~r_front_led_clk3    ;
	end 
	else begin
		r_front_led_clk3  <= ~front_led_cnt3[0]	;
	end
end

always@(posedge CLK_1M)begin
	if(~sys_reset_n)
	begin
		front_led_data_r3  <=	'b0					;
	end else begin
		front_led_data_r3  <=	r_front_led_data3[front_led_cnt3[6:1]]	;	
	end
end
	

assign 	FRONT_LED_CLK  = r_front_led_clk3	;

assign 	FRONT_LED_DATA = front_led_data_r3	;
endmodule 