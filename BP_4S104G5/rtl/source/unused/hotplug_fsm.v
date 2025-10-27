//=================================================================================================--
// Copyright(c) 2021, CLOUDNINEINFO.CO, Ltd, All right reserved
// Filename   : AIS03MB03.v
// Project    : CLOUDNINEINFO common code
// Author     : dingxianhua
// Date       : 2020-09-24
// Email      : dingxianhua@cloudnineinfo.com
// Company    : CLOUDNINEINFO.CO., Ltd
// Description:
// History    :
//   Date      By          Revision  Change Description
//=================================================================================================
module hotplug_fsm
( 
input      clk                  ,
input      rst_n                ,
input      cpu_i2c_pwr_en       ,				//controlled by CPU I2C, analyzed by PCA9555,VPP
input      TPS2363_PGOODA_N     ,				//Slot aux&main power good, from TPS2363, active low
input      ocp_attn_btn_n       ,		       //Attention button on RISER pushed, debug2_sw[7]
input      time1ms              ,
input      NIC_PWR_GOOD         ,                //PGD of OCP CARD
input      OCP_PRSNT_N          ,                //prsnt of OCP CARD
input      st_steady_pwrok      ,                // power sequencer current state
output     NORMAL_OPERATION_state,

output reg OCP_ONA_pwr_en     ,         //ocp tps2363 Aux power enable
output reg OCP_main_pwr_en    ,			//ocp main power enable
output reg OCP_aux_pwr_R_EN   ,			//ocp AUX power enable
output reg pcie_rst_n         ,      	//ocp PCIE RESET, active low
output reg vpp_button_pulse   ,         //VPP_Button
output reg Prsnt_OCP_n_reg    ,         //OCP CARD PRSNT
output reg Bus_switch_en_N    ,         //OCP bus switch
output reg hotplug_start      ,
output reg [3:0] current_state,
output reg [3:0] next_state
);




wire IDLE_to_OCP_CARD_PRSNT_dly;
wire ATTN_BTN_to_ONA_dly;
wire ONA_to_AUX_EN_dly;
wire AUX_to_MAIN_en_dly;
wire MAIN_to_RST_DEASSERT_dly;
wire RST_DEASSERT_to_NORMAL_OPERATION_dly;
wire RST_ASSERT_to_MAIN_POWER_DISABLE_dly;
wire MAIN_POWER_DISABLE_to_AUX_POWER_DISABLE_dly;
wire AUX_POWER_DISABLE_to_ONA_DISABLE_dly;
wire REMOVE_OCP_TO_IDLE_dly;
wire NORMAL_OPERATION_to_RST;


//reg [3:0] current_state,next_state;
reg [12:0] count;						//Counter to produce the delay
reg [15:0] count_s5_device;
reg [2:0]  ocp_attn_btn_n_reg;



//Hot plug Finite State Machine
parameter IDLE                   = 4'b0000;				//0
parameter OCP_CARD_PRSNT         = 4'b0001;				//1   
parameter ATTN_BTN_PUSHED_ENABLE = 4'b0010;				//2
parameter OCP_CARD_ONA_ENABLE    = 4'b0011;				//3
parameter AUX_POWER_EN_ENABLE    = 4'b0100;				//4
parameter MAIN_POWER_EN_ENABLE   = 4'b0101;				//5
parameter RST_DEASSERT           = 4'b0110;				//6
parameter NORMAL_OPERATION       = 4'b0111;				//7
parameter ATTN_BTN_PUSHED_DISABLE= 4'b1000;				//8
parameter RST_ASSERT             = 4'b1001;				//9
parameter MAIN_POWER_EN_DISABLE  = 4'b1010;				//A
parameter AUX_POWER_EN_DISABLE   = 4'b1011;				//B
parameter OCP_CARD_ONA_DISABLE   = 4'b1100;				//C
parameter REMOVE_OCP             = 4'b1101;				//D


			
//Hot-plug and Hot-removal sequences			
/* Signal								Power UP												Power Down
Indicator:	    |--------------------------------------------------     ~~~~    --------|
			____|                                                       ~~~~            |_______________________________________________
AUX_EN:			    |----------------------------------------------     ~~~~    -------------------------------------------|
			________|                                                                                                      |____________
MAIN_EN:                 |-----------------------------------------     ~~~~    -------------------------------------------|
			_____________|                                                                                                 |____________
CLOCK_EN_N:	----------------------------|                               ~~~~                                     |----------------------
                                        |__________________________             _________________________________|
BUS_EN_N:	----------------------------------|                         ~~~~                               |----------------------------
			                                  |____________________     ~~~~    ___________________________|
RST:		                                          |------------     ~~~~    --------------|
			__________________________________________|                                       |_________________________________________ 
 */
			


