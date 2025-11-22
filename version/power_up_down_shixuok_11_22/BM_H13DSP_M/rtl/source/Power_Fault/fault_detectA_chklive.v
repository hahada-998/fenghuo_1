module fault_detectA_chklive #(
  parameter FAULT_VEC_SIZE              = 16,	//221207 L00289
  parameter [FAULT_VEC_SIZE-1:0] RECOV_FAULT_MASK       = 40'b0000_1111_1111_0000_0000_0000_0000_0000_0000_0000,
  parameter [FAULT_VEC_SIZE-1:0] LIM_RECOV_FAULT_MASK   = 40'b0011_0000_0000_1111_1111_1111_1111_1111_1111_1001,
  parameter [FAULT_VEC_SIZE-1:0] NON_RECOV_FAULT_MASK   = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000
  
  
)
(

input wire i_clk,
input wire i_reset,
input wire i_t64ms,

//input [5:0] power_seq_sm,
input wire i_st_critical_fail,
input wire i_fault_clear,

// input wire i_p1v0_stby_m2_pg,		//221207 L00289

input wire i_p1v0_stby_bmc_pg,
//input i_p1v05_stby_pg,
input wire i_p1v2_stby_bmc_pg,
input wire i_p1v8_stby_bmc_pg,		//221207 L00289
input wire i_p1v8_stby_bmc_pe_rc_pg,	//221207 L00289
input wire i_p2v5_stby_bmc_pg,
input wire i_p3v3_stby_bmc_pg,	//221207 L00289
input wire i_p3v3_bmc_rgm_pg,
// input wire i_p12v_moc_fault_clear	,	//230310 L00289
// input wire i_p12v_moc_stby_efuse_pg,	//221207 L00289
//input i_p5v0_stby_pg,		//221207 L00289
//input i_p3v3_m2_pg,		//221207 L00289
// input wire i_io_pg_p1v8_stby,		//221203 L00289
// input wire i_io_pg_p3v3_stby,		//221203 L00289
// input wire i_io_pg_p5v0_stby,		//221203 L00289
// input wire i_io_pg_p12v_stby,		//221203 L00289

// input wire i_p1v0_stby_m2_en,	//221207 L00289

input wire i_p1v0_stby_bmc_en,
//input i_p1v05_stby_en,
input wire i_p1v2_stby_bmc_en,
input wire i_p1v8_stby_bmc_en,	//221207 L00289
input wire i_p1v8_stby_bmc_pe_rc_en,	//221207 L00289
input wire i_p2v5_stby_bmc_en,
input wire i_p3v3_stby_bmc_en,		//221207 L00289
input wire i_p3v3_bmc_rgm_en,
// input wire i_p12v_moc_stby_efuse_en,	//221207 L00289
//input i_p5v0_stby_en,			//221207 L00289
//input i_p3v3_m2_en,			//221207 L00289
// input wire i_io_en_p1v8_stby,		//221203 L00289
// input wire i_io_en_p3v3_stby,		//221203 L00289
// input wire i_io_en_p5v0_stby,		//221203 L00289
// input wire i_io_en_p12v_stby,		//221203 L00289

// output wire o_p1v0_stby_m2_fault_det,	//221207 L00289

output wire o_p1v0_stby_bmc_fault_det,
//output o_p1v05_stby_fault_det,
output wire o_p1v2_stby_bmc_fault_det,
output wire o_p1v8_stby_bmc_fault_det,
output wire o_p1v8_stby_bmc_pe_rc_fault_det,	//221207 L00289
output wire o_p2v5_stby_bmc_fault_det,
output wire o_p3v3_stby_bmc_fault_det,		//221207 L00289
output wire o_p3v3_bmc_rgm_fault_det,
// output wire o_p12v_moc_stby_efuse_fault_det,	//221207 L00289
//output o_p5v0_stby_fault_det,			//221207 L00289
//output o_p3v3_m2_fault_det,			//221207 L00289
// output wire o_io_p1v8_stby_fault_det,		//221203 L00289
// output wire o_io_p3v3_stby_fault_det,		//221203 L00289
// output wire o_io_p5v0_stby_fault_det,		//221203 L00289
// output wire o_io_p12v_stby_fault_det,		//221203 L00289

output reg  o_any_pwr_fault_det ,
output reg  o_any_recov_fault	,
output reg  o_any_lim_recov_fault,
output reg  o_any_non_recov_fault
//output 		o_any_aux_vrm_fault	//230304 L00289

);

