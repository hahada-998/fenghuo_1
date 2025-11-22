//2023-2-27 new created 
module pcie_dync_alloc
(
input  i_rst_n      , 
input  i_clk        ,

input  i_cable_id1_h  ,  
input  i_cable_id0_h  , 
input  i_cable_id1_l  ,  
input  i_cable_id0_l  ,

output reg [3:0]     o_pcie_date

);

always@(posedge i_clk or negedge i_rst_n)
begin
    if(~i_rst_n)
	begin
	    o_pcie_date <= 4'b1111;
	end
	else 
	begin
	case({i_cable_id1_h,i_cable_id0_h,i_cable_id1_l,i_cable_id0_l})
            4'b0000: o_pcie_date <= 4'b0000;   //4X4
            4'b1100: o_pcie_date <= 4'b0001;   //NA+X4+X4   4'b0000--> 4'b0001  NA+X4+X4--> X8+X4+X4  //2023-8-7 modify
            4'b0100: o_pcie_date <= 4'b0001;   //X8+X4+X4
            4'b0111: o_pcie_date <= 4'b0001;   //X8+NA
            4'b0001: o_pcie_date <= 4'b0010;   //X4+X4+X8
            4'b0011: o_pcie_date <= 4'b0010;   //X4+X4+NA   4'b0000--> 4'b0010  X4+X4+NA--> X4+X4+X8  //2023-8-7 modify
            4'b1101: o_pcie_date <= 4'b0010;   //NA+X8
            4'b0101: o_pcie_date <= 4'b0101;   //X8+X8  //2023-5-25 add 
            4'b1001: o_pcie_date <= 4'b0101;   //X8+X8  //2024-7-19 add 
            4'b0110: o_pcie_date <= 4'b0101;   //X8+X8  //2024-7-19 add 
            4'b1111: o_pcie_date <= 4'b1111;   //X16
            default: o_pcie_date <= 4'b1111;
	endcase
	end
end
	
endmodule 