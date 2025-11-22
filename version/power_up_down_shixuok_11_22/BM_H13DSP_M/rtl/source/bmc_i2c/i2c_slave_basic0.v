// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                   C O P Y R I G H T     N O T I C E                       *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

 
`timescale 1ns/1ps

module i2c_slave_basic0 #(
parameter    TOTAL_STAGES = 3,
parameter    DLY_LEN = 8            //24.18MHz,330ns
)(      
// generic ports
input            wire i_clk,              // System Reset
input            wire i_rst_n, 		
input            wire i_1ms_clk,
input  wire [7:0]     i_data_in,          // parallel data in
input            wire i_addr_hit,         // when address meet, turn to high
output reg [6:0] o_I2C_ADDR_OUT,
output reg [7:0] o_data_out,         // parallel data out 
output           wire o_R_W,              // read/write signal to the reg_map bloc
output reg       o_data_vld,         // data valid from i2c 
output           wire o_start,            // o_start of the i2c cycle
output           wire o_stop,             // o_stop the i2c cycle

input            wire i_scl,
inout            wire io_sda
);
////////////////////////////////////////////////////////////////////////////////// //
// VariableS Declaration                                                           //
////////////////////////////////////////////////////////////////////////////////// //
wire w_scl_in;//scl_out;
wire w_sda_in;
reg  r_sda_en;

reg  r_sda_data;
reg  r_I2C_RW;
reg  r_start;
reg  r_stop;

wire w_rst;
wire w_scl;
wire w_sda;

//scl filter start//////
reg  r_glitchlessSignal_scl_d;
reg  r_glitchlessSignal_scl_q;
reg  [TOTAL_STAGES-1:0] r_sampledData_scl_d;
reg  [TOTAL_STAGES-1:0] r_sampledData_scl_q;
////sda filter start//////
reg  r_glitchlessSignal_sda_d;
reg  r_glitchlessSignal_sda_q;
reg  [TOTAL_STAGES-1:0] r_sampledData_sda_d;
reg  [TOTAL_STAGES-1:0] r_sampledData_sda_q;

reg  r_sda_0;// SDA信号打拍（用于检测跳变沿）
reg  r_sda_1;// SCL信号打拍（用于检测跳变沿）
wire w_sda_pos;// SDA上升沿（停止信号检测）
wire w_sda_neg;// SDA下降沿（起始信号检测）
reg  r_scl_0;
reg  r_scl_1;
wire w_scl_pos;// SCL上升沿
wire w_scl_neg;// SCL下降沿（数据采样触发）

reg  [6:0] r_I2c_address;// 暂存主机发送的7位从机地址
reg  [4:0] r_I2C_state;// I2C协议状态机（5位，支持32个状态）

reg  [DLY_LEN-1:0] r_r1_sda_dly;
wire w_r1_sda_dly ;
/////////////////////////////////
//data_in lock  2019-8-22 14:49
/////////////////////////////////
reg  r_data_in_lock;
reg  [7:0] r_data_in;
//===============================
//timeout reset function   i_1ms_clk
//===============================
reg  [7:0] r_timeout_cnt;// 超时计数器（1ms时钟累加）
reg  r_1ms_clk_0;
reg  r_1ms_clk_1;
wire w_1ms_clk_pos;
reg  r_timeout_rst_n;// 超时复位使能（低有效）
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////// //
// Continuous assignments                                                          //
////////////////////////////////////////////////////////////////////////////////// //
assign w_rst     = ~(i_rst_n & r_timeout_rst_n);// 总复位 = 系统复位无效 或 超时复位无效（低有效）
assign w_scl     = i_scl;
assign w_sda     = io_sda;
assign w_scl_in  = r_glitchlessSignal_scl_q;
assign w_sda_in  = r_glitchlessSignal_sda_q;

// assign w_scl_pos = ~r_scl_1 & r_scl_1;
// assign w_scl_neg = r_scl_1 & ~r_scl_1;
assign w_scl_pos = ~r_scl_0 & w_scl_in;
assign w_scl_neg = r_scl_0 & ~w_scl_in;
// assign w_sda_pos = !r_sda_1 & r_sda_1;  
// assign w_sda_neg = r_sda_1 & !r_sda_1;
assign w_sda_pos = !r_sda_0 & w_sda_in;   
assign w_sda_neg = r_sda_0 & !w_sda_in;


assign o_start   = r_start;
assign o_stop    = r_stop;

// assign io_sda    =  r_sda_en ? r_rSda_data_dly[DLY_LEN-1]:1'bz; //2020-8-27 22:26
assign io_sda    =  r_sda_en ? r_sda_data:1'bz; // SDA开漏输出：r_sda_en=1时，从机驱动SDA为r_sda_data；否则高阻（主机驱动）

assign o_R_W     = r_I2C_RW;// 读写标志输出（对接上层模块）

assign w_1ms_clk_pos = (~r_1ms_clk_0) & r_1ms_clk_1;
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Secuencial Logic
//////////////////////////////////////////////////////////////////////////////////

//GlitchFilter start  //////////////////////////////////
//scl filter start//////
always @(posedge i_clk or posedge w_rst)
begin
    if(w_rst)                                                    
    begin
        r_glitchlessSignal_scl_q <=      0;                           
        r_sampledData_scl_q     <=      {TOTAL_STAGES{w_scl}};    
    end
    else
    begin
        r_glitchlessSignal_scl_q <=      r_glitchlessSignal_scl_d;
        r_sampledData_scl_q     <=      r_sampledData_scl_d;
    end
end

always @*
begin
    r_sampledData_scl_d         =    {r_sampledData_scl_q[(TOTAL_STAGES-2):0],w_scl};
    r_glitchlessSignal_scl_d     =    r_glitchlessSignal_scl_q;
    if(~|r_sampledData_scl_q)
    begin
        r_glitchlessSignal_scl_d =   0;
    end
    if(&r_sampledData_scl_q)
    begin
        r_glitchlessSignal_scl_d =   1;
    end
end
//scl filter end////////
////sda filter start//////
always @(posedge i_clk or posedge w_rst)
begin
    if(w_rst)                                                    
    begin
        r_glitchlessSignal_sda_q  <= 0;                           
        r_sampledData_sda_q      <= {TOTAL_STAGES{w_sda}};    
    end
    else
    begin
        r_glitchlessSignal_sda_q  <= r_glitchlessSignal_sda_d;
        r_sampledData_sda_q      <= r_sampledData_sda_d;
    end
end

always @*
begin
    r_sampledData_sda_d         =    {r_sampledData_sda_q[(TOTAL_STAGES-2):0],w_sda};
    r_glitchlessSignal_sda_d     =    r_glitchlessSignal_sda_q;
    if(~|r_sampledData_sda_q)
    begin
        r_glitchlessSignal_sda_d =   0;
    end
    if(&r_sampledData_sda_q)
    begin
        r_glitchlessSignal_sda_d =   1;
    end
end

////sda filter end//////

//GlitchFilter end////////////////////////////////////////////////
// always @ (posedge i_clk or posedge w_rst)	               // add delay for io_sda output
// begin
    // if (w_rst)
        // r_rSda_data_dly <= {DLY_LEN{1'b1}};
    // else 
        // r_rSda_data_dly <= {r_rSda_data_dly[DLY_LEN-2:0],r_sda_data};
// end



always @ (posedge i_clk or posedge w_rst)	               // use delayed version of w_sda_in to prevent the false START			
begin
    if (w_rst)
    begin
        r_sda_0 <= 1'b0;
        r_sda_1 <= 1'b0;
    end
    else
    begin
        r_sda_0 <= w_sda_in;// 滤波后SDA打拍（一级）
        r_sda_1 <= r_sda_0;// 滤波后SCL打拍（一级）
    end
end

always @ (posedge i_clk or posedge w_rst)	               // use delayed version of w_sda_in to prevent the false START			
begin
    if (w_rst)
    begin
        r_start     <= 1'b0;
        r_stop      <= 1'b0;
    end
    else
    begin
        r_start     <= 1'b0;
        r_stop      <= 1'b0;
        if (w_scl_in & w_sda_pos)// SCL高电平时，SDA上升沿→停止信号
		begin
            r_stop  <= 1'b1;
            r_start <= 1'b0;
        end

        if (w_scl_in & w_sda_neg)// SCL高电平时，SDA下降沿→起始信号
        begin
            r_stop  <= 1'b0;
            r_start <= 1'b1;
        end
    end
end

always @ (posedge i_clk or posedge w_rst)	               // use delayed version of w_sda_in to prevent the false START			
begin
    if (w_rst)
    begin
        r_scl_0 <= 1'b0;
        r_scl_1 <= 1'b0;
    end
    else
    begin
        r_scl_0 <= w_scl_in;
        r_scl_1 <= r_scl_0;
    end
end


//==============================================================
always @ (posedge i_clk or posedge w_rst)	               // add delay for internal SDA output
begin
    if (w_rst)
        r_r1_sda_dly <= {DLY_LEN{1'b1}};
    else 
        r_r1_sda_dly <= {r_r1_sda_dly[DLY_LEN-2:0],r_sda_1};
end
assign w_r1_sda_dly = r_r1_sda_dly[DLY_LEN-1];
//==============================================================


/////////////////////////////////
//data_in lock  2019-8-22 14:49
/////////////////////////////////
always @ (posedge i_clk or posedge w_rst)	               			
begin
    if (w_rst)
        r_data_in <= 8'hff;
    else if (r_data_in_lock)
        r_data_in <= r_data_in;			
    else 
        r_data_in <= i_data_in;
end

always @ (posedge i_clk or posedge w_rst)	                			
begin
    if (w_rst)
        o_I2C_ADDR_OUT <= 7'h0;			
    else if (r_I2C_state == 5'h00)
        o_I2C_ADDR_OUT <= 7'h0;
    else if (r_I2C_state == 5'h08)
        o_I2C_ADDR_OUT <= r_I2c_address;	
end

always @ (posedge i_clk or posedge w_rst) 		
begin
    if (w_rst)
    begin
        r_I2C_state     <= 5'b0;// 复位后进入空闲状态（0x00）
        r_sda_en        <= 1'b0;// 禁止SDA驱动
        r_sda_data      <= 1'b0;
        o_data_vld      <= 1'b0;// 数据无效
        r_I2C_RW        <= 1'b0;// 默认写操作
        o_data_out      <= 8'b0;// 数据输出清零
        r_data_in_lock  <= 1'b0;
    end
    //2020-1-20 17:00  //2020-2-5 16:26
    else if(r_start)// 检测到起始信号→进入地址接收准备状态（0x13）
        r_I2C_state <= 5'h13;	
    else if(r_stop)// 检测到停止信号→返回空闲状态（0x00）
        r_I2C_state <= 5'h00;
	else
        case(r_I2C_state)                                               
        5'h00 :// 空闲状态：等待起始信号
        begin
            if (r_start)
                r_I2C_state <= 5'h13;
            r_sda_en        <= 1'b0;
            r_sda_data      <= 1'b0;
            o_data_vld      <= 1'b0;
            r_data_in_lock  <= 1'b0;
        end
        5'h13 :// 起始后准备：等待SCL下降沿，开始接收地址
        begin
            if (w_scl_neg)
                r_I2C_state <= 5'h01;// 跳转到接收地址第7位
            r_sda_en        <= 1'b0;
            r_sda_data      <= 1'b0;
            o_data_vld      <= 1'b0;
            r_data_in_lock  <= 1'b0;
        end
        5'h01 :// 5'h01~5'h07：接收7位从机地址（高位到低位）
        begin
            r_sda_en        <= 1'b0;
            r_sda_data      <= 1'b0;
            o_data_vld      <= 1'b0;
            r_data_in_lock  <= 1'b0;
            if (w_scl_neg)// SCL下降沿时采样SDA电平（地址第7位）
            begin
                r_I2c_address[6] <= w_r1_sda_dly;// w_r1_sda_dly是延迟后的SDA信号
                r_I2C_state      <= 5'h02;// 下一位地址
            end
        end
        5'h02 :
        begin
            r_sda_en        <= 1'b0;
            r_sda_data      <= 1'b0;
            o_data_vld      <= 1'b0;
            if (w_scl_neg)
            begin
                r_I2c_address[5] <= w_r1_sda_dly;
                r_I2C_state      <= 5'h03;
            end 
        end
        5'h03 :
        begin
            r_sda_en        <= 1'b0;
            r_sda_data      <= 1'b0;
            o_data_vld      <= 1'b0;
            if (w_scl_neg)
            begin
                r_I2c_address[4] <= w_r1_sda_dly;
                r_I2C_state      <= 5'h04;
            end  
        end
        5'h04 :
        begin
            r_sda_en        <= 1'b0;
            r_sda_data      <= 1'b0;
            o_data_vld      <= 1'b0;
            if (w_scl_neg)
            begin
                r_I2c_address[3] <= w_r1_sda_dly;
                r_I2C_state      <= 5'h05;
            end 
        end
        5'h05 :
        begin
            if (w_scl_neg)
            begin
                r_I2c_address[2] <= w_r1_sda_dly;
                r_I2C_state      <= 5'h06;
            end 
        end
        5'h06 :
        begin
            if (w_scl_neg)
            begin
                r_I2c_address[1] <= w_r1_sda_dly;
                r_I2C_state      <= 5'h07;
            end 
        end
        5'h07 :
        begin
            if (w_scl_neg)
            begin
                r_I2c_address[0] <= w_r1_sda_dly;
                r_I2C_state      <= 5'h08;
            end 
        end
        5'h08 :// 接收第8位：读写标志（R/W）
        begin
            if (w_scl_neg)
            begin 
                r_I2C_RW         <= w_r1_sda_dly;// 1=读，0=写
                r_I2C_state      <= 5'h09;// 跳转到ACK响应状态
            end  
        end
        5'h09 :// ACK/NACK响应：地址匹配则返回ACK（0），否则NACK（1）
        begin
            if (i_addr_hit)
            begin //ACK
                r_sda_data       <= 1'b0;
                r_sda_en         <= 1'b1;
            end
            else
            begin    //NACK
                r_sda_data       <= 1'b1;
                r_sda_en         <= 1'b0; 
            end

            if (w_scl_neg)
                if (i_addr_hit)
                    r_I2C_state  <= 5'h0A;// 匹配则进入数据读写，否则空闲
                else
                    r_I2C_state  <= 5'h00;    
        end
        5'h0A :
        begin
            o_data_vld <= 1'b0;
            if (r_I2C_RW)
            begin  //read, return MSB data 7 读操作：从机向主机发送数据（先发送最高位bit7）
                r_sda_en         <= 1'b1;// 驱动SDA
                r_sda_data       <= r_data_in[7];// r_data_in是上层传入的待返回数据

                r_data_in_lock   <= 1'b1;
            end
            else
            begin     //write  写操作：从机接收主机数据（采样SDA电平）
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
                r_I2C_state      <= 5'h0B;// 下一位数据
                o_data_out[7]    <= w_r1_sda_dly; // 写操作时，采样SDA存入o_data_out[7]
            end
        end
        5'h0B :
        begin
            if (r_I2C_RW)
            begin  //read, return MSB data 6
                r_sda_en         <= 1'b1;
                r_sda_data       <= r_data_in[6];
            end
            else
            begin     //write
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
               r_I2C_state       <= 5'h0C;
               o_data_out[6]     <= w_r1_sda_dly;
            end
        end
        5'h0C :
        begin
            if (r_I2C_RW)
            begin  //read, return MSB data 5
                r_sda_en         <= 1'b1;
                r_sda_data       <= r_data_in[5];
            end
            else
            begin     //write
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
                r_I2C_state      <= 5'h0D;
                o_data_out[5]    <= w_r1_sda_dly;
            end
        end
        5'h0D :
        begin
            if (r_I2C_RW)
            begin  //read, return MSB data 4
                r_sda_en         <= 1'b1;
                r_sda_data       <= r_data_in[4];
            end
            else
            begin     //write
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
                r_I2C_state      <= 5'h0E;
                o_data_out[4]    <= w_r1_sda_dly;
            end
        end
        5'h0E :
        begin
            if (r_I2C_RW)
            begin  //read, return MSB data 3
                r_sda_en         <= 1'b1;
                r_sda_data       <= r_data_in[3];
            end
            else
            begin     //write
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
                r_I2C_state      <= 5'h0F;
                o_data_out[3]    <= w_r1_sda_dly;
            end
        end
        5'h0F :
        begin
            if (r_I2C_RW)
            begin  //read, return MSB data 2
                r_sda_en         <= 1'b1;
                r_sda_data       <= r_data_in[2];
            end
            else
            begin     //write
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
                r_I2C_state      <= 5'h10;
                o_data_out[2]    <= w_r1_sda_dly;
            end
        end
        5'h10 :
        begin
            if (r_I2C_RW)
            begin  //read, return MSB data 1
                r_sda_en         <= 1'b1;
                r_sda_data       <= r_data_in[1];
            end
            else
            begin     //write
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
                r_I2C_state      <= 5'h11;
                o_data_out[1]    <= w_r1_sda_dly;
            end
        end
        5'h11 :
        begin
            if (r_I2C_RW)
            begin  //read, return MSB data 0
                r_sda_en         <= 1'b1;
                r_sda_data       <= r_data_in[0];
            end
            else
            begin     //write
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end

            if (w_scl_neg)
            begin
                r_I2C_state      <= 5'h12;
                o_data_out[0]    <= w_r1_sda_dly;
                o_data_vld       <= 1'b1;  //2020-8-27 20:33
            end
        end
        5'h12 :// 数据读写完成：处理ACK，准备连续读写
        begin
            r_data_in_lock       <= 1'b0;
        
            if (r_I2C_RW)
            begin  //read, wait for ACK
                r_sda_en         <= 1'b0;
                r_sda_data       <= 1'b0;
            end
            else
            begin     //write, send ACK
                r_sda_en         <= 1'b1;
                r_sda_data       <= 1'b0;
            end
              
            //o_data_vld <= 1'b1;  //2020-8-27 20:36
            if(w_scl_pos)
                o_data_vld       <= 1'b0; 
            else
                o_data_vld       <= o_data_vld; 
        	
            if (w_scl_neg)
                if (r_I2C_RW) 
                    if (w_r1_sda_dly)
                        r_I2C_state <= 5'h12;
                    else
                        r_I2C_state <= 5'h0A;
                else
                    r_I2C_state     <= 5'h0A;
        	end
        default:
        begin
		    r_data_in_lock       <= 1'b0;
            r_I2C_state          <= 5'h00;
            r_sda_en             <= 1'b0;
		    r_sda_data           <= 1'b0;
		    o_data_vld           <= 1'b0;
		end                                     // default state
        endcase
end

//===============================
//timeout reset function   i_1ms_clk(35ms)
//===============================
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
    begin
        r_1ms_clk_0 <= 1'b1;
        // r_1ms_clk_0 <= 1'b1;
        r_1ms_clk_1 <= 1'b1;    //2021-5-14 12:04
    end
    else
    begin
        r_1ms_clk_0 <= i_1ms_clk;
        // r_1ms_clk_0 <= r_1ms_clk_0;
        r_1ms_clk_1 <= r_1ms_clk_0;   //2021-5-14 12:04
    end
end

// 超时计数器：1ms时钟累加，SDA有信号时清零
always@(posedge i_clk or negedge i_rst_n) //r_sda_1
begin
    if(~i_rst_n)
        r_timeout_cnt <= 8'd0;
    else if(r_timeout_cnt >= 8'd35 || r_sda_1)// 35ms超时 或 SDA有信号→ 清零
        r_timeout_cnt <= 8'd0;
    else if(w_1ms_clk_pos && (~r_sda_1))// 1ms上升沿且SDA无信号→ 累加
        r_timeout_cnt <= r_timeout_cnt + 1'b1;
    else
        r_timeout_cnt <= r_timeout_cnt;
end

// 超时复位：35ms超时→ 触发复位（r_timeout_rst_n=0）
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
        r_timeout_rst_n <= 1'b1;
    else if(r_timeout_cnt == 8'd35)
        r_timeout_rst_n <= 1'b0;
    else
        r_timeout_rst_n <= 1'b1;
end
////////////////////////////////////////////////////////////////////////////////// //

////////////////////////////////////////////////////////////////////////////////// //
// Submodule                                                                       //
////////////////////////////////////////////////////////////////////////////////// //

//////////////////////////////////////////////////////////////////////////////////
endmodule

//--------------------------------EOF-----------------------------------------