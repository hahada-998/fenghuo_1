
module extrst_evt_count
(
input  wire i_clk,
input  wire i_rst_n,
input  wire i_data_in,

output wire [7:0] o_count_out
);

reg r_extrst;
reg r_extrst_ff;
reg [7:0]o_count;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
	begin
        r_extrst	<= 1'b1;
		r_extrst_ff	<= 1'b1;
	end
    else
	begin
        r_extrst	<= i_data_in;
		r_extrst_ff	<= r_extrst	;
	end
end

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n) 
        o_count	<= 8'b0;
    else if (r_extrst_ff && (~r_extrst))
        o_count	<= o_count + 1;
    else
        o_count	<= o_count;
end

assign o_count_out = o_count;

endmodule 