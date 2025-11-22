module bios_cpld_i2c_ram #( 
parameter DLY_LEN       = 3   //24.18MHz,330ns
)
(
input  i_rst_n      , 
input  i_clk        ,
input  i_1ms_clk    ,	
input  i_rst_i2c_n  ,
input  i_scl        , 
inout  io_sda       ,

/*CPLD Common Register*/
input     wire     i_p0_mciog3a_cb_id0  ,  //CPU0 G3-L--J45
input     wire     i_p0_mciog3a_cb_id1  , 
input     wire     i_p0_mciog3c_cb_id0  ,  //CPU0 G3-H--J44
input     wire     i_p0_mciog3c_cb_id1  ,

input     wire     i_p0_mciop0a_cb_id0  ,  //CPU0 PE0-L--J185
input     wire     i_p0_mciop0a_cb_id1  , 
input     wire     i_p0_mciop0c_cb_id0  ,  //CPU0 PE0-H--J48
input     wire     i_p0_mciop0c_cb_id1  , 
 
input     wire     i_p0_mciop1a_cb_id0  ,  //CPU0 PE1-L--J75
input     wire     i_p0_mciop1a_cb_id1  , 
input     wire     i_p0_mciop1c_cb_id0  ,  //CPU0 PE1-H--J76
input     wire     i_p0_mciop1c_cb_id1  ,

input     wire     i_p0_mciop2a_cb_id0  ,  //CPU0 PE2-L--J40
input     wire     i_p0_mciop2a_cb_id1  , 
input     wire     i_p0_mciop2c_cb_id0  ,  //CPU0 PE2-H--J41
input     wire     i_p0_mciop2c_cb_id1  , 
 
input     wire     i_p0_mciop3a_cb_id0     ,  //CPU0 PE3-L--J42
input     wire     i_p0_mciop3a_cb_id1     ,
input     wire     i_p0_mciop3c_cb_id0     ,  //CPU0 PE3-H--J43    
input     wire     i_p0_mciop3c_cb_id1     ,   
 
input     wire     i_p1_mciog1a_cb_id0 ,  //CPU1 G1-L--J210 
input     wire     i_p1_mciog1a_cb_id1 ,  
input     wire     i_p1_mciog1c_cb_id0 ,  //CPU1 G1-H--J209
input     wire     i_p1_mciog1c_cb_id1 ,

input     wire     i_p1_mciop0a_cb_id0 ,  //CPU1 PE0-L--J73
input     wire     i_p1_mciop0a_cb_id1 ,
input     wire     i_p1_mciop0c_cb_id0 ,  //CPU1 PE0-H--J74
input     wire     i_p1_mciop0c_cb_id1 , 

input     wire     i_p1_mciop1a_cb_id0 ,  //CPU1 PE1-L--J204
input     wire     i_p1_mciop1a_cb_id1 , 
input     wire     i_p1_mciop1c_cb_id0 ,  //CPU1 PE1-H--J203
input     wire     i_p1_mciop1c_cb_id1 , 

input     wire     i_p1_mciop2a_cb_id0 , //CPU1 PE2-L--J205
input     wire     i_p1_mciop2a_cb_id1 ,
input     wire     i_p1_mciop2c_cb_id0 , //CPU1 PE2-H--J206
input     wire     i_p1_mciop2c_cb_id1 ,
 
input     wire     i_p1_mciop3a_cb_id0 , //CPU1 PE3-L--J207
input     wire     i_p1_mciop3a_cb_id1 , 
input     wire     i_p1_mciop3c_cb_id0 , //CPU1 PE3-H--J208
input     wire     i_p1_mciop3c_cb_id1 , 

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
input  wire  [7:0] i_PRODUCT_LINE_C2	           , //addr 0x00C2
input  wire  [7:0] i_PRODUCT_GEN_ID_C3             , //addr 0x00C3
input  wire  [7:0] i_SERVER_ID_C5                  , //addr 0x00C5
input  wire  [7:0] i_BOARD_ID_C6                    ,//addr 0x00C6

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////

output   wire    [7:0]   o_espi_debug_ram_1000,   //2023-3-30 add for bios debug
output   wire    [7:0]   o_espi_debug_ram_1001,
output   wire    [7:0]   o_espi_debug_ram_1002,
output   wire    [7:0]   o_espi_debug_ram_1003,
output   wire    [7:0]   o_espi_debug_ram_1004,
output   wire    [7:0]   o_espi_debug_ram_1005,
output    wire   [7:0]   o_test_reg             ,

input   wire     [7:0]   i_switch_mode,
input   wire     [7:0]   i_switch2_mode,

input   wire     [7:0]   i_espi_ram_1050,
input   wire     [7:0]   i_espi_ram_1051,
input   wire     [7:0]   i_espi_ram_1052,
input   wire     [7:0]   i_espi_ram_1053,
input   wire     [7:0]   i_espi_ram_1054,
input   wire     [7:0]   i_espi_ram_1055,
input   wire     [7:0]   i_espi_ram_1056,
input   wire     [7:0]   i_espi_ram_1057,
input   wire     [7:0]   i_espi_ram_1058,

input    wire    [7:0]   i_espi_ram_1100,
input    wire    [7:0]   i_espi_ram_1101,
input    wire    [7:0]   i_espi_ram_1102,
input    wire    [7:0]   i_espi_ram_1103,
input    wire    [7:0]   i_espi_ram_1104,
input    wire    [7:0]   i_espi_ram_1105,
input    wire    [7:0]   i_espi_ram_1106,
input    wire    [7:0]   i_espi_ram_1107,
input    wire    [7:0]   i_espi_ram_1108,
input    wire    [7:0]   i_espi_ram_1109,
input    wire    [7:0]   i_espi_ram_110a,
input    wire    [7:0]   i_espi_ram_110b,
input    wire    [7:0]   i_espi_ram_110c,
input    wire    [7:0]   i_espi_ram_110d,
input    wire    [7:0]   i_espi_ram_110e,
input    wire    [7:0]   i_espi_ram_110f,
input    wire    [7:0]   i_espi_ram_1110,
input    wire    [7:0]   i_espi_ram_1111,
input    wire    [7:0]   i_espi_ram_1112,
input    wire    [7:0]   i_espi_ram_1113

/*YRS36M2C4S RAM END */


);
////////////////////////////////////////////////////////////////////////
//for i2c slave
///////////////////////////////////////////////////////////////////////
wire w_i2c_start;
wire w_WR       ;
wire w_data_vld_pos;
wire [15:0]w_i2c_command ;
wire [7:0] w_i2c_data_out;
reg  [7:0] r_i2c_data_in;

