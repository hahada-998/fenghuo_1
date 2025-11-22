
module TPCM (
	input				iClk,                        
	input				iRst,                      
	input 				inTPCMPren,                  
	output				ovTPCMSpi0SW,                
	output				ovTPMSpi1SW,                 
	output				ovPwron,                     
	input				inBIOSRomTMDonen,            
	input				inBMCRomTMDonen,             
	input               i_w32mSCE,
	output [1:0]       o_now_state
	
	);
	
	reg 	rvTPMSpi1SW;
	reg		rvTPCMSpi0SW;
//	reg 	rvTPMPren; 	//230304 L00289
	parameter s0 = 3'h00 ;
	parameter s1 = 3'h01 ;
	parameter s2 = 3'h02 ;
	parameter s3 = 3'h03 ;

	
	reg [1:0] state;

    reg  r_ovPwron ;
	assign	ovTPCMSpi0SW	= rvTPCMSpi0SW;
	assign	ovTPMSpi1SW		= rvTPMSpi1SW; 
	assign  o_now_state     = state;
	assign  ovPwron     = r_ovPwron;


//由CPLD控制电源，先只给TPCM、switch、Falsh供电，同时switch把两flash信号切换到TPCM连接�
//2）延�00毫秒后检测TPCM Present#为低时，并且BMC done# 及BIOS done#为都高时，CPLD等待TPCM送出两done信号为低，分别切换switch 两flash信号到BMC和南桥，并分别释放BMC和服务器电源启动计算机。如果以�00毫秒延迟后测TPCM Present#为高或者，BMC done# 及BIOS done#为低时，切换switch到BMC和南桥直接打开所有电源让计算机正常启动�/

reg [3:0] cnt;
reg cnt_done;
always@(posedge iClk or posedge iRst) 	
if(iRst) begin
cnt<=0;
cnt_done<=1'b0;
end
else if(cnt==4'd10) begin
cnt<=cnt;
cnt_done<=1'b1;
end
else if(i_w32mSCE)begin
cnt<=cnt+1;
cnt_done<=1'b0;
end		

always@(posedge iClk or posedge iRst) 
if(iRst)  begin
rvTPCMSpi0SW	<=	1'b1;
rvTPMSpi1SW		<=  1'b1;
r_ovPwron         <=  1'b0;
state           <=  s0;
end
else begin 
case(state)

s0: begin 
		if(cnt_done)  begin  
		state<=s1;
		end
	end
				
s1: begin     
        if(inTPCMPren) begin //Normal module
		state<=s3;
		end
        else if(~inTPCMPren & inBIOSRomTMDonen & inBMCRomTMDonen) begin	//TCPM presnt
		state<=s2;
		end
		else if(~inTPCMPren & ~inBIOSRomTMDonen & ~inBMCRomTMDonen) begin  //TPM presnt
		state<=s3;
		end
	end		

s2: begin 
		if(~inBIOSRomTMDonen & ~inBMCRomTMDonen)	begin//TPCM measure finished
		rvTPCMSpi0SW	<=	1'b0;
		rvTPMSpi1SW		<=  1'b1;
		state           <=  state;
		r_ovPwron         <=  1'b1;

	   end
	end		

s3: begin  
	if(~inBIOSRomTMDonen & ~inBMCRomTMDonen)	begin//TPM presnt or Normal module
		rvTPCMSpi0SW	<=	1'b0;
		rvTPMSpi1SW		<=  1'b1;
		state           <=  state;
		r_ovPwron         <=  1'b1;
	  end 
	end

default: begin
		rvTPCMSpi0SW	<=	1'b1;
		rvTPMSpi1SW		<=  1'b1;
		r_ovPwron       <=  1'b0;
		state           <=  s0;
		end
endcase
end


	
endmodule