//power up delay

//Only if in the right state, will the counter keep increasing, otherwise the counter will clear



  
  always@ ( posedge clk or negedge rst_n)
  begin
    if (!rst_n)
	begin
		hotplug_start   <= 1'b0 ;
	end
    else if (((current_state == NORMAL_OPERATION) && st_steady_pwrok && (~OCP_PRSNT_N))||((current_state == IDLE) && st_steady_pwrok && OCP_PRSNT_N))   //×´Ì¬»úÔÚµÚÒ»¸öNORMAL_OPERATION×´Ì¬³öÏÖÊ±¼´¿Ì½Ó¹Ü²¢Ò»Ö±½Ó¹Ü
	begin
			hotplug_start   <= 1'b1 ;
	end		
  end

  always@ ( posedge clk or negedge rst_n)
  begin
    if (!rst_n)
        count <= 0;
    else
       // if ((current_state != next_state) & count[12]==1)
		if ((current_state != next_state) | count[12]==1)	
            count <= 0;
        else if (time1ms)
            count <= count + 1; 
  end

assign IDLE_to_OCP_CARD_PRSNT_dly = (current_state == IDLE) & (count == 200 );				                        //100ms delay, from IDLE to OCP_CARD_PRSNT
assign ATTN_BTN_to_ONA_dly        = (current_state == OCP_CARD_PRSNT) & (count == 100);				        //100ms delay, from ATTN_BTN_PUSHED_ENABLE to OCP_CARD_ONA_ENABLE
assign ONA_to_AUX_EN_dly          = (current_state == OCP_CARD_ONA_ENABLE)  & (count == 100);						//100ms delay, turn on the AUX_POWER 
assign AUX_to_MAIN_en_dly         = (current_state == AUX_POWER_EN_ENABLE)  & (count == 100);						//100ms delay, turn on the MAIN_POWER
assign MAIN_to_RST_DEASSERT_dly   = (current_state == MAIN_POWER_EN_ENABLE) & (count == 2000);						//2000ms delay,release the PCIE Reset
assign RST_DEASSERT_to_NORMAL_OPERATION_dly  = (current_state == RST_DEASSERT) & (count == 10);				      	//10ms delay, enter the NORMAL_OPERATION state
assign RST_ASSERT_to_MAIN_POWER_DISABLE_dly  = (current_state == RST_ASSERT)   & (count == 10);						//10ms delay, turn off the MAIN_POWER 
assign MAIN_POWER_DISABLE_to_AUX_POWER_DISABLE_dly  = (current_state == MAIN_POWER_EN_DISABLE)  & (count == 100);	//100ms delay, turn off the AUX_POWER
assign AUX_POWER_DISABLE_to_ONA_DISABLE_dly   = (current_state == AUX_POWER_EN_DISABLE) & (count == 100);		    //1000ms delay,turn off the ONA
assign REMOVE_OCP_TO_IDLE_dly      = (current_state == REMOVE_OCP) & (count == 100);		                        //100ms delay,enter the IDLE state 
assign NORMAL_OPERATION_to_RST     = (current_state == NORMAL_OPERATION) & (count == 3000);
//assign OCP_ONA_DISABLE_to_OCP_ONA_ENABLE = (current_state == NORMAL_OPERATION) & (count == 3000);

assign NORMAL_OPERATION_state      = NORMAL_OPERATION_to_RST;

always@ ( posedge clk or negedge rst_n)
begin
     if (!rst_n)
     begin
        ocp_attn_btn_n_reg[2:0] <= 3'b0;
     end
     else
     begin
        ocp_attn_btn_n_reg[2:0] <= {ocp_attn_btn_n_reg[1:0],ocp_attn_btn_n};
     end
end