////////////////////////////////////////////////////////////////////////////////////
//read only register
////////////////////////////////////////////////////////////////////////////////////
wire [3:0]  w_cpu0_ge3_alloc;
wire [3:0]  w_cpu0_pe0_alloc;
wire [3:0]  w_cpu0_pe1_alloc;
wire [3:0]  w_cpu0_pe2_alloc;
wire [3:0]  w_cpu0_pe3_alloc;
wire [3:0]  w_cpu1_ge1_alloc;
wire [3:0]  w_cpu1_pe0_alloc;
wire [3:0]  w_cpu1_pe1_alloc;
wire [3:0]  w_cpu1_pe2_alloc;
wire [3:0]  w_cpu1_pe3_alloc;

////////////////////////////////////////////////////////////////////////////////////
//read only register
////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
wire [7:0] w_ram_00C2                                                        ;
wire [7:0] w_ram_00C3                                                        ;
wire [7:0] w_ram_00C5                                                        ;
wire [7:0] w_ram_00C6                                                        ;

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
wire [7:0] w_ram_1000 ;
wire [7:0] w_ram_1001 ;
wire [7:0] w_ram_1002 ;
wire [7:0] w_ram_1003 ;
wire [7:0] w_ram_1004 ;
wire [7:0] w_ram_1005 ;

