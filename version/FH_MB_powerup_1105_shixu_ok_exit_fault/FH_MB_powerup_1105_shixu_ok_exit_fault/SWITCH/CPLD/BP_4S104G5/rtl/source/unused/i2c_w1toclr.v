module  i2c_w1toclr  ( 
					  input i_clk,
					  input i_enable,
					  input i_reset,
					  input i_signal_in,
					  input i_address,
					  input i_clr,
					  output o_signal_latch 				  
						);

always @(posedge i_clk or negedge i_reset)
 if(i_reset)
 	 begin
     reset_event <= 1'b0;
   end
	else
 	 begin
     reset_event <= i_clr ;
   end



endmodule