assign ocp_attn_btn_n_pos = (ocp_attn_btn_n_reg[2:1] == 2'b01);
assign ocp_attn_btn_n_neg = (ocp_attn_btn_n_reg[2:1] == 2'b10);  
  
  always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end

		

  always@(*)
  begin
    case(current_state)
	 IDLE:begin 										//×´Ì¬£º00
      if (!OCP_PRSNT_N & IDLE_to_OCP_CARD_PRSNT_dly )
          next_state            = OCP_CARD_PRSNT;
      else
          next_state            = IDLE;
      end
	  
      OCP_CARD_PRSNT:begin		                         //×´Ì¬£º11               
		if (ATTN_BTN_to_ONA_dly)
            next_state          = ATTN_BTN_PUSHED_ENABLE;
        else
            next_state          = OCP_CARD_PRSNT;
	  end

	  ATTN_BTN_PUSHED_ENABLE:begin						 //×´Ì¬£º22
		if (cpu_i2c_pwr_en)
			next_state          = OCP_CARD_ONA_ENABLE;
		else
			next_state          = ATTN_BTN_PUSHED_ENABLE;
	  end
	  
      OCP_CARD_ONA_ENABLE:begin	 						 //×´Ì¬£º33
	   // if (ONA_to_AUX_EN_dly)	  
        if (ONA_to_AUX_EN_dly &(~TPS2363_PGOODA_N))	     //change by g14161 in 20200315
            next_state          = AUX_POWER_EN_ENABLE;
        else
            next_state          = OCP_CARD_ONA_ENABLE;
      end
	  
      AUX_POWER_EN_ENABLE:begin							//×´Ì¬£º44
		if (NIC_PWR_GOOD & AUX_to_MAIN_en_dly)
      	    next_state          = MAIN_POWER_EN_ENABLE;
      	else
      	    next_state          = AUX_POWER_EN_ENABLE;
      end
	   
      MAIN_POWER_EN_ENABLE:begin						//×´Ì¬£º55
		if (MAIN_to_RST_DEASSERT_dly)                 
			next_state          = RST_DEASSERT;
		else
			next_state          = MAIN_POWER_EN_ENABLE;
		end
		
      RST_DEASSERT:begin								//×´Ì¬£º66
        if (RST_DEASSERT_to_NORMAL_OPERATION_dly)
            next_state          = NORMAL_OPERATION;
        else
            next_state          = RST_DEASSERT;
      end

      NORMAL_OPERATION:begin							//×´Ì¬£º77
        if (ocp_attn_btn_n_pos | ocp_attn_btn_n_neg)                                       
            next_state         = ATTN_BTN_PUSHED_DISABLE;
		else if (NORMAL_OPERATION_to_RST & (!cpu_i2c_pwr_en))
            next_state         = RST_ASSERT;
        else
            next_state         = NORMAL_OPERATION;
      end
 
      ATTN_BTN_PUSHED_DISABLE:begin						//×´Ì¬£º88
        if (!cpu_i2c_pwr_en)
            next_state         = RST_ASSERT;
        else
            next_state         = ATTN_BTN_PUSHED_DISABLE;
      end
	  

	  
      RST_ASSERT:begin                                //×´Ì¬£º99
		if (RST_ASSERT_to_MAIN_POWER_DISABLE_dly)
			next_state         = MAIN_POWER_EN_DISABLE;
		else
			next_state         = RST_ASSERT;
      end
	  
	  MAIN_POWER_EN_DISABLE:begin                     //×´Ì¬£ºaa
		if (MAIN_POWER_DISABLE_to_AUX_POWER_DISABLE_dly)
			next_state         = AUX_POWER_EN_DISABLE;
		else
			next_state         = MAIN_POWER_EN_DISABLE;
	  end
	  
	  AUX_POWER_EN_DISABLE:begin                      //×´Ì¬£ºbb
		if (!NIC_PWR_GOOD & AUX_POWER_DISABLE_to_ONA_DISABLE_dly)
			next_state         = OCP_CARD_ONA_DISABLE;
		else
			next_state         = AUX_POWER_EN_DISABLE;
	  end
	  
	  OCP_CARD_ONA_DISABLE:begin                      //×´Ì¬£ºcc
		if (OCP_PRSNT_N)
			next_state         = REMOVE_OCP;
		else if(cpu_i2c_pwr_en)
		    next_state         = AUX_POWER_EN_ENABLE;                                  
		else
			next_state         = OCP_CARD_ONA_DISABLE;
	  end
	  
	  REMOVE_OCP:begin                                //×´Ì¬£ºdd
		if (REMOVE_OCP_TO_IDLE_dly)
			next_state         = IDLE;
		else
			next_state         = REMOVE_OCP;
	  end
	  
      default:begin
		next_state       = IDLE ;       
      end
    endcase
  end

  always@(*)
  begin
    case(current_state)
      IDLE: begin							    	//×´Ì¬£º00
	  OCP_ONA_pwr_en          = 1'b0;                 //ocp tps2363 Aux power enable
      OCP_main_pwr_en         = 1'b0;                 //ocp main power enable
      OCP_aux_pwr_R_EN        = 1'b0;                 //ocp aux power enable
      pcie_rst_n              = 1'b0;                 //ocp PCIE RESET, active low
	  Bus_switch_en_N         = 1'b1;
      vpp_button_pulse        = 1'b1;                 //VPP button	  
      Prsnt_OCP_n_reg         = 1'b1;                 //OCP CARD PRSNT
	  
      end
	  
      OCP_CARD_PRSNT:begin		                   //×´Ì¬£º11
	  OCP_ONA_pwr_en          = 1'b0;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b0;                 
      pcie_rst_n              = 1'b0;  
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;	  
      Prsnt_OCP_n_reg         = 1'b0;                 
      end

	  ATTN_BTN_PUSHED_ENABLE:begin                 //×´Ì¬£º22
	  OCP_ONA_pwr_en          = 1'b0;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b0;                 
      pcie_rst_n              = 1'b0;  
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b0;  	  
      Prsnt_OCP_n_reg         = 1'b0;   
	  end
	  
      OCP_CARD_ONA_ENABLE:begin	                     //×´Ì¬£º33
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b0;                 
      pcie_rst_n              = 1'b0; 
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b0;    	  
      Prsnt_OCP_n_reg         = 1'b0;   
      end
	  
      AUX_POWER_EN_ENABLE:begin                    //×´Ì¬£º44
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b1;                 
      pcie_rst_n              = 1'b0;  
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;      	  
      Prsnt_OCP_n_reg         = 1'b0;   
      end
	  
      MAIN_POWER_EN_ENABLE:begin                    //×´Ì¬£º55
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b1;                 
      OCP_aux_pwr_R_EN        = 1'b1;                 
      pcie_rst_n              = 1'b0; 
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;    	  
      Prsnt_OCP_n_reg         = 1'b0;  
	  end
		
      RST_DEASSERT:begin                            //×´Ì¬£º66
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b1;                 
      OCP_aux_pwr_R_EN        = 1'b1;                 
      pcie_rst_n              = 1'b1; 
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;      	  
      Prsnt_OCP_n_reg         = 1'b0;  
      end
	 
      NORMAL_OPERATION:begin                        //×´Ì¬£º77
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b1;                 
      OCP_aux_pwr_R_EN        = 1'b1;                 
      pcie_rst_n              = 1'b1; 
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;  //by14162     	  
      Prsnt_OCP_n_reg         = 1'b0;  
      end
	  
      ATTN_BTN_PUSHED_DISABLE:begin                  //×´Ì¬£º88
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b1;                 
      OCP_aux_pwr_R_EN        = 1'b1;                 
      pcie_rst_n              = 1'b1; 
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b0;    	  
      Prsnt_OCP_n_reg         = 1'b0;  
      end
	  
      RST_ASSERT:begin                               //×´Ì¬£º99
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b1;                 
      OCP_aux_pwr_R_EN        = 1'b1;                 
      pcie_rst_n              = 1'b0;  
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;    	  
      Prsnt_OCP_n_reg         = 1'b0;  
      end
	  
	  
	  MAIN_POWER_EN_DISABLE:begin                   //×´Ì¬£ºaa
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b1;                 
      pcie_rst_n              = 1'b0;
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;    	  
      Prsnt_OCP_n_reg         = 1'b0;  
	  end
	  
	  
	  AUX_POWER_EN_DISABLE:begin                       //×´Ì¬£ºbb
	  OCP_ONA_pwr_en          = 1'b1;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b0;                 
      pcie_rst_n              = 1'b0;  
	  Bus_switch_en_N         = 1'b0;
      vpp_button_pulse        = 1'b1;      	  
      Prsnt_OCP_n_reg         = 1'b0;  
	  end
	  
	  OCP_CARD_ONA_DISABLE:begin                          //×´Ì¬£ºcc
	  OCP_ONA_pwr_en          = 1'b0;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b0;                 
      pcie_rst_n              = 1'b0; 
	  Bus_switch_en_N         = 1'b1;
      vpp_button_pulse        = 1'b1;    	 
      Prsnt_OCP_n_reg         = 1'b0;  
	  end
	  
	  
	  REMOVE_OCP:begin                              //×´Ì¬£ºdd
	  OCP_ONA_pwr_en          = 1'b0;                 
      OCP_main_pwr_en         = 1'b0;                 
      OCP_aux_pwr_R_EN        = 1'b0;                 
      pcie_rst_n              = 1'b0;
      Bus_switch_en_N         = 1'b1;	  
      vpp_button_pulse        = 1'b1;    
      Prsnt_OCP_n_reg         = 1'b0;  
	  end
	  
	  
      default:begin
	  OCP_ONA_pwr_en          = 1'b0;                 //ocp tps2363 Aux power enable
      OCP_main_pwr_en         = 1'b0;                 //ocp main power enable
      OCP_aux_pwr_R_EN        = 1'b0;                 //ocp aux power enable
      pcie_rst_n              = 1'b0;                 //ocp PCIE RESET, active low
	  Bus_switch_en_N         = 1'b1;
      vpp_button_pulse        = 1'b1;                 //VPP button
      Prsnt_OCP_n_reg         = 1'b1;  
      end
    endcase
  end
 

endmodule