wire [7:0] w_ram_1010 ;
wire [7:0] w_ram_1011 ;

wire [7:0] w_ram_1050 ;
wire [7:0] w_ram_1051 ;
wire [7:0] w_ram_1052 ;
wire [7:0] w_ram_1053 ;
wire [7:0] w_ram_1054 ;
wire [7:0] w_ram_1055 ;
wire [7:0] w_ram_1056 ;
wire [7:0] w_ram_1057 ;
wire [7:0] w_ram_1058 ;

wire [7:0] w_ram_1100 ;
wire [7:0] w_ram_1101 ;
wire [7:0] w_ram_1102 ;
wire [7:0] w_ram_1103 ;
wire [7:0] w_ram_1104 ;
wire [7:0] w_ram_1105 ;
wire [7:0] w_ram_1106 ;
wire [7:0] w_ram_1107 ;
wire [7:0] w_ram_1108 ;
wire [7:0] w_ram_1109 ;
wire [7:0] w_ram_110a ;
wire [7:0] w_ram_110b ;
wire [7:0] w_ram_110c ;
wire [7:0] w_ram_110d ;
wire [7:0] w_ram_110e ;
wire [7:0] w_ram_110f ;
wire [7:0] w_ram_1110 ;
wire [7:0] w_ram_1111 ;
wire [7:0] w_ram_1112 ;
wire [7:0] w_ram_1113 ;
////////////////////////////////////////////////////////////////////////////////////
//raed & write  register
////////////////////////////////////////////////////////////////////////////////////

reg      r_reg_1006;
////////////////////////////////////////////////////////////////////////////////////
//PCIE DYNC ALLOC 
////////////////////////////////////////////////////////////////////////////////////	
pcie_dync_alloc  cpu0_ge3_alloc //2023-6-28 chg back to normal
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p0_mciog3c_cb_id1) ,  
    .i_cable_id0_h       (i_p0_mciog3c_cb_id0) ,  
    .i_cable_id1_l       (i_p0_mciog3a_cb_id1) ,  
    .i_cable_id0_l       (i_p0_mciog3a_cb_id0) ,  
    .o_pcie_date         (w_cpu0_ge3_alloc)
);

pcie_dync_alloc  cpu0_pe0_alloc
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p0_mciop0c_cb_id1) ,  
    .i_cable_id0_h       (i_p0_mciop0c_cb_id0) , 
    .i_cable_id1_l       (i_p0_mciop0a_cb_id1) ,  
    .i_cable_id0_l       (i_p0_mciop0a_cb_id0) ,
    .o_pcie_date         (w_cpu0_pe0_alloc)
);

pcie_dync_alloc  cpu0_pe1_alloc
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p0_mciop1c_cb_id1) ,   
    .i_cable_id0_h       (i_p0_mciop1c_cb_id0) , 
    .i_cable_id1_l       (i_p0_mciop1a_cb_id1) ,  
    .i_cable_id0_l       (i_p0_mciop1a_cb_id0) ,
    .o_pcie_date         (w_cpu0_pe1_alloc)
);

pcie_dync_alloc  cpu0_pe2_alloc
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p0_mciop2c_cb_id1) ,  
    .i_cable_id0_h       (i_p0_mciop2c_cb_id0) , 
    .i_cable_id1_l       (i_p0_mciop2a_cb_id1) ,  
    .i_cable_id0_l       (i_p0_mciop2a_cb_id0) ,
    .o_pcie_date         (w_cpu0_pe2_alloc)
);

pcie_dync_alloc  cpu0_pe3_alloc  //2023-6-28 chg back to normal
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p0_mciop3c_cb_id1) ,    // 1'b0
    .i_cable_id0_h       (i_p0_mciop3c_cb_id0) ,    // 1'b0
    .i_cable_id1_l       (i_p0_mciop3a_cb_id1) ,    // 1'b0
    .i_cable_id0_l       (i_p0_mciop3a_cb_id0) ,    // 1'b0
    .o_pcie_date         (w_cpu0_pe3_alloc)
);

