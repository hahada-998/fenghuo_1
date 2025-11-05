module sn74hc595(
  input i_clk,
  input i_rst,
  input i_t1us,
  
  input [47:0] iv_data,
  
  output reg o_shift_clk,
  output reg o_storage_clk,
  output reg o_seiral_data
);

reg [5:0] data_out_cnt;

////////////////////////////////////////////////////////////////////////////////
//                   register shift clock output logic                        //
////////////////////////////////////////////////////////////////////////////////
always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst)
	begin
		o_shift_clk <= 1'b0;
	end
	else
	begin
	    //register shift clock Frequency is 500KHz
	    o_shift_clk <= (i_t1us?(~o_shift_clk):o_shift_clk);  
	end
end

////////////////////////////////////////////////////////////////////////////////
//                             counter logic                                  //
////////////////////////////////////////////////////////////////////////////////
always @(negedge o_shift_clk or posedge i_rst)
begin
    if(i_rst)
		data_out_cnt <= 1'b0;
	else if(data_out_cnt<49)
	    data_out_cnt  <= data_out_cnt+1'b1;  
	else
	    data_out_cnt  <= 6'b000000;
end


////////////////////////////////////////////////////////////////////////////////
//                   register storage clock output logic                      //----------y13334 11:20 2018/6/1 Merge register storage、seiral data output---------//
////////////////////////////////////////////////////////////////////////////////
always @(negedge o_shift_clk or posedge i_rst)
begin
    if(i_rst)
		begin
		o_storage_clk <= 1'b0;
		o_seiral_data <= 1'b1;
		end
	else if(data_out_cnt<48)
		begin
	    //register shift clock Frequency is 500KHz
	    o_storage_clk <= 1'b0;  
		o_seiral_data <= iv_data[47-data_out_cnt];
		end
	else
		begin
	    o_storage_clk <= 1'b1;
		o_seiral_data <= o_seiral_data;
		end
end

////////////////////////////////////////////////////////////////////////////////
//                        seiral data output logic                            //
////////////////////////////////////////////////////////////////////////////////


//always @(negedge o_shift_clk or posedge i_rst)
//begin
//    if(i_rst)
//		o_seiral_data <= 1'b1;
//	else
//	begin
//	    //shift seiral data out at negedge of o_shift_clk
//	    if(data_out_cnt<8)
//	        o_seiral_data <= iv_data[7-data_out_cnt];
//	    else
//	        o_seiral_data <= o_seiral_data;
//	end
//end

endmodule