//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
//
//--------------------------------------------------------------------------------------
//Descrpton :
//
//Modfcaton Hstory:
//Date              By              Revson                Change Descrpton 

/******************************************************************************************/

module slot_number(
  input                      rst_n,
  input [7:0]                slot_number_select,
  input                      port_type,
  input [2:0]                chassis_id,
  output reg[7:0]            cpA_Slot_num ,
  output reg[7:0]            cpB_Slot_num ,
  output reg[7:0]            cpC_Slot_num ,
  input [2:0]                hbp_to_cpld0 ,
  output reg[7:0]            cpD_Slot_num 
  
);

always @(*)   
if (rst_n) 
                 begin
                 cpA_Slot_num  <= 8'h00;  //00
                 cpB_Slot_num  <= 8'h00;  //00
				 cpC_Slot_num  <= 8'h00;  //00
				 cpD_Slot_num  <= 8'h00;  //00
                 end	

 /***********************************2U 板载X8************************/  
else if((port_type==1'b0))
begin    
 case(slot_number_select)   
	 
8'h02:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h14;  //20,
                 cpB_Slot_num  <= 8'h15;  //21
				 cpC_Slot_num  <= 8'h14;  //20,
                 cpD_Slot_num  <= 8'h15;  //21				 
				 end	 
8'h12:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h16;  //22
                 cpB_Slot_num  <= 8'h17;  //23
				 cpC_Slot_num  <= 8'h16;  //22
                 cpD_Slot_num  <= 8'h17;  //23
				 end
8'h22:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h18;  //24
                 cpB_Slot_num  <= 8'h19;  //25
				 cpC_Slot_num  <= 8'h18;  //24
                 cpD_Slot_num  <= 8'h19;  //25				 
				 end
8'h32:  begin                    //RS35B08SUFA 
                 cpA_Slot_num  <= 8'h1A;  //26
                 cpB_Slot_num  <= 8'h1B;  //27
				 cpC_Slot_num  <= 8'h1A;  //26
                 cpD_Slot_num  <= 8'h1B;  //27
				 end
8'h42:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h1C;  //28
                 cpB_Slot_num  <= 8'h1D;  //29
				 cpC_Slot_num  <= 8'h1C;  //28
                 cpD_Slot_num  <= 8'h1D;  //29
				 end
8'h52:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h1E;  //30
                 cpB_Slot_num  <= 8'h1F;  //31
				 cpC_Slot_num  <= 8'h1E;  //
                 cpD_Slot_num  <= 8'h1F;  //
                 end				 
8'h62:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h20;  //32
                 cpB_Slot_num  <= 8'h21;  //33
				 cpC_Slot_num  <= 8'h20;  //
                 cpD_Slot_num  <= 8'h21;  //
                 end				 
8'h72:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h22;  //34
                 cpB_Slot_num  <= 8'h23;  //35
				 cpC_Slot_num  <= 8'h22;  //
                 cpD_Slot_num  <= 8'h23;  //
                 end				 
8'h82:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h24;  //36
                 cpB_Slot_num  <= 8'h25;  //37
				 cpC_Slot_num  <= 8'h24;  //
                 cpD_Slot_num  <= 8'h25;  //
                 end				 
8'h92:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h26;  //38
                 cpB_Slot_num  <= 8'h27;  //39
				 cpC_Slot_num  <= 8'h26;  //
                 cpD_Slot_num  <= 8'h27;  //	
				 end
8'hA2:  begin                    //RS35B08SUFA
                 cpA_Slot_num  <= 8'h28;  //40
                 cpB_Slot_num  <= 8'h29;  //41
				 cpC_Slot_num  <= 8'h28;  //
                 cpD_Slot_num  <= 8'h29;  //
                 end
8'hA3:  begin                    //RS35B08SUFA 4NVME DEFAULT
                 cpA_Slot_num  <= 8'h28;  //40
                 cpB_Slot_num  <= 8'h29;  //41
				 cpC_Slot_num  <= 8'h28;  //
                 cpD_Slot_num  <= 8'h29;  //
                 end				 
8'hB2:  begin                    //RS35B08SUFA  
                 cpA_Slot_num  <= 8'h2A;  //42
                 cpB_Slot_num  <= 8'h2B;  //43
				 cpC_Slot_num  <= 8'h2A;  //42
                 cpD_Slot_num  <= 8'h2B;  //43	
                 end				 			 
8'hB3:  begin                    //RS35B08SUFA 4NVME DEFAULT
                 cpA_Slot_num  <= 8'h2A;  //42
                 cpB_Slot_num  <= 8'h2B;  //43
				 cpC_Slot_num  <= 8'h2A;  //42
                 cpD_Slot_num  <= 8'h2B;  //43	
                 end				 

8'h64:  begin                    //RS35B12LUF
                 cpA_Slot_num  <= 8'h14;  //20,
                 cpB_Slot_num  <= 8'h15;  //21
				 cpC_Slot_num  <= 8'h14;  //20,
                 cpD_Slot_num  <= 8'h15;  //21				 
				 end
8'h66:  begin                    //RS35B12LUF
                 cpA_Slot_num  <= 8'h16;  //22
                 cpB_Slot_num  <= 8'h17;  //23
				 cpC_Slot_num  <= 8'h16;  //22
                 cpD_Slot_num  <= 8'h17;  //23
				 end
8'h68:  begin                    //RS35B12L08UPF + RS35B12LUF
                 cpA_Slot_num  <= 8'h18;  //24
                 cpB_Slot_num  <= 8'h19;  //25
				 cpC_Slot_num  <= 8'h18;  //24
                 cpD_Slot_num  <= 8'h19;  //25				 
				 end
8'h6A:  begin                    //RS35B12L08UPF + RS35B12LUF 
                 cpA_Slot_num  <= 8'h1A;  //26
                 cpB_Slot_num  <= 8'h1B;  //27
				 cpC_Slot_num  <= 8'h1A;  //26
                 cpD_Slot_num  <= 8'h1B;  //27
				 end
8'h6C:  begin                    //RS35B12L08UPF + RS35B12LUF + RS35B12L04UF
                 cpA_Slot_num  <= 8'h1C;  //28
                 cpB_Slot_num  <= 8'h1D;  //29
				 cpC_Slot_num  <= 8'h1C;  //28
                 cpD_Slot_num  <= 8'h1D;  //29
				 end
8'h6E:  begin                    //RS35B12L08UPF + RS35B12LUF + RS35B12L04UF
                 cpA_Slot_num  <= 8'h1E;  //30
                 cpB_Slot_num  <= 8'h1F;  //31
				 cpC_Slot_num  <= 8'h1E;  //30
                 cpD_Slot_num  <= 8'h1F;  //31
				 end
8'h70:  begin                    //0, 
                 cpA_Slot_num  <= 8'h20;  //32
                 cpB_Slot_num  <= 8'h21;  //33
				 cpC_Slot_num  <= 8'h20;  //32
                 cpD_Slot_num  <= 8'h21;  //33
				 end
8'h74:  begin                    //0, 
                 cpA_Slot_num  <= 8'h24;  //36
                 cpB_Slot_num  <= 8'h25;  //37
				 cpC_Slot_num  <= 8'h24;  //36
                 cpD_Slot_num  <= 8'h25;  //37
				 end
				 

8'h75:  begin                    //R4900 117, R4950 37   W17260
                 cpA_Slot_num  <= 8'h25;  //37
                 cpB_Slot_num  <= 8'h26;  //38
				 cpC_Slot_num  <= 8'h25;  //37
                 cpD_Slot_num  <= 8'h26;  //38
				 end		 
8'h77:  begin                    //R4900 119, R4950 39    W17260
                 cpA_Slot_num  <= 8'h27;  //39
                 cpB_Slot_num  <= 8'h28;  //40
				 cpC_Slot_num  <= 8'h27;  //39
                 cpD_Slot_num  <= 8'h28;  //40
				 end
8'h79:  begin                    //R4900 121, R4950 41    W17260
                 cpA_Slot_num  <= 8'h29;  //41
                 cpB_Slot_num  <= 8'h2A;  //42
				 cpC_Slot_num  <= 8'h29;  //41
                 cpD_Slot_num  <= 8'h2A;  //42
				 end
8'h7B:  begin                    //R4900 123, R4950 43   W17260
                 cpA_Slot_num  <= 8'h29;  //43
                 cpB_Slot_num  <= 8'h2A;  //44
				 cpC_Slot_num  <= 8'h29;  //43
                 cpD_Slot_num  <= 8'h2A;  //44
				 end
				 			 
				 
8'h76:  begin                    //0, 
                 cpA_Slot_num  <= 8'h26;  //38
                 cpB_Slot_num  <= 8'h27;  //39
				 cpC_Slot_num  <= 8'h26;  //38
                 cpD_Slot_num  <= 8'h27;  //39
				 end
8'h78:  begin                    //0, 
                 cpA_Slot_num  <= 8'h28;  //40
                 cpB_Slot_num  <= 8'h29;  //41
				 cpC_Slot_num  <= 8'h28;  //40
                 cpD_Slot_num  <= 8'h29;  //41
				 end
8'h7A:  begin                    //0, 
                 cpA_Slot_num  <= 8'h2A;  //42
                 cpB_Slot_num  <= 8'h2B;  //43
				 cpC_Slot_num  <= 8'h2A;  //42
                 cpD_Slot_num  <= 8'h2B;  //43
				 end



8'hB4: begin                    //0    ,中置,5x
                 cpA_Slot_num  <= 8'h3C;  //60,
                 cpB_Slot_num  <= 8'h3D;  //61
				 cpC_Slot_num  <= 8'h3C;  //60
				 cpD_Slot_num  <= 8'h3D;  //61
				 end
8'hB6: begin   				 
				 cpA_Slot_num  <= 8'h3E;  //62
				 cpB_Slot_num  <= 8'h3F;  //63				 
				 cpC_Slot_num  <= 8'h3E;  //62
				 cpD_Slot_num  <= 8'h3F;  //63
				 end
8'hB8: begin                   
                 cpA_Slot_num  <= 8'h40;  //64
                 cpB_Slot_num  <= 8'h41;  //65                  
                 cpC_Slot_num  <= 8'h40;  //64
                 cpD_Slot_num  <= 8'h41;  //65
				 end	 
				 
8'h96: begin                    //0    ,后置, R4900 150 ,R4950 50
                 cpA_Slot_num  <= 8'h32;  //50
                 cpB_Slot_num  <= 8'h33;  //51
				 cpC_Slot_num  <= 8'h32;  //50
                 cpD_Slot_num  <= 8'h33;  //51
				 end
8'h98: begin                     //2
                 cpA_Slot_num  <= 8'h34;  //52
				 cpB_Slot_num  <= 8'h35;  //53	
				 cpC_Slot_num  <= 8'h34;  //52
				 cpD_Slot_num  <= 8'h35;  //53
				 end

8'h8A: begin                    //RS65B25SXP8Y
                 cpA_Slot_num  <= 8'h25;  //37
                 cpB_Slot_num  <= 8'h26;  //38
				 cpC_Slot_num  <= 8'h25;  //
				 cpD_Slot_num  <= 8'h26;  //
                 end
8'h9A: begin                    //RS65B25SXP8Y
                 cpA_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h27:8'h37;  //39
                 cpB_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h28:8'h38;  //40
				 cpC_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h27:8'h37;  //
				 cpD_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h28:8'h38;  //
				 end
8'hAA: begin                    //RS65B25SXP8Y
                 cpA_Slot_num  <= 8'h29;  //41
                 cpB_Slot_num  <= 8'h2A;  //42
				 cpC_Slot_num  <= 8'h29;  //
				 cpD_Slot_num  <= 8'h2A;  //
				 end
				 
8'hAB: begin                    //RS65B25SXP8Y DEFAULT 4unibay
                 cpA_Slot_num  <= 8'h29;  //41
                 cpB_Slot_num  <= 8'h2A;  //42
				 cpC_Slot_num  <= 8'h29;  //
				 cpD_Slot_num  <= 8'h2A;  //
				 end
				 
8'hBA: begin                    //RS65B25SXP8Y
                 cpA_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h2B:8'h42;  //43
                 cpB_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h2C:8'h43;  //44
				 cpC_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h2B:8'h42;  //
				 cpD_Slot_num  <= (hbp_to_cpld0== 3'b110)?8'h2C:8'h43;  //
				 end				 
		
8'hBB: begin                    //RS65B25SXP8Y  DEFAULT 4unibay
                 cpA_Slot_num  <= 8'h2B;  //43
                 cpB_Slot_num  <= 8'h2C;  //44
				 cpC_Slot_num  <= 8'h2B;  //
				 cpD_Slot_num  <= 8'h2C;  //
				 end			
				 
8'h9C: begin                    //后置2SFF
                 cpA_Slot_num  <= 8'h39;  //57
                 cpB_Slot_num  <= 8'h3A;  //58
				 cpC_Slot_num  <= 8'h39;  //57
				 cpD_Slot_num  <= 8'h3A;  //58
				 end   

8'h9B: begin                    //后置4sff
                 cpA_Slot_num  <= 8'h37;  //55
                 cpB_Slot_num  <= 8'h38;  //56
				 cpC_Slot_num  <= 8'h37;  //55
				 cpD_Slot_num  <= 8'h38;  //56
				 end				 
8'h9D: begin                    //后置4sff
                 cpA_Slot_num  <= 8'h39;  //57
                 cpB_Slot_num  <= 8'h3A;  //58
				 cpC_Slot_num  <= 8'h39;  //57
				 cpD_Slot_num  <= 8'h3A;  //58
				 end				 
8'hB5: begin                    //后置4sff
                 cpA_Slot_num  <= 8'h37;  //55
                 cpB_Slot_num  <= 8'h38;  //56
				 cpC_Slot_num  <= 8'h37;  //55
				 cpD_Slot_num  <= 8'h38;  //56
				 end				 
8'hB7: begin                    //后置4sff
                 cpA_Slot_num  <= 8'h39;  //57
                 cpB_Slot_num  <= 8'h3A;  //58
				 cpC_Slot_num  <= 8'h39;  //57
				 cpD_Slot_num  <= 8'h3A;  //58
				 end					 
8'h43: begin                    //add by l19691 for 16nvme
                 cpA_Slot_num  <= 8'h1C;  //28
                 cpB_Slot_num  <= 8'h1D;  //29
				 cpC_Slot_num  <= 8'h1C;  //28
				 cpD_Slot_num  <= 8'h1D;  //29
				 end				 
8'h53: begin                    //add by l19691 for 16nvme
                 cpA_Slot_num  <= 8'h1E;  //30
                 cpB_Slot_num  <= 8'h1F;  //31
				 cpC_Slot_num  <= 8'h1E;  //30
				 cpD_Slot_num  <= 8'h1F;  //31
				 end
8'h83: begin                    //add by l19691 for 16nvme
                 cpA_Slot_num  <= 8'h24;  //36
                 cpB_Slot_num  <= 8'h25;  //37
				 cpC_Slot_num  <= 8'h24;  //36
				 cpD_Slot_num  <= 8'h25;  //37
				 end	
8'h93: begin                    //add by l19691 for 16nvme
                 cpA_Slot_num  <= 8'h26;  //38
                 cpB_Slot_num  <= 8'h27;  //39
				 cpC_Slot_num  <= 8'h26;  //38
				 cpD_Slot_num  <= 8'h27;  //39
				 end	

				 
 default:        begin                    //
                 cpA_Slot_num  <= 8'hFF;  //未使用,NVMe硬盘不在位
                 cpB_Slot_num  <= 8'hFF;  //未使用,NVMe硬盘不在位
				 cpC_Slot_num  <= 8'hFF;  //未使用,NVMe硬盘不在位
				 cpD_Slot_num  <= 8'hFF;  //未使用,NVMe硬盘不在位
				 end
 endcase
end




endmodule 
				 