pcie_dync_alloc  cpu1_ge1_alloc
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p1_mciog1c_cb_id1) ,   // 1'b0
    .i_cable_id0_h       (i_p1_mciog1c_cb_id0) ,   // 1'b1
    .i_cable_id1_l       (i_p1_mciog1a_cb_id1) ,   // 1'b0
    .i_cable_id0_l       (i_p1_mciog1a_cb_id0) ,   // 1'b0
    .o_pcie_date         (w_cpu1_ge1_alloc)
);

pcie_dync_alloc  cpu1_pe0_alloc
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p1_mciop0c_cb_id1) ,  
    .i_cable_id0_h       (i_p1_mciop0c_cb_id0) , 
    .i_cable_id1_l       (i_p1_mciop0a_cb_id1) ,  
    .i_cable_id0_l       (i_p1_mciop0a_cb_id0) ,
    .o_pcie_date         (w_cpu1_pe0_alloc)
);

pcie_dync_alloc  cpu1_pe1_alloc
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p1_mciop1c_cb_id1) ,  
    .i_cable_id0_h       (i_p1_mciop1c_cb_id0) , 
    .i_cable_id1_l       (i_p1_mciop1a_cb_id1) ,  
    .i_cable_id0_l       (i_p1_mciop1a_cb_id0) ,
    .o_pcie_date         (w_cpu1_pe1_alloc)
);

pcie_dync_alloc  cpu1_pe2_alloc  
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p1_mciop2c_cb_id1) ,  
    .i_cable_id0_h       (i_p1_mciop2c_cb_id0) , 
    .i_cable_id1_l       (i_p1_mciop2a_cb_id1) ,  
    .i_cable_id0_l       (i_p1_mciop2a_cb_id0) ,
    .o_pcie_date         (w_cpu1_pe2_alloc)
);

pcie_dync_alloc  cpu1_pe3_alloc   //2023-6-28 chg back to normal
(
    .i_rst_n             (i_rst_n) , 
    .i_clk               (i_clk) ,
    .i_cable_id1_h       (i_p1_mciop3c_cb_id1) ,   // 1'b0 
    .i_cable_id0_h       (i_p1_mciop3c_cb_id0) ,   // 1'b0
    .i_cable_id1_l       (i_p1_mciop3a_cb_id1) ,   // 1'b0
    .i_cable_id0_l       (i_p1_mciop3a_cb_id0) ,   // 1'b0
    .o_pcie_date         (w_cpu1_pe3_alloc)
);