wire i_p1v0_stby_m2_en_check;

wire i_p1v0_stby_bmc_en_check;       
//wire i_p1v05_stby_en_check;      
wire i_p1v2_stby_bmc_en_check;       
wire i_p1v8_stby_bmc_en_check;
wire i_p1v8_stby_bmc_pe_rc_en_check;	//221207 L00289      
wire i_p2v5_stby_bmc_en_check;
wire i_p3v3_stby_bmc_en_check;	  		//221207 L00289
// wire i_p12v_moc_stby_efuse_en_check; 	//221207 L00289
//wire i_p3v3_m2_en_check;         
wire i_p3v3_bmc_rgm_en_check;    
//wire i_p5v0_stby_en_check;       
// wire i_io_en_p1v8_stby_check;		//221203 L00289
// wire i_io_en_p3v3_stby_check;		//221203 L00289
// wire i_io_en_p5v0_stby_check;		//221203 L00289
// wire i_io_en_p12v_stby_check;		//221203 L00289

//wire aux_fault;
wire [FAULT_VEC_SIZE-1:0] fault_vec;
wire [FAULT_VEC_SIZE-1:0] any_recov_fault_vec;
wire [FAULT_VEC_SIZE-1:0] any_lim_recov_fault_vec;
wire [FAULT_VEC_SIZE-1:0] any_non_recov_fault_vec;
wire any_recov_fault_c;
wire any_lim_recov_fault_c;
wire any_non_recov_fault_c;

//assign st_critical_fail  = (power_seq_sm == SM_CRITICAL_FAIL);
//assign o_any_aux_vrm_fault = aux_fault;	//230304 L00289

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p1v0 stby m.2 detect
//--------------------------------------------------------------------------------------------------------------------------------------------------

// edge_delay #(.CNTR_NBITS(2)) p1v0_stby_m2_en_check_inst (                       //20220105 d50092 idms:202201040005
  // .clk           (i_clk),
  // .reset         (i_reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_t64ms),
  // .signal_in     (i_p1v0_stby_m2_en),
  // .delay_output  (i_p1v0_stby_m2_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v0_stby_m2_fault_detect_inst (     //20220105 d50092 idms:202201040005
  // .clk              (i_clk),								    //in
  // .reset            (i_reset),							    //in
  // .vrm_enable       (i_p1v0_stby_m2_en & i_p1v0_stby_m2_en_check),	    //in
  // .vrm_pgood        (i_p1v0_stby_m2_pg),							//in
  // .vrm_chklive_en   (i_p1v0_stby_m2_en_check),				        //in
  // .vrm_chklive_dis  (~i_p1v0_stby_m2_en_check),			        //in
  // .critical_fail    (i_st_critical_fail),					        //in
  // .fault_clear      (i_fault_clear),						        //in
  // .lock             (o_any_pwr_fault_det),					        //in
  // .any_vrm_fault    ( ),						                    //out
  // .vrm_fault        (o_p1v0_stby_m2_fault_det)				        //out
// );

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p1v0 stby bmc fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
                    
edge_delay #(.CNTR_NBITS(2)) p1v0_stby_bmc_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p1v0_stby_bmc_en),
  .delay_output  (i_p1v0_stby_bmc_en_check)
);


fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v0_stby_bmc_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								    //in
  .reset            (i_reset),							        //in
  .vrm_enable       (i_p1v0_stby_bmc_en & i_p1v0_stby_bmc_en_check),	//in
  .vrm_pgood        (i_p1v0_stby_bmc_pg						  ),	//in
  .vrm_chklive_en   (i_p1v0_stby_bmc_en_check),				        //in
  .vrm_chklive_dis  (~i_p1v0_stby_bmc_en_check),				    //in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det ),				        //in
  .any_vrm_fault    (   ),							            //out
  .vrm_fault        (o_p1v0_stby_bmc_fault_det )				    //out
);


//--------------------------------------------------------------------------------------------------------------------------------------------------
// p1v05 fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
/*221207 L00289
edge_delay #(.CNTR_NBITS(2)) p1v05_stby_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p1v05_stby_en),
  .delay_output  (i_p1v05_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v05_stby_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								    //in
  .reset            (i_reset),							    //in
  .vrm_enable       (i_p1v05_stby_en & i_p1v05_stby_en_check),	    //in
  .vrm_pgood        (i_p1v05_stby_pg),						//in
  .vrm_chklive_en   (i_p1v05_stby_en_check),				        //in
  .vrm_chklive_dis  (~i_p1v05_stby_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det),				        //in
  .any_vrm_fault    ( ),						                    //out
  .vrm_fault        (o_p1v05_stby_fault_det)				        //out
);
*/

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p1v2 stby bmc fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------

edge_delay #(.CNTR_NBITS(2)) p1v2_stby_bmc_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p1v2_stby_bmc_en),
  .delay_output  (i_p1v2_stby_bmc_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v2_stby_bmc_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								    //in
  .reset            (i_reset),							    //in
  .vrm_enable       (i_p1v2_stby_bmc_en & i_p1v2_stby_bmc_en_check),	    //in
  .vrm_pgood        (i_p1v2_stby_bmc_pg),						//in
  .vrm_chklive_en   (i_p1v2_stby_bmc_en_check),				        //in
  .vrm_chklive_dis  (~i_p1v2_stby_bmc_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det),				        //in
  .any_vrm_fault    ( ),						                    //out
  .vrm_fault        (o_p1v2_stby_bmc_fault_det)				        //out
);


//--------------------------------------------------------------------------------------------------------------------------------------------------
// p1v8 stby bmc fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------

edge_delay #(.CNTR_NBITS(2)) p1v8_stby_bmc_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p1v8_stby_bmc_en),
  .delay_output  (i_p1v8_stby_bmc_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v8_stby_bmc_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),										//in
  .reset            (i_reset),										//in
  .vrm_enable       (i_p1v8_stby_bmc_en & i_p1v8_stby_bmc_en_check),	//in
  .vrm_pgood        (i_p1v8_stby_bmc_pg),							//in
  .vrm_chklive_en   (i_p1v8_stby_bmc_en_check),						//in
  .vrm_chklive_dis  (~i_p1v8_stby_bmc_en_check),					//in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det),							//in
  .any_vrm_fault    ( ),						                    //out
  .vrm_fault        (o_p1v8_stby_bmc_fault_det)						//out
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p1v8_stby_bmc_pe_rc fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
//221207 L00289
edge_delay #(.CNTR_NBITS(2)) p1v8_stby_bmc_pe_rc_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p1v8_stby_bmc_pe_rc_en),
  .delay_output  (i_p1v8_stby_bmc_pe_rc_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p1v8_stby_bmc_pe_rc_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								    //in
  .reset            (i_reset),							    //in
  .vrm_enable       (i_p1v8_stby_bmc_pe_rc_en & i_p1v8_stby_bmc_pe_rc_en_check),	    //in
  .vrm_pgood        (i_p1v8_stby_bmc_pe_rc_pg),						//in
  .vrm_chklive_en   (i_p1v8_stby_bmc_pe_rc_en_check),				        //in
  .vrm_chklive_dis  (~i_p1v8_stby_bmc_pe_rc_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det),				        //in
  .any_vrm_fault    ( ),						                    //out
  .vrm_fault        (o_p1v8_stby_bmc_pe_rc_fault_det)				        //out
);


