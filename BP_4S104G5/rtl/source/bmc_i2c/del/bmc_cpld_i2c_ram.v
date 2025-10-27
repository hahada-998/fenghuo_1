//file create --2022-12-11

module bmc_cpld_i2c_ram #(
parameter DLY_LEN       = 3   //24.18MHz,330ns
)
(
input  wire  i_rst_n                       ,
input  wire  i_clk                         ,
input  wire  i_scl                         ,
inout  wire  io_sda                        ,

/*YRS36FPB2U RAM START*/
/*CPLD Common Register*/
input  wire  [7:0] i_product_id                    ,//addr 0x0000
input  wire  [7:0] i_vender_id                     ,//addr 0x0001
input  wire  [7:0] i_board_id                      ,//addr 0x0002
input  wire  [7:0] i_pcb_version                   ,//addr 0x0003
input  wire  [7:0] i_bom_id                        ,//addr 0x0004
input  wire  [7:0] i_cpld_version                  ,//addr 0x0005
output wire  [7:0] o_test_reg                      ,//addr 0x0006
input  wire  [7:0] i_year                          ,//addr 0x0007
input  wire  [7:0] i_month                         ,//addr 0x0008
input  wire  [7:0] i_day                           ,//addr 0x0009
input  wire  [7:0] i_bios_id                       ,//addr 0x000a
input  wire  [7:0] i_cpld_compa_version            ,//addr 0x000b
input  wire  [7:0] i_cpld_debug_version            //addr 0x000c

/*CPLD SYSTEM Register*/

//misc--0x000D


/*YRS36FPB2U RAM END */

);
////////////////////////////////BMC I2C Slave/////////////////////////////////
reg  [7:0] iic_slave_rdata_BMC                                               ;
reg  [7:0] Test_Reg                                                          ;

wire iic_slave_scl_BMC                                                       ;
wire iic_slave_sda_in_BMC                                                    ;
wire slave_iic_sda_out_BMC                                                   ;
wire [6:0] iic_slave_device_id                                               ;
wire [7:0] iic_slave_connand_BMC                                             ;
wire [7:0] iic_slave_address_h_BMC                                           ;
wire [7:0] iic_slave_address_l_BMC                                           ;
wire [7:0] iic_slave_wdata_BMC                                               ;
wire [15:0] iic_slave_address                                                ;
wire iic_slave_write_en_BMC                                                  ;
wire iic_slave_read_en_BMC                                                   ;
wire iic_slave_busy_BMC                                                      ;
////////////////////////////////////////////////////////////////////////////////////
//read only register
////////////////////////////////////////////////////////////////////////////////////
wire [7:0] w_ram_0000                                                        ;
wire [7:0] w_ram_0001                                                        ;
wire [7:0] w_ram_0002                                                        ;
wire [7:0] w_ram_0003                                                        ;
wire [7:0] w_ram_0004                                                        ;
wire [7:0] w_ram_0005                                                        ;
wire [7:0] w_ram_0007                                                        ;
wire [7:0] w_ram_0008                                                        ;
wire [7:0] w_ram_0009                                                        ;
wire [7:0] w_ram_000a                                                        ;
wire [7:0] w_ram_000b                                                        ;
wire [7:0] w_ram_000c                                                        ;




////////////////////////////////////////////////////////////////////////////////////
//raed & write  register
////////////////////////////////////////////////////////////////////////////////////
reg [7:0] r_reg_0006                                                         ;


////////////////////////////////////////////////////////////////////////////////////
//RW REG assignment
////////////////////////////////////////////////////////////////////////////////////
assign  o_test_reg                   = r_reg_0006                            ;



////////////////////////////////////////////////////////////////////////////////////
//RO REG assignment
////////////////////////////////////////////////////////////////////////////////////
assign w_ram_0000    = i_product_id	                                         ;
assign w_ram_0001    = i_vender_id	                                         ;
assign w_ram_0002    = i_board_id	                                         ;
assign w_ram_0003    = i_pcb_version                                         ;
assign w_ram_0004    = i_bom_id                                              ;
assign w_ram_0005    = i_cpld_version                                        ;
assign w_ram_0007    = i_year                                                ;
assign w_ram_0008    = i_month                                               ;
assign w_ram_0009    = i_day                                                 ;
assign w_ram_000a	 = i_bios_id                                             ;
assign w_ram_000b	 = i_cpld_compa_version                                  ;
assign w_ram_000c	 = i_cpld_debug_version                                  ;


