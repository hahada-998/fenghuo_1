module clear_cmos (
input  wire i_clk,
input  wire i_rst_n,
input  wire i_clr_cmos_flg,
input  wire i_t64ms_tick,
output wire o_clr_cmos_done_rst,
output wire o_clr_cmos_done

);

//wire o_clr_cmos_done_rst;
reg  reg_clr_cmos_done;

assign o_clr_cmos_done = reg_clr_cmos_done;

always @(posedge i_clk or negedge i_rst_n) begin
      if (~i_rst_n) begin
		reg_clr_cmos_done  <=1'b0; 
      end
	 else if (i_clr_cmos_flg ) begin
		reg_clr_cmos_done <=1'b1;
	  end
	 else if (o_clr_cmos_done_rst) begin
		reg_clr_cmos_done <=1'b0;
	  end	  
end

edge_delay #(
  .CNTR_NBITS    (2)
) clr_cmos_delay_inst (
  .clk             (i_clk		          ),
  .reset           (~i_rst_n	          ),
  .cnt_size        (2'b10		          ),
  .cnt_step        (i_t64ms_tick	      ),
  .signal_in       (o_clr_cmos_done       ),
  .delay_output    (o_clr_cmos_done_rst   )
);

endmodule