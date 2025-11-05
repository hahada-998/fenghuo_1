module clear_nmi (
input  i_clk,
input  i_rst_n,
input  i_clr_nmi_flg,
input  i_t64ms_tick,
output o_clr_nmi_done_rst,
output o_clr_nmi_done

);

//wire o_clr_cmos_done_rst;
reg  reg_clr_nmi_done;

assign o_clr_nmi_done = reg_clr_nmi_done;

always @(posedge i_clk or negedge i_rst_n) begin
      if (~i_rst_n) begin
		reg_clr_nmi_done  <=1'b0; 
      end
	 else if (i_clr_nmi_flg ) begin
		reg_clr_nmi_done <=1'b1;
	  end
	 else if (o_clr_nmi_done_rst) begin
		reg_clr_nmi_done <=1'b0;
	  end	  
end

edge_delay #(
  .CNTR_NBITS    (2)
) clr_nmi_delay_inst (
  .clk             (i_clk		          ),
  .reset           (~i_rst_n	          ),
  .cnt_size        (2'b10		          ),
  .cnt_step        (i_t64ms_tick	      ),
  .signal_in       (o_clr_nmi_done       ),
  .delay_output    (o_clr_nmi_done_rst   )
);



endmodule