//--------------------------------------------------------------------------------------------------------------------------------------------------
// p2v5 stby bmc fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------

edge_delay #(.CNTR_NBITS(2)) p2v5_stby_bmc_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p2v5_stby_bmc_en),
  .delay_output  (i_p2v5_stby_bmc_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p2v5_stby_bmc_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								    //in
  .reset            (i_reset),							    //in
  .vrm_enable       (i_p2v5_stby_bmc_en && i_p2v5_stby_bmc_en_check),	    //in
  .vrm_pgood        (i_p2v5_stby_bmc_pg),						//in
  .vrm_chklive_en   (i_p2v5_stby_bmc_en_check),				        //in
  .vrm_chklive_dis  (~i_p2v5_stby_bmc_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det),				        //in
  .any_vrm_fault    ( ),						                    //out
  .vrm_fault        (o_p2v5_stby_bmc_fault_det)				        //out
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p3v3_stby_bmc fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------

edge_delay #(.CNTR_NBITS(2)) p3v3_stby_bmc_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p3v3_stby_bmc_en),
  .delay_output  (i_p3v3_stby_bmc_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p3v3_stby_bmc_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								        //in
  .reset            (i_reset),							        //in
  .vrm_enable       (i_p3v3_stby_bmc_en & i_p3v3_stby_bmc_en_check),	    //in
  .vrm_pgood        (i_p3v3_stby_bmc_pg),			    //in
  .vrm_chklive_en   (i_p3v3_stby_bmc_en_check),				        //in
  .vrm_chklive_dis  (~i_p3v3_stby_bmc_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					            //in
  .fault_clear      (i_fault_clear),						            //in
  .lock             (o_any_pwr_fault_det),				            //in
  .any_vrm_fault    ( ),						                        //out
  .vrm_fault        (o_p3v3_stby_bmc_fault_det)				        //out
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p3v3_bmc_rgm fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------

edge_delay #(.CNTR_NBITS(2)) p3v3_bmc_rgm_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p3v3_bmc_rgm_en),
  .delay_output  (i_p3v3_bmc_rgm_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p3v3_bmc_rgm_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								        //in
  .reset            (i_reset),							        //in
  .vrm_enable       (i_p3v3_bmc_rgm_en & i_p3v3_bmc_rgm_en_check),	    //in
  .vrm_pgood        (i_p3v3_bmc_rgm_pg),			    //in
  .vrm_chklive_en   (i_p3v3_bmc_rgm_en_check),				        //in
  .vrm_chklive_dis  (~i_p3v3_bmc_rgm_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					            //in
  .fault_clear      (i_fault_clear),						            //in
  .lock             (o_any_pwr_fault_det),				            //in
  .any_vrm_fault    ( ),						                        //out
  .vrm_fault        (o_p3v3_bmc_rgm_fault_det)				        //out
);

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p12v_moc_stby_efuse fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------

// edge_delay #(.CNTR_NBITS(2)) p12v_moc_stby_en_check_inst (                       //20220105 d50092 idms:202201040005
  // .clk           (i_clk),
  // .reset         (i_reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_t64ms),
  // .signal_in     (i_p12v_moc_stby_efuse_en),
  // .delay_output  (i_p12v_moc_stby_efuse_en_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p12v_moc_stby_efuse_fault_detect_inst (     //20220105 d50092 idms:202201040005
  // .clk              (i_clk),								        //in
  // .reset            (i_reset),							        //in
  // .vrm_enable       (i_p12v_moc_stby_efuse_en & i_p12v_moc_stby_efuse_en_check),	    //in
  // .vrm_pgood        (i_p12v_moc_stby_efuse_pg),			    //in
  // .vrm_chklive_en   (i_p12v_moc_stby_efuse_en_check),				        //in
  // .vrm_chklive_dis  (~i_p12v_moc_stby_efuse_en_check),				        //in
  // .critical_fail    (i_st_critical_fail),					            //in
  // .fault_clear      (i_p12v_moc_fault_clear),				           //in	//230310 L00289: i_fault_clear
  // .lock             (o_any_pwr_fault_det),				            //in
  // .any_vrm_fault    ( ),						                        //out
  // .vrm_fault        (o_p12v_moc_stby_efuse_fault_det)				        //out
// );

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p5v0 fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
/*221207 L00289
edge_delay #(.CNTR_NBITS(2)) p5v0_stby_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p5v0_stby_en),
  .delay_output  (i_p5v0_stby_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p5v0_stby_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								    //in
  .reset            (i_reset),							    //in
  .vrm_enable       (i_p5v0_stby_en & i_p5v0_stby_en_check),	    //in
  .vrm_pgood        (i_p5v0_stby_pg),						//in
  .vrm_chklive_en   (i_p5v0_stby_en_check),				        //in
  .vrm_chklive_dis  (~i_p5v0_stby_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det),				        //in
  .any_vrm_fault    ( ),						                    //out
  .vrm_fault        (o_p5v0_stby_fault_det)				        //out
);
*/

//--------------------------------------------------------------------------------------------------------------------------------------------------
// p3v3_m2 fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
/*221207 L00289
edge_delay #(.CNTR_NBITS(2)) p3v3_m2_en_check_inst (                       //20220105 d50092 idms:202201040005
  .clk           (i_clk),
  .reset         (i_reset),
  .cnt_size      (2'b10),
  .cnt_step      (i_t64ms),
  .signal_in     (i_p3v3_m2_en),
  .delay_output  (i_p3v3_m2_en_check)
);

fault_detectB_chklive #(.NUMBER_OF_VRM(1)) p3v3_m2_fault_detect_inst (     //20220105 d50092 idms:202201040005
  .clk              (i_clk),								    //in
  .reset            (i_reset),							    //in
  .vrm_enable       (i_p3v3_m2_en & i_p3v3_m2_en_check),	    //in
  .vrm_pgood        (i_p3v3_m2_pg),						//in
  .vrm_chklive_en   (i_p3v3_m2_en_check),				        //in
  .vrm_chklive_dis  (~i_p3v3_m2_en_check),				        //in
  .critical_fail    (i_st_critical_fail),					        //in
  .fault_clear      (i_fault_clear),						        //in
  .lock             (o_any_pwr_fault_det),				        //in
  .any_vrm_fault    ( ),						                    //out
  .vrm_fault        (o_p3v3_m2_fault_det)				        //out
);
*/

//--------------------------------------------------------------------------------------------------------------------------------------------------
// IO p1v8_stby fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
//221203 L00289
// edge_delay #(.CNTR_NBITS(2)) io_en_p1v8_stby_check_inst (                       //20220105 d50092 idms:202201040005
  // .clk           (i_clk),
  // .reset         (i_reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_t64ms),
  // .signal_in     (i_io_en_p1v8_stby),
  // .delay_output  (i_io_en_p1v8_stby_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) io_p1v8_stby_fault_detect_inst (     //20220105 d50092 idms:202201040005
  // .clk              (i_clk),									    //in
  // .reset            (i_reset),									    //in
  // .vrm_enable       (i_io_en_p1v8_stby & i_io_en_p1v8_stby_check),	//in
  // .vrm_pgood        (i_io_pg_p1v8_stby),							//in
  // .vrm_chklive_en   (i_io_en_p1v8_stby_check),				        //in
  // .vrm_chklive_dis  (~i_io_en_p1v8_stby_check),			        //in
  // .critical_fail    (i_st_critical_fail),					        //in
  // .fault_clear      (i_fault_clear),						        //in
  // .lock             (o_any_pwr_fault_det),					        //in
  // .any_vrm_fault    ( ),						                    //out
  // .vrm_fault        (o_io_p1v8_stby_fault_det)				        //out
// );

//--------------------------------------------------------------------------------------------------------------------------------------------------
// IO p3v3_stby fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
//221203 L00289
// edge_delay #(.CNTR_NBITS(2)) io_en_p3v3_stby_check_inst (                       //20220105 d50092 idms:202201040005
  // .clk           (i_clk),
  // .reset         (i_reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_t64ms),
  // .signal_in     (i_io_en_p3v3_stby),
  // .delay_output  (i_io_en_p3v3_stby_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) io_p3v3_stby_fault_detect_inst (     //20220105 d50092 idms:202201040005
  // .clk              (i_clk),									    //in
  // .reset            (i_reset),									    //in
  // .vrm_enable       (i_io_en_p3v3_stby & i_io_en_p3v3_stby_check),	//in
  // .vrm_pgood        (i_io_pg_p3v3_stby),							//in
  // .vrm_chklive_en   (i_io_en_p3v3_stby_check),				        //in
  // .vrm_chklive_dis  (~i_io_en_p3v3_stby_check),			        //in
  // .critical_fail    (i_st_critical_fail),					        //in
  // .fault_clear      (i_fault_clear),						        //in
  // .lock             (o_any_pwr_fault_det),					        //in
  // .any_vrm_fault    ( ),						                    //out
  // .vrm_fault        (o_io_p3v3_stby_fault_det)				        //out
// );

//--------------------------------------------------------------------------------------------------------------------------------------------------
// IO p5v0_stby fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
//221203 L00289
// edge_delay #(.CNTR_NBITS(2)) io_en_p5v0_stby_check_inst (                       //20220105 d50092 idms:202201040005
  // .clk           (i_clk),
  // .reset         (i_reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_t64ms),
  // .signal_in     (i_io_en_p5v0_stby),
  // .delay_output  (i_io_en_p5v0_stby_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) io_p5v0_stby_fault_detect_inst (     //20220105 d50092 idms:202201040005
  // .clk              (i_clk),									    //in
  // .reset            (i_reset),									    //in
  // .vrm_enable       (i_io_en_p5v0_stby & i_io_en_p5v0_stby_check),	//in
  // .vrm_pgood        (i_io_pg_p5v0_stby),							//in
  // .vrm_chklive_en   (i_io_en_p5v0_stby_check),				        //in
  // .vrm_chklive_dis  (~i_io_en_p5v0_stby_check),			        //in
  // .critical_fail    (i_st_critical_fail),					        //in
  // .fault_clear      (i_fault_clear),						        //in
  // .lock             (o_any_pwr_fault_det),					        //in
  // .any_vrm_fault    ( ),						                    //out
  // .vrm_fault        (o_io_p5v0_stby_fault_det)				        //out
// );

//--------------------------------------------------------------------------------------------------------------------------------------------------
// IO p12v_stby fault detect
//--------------------------------------------------------------------------------------------------------------------------------------------------
//221203 L00289
// edge_delay #(.CNTR_NBITS(2)) io_en_p12v_stby_check_inst (                       //20220105 d50092 idms:202201040005
  // .clk           (i_clk),
  // .reset         (i_reset),
  // .cnt_size      (2'b10),
  // .cnt_step      (i_t64ms),
  // .signal_in     (i_io_en_p12v_stby),
  // .delay_output  (i_io_en_p12v_stby_check)
// );

// fault_detectB_chklive #(.NUMBER_OF_VRM(1)) io_p12v_stby_fault_detect_inst (     //20220105 d50092 idms:202201040005
  // .clk              (i_clk),									    //in
  // .reset            (i_reset),									    //in
  // .vrm_enable       (i_io_en_p12v_stby & i_io_en_p12v_stby_check),	//in
  // .vrm_pgood        (i_io_pg_p12v_stby),							//in
  // .vrm_chklive_en   (i_io_en_p12v_stby_check),				        //in
  // .vrm_chklive_dis  (~i_io_en_p12v_stby_check),			        //in
  // .critical_fail    (i_st_critical_fail),					        //in
  // .fault_clear      (i_fault_clear),						        //in
  // .lock             (o_any_pwr_fault_det),					        //in
  // .any_vrm_fault    ( ),						                    //out
  // .vrm_fault        (o_io_p12v_stby_fault_det)				        //out
// );

assign fault_vec[0]  = o_p1v0_stby_bmc_fault_det	;
assign fault_vec[1]  = 1'b0;
assign fault_vec[2]  = 1'b0;
assign fault_vec[3]  = o_p1v8_stby_bmc_fault_det	;
assign fault_vec[4]  = o_p2v5_stby_bmc_fault_det	;
assign fault_vec[5]  = o_p3v3_bmc_rgm_fault_det		;
assign fault_vec[6]  = o_p3v3_stby_bmc_fault_det	;	//221207 L00289
assign fault_vec[7]  = o_p1v2_stby_bmc_fault_det;	//221207 L00289
//assign fault_vec[6]  = o_p5v0_stby_fault_det;
//assign fault_vec[7]  = o_p3v3_m2_fault_det;
assign fault_vec[8]  = o_p1v8_stby_bmc_pe_rc_fault_det	;	//221207 L00289: o_p1v05_stby_fault_det	;
assign fault_vec[9]  = 1'b0;//o_p1v0_stby_m2_fault_det
//assign fault_vec[1]  = o_io_p1v8_stby_fault_det;		//221203 L00289
//assign fault_vec[2]  = o_io_p3v3_stby_fault_det;		//221203 L00289
assign fault_vec[10] = 1'b0	;	//230306 L00289: o_p12v_moc_stby_efuse_fault_det;	//221203 L00289
assign fault_vec[11] = 1'b0;	//221203 L00289        //o_io_p1v8_stby_fault_det
assign fault_vec[12] = 1'b0;		//221203 L00289    //o_io_p3v3_stby_fault_det
assign fault_vec[13] = 1'b0;		//221203 L00289    //o_io_p5v0_stby_fault_det
assign fault_vec[14] = 1'b0;		//221203 L00289    //o_io_p12v_stby_fault_det
assign fault_vec[15] = 1'b0;		//221203 L00289

genvar i;
// Mask each fault with the corresponding bits
generate for (i = 0; i < FAULT_VEC_SIZE; i = i + 1) begin : _fault_vec_block_
  assign any_recov_fault_vec[i]     = fault_vec[i] & RECOV_FAULT_MASK[i];
  assign any_lim_recov_fault_vec[i] = fault_vec[i] & LIM_RECOV_FAULT_MASK[i];
  assign any_non_recov_fault_vec[i] = fault_vec[i] & NON_RECOV_FAULT_MASK[i];
end
endgenerate

assign any_recov_fault_c     = |any_recov_fault_vec;
assign any_lim_recov_fault_c = |any_lim_recov_fault_vec;
assign any_non_recov_fault_c = |any_non_recov_fault_vec;

always @(posedge i_clk or posedge i_reset) begin
  if (i_reset) begin
    o_any_pwr_fault_det   <= 1'b0;
    o_any_recov_fault     <= 1'b0;
    o_any_lim_recov_fault <= 1'b0;
    o_any_non_recov_fault <= 1'b0;
  end
  else begin
    o_any_pwr_fault_det   <= any_recov_fault_c | any_lim_recov_fault_c | any_non_recov_fault_c;
    o_any_recov_fault     <= any_recov_fault_c;
    o_any_lim_recov_fault <= any_lim_recov_fault_c;
    o_any_non_recov_fault <= any_non_recov_fault_c;
  end
end


endmodule