////////////////////////////////////////////////////////////////////////////////////
//RW REG assignment
////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
assign w_ram_00C2 = i_PRODUCT_LINE_C2	             ;
assign w_ram_00C3 = i_PRODUCT_GEN_ID_C3              ;
assign w_ram_00C5 = i_SERVER_ID_C5                   ;
assign w_ram_00C6 = i_BOARD_ID_C6                    ;

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
assign  w_ram_1000 = {4'b1111                   , w_cpu0_ge3_alloc}  ;
assign  w_ram_1001 = {w_cpu0_pe1_alloc , w_cpu0_pe0_alloc}  ;
assign  w_ram_1002 = {w_cpu0_pe3_alloc , w_cpu0_pe2_alloc}  ; 
assign  w_ram_1003 = {4'b1111                   , w_cpu1_ge1_alloc}  ; 
assign  w_ram_1004 = {w_cpu1_pe1_alloc , w_cpu1_pe0_alloc}  ; 
assign  w_ram_1005 = {w_cpu1_pe3_alloc , w_cpu1_pe2_alloc}  ; 

assign  w_ram_1010 = i_switch_mode; 
assign  w_ram_1011 = i_switch2_mode; 

assign  w_ram_1050 = i_espi_ram_1050; 
assign  w_ram_1051 = i_espi_ram_1051; 
assign  w_ram_1052 = i_espi_ram_1052 ;
assign  w_ram_1053 = i_espi_ram_1053 ; 
assign  w_ram_1054 = i_espi_ram_1054; 
assign  w_ram_1055 = i_espi_ram_1055; 
assign  w_ram_1056 = i_espi_ram_1056 ;
assign  w_ram_1057 = i_espi_ram_1057 ; 
assign  w_ram_1058 = i_espi_ram_1058 ; 

assign  w_ram_1100 = i_espi_ram_1100 ;
assign  w_ram_1101 = i_espi_ram_1101 ;
assign  w_ram_1102 = i_espi_ram_1102 ;
assign  w_ram_1103 = i_espi_ram_1103 ;
assign  w_ram_1104 = i_espi_ram_1104 ;
assign  w_ram_1105 = i_espi_ram_1105 ;
assign  w_ram_1106 = i_espi_ram_1106 ;
assign  w_ram_1107 = i_espi_ram_1107 ;
assign  w_ram_1108 = i_espi_ram_1108 ;
assign  w_ram_1109 = i_espi_ram_1109 ;
assign  w_ram_110a = i_espi_ram_110a ;
assign  w_ram_110b = i_espi_ram_110b ;
assign  w_ram_110c = i_espi_ram_110c ;
assign  w_ram_110d = i_espi_ram_110d ;
assign  w_ram_110e = i_espi_ram_110e ;
assign  w_ram_110f = i_espi_ram_110f ;
assign  w_ram_1110 = i_espi_ram_1110 ;
assign  w_ram_1111 = i_espi_ram_1111 ;
assign  w_ram_1112 = i_espi_ram_1112 ;
assign  w_ram_1113 = i_espi_ram_1113 ;
////////////////////////////////////////////////////////////////////////////////////
//RO REG assignment
////////////////////////////////////////////////////////////////////////////////////	

assign  o_espi_debug_ram_1000 = w_ram_1000;//2023-3-30 add for bios debug
assign  o_espi_debug_ram_1001 = w_ram_1001;
assign  o_espi_debug_ram_1002 = w_ram_1002;
assign  o_espi_debug_ram_1003 = w_ram_1003;
assign  o_espi_debug_ram_1004 = w_ram_1004;
assign  o_espi_debug_ram_1005 = w_ram_1005;
assign  o_test_reg                       = r_reg_1006 ;



//////////////////////////////////////Read data/////////////////////////////////////
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
	begin
	    r_i2c_data_in  <= 8'h00;
	end
	else 
	begin
	case(w_i2c_command)

//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////
                16'h00C2: r_i2c_data_in <= w_ram_00C2;//RW
                16'h00C3: r_i2c_data_in <= w_ram_00C3;//RW
                16'h00C5: r_i2c_data_in <= w_ram_00C5;//RW
                16'h00C6: r_i2c_data_in <= w_ram_00C6;//RW
//////////////////////////////////0x00C0-0x00D0 for FIX REG/////////////////////////////////////////////////////////////////////////////                             
                16'h1000: r_i2c_data_in <= w_ram_1000;//RO
                16'h1001: r_i2c_data_in <= w_ram_1001;//RO
                16'h1002: r_i2c_data_in <= w_ram_1002;//RO
                16'h1003: r_i2c_data_in <= w_ram_1003;//RO
                16'h1004: r_i2c_data_in <= w_ram_1004;//RO
                16'h1005: r_i2c_data_in <= w_ram_1005;//RO
                16'h1006: r_i2c_data_in <= r_reg_1006;//Rw
                        
                16'h1010: r_i2c_data_in <= w_ram_1010;//RO
                16'h1011: r_i2c_data_in <= w_ram_1011;//RO

                16'h1050: r_i2c_data_in <= w_ram_1050;//RO
                16'h1051: r_i2c_data_in <= w_ram_1051;//RO
                16'h1052: r_i2c_data_in <= w_ram_1052;//RO                
                16'h1053: r_i2c_data_in <= w_ram_1053;//RO       
                16'h1054: r_i2c_data_in <= w_ram_1054;//RO
                16'h1055: r_i2c_data_in <= w_ram_1055;//RO
                16'h1056: r_i2c_data_in <= w_ram_1056;//RO                
                16'h1057: r_i2c_data_in <= w_ram_1057;//RO       
                16'h1058: r_i2c_data_in <= w_ram_1058;//RO       

                16'h1100: r_i2c_data_in <= w_ram_1100;//RO
                16'h1101: r_i2c_data_in <= w_ram_1101;//RO
                16'h1102: r_i2c_data_in <= w_ram_1102;//RO
                16'h1103: r_i2c_data_in <= w_ram_1103;//RO
                16'h1104: r_i2c_data_in <= w_ram_1104;//RO
                16'h1105: r_i2c_data_in <= w_ram_1105;//RO
                16'h1106: r_i2c_data_in <= w_ram_1106;//RO
                16'h1107: r_i2c_data_in <= w_ram_1107;//RO
                16'h1108: r_i2c_data_in <= w_ram_1108;//RO
                16'h1109: r_i2c_data_in <= w_ram_1109;//RO
                16'h110a: r_i2c_data_in <= w_ram_110a;//RO
                16'h110b: r_i2c_data_in <= w_ram_110b;//RO
                16'h110c: r_i2c_data_in <= w_ram_110c;//RO
                16'h110d: r_i2c_data_in <= w_ram_110d;//RO
                16'h110e: r_i2c_data_in <= w_ram_110e;//RO
                16'h110f: r_i2c_data_in <= w_ram_110f;//RO
                16'h1110: r_i2c_data_in <= w_ram_1110;//RO
                16'h1111: r_i2c_data_in <= w_ram_1111;//RO
                16'h1112: r_i2c_data_in <= w_ram_1112;//RO
                16'h1113: r_i2c_data_in <= w_ram_1113;//RO
		
	default: r_i2c_data_in <= 8'h00;
	endcase
	end
end
 
///////////////////////////////////////////////////////////////////////
//write data to cpld
///////////////////////////////////////////////////////////////////////
//0x0006
// always@(posedge i_clk or negedge i_rst_n) begin
    // if(~i_rst_n)  begin
        // r_reg_0006  <=8'h55;
    // end
    // else if((w_WR==1'b0)&&(w_i2c_command==16'h0006) && w_data_vld_pos)  begin
        // r_reg_0006  <= ~w_i2c_data_out;
    // end
// end

//0x1006
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)  begin
        r_reg_1006  <=8'h55;
    end
    else if((w_WR==1'b0)&&(w_i2c_command==16'h1006) && w_data_vld_pos)  begin
        r_reg_1006  <= ~w_i2c_data_out;
    end
end


///////////////////////////////////////////////////////////////////////
//i2c slave
///////////////////////////////////////////////////////////////////////
i2c_slave_bmc  #(
.DLY_LEN                 (DLY_LEN)      //3   //24.18MHz,330ns
)i2c_slave_bmc_u0(
    .i_rst_n                        (i_rst_n                  ), 
    .i_clk                            (i_clk                      ),
    .i_1ms_clk                    (i_1ms_clk              ),
    .i_rst_i2c_n                (i_rst_i2c_n          ),
    
    .i_scl                            (i_scl                      ),
    .io_sda                          (io_sda                    ),
    
    .i_i2c_address            (7'h50                      ),
    .o_i2c_start                (w_i2c_start          ),
    .o_WR                              (w_WR                        ),
    .o_data_vld_pos          (w_data_vld_pos    ),
    .o_i2c_command            (w_i2c_command      ),
    .i_i2c_data_in            (r_i2c_data_in      ),
    .o_i2c_data_out          (w_i2c_data_out    )
); 
	
endmodule 