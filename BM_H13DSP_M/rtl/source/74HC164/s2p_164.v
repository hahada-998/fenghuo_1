

module s2p_164 (   //#(parameter NBIT = 8)
  input                 i_clk  ,
  input                 i_rst  ,
  input                 tick   ,
  input                 CLK_1ms,
  input                 i_mr_n ,
  input  [7:0]          pi   ,
  output  reg           so   ,
  output                sld_n,
  output  reg           o_sclk
) /* synthesis syn_preserve=1 */;


reg [3:0] data_out_cnt;

reg [7:0] r_old_data;

reg r_data_chg_flag;

reg sclk;

always @(posedge CLK_1ms or posedge i_rst) begin
    if(i_rst)begin
		r_old_data <= pi;
		r_data_chg_flag <= 1'b1;
	end
	else if(r_old_data == pi) begin
	    r_old_data <= r_old_data;
		r_data_chg_flag <= 1'b0;
	end
	else begin
	    r_old_data <= pi;
	    r_data_chg_flag <= 1'b1;
	end
	
end



////////////////////////////////////////////////////////////////////////////////
//                  clock output logic                        //
////////////////////////////////////////////////////////////////////////////////
always @(posedge tick or posedge i_rst)
begin
    if(i_rst)
	begin
		sclk <= 1'b0;
	end
	else if((r_data_chg_flag == 1'b0) && (data_out_cnt  == 4'd8))
	begin
	    sclk <= 1'b0;
	end
	else 
	begin
	    //register shift clock Frequency is 500KHz
	    sclk <= ~sclk;  
	end
end

always @(negedge tick or posedge i_rst)
begin
    if(i_rst)
	begin
		o_sclk <= 1'b1;
	end else 
	begin
	    //register shift clock Frequency is 500KHz
	    o_sclk <= ~sclk;  
	end
end



////////////////////////////////////////////////////////////////////////////////
//                             counter logic                                  //
////////////////////////////////////////////////////////////////////////////////
always @(posedge sclk or posedge i_rst)
begin
    if(i_rst)
		data_out_cnt <= 4'd0;
	else if(r_data_chg_flag == 1'b1)
	    data_out_cnt <= 4'd0;
	else if(data_out_cnt<8)
	    data_out_cnt  <= data_out_cnt+1'b1;  
	else
	    data_out_cnt  <= 4'd8;
end

// wire [7:0] w_so_data;

// assign w_so_data = {pi[6],pi[5],pi[4],pi[3],pi[2],pi[1],pi[0],pi[7]} ;
////////////////////////////////////////////////////////////////////////////////
//                   register storage clock output logic                      
////////////////////////////////////////////////////////////////////////////////
always @(posedge sclk or posedge i_rst)
begin
    if(i_rst)
		begin
		so <= 1'b1;
		end
	else if(data_out_cnt<8)
		begin
		so <= pi[7-data_out_cnt];
		end
	else
		begin
		so <= so;
		end
end




assign sld_n = i_mr_n ;  //2024-2-20 add for 74AHC164  MR  PIN9  default 1 ,set 0 to reset



endmodule
