module dimm_fail_event (
input i_clk,
input i_rst_n,
input  [3:0] i_dimm_pwrgd_fail_n	   		,
input  [3:0] i_dimm_pwrgd_fail_event_clr_n	,
output [3:0] o_dimm_pwrgd_fail_event		
);


reg [3:0] reg_dimm_pwrgd_fail_event;

assign o_dimm_pwrgd_fail_event = reg_dimm_pwrgd_fail_event;


always @(posedge i_clk or negedge i_rst_n) begin
      if (~i_rst_n) begin
		reg_dimm_pwrgd_fail_event[0] <=1'b0;
      end
	  else if (~i_dimm_pwrgd_fail_event_clr_n[0]) begin
		reg_dimm_pwrgd_fail_event[0] <=1'b0;
	  end
	  else if(~i_dimm_pwrgd_fail_n[0]) begin
		reg_dimm_pwrgd_fail_event[0] <=1'b1;
	  end
end

always @(posedge i_clk or negedge i_rst_n) begin
      if (~i_rst_n) begin
		reg_dimm_pwrgd_fail_event[1] <=1'b0;
      end
	  else if (~i_dimm_pwrgd_fail_event_clr_n[0]) begin
		reg_dimm_pwrgd_fail_event[1] <=1'b0;
	  end
	  else if(~i_dimm_pwrgd_fail_n[1]) begin
		reg_dimm_pwrgd_fail_event[1] <=1'b1;
	  end
end

always @(posedge i_clk or negedge i_rst_n) begin
      if (~i_rst_n) begin
		reg_dimm_pwrgd_fail_event[2] <=1'b0;
      end
	  else if (~i_dimm_pwrgd_fail_event_clr_n[0]) begin
		reg_dimm_pwrgd_fail_event[2] <=1'b0;
	  end
	  else if(~i_dimm_pwrgd_fail_n[2]) begin
		reg_dimm_pwrgd_fail_event[2] <=1'b1;
	  end
end

always @(posedge i_clk or negedge i_rst_n) begin
      if (~i_rst_n) begin
		reg_dimm_pwrgd_fail_event[3] <=1'b0;
      end
	  else if (~i_dimm_pwrgd_fail_event_clr_n[0]) begin
		reg_dimm_pwrgd_fail_event[3] <=1'b0;
	  end
	  else if(~i_dimm_pwrgd_fail_n[3]) begin
		reg_dimm_pwrgd_fail_event[3] <=1'b1;
	  end
end

endmodule