//////////////////////////////////////Read data/////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
	if(~i_rst_n)
		begin
			iic_slave_rdata_BMC <= 8'h00;
		end
	else if(iic_slave_read_en_BMC == 1'b1)
		case(iic_slave_address[15:0])
		    16'h0000: iic_slave_rdata_BMC <= w_ram_0000;//RO
		    16'h0001: iic_slave_rdata_BMC <= w_ram_0001;//RO
			16'h0002: iic_slave_rdata_BMC <= w_ram_0002;//RO
            16'h0003: iic_slave_rdata_BMC <= w_ram_0003;//RO
			16'h0004: iic_slave_rdata_BMC <= w_ram_0004;//RO
            16'h0005: iic_slave_rdata_BMC <= w_ram_0005;//RO
			16'h0006: iic_slave_rdata_BMC <= r_reg_0006;//RW
            16'h0007: iic_slave_rdata_BMC <= w_ram_0007;//RO
			16'h0008: iic_slave_rdata_BMC <= w_ram_0008;//RO
			16'h0009: iic_slave_rdata_BMC <= w_ram_0009;//RO
			16'h000a: iic_slave_rdata_BMC <= w_ram_000a;//RO
			16'h000b: iic_slave_rdata_BMC <= w_ram_000b;//RO
			16'h000c: iic_slave_rdata_BMC <= w_ram_000c;//RO
			

			default : iic_slave_rdata_BMC <= 8'h00     ;
		endcase
	else;
end



///////////////////////////////////Write Data////////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
	if(~i_rst_n)
		begin
			r_reg_0006[7:0] <= 8'h55                                              ;

		end
	else if(iic_slave_write_en_BMC == 1'b1)
		begin
			case(iic_slave_address[15:0])
                16'h0006 :r_reg_0006 <= ~iic_slave_wdata_BMC                      ;
				default : r_reg_0006 <= iic_slave_wdata_BMC                       ;
			endcase
		end
	else begin
	end
end


//////////////////////////////////IIC_BMC_module////////////////////////////////////////
assign iic_slave_scl_BMC = i_scl                                             ;
assign iic_slave_sda_in_BMC = io_sda                                         ;
assign io_sda = (slave_iic_sda_out_BMC == 1'b1) ? 1'bz : 1'b0                ;
assign iic_slave_device_id = {7'h10 }                                        ;//0x40
assign iic_slave_address = {iic_slave_address_h_BMC,iic_slave_address_l_BMC} ;

// iic_slave_BMC iic_slave_BMC_module(
    // .i_reset_n                (i_rst_n)                ,
    // .i_clk                    (i_clk)                  ,

    // .i_iic_scl                (i_scl)                  ,
    // .i_iic_sda_in             (iic_slave_sda_in_BMC)   ,
    // .o_iic_sda_out            (slave_iic_sda_out_BMC)  ,
    // .i_DEVICE_ID              (iic_slave_device_id)    ,
    // .i_address_width          (1'b0)                   , // 0:8bit  1:16bit
    // .o_command                (iic_slave_connand_BMC)  , // == DEVICE_ID  in this file no use
    // .o_address_h              (iic_slave_address_h_BMC),
    // .o_address_l              (iic_slave_address_l_BMC),
    // .o_wdata                  (iic_slave_wdata_BMC)    , // write :data from bmc to cpld
    // .i_rdata                  (iic_slave_rdata_BMC)    , // read : data from cpld to bmc

    // .o_write_en               (iic_slave_write_en_BMC) ,
    // .o_read_en                (iic_slave_read_en_BMC)  ,
    // .o_busy                   (iic_slave_busy_BMC)       //  no use
// );

iic_slave_BMC iic_slave_BMC_module(
    .reset_n                (i_rst_n)                ,                                           //i_
    .clk_25mhz              (i_clk)                  ,                                           //i_
																								 //
    .iic_scl                (i_scl)                  ,                                           //i_
    .iic_sda_in             (iic_slave_sda_in_BMC)   ,                                           //i_
    .iic_sda_out            (slave_iic_sda_out_BMC)  ,                                           //o_
    .DEVICE_ID              (iic_slave_device_id)    ,                                           //i_
    .address_width          (1'b0)                   , // 0:8bit  1:16bit                        //i_
    .command                (iic_slave_connand_BMC)  , // == DEVICE_ID  in this file no use      //o_
    .address_h              (iic_slave_address_h_BMC),                                           //o_
    .address_l              (iic_slave_address_l_BMC),                                           //o_
    .wdata                  (iic_slave_wdata_BMC)    , // write :data from bmc to cpld           //o_
    .rdata                  (iic_slave_rdata_BMC)    , // read : data from cpld to bmc           //i_
																								 //
    .write_en               (iic_slave_write_en_BMC) ,                                           //o_
    .read_en                (iic_slave_read_en_BMC)  ,                                           //o_
    .busy                   (iic_slave_busy_BMC)       //  no use                                //o_
);



endmodule