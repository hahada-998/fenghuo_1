module error_code(

input i_clk  ,
input i_reset,

input i_stby_failure_detected			,	// standby failure detected 
input i_po_failure_detected				,	// poweron failure detected 
input i_rt_failure_detected				,	// runtime failure detected 
input i_any_pwr_fault_det				,	// any type of power fault

input i_power_fail_err_code_clr		,	//clear sig

//input [5:0]pwrseq_sm_fault_det		,	// SM state where fault occurred

input i_p3v3_stby_fault_det				,
input i_p5v0_stby_fault_det				,
input i_p12v_stby_fault_det				,

input i_bmc_p3v3_bmc_rgm_fault_det		,
input i_bmc_p2v5_stby_fault_det			,
input i_bmc_p1v8_stby_fault_det			,
input i_bmc_p1v2_stby_fault_det			,
input i_cmu_p1v05_stby_fault_det		,	//0x0f
input i_bmc_p1v0_stby_fault_det			,	//0x10
input i_bmc_p3v3_stby_fault_det			,	//0x20
input i_bmc_p1v8_stby_pe_rc_fault_det	,	//0x21

// input i_p3v3_m2_fault_det				,
input i_p1v0_stby_m2_fault_det			,	//0x22
input i_p5v_fault_det					,	//0x19

input i_grp_b_p0_18_s5_fault_det		,	//0x05
input i_grp_b_p1_18_s5_fault_det		,
input i_grp_b_p0_33_s5_fault_det		,
input i_grp_b_p1_33_s5_fault_det		,

input i_grp_c_p0_fault_det				,	//0x1e
input i_grp_c_p1_fault_det				,	//0x1f

input i_grp_d_vddio_p0_fault_det		,	//0x11
input i_grp_d_vddio_p1_fault_det		,
input i_grp_d_soc_p0_fault_det			,
input i_grp_d_soc_p1_fault_det			,
input i_grp_d_p0_vddcore0_fault_det		,
input i_grp_d_p0_vddcore1_fault_det		,
input i_grp_d_p1_vddcore0_fault_det		,
input i_grp_d_p1_vddcore1_fault_det		,	//0x18

output wire [7:0] o_pwr_flt_code              
);
reg     [7:0]   r_timeout_code;

assign o_pwr_flt_code = r_timeout_code;

always@(posedge i_clk or negedge i_reset)begin
        if (~i_reset)
            begin
                    r_timeout_code    <= 8'h00;
            end
	else if(i_power_fail_err_code_clr)
            begin
                    r_timeout_code <= 8'h00;
            end
         else if(~i_power_fail_err_code_clr)
	begin 
                   if(i_p3v3_stby_fault_det	                   )
		    r_timeout_code    <= 8'h01;
		// else if(w_p12v_fault_det		)
		    // r_timeout_code    <= 8'h02;
		else if(i_p5v0_stby_fault_det		)
		    r_timeout_code    <= 8'h03;
		else if(i_p12v_stby_fault_det		)
		    r_timeout_code    <= 8'h04;
                   else if(i_bmc_p1v8_stby_pe_rc_fault_det	)
		    r_timeout_code   <= 8'h05;
 		else if(i_bmc_p1v0_stby_fault_det	)
		    r_timeout_code    <= 8'h06;
		else if(i_bmc_p3v3_stby_fault_det	)	
		    r_timeout_code   <= 8'h07;
 		else if(i_bmc_p3v3_bmc_rgm_fault_det	)
		    r_timeout_code    <= 8'h08;
		else if(i_bmc_p2v5_stby_fault_det	)
		    r_timeout_code    <= 8'h09;
		else if(i_bmc_p1v8_stby_fault_det	)
		    r_timeout_code    <= 8'h0a;
		else if(i_bmc_p1v2_stby_fault_det	)
		    r_timeout_code    <= 8'h0b;
		else if(i_cmu_p1v05_stby_fault_det	)
		    r_timeout_code    <= 8'h0c;           
		// else if(i_p3v3_m2_fault_det			)
		    // r_timeout_code    <= 8'h0d;
		else if(i_p1v0_stby_m2_fault_det		)
		    r_timeout_code    <= 8'h0e;
		else if(i_p5v_fault_det			         )
		    r_timeout_code    <= 8'h0f;
		else if(i_grp_b_p0_18_s5_fault_det	)
		    r_timeout_code    <= 8'h10;
		else if(i_grp_b_p1_18_s5_fault_det	)
		    r_timeout_code    <= 8'h11;
		else if(i_grp_b_p0_33_s5_fault_det	)
		    r_timeout_code    <= 8'h12;
		else if(i_grp_b_p1_33_s5_fault_det	)
		    r_timeout_code    <= 8'h13;
                   else if(i_grp_c_p0_fault_det			)
		    r_timeout_code    <= 8'h14;
		else if(i_grp_c_p1_fault_det			)
		    r_timeout_code    <= 8'h15;
		else if(i_grp_d_vddio_p0_fault_det	)
		    r_timeout_code    <= 8'h16;
		else if(i_grp_d_vddio_p1_fault_det	)
		    r_timeout_code    <= 8'h17;
		else if(i_grp_d_soc_p0_fault_det	         )
		    r_timeout_code    <= 8'h18;
		else if(i_grp_d_soc_p1_fault_det	         )
		    r_timeout_code    <= 8'h19;
		else if(i_grp_d_p0_vddcore0_fault_det	)
		    r_timeout_code    <= 8'h1a;
		else if(i_grp_d_p0_vddcore1_fault_det	)
		    r_timeout_code    <= 8'h1b;
		else if(i_grp_d_p1_vddcore0_fault_det	)
		    r_timeout_code    <= 8'h1c;
		else if(i_grp_d_p1_vddcore1_fault_det	)
		    r_timeout_code    <= 8'h1d;
	end
	else begin
	    r_timeout_code	<= 8'h00;
	end
end

